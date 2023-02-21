from movingNgon.rays import Ray, ConditionalRay
from movingNgon.movingNgon import MovingNGon, ConditionalMovingNGon
from mdYeasts.userIO import readSettings
from movingNgon.basicContours import buildShrinkingBox, buildShrinkingEllipsis
from movingNgon.basicOps import dotProduct

from ij import IJ, ImagePlus
from ij.gui  import Roi, PolygonRoi
from ij.process import FloatPolygon
import math


def drawYeast(yeast, canvas, color, roiCoords):

    """
    Function drawing a yeast object (its underlying ROI) on the 8-bit canvas
    The yeast is supposed to be extracted from a wider image, so the coordinates on the original image are required.

    @type  yeast: MovingNGon
    @param yeast: This object will be turned into an ROI to be drawn on the canvas.
    @type  canvas: ImagePlus
    @param canvas: An 8-bit single-channeled image, as big as the original image, on which the yeast will be drawn.
    @type  color: int
    @param color: Color used to draw that yeast. Must be in [0, 255].
    @type  roiCoords: (float, float)
    @param roiCoords: A tuple representing the shift to apply to the coordinates of C{yeast} to draw its points on the canvas.

    @rtype: void
    """

    roiYeast = yeast.asROI()
    coordsDraw = (roiCoords[0] + roiYeast.getXBase(), roiCoords[1] + roiYeast.getYBase())
    roiYeast.setLocation(coordsDraw[0], coordsDraw[1])
    proc = canvas.getProcessor()
    proc.setColor(color)
    proc.fill(roiYeast)


def buildStatistics(histoBefore, histoAfter):

    """
    Takes the histogram of the full cell, and the one of the cytoplasm.
    The subtraction of these two entities produces the histogram of the membrane.
    Processes: Q1, median, Q3, minimum, maximum, mean, standard deviation, perimeter & area.

    @type  histoBefore: int[]
    @param histoBefore: Histogram of the entire cell.
    @type  histoAfter: int[]
    @param histoAfter: Histogram of the cytoplasm.

    @rtype: dict((str, float))
    @return: A dictionary representing statistics in the membrane of the cell.
    """

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

    stats['std_dev'] = math.sqrt(sum([histoBefore[i] * pow(i - mean, 2) for i in range(len(histoBefore))]) / total)

    return stats


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   IMAGEJ TOLERANCE RAY                                                                              #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


def checkIntensityGap(obj):

    """
    Function determining if the intensity difference between two steps of a ray is too big.
    Function exclusively used by LevelGapRay::checkCondition.

    @type  obj: LevelGapRay
    @param obj: A C{LevelGapRay} instance.

    @rtype: bool
    @return: True if the difference of intensity found is neglectable. False otherwise.
    """

    x = obj.origin[0] + obj.stepSize * obj.direction[0]
    y = obj.origin[1] + obj.stepSize * obj.direction[1]

    proc = obj.image.getProcessor()
    before = proc.get(int(obj.origin[0]), int(obj.origin[1]))
    after = proc.get(int(x), int(y))

    return abs(before - after) < obj.tolerance


def checkInsideHalo(obj):

    """
    Verifies if the instance to which it is attached is before, inside, or after the light halo surrounding these yeasts.
    Function exclusively used by LevelGapRay::checkCondition.

    @type  obj: LevelGapRay
    @param obj: A C{LevelGapRay} instance.

    @rtype: bool
    @return: True if we are before or inside the light halo. False if we are on the rim or if we went through.
    """

    x = obj.origin[0]
    y = obj.origin[1]

    if (obj.origin[0] < 0) or (obj.origin[0] >= obj.image.getWidth()):
        return False

    if (x < 0) or (x >= obj.image.getWidth()):
        return False

    if (obj.origin[1] < 0) or (obj.origin[1] >= obj.image.getHeight()):
        return False

    if (y < 0) or (y >= obj.image.getHeight()):
        return False

    proc = obj.image.getProcessor()
    val = proc.get(int(x), int(y))

    if val == 0:
        return not obj.enteredWhite
    else:
        obj.enteredWhite = (val == 255) or obj.enteredWhite

    return True


