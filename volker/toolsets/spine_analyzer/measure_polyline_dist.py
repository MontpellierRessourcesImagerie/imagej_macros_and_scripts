from ij.plugin.frame import RoiManager
from ij.measure import Measurements
from ij.gui import PolygonRoi
from ij.gui import Roi
from ij import IJ
import math 

image = IJ.getImage()
roiManager = RoiManager.getRoiManager()
rois = roiManager.getRoisAsArray()
l1 = rois[0]
l2 = rois[1]

length = max(l1.getUncalibratedLength(), l2.getUncalibratedLength())
print("length", length)
length = image.getCalibration().getX(length)
print("length", length)
shape1 = l1.getPolygon()
shape2 = l2.getPolygon()

p11x = shape1.xpoints[0]
p11y = shape1.ypoints[0]
p12x = shape1.xpoints[-1]
p12y = shape1.ypoints[-1]

p21x = shape2.xpoints[0]
p21y = shape2.ypoints[0]
p22x = shape2.xpoints[-1]
p22y = shape2.ypoints[-1]

dist1 = math.sqrt((p11x - p21x)**2 + (p11y - p21y)**2)
dist2 = math.sqrt((p11x - p22x)**2 + (p11y - p22y)**2)

if dist2<=dist1:
    xMerged = list(shape2.xpoints)
    yMerged = list(shape2.ypoints)
    xMerged.extend(list(shape1.xpoints))
    yMerged.extend(list(shape1.ypoints))
else:    
    xMerged = list(shape1.xpoints)
    xMerged.reverse()
    yMerged = list(shape1.ypoints)
    yMerged.reverse()
    xMerged.extend(list(shape2.xpoints))
    yMerged.extend(list(shape2.ypoints))

closedRoi = PolygonRoi(xMerged, yMerged, len(xMerged), Roi.POLYGON)

tmpRoi = image.getRoi()
image.setRoi(closedRoi)
stats = image.getStatistics(Measurements.AREA)
area = stats.area
print("area", area)
dist = area / length
print(dist)
# image.setRoi(tmpRoi)