from basicOps import isSmall, vecSub, normalize, distance
import math

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   RAY ORIGIN BUILDERS                                                                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

## @brief Creates a list of angles (in radians) on 2pi (360deg)
def makeAnglesList(nPoints):
    incre = (2 * math.pi) / nPoints
    angle = -math.pi
    angles = []

    for i in range(nPoints):
        angles.append(angle)
        angle += incre

    return angles


## @brief Builds a list of vector that are use to orient rays for expanding shapes.
def expandingDirVectors(angles):
    return [(math.cos(angle), math.sin(angle)) for angle in angles]


## @brief Builds a list of vector that are use to orient rays for shrinking shapes.
def shrinkingDirVectors(angles):
    return [(-math.cos(angle), -math.sin(angle)) for angle in angles]


#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

## @brief Given a direction vector, builds a point close from the boundaries of the box.
def borderFromRay(d, ori, height, width):
    if isSmall(d[0]):
        return (ori[0], 0) if d[1] < 0 else (ori[0], height-1)
    else:
        if d[0] < 0:
            dist = ori[0]
        else:
            dist = width - ori[0]
        tx = abs(dist / d[0])

    if isSmall(d[1]):
        return (0, ori[1]) if d[0] < 0 else (width-1, ori[1])
    else:
        if d[1] < 0:
            dist = ori[1]
        else:
            dist = height - ori[1]
        ty = abs(dist / d[1])

    t = min(tx, ty)

    x = ori[0] + d[0] * t
    y = ori[1] + d[1] * t

    if x < 0:
        x = 0
    if x >= width:
        x = width - 0.01

    if y < 0:
        y = 0
    if y >= height:
        y = height - 0.01

    return (x, y)


def buildShrinkingBox(nbPoints, height, width):
    vDirs = expandingDirVectors(makeAnglesList(nbPoints))
    points = [borderFromRay((-vDir[0], -vDir[1]), (width/2, height/2), height, width) for vDir in vDirs]
    return points, vDirs


#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -


## @brief Given an angle, calculates the module to create an ellipsis (in polar coordinates)
def makeEllipsisPoint(width, height, angle):
    b = int(height / 2) - 1
    a = int(width / 2) - 1
    
    return (a * b) / math.sqrt((b*b*math.cos(angle)*math.cos(angle)) + (a*a*math.sin(angle)*math.sin(angle)))


## @brief Builds a list of point representing an ellipsis, and a list of direction vector to make it shrink evenly.
## @param nbPoints Number of points to generate.
## @param height Height of the ellipsis
## @param width Width of the ellipsis
## @return A list of 2D points and a list of 2D vectors.
def buildShrinkingEllipsis(nbPoints, height, width):
    angles = makeAnglesList(nbPoints)
    points = []
    vDirs = []

    for angle in angles:
        ro = makeEllipsisPoint(width, height, angle)
        x = (width / 2) + ro * math.cos(angle)
        y = (height / 2) + ro * math.sin(angle)
        
        points.append((x, y))
        vDirs.append((-math.cos(angle), -math.sin(angle)))
    
    return points, vDirs


#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

## Builds several points that will expand as a circle over iterations.
def buildExpandingCircle(nbPoints, origin):
    vDirs = expandingDirVectors(makeAnglesList(nbPoints))
    points = [origin for i in range(nbPoints)]
    return points, vDirs