def checkDistanceFunction(obj):

    """
    Verifies that the distance traveled by an instance of ray doesn't exceed a certain cap.
    The cap is meant to be the thickness of the membrane (in pixels) in that case.
    Function exclusively used by LevelGapRay::checkCondition.

    @type  obj: LevelGapRay
    @param obj: A C{LevelGapRay} instance.

    @rtype: bool
    @return: True if we can still travel. False otherwise.
    """

    return obj.distance < obj.thickness


class LevelGapRay(ConditionalRay):

    def __init__(self, img, tol, o, d, s):
        """
        Constructor

        @type  img: ImagePlus
        @param img: A single-channeled image on which rays will move.
        @type  o: (float, float)
        @param o: The origin point of this ray, where it will start its travel.
        @type  d: (float, float)
        @param d: Director vector of this ray. It is recommended to provided something normalized.
        @type  s: float
        @param s: The distance traveled by this ray at each iteration.

        @rtype: LevelGapRay
        """
        super(LevelGapRay, self).__init__(o, d, s)
        self.image = img
        self.tolerance = tol
        self.fx = checkIntensityGap
        self.enteredWhite = False
        self.thickness = 0.0
    

    def makeCopy(self):
        """
        Makes a deep copy of this object.
        You can use the function C{deepcopy()} from the C{copy} module if it exists in your version of Python instead of this function.

        @rtype: ConditionalRay
        @return: An independant copy of the summoner.
        """
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
        """
        Uses a rolling sum on a short distance to find the maximal intensity without being bothered by the noise.
        The given point corresponds to the start of the membrane as it is on the fluo channel. (since it is shifted from the transmission one).
        Sets the C{origin} position automatically by the end.
        Some holes can appear were the protein is less present.

        @type  data: ImagePlus
        @param data: The image on which values will be taken to adjust the contour's position.
        @type  scalar: float
        @param scalar: The distance C{membraneThickness * scalar} will be explored by the rolling sum.

        @rtype: void
        """
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

            if current[0] < 0 or current[0] >= data.getWidth():
                return
            
            if current[1] < 0 or current[1] >= data.getHeight():
                return

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
            
            if current[0] < 0 or current[0] >= data.getWidth():
                break
            
            if current[1] < 0 or current[1] >= data.getHeight():
                break
            
            values.append(proc.get(int(current[0]), int(current[1])))
            acc = sum(values)

            if acc > valMax:
                valMax = acc
                posMax = (
                    self.origin[0] + (i - 0.5) * step * self.direction[0],
                    self.origin[1] + (i - 0.5) * step * self.direction[1]
                )

            current = (
                current[0] + i * step * self.direction[0],
                current[1] + i * step * self.direction[1]
            )
        
        self.origin = posMax


