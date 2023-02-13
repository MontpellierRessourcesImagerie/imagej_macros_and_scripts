import json
import numpy as np
import pymeshlab
from collections import defaultdict
from scipy.spatial import KDTree, Delaunay
import open3d as o3d


def sumOfFirstIntegers(n):
    return int((n * (n+1))/2)


def fillCell(face, table):
    pairs = [(0, 1), (0, 2), (1, 2)]
    for i1, i2 in pairs:
        p1 = face[i1]
        p2 = face[i2]

        major = sumOfFirstIntegers(max(p1, p2))
        minor = min(p1, p2)
        table[major + minor] = 1


def normalize(v):
    return v / np.linalg.norm(v)


class IncidenceMatrix(object):

    def internalDataLength(self):
        return sumOfFirstIntegers(len(self.points))


    def __init__(self, pts, fcs, nmls):
        self.points        = pts
        self.faces         = fcs
        self.normals       = nmls
        # - - - - - - - - - - - -
        self.connection    = None
        self.participation = None
        self.e0            = None
        self.e1            = None


    def buildDataStructures(self):

        self.connection = np.zeros(self.internalDataLength(), dtype=np.uint8)
        self.fillTable(1)

        self.participation = [[] for i in range(len(self.points))]
        self.buildParticipation()

        self.e0 = np.zeros((self.getNumberOfEdges(), len(self.points)), dtype=np.uint8)
        self.fillE0()

        self.e1 = np.zeros((len(self.faces), self.getNumberOfEdges()), dtype=np.uint8)
        self.fillE1()

        print("Initialization done.")

    
    def fillTable(self, nbThreads):
        print("Processing raw incidence map...")
        for face in self.faces:
            fillCell(face, self.connection)
    

    def buildParticipation(self):
        print("Processing participation map...")
        for idxFace, face in enumerate(self.faces):
            for vertex in face:
                self.participation[vertex].append(idxFace)
    

    def fillE1(self):
        print("Processing E1...")
        nn = np.nonzero(self.e0)
        d = defaultdict(list)

        edgesIdcs = nn[0]
        vrtcsIdcs = nn[1]

        for i in range(0, len(edgesIdcs), 2):
            t = (edgesIdcs[i], vrtcsIdcs[i], vrtcsIdcs[i+1])
            d[vrtcsIdcs[i]].append(t)
            d[vrtcsIdcs[i+1]].append(t)

        # d[vertex index]  =>  (edge index, v1 index, v2 index)

        for faceIdx, face in enumerate(self.faces):
            for vertex in face:
                for idx, v1, v2 in d[vertex]:
                    if (v1 in face) and (v2 in face):
                        self.e1[faceIdx, idx] = 1
    

    def fillE0(self):
        print("Processing E0...")
        current = 0 # Increments for each edge
        for row in range(len(self.points)):
            for column in range(row):
                if self.get(row, column) == 1:
                    self.e0[current, row] = 1
                    self.e0[current, column] = 1
                    current += 1


    # Only individual edges are counted. (3, 8) and (8, 3) count only as one edge.
    def getNumberOfEdges(self):
        return np.count_nonzero(self.connection)

    
    def get(self, row, column):
        if column > row:
            row, column = column, row
        return self.connection[sumOfFirstIntegers(row) + column]

    
    def set(self, row, column, val):
        if column > row:
            row, column = column, row
        self.connection[sumOfFirstIntegers(row) + column] = val


# Brings the geometry to the center of the world
def geometryToOrigin(mesh):
    vertices = mesh.vertex_matrix()
    avg = np.average(vertices, axis=0)

    for i in range(len(vertices)):
        vertices[i] -= avg

    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=mesh.face_matrix())


# Shrink a mesh along its vertices' normals
def shrink(mesh, shrinkingFactor=0.18):
    normals  = np.array([normalize(n) for n in mesh.vertex_normal_matrix()])
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()

    for idx, N in enumerate(normals):
        vertices[idx] -= shrinkingFactor * N
    
    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=faces)


def buildNeighborhoodGraph(mesh):
    nhg = [set() for i in range(mesh.vertex_number())]
    pairs = [(0, 1), (0, 2), (1, 2)]

    for face in mesh.face_matrix():
        for i, j in pairs:
            nhg[face[i]].add(face[j])
            nhg[face[j]].add(face[i])
        
    return nhg


