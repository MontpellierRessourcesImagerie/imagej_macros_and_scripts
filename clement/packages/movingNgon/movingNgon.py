import math
from rays import Ray, ConditionalRay, merge
from basicOps import vecSub, normalize, distance, nextRotate, dotProduct
import copy

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   MOVING N-GON BASE CLASS                                                                           #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

## @brief Class representing an n-gon that can (shrink around / expand to) a structure.
class MovingNGon(object):

    def __init__(self, center, s):
        self.points   = []
        self.origin   = center
        self.stepSize = s

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

    
    def split(self, i, j):
        if i >= j:
            return None, None
        
        mn1 = MovingNGon((0.0, 0.0), self.stepSize)
        mn2 = MovingNGon((0.0, 0.0), self.stepSize)

        mn1.points = [copy.deepcopy(p) for p in self.points[i:j+1]]
        mn2.points = [copy.deepcopy(p) for p in self.points[0:i+1] + self.points[j:]]

        mn1.updateCentroid()
        mn2.updateCentroid()

        return mn1, mn2


    # = = = A BOUGER DANS LA CLASSE QUI DEPEND DE IMAGEJ = = =
    def splitCells(self):
        curvatures = sorted(
            [(p.getCurvature(), idx) for idx, p in enumerate(self.points)], 
            key=lambda x: x[0]
        )

        curvatures.reverse()
        maxIndex = curvatures[0][1]
        scdMax = curvatures[1][1]
        
        for i in range(1, len(curvatures)):
            if dotProduct(self.points[maxIndex].getDirection(), self.points[curvatures[i][1]].getDirection()) <= 0:
                scdMax = curvatures[i][1]
                break

        if maxIndex < scdMax:
            maxIndex, scdMax = scdMax, maxIndex

        return self.split(scdMax, maxIndex)


    def fixHolesAndBumps(self, lim=-0.3):
        keepPoints = []
        for p in self.points:
            if p.getCurvature() < lim:
                continue
            keepPoints.append(p)
        self.points = keepPoints()


    def spreadSampling(self, tol=1, ang=0.4):
        avg   = self.getPerimeter() / len(self.points) # average length of a segment
        lower = tol
        var   = self.getSegmentLengthVariations()
        nvPts = [self.points[0]]
        dst   = 0

        for idx, p in enumerate(self.points):
            if p.getCurvature() >= ang:
                nD = distance(nvPts[-1].getOrigin(), p.getOrigin()) / avg
                if (idx == 0) or (nD < 0.6):
                    nvPts.pop()
                nvPts.append(p)
                dst = 0.0
                continue

            if dst >= lower:
                nvPts.append(p)
                dst = 0.0
            else:
                dst += var[idx] # var[i] == distance between points i and i+1
            
        
        self.points = nvPts
        self.updateNormals()
        self.processCurvature()

    
    def interpolateSamples(self, tol=1.1):
        avg   = self.getPerimeter() / len(self.points)
        var   = self.getSegmentLengthVariations()
        nvPts = []
        
        for idx in range(len(self.points)):
            nvPts.append(self.points[idx])

            if var[idx] >= tol:
                
                # Getting working indices
                bfr = idx - 1
                nxt1 = nextRotate(idx, len(self.points))
                nxt2 = nextRotate(nxt1, len(self.points))
                pMid = merge(self.points[idx], self.points[nxt1])

                # Direction vectors of the three segments
                b1ix = normalize((
                    self.points[idx].getOrigin()[0] - self.points[bfr].getOrigin()[0],
                    self.points[idx].getOrigin()[1] - self.points[bfr].getOrigin()[1]
                ))
                ixn1 = normalize((
                    self.points[nxt1].getOrigin()[0] - self.points[idx].getOrigin()[0],
                    self.points[nxt1].getOrigin()[1] - self.points[idx].getOrigin()[1]
                ))
                n1n2 = normalize((
                    self.points[nxt2].getOrigin()[0] - self.points[nxt1].getOrigin()[0],
                    self.points[nxt2].getOrigin()[1] - self.points[nxt1].getOrigin()[1]
                ))

                # Middle point of each segment
                mid1 = (
                    (self.points[idx].getOrigin()[0] + self.points[bfr].getOrigin()[0])/2.0,
                    (self.points[idx].getOrigin()[1] + self.points[bfr].getOrigin()[1])/2.0
                )
                mid2 = (
                    (self.points[nxt1].getOrigin()[0] + self.points[idx].getOrigin()[0])/2.0,
                    (self.points[nxt1].getOrigin()[1] + self.points[idx].getOrigin()[1])/2.0
                )
                mid3 = (
                    (self.points[nxt2].getOrigin()[0] + self.points[nxt1].getOrigin()[0])/2.0,
                    (self.points[nxt2].getOrigin()[1] + self.points[nxt1].getOrigin()[1])/2.0
                )

                # Normal of each segment
                med1 = (b1ix[1], -b1ix[0])
                med2 = (ixn1[1], -ixn1[0])
                med3 = (n1n2[1], -n1n2[0])

                # Intersections of medians
                u1 = (mid1[1]*med2[0] + med2[1]*mid2[0] - mid2[1]*med2[0] - med2[1]*mid1[0] ) / (med1[0]*med2[1] - med1[1]*med2[0])
                u2 = (mid2[1]*med3[0] + med3[1]*mid3[0] - mid3[1]*med3[0] - med3[1]*mid2[0] ) / (med2[0]*med3[1] - med2[1]*med3[0])

                v1 = (mid1[0] + med1[0] * u1 - mid2[0]) / med2[0]
                v2 = (mid2[0] + med2[0] * u2 - mid3[0]) / med3[0]

                if (u1 >= 0) and (v1 >= 0):
                    c1 = (
                        mid1[0] + med1[0] * u1,
                        mid1[1] + med1[1] * u1
                    )
                else:
                    c1 = None

                if (u2 >= 0) and (v2 >= 0):
                    c2 = (
                        mid2[0] + med2[0] * t2,
                        mid2[1] + med2[1] * t2
                    )
                else:
                    c2 = None

                if (c1 is None) or (c2 is None):
                    continue

                d1 = distance(c1, self.points[idx].getOrigin())
                d2 = distance(c2, self.points[idx].getOrigin())
                
                r = d1 if d1 > d2 else d2
                c = c1 if d1 > d2 else c2

                vDir = normalize((
                    pMid[0] - c[0],
                    pMid[1] - c[1]
                ))

                nP = copy.deepcopy(self.points[idx])
                nP.setOrigin(
                    (
                        c[0] + r * vDir[0],
                        c[1] + r * vDir[1]
                    )
                )
                nvPts.append(nP)

        self.points = nvPts
        self.updateNormals()
        self.processCurvature()

    
    def _interpolateSamples(self, tol=1.1):
        avg   = self.getPerimeter() / len(self.points)
        var   = self.getSegmentLengthVariations()
        nvPts = []
        
        for idx in range(len(self.points)):
            nvPts.append(self.points[idx])

            if var[idx] >= tol:
                bfr = idx - 1
                nxt1 = nextRotate(idx, len(self.points))
                nxt2 = nextRotate(nxt1, len(self.points))

                v1 = normalize((
                    self.points[idx].getOrigin()[0] - self.points[bfr].getOrigin()[0],
                    self.points[idx].getOrigin()[1] - self.points[bfr].getOrigin()[1]
                ))
                v2 = normalize((
                    self.points[nxt2].getOrigin()[0] - self.points[nxt1].getOrigin()[0],
                    self.points[nxt2].getOrigin()[1] - self.points[nxt1].getOrigin()[1]
                ))
                ang = (2 * math.pi - math.acos(dotProduct(v1, v2))) / 1.95
                d = 0.5 * distance(self.points[idx].getOrigin(), self.points[nxt1].getOrigin()) / math.tan(ang / 2)
                nPtemp  = merge(self.points[idx], self.points[nxt1])
                px, py = nPtemp.getOrigin()
                dx, dy = nPtemp.getDirection()
                x = px - d * dx
                y = py - d * dy
                nP = copy.deepcopy(self.points[idx])
                nP.setOrigin((x, y))
                #nP.setOrigin(nPtemp.getOrigin())
                nvPts.append(nP)

        self.points = nvPts
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
