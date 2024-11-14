import os
import sys
import random
import json
import numpy as np
import pymeshlab
import subprocess
from scipy.spatial import KDTree, Delaunay
import csv
from multiprocessing import Pool
from functools import partial

def isSmall(e):
    """Determines if a value can be considered as neglectable (whether it's positive or negative)."""
    return abs(e) < 0.0001

def normalize(v):
    """Turns the vector passed as argument into a unit vector."""
    return v / np.linalg.norm(v)

def makeSourceName(name):
    return os.path.basename(name).split('.')[0]


class CSVtable(object):

    def __init__(self, ttls, d="-"):
        self.titles  = [str(t) for t in ttls]
        self.lines   = []
        self.default = d
    
    def getTitles(self):
        return self.titles

    def newRow(self):
        self.lines.append([self.default for i in range(len(self.titles))])

    def cancelRow(self):
        self.lines.pop()
    
    def _nameToIndex(self, name):
        n = str(name)
        for i, c in enumerate(self.titles):
            if c == n:
                return i

        return -1

    def setValue(self, col, val):
        idx = self._nameToIndex(col)
        if idx < 0:
            return
        self.lines[-1][idx] = str(val)
    
    def exportTo(self, dirPath, name):
        if not os.path.isdir(dirPath):
            return
        
        fullPath = os.path.join(dirPath, name)

        with open(fullPath, 'w') as csvfile:
            writer = csv.writer(csvfile, delimiter=',')
            writer.writerow(self.titles)
            for row in self.lines:
                writer.writerow(row)


#
# State used all along the execution. This is a global state used by all functions and tracking the current operation.
# The variables labeled [environment] are not meant to be modified by anything else than the script itself.
#
# - outputDirectory: Directory in which the script will export every created files. The production includes:
#                        - The results CSV containing all metrics (state.resultsName)
#                        - The centered version on the mesh ("1-centered-*.obj")
#                        - The mesh shrunk along its normals ("2-shrunk-*.obj")
#                        - The smoothed version of the mesh ("3-smooth-*.obj")
#                        - The flattened version of the mesh ("4-flattened-*.obj")
#                        - The mesh projected on its bounding sphere ("5-sphere-*.obj")
#                        - The mesh after removing duplicates, non-manifold, ... ("6-cleaned-*.obj")
#                        - A JSON containing the geodesic distance of each vertex to the closest border ("7-geodesic-*.json")
#                        - The logs of the execution ("logs.txt")
#                        - A Blender file to help the user visually check the results ("*.blender")
#
# - target: Can be either:
#              - The direct path to a .wrl file 
#              - A folder's path containing multiple .wrl files
#
# - clearOBJs: Do you want the script to remove all the .obj and .json files from the output folder.
#
# - current: [environment] The path to the file currently processed.
#
# - blenderPath: Path to Blender (including the name of the binary)
#
# - blenderScript: Path to the secondary script creating Blender check files ("generateBlenderFile.py")
#
# - produced: [environment] List of dictionaries. Each dictionary contains the path of some obj files.
#                           The content of this variable will be the input of "generateBlenderFile.py"
#
# - success: [environment] Contains the list of file names that were successfully processed.
#
# - fails: [environment] Contains the list of file names that the script failed to process.
#
# - operation: [environment] Contains a string representing the current operation being realized.
#                            The content of this variable is SET through the setOperation(str) function
#                            You can GET the content just by reading the state object.
#
# - history: [environment] Contains the list of all the file names that have already been processed to avoid reprocessing them.
#                          When the script in launched, it is populated with the files found in state.resultsName (if it exists already).
#


