import math
import jarray
from ij.measure import ResultsTable
from org.apache.commons.math3.ml.clustering import DoublePoint
from ij import WindowManager, IJ
from itertools import groupby
from operator import itemgetter

def main(tableName):
	if tableName=='clusters':
		calculateNNDsByCluster(tableName)
	else:
		calculateNNDsByTable(tableName)

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
	for cluster in clusters:
		dplist = []
		for nr, x, y, z in cluster:
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
			rt.setValue("neighbor", row, nearestNeighborsInd[index]+1)
			index = index + 1
	win.rename("tmp")
	win.rename(tableName)
		
def calculateNNDsByTable(tableName):
	pointList = pointList3DFromRT(tableName)	
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
#	drawNearestNeighborConnections()

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
		
def drawNearestNeighborConnections():
	ip = IJ.getImage()
	calibration = ip.getCalibration()
	width = ip.getWidth()
	height = ip.getHeight()
	stackSize = ip.getStackSize()
	win = WindowManager.getWindow("clusters")
	rt = win.getResultsTable()
	for row in range(0, rt.size()):
		x1 = rt.getValue("X", row)
		y1 = rt.getValue("Y", row)
		z1 = rt.getValue("Z", row)
		neighbor = int(rt.getValue("neighbor", row)-1)
		x2 = rt.getValue("X", neighbor)
		y2 = rt.getValue("Y", neighbor)
		z2 = rt.getValue("Z", neighbor)
		x1 = calibration.getRawX(x1)
		y1 = calibration.getRawY(y1)
		z1 = calibration.getRawZ(z1)
		x2 = calibration.getRawX(x2)
		y2 = calibration.getRawY(y2)
		z2 = calibration.getRawZ(z2)
		IJ.run(ip, "3D Draw Line", "size_x="+str(width)+" size_y="+str(height)+" size_z="+str(stackSize)+" x0="+str(x1)+" y0="+str(y1)+" z0="+str(z1)+" x1="+str(x2)+" y1="+str(y2)+" z1="+str(z2)+" thickness=1.000 value=65535 display=Overwrite")
	
def pointList3DFromRT(tableName):
	win = WindowManager.getWindow(tableName)
	rt = win.getResultsTable()
	X = rt.getColumn(rt.getColumnIndex("X"))
	Y = rt.getColumn(rt.getColumnIndex("Y"))
	Z = rt.getColumn(rt.getColumnIndex("Z"))
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

if 'getArgument' in globals():
  del zip 	# the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
  parameter = getArgument()
  args = parameter.split(",")
  tableName =  args[0].split("=")[1]
else:
  tableName = "clusters"
main(tableName)