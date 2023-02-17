import os
import sys
import random
import json
import numpy as np
import pymeshlab
import subprocess
from scipy.spatial import KDTree, Delaunay
import matplotlib.pyplot as plt
import matplotlib.cm as cm
from multiprocessing import Pool
from functools import partial

# State used all along the execution.
state = {
    'outputDirectory': "/home/benedetti/Documents/projects/7-isosurface/produced",
    'target': "/home/benedetti/Documents/projects/7-isosurface/testing-set",
    'exports': {
        'shrunk': True,
        'smooth': True,
        'flat': True,
        'sphere': True,
        'cleaned': True,
        'geodesic': True
    },
    'current': None,
    'blenderPath': "/home/benedetti/blender",
    'blenderScript': "/home/benedetti/Documents/projects/7-isosurface/astrocytesBloodVessels/generateBlenderFile.py",
    'produced': [],
    'success': [],
    'fails': [],
    'operation': ""
}

sys.stdout = open(os.path.join(state['outputDirectory'], "logs.txt"), 'w')

def setState(s):
    global state
    state['operation'] = s
    print(s)


def main():
    measures = {}

    # Determining if the provided path is a directory (batch mode) or a file (one shot).
    path  = state['target']
    batch = os.path.isdir(path)
    
    if not os.path.isfile(path) and not batch:
        setState("ERROR. The provided path doesn't correspond to anything.")
        return -1

    if batch:
        queue = [os.path.join(path, f) for f in sorted(os.listdir(path)) if os.path.isfile(os.path.join(path, f)) and f.lower().endswith('.wrl')]
    else:
        queue = [path]
    
    # For each file containing meshes:
    for filePath in queue:
        state['current'] = filePath

        # try:
        extractMeasures(measures)
        state['success'].append(state['current'])
        # except Exception as err:
        #     setState(f"{state['current']} skipped due to an error.")
        #     setState(str(err))
        #     state['fails'].append(state['current'])
        
        createVerificationFile()
        state['produced'].clear()
    
    csvPath = os.path.join(state['outputDirectory'], "result.csv")
    setState(f"Exporting CSV to: {csvPath}")
    dicoToCSV(measures, csvPath)

    sys.stderr.write(" ---------------------------------------------------------------------------------------\n")
    sys.stderr.write(" |                                    SUCCESS                                          |\n")
    sys.stderr.write(" ---------------------------------------------------------------------------------------\n")
    sys.stderr.write(" |\n")
    for s in state['success']:
        sys.stderr.write(f" | - {s}\n")
    sys.stderr.write(" |\n")
    sys.stderr.write(" ---------------------------------------------------------------------------------------\n")
    sys.stderr.write(" |                                    FAILS                                            |\n")
    sys.stderr.write(" ---------------------------------------------------------------------------------------\n")
    sys.stderr.write(" |\n")
    for f in state['fails']:
        sys.stderr.write(f" | - {f}\n")
    sys.stderr.write(" |\n")
    sys.stderr.write(" ---------------------------------------------------------------------------------------\n")
    sys.stderr.write("\n")

    sys.stderr.write("DONE.\n")

    return 0


def createVerificationFile():
    """Launches an instance of Blender and runs a script on the embedded Python. It builds a verification scene from the surface."""
    jsonParams = json.dumps(state).replace('"', '#')
    commandLine = f"{state['blenderPath']} --background --python {state['blenderScript']} -- \"{jsonParams}\" > {os.path.devnull}"
    # commandLine = f"{state['blenderPath']} --background --python {state['blenderScript']} -- \"{jsonParams}\""
    setState(f"        | Command: <{commandLine}>")
    # os.system(commandLine)
    subprocess.run(commandLine, shell=True)


def isSmall(e):
    """Determines if a value can be considered as neglectable (whether it's positive or negative)."""
    return abs(e) < 0.0001


def normalize(v):
    """Turns the vector passed as argument into a unit vector."""
    return v / np.linalg.norm(v)


def geometryToOrigin(mesh):
    """Brings the geometry to the center of the world"""

    vertices = mesh.vertex_matrix()
    avg = np.average(vertices, axis=0)

    for i in range(len(vertices)):
        vertices[i] -= avg

    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=mesh.face_matrix())


