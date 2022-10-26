from ij import IJ
from sc.fiji.snt import (Path, SNT, Tree)
from net.imagej import ImageJ
from sc.fiji.snt.util import PointInImage

ij = ImageJ()
context = ij.context()
image = IJ.getImage()
snt = SNT(context, image)
snt.enableAstar(True)
snt.initialize(True, 1, 1)


roi = image.getRoi()
points = list(roi.getContainedPoints())

print(points)
startPoint = PointInImage(points[0].getX(),  points[0].getY(), 0)
endPoint = PointInImage(points[1].getX(),  points[1].getY(), 0)
primary_path = snt.autoTrace(startPoint, endPoint, None)