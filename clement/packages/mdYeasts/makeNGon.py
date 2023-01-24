from movingNgon.rays import Ray, ConditionalRay
from movingNgon.movingNgon import MovingNGon, ConditionalMovingNGon
from mdYeasts.userIO import readSettings
from movingNgon.basicContours import buildShrinkingBox, buildShrinkingEllipsis
from movingNgon.basicOps import dotProduct

from ij import IJ, ImagePlus
from ij.gui  import Roi, PolygonRoi
from ij.process import FloatPolygon
from ij.measure import ResultsTable
import time
import math


def drawYeast(yeast, canvas, color, roi):
    roiYeast = yeast.asROI()
    roiYeast.setLocation(roi[0] + roiYeast.getXBase(), roi[1] + roiYeast.getYBase())
    proc = canvas.getProcessor()
    proc.setColor(color)
    proc.fill(roiYeast)


def buildStatistics(histoBefore, histoAfter):

    for i in range(len(histoBefore)):
        sous = histoBefore[i] - histoAfter[i]
        histoBefore[i] = max(0, sous)
    
    stats = {}

    # ---> Mean and standard deviation
    total = sum(histoBefore) # Number of pixels in the ring

    stats['area'] = total

    accumulator = sum([its1 * occurences for its1, occurences in enumerate(histoBefore)])
    mean = accumulator / total
    stats['mean'] = mean

    # ---> Min, max, median, quartiles and standard deviation
    linearized = [[its2 for i in range(occurences)] for its2, occurences in enumerate(histoBefore)]
    linearized = [item for sublist in linearized for item in sublist]
    linearized.sort()
    

    stats['min'] = 0
    stats['max'] = 0

    for i in range(len(histoBefore)):
        if histoBefore[i] > 0:
            stats['min'] = i
            break

    for i in range(len(histoBefore)-1, -1, -1):
        if histoBefore[i] > 0:
            stats['max'] = i
            break

    for q in range(1, 4):
        accu = 0
        for i in range(len(histoBefore)):
            accu += histoBefore[i]
            if accu >= q * (total / 4):
                stats['Q'+str(q)] = i
                break


    stats['med'] = stats['Q2']
    del stats['Q2']

    return stats


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   IMAGEJ TOLERANCE RAY                                                                              #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


def checkIntensityGap(obj):
    x = obj.origin[0] + obj.stepSize * obj.direction[0]
    y = obj.origin[1] + obj.stepSize * obj.direction[1]

    proc = obj.image.getProcessor()
    before = proc.get(int(obj.origin[0]), int(obj.origin[1]))
    after = proc.get(int(x), int(y))

    return abs(before - after) < obj.tolerance


def checkInsideHalo(obj):
    x = obj.origin[0] + obj.stepSize * obj.direction[0]
    y = obj.origin[1] + obj.stepSize * obj.direction[1]

    proc = obj.image.getProcessor()
    before = proc.get(int(obj.origin[0]), int(obj.origin[1]))
    obj.enteredWhite = (before == 255) or obj.enteredWhite
    after = proc.get(int(x), int(y))

    return not (obj.enteredWhite and (before == 0))


def checkDistanceFunction(obj):
    return obj.distance < obj.thickness


class LevelGapRay(ConditionalRay):

    def __init__(self, img, tol, o, d, s):
        super(LevelGapRay, self).__init__(o, d, s)
        self.image = img
        self.tolerance = tol
        self.fx = checkIntensityGap
        self.enteredWhite = False
        self.thickness = 0.0
    

    def makeCopy(self):
        r = LevelGapRay(self.image, self.tolerance, self.origin, self.direction, self.stepSize)
        r.distance = self.distance
        r.count = self.count
        r.curvature = self.curvature
        r.go = self.go
        r.distances = [d for d in self.distances]
        r.fx = self.fx
        r.thickness = self.thickness
        return r

    
    def rollingSum(self, data, scalar=2):
        # Declaring used variables.
        length   = int(scalar * self.thickness)
        membrane = int(self.thickness)
        step     = 1
        values   = [0 for i in range(membrane)]
        proc     = data.getProcessor()

        # If the membrane is thicker than the explored length, this function is useless.
        if membrane > length:
            return

        current = self.origin

        # Filling the values with what's currently considered as the membrane.
        for i in range(membrane):
            values[i] = proc.get(int(current[0]), int(current[1]))
            current = (
                self.origin[0] + i * step * self.direction[0],
                self.origin[1] + i * step * self.direction[1]
            )

        valMax = sum(values)
        posMax = self.origin

        # Searching farther if the membrane can be reached.
        for i in range(0, length-membrane):
            if len(values) >= membrane:
                del values[0]
            
            values.append(proc.get(int(current[0]), int(current[1])))
            acc = sum(values)

            if acc > valMax:
                valMax = acc
                posMax = (
                    self.origin[0] + i * step * self.direction[0],
                    self.origin[1] + i * step * self.direction[1]
                )

            current = (
                current[0] + i * step * self.direction[0],
                current[1] + i * step * self.direction[1]
            )
        # print(self.origin, current)
        self.origin = posMax