class State(object):

    def __init__(self, outputDir="", inputs="", clear=True, csvName="results.csv", blender="", secondaryScript="", flushDir=True, resetAll=False):

        self.outputDirectory = ""
        self.target          = ""
        self.clearOBJs       = True
        self.resultsName     = "results.csv"
        self.blenderPath     = "blender"
        self.blenderScript   = ""
        self.reset           = resetAll
        self.flush           = flushDir

        self.current         = None
        self.produced        = []
        self.success         = {}
        self.fails           = {}
        self.operation       = ""
        self.history         = set()
        self.batch           = False
        self.queue           = []
        self.results         = CSVtable(["islands", "source", "rank", "radius", "perimeter", "nbHoles", "area", "aa_width", "aa_height", "aa_depth", "maxCompos"])

        if self.setResultsName(csvName) > 0:
            raise ValueError("Failed to set a value of results name in constructor.")
        if self.setOutputDirectory(outputDir) > 0:
            raise ValueError("Failed to set a value of output directory in constructor.")
        if self.setTarget(inputs) > 0:
            raise ValueError("Failed to set a value of target in constructor.")
        if self.setClearOBJs(clear) > 0:
            raise ValueError("Failed to set a value of cleaning in constructor.")
        if self.setBlenderPath(blender) > 0:
            raise ValueError("Failed to set a value of blender path in constructor.")
        if self.setBlenderScript(secondaryScript) > 0:
            raise ValueError("Failed to set a value of blender script in constructor.")

        with open(os.path.join(self.getOutputDirectory(), "logs.txt"), 'w') as f:
            f.write(self.operation+"\n")
    
    def run(self):

        self.populateHistory()

        while self.nextFile():
            extractMeasures(self)
            createVerificationFile(self)
            self.produced.clear()

        if self.clearOBJs:
            self.clearOutput()

        self.displayAssessment()

    def clearOutput(self):
        """Removes all temporary files (.obj and .json) from the output directory."""
        output  = self.getOutputDirectory()
        content = os.listdir(output)

        for c in content:
            if c.endswith(".obj") or c.endswith(".json"):
                fullPath = os.path.join(output, c)
                os.remove(fullPath)
                self.setOperation(f"Removed {fullPath}", 'l')
    
    def getCurrent(self):
        """Returns the full absolute path of the next file to process, or the one currently processed (or None if the queue is empty)."""
        return self.current
    
    def nextFile(self):
        """
        Uses the processing queue to determine which is the next file to process.
        It uses the history attribute to skip the files that have already been processed on a previous run.
        If the queue is empty, sets self.current to None.
        Returns True if a file was found or False if everything was processed.
        """
        if self.current is not None:
            self.history.add(makeSourceName(self.current))

        while (len(self.queue) > 0) and (makeSourceName(self.queue[0]) in self.history):
            self.queue.pop(0)
        
        if len(self.queue) == 0:
            return False

        self.current = self.queue[0]

        return True


    def getBlenderScript(self):
        """Returns the path to the script that will be launched from Blender."""
        if self.blenderScript is None or len(self.blenderScript) == 0:
            return "./generateBlenderFile.py"
        else:
            return self.blenderScript

    def setBlenderScript(self, s):
        """
        Sets the path of the script that will be launched in Blender.
        Returns: 0 on success
                 1 if the provided path is invalid
        """
        if not os.path.isfile(s):
            print(f"[E] The provided path is not valid for the secondary script: '{s}'")
            return 1

        self.blenderScript = s
        print(f"[i] Blender script path set to: '{self.blenderScript}'")
        return 0

    def getBlenderPath(self):
        """Returns the path to the Blender executable."""
        if (self.blenderPath is None) or (len(self.blenderPath) == 0):
            return "blender"
        else:
            return self.blenderPath

    def setBlenderPath(self, p):
        """
        Sets the path to the Blender executable.
        If 'blender' is in your PATH, you can simply write 'blender'. Otherwise, provide an absolute path including the name of the binary.
        Returns: 0 on success
                 1 if the specified path to Blender doesn't exist and is not in the PATH.
        """
        res = subprocess.run(f"\"{p}\" --background", shell=True)

        if res.returncode == 0:
            self.blenderPath = p
            print(f"[i] Blender binary path set to: '{self.blenderPath}'")
            return 0

        print(f"[E] The provided path is not valid for Blender binary: '{p}' (return code: {res.returncode})")
        return 1

    def getResultsName(self):
        """Returns the name that will be given to the CSV file containing the measures."""
        if (self.resultsName is None) or (len(self.resultsName) == 0) or (self.resultsName == ".csv"):
            return "results.csv"
        else:
            return self.resultsName
    
    def setResultsName(self, n):
        """
        Sets the name of the CSV that will receive the exported measures.
        """
        newName = n.lower().replace(" ", "-")
        
        if not newName.endswith(".csv"):
            if newName.find(".") > 0:
                newName = newName.split(".")[0] + ".csv"
            else:
                newName += ".csv"
        
        if newName != n:
            print(f"[i] Results name request transformed from '{n}' to '{newName}'.")
        
        self.resultsName = newName
        print(f"[i] Results name set to: '{newName}'")

        return 0

    def getOutputDirectory(self):
        """Returns the path to which the script will export its temporary files and its outputs."""
        if (self.outputDirectory is None) or (len(self.outputDirectory) == 0):
            print("[W] The output directory was accessed but not set.")
            return "."
        else:
            return self.outputDirectory
    
    def setOutputDirectory(self, s):
        """
        Sets the path to which the script will export its outputs and its temporary files.
        This function detects if the folder is empty and asks the user if he still wants to proceed despite the fact that some files may be overwritten.
        Returns: 0 on success.
                 1 if the provided path is not a directory.
                 2 if the user canceled the execution because the folder is not empty.
        """
        if not os.path.isdir(s):
            print("[E] The selected output path is not an existing folder.")
            return 1

        if self.flush:
            self.outputDirectory = s
            print(f"[i] Output directory set to: {self.outputDirectory}")

            for c in os.listdir(s):
                if os.path.isfile(os.path.join(s, c)):
                    if (not self.reset) and (c == self.getResultsName()):
                        continue
                    os.remove(os.path.join(s, c))
            
            print(f"[i] Output directory flushed.")
            return 0
        
        for c in os.listdir(s):
            if os.path.isfile(os.path.join(s, c)):
                c = input("The selected output directory is not empty. \nIts content may be overwrritten along the execution.Continue ? [y/n] ")
                if c.lower().startswith("y"):
                    self.outputDirectory = s
                    print(f"[i] Output directory set to: {self.outputDirectory}")
                    return 0;
                else:
                    print("[E] Execution canceled by user because output folder is not empty.")
                    return 2

        self.outputDirectory = s
        print(f"[i] Output directory set to: {self.outputDirectory}")

        return 0

    def isBatching(self):
        """Returns True if a batch of files was provided as input, False otherwise."""
        return self.batch

    def getTarget(self):
        """Returns the path of the file/folder that will be used as input for the script."""
        if self.target is None or len(self.target) == 0:
            print("[W] The target path was accessed but not set.")
            return "."
        else:
            return self.target

    def setTarget(self, t):
        """
        Sets the path that will be used as input for the script.
        If the path points to a file, only this file will be processed.
        If it points to a folder, every .wrl in this folder will be processed.
        Returns: 0 on success
                 1 if the provided path doesn't exist
                 2 if the processing queue is empty (no file found to be processed)
        """
        path = t
        self.batch = os.path.isdir(path)
        
        if not os.path.isfile(path) and not self.batch:
            print("[E] The provided path doesn't correspond to anything.")
            return 1
        
        self.target = t
        print(f"[i] Target set to: {self.target}")
        print(f"[i] Batching: {'YES' if self.batch else 'NO'}")

        if self.batch:
            self.queue = [os.path.join(path, f) for f in sorted(os.listdir(path)) if os.path.isfile(os.path.join(path, f)) and f.lower().endswith('.wrl')]
        else:
            self.queue = [path]
        
        if len(self.queue) == 0:
            return 2
        
        return 0

    def getClearOBJs(self):
        """Returns True if the temporary files must be removed, False otherwise."""
        return self.clearOBJs

    def setClearOBJs(self, v):
        """
        Sets the value of clearOBJs, to determine if temporary files should be removed by the end of the execution.
        Returns: 0 on success
                 1 if the input is not a boolean
        """
        if type(v) is bool:
            self.clearOBJs = v
            return 0
        
        print(f"[E] The value of clearOBJs can only be a boolean. Received {v}.")
        return 1
    
    def toggleClearOBJs(self):
        """Inverts the status of clearOBJs"""
        self.clearOBJs = not self.clearOBJs

    def populateHistory(self):
        """
        Function reading the results from the previous run (if the output directory didn't change) and populating the 'history' set.
        By doing so, we avoid recomputing the same files over and over again if a crash occurs for any reason.
        It also loads the datas from the previous run to avoid overwriting them.
        The resulting CSV aggregates the results of the previous run with the new ones of the current run.
        """
        path = os.path.join(self.outputDirectory, self.resultsName)

        print("[i] Populating history from previous run results.")

        if not os.path.isfile(path):
            print("[i] No previous run results found.")
            return

        with open(path) as csvfile:
            reader = csv.reader(csvfile, delimiter=',')
            rank = -1
            titles = []

            for row in reader:
                if rank == -1:
                    titles = row
                    for i, title in enumerate(row):
                        t = title.strip().lower()
                        if t == "source":
                            rank = i
                            continue
                else:
                    self.history.add(row[rank].strip())
                    self.results.newRow()
                    for val, cat in zip(row, titles):
                        self.results.setValue(cat, val)

        print("[i] Initial population:")
        for k in self.history:
            print(f"      - {k}")
    
    def displayAssessment(self):
        """Displays in the terminal which files were successfully processed, and which ones could not."""
        self.setOperation("-----------------------------------------------------------------------------------------")
        self.setOperation(f"|                            SUCCESS ({str(len(self.success)).zfill(3)}/{str(len(self.fails)+len(self.success)).zfill(3)})                                          |")
        self.setOperation("-----------------------------------------------------------------------------------------")
        self.setOperation(" ")

        for key, items in self.success.items():
            self.setOperation(f"  - {key} ({', '.join([str(i) for i in items])})")

        self.setOperation(" ")
        self.setOperation("-----------------------------------------------------------------------------------------")
        self.setOperation(f"|                            FAILS ({str(len(self.fails)).zfill(3)}/{str(len(self.fails)+len(self.success)).zfill(3)})                                            |")
        self.setOperation("-----------------------------------------------------------------------------------------")
        self.setOperation(" ")

        for key, items in self.fails.items():
            self.setOperation(f"  - {key} ({', '.join([str(i) for i in items])})")

        self.setOperation(" ")
        self.setOperation("-----------------------------------------------------------------------------------------")
        self.setOperation("")

    def setOperation(self, s, dest="tl"):
        """
        Modifies the 'operation' attribute in the state.
        This attribute basically contains the operation being executed at some point in time.
        It allows to output some part of the logs in a file, some other in the terminal, or even both.
        dest is a string that shoud take its value in ['', 't', 'l', 'tl']. 't' meaning 'terminal' and 'l' log (for logs file).
        """
        self.operation = str(s)

        if 't' in dest:
            print(self.operation)
        if 'l' in dest:
            with open(os.path.join(self.getOutputDirectory(), "logs.txt"), 'a') as f:
                f.write(self.operation+"\n")
            
        return 0


