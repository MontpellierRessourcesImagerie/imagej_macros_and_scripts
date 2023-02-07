import math
from rays import Ray, ConditionalRay, merge
from basicOps import vecSub, normalize, distance, nextRotate, dotProduct

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   MOVING N-GON BASE CLASS                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

class MovingNGon(object):

    """
    Class representing a polygon, of which points are actually rays.
    By shifting the rays' origin along their normal direction, the n-gon can shrink or grow.
    """

    def __init__(self, center, s):
        """
        Constructor.

        @type  center: (float, float)
        @param center: Supposed center of this n-gon. Can be recomputed later.
        @type  s: float
        @param s: Step size of the rays (distance they will travel at each iteration along their direction vector).
        """
        self.points   = []
        self.origin   = center
        self.stepSize = s


    def makeCopy(self):
        """
        Make a deep copy of this object.
        """
        n = MovingNGon(self.origin, self.stepSize)
        n.points = [p.makeCopy() for p in self.points]
        return n


    def inflate(self, maxIters=100):
        """
        Moves a point having a positive curvature in the opposite direction of their direction vector.
        It results in a star-convex shape containing strictly negative curvatures (closing).
        To prevent infinite loops, an iteration cap was set. So it is not guaranteed that the result is correct.

        @type  maxIters: int
        @param maxIters: Maximal number of steps allowed to make a point's curvature null or negative. To prevent infinite loops.
        """
        run = True
        current = 0

        while (current < maxIters) and run:
            run = False
            for p in self.points:
                if p.getCurvature() >= 0.01:
                    p.forceStep(-0.5)
                    run = True
            current += 1
            self.processCurvature()


    def getOrigin(self):
        """
        Accessor on the polygon's center.

        @rtype: (float, float)
        @return: The point that is considered the center for this polygon.
        """
        return self.origin


    def getNPoints(self):
        """
        Accessor on the number of points. Processed.

        @rtype: int
        @return: The number of points of this polygon.
        """
        return len(self.points)


    def getStepSize(self):
        """
        Accessor of the step size.

        @rtype: float
        @return: The distance traveled by a ray at each iteration.
        """
        return self.stepSize
    

    def forceStep(self, t):

        """
        Forces a step for each contained.

        @type  t: float
        @param t: The distance to travel for this forced step.

        @rtype: void
        """

        for p in self.points:
            p.forceStep(t)
    

    def setStepSize(self, s):
        """
        Modifies the step size for every ray of this polygon.

        @type  s: float
        @param s: A new step size that will be applied to every rays.

        @rtype: void
        """
        if s > 0:
            self.stepSize = s
            for p in self.points:
                p.setStepSize(s)


    def makeRaysFromPoints(self, points, directions):
        """
        Takes a list of coordinates and a list of direction vectors, and builds a list of rays from that.

        @type  points: list((float, float))
        @param points: List of points that will determine the origins of the rays composing the n-gon.
        @type  directions: list((float, float))
        @param directions: List of normalized 2D vectors representing the direction vectors of the rays.

        @rtype: void
        """
        self.points = [Ray(p, d, self.stepSize) for p, d in zip(points, directions)]


    def makeNormalsFromCentroid(self, mode):
        """
        This function recalculates normals according to the position of each point and the current polygon's centroid.
        In this case, the normal for the i-th point is: M{Ni = |O - Pi|} or M{Ni = -|O - Pi|} if we are in expansion mode.

        @type  mode: str
        @param mode: This parameter can have the following values:
            - C{'SHRINK'} to make the direction vectors face inwards the polygon.
            - C{'EXPAND'} to make the polygon grow at each iteration.
        
        @rtype: void
        """
        if (mode != 'SHRINK') and (mode != 'EXPAND'):
            return
        
        for p in self.points:
            vDir = normalize(vecSub(p.getOrigin(), self.origin))
            if mode == 'SHRINK':
                vDir = (-1*vDir[0], -1*vDir[1])
            p.setDirection(vDir)


    def getSegmentsSize(self):
        """
        Computes a list containing the length (in pixels) of every segments composing the polygon.

        @rtype: list(float)
        @return: A list of float corresponding to the length of each segment.
        """
        distances = []

        for i in range(0, len(self.points)-1):
            p1 = self.points[i].getOrigin()
            p2 = self.points[i+1].getOrigin()
            distances.append(distance(p1, p2))
        
        p1 = self.points[0].getOrigin()
        p2 = self.points[-1].getOrigin()
        distances.append(distance(p1, p2))

        return distances

    
    def setOriginFromPoints(self):
        """
        Updates the position of this polygon's centroid according to the centroid of this polygon's points.

        @rtype: void
        """
        xs, ys = zip(*[t.getOrigin() for t in self.points])
        self.origin = (sum(xs)/len(self.points), sum(ys)/len(self.points))


    def getSegmentLengthVariations(self):
        """
        Process a scalar for each segment representing the factor between the theorical size of a segment, and it actual size.
        The theorical size is the size of a segment if all segments had the same length for this given polygon.
        Ex: A factor of 1 means that it is exactly the theorical size, a factor of 2 means that it is twice longer than "it should be".
        This function helps to detect where the segmentation might be less precise (wide jump) or where the density of points is unecessarily high.

        @rtype: list(float)
        """
        distances = self.getSegmentsSize()
        total = sum(distances)
        theory = total / len(self.points)
        return list(map(lambda e : e / theory, distances))


    def getPerimeter(self):
        """
        Processes the perimeter of this instance of polygon.

        @rtype: float
        @return: The perimeter of this polygon.
        """
        distances = self.getSegmentsSize()
        return sum(distances)

    
    def split(self, i, j, sharpCut=False):
        """
        Splits this polygon into two smaller polygons, given two indices of points.
        The new polygons share un edge while no ray operation is launched.

        @type  i: int
        @param i: Index of a point that will be part of of both polygons after the cut was performed. Condition: i < j
        @type  j: int
        @param j: Index of a point that will be part of of both polygons after the cut was performed. Condition: i < j
        @type  sharpCut: bool
        @param sharpCut: Should the normals of c{i} and C{j} be updated after the cut or kept like they were before.

        @rtype: (MovingNGon, MovingNGon)
        @return: Two new instances of MovingNGon, independant of the original. The union of these two instances would form the original polygon.
        """
        if i >= j:
            return None, None
        
        mn1 = self.makeCopy()
        mn2 = self.makeCopy()

        mn1.points = [p.makeCopy() for p in self.points[i:j+1]]
        mn2.points = [p.makeCopy() for p in self.points[0:i+1] + self.points[j:]]

        mn1.updateCentroid()
        mn2.updateCentroid()

        mn1.updateNormals()
        mn2.updateNormals()

        if sharpCut:
            v1 = normalize(vecSub(self.points[j].getOrigin(), self.points[i].getOrigin()))
            v2 = normalize(vecSub(self.points[i].getOrigin(), self.points[j].getOrigin()))

            mn1.points[0].setDirection(v1)
            mn1.points[-1].setDirection(v2)

            mn2.points[i].setDirection(v1)
            mn2.points[i+1].setDirection(v2)

        mn1.processCurvature()
        mn2.processCurvature()

        return mn1, mn2, (0, len(mn1.points)-1, i, i+1)


    def fixHolesAndBumps(self, lim=0.3):
        """
        Simply ditches points with a curvature higher than a certain threshold.
        All curvatures must lie in the range M{[-lim, lim]}.

        @type  lim: float
        @param lim: The curvature tolerance. Curvatures lie in the range M{[-1.0, 1.0]}.

        @rtype: void
        """
        keepPoints = []
        for p in self.points:
            if p.getCurvature() < lim:
                continue
            keepPoints.append(p)
        self.points = keepPoints()


    def spreadSamplingLimit(self, tol=0.8, top=0, bottom=0):

        """
        Deletes points too close from one another. Makes an exception for points with extreme curvatures.

        @type  tol: float
        @param tol: Length tolerance as a percentage of theorical value. The theorical value,represented by 1.0, is the length of an edge if all edges had the same length for this polygon.
        @type  top: int
        @param top: If this number equals M{N}, the N points with the highest curvature will be conserved without condition.
        @type  bottom: int
        @param bottom: If this number equals M{N}, the N points with the lowest curvature will be conserved without condition.

        @rtype: void
        """

        # Working copy of ours points. The tuple means: (global index, ray object, do we keep it?)
        dupliPoints = [(i, p, False) for i, p in enumerate(self.points)]
        dupliPoints.sort(key=lambda tup: tup[1].getCurvature())

        # Keeping the points with the lowest curvatures.
        for i in range(bottom):
            dupliPoints[i] = (dupliPoints[i][0], dupliPoints[i][1], True)

        dupliPoints.reverse()

        # Keeping the points with the highest curvatures.
        for i in range(top):
            dupliPoints[i] = (dupliPoints[i][0], dupliPoints[i][1], True)

        dupliPoints.sort(key=lambda tup: tup[0]) # Sorting by index == order in the polygon.

        var   = self.getSegmentLengthVariations()
        nvPts = [dupliPoints[0]] # We necessarily keep the first point.
        dst   = 0.0 # Traveled distance since the last conserved point.
        avg   = self.getPerimeter() / len(self.points) # average length of a segment

        for i, p, s in dupliPoints:
            if s:
                nD = distance(nvPts[-1][1].getOrigin(), p.getOrigin()) / avg
                if (i == 0) or ((not nvPts[-1][2]) and (nD < tol)):
                    nvPts.pop()
                nvPts.append((i, p, s))
                dst = var[i]
                continue

            if dst >= tol:
                nvPts.append((i, p, s))
                dst = var[i]
            else:
                dst += var[i] # var[i] == distance between points i and i+1
            
        
        self.points = [p for i, p, s in nvPts]
        self.updateNormals()
        self.processCurvature()

    
    def isConvex(self):
        """
        B{NOT IMPLEMENTED}
        Should return a boolean representing the convexity of that polygon.

        @rtype: bool
        @return: C{True}
        """
        return True

    
    def subdivide(self, idx, nbPts):
        """
        Subdivides the edge between the points C{idx} and C{idx+1} by adding C{nbPts} equally spaced points in between.
        The direction vectors are equally interpolated.

        @type  idx: int
        @param idx: An index in the points array. The edge that it forms with the point C{idx+1} is the target.
        @type  nbPts: int
        @param nbPts: How many points should be inserted on the targeted edge.

        @rtype: void
        """
        ptLeft = self.points[idx].getOrigin()
        ptRight = self.points[nextRotate(idx, len(self.points))].getOrigin()

        nmlLeft = self.points[idx].getDirection()
        nmlRight = self.points[nextRotate(idx, len(self.points))].getDirection()

        incre = 1.0 / (nbPts + 1)
        subStart = incre

        src = self.points[idx].makeCopy()
        subdivs = []

        for i in range(nbPts):
            right = subStart + i * incre
            left = 1.0 - right

            p = (
                ptLeft[0] * left + ptRight[0] * right,
                ptLeft[1] * left + ptRight[1] * right
            )

            n = (
                nmlLeft[0] * left + nmlRight[0] * right,
                nmlLeft[1] * left + nmlRight[1] * right
            )

            nvPt = src.makeCopy()
            nvPt.reset()
            nvPt.setOrigin(p)
            nvPt.setDirection(n)
            subdivs.append(nvPt)

        self.points = self.points[:idx+1] + subdivs + self.points[idx+1:]
        self.processCurvature()


    def interpolatePoint(self, idx, nbPts):
        """
        Function inserting a certain number of points after a given point.
        The best interpolation is processed before inserting the points, to avoid creating a flat surface.
        The newly created points have an optimal curvature to match the continuity of the original neighbours.

        @type  idx: int
        @param idx: Index of the point after which new points must be inserted.
        @type  nbPts: int
        @param nbPts: Number of points to be inserted after C{points[idx]}.

        @rtype: list((float, float))
        @return: A list containing the new points to add after C{points[idx]}.
        """
        nvPts = []

        # = = = Building the list of coordinates on which we will work. = = =
        iStart = idx-1
        points = []

        for i in range(4):
            pt  = self.points[iStart].getOrigin()
            nml = self.points[iStart].getDirection()
            points.append({'point': pt, 'normal': nml})
            iStart = nextRotate(iStart, len(self.points))

        # = = = Building base points along the edge to interpolate. = = =
        subdiv = []
        incre = 1.0 / (nbPts + 1)
        subStart = incre

        for i in range(nbPts):
            right = subStart + i * incre
            left = 1.0 - right
            subdiv.append((
                points[1]['point'][0] * left + points[2]['point'][0] * right,
                points[1]['point'][1] * left + points[2]['point'][1] * right
            ))

        # = = = Building base points along the edge to interpolate. = = =
        midPoints = []
        medVec    = []

        for p1, p2 in zip(points, points[1:]):
            edge = (
                p2['point'][0] - p1['point'][0],
                p2['point'][1] - p1['point'][1]
            )
            midPoint = (
                (p1['point'][0] + p2['point'][0]) / 2,
                (p1['point'][1] + p2['point'][1]) / 2
            )
            nml = (edge[1], -edge[0])
            if dotProduct(nml, p1['normal']):
                nml = (-edge[1], edge[0])

            midPoints.append(midPoint)
            medVec.append(nml)

        circles = []
        for med1, med2, mid1, mid2 in zip(medVec, medVec[1:], midPoints, midPoints[1:]):
            alpha1 = med1[1]
            beta1  = -med1[0]
            gamma1 = -(alpha1 * mid1[0] + beta1 * mid1[1])

            alpha2 = med2[1]
            beta2  = -med2[0]
            gamma2 = -(alpha2 * mid2[0] + beta2 * mid2[1])

            circles.append((
                (beta1 * gamma2 - beta2 * gamma1) / (alpha1 * beta2 - alpha2 * beta1),
                (alpha2 * gamma1 - alpha1 * gamma2) / (alpha1 * beta2 - alpha2 * beta1)
            ))

        midPt = points[int(len(points)/2)]['point']
        dists = [(idx, distance(center, midPt)) for idx, center in enumerate(circles)]
        dists.sort(key=lambda tup: tup[1])

        r = dists[-1][1]
        c = circles[dists[-1][0]]

        for s in subdiv:
            vDir = normalize((
                s[0] - c[0],
                s[1] - c[1]
            ))

            nv = (
                c[0] + r * vDir[0],
                c[1] + r * vDir[1]
            )

            nvPts.append(nv)
        
        return nvPts

    
    def makeStats(self):
        """
        Function creating a collection of statistics about the current MovingNGon.

        @rtype: dict((str, float))
        @return: A dictionary containing C{'distance'}, C{'distances.derivative'}, C{'spacing'}, C{'curvatures'} and C{'curvatures.derivative'}.
        """
        distances = [distance(p.getOrigin(), self.origin) for p in self.points]
        distDer   = [b - a for a, b in zip(distances, distances[1:] + [distances[0]])]
        spacing   = [distance(p1.getOrigin(), p2.getOrigin()) for p1, p2 in zip(self.points, self.points[1:] + [self.points[0]])]
        curvats   = [p.getCurvature() for p in self.points]
        curvaDer  = [c2 - c1 for c1, c2 in zip(curvats, curvats[1:] + [curvats[0]])]

        return {
            'distances': distances,
            'distances.derivative': distDer,
            'spacing': spacing,
            'curvatures': curvats,
            'curvatures.derivative': curvaDer
        }

    
    def interpolateSamples(self, tol=1):
        """
        Function searching long edges in the whole polygon, and inserts points on these edges to make them a more normal size.
        New points are created with C{interpolatePoint} so new points are interpolated. No flat surface will be created.

        @type  tol: float
        @param tol: Length tolerance, in percent of "normal" length. Above this length, the edge will be subdivided.

        @rtype: void
        """
        avg   = self.getPerimeter() / len(self.points)
        var   = self.getSegmentLengthVariations()
        nvPts = []
        
        for idx in range(len(self.points)):
            nvPts.append(self.points[idx])

            if var[idx] >= tol:
                pts = self.interpolatePoint(idx, int(var[idx] / tol))
                for p in pts:
                    nP = self.points[idx].makeCopy()
                    nP.setOrigin(p)
                    nvPts.append(nP)

        self.points = nvPts
        self.updateNormals()
        self.processCurvature()

    
    def normalizedCurvatures(self):
        """
        Builds a list representing the normalized curvature of this polygon's points.
        Values are guaranteed to reach -1 or 1 (division by the maximal value of absolute curvatures).

        @rtype: list(float)
        """
        l = [abs(c.getCurvature()) for c in self.points]
        m = max(l)
        return [li.getCurvature() / m for li in self.points]


    def smoothProjection(self, strength=0.5, tol=1.0, absolute=False):
        """
        Smooth the points by averaging their current position with their projection on the vector formed by its neighbours.
        Let's say that we want to smooth Pb. Then, V1 = Pb - Pa and V2 = Pc - Pa. We project V1 on V2, which gives us a point.
        The new point is obtained with a weighted average of the actual point and the projected.

        @type  strength: float
        @param strength: In the range ]0.0, 1.0[. Importance of the actual point in the weighted average. At 0.5, this is a regular average.
        @type  tol: float
        @param tol: If the curvature of a point is greater than this value, this point is not smoothed.
        @type  absolute: bool
        @param absolute: If True, curvatures above C{tol} and below C{-tol} will be skipped.

        @rtype: void
        """

        normaCurvats = self.normalizedCurvatures()
        newOris = []

        for i in range(len(self.points)):
            if normaCurvats[i] > tol:
                newOris.append(self.points[i].getOrigin())
                continue

            if absolute and (normaCurvats[i] < -tol):
                newOris.append(self.points[i].getOrigin())
                continue

            p0 = self.points[i-1].getOrigin()
            p1 = self.points[i].getOrigin()
            p2 = self.points[nextRotate(i, len(self.points))].getOrigin()

            v1 = vecSub(p2, p0)
            v2 = vecSub(p1, p0)

            factor = dotProduct(v1, v2) / (distance((0, 0), v1) * distance((0, 0), v1))
            projVec = (
                factor * v1[0] + p0[0],
                factor * v1[1] + p0[1])

            newOris.append((
                (projVec[0] * strength + p1[0] * (1.0 - strength)),
                (projVec[1] * strength + p1[1] * (1.0 - strength))
            ))
        
        for p, o in zip(self.points, newOris):
            p.setOrigin(o)

        self.updateNormals()
        self.processCurvature()


    def smoothCurve(self, keepAngles=False, angleMax=math.pi/5):
        """
        Smoothes the polygon by making each point the average of its neighbours.
        """
        nouvPts = []
    
        for i in range(len(self.points)):
            a = self.points[i-1].getOrigin() # A
            b = self.points[i].getOrigin()   # B

            if i+1 >= len(self.points):
                c = self.points[0].getOrigin() # C
            else:
                c = self.points[i+1].getOrigin() # C

            # Vecteurs directeurs
            v1 = normalize((b[0]-a[0], b[1]-a[1])) # AB
            v2 = normalize((c[0]-b[0], c[1]-b[1])) # BC

            angle = math.acos(v1[0]*v2[0]+v1[1]*v2[1])

            # We want to keep sharp angles in place.
            if keepAngles and (angle > angleMax):
                nouvPts.append(self.points[i].getOrigin())
                continue
            
            pt = ((a[0] + c[0])/2, (a[1] + c[1])/2)
            nouvPts.append(pt)
        
        for n, p in zip(nouvPts, self.points):
            p.setOrigin(n)

    
    ## @brief Function used in the shrinking process to change the position of the centroid according to the detected contours.
    def updateCentroid(self):
        xs, ys = zip(*map(Ray.getOrigin, self.points))
        x = sum(xs) / len(xs)
        y = sum(ys) / len(ys)
        self.origin = (x, y)

    
    ## @brief Get the median distance traveled by rays for this iteration.
    def getMedianDistance(self):
        return sorted(map(Ray.getDistance, self.points))[int(len(self.points)/2)]

    
    def outputCoordinates(self, path):
        current = {
            'origin': self.origin,
            'stepSize': self.stepSize,
            'coordinates': []
        }

        for p in self.points:
            p_i = list(p.getOrigin()) + list(p.getDirection()) + [p.getCurvature(), p.distance]
            current['coordinates'].append(p_i)

        import json
        f = open(path, 'w')
        json.dump(current, f)
        f.close()

    
    def loadFromFile(self, path):
        import json
        f = open(path, 'r')
        raw = json.load(f)
        f.close()
        
        self.origin = raw['origin']

        sts = raw['stepSize']

        self.points = [Ray(l[0:2], l[2:4], sts) for l in raw['coordinates']]

        for p, l in zip(self.points, raw['coordinates']):
            p.curvature = l[4]
            p.distance  = l[5]

    
    def updateNormals(self):
        nouvDirs = []
        for i in range(len(self.points)):
            # = = = = 1. Acquiring three points around the current one. = = = = 
            a = self.points[i-1].getOrigin() # A
            b = self.points[i].getOrigin()   # B

            if i+1 >= len(self.points):
                c = self.points[0].getOrigin() # C
            else:
                c = self.points[i+1].getOrigin() # C

            # = = = = 2. Building a director vector for each edge. = = = = 
            v1 = vecSub(b, a) # (b[0]-a[0], b[1]-a[1]) # AB
            v2 = vecSub(c, b) # (c[0]-b[0], c[1]-b[1]) # BC

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
            cx = self.points[i].getDirection()[0]
            cy = self.points[i].getDirection()[1]

            if nx * cx + ny * cy > 0:
                n = (nx, ny)
            else:
                n = (-nx, -ny)
            
            # = = = = 7. Normalizing final normal vector and modifying list entry = = = = 
            n = normalize(n)
            nouvDirs.append((n[0], n[1]))
        
        for p, n in zip(self.points, nouvDirs):
            p.setDirection(n)

    
    def processCurvature(self):
    
        curvatures = []
        points = list(map(Ray.getOrigin, self.points))
        directions = list(map(Ray.getDirection, self.points))

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
            dot = round(v1[0] * v2[0] + v1[1] * v2[1], 5)
            ang = math.acos(dot)

            if ang == 0:
                curvatures.append(0.0)
                continue

            # Processing sign
            dotN = n1[0] * v2[0] + n1[1] * v2[1]
            dotN /= abs(dotN) # 1.0 or -1

            # Append
            curvatures.append(dotN * (math.sin(ang / 2))) # dotN to change the sign according to the direction of the angle.
        
        for p, c in zip(self.points, curvatures):
            p.curvature = c


    ## @brief Calls the move function of each ray until no one can move anymore
    ## @return A boolean telling if at least a ray can still move in this n-gon.
    def move(self):
        for p in self.points:
            p.move()


class ConditionalMovingNGon(MovingNGon):

    def __init__(self, center, s):
        super(ConditionalMovingNGon, self).__init__(center, s)
        self.moving = 1.0 # Proportions of rays able to move at last iteration.

    
    def makeCopy(self):
        n = ConditionalMovingNGon(self.origin, self.stepSize)
        n.points = [p.makeCopy() for p in self.points]
        n.moving = self.moving
        return n

    
    def makeRaysFromPoints(self, points, directions):
        self.points = [ConditionalRay(p, d, self.stepSize) for p, d in zip(points, directions)]

    
    ## @brief Resets the locking status of all rays
    def reset(self):
        for pt in self.points:
            pt.reset()
        self.moving = 1.0

    
    def move(self):
        status = [p.move() for p in self.points]
        moved = any(status)
        stillMoving = status.count(True)
        self.moving = float(stillMoving) / float(len(self.points))
        return moved
    

    def setTestFunction(self, fx):
        for r in self.points:
            r.setTestFunction(fx)

    
    def shrink(self):
        # !!! Add something to prevent infinite loops.
        while self.move():
            pass
