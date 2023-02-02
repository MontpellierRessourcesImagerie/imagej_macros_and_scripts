import math

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   BASIC POINTS AND VECTORS OPERATIONS                                                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def nextRotate(i, length):

    """
    Processes a rotating incremental index for a list of a certain length.
    The generated index comes back to 0 when the end of the list was reached.

    @type  i: int
    @param i: Previous index used on the list.
    @type  length: int
    @param length: Length of the list on which we are working.

    @rtype: int
    @return: An index in [0, length[ that comes back to 0 when the end was reached.
    """

    i += 1
    if i >= length:
        return 0
    return i


def isSmall(e):
    """
    Determines whether a number (positive or negative) is close enough from zero to be considered null.
    In the current implementation, M{1E-4} is used as the lower bound.

    @type  e: float
    @param e: The float to be tested. Can be positive or negative.

    @rtype: bool
    @return: True if C{e} is neglectable. False otherwise.
    """
    return abs(e) < 0.0001

 
def vecSub(v1, v2):
    """
    Subtraction: v1 - v2

    @type  v1: (float, float)
    @param v1: Left part of the subtraction.
    @type  v2: (float, float)
    @param v2: Right part of the subtraction.

    @rtype: (float, float)
    @return: A 2D vector being the result of v1 - v2 (in this order).
    """
    x1, y1 = v1
    x2, y2 = v2
    return (x1-x2, y1-y2)


def dotProduct(v1, v2):
    """
    Computes the dot product of 2D vectors.

    @type v1: (float, float)
    @type v2: (float, float)

    @rtype: float
    @return: The dot product of the two input vectors.
    """
    return v1[0] * v2[0] + v1[1] * v2[1]


def distance(p1, p2):
    """
    Process the distance between two points.

    @type p1: (float, float)
    @type p2: (float, float)

    @rtype: float
    @return: The distance between the two points passed as parameters.
    """
    return math.sqrt(pow(p2[0] - p1[0], 2) + pow(p2[1] - p1[1], 2))


def normalize(vec):
    """
    Normalize a vector (== turn it into a unit vector)

    @type  vec: (float, float)
    @param vec: A vector to be normalized.

    @rtype: (float, float)
    @return: A 2D vector oriented in the same direction as C{vec} but of unit length.
    """
    length = distance((0, 0), vec)
    return (vec[0]/length, vec[1]/length)


def drawWithMatPlotLib(mvngList, scale=12, nFac=1.0, save=False, path=None, bg=None):
    """
    Function drawing and exporting objects derivated from MovingNGon using MatPlotLib.
    Points, edges and normals are represented on these images.

    @type  mvngList: list(MovingNGon)
    @param mvngList: A list containing instances of MovingNGons that will all the drawn on the same canvas.
    @type  scale: float
    @param scale: The scaling factor for the produced image.
    @type  nFac: float
    @param nFac: Scalar used to influence the length of normals on the drawing, just to see them better.
    @type  save: bool
    @param save: Should the produced image be saved to the disk.
    @type  path: str
    @param path: Full path (file name included) to which the image must be saved.

    @rtype: bool
    @return: The returned boolean simply means that MatPlotLib is installed, it doesn't really represent the status of the function.
    """
    try:
        import matplotlib.pyplot as plt
    except:
        print("Matplotlib is required")
        return False

    from rays import Ray

    plt.figure(figsize=(scale, scale))
    ax = plt.subplot()
    plt.axis('equal')

    if bg is not None:
        ax.imshow(bg)

    for idmvng, mvng in enumerate(mvngList):
        points     = list(map(Ray.getOrigin, mvng.points))
        directions = list(map(Ray.getDirection, mvng.points))
        curvatures = list(map(Ray.getCurvature, mvng.points))

        # Draw normals
        for idx, (dx, dy) in enumerate(directions):
            xs = [points[idx][0], points[idx][0]+dx*nFac]
            ys = [points[idx][1], points[idx][1]+dy*nFac]
            clr = (abs(dx), abs(dy), 0.0)
            plt.plot(xs, ys, linewidth=2, color=clr, zorder=0)

        # Draw polygon
        xs, ys = zip(*(points + [points[0]]))
        plt.plot(xs, ys, linewidth=2, zorder=1)

        # Draw points
        tempCurvatures = [abs(c) for c in curvatures]
        mx = max(tempCurvatures)
        if mx == 0:
            mx = 1

        colors = []
        for c in curvatures:
            if c < 0:
                colors.append((0.0, abs(c)/mx, 0.0))
            else:
                colors.append((abs(c)/mx, 0.0, 0.0))

        markers = ['1', '2', '+', 'x', '.']

        for x, y, c in zip(xs, ys, colors):
            plt.scatter(x, y, 100, color=c, zorder=2, marker=markers[int(idmvng%len(markers))])

        xC, yC = mvng.getOrigin()
        plt.scatter(xC, yC, color='orange', zorder=3)

        xO, yO = mvng.points[0].getOrigin()
        plt.scatter(xO, yO, 90, marker='x', color='cyan', zorder=4)

    plt.tight_layout()

    if save:
        plt.savefig(path)
    else:
        plt.show()
    
    plt.clf()
    plt.close()
    return True