#######################################################


def createVerificationFile(state):
    """Launches an instance of Blender and runs a script on the embedded Python. It builds a verification scene from the surface."""
    jsonParams = json.dumps({
        "outputDirectory": state.getOutputDirectory(),
        "current": state.getCurrent(),
        "produced": state.produced
    }).replace('"', '#')

    commandLine = f"\"{state.getBlenderPath()}\" --background --python \"{state.getBlenderScript()}\" -- \"{jsonParams}\" > {os.path.devnull}"
    state.setOperation(f"        | Command: <{commandLine}>", 'l')
    subprocess.run(commandLine, shell=True)


def geometryToOrigin(mesh):
    """Brings the geometry to the center of the world"""
    vertices = mesh.vertex_matrix()
    avg = np.average(vertices, axis=0)

    for i in range(len(vertices)):
        vertices[i] -= avg

    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=mesh.face_matrix())


def shrink(mesh, shrinkingFactor=0.18):
    """Shrinks a mesh along its vertices' normals."""
    normals  = np.array([normalize(n) for n in mesh.vertex_normal_matrix()])
    vertices = mesh.vertex_matrix()
    faces    = mesh.face_matrix()

    for idx, N in enumerate(normals):
        vertices[idx] -= shrinkingFactor * N
    
    return pymeshlab.Mesh(vertex_matrix=vertices, face_matrix=faces)


