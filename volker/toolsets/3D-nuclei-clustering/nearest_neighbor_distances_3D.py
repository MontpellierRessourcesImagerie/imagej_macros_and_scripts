import math
import jarray
from ij.measure import ResultsTable
from org.apache.commons.math3.ml.clustering import DoublePoint
from ij import WindowManager, IJ
from itertools import groupby
from operator import itemgetter

def main(tableName, XColumn='X', YColumn='Y', ZColumn='Z'):
	if tableName=='clusters':
		calculateNNDsByCluster(tableName)
	else:
		calculateNNDsByTable(tableName, XColumn='X', YColumn='Y', ZColumn='Z')

def calculateNNDsByCluster(tableName):
	win = WindowManager.getWindow(tableName)
	rt =  win.getResultsTable()
	C = rt.getColumn(4)
	nrOfClusters = int(max(C))
	NR = rt.getColumn(0)
	C = rt.getColumn(4)
	X = rt.getColumn(1)
	Y = rt.getColumn(2)
	Z = rt.getColumn(3)
	points = list(zip(NR,X,Y,Z,C))
	points.sort(key = itemgetter(4))
	groups = groupby(points, itemgetter(4))
	clusters = [[(item[1], item[2], item[3], item[0]) for item in data] for (key, data) in groups]
	offset = 0;
	for cluster in clusters:
		dplist = []
		for x, y, z, nr in cluster:
			array = []
			array.append(x)
			array.append(y)
			array.append(z)
			array.append(nr)
			jArray = jarray.array(array, 'd')
			dp = DoublePoint(jArray)
			dplist.append(dp)
	
		nearestNeighborsDist, nearestNeighborsInd = calculateNNDs(dplist)
		index = 0
		for point in cluster:
			row = int(point[3]) - 1
			rt.setValue("nn. dist", row, nearestNeighborsDist[index])
			rt.setValue("neighbor", row, nearestNeighborsInd[index]+1+offset)
			index = index + 1
		offset = offset + len(cluster);
	win.rename("tmp")
	win.rename(tableName)
		
def calculateNNDsByTable(tableName, XColumn='X', YColumn='Y', ZColumn='Z'):
	pointList = pointList3DFromRT(tableName, XColumn='X', YColumn='Y', ZColumn='Z')	
	nearestNeighborsDist, nearestNeighborsInd = calculateNNDs(pointList)
	
	win = WindowManager.getWindow(tableName)
	rt = win.getResultsTable()
	row = 0
	for distance in nearestNeighborsDist:
		rt.setValue("nn. dist", row, distance)
		row = row + 1
	row = 0
	for neighbor in nearestNeighborsInd:
		rt.setValue("neighbor", row, neighbor+1)
		row = row + 1
	rt.updateResults()
	win.rename("tmp")
	win.rename(tableName)

def calculateNNDs(pointList):
	big = float("inf")
	width = len(pointList)
	height = width - 1
	
	matrix = [[big for x in range(width)] for y in range(width)] 
	
	for l in range(0,height):
		for c in range(l+1,width):
			p1 = pointList[l].getPoint()
			p2 = pointList[c].getPoint()   
			delta_x = p1[0] - p2[0]
			delta_y = p1[1] - p2[1]
			delta_z = p1[2] - p2[2]
			value = math.sqrt((delta_x * delta_x) + (delta_y*delta_y) + (delta_z*delta_z))
			matrix[l][c] = value
			matrix[c][l] = value
	
	nearestNeighborsDist = []
	nearestNeighborsInd = []
	for l in range(0, width):
		minimum = min(matrix[l])
		index = matrix[l].index(minimum)
		nearestNeighborsDist.append(minimum)
		nearestNeighborsInd.append(index)
	return nearestNeighborsDist, nearestNeighborsInd
			
def pointList3DFromRT(tableName, XColumn='X', YColumn='Y', ZColumn='Z'):
	win = WindowManager.getWindow(tableName)
	rt = win.getResultsTable()
	X = rt.getColumn(rt.getColumnIndex(XColumn))
	Y = rt.getColumn(rt.getColumnIndex(YColumn))
	Z = rt.getColumn(rt.getColumnIndex(ZColumn))
	dplist = []
	for x, y, z in zip(X, Y, Z):
		array = []
		array.append(x)
		array.append(y)
		array.append(z)
		jArray = jarray.array(array, 'd')
		dp = DoublePoint(jArray)
		dplist.append(dp)
	return dplist

XColumn = 'X'
YColumn = 'Y'
ZColumn = 'Z'
if 'getArgument' in globals():
	if not hasattr(zip, '__call__'):
		del zip 					# the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
	parameter = getArgument()
	args = parameter.split(",")
	tableName =  args[0].split("=")[1]
	if len(args)>1:
		XColumn=args[2].split("=")[1]
		YColumn=args[3].split("=")[1]
		ZColumn=args[4].split("=")[1]
else:
	tableName = "clusters"
main(tableName, XColumn, YColumn, ZColumn)