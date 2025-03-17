from ij import IJ
from ij.plugin.filter import ThresholdToSelection
from ij.gui import OvalRoi
from ij.macro import Interpreter
from ij.plugin.frame import RoiManager
from inra.ijpb.morphology.filter import Gradient
from inra.ijpb.morphology.strel import DiskStrel

MIN_RADIUS = 1

image = IJ.getImage()
width = image.getWidth()
height = image.getHeight()
maxRadius = max(width, height) # It only needs to be big enough
image.getProcessor().setThreshold(1, 255)
roi = ThresholdToSelection.run(image)
points = roi.getContainedPoints()

strel = DiskStrel.fromRadius(1)
gradient = Gradient(strel)
gradientIP = gradient.process(image.getProcessor())
image.setProcessor(gradientIP)
image.hide()
strels = [None] * ((maxRadius - MIN_RADIUS) + 1)
for index in range(len(strels)):
    roiWidth = MIN_RADIUS + index
    strels[index] = OvalRoi(-roiWidth/2, -roiWidth/2, roiWidth, roiWidth)
 
medialAxis = []

Interpreter.batchMode = True
nrOfPoints = len(points)
for point in points:
    print("Processing point " + str(point) + " of " + str(nrOfPoints))
    for index, roi in enumerate(strels):
        roi.setLocation(point.x, point.y)
        image.setRoi(roi)
        h = image.getProcessor().getHistogram()
        roi.translate(-point.x, -point.y)
        if h[255] > 5:
            continue
        if h[255] > 1:
            medialAxis.append((point, MIN_RADIUS + index))
        if h[255] > 0: 
            break
Interpreter.batchMode = False            
image.show()
# print(medialAxis)
roiManager = RoiManager.getRoiManager()
for point, radius in medialAxis:
    print(point, radius)
    roi = OvalRoi(point.x, point.y, radius, radius, image)
    print(roi)
    roiManager.addRoi(roi)