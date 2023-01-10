import math

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   BASIC POINTS AND VECTORS OPERATIONS                                                               #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# @brief Determines whether a number (positive or negative) is close enough from zero to be considered null.
def isSmall(e):
    return abs(e) < 0.0001


## @brief Subtraction: v1 - v2
def vecSub(v1, v2):
    x1, y1 = v1
    x2, y2 = v2
    return (x1-x2, y1-y2)


## @brief Process the distance between two points
def distance(p1, p2):
    return math.sqrt(pow(p2[0] - p1[0], 2) + pow(p2[1] - p1[1], 2))


## @brief Normalize a vector
def normalize(vec):
    length = distance((0, 0), vec)
    return (vec[0]/length, vec[1]/length)


def drawWithMatPlotLib(mvng, save=False, path=None):
    try:
        import matplotlib.pyplot as plt
    except:
        print("Matplotlib is required")
        return False

    from rays import Ray

    plt.figure(figsize=(15, 15))
    plt.axis('equal')

    points     = list(map(Ray.getOrigin, mvng.points))
    directions = list(map(Ray.getDirection, mvng.points))
    curvatures = list(map(Ray.getCurvature, mvng.points))

    # Draw normals
    for idx, (dx, dy) in enumerate(directions):
        xs = [points[idx][0], points[idx][0]+dx*0.5]
        ys = [points[idx][1], points[idx][1]+dy*0.5]
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

    for x, y, c in zip(xs, ys, colors):
        plt.scatter(x, y, 100, color=c, zorder=2)

    plt.tight_layout()

    if save:
        plt.savefig(path)
    else:
        plt.show()
    return True