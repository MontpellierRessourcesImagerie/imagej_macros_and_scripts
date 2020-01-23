from ij import IJ, WindowManager
from ij.measure import ResultsTable
from org.apache.commons.math3.ml.clustering import DoublePoint
from org.apache.commons.math3.ml.clustering import DBSCANClusterer
import jarray

def run(maxDist, minPts):
	points = pointList3DFromRT()
	clusterer = DBSCANClusterer(maxDist, minPts)
	clusters = clusterer.cluster(points)
	reportClustersAsTable(clusters)

def pointList3DFromRT():
	rt = ResultsTable.getResultsTable()
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

def reportClustersAsTable(clusters):
	rt = ResultsTable()
	counter = 1;
	clusterCounter = 1
	for c in clusters:
		for dp in c.getPoints():
			rt.incrementCounter()
			p = dp.getPoint()
			rt.addValue("NR", counter)
			rt.addValue("X", p[0])
			rt.addValue("Y", p[1])
			rt.addValue("Z", p[2])
			rt.addValue("C", clusterCounter)
			counter = counter + 1;
		clusterCounter = clusterCounter + 1
	rt.show("clusters")
	win = WindowManager.getWindow("Results")
	rt = win.getResultsTable()
	X = rt.getColumn(0)
	Y = rt.getColumn(1)
	Z = rt.getColumn(2)
	NR = rt.getColumn(4)
	
	allPoints = list(zip(NR,X,Y,Z))
	
	win = WindowManager.getWindow("clusters")
	rt = win.getResultsTable()
	XC = rt.getColumn(1)
	YC = rt.getColumn(2)
	ZC = rt.getColumn(3)
	
	clusteredPoints = list(zip(XC,YC,ZC))
	
	unclusteredPoints = [point for point in allPoints if (point[1], point[2], point[3]) not in clusteredPoints] 
	
	counter = 1;
	rt = ResultsTable()
	for p in unclusteredPoints:
		rt.incrementCounter()
		rt.addValue("NR", counter)
		rt.addValue("X", p[1])
		rt.addValue("Y", p[2])
		rt.addValue("Z", p[3])
		counter = counter + 1;
	
	rt.show("unclustered")
	WindowManager.setWindow(win)


if 'getArgument' in globals():
  del zip 	# the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
  parameter = getArgument()
  args = parameter.split(",")
  maxDist =  float(args[0].split("=")[1])
  minPts = int(args[1].split("=")[1])
else:
  minPts = 5
  maxDist = 18
run(maxDist, minPts)