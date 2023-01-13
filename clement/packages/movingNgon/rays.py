from basicOps import vecSub, normalize, distance

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   RAYS BASE CLASS                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## @brief Class representing a ray with its origin and its direction. Handles moves.
#         It keeps track of the distance it travelled, the number of iterations that it took to get here, and manages its own step size.
#         It contains a curvature attribute which is useful only if you couple it with a MovingNGon object.
class Ray(object):

    ## @brief Constructor
    ## @param o The origin point of this ray, where it will start its travel.
    ## @param d Director vector of this ray. It is recommended to provided something normalized.
    def __init__(self, o, d, s):
        self.origin    = o
        self.direction = d
        self.stepSize  = s
        self.distance  = 0.0
        self.count     = 0
        self.curvature = 0.0

    ## @brief Returns the curvature at that points under the form of a signed angle.
    #         A negative value corresponds to a closing, while a positive one to an opening.
    def getCurvature(self):
        return self.curvature

    ## @brief Returns the current step size for each move.
    def getStepSize(self):
        return self.stepSize

    ## @brief Returns the distance traveled by this ray during this iteration (from start to lock)
    def traveledDistance(self):
        return self.distance

    ## @brief Get the current location of the ray.
    def getOrigin(self):
        return self.origin

    ## @brief Get the director vector of this ray
    def getDirection(self):
        return self.direction

    ## @brief Returns the number of move() operations that were called to get to that point.s
    def getCount(self):
        return self.count
    
    ## @brief Modifies the current position of this ray.
    def setOrigin(self, o):
        self.origin = o

    ## @brief Modifies the director vector of this ray
    def setDirection(self, d):
        self.direction = normalize(d)

    ## @brief Sets a new value for the step size
    def setStepSize(self, s):
        if s > 0.0:
            self.stepSize = s

    ## @brief Acts like the move method, but doesn't modify the values of travelledDistance() and getCount()
    def forceStep(self):
        newPoint = (
            self.origin[0] + self.stepSize * self.direction[0], 
            self.origin[1] + self.stepSize * self.direction[1])
        
        self.origin = newPoint

    ## @brief Method moving a ray along its normal according to the provided step size.
    def move(self):

        newPoint = (
            self.origin[0] + self.stepSize * self.direction[0], 
            self.origin[1] + self.stepSize * self.direction[1])
        
        self.distance += self.stepSize
        self.origin = newPoint
        self.count += 1


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   UTILS RAY                                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def merge(r1, r2):
    ox1, oy1 = r1.getOrigin()
    ox2, oy2 = r2.getOrigin()
    dx1, dy1 = r1.getDirection()
    dx2, dy2 = r2.getDirection()
    x = (ox1 + ox2) / 2
    y = (oy1 + oy2) / 2
    dx = (dx1 + dx2) / 2
    dy = (dy1 + dy2) / 2
    return Ray((x, y), (dx, dy), r1.getStepSize())

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   CONDITIONAL RAY                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


class ConditionalRay(Ray):

    def __init__(self, o, d, s):
        super(ConditionalRay, self).__init__(o, d, s)
        self.go = True
        self.distances = []
        self.fx = None

    
    def setTestFunction(self, f):
        self.fx = f


    ## @brief Resets the locking status of this ray so it can move again.
    def reset(self):
        self.go = True
        self.distances.append(self.distance)
        self.distance = 0.0


    def checkCondition(self):
        if self.fx is None:
            return True
        return self.fx(self)


    def move(self):
        if not self.go:
            return False
        
        val = self.checkCondition()

        if val:
            super(ConditionalRay, self).move()
            return True
        else:
            self.go = False
            return False

