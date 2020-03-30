'''
DBSCAN-clustering of 3D-points. 

(c) 2019-2020, INSERM
written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)

The points must be in the X, Y, Z and NR columns
of the ImageJ system results-table. By default the columns
'X', 'Y', 'Z' and 'NR' are used. However other column names
can be provided. 

	X, Y, Z: The column names of the columns containing the 3D coordinates of the points
	     NR: The column containing the indices or ids of the points. If the table does not have this column, it is created. 

The DBSCAN-slustering is run with a maximum distance and a 
minimum number of points for a cluster.

The script will create two tables as results. The table clusters and the table unclustered. The table clusters will contain
all points that belong to a cluster. The column 'C' in the clusters table specifies the cluster to which the point belongs. 
The table unclustered contains all points that have not been associated with a cluster.
'''
from ij import IJ, WindowManager
from ij.measure import ResultsTable
from org.apache.commons.math3.ml.clustering import DoublePoint
from org.apache.commons.math3.ml.clustering import DBSCANClusterer
import jarray

def run(maxDist, minPts, XColumn='X', YColumn='Y', ZColumn='Z', NRColumn='NR'):
	'''
	Run the DBSCAN-clustering.

	Parameters:
		maxDist: The maximum distance for the DBScan-clustering algorithm
		minPts: The minimum number of points a cluster must have
		XColumn: The name of column containing the x-coordinates
		YColumn: The name of column containing the y-coordinates
		ZColumn: The name of column containing the z-coordinates
		NRColumn: The name of column containing the indices or ids of the points
	'''
	points = pointList3DFromRT(XColumn, YColumn, ZColumn)
	clusterer = DBSCANClusterer(maxDist, minPts)
	clusters = clusterer.cluster(points)
	reportClustersAsTable(clusters, XColumn, YColumn, ZColumn, NRColumn)

def pointList3DFromRT(XColumn='X', YColumn='Y', ZColumn='Z'):
	'''
	Create a list of 3D-coordinates from the ImageJ system results table and return it.
	'''
	rt = ResultsTable.getResultsTable()
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

def reportClustersAsTable(clusters, XColumn='X', YColumn='Y', ZColumn='Z', NRColumn='NR'):
	'''
	Report the clustered and unclustered points in the tables 'clusters' and 'unclustered'.
	'''
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
	X = rt.getColumn(rt.getColumnIndex(XColumn))
	Y = rt.getColumn(rt.getColumnIndex(YColumn))
	Z = rt.getColumn(rt.getColumnIndex(ZColumn))
	if not rt.columnExists(NRColumn):
		for i in range(0, len(X)):
			rt.setValue(NRColumn, i, i+1)
		rt.updateResults()
	NR = rt.getColumn(rt.getColumnIndex(NRColumn))
	
	allPoints = list(zip(NR,X,Y,Z))
	
	win = WindowManager.getWindow("clusters")
	rt = win.getResultsTable()
	XC = rt.getColumn(1)
	YC = rt.getColumn(2)
	ZC = rt.getColumn(3)

	clusteredPoints = []
	if XC:
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


XColumn = 'X'
YColumn = 'Y'
ZColumn = 'Z'
NRColumn = 'NR'
if 'getArgument' in globals():
	if not hasattr(zip, '__call__'):
		del zip 					# the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
	parameter = getArgument()
	args = parameter.split(",")
	maxDist = float(args[0].split("=")[1])
	minPts = int(args[1].split("=")[1])
	if len(args)>2:
		XColumn=args[2].split("=")[1]
		YColumn=args[3].split("=")[1]
		ZColumn=args[4].split("=")[1]
		NRColumn=args[5].split("=")[1]
else:
  minPts = 5
  maxDist = 18
run(maxDist, minPts, XColumn, YColumn, ZColumn, NRColumn)