def averageSmoothing(mesh, graph):
    
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()
    newVerts = np.zeros(vertices.shape)

    for v in range(len(vertices)):
        newVerts[v] = np.average(vertices[list(graph[v])], axis=0)
    
    return pymeshlab.Mesh(vertex_matrix=newVerts, face_matrix=faces)
        


def flatten(mesh, original, incidence, radius=0.6, dotLimit=0.0):
    
    sources  = original.vertex_matrix()
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()
    normals  = mesh.vertex_normal_matrix()
    
    # Initializing variables
    kdtree    = KDTree(vertices, leafsize=5)
    dst, idx  = kdtree.query(np.array([0, 0, 0]), 1)
    newPoints = []
    removed   = set()
    marking   = np.array([{'visited': -1, 'count': 0} for i in range(len(vertices))])
    queue     = [idx] # The seed is the closest vertex from the origin
    count     = 0

    # Filtering all points
    while len(queue) > 0:
        current = queue.pop(0)
        
        if marking[current]['visited'] != -1: # -1 means "not processed yet".
            continue

        marking[current]['visited'] = count
        summonerN        = normals[current]
        p                = vertices[current]
        newPoints.append(current)
        
        close = set(kdtree.query_ball_point(p, radius)).union(incidence[current]) # returns a list of indices in self.points
        
        count += 1

        for n in close:
            if (n in incidence[current]):
                queue.append(n)
                marking[n]['count'] += 1
                continue 
            
            elif (np.dot(normalize(summonerN), normalize(normals[n])) < dotLimit):
                removed.add(n)
                marking[n]['visited'] = -2

    for i, d in enumerate(marking):
        if (d['visited'] == -2) and (d['count'] > 1):
            d['visited'] = count
            newPoints.append(i)
            removed.remove(i)
            count += 1

    removed  = removed.union(set([k for k in range(len(vertices)) if marking[k]['visited'] < 0]))
    vertices = np.array([vertices[p] for p in newPoints])
    faces    = np.array([(marking[a]['visited'], marking[b]['visited'], marking[c]['visited']) for a, b, c in faces if len(set([a, b, c]).intersection(removed)) == 0])

    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=faces)


def main():
    meshFilePath = "../testing-set/three.wrl"

    ms = pymeshlab.MeshSet()
    ms.load_new_mesh(meshFilePath)
    ms.save_current_mesh("./before.obj")
    print(f"Currently {len(ms)} mesh(es) loaded.")
    
    raw = ms[0]

    centered = geometryToOrigin(raw)
    ms.add_mesh(centered)
    ms.save_current_mesh("./centered.obj")
    
    graph = buildNeighborhoodGraph(centered)

    shrunk = shrink(centered)
    ms.add_mesh(shrunk)
    ms.save_current_mesh("./shrunk.obj")

    smooth = averageSmoothing(shrunk, graph)
    ms.add_mesh(smooth)
    ms.save_current_mesh("./smooth.obj")

    flat = flatten(smooth, smooth, graph)
    ms.add_mesh(flat)

    ms.apply_filter("meshing_close_holes")
    ms.apply_filter("meshing_snap_mismatched_borders")
    ms.apply_filter("meshing_repair_non_manifold_vertices")
    ms.apply_filter("meshing_merge_close_vertices")

    ms.apply_filter("compute_selection_from_mesh_border") # Selectionne les vertices et les faces de la border

    ms.save_current_mesh("./flat.obj")


main()

# Séparer les meshes s'il y a plusieurs composantes connexes dans le fichier d'origine.
# Echantilloner le long de quelques rayons le long de chaque axe pour déterminer le sens du cylindre pour la projection
# Mettre sous forme d'addon Blender !!!

# Mesures:
#  - Aire
#  - Périmètre
#  - Aire convex hull
#  - Ratio projection sphérique (aire après projection sphérique / aire sphère englobante)
#  - Roundness, compactness
#  - Dimensions X, Y et Z
#  - Nombre de rétrécissement
#  - Essayer de caractériser les tentacules
#  - Sortir une image de la distance de chaque vertex au centre
#  - Essayer de caractériser la pliure

# compute_selection_bad_faces
# create_sphere_points
# generate_convex_hull
# meshing_remove_duplicate_faces
# get_geometric_measures
# generate_surface_reconstruction_vcg

# Avant ou après le shrink, essayer de smooth le mesh
# (soit par average, soit par projection)

# Dilates and erodes
# Remove holes
# Remove non-manifold edges/faces
# Smooth
# Detect contours + smooth contours.

# Le résulatat final est connu (connexe, doux, sans trou, ...)
# On peut donc forcer le résultat à travers des correctifs.