class IJMovingNGon(ConditionalMovingNGon):

    """
    This structure is made to represent a polygon able to move over an ImagePlus object.
    Many methods are specific to the MD Yeasts project, rather than the MovingNGon package.
    """

    def __init__(self, center, s, img, tol):
        """
        Constructor

        @type  center: (float, float)
        @param center: Theorical center of this object. I{(deprecated)}
        @type  s: float
        @param s: The distance traveled by the rays composing this polygon at each iteration.
        @type  img: ImagePlus
        @param img: A single-channeled image on which rays will move.
        @type  tol: int
        @param tol: Difference tolerated from one step to another to keep the rays moving.

        @rtype: IJMovingNGon
        """
        super(IJMovingNGon, self).__init__(center, s)
        self.image     = img
        self.tolerance = tol
        self.thickness = 0.0

    # 'val' is in um
    def setMembraneThickness(self, val):
        """
        Modifies the C{thickness} attribute that represents the thickness of a yeast's membrane in pixels.
        This function casts a value in um to a value in pixels.

        @type  val: float
        @param val: Thickness of a membrane in um (according to the current image's calibration).

        @rtype: void
        """
        self.thickness = math.ceil(self.image.getCalibration().getRawY(val))
        for p in self.points:
            p.thickness = self.thickness
    

    def makeCopy(self):
        """
        Makes a deep copy of this object.
        You can use the function C{deepcopy()} from the C{copy} module if it exists in your version of Python instead of this function.

        @rtype: IJMovingNGon
        @return: An independant copy of the summoner.
        """
        n = IJMovingNGon(self.origin, self.stepSize, self.image, self.tolerance)
        n.points = [p.makeCopy() for p in self.points]
        n.moving = self.moving
        n.thickness = self.thickness
        return n

    
    def splitCells(self):
        """
        It was determined that the limit between the two cells is a straight line between the two points of the polygon having the highest positive curvature.
        This function finds these two points, and generates two new polygons from the summoner.
        Each of these polygon is a different cell.

        @rtype: (IJMovingNGon, IJMovingNGon, (int, int, int, int))
        @return: The two new polygons are returned as well as a tuple containing the indices of the cuts in the new polygons' referential.
        """
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

        c1, c2, cuts = self.split(scdMax, maxIndex, True)

        return c1, c2, cuts


    def makeRaysFromPoints(self, points, directions):
        """
        Transforms a collection of coordinates and vectors in LevelGapRay objects.

        @type  points: list((float, float))
        @param points: A list of 2D coordinates.
        @type  directions: list((float, float))
        @param directions: A list of 2D vectors.

        @rtype: void
        """
        self.points = [LevelGapRay(self.image, self.tolerance, p, d, self.stepSize) for p, d in zip(points, directions)]


    def displayPoints(self):
        """
        Generates an ROI and places it on the current image where the polygon is.

        @rtype: void
        """
        IJ.run(self.image, "Select None", "")

        self.image.setRoi(PolygonRoi(
            FloatPolygon(*map(list, zip(*map(Ray.getOrigin, self.points)))), # Unpacking x and y coordinates of rays in two lists
            Roi.NORMAL
        ))

    
    def centroidFromMask(self):
        """
        Places the centroid according to the centroid of white pixels on a mask

        @rtype: void
        """
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
    
    
    def skipHalo(self, percentage):
        """
        Function moving along the direction vectors until a certain percentage of rays have stopped (to avoid going forever at the corners).

        @type  percentage: float
        @param percentage: A percentage (in [0.0, 1.0]). If this percentage of points has already stoped, all points will stop.

        @rtype: void
        """
        self.reset()
        self.setTestFunction(checkInsideHalo)
        while ((1.0 - self.moving) < percentage) and self.move():
            pass
    

    def asROI(self):
        """
        Transforms this polygon into an ROI.

        @rtype: Roi
        @return: An Roi.
        """
        return PolygonRoi(
            FloatPolygon(*map(list, zip(*map(Ray.getOrigin, self.points)))), # Unpacking x and y coordinates of rays in two lists
            Roi.NORMAL
        )

    
    def goThroughMembrane(self):
        """
        Uses the membrane's thickness stored as attribute to reach the inner rim of the membrane.

        @rtype: void
        """
        self.reset()
        self.setTestFunction(checkDistanceFunction)
        
        while self.move():
            pass

    
    def recordMembrane(self, data, control, marker, base):
        """
        When calling this function, the polygon must match the outter rim of the membrane.
        Builds a dictionary of stats from the difference between the two polygons.

        @type  data: ImagePlus
        @param data: The values will be taken from this image when the stats will be built.
        @type  control: ImagePlus
        @param control: Image on which masks will be drawn once the segmentation is successful.
        @type  marker: int
        @param marker: Value in [0, 255] representing the intensity with which the current cell will be drawn on the C{control} image.
        @type  base: (int, int)
        @param base: Coordinates of the current working area in the original picture (we are working on croped versions).

        @rtype: void
        """
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
        """
        Summons the rolling sum on each ray composing this polygon.

        @rtype: void
        """
        for r in self.points:
            r.rollingSum(data, scalar)

    
    def validity(self):
        """
        Function aiming to check the validity of a polygon through arbitrary tests.
        We would like to be able to abort the process earlier if the segmentation failed.
        In the current context, cells are supposed to be cycloids (kinda) so we shouldn't have positive curvatures (holes) or harsh angles.

        @rtype: bool
        @return: C{True} if the polygon is supposed valid. False otherwise.
        """
        curvatures = [p.getCurvature() for p in self.points]
        maxCurv = max(curvatures)
        minCurv = min(curvatures)

        if maxCurv > 0.1:
            IJ.log("Skipped. A curvature too high was detected.")
            return False
        
        if minCurv < -0.7:
            IJ.log("Skipped. A curvature too low was detected.")
            return False

        return True


