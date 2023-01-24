import math
from rays import Ray, ConditionalRay, merge
from basicOps import vecSub, normalize, distance, nextRotate, dotProduct

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   MOVING N-GON BASE CLASS                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## @brief Class representing an n-gon that can (shrink around / expand to) a structure.
class MovingNGon(object):

    def __init__(self, center, s):
        self.points   = []
        self.origin   = center
        self.stepSize = s

    def makeCopy(self):
        n = MovingNGon(self.origin, self.stepSize)
        n.points = [p.makeCopy() for p in self.points]
        return n

    ## @brief Returns the point that is considered the center for this polygon.
    def getOrigin(self):
        return self.origin

    def getNPoints(self):
        return len(self.points)

    ## @brief Returns the step size for the contained rays.
    def getStepSize(self):
        return self.stepSize
    
    ## @brief Forces a step for each contained.
    def forceStep(self):
        for p in self.points:
            p.forceStep()
    
    ## @brief Modifies the step size for every ray of this polygon.
    def setStepSize(self, s):
        if s > 0:
            self.stepSize = s
            for p in self.points:
                p.setStepSize(s)

    ## @brief Takes a list of coordinates and a list of direction vectors, and builds a list of rays from that.
    def makeRaysFromPoints(self, points, directions):
        self.points = [Ray(p, d, self.stepSize) for p, d in zip(points, directions)]


    ## @brief Recalculates the normals to point towards this polygon's center rather than towards their automatic direction.
    def makeNormalsFromCentroid(self, mode):
        if (mode != 'SHRINK') and (mode != 'EXPAND'):
            return
        
        for p in self.points:
            vDir = normalize(vecSub(p.getOrigin(), self.origin))
            if mode == 'SHRINK':
                vDir = (-1*vDir[0], -1*vDir[1])
            p.setDirection(vDir)


    ## @brief Returns a list containing the length of every segment composing the polygon.
    def getSegmentsSize(self):
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
        xs, ys = zip(*[t.getOrigin() for t in self.points])
        self.origin = (sum(xs)/len(self.points), sum(ys)/len(self.points))


    ## @brief Process a scalar for each segment representing the factor between the theorical size of a segment, and it actual size.
    #         The theorical size is the size of a segment if all segments had the same length for this given polygon.
    #         A factor of 1 means that it is exactly the theorical size, a factor of 2 means that it is twice longer than "it should be".
    def getSegmentLengthVariations(self):
        distances = self.getSegmentsSize()
        total = sum(distances)
        theory = total / len(self.points)
        return list(map(lambda e : e / theory, distances))


    ## @brief Process the perimeter length of the polygon.
    def getPerimeter(self):
        distances = self.getSegmentsSize()
        return sum(distances)

    
    def split(self, i, j, sharpCut=False):
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

        return mn1, mn2


    def fixHolesAndBumps(self, lim=-0.3):
        keepPoints = []
        for p in self.points:
            if p.getCurvature() < lim:
                continue
            keepPoints.append(p)
        self.points = keepPoints()


    def spreadSamplingLimit(self, tol=0.8, top=0, bottom=0):
        dupliPoints = [(i, p, False) for i, p in enumerate(self.points)]
        dupliPoints.sort(key=lambda tup: tup[1].getCurvature())

        for i in range(bottom):
            dupliPoints[i] = (dupliPoints[i][0], dupliPoints[i][1], True)

        dupliPoints.reverse()

        for i in range(top):
            dupliPoints[i] = (dupliPoints[i][0], dupliPoints[i][1], True)

        dupliPoints.sort(key=lambda tup: tup[0])

        var   = self.getSegmentLengthVariations()
        nvPts = [dupliPoints[0]]
        dst   = 0.0
        avg   = self.getPerimeter() / len(self.points) # average length of a segment

        for i, p, s in dupliPoints:
            if s:
                nD = distance(nvPts[-1][1].getOrigin(), p.getOrigin()) / avg
                if (i == 0) or ((not nvPts[-1][2]) and (nD < tol)):
                    nvPts.pop()
                nvPts.append((i, p, s))
                dst = 0.0
                continue

            if dst >= tol:
                nvPts.append((i, p, s))
                dst = 0.0
            else:
                dst += var[i] # var[i] == distance between points i and i+1
            
        
        self.points = [p for i, p, s in nvPts]
        self.updateNormals()
        self.processCurvature()


    def spreadSampling(self, tol=0.8, ang=0.2):
        avg   = self.getPerimeter() / len(self.points) # average length of a segment
        var   = self.getSegmentLengthVariations()
        nvPts = [self.points[0]]
        dst   = 0.0

        for idx, p in enumerate(self.points):
            if p.getCurvature() >= ang:
                nD = distance(nvPts[-1].getOrigin(), p.getOrigin()) / avg
                if (idx == 0) or (nD < tol):
                    nvPts.pop()
                nvPts.append(p)
                dst = 0.0
                continue

            if dst >= tol:
                nvPts.append(p)
                dst = 0.0
            else:
                dst += var[idx] # var[i] == distance between points i and i+1
            
        
        self.points = nvPts
        self.updateNormals()
        self.processCurvature()

    
    def isConvex(self):
        return True


    def interpolatePoint(self, idx, nbPts):
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
        avg   = self.getPerimeter() / len(self.points)
        var   = self.getSegmentLengthVariations()
        nvPts = []
        
        for idx in range(len(self.points)):
            nvPts.append(self.points[idx])

            if var[idx] > tol:
                pts = self.interpolatePoint(idx, int(var[idx] / tol))
                for p in pts:
                    nP = self.points[idx].makeCopy()
                    nP.setOrigin(p)
                    nvPts.append(nP)

        self.points = nvPts
        self.updateNormals()
        self.processCurvature()

    def smoothProjection(self, strength=0.5):
        newOris = []
        for i in range(len(self.points)):
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


    ## @brief Spreads the points more evenly on the detected contour.
    def smoothCurve(self, keepAngles=False, angleMax=math.pi/5):
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
        f = open(path, 'w')
        for p in self.points:
            pts = list(p.getOrigin())
            pts += list(p.getDirection())
            pts.append(p.getCurvature())
            f.write(";".join([str(s) for s in pts]) + "\n")
        f.close()

    
    def loadFromFile(self, path):
        f = open(path, 'r')
        raw = f.read()
        f.close()
        lines = raw.split('\n')

        for line in lines:
            if len(line) <= 1:
                continue
            nbs = line.split(';')
            x, y, dx, dy, c = [float(n) for n in nbs]
            r = Ray((x, y), (dx, dy), self.stepSize)
            r.curvature = c
            self.points.append(r)
        

    
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
        self.moving = stillMoving / len(self.points)
        return moved
    

    def setTestFunction(self, fx):
        for r in self.points:
            r.setTestFunction(fx)

    
    def shrink(self):
        # !!! Add something to prevent infinite loops.
        while self.move():
            pass
