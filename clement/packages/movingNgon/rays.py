from basicOps import vecSub, normalize, distance, isSmall

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   RAYS BASE CLASS                                                                                   #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

class Ray(object):

    """
    Class representing a ray with its origin and its direction. Handles moves.
    It keeps track of the distance it travelled, the number of iterations that it took to get here, and manages its own step size.
    It contains a curvature attribute which is useful only if you couple it with a MovingNGon object.
    """
    
    def __init__(self, o, d, s):

        """
        Constructor

        @type  o: (float, float)
        @param o: The origin point of this ray, where it will start its travel.
        @type  d: (float, float)
        @param d: Director vector of this ray. It is recommended to provided something normalized.
        @type  s: float
        @param s: The distance traveled by this ray at each iteration.

        @rtype: Ray
        """

        self.origin    = o
        self.direction = d
        self.stepSize  = s
        self.distance  = 0.0
        self.count     = 0
        self.curvature = 0.0

    
    def reset(self):
        """
        Reset function. Doesn't have any effect on this class. Only usefull once overriden.

        @rtype: void
        """
        pass
    

    def makeCopy(self):
        """
        Makes a deep copy of this object.
        You can use the function C{deepcopy()} from the C{copy} module if it exists in your version of Python instead of this function.

        @rtype: Ray
        @return: An independant copy of the summoner.
        """
        r = Ray(self.origin, self.direction, self.stepSize)
        r.distance = self.distance
        r.count = self.count
        r.curvature = self.curvature
        return r


    def getCurvature(self):
        """
        Accessor on the C{curvature} attribute.

        @rtype: float
        @return: A number in [-1.0, 1.0] determining the curvature at this point. The sign indicates the curvature direction.
        """
        return self.curvature


    def getStepSize(self):
        """
        Accessor on the C{stepSize} attribute.

        @rtype: float
        @return: A strictly positive number representing the distance traveled by this ray each time C{move} is summoned.
        """
        return self.stepSize

    
    def traveledDistance(self):
        """
        Accessor on the C{distance} attribute.

        @rtype: float
        @return: A number >= 0 representing the distance that this point traveled since its instanciation. This is the actual distance, not the srtaight line between the starting point and the current location.
        """
        return self.distance


    def getOrigin(self):
        """
        Accessor on the C{origin} attribute.

        @rtype: (float, float)
        @return: The current location of this instance.
        """
        return self.origin


    def getDirection(self):
        """
        Accessor on the C{distance} attribute.

        @rtype: (float, float)
        @return: A unit vector (2D) representing the direction in which this point travels.
        """
        return self.direction

    
    def getCount(self):
        """
        Accessor on the C{count} attribute.

        @rtype: int
        @return: An integer >= 0 representing the number of time C{move} was called.
        """
        return self.count
    
    
    def setOrigin(self, o):
        """
        Setter for the C{origin} attribute. No safety check performed.

        @type  o: (float, float)
        @param o: A 2D vector representing the new ray's position.

        @rtype: void
        """
        self.origin = o

    
    def setDirection(self, d):
        """
        Setter for the C{direction} attribute.
        A safety check is performed to check that the vector is not (0, 0).
        The provided vector is systematically normalized before being assigned.

        @type  d: (float, float)
        @param d: A 2D vector being the new traveling direction of this ray.

        @rtype: void
        """
        if isSmall(d[0]) and isSmall(d[1]):
            return

        self.direction = normalize(d)

    
    def setStepSize(self, s):
        """
        Setter for the C{stepSize} attribute.
        A safety check is performed to check that the provided value is strictly positive.

        @type  s: float
        @param s: The new traveling distance of this ray.

        @rtype: void
        """
        if s > 0.0:
            self.stepSize = s

    
    def forceStep(self, t):
        """
        Acts like the C{move()} method, but doesn't modify the values of C{travelledDistance()} and C{getCount()}.
        This method doesn't even have to respect the step size of this ray.

        @type  t: float
        @param t: A signed float representing the distance along which this ray must travel.

        @rtype: void
        """
        newPoint = (
            self.origin[0] + t * self.direction[0], 
            self.origin[1] + t * self.direction[1])
        
        self.origin = newPoint

    
    def move(self):
        """
        Method moving a ray along its normal according to the provided step size.

        @rtype: void
        """
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
    """
    Creates a new ray by averaging the coordinates and the directions of two input rays.

    @type  r1: Ray
    @param r1: A ray that will participate to the average.
    @type  r2: Ray
    @param r2: A ray that will participate to the average.

    @rtype: Ray
    @return: A new Ray in the middle of the two input ones.
    """
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

    """
    A Ray of which the C{move()} method has an effect only if a condition is fulfilled.
    Aside this property, this objects behaves like a regular Ray.
    """

    def __init__(self, o, d, s):
        """
        Constructor

        @type  o: (float, float)
        @param o: The origin point of this ray, where it will start its travel.
        @type  d: (float, float)
        @param d: Director vector of this ray. It is recommended to provided something normalized.
        @type  s: float
        @param s: The distance traveled by this ray at each iteration.

        @rtype: ConditionalRay
        """
        super(ConditionalRay, self).__init__(o, d, s)
        self.go = True
        self.distances = []
        self.fx = None

    
    def makeCopy(self):
        """
        Makes a deep copy of this object.
        You can use the function C{deepcopy()} from the C{copy} module if it exists in your version of Python instead of this function.

        @rtype: ConditionalRay
        @return: An independant copy of the summoner.
        """
        r = ConditionalRay(self.origin, self.direction, self.stepSize)
        r.distance = self.distance
        r.count = self.count
        r.curvature = self.curvature
        r.go = self.go
        r.distances = self.distances.copy()
        r.fx = self.fx
        return r

    
    def setTestFunction(self, f):
        """
        Modifies the function that will be used to determine if calling C{move()} on this instance will have an effect.
        The function passed as parameter is supposed to return C{True} if this instance can go one step forward. C{False} otherwise.

        @type  f: bool: (ConditionalRay)
        @param f: A function taking an instance of C{ConditionalRay} and returning a C{boolean}.

        @rtype: void
        """
        self.fx = f


    def reset(self):
        """
        Resets the state of this instance of ray.
        Resetting:
            - Makes this Ray able to move again (if the function returns C{True}).
            - Stores the traveled distance in an array, and sets to 0.0 the current one.
        
        @rtype: void
        """
        self.go = True
        self.distances.append(self.distance)
        self.distance = 0.0


    def checkCondition(self):
        """
        Evaluates the function testing if this ray can move.

        @rtype: bool
        @return: What the provided function should return if this instance was passed in argument.
        """
        if self.fx is None:
            return True
        return self.fx(self)


    def move(self):
        """
        If this ray is allowed to move, makes it go one step forward according to its direction vector.
        If the function returned C{False} a single time, this ray is blocked until C{reset()} was called.
        Calling this method on a blocked ray doesn't have any effet.

        @rtype: bool
        @return: True if the ray successfully moved. False otherwise.
        """
        if not self.go:
            return False
        
        val = self.checkCondition()

        if val:
            super(ConditionalRay, self).move()
            return True
        else:
            self.go = False
            return False