def mvngFromUser(img):
    """
    Reads the user's settings from a file and generate a IJMovingNGon according to them.

    @type  img: ImagePlus
    @param img: Image (mask) on which operations will occur. In the present context, this image should be the preprocessed transmission channel.

    @rtype: IJMovingNGon
    @return: An instance of C{IJMovingNGon} built with respect of the user's settings.
    """
    settings, verbose = readSettings()

    if settings is None:
        return (None, "Failed to read settings: {0}".format(verbose))

    nPoints = settings['nPoints']

    mvng = IJMovingNGon((img.getWidth()/2, img.getHeight()/2), settings['stepSize'], img, settings['tolerance'])
    
    if settings['shape'] == "Box":
        pts, dirs = buildShrinkingBox(nPoints, img.getHeight(), img.getWidth())

    if settings['shape'] == "Ellipse":
        pts, dirs = buildShrinkingEllipsis(nPoints, img.getHeight(), img.getWidth())
    
    mvng.makeRaysFromPoints(pts, dirs)
    
    if settings['ctr_from_mask'] == 'MASK':
        mvng.centroidFromMask()

    if settings['ctr_from_mask'] == 'POINTS':
        mvng.setOriginFromPoints()

    mvng.setMembraneThickness(settings['maxThickness'])

    return (mvng, "DONE.")


def motherDaughterSegmentation(img, data, control, base, idx=None):
    """
    Main function determining the procedure to follow in order to segments dividing yeast cells, and building statistics over them.

    @type  img: ImagePlus
    @param img: Mask used by the IJMovingNGon (preprocessed transmission channel)
    @type  data: ImagePlus
    @param data: Image used to build statistics (in this case, the fluo channel).
    @type  control: ImagePlus:
    @param control: Empty canvas on which masks of detected cells will be drawn as they'll be segmented.
    @type  base: ImagePlus
    @param base: Position of the current working area in the source image

    @rtype: (IJMovingNGon, IJMovingNGon, dict((str, float)), str)
    @return: The two final yeast cells as they've been detected, a dictionary of statistics, and a verbose string.
    """
    # 1. Acquiring polygon object from user's input
    mvng, verbose = mvngFromUser(img)
    if mvng is None:
        return (None, None, None, "Failed to create polygon from settings: {0}".format(verbose))

    # 2. Shrinking polygon to the light halo around the yeasts
    mvng.shrink()
    mvng.updateNormals()
    mvng.processCurvature()

    # 3. Adjusting the new polygon, and splitting it to separate yeasts.
    mvng.smoothProjection(tol=0.8)
    mvng.spreadSamplingLimit(1.0, 2, 0)
    mvng.interpolateSamples(1)

    yeastD, yeastM, cuts = mvng.splitCells()
    cuts = (cuts[1], cuts[0], cuts[2], cuts[3])
    
    if yeastD.getPerimeter() > yeastM.getPerimeter():
        yeastD, yeastM = yeastM, yeastD
        cuts = (cuts[2], cuts[3], cuts[0], cuts[1])

    # 4. Going to the cells.
    percTolHalo = 0.8
    yeastD.skipHalo(percTolHalo)
    yeastM.skipHalo(percTolHalo)

    yeastD.updateNormals()
    yeastM.updateNormals()

    yeastD.subdivide(cuts[0], 3)
    yeastM.subdivide(cuts[2], 3)

    # 5. Getting to the actual membrane
    yeastD.rollingSum(data)
    yeastM.rollingSum(data)

    # 6. Fixing holes
    yeastD.inflate()
    yeastM.inflate()

    # 7. Updating normals and curvature
    yeastD.updateNormals()
    yeastM.updateNormals()

    yeastD.processCurvature()
    yeastM.processCurvature()

    # 8. Recording the membrane area
    if not (yeastD.validity() and yeastM.validity()):
        return (None, None, None, "Segmentation failed: Invalid polygon.")

    statsM = yeastM.recordMembrane(data, control, 255, base)
    statsD = yeastD.recordMembrane(data, control, 127, base)

    # 9. Making stats for daughter (D) and mother (M) yeasts
    stats = {}

    for key, item in statsM.items():
        stats["M_{0}".format(key)] = item

    for key, item in statsD.items():
        stats["D_{0}".format(key)] = item

    infos = data.getTitle().split('$')
    stats['origin'] = infos[0]
    stats['X'] = infos[1]
    stats['Y'] = infos[2]

    return (yeastD, yeastM, stats, "DONE.")