def buildParticipationGraph(mesh):
    """
    Builds a list of sets associating each index of vertex to the faces' indices using it.
    The resulting table is accessed using a vertex index.
    """
    faces = mesh.face_matrix()
    participation = [set() for i in range(mesh.vertex_number())]

    for idxFace, face in enumerate(faces):
        for vertex in face:
            participation[vertex].add(idxFace)

    return participation


def buildNeighborhoodGraph(mesh):
    """Builds a list of sets associating each index of vertex to the indices of its direct neighbor vertices."""
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
    """Associates to each vertex the shortest geodesic distance from it to the border."""
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
    """
    Flattens a mesh by inspecting the normals variations in a sphere around each vertex.
    A seed vertex is chosen and a breadth-first iteration is launched from there.
    A certain angle is tolerated between normals, above that, it is considered as from the oposite side.
    In the angle-testing phase, neighbors are taken from a kd-tree (in a sphere) to grab and discard points of the oposite face.
    """
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
        
        if marking[current]['visited'] != -1: # -1 means "not processed yet"/unmarked.
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
    """
    Finds the vertices of 'sphere' that have been deleted in 'sphereClean' and applies these deletions to 'original'.
    The projection on a sphere allows to fold the remaining parts and increases the angle.
    """
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


def makeAABB(mesh):
    """
    Processes the axis-aligned bounding-box of a given mesh.
    Return: [(minX, maxX), (minY, maxY), (minZ, maxZ)]
    """
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
    return sum([np.linalg.norm(np.cross(vertices[face[1]] - vertices[face[0]], vertices[face[2]] - vertices[face[0]])) for face in faces]) / 2.0


