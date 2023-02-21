from basicOps import isSmall, vecSub, normalize, distance
import math

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   RAY ORIGIN BUILDERS                                                                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

def makeAnglesList(nPoints):

    """
    This function iterates in M{[-2S{pi}, 2S{pi}[} to create uniformaly scattered angles around the unit circle.

    @type  nPoints: int
    @param nPoints: Number of angles to generate in the range M{[-2S{pi}, 2S{pi}[}.

    @rtype: list(float)
    @return: A list of float containing evenly spaced values in M{[-2S{pi}, 2S{pi}[}.
    """

    incre = (2 * math.pi) / nPoints
    angle = -math.pi
    angles = []

    for i in range(nPoints):
        angles.append(angle)
        angle += incre

    return angles


def expandingDirVectors(angles):

    """
    Transforms a list of angles into a list of vectors originating from the point (0, 0).
    The produced vectors are already normalized. 
    Their construction points are:
        - A point on the unit circle
        - The origin, (0, 0).
    Basically, M{P(S{theta}) = (cos(S{theta}), sin(S{theta}))}.

    @type  angles: list(float)
    @param angles: A list of float in M{[-2S{pi}, 2S{pi}[.}

    @rtype: list((float, float))
    @return: A list of unit vectors corresponding on the angles passed in parameters.
    """

    return [(math.cos(angle), math.sin(angle)) for angle in angles]



def shrinkingDirVectors(angles):

    """
    Transforms a list of angles into a list of vectors originating from the unit circle, oriented towards the point (0, 0).
    The produced vectors are already normalized. 
    Their construction points are: 
        - A point on the unit circle
        - The origin, (0, 0).
    Basically, M{P(S{theta}) = (-cos(S{theta}), -sin(S{theta}))}.

    @type  angles: list(float)
    @param angles: A list of float in [-2*pi, 2*pi[.

    @rtype: list((float, float))
    @return: A list of unit vectors corresponding to the angles passed in parameters.
    """

    return [(-math.cos(angle), -math.sin(angle)) for angle in angles]


#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

def borderFromRay(d, ori, height, width):
    
    """
    Given a direction vector, builds a point close from the boundaries of the box.
    The point is guaranteed to touch the edge of the box.
    The box is defined by its height and width. It is supposed that it originates in (0, 0).

    @type  d: (float, float)
    @param d: Direction to follow from the origin to reach the image's frame.
    @type  ori: (float, float)
    @param ori: The point that we consider as being the origin from which we launch our rays.
    @type  height: float
    @param height: Height of the box (frame of the image)
    @type  width: float
    @param width: Width of the box (frame of the image)

    @rtype: (float, float)
    @return: A point on the image's frame along the C{d} vector. (Necessarily "in front" of the vector).
    """

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

    """
    Uses the L{borderFromRay} function to build a polygon all around an image.
    Also computes director vectors to make it grow.

    @type  nbPoints: int
    @param nbPoints: Number of points to generate along the image's frame to form a polygon.

    @rtype: list((float, float))
    @return: A list of points that can be used as a polygon, matching the image's frame.
    """

    vDirs = expandingDirVectors(makeAnglesList(nbPoints))
    points = [borderFromRay((-vDir[0], -vDir[1]), (width/2, height/2), height, width) for vDir in vDirs]
    return points, vDirs


#  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -

def makeEllipsisPoint(width, height, angle):

    """
    Calculates the length of the "radius" of an ellipse for a given angle on the trigonometric circle.
    The ellipse will necessarily be the biggest one that can fit in the image frame.

    @type  width: float
    @param width: Width of the box in which the ellipse must fit.
    @type  height: float
    @param height: Height of the box in which the ellipse must fit.
    
    @rtype: float
    @return: The local radius at a given angle of the biggest ellipse that can fit in the frame.
    """

    b = int(height / 2) - 1
    a = int(width / 2) - 1
    
    return (a * b) / math.sqrt((b*b*math.cos(angle)*math.cos(angle)) + (a*a*math.sin(angle)*math.sin(angle)))


def buildShrinkingEllipsis(nbPoints, height, width):

    """
    Builds a list of points representing an ellipse, and a list of direction vector to make it shrink evenly.

    @type  nbPoints: int
    @param nbPoints: Number of points to generate.
    @type  height: float
    @param height: Height of the ellipsis
    @type  width: float
    @param width: Width of the ellipsis

    @rtype: (list((float, float)), list((float, float)))
    @return: A list of 2D points and a list of 2D vectors.
    """

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

def buildExpandingCircle(nbPoints, origin):
    """
    Builds several points that will expand as a circle over iterations.

    @type  nbPoints: int
    @param nbPoints: Number of points to fit on the circle.
    @type  origin: (float, float)
    @param origin: Origin of the circle.

    @rtype: (list((float, float)), list((float, float)))
    @return: A list of 2D points and a list of 2D vectors.
    """
    vDirs = expandingDirVectors(makeAnglesList(nbPoints))
    points = [origin for i in range(nbPoints)]
    return points, vDirs


