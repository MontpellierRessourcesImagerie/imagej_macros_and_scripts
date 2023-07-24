from ij.gui import NewImage,PolygonRoi, Roi
from ij.plugin import HyperStackConverter
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation
from java.awt import Color
import random

minWidth = 5
maxWidth = 15
minHeight = 3
maxHeight = 6



image = NewImage.createShortImage ("test hyperstack", 256, 256, 60, NewImage.FILL_BLACK)
hyperStack = HyperStackConverter.toHyperStack(image, 2, 6, 5)  
segmentation = InstanceSegmentation(hyperStack)
hyperStack.setC(3)
segmentation.image.show()

xpoints = [118,130,147,156,177,173,199,205];
ypoints = [35,62,98,138,181,215,240,248];
roi = PolygonRoi(xpoints,ypoints,Roi.POLYLINE)
segmentation.image.setRoi(roi);

coords = zip(roi.getPolygon().xpoints, roi.getPolygon().ypoints)

segmentation.image.setColor(Color.white)

processor = segmentation.image.getProcessor()

offsetX = 0
offsetY = 0
for t in range(1, 5):
    segmentation.image.setT(t)
    for z in range(1, 4):
        segmentation.image.setZ(z)
        for index, coord in enumerate(coords):
            label = index + 1
            w = random.randint(minWidth, maxWidth)
            h = random.randint(minHeight, maxHeight)
            processor.fillOval(coord[0] + offsetX, coord[1] + offsetY, w, h)
    offsetX = offsetX + random.randint(-5, 5)
    offsetY = offsetY + random.randint(-5, 5)
    print(offsetX, offsetY)