def shrink(mesh, shrinkingFactor=0.18):
    """Shrinks a mesh along its vertices' normals"""
    
    normals  = np.array([normalize(n) for n in mesh.vertex_normal_matrix()])
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()

    for idx, N in enumerate(normals):
        vertices[idx] -= shrinkingFactor * N
    
    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=faces)


def buildParticipationGraph(mesh):
    """Builds a list of sets associating each index of vertex to the faces' indices using it."""

    faces = mesh.face_matrix()
    participation = [set() for i in range(mesh.vertex_number())]

    for idxFace, face in enumerate(faces):
        for vertex in face:
            participation[vertex].add(idxFace)

    return participation


def buildNeighborhoodGraph(mesh):
    """Builds a list of sets associating each index of vertex to the indices of its direct neighbors."""

    nhg = [set() for i in range(mesh.vertex_number())]
    pairs = [(0, 1), (0, 2), (1, 2)]

    for face in mesh.face_matrix():
        for i, j in pairs:
            nhg[face[i]].add(face[j])
            nhg[face[j]].add(face[i])
        
    return nhg


def averageSmoothing(mesh, graph):
    """Smoothes a mesh by averaging each vertex with its direct neighbors."""
    
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()
    newVerts = np.zeros(vertices.shape)

    for v in range(len(vertices)):
        newVerts[v] = np.average(vertices[list(graph[v])], axis=0)
    
    return pymeshlab.Mesh(vertex_matrix=newVerts, face_matrix=faces)


def distanceToBorder(mesh, graph, borders):
    """Associates to each vertex the shortest geodesic distance between it and the border."""

    vertices  = mesh.vertex_matrix()
    distances = np.full(len(vertices), -1)
    selected  = set([item for sublist in borders for item in sublist])
    counter   = 0

    while len(selected) > 0:
        nextStep = set()

        for s in selected:
            if distances[s] > -1:
                continue
            distances[s] = counter
            nextStep = nextStep.union(graph[s])
        
        selected = nextStep
        counter += 1
    
    return distances


def sphereProject(mesh, radius=-1):
    """Projects each vertex of the input mesh onto a sphere of the specified radius."""

    vertices = mesh.vertex_matrix()
    normals  = mesh.vertex_normal_matrix()
    faces    = mesh.face_matrix()
    projectedVertices = np.zeros(vertices.shape)

    if radius <= 0.0:
        # Farthest point from the origin
        m, i = 0, 0
        for idx, v in enumerate(vertices):
            n = np.linalg.norm(v)
            if n > m:
                m = n
                i = idx
        radius = m + 0.5

    # Sphere projection
    for i, (v, n) in enumerate(zip(vertices, normals)):
        rho   = np.linalg.norm(v)
        theta = np.arccos(v[2] / rho)
        phi   = np.arctan2(v[1], v[0])

        projectedVertices[i] = (
            radius * np.sin(theta) * np.cos(phi),
            radius * np.sin(theta) * np.sin(phi),
            radius * np.cos(theta)
        )

    return radius, pymeshlab.Mesh(vertex_matrix=projectedVertices, face_matrix=faces)


def flatten(mesh, original, incidence, radius=0.6, dotLimit=0.0):
    """Flattens a mesh by inspecting the normals variations in a sphere around each vertex."""

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


def compare(original, sphere, sphereClean):
    """Finds the vertices of 'sphere' that have been deleted in 'sphereClean' and applies these deletions to 'original'."""

    vtc1     = sphere.vertex_matrix()
    vtc2     = sphereClean.vertex_matrix()
    vertices = original.vertex_matrix()
    faces    = original.face_matrix()

    tree     = KDTree(vtc2, leafsize=5)
    count    = 0
    lut      = [-1 for i in range(len(vertices))]
    removed  = set()

    for idx, vertex in enumerate(vtc1):
        d, i = tree.query(vertex, 1)
        if isSmall(d):
            lut[idx] = count
            count += 1

    newVerts = np.array([vertices[idx] for idx, target in enumerate(lut) if target >= 0])
    newFaces = np.array([(lut[a], lut[b], lut[c]) for a, b, c in faces if (-1 not in set([lut[a], lut[b], lut[c]]))])

    return pymeshlab.Mesh(vertex_matrix=newVerts, face_matrix=newFaces)


