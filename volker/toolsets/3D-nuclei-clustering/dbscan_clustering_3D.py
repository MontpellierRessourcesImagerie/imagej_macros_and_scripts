from ij import IJ
from ij.measure import ResultsTable
from org.apache.commons.math3.ml.clustering import DoublePoint
from org.apache.commons.math3.ml.clustering import DBSCANClusterer
import jarray

def run():
	global maxDist, minPts
	points = pointList3DFromRT()
	clusterer = DBSCANClusterer(maxDist, minPts)
	clusters = clusterer.cluster(points)
	print(clusters.size())
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
			rt.addValue("N", counter)
			rt.addValue("X", p[0])
			rt.addValue("Y", p[1])
			rt.addValue("Z", p[2])
			rt.addValue("C", clusterCounter)
			counter = counter + 1;
		clusterCounter = clusterCounter + 1
	rt.show("clusters")
	
if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  maxDist =  float(args[0].split("=")[1])
  minPts = int(args[1].split("=")[1])
else:
  minPts = 5
  maxDist = 18
run()