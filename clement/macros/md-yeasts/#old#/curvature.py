from pprint import pprint
import math
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np


def distance(p1, p2):
    return math.sqrt(pow(p1[0] - p2[0], 2) + pow(p1[1] - p2[1], 2))


def normalize(v):
    l = distance((0, 0), v)
    v0 = v[0] / l
    v1 = v[1] / l
    return (v0, v1)


def spreadPoints(points):
    nouvPts = []
    
    for i in range(len(points)):
        a = points[i-1] # A
        b = points[i]   # B

        if i+1 >= len(points):
            c = points[0] # C
        else:
            c = points[i+1] # C

        # Vecteurs directeurs
        v1 = normalize((b[0]-a[0], b[1]-a[1])) # AB
        v2 = normalize((c[0]-b[0], c[1]-b[1])) # BC

        angle = math.acos(v1[0]*v2[0]+v1[1]*v2[1])

        # We want to keep sharp angles in place.
        if angle > math.pi/5:
            nouvPts.append(points[i])
            continue
        
        pt = ((a[0] + c[0])/2, (a[1] + c[1])/2)
        nouvPts.append(pt)
    
    return nouvPts


def updateNormals(points, directions):
    nouvDirs = []
    for i in range(len(points)):
        # = = = = 1. Acquiring three points around the current one. = = = = 
        a = points[i-1] # A
        b = points[i]   # B

        if i+1 >= len(points):
            c = points[0] # C
        else:
            c = points[i+1] # C

        # = = = = 2. Building a director vector for each edge. = = = = 
        v1 = (b[0]-a[0], b[1]-a[1]) # AB
        v2 = (c[0]-b[0], c[1]-b[1]) # BC

        # = = = = 3. Parametric equation for each curve in which edges are in. = = = = 
        beta1  = -v1[0]
        alpha1 = v1[1]
        delta1 = -(alpha1 * a[0] + beta1 * a[1])

        beta2 = -v2[0]
        alpha2 = v2[1]
        delta2 = -(alpha2 * b[0] + beta2 * b[1])

        # = = = = 4. Normalized edges normals (if not normalized, edge length influences direction too much). = = = = 
        n1 = normalize((alpha1, beta1))
        n2 = normalize((alpha2, beta2))

        # = = = = 5. Vertex length = average of two edge normals = = = = 
        nx = 0.5 * n1[0] + 0.5 * n2[0]
        ny = 0.5 * n1[1] + 0.5 * n2[1]

        # = = = = 6. Checking that the normal is pointing towards the good direction. = = = = 
        cx = directions[i][0]
        cy = directions[i][1]

        if nx * cx + ny * cy > 0:
            n = (nx, ny)
        else:
            n = (-nx, -ny)
        
        # = = = = 7. Normalizing final normal vector and modifying list entry = = = = 
        n = normalize(n)
        nouvDirs.append((n[0], n[1]))
    
    return nouvDirs

    
def processCurvate(points, directions):
    
    curvatures = []

    for i in range(len(points)):
        # = = = = 1. Acquiring three points around the current one. = = = = 
        a = points[i-1] # A
        b = points[i]   # B

        if i+1 >= len(points):
            c = points[0] # C
        else:
            c = points[i+1] # C

        # = = = = 2. Building a director vector for each edge. = = = = 
        v1 = normalize((b[0]-a[0], b[1]-a[1])) # AB
        v2 = normalize((c[0]-b[0], c[1]-b[1])) # BC

        # = = = = 3. Parametric equation for each curve in which edges are in. = = = = 
        beta1  = -v1[0]
        alpha1 = v1[1]
        delta1 = -(alpha1 * a[0] + beta1 * a[1])

        beta2 = -v2[0]
        alpha2 = v2[1]
        delta2 = -(alpha2 * b[0] + beta2 * b[1])

        # = = = = 4. Normalized edges normals (if not normalized, edge length influences direction too much). = = = = 
        n1 = normalize((alpha1, beta1))
        n2 = normalize((alpha2, beta2))

        # # # # # # # # # # # # # # # #
        # Angle between the vectors
        dot = v1[0] * v2[0] + v1[1] * v2[1]
        ang = math.acos(dot)

        # Processing sign
        dotN = n1[0] * v2[0] + n1[1] * v2[1]
        dotN /= abs(dotN) # 1.0 or -1

        # Append
        curvatures.append(dotN * (2.0 * math.sin(ang / 2)))
    
    return curvatures