def processPerimeter(mesh, borders):
    """Processes the perimeter by summing the perimeter of every holes. Some contact surfaces form a tube hence don't have a perimeter."""
    vertices = mesh.vertex_matrix()
    acc      = 0
    
    for idx, border in enumerate(borders):
        indices = border + [border[0]]
        perim   = sum([np.linalg.norm(vertices[i] - vertices[i+1]) for i in range(len(indices)-1)])
        acc    += perim
    
    return acc


def findBorders(mesh, graph, participation):
    """
    Finds every loops of vertices being borders of the mesh.
    Returns a list of lists. Each list is a sequence of vertex indices in the correct order according to the way they are linked through edges.
    """
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

def extractMeasures(state):

    exportName = makeSourceName(state.getCurrent())

    state.setOperation(f"= = = = = = Importing '{exportName}' = = = = = =", 'tl')
    ms_base = pymeshlab.MeshSet()
    ms_base.load_new_mesh(state.current)

    nbBefore = len(ms_base)
    ms_base.apply_filter("generate_splitting_by_connected_components")
    nbAfter  = len(ms_base)

    chunks = [ms_base[i] for i in range(nbBefore, nbAfter)]

    state.setOperation(f"    | = = = = = = Currently {nbAfter - nbBefore} mesh loaded. = = = = = =", 'tl')

    for iC, chunk in enumerate(chunks):
        
        # Creating new line in CSV table + production iteration
        state.results.newRow()
        ms = pymeshlab.MeshSet()

        produced = {
            'center' : None,
            'cleaned': None,
            'json'   : None
        }

        try:
            state.setOperation(f"    | Processing mesh {iC+1}/{nbAfter - nbBefore}.", 'tl')
            
            state.results.setValue("source", exportName)
            state.results.setValue("islands", nbAfter - nbBefore)
            state.results.setValue("rank", iC+1)

            # Centering the mesh around the origin of the world.

            state.setOperation("        | Centering the mesh at the center of the world.", 'l')
            centered = geometryToOrigin(chunk)
            ms.add_mesh(centered)
            ms.apply_filter("meshing_merge_close_vertices")
            expNameCenter = os.path.join(state.getOutputDirectory(), f"1-centered-{exportName}-{str(iC+1).zfill(4)}.obj")
            ms.save_current_mesh(expNameCenter)
            produced['center'] = expNameCenter
        
            state.setOperation("        | Building a graph giving, for each index of vertex, the indices of its neighbors vertices.", 'l')
            graph = buildNeighborhoodGraph(ms.current_mesh())

            # Shrinking the mesh along the normals of its vertices

            state.setOperation("        | Shrinking the mesh along its vertices' normals.", 'l')
            shrunk = shrink(ms.current_mesh())
            ms.add_mesh(shrunk)
            ms.save_current_mesh(os.path.join(state.getOutputDirectory(), f"2-shrunk-{exportName}-{str(iC+1).zfill(4)}.obj"))

            # Smoothing the mesh

            state.setOperation("        | Smoothing the mesh by interpolation each vertex with its neighbors.", 'l')
            smooth = averageSmoothing(shrunk, graph)
            ms.add_mesh(smooth)
            ms.save_current_mesh(os.path.join(state.getOutputDirectory(), f"3-smooth-{exportName}-{str(iC+1).zfill(4)}.obj"))

            # Flattening the mesh (removing outter layer)

            state.setOperation("        | Create a rough version of a 0-thickness mesh.", 'l')
            flat = flatten(smooth, smooth, graph)
            ms.add_mesh(flat)
            ms.apply_filter("meshing_repair_non_manifold_edges")
            ms.apply_filter("meshing_repair_non_manifold_vertices")
            flat = ms.current_mesh()
            ms.save_current_mesh(os.path.join(state.getOutputDirectory(), f"4-flattened-{exportName}-{str(iC+1).zfill(4)}.obj"))

            # Cleaning the mesh for remaining borders

            state.setOperation("        | Building a sphere projection of our rough flatenned version.", 'l')
            radius, sphere = sphereProject(ms.current_mesh())
            state.results.setValue("radius", round(radius, 3))
            
            state.setOperation("        | Removing points projected at the same place on the sphere (corresponding to failed borders)", 'l')
            ms.add_mesh(sphere)
            ms.apply_filter("meshing_cut_along_crease_edges")
            ms.apply_filter("meshing_remove_connected_component_by_face_number")
            ms.save_current_mesh(os.path.join(state.getOutputDirectory(), f"5-sphere-{exportName}-{str(iC+1).zfill(4)}.obj"))

            state.setOperation("        | Removing the vertices on the rough version corresponding to the one removed at the previous step.", 'l')
            cleaned = compare(flat, sphere, ms.current_mesh())
            ms.add_mesh(cleaned)

            state.setOperation("        | Cleaning the correct version of the surface.", 'l')
            ms.apply_filter("meshing_close_holes", maxholesize=20)
            ms.apply_filter("meshing_snap_mismatched_borders")
            ms.apply_filter("meshing_repair_non_manifold_vertices")
            ms.apply_filter("meshing_merge_close_vertices")
            ms.apply_filter("meshing_remove_duplicate_faces")
            expCleanPath = os.path.join(state.getOutputDirectory(), f"6-cleaned-{exportName}-{str(iC+1).zfill(4)}.obj")
            ms.save_current_mesh(expCleanPath)
            produced['cleaned'] = expCleanPath

            state.setOperation("        | Finding all loops of vertices being on borders", 'l')
            graph     = buildNeighborhoodGraph(ms.current_mesh())
            partGraph = buildParticipationGraph(ms.current_mesh())
            borders   = findBorders(ms.current_mesh(), graph, partGraph)

            state.setOperation("        | The perimeter is the border with the biggest length", 'l')
            perimeter = processPerimeter(ms.current_mesh(), borders)
            state.results.setValue("perimeter", round(perimeter, 3))

            state.setOperation("        | Processing the number of holes and the area of the surface.", 'l')
            state.results.setValue("nbHoles", len(borders)-1)
            area = processArea(ms.current_mesh())
            state.results.setValue("area", round(area, 3))

            state.setOperation("        | Determining the Axis Aligned measures.", 'l')
            bb = makeAABB(ms.current_mesh())
            state.results.setValue('aa_width', round(bb[0][1] - bb[0][0], 3))
            state.results.setValue('aa_height', round(bb[1][1] - bb[1][0], 3))
            state.results.setValue('aa_depth', round(bb[2][1] - bb[2][0], 3))

            state.setOperation("        | Building geodesic distance to the closest border.", 'l')
            distances = distanceToBorder(ms.current_mesh(), graph, borders)
            distancesDict = {'geodesic': [int(i) for i in distances]}
            geoPath = os.path.join(state.getOutputDirectory(), f"7-geodesic-{exportName}-{str(iC+1).zfill(4)}.json")
            produced['json'] = geoPath
            f = open(geoPath, 'w')
            json.dump(distancesDict, f)
            f.close()
            
            state.setOperation("        | Max number of connected components reached during decimation caracterizes the sprawlingness of the surface.", 'l')
            maxCompos = decimate(distances, graph)
            state.results.setValue('maxCompos', maxCompos)

            state.produced.append(produced)
            state.success.setdefault(exportName, []).append(iC+1)
        
        except:
            state.fails.setdefault(exportName, []).append(iC+1)
            state.setOperation(f"Skipping part {iC+1} from {exportName} due to an error.", 'tl')
            state.results.cancelRow()
        
        state.results.exportTo(state.getOutputDirectory(), state.getResultsName())

#
# outputDir: Path to the folder to which all produced files will be exported (CSV, blend, ...)
# inputs: Path to a .wrl or a folder containing .wrl files.
# clear: Should all .obj be removed by the end of the execution ?
# csvName: Choose the name that the results file will have.
# blender: Path to the blender binary or shell command.
# secondaryScript: Path to the "generateBlenderFile.py" script.
# flushDir: If activated, removes all files from the output directory before starting EXCEPT the file having the name of the result.
#           If turned off, and if the script detects files in the provided folder, you will be asked whether you still want to export there or not.
# resetAll: Useless if flushDir is not activated. Otherwise, allows the script to delete the results file of the previous run during the flushing phase.
#

state = State(
    outputDir="/home/benedetti/Downloads/wrl-v2/output/",
    inputs="/home/benedetti/Downloads/wrl-v2/",
    clear=False,
    csvName="results.csv",
    blender="/home/benedetti/Desktop/blender-formation-3d/blender-4.1.1-linux-x64/blender",
    secondaryScript="/home/benedetti/Documents/imagej_macros_and_scripts/clement/stand-alones/astrocytesBloodVessels/generateBlenderFile.py",
    flushDir=True,
    resetAll=True
)


state.run()