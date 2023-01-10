from movingNgon.rays import Ray, ConditionalRay
from movingNgon.movingNgon import MovingNGon, ConditionalMovingNGon
from mdYeasts.userIO import askSettings, checkSettings
from movingNgon.basicContours import buildShrinkingBox, buildShrinkingEllipsis

from ij import IJ
from ij.gui  import Roi, PolygonRoi
from ij.process import FloatPolygon
import time

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   IMAGEJ TOLERANCE RAY                                                                              #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


class LevelGapRay(ConditionalRay):

    def __init__(self, img, tol, o, d, s):
        super(LevelGapRay, self).__init__(o, d, s)
        self.image = img
        self.tolerance = tol


    def checkCondition(self):
        x = self.origin[0] + self.stepSize * self.direction[0]
        y = self.origin[1] + self.stepSize * self.direction[1]

        proc = self.image.getProcessor()
        before = proc.get(int(self.origin[0]), int(self.origin[1]))
        after = proc.get(int(x), int(y))

        return abs(before - after) < self.tolerance


class IJMovingNGon(ConditionalMovingNGon):

    def __init__(self, center, s, img, tol):
        super(IJMovingNGon, self).__init__(center, s)
        self.image     = img
        self.tolerance = tol


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


def mvngFromUser():
    settings = askSettings()

    if (settings is None) or (not checkSettings(settings)):
        return None
    
    img = IJ.getImage()
    nPoints = settings['nPoints']

    mvng = IJMovingNGon((img.getWidth()/2, img.getHeight()/2), settings['stepSize'], img, settings['tolerance'])
    
    
    if settings['shape'] == "Box":
        pts, dirs = buildShrinkingBox(nPoints, mvng.getOrigin(), img.getHeight(), img.getWidth())

    if settings['shape'] == "Ellipsis":
        pts, dirs = buildShrinkingEllipsis(nPoints, img.getHeight(), img.getWidth())
    
    mvng.makeRaysFromPoints(pts, dirs)
    
    if settings['ctr_from_mask'] == 'MASK':
        mvng.centroidFromMask()

    if settings['ctr_from_mask'] == 'POINTS':
        mvng.setOriginFromPoints()

    return mvng


def motherDaughterSegmentation():
    
    mvng = mvngFromUser()

    if mvng is None:
        return False

    while mvng.move():
        mvng.displayPoints()
        time.sleep(0.02)

    mvng.updateNormals()
    mvng.processCurvate()

    mvng.outputCoordinates("/home/benedetti/Bureau/testingRefactor.txt")

    k = MovingNGon((0, 0), 0.2)
    k.loadFromFile("/home/benedetti/Bureau/testingRefactor.txt")

    return True