class IJMovingNGon(ConditionalMovingNGon):

    def __init__(self, center, s, img, tol):
        super(IJMovingNGon, self).__init__(center, s)
        self.image     = img
        self.tolerance = tol
        self.thickness = 0.0

    # 'val' is in um
    def setMembraneThickness(self, val):
        self.thickness = math.ceil(self.image.getCalibration().getRawY(val))
        for p in self.points:
            p.thickness = self.thickness
    

    def makeCopy(self):
        n = IJMovingNGon(self.origin, self.stepSize, self.image, self.tolerance)
        n.points = [p.makeCopy() for p in self.points]
        n.moving = self.moving
        n.thickness = self.thickness
        return n

    
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

        return self.split(scdMax, maxIndex, True)


    def makeRaysFromPoints(self, points, directions):
        self.points = [LevelGapRay(self.image, self.tolerance, p, d, self.stepSize) for p, d in zip(points, directions)]


    ## @brief Displays this N-Gon as an ROI in Fiji
    def displayPoints(self):
        IJ.run(self.image, "Select None", "")

        self.image.setRoi(PolygonRoi(
            FloatPolygon(*map(list, zip(*map(Ray.getOrigin, self.points)))), # Unpacking x and y coordinates of rays in two lists
            Roi.NORMAL
        ))

    # Places the centroid according to the centroid of white pixels on a mask
    def centroidFromMask(self):
        pc = self.image.getProcessor()
        xs = []
        ys = []

        for c in range(self.image.getWidth()):
            for l in range(self.image.getHeight()):
                if pc.get(c, l) == 255:
                    xs.append(c)
                    ys.append(l)

        self.origin = (
            sum(xs) / len(xs),
            sum(ys) / len(ys)
        )
    
    # Move along the normals until a certain percentage of points have stopped.
    def skipHalo(self, percentage):
        self.reset()
        self.setTestFunction(checkInsideHalo)

        while (1.0 - self.moving) < percentage:
            self.move()
    

    def asROI(self):
        return PolygonRoi(
            FloatPolygon(*map(list, zip(*map(Ray.getOrigin, self.points)))), # Unpacking x and y coordinates of rays in two lists
            Roi.NORMAL
        )

    
    def goThroughMembrane(self):
        self.reset()
        self.setTestFunction(checkDistanceFunction)
        
        while self.move():
            pass

    
    def recordMembrane(self, data, control, marker, base):
        data.setRoi(self.asROI())
        statsBefore = data.getProcessor().getHistogram()
        perOut = self.getPerimeter()

        drawYeast(self, control, marker, base)

        self.goThroughMembrane()

        drawYeast(self, control, 0, base)

        data.setRoi(self.asROI())
        statsAfter = data.getProcessor().getHistogram()
        perIn = self.getPerimeter()

        stats = buildStatistics(statsBefore, statsAfter)

        stats['perimeter_in'] = self.image.getCalibration().getX(perIn)
        stats['perimeter_out'] = self.image.getCalibration().getX(perOut)

        return stats

    
    def rollingSum(self, data, scalar=2):
        for r in self.points:
            r.rollingSum(data, scalar)


def mvngFromUser(img):

    settings, verbose = readSettings()

    if settings is None:
        return (None, "Failed to read settings: {0}".format(verbose))

    nPoints = settings['nPoints']

    mvng = IJMovingNGon((img.getWidth()/2, img.getHeight()/2), settings['stepSize'], img, settings['tolerance'])
    
    if settings['shape'] == "Box":
        pts, dirs = buildShrinkingBox(nPoints, img.getHeight(), img.getWidth())

    if settings['shape'] == "Ellipsis":
        pts, dirs = buildShrinkingEllipsis(nPoints, img.getHeight(), img.getWidth())
    
    mvng.makeRaysFromPoints(pts, dirs)
    
    if settings['ctr_from_mask'] == 'MASK':
        mvng.centroidFromMask()

    if settings['ctr_from_mask'] == 'POINTS':
        mvng.setOriginFromPoints()

    mvng.setMembraneThickness(settings['maxThickness'])

    return (mvng, "DONE.")



def motherDaughterSegmentation(img, data, control, base):
    
    # 1. Acquiring polygon object from user's input
    mvng, verbose = mvngFromUser(img)

    if mvng is None:
        return (None, None, None, "Failed to create polygon from settings: {0}".format(verbose))

    # 2. Shrinking polygon to the light halo around the yeasts
    mvng.shrink()
    mvng.updateNormals()
    mvng.processCurvature()

    # 3. Adjusting the new polygon, and splitting it to separate yeasts.
    mvng.smoothProjection()
    mvng.spreadSamplingLimit(1, 2, 0)
    mvng.interpolateSamples(1)
    yeastD, yeastM = mvng.splitCells()

    if yeastD.getPerimeter() > yeastM.getPerimeter():
        yeastD, yeastM = yeastM, yeastD

    # 4. Checking that the segmentation in valid.
    if not (yeastD.isConvex() and yeastM.isConvex()):
        return (None, None, None, "Yeasts are supposed to be star-convex shapes.")

    # 5. Going to the cells.
    percTolHalo = 0.8
    yeastD.skipHalo(percTolHalo)
    yeastM.skipHalo(percTolHalo)

    yeastD.rollingSum(data)
    yeastM.rollingSum(data)

    yeastD.updateNormals()
    yeastM.updateNormals()

    yeastD.processCurvature()
    yeastM.processCurvature()

    # 6. Starting recording points and going through the membrane
    statsM = yeastM.recordMembrane(data, control, 255, base)
    statsD = yeastD.recordMembrane(data, control, 127, base)

    stats = {}

    for key, item in statsM.items():
        stats["M_{0}".format(key)] = item

    for key, item in statsD.items():
        stats["D_{0}".format(key)] = item

    return (yeastD, yeastM, stats, "DONE.")

