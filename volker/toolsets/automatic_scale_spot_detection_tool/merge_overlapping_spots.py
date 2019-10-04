from ij import IJ
from java.util import Arrays
import math
from ij.gui import Line
from ij.measure import ResultsTable
from ij.plugin.frame import RoiManager

MIN_OVERLAP = 50

rt = ResultsTable.getResultsTable()
X = rt.getColumn(ResultsTable.X_CENTROID)
Y = rt.getColumn(ResultsTable.Y_CENTROID)
D = rt.getColumn(ResultsTable.FERET)

width = len(X)
height = width - 1
big = float("inf")
matrix = [[0 for x in range(width)] for y in range(width)] 


for l in range(0,height):
	for c in range(l+1,width):
		x1 = X[l]
		y1 = Y[l]
		d1 = D[l]
		r1 = d1 / 2.0
		x2 = X[c]
		y2 = Y[c]
		d2 = D[c]
		r2 = d2 / 2.0
		delta_x = x1 - x2
		delta_y = y1 - y2
		distance = math.sqrt((delta_x * delta_x) + (delta_y*delta_y))
		t = (r1+r2)-distance
		p1 = 0
		p2 = 0
		if t>0:
			p1 = (100 * d1) / t
			p2 = (100 * d2) / t 
		matrix[l][c] = p1
		matrix[c][l] = p2

RoiManager()
roiManager = RoiManager.getRoiManager()
image = IJ.getImage()
toBeDeleted = []
for l in range(0,height):
	for c in range(l+1,width):
		if matrix[c][l]>MIN_OVERLAP:
			tmp = c;
			c = l;
			l = tmp;
		if matrix[l][c]>MIN_OVERLAP:
			roiManager.setSelectedIndexes([l,c])
			roiManager.runCommand("Combine")
			roi = image.getRoi()	
			roiManager.setRoi(roi, l)
			toBeDeleted.append(c)
			matrix[c][l] = 0
			matrix[l][c] = 0
			
if len(toBeDeleted)>0:
	roiManager.setSelectedIndexes(toBeDeleted)
	roiManager.runCommand("Delete")