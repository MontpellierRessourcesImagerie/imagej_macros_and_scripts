from ij import IJ
from java.util import Arrays
import math
from ij.gui import Line
from ij.plugin.frame import RoiManager

big = float("inf")
ip = IJ.getImage()
roi = ip.getRoi();
points = roi.getContainedPoints()
pointList = Arrays.asList(points)

width = len(pointList)
height = width - 1

matrix = [[big for x in range(width)] for y in range(width)] 

for l in range(0,height):
	for c in range(l+1,width):
		p1 = pointList[l]
		p2 = pointList[c]   
		delta_x = p1.x - p2.x
		delta_y = p1.y - p2.y
		value = math.sqrt((delta_x * delta_x) + (delta_y*delta_y))
		matrix[l][c] = value
		matrix[c][l] = value

nearestNeighborsDist = []
nearestNeighborsInd = []
for l in range(0, width):
	minimum = min(matrix[l])
	index = matrix[l].index(minimum)
	nearestNeighborsDist.append(minimum)
	nearestNeighborsInd.append(index)

RoiManager()
roiManager = RoiManager.getRoiManager()

for i in range(0, width):
	nnI = nearestNeighborsInd[i]
	if (nnI<i and nearestNeighborsInd[nnI]==i):
		continue
	p1 = pointList[i]
	p2 = pointList[nnI]
	roi = Line(p1.x, p1.y, p2.x, p2.y)
	roiManager.addRoi(roi)