# Return: [(minX, maxX), (minY, maxY), (minZ, maxZ)]
def makeAABB(mesh):
    """Processes the axis-aligned bounding-box of a given mesh."""

    vertices = mesh.vertex_matrix()
    v1 = vertices[0]
    x, X = v1[0], v1[0]
    y, Y = v1[1], v1[1]
    z, Z = v1[2], v1[2]

    for a, b, c in vertices:
        if a < x:
            x = a
        if a > X:
            X = a

        if b < y:
            y = b
        if b > Y:
            Y = b

        if c < z:
            z = c
        if c > Z:
            Z = c
    
    return [(x, X), (y, Y), (z, Z)]


def processIntersection(vertices, faces, intersections, ray):
    """Processes the number of intersections between a ginven ray and a mesh."""
    count = 0
    index, direction, origin = ray

    for idx, face in enumerate(faces):
        
        edge1 = vertices[face[1]] - vertices[face[0]]
        edge2 = vertices[face[2]] - vertices[face[0]]
        
        pvec = np.cross(direction, edge2)
        det  = np.dot(edge1, pvec)

        if isSmall(det):
            continue
        
        invDet = 1.0 / det
        tvec   = origin - vertices[face[0]]
        u = invDet * np.dot(tvec, pvec)

        if (u < 0) or (u > 1.0):
            continue
        
        qvec = np.cross(tvec, edge1)
        v = invDet * np.dot(direction, qvec)

        if (v < 0) or (u + v > 1.0):
            continue

        count += 1
    
    intersections[index] = count


def detectAxisBloodVessel(mesh, samples=1000, radius=8):
    """Function trying to detect the axis the blood vessel is aligned with."""
    
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()
    
    # Sampling a quarter of sphere
    points = np.zeros((samples, 3))
    rays   = np.zeros((samples, 3))

    for s in range(samples):
        phi   = random.random() * (np.pi / 2.0)
        theta = random.random() * (np.pi / 2.0)
        rays[s] = (
            np.sin(theta) * np.cos(phi),
            np.sin(theta) * np.sin(phi),
            np.cos(theta)
        )
        points[s] = -radius * rays[s]

    intersections = np.zeros(samples)
    pool = Pool(32)
    pool.map(partial(processIntersection, vertices, faces, intersections), zip(range(samples), rays, points))
    indices = [i for i, d in enumerate(intersections) if d == 0]
    
    startAxis = np.average(points[indices], axis=0)
    axis      = np.average(rays[indices], axis=0)
    print(startAxis, axis)

    return None


def mostIsolated(indices, graph):
    """Determines which vertex is the most isolated (least number of connections) among the ones proposed in the input list."""

    d = len(graph[indices[0]])
    best = indices[0]

    for i in indices:
        di = len(graph[i])
        if di < d:
            best = i
            d = di
    
    return best


def processArea(mesh):
    """Processes the area of a mesh by summing the area of the faces composing it."""

    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()
    return sum([np.linalg.norm(np.cross(vertices[face[1]] - vertices[face[0]], vertices[face[2]] - vertices[face[0]])) / 2.0 for face in faces])


def processPerimeter(mesh, borders):
    """Processes the perimeter by finding the biggest loop of border vertices."""

    vertices = mesh.vertex_matrix()
    index    = 0
    maxPerim = 0
    
    for idx, border in enumerate(borders):
        indices = border + [border[0]]
        perim = sum([np.linalg.norm(vertices[i] - vertices[i+1]) for i in range(len(indices)-1)])

        if perim > maxPerim:
            maxPerim = perim
            index = idx
    
    return index, maxPerim


def findBorders(mesh, graph, participation):
    """Finds every loops of vertices being borders of the mesh."""

    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()
    used     = set([])
    loops    = []

    for vertex, (neighbors, owners) in enumerate(zip(graph, participation)):
        
        if vertex in used:
            continue

        if len(neighbors) <= len(owners):
            continue
        
        current = vertex
        loop    = [current]
        used.add(vertex)

        while True:
            candidates = [n for n in graph[current] if (n not in used) and (len(graph[n]) > len(participation[n]))]
            if len(candidates) == 0:
                break
            link = mostIsolated(candidates, graph)
            used.add(link)
            loop.append(link)
            current = link
            opened = current != vertex
        
        loops.append(loop)

    return loops