def importContour(path):
    beforeFile = open(path, 'r')
    beforeContent = beforeFile.read()
    beforeFile.close()
    beforeLines = [l for l in beforeContent.split('\n') if len(l) > 0]

    points     = []
    directions = []

    for line in beforeLines:
        line = line.replace("(", "").replace(")", "").replace(" ", "")
        t1, t2 = line.split(';')
        p1, p2 = t1.split(',')
        n1, n2 = t2.split(',')

        points.append((float(p1), float(p2)))
        directions.append((float(n1), float(n2)))

    return points, directions



def importInBlender(points, directions):
    import bpy

    edges = [(i, i+1) for i in range(len(points)-1)]
    edges.append((len(points)-1, 0))
    new_mesh = bpy.data.meshes.new('enveloppe')
    new_mesh.from_pydata(points, edges, [])
    new_mesh.update()
    new_object = bpy.data.objects.new('enveloppe', new_mesh)
    bpy.context.scene.collection.children[0].objects.link(new_object)


    new_collection = bpy.data.collections.new('normals')
    bpy.context.scene.collection.children[0].children.link(new_collection)
    
    for i, (p, d) in enumerate(zip(points, directions)):
        new_mesh = bpy.data.meshes.new('enveloppe')
        px = p[0] + d[0] * 3
        py = p[1] + d[1] * 3
        new_mesh.from_pydata([p, (px, py, 0)], [(0, 1)], [])
        new_mesh.update()
        new_object = bpy.data.objects.new(f"nml_{str(i).zfill(4)}", new_mesh)
        new_collection.objects.link(new_object)


def expand(points, directions, dist):
    nouvPts = []
    for i, (p, d) in enumerate(zip(points, directions)):
        nP = (
            p[0] + dist * d[0],
            p[1] + dist * d[1]
            )
        nouvPts.append(nP)
    return nouvPts


def drawPolygon(pointsList, directionsList, curvaturesList):

    plt.figure(figsize=(15, 15))
    plt.axis('equal')

    for points, directions, curvatures in zip(pointsList, directionsList, curvaturesList):
        # Draw normals
        for idx, (dx, dy) in enumerate(directions):
            xs = [points[idx][0], points[idx][0]+dx*3]
            ys = [points[idx][1], points[idx][1]+dy*3]
            clr = (abs(dx), abs(dy), 0.0)
            plt.plot(xs, ys, linewidth=2, color=clr, zorder=0)

        # Draw polygon
        xs, ys = zip(*(points + [points[0]]))
        plt.plot(xs, ys, linewidth=2, zorder=1)

        # Draw points
        tempCurvatures = [abs(c) for c in curvatures]
        mx = max(tempCurvatures)

        colors = []
        for c in curvatures:
            if c < 0:
                colors.append((0.0, abs(c)/mx, 0.0))
            else:
                colors.append((abs(c)/mx, 0.0, 0.0))

        for x, y, c in zip(xs, ys, colors):
            plt.scatter(x, y, 100, color=c, zorder=2)

    # Display
    plt.tight_layout()
    plt.show()


points, directions = importContour("/home/clement/Desktop/update_normals/before_update.txt")
# directions = updateNormals(points, directions)
curvatures = processCurvate(points, directions)


drawPolygon([points], [directions], [curvatures])


# - [ ] Par sécurité, check que le dot product des directions des deux plus fortes curvatures est négatif (pointent l'un vers l'autre).
# - [ ] Dans quels cas la segmentation basique échoue ?
# - [ ] Que faire dans le cas où il n'y a pas de halo blanc autour de la levure ?
# - [ ] Check dans le second channel où se trouve la donnée par rapport à l'endroit où on arrive.
# - [ ] Devrait-on détecter les self-colisions ?
# - [ ] Mettre une sécurité pour les infinite-loops.
# - [ ] Au lieu de s'arrêter à la tolérance, continuer et changer la liste de record.
#       Quand s'arrêter si on choisi cette méthode ? Quand on retombe sur du noir ?
# - [ ] Ajouter une sécurité avant de faire le contour qui check qu'on a bien un certain nombre de components ?
#       Selon la taille du trou on peu réparer la courbe.
# - [ ] Ajouter une fonction qui corrige le contour en fonction du contour signé.
#       On peut avoir de petites variations avant les cornes, mais pas de grosses variations en fermeture.
#       Les deux cornes ont une variation en ouverture.
# - [ ] Une fois qu'on est en phase de collecte de données, on peut arrêter le shrink quand un certain % des points se sont arrêtés.
#       Le polygon doit se comporter comme une state machine où l'état influence le comportement des méthodes.