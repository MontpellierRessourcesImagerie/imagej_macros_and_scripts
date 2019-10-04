from ij import IJ
from java.util import Arrays
import math
from ij.gui import Line
from ij.measure import ResultsTable
from ij.plugin.frame import RoiManager
from ij.gui import WaitForUserDialog

MIN_OVERLAP = 50

def main(minOverlap):

	nrOfMerges = 0;
	
	rt = ResultsTable.getResultsTable()
	X = rt.getColumn(ResultsTable.X_CENTROID)
	Y = rt.getColumn(ResultsTable.Y_CENTROID)
	D = rt.getColumn(ResultsTable.FERET)
	
	width = len(X)
	height = width - 1
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
				p1 = (100 * t) / d1
				p2 = (100 * t) / d2 
			matrix[l][c] = p1
			matrix[c][l] = p2
	
	RoiManager()
	roiManager = RoiManager.getRoiManager()
	image = IJ.getImage()
	toBeDeleted = []
	for l in range(0,height):
		for c in range(l+1,width):
			if matrix[c][l]>minOverlap:
				tmp = c;
				c = l;
				l = tmp;
			if matrix[l][c]>minOverlap:
				print(matrix[l][c])
				nrOfMerges = nrOfMerges + 1
				roiManager.setSelectedIndexes([l,c])
				roiManager.runCommand("Combine")
				roi = image.getRoi()	
				roiManager.setRoi(roi, l)
				IJ.run(image, "Select None", "");
				toBeDeleted.append(c)
				matrix[c][l] = 0
				matrix[l][c] = 0
				
	if len(toBeDeleted)>0:
		roiManager.setSelectedIndexes(toBeDeleted)
		roiManager.runCommand("Delete")
	return nrOfMerges

def isIntersectionEmpty(roi1, roi2):
	shape1 = ShapeRoi(roi1)
	shape2 = ShapeRoi(roi2)
	shape = shape2.and(shape1)
	array = shape.getShapeAsArray()
	result = (array is None or len(array)==0)
	return result

minOverlap = MIN_OVERLAP
if 'getArgument' in globals():
	parameter = getArgument()
	args = parameter.split(",")
	minOverlap = int(args[0].split("=")[1])

nrOfMerges = 99999
while(nrOfMerges>0):
	nrOfMerges = main(minOverlap)
	print(nrOfMerges)
	rt = ResultsTable.getResultsTable()
	roiManager = RoiManager.getRoiManager()
	IJ.run("Clear Results", "")
	rt.updateResults()
	roiManager.runCommand("Deselect")
	roiManager.runCommand("Measure")
	rt.updateResults()
	wfud = WaitForUserDialog("continue") 
	wfud.show()