def browseFromVertex(vertex, distances, graph, marking):
    """Propagation algorithm reaching all vertices from a seed vertex."""
    queue = [vertex]

    while len(queue) > 0:
        current = queue.pop(0)
        if (marking[current] == 0) and (distances[current] >= 0):
            marking[current] = 1
            for n in graph[current]:
                if (marking[n] == 0) and (distances[n] >= 0):
                    queue.append(n)


def decimate(dst, graph):
    """Iteratively decreases the chamfer distance to determine the regularity of the shape. Bigger numbers mean less regularity."""
    distances = dst.copy()
    maxCount = 0

    while True:
        distances -= 1
        nn = np.nonzero(distances >= 0)[0]

        if len(nn) == 0:
            break
        
        visited = np.zeros(len(graph)) # 0 = not visited, 1 = visited
        count = 0

        for n in nn:
            if visited[n] == 1:
                continue
            browseFromVertex(n, distances, graph, visited)
            count += 1
        
        if count > maxCount:
            maxCount = count
    
    return maxCount
            

def createPlot(graph, mapping, measures, name):
    print(f"Rendering {name}")
    plt.figure(figsize=(12, 10), dpi=100)
    ax = plt.subplot()
    ax.axis('equal')

    for source, neighbors in enumerate(graph):
        for n in neighbors:
            src = mapping[source]
            nbr = mapping[n]
            plt.plot([src[0], nbr[0]], [src[1], nbr[1]], linewidth=1.0, color='#eeeeee', zorder=0)

    maxD = np.max(measures)

    colors = np.array([cm.hot(d / maxD) if d >= 0 else (1.0, 1.0, 1.0, 1.0) for d in measures])
    mapping = np.transpose(mapping)

    ax.scatter(mapping[0], mapping[1], c=colors, marker='1', zorder=1)
    
    plt.tight_layout()
    # plt.show()

    plt.savefig(name)
    plt.clf()
    plt.close()


def extractMeasures(measures):

    exportName = os.path.basename(state['current']).split('.')[0]

    setState(f"= = = = = = Importing '{exportName}' = = = = = =")
    sys.stderr.write(f"= = = = = = Importing '{exportName}' = = = = = =\n")
    ms = pymeshlab.MeshSet()
    ms.load_new_mesh(state['current'])

    nbBefore = len(ms)
    ms.apply_filter("generate_splitting_by_connected_components")
    nbAfter  = len(ms)
    chunks = [ms[i] for i in range(nbBefore, nbAfter)]

    setState(f"    | = = = = = = Currently {nbAfter - nbBefore} mesh loaded. = = = = = =")

    for iC, chunk in enumerate(chunks):
        produced = {
            'center': None,
            'cleaned': None,
            'json': None
        }
        setState(f"    | Processing mesh {iC+1}/{nbAfter - nbBefore}.")
        measures.setdefault('islands', []).append(nbAfter - nbBefore)

        measures.setdefault('source', []).append(exportName)
        measures.setdefault('rank', []).append(iC+1)

        setState("        | Centering the mesh at the center of the world.")
        centered = geometryToOrigin(chunk)
        ms.add_mesh(centered)
        ms.apply_filter("meshing_merge_close_vertices")
        expNameCenter = os.path.join(state['outputDirectory'], f"1-centered-{exportName}-{str(iC+1).zfill(2)}.obj")
        ms.save_current_mesh(expNameCenter)
        produced['center'] = expNameCenter
    
        setState("        | Building a graph giving, for each index of vertex, the indices of its neighbors vertices.")
        graph = buildNeighborhoodGraph(ms.current_mesh())

        setState("        | Shrinking the mesh along its vertices' normals.")
        shrunk = shrink(ms.current_mesh())
        ms.add_mesh(shrunk)
        ms.save_current_mesh(os.path.join(state['outputDirectory'], f"2-shrunk-{exportName}-{str(iC+1).zfill(2)}.obj"))

        setState("        | Smoothing the mesh by interpolation each vertex with its neighbors.")
        smooth = averageSmoothing(shrunk, graph)
        ms.add_mesh(smooth)
        ms.save_current_mesh(os.path.join(state['outputDirectory'], f"3-smooth-{exportName}-{str(iC+1).zfill(2)}.obj"))

        setState("        | Create a rough version of a 0-thickness mesh.")
        flat = flatten(smooth, smooth, graph)
        ms.add_mesh(flat)
        ms.apply_filter("meshing_repair_non_manifold_edges")
        ms.apply_filter("meshing_repair_non_manifold_vertices")
        flat = ms.current_mesh()
        ms.save_current_mesh(os.path.join(state['outputDirectory'], f"4-flattened-{exportName}-{str(iC+1).zfill(2)}.obj"))

        setState("        | Building a sphere projection of our rough flatenned version.")
        radius, sphere = sphereProject(ms.current_mesh())
        measures.setdefault('radius', []).append(radius)
        
        setState("        | Removing points projected at the same place on the sphere (corresponding to failed borders)")
        ms.add_mesh(sphere)
        ms.apply_filter("meshing_cut_along_crease_edges")
        ms.apply_filter("meshing_remove_connected_component_by_face_number")
        ms.save_current_mesh(os.path.join(state['outputDirectory'], f"5-sphere-{exportName}-{str(iC+1).zfill(2)}.obj"))

        setState("        | Removing the vertices on the rough version corresponding to the one removed at the previous step.")
        cleaned = compare(flat, sphere, ms.current_mesh())
        ms.add_mesh(cleaned)

        setState("        | Cleaning the correct version of the surface.")
        ms.apply_filter("meshing_close_holes", maxholesize=20)
        ms.apply_filter("meshing_snap_mismatched_borders")
        ms.apply_filter("meshing_repair_non_manifold_vertices")
        ms.apply_filter("meshing_merge_close_vertices")
        ms.apply_filter("meshing_remove_duplicate_faces")
        expCleanPath = os.path.join(state['outputDirectory'], f"6-cleaned-{exportName}-{str(iC+1).zfill(2)}.obj")
        ms.save_current_mesh(expCleanPath)
        produced['cleaned'] = expCleanPath

        setState("        | Finding all loops of vertices being on borders")
        graph     = buildNeighborhoodGraph(ms.current_mesh())
        partGraph = buildParticipationGraph(ms.current_mesh())
        borders   = findBorders(ms.current_mesh(), graph, partGraph)

        setState("        | The perimeter is the border with the biggest length")
        idBorderPerim, perimeter = processPerimeter(ms.current_mesh(), borders)
        measures.setdefault('perimeter', []).append(perimeter)

        setState("        | Processing the number of holes and the area of the surface.")
        measures.setdefault('nbHoles', []).append(len(borders)-1)
        measures.setdefault('area', []).append(processArea(ms.current_mesh()))

        setState("        | Determining the Axis Aligned measures.")
        bb = makeAABB(ms.current_mesh())
        measures.setdefault('aa_width', []).append(bb[0][1] - bb[0][0])
        measures.setdefault('aa_height', []).append(bb[1][1] - bb[1][0])
        measures.setdefault('aa_depth', []).append(bb[2][1] - bb[2][0])

        setState("        | Building geodesic distance to the closest border.")
        distances = distanceToBorder(ms.current_mesh(), graph, borders)
        distancesDict = {'geodesic': [int(i) for i in distances]}
        geoPath = os.path.join(state['outputDirectory'], f"7-geodesic-{exportName}-{str(iC+1).zfill(2)}.json")
        produced['json'] = geoPath
        f = open(geoPath, 'w')
        json.dump(distancesDict, f)
        f.close()
        
        setState("        | Max number of connected components reached during decimation caracterizes the sprawlingness of the surface.")
        measures.setdefault('maxCompos', []).append(decimate(distances, graph))

        # print("    | Building convex hull from cylindrical projection.")
        # axis = detectAxisBloodVessel(ms.current_mesh(), samples=10, radius=radius)

        measures.setdefault('iters', 0)
        measures['iters'] += 1
        state['produced'].append(produced)


def dicoToCSV(dico, outpath):
    width  = len(dico.keys())
    height = dico.pop('iters')
    header = list(dico.keys())
    lines  = []

    for i in range(height):
        line = []
        for key, items in dico.items():   
            line.append(items[i])
        lines.append(line)
    
    f = open(outpath, 'w')
    f.write(", ".join(header) + '\n')
    for line in lines:
        f.write(", ".join([str(l) for l in line]) + '\n')
    f.close()


main()
