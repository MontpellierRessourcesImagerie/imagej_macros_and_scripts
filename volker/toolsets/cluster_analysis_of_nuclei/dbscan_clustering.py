from ij import IJ
from org.apache.commons.math3.ml.clustering import DBSCANClusterer
from org.apache.commons.math3.ml.clustering import DoublePoint
from java.util import Arrays
import jarray
from ij.gui import PointRoi
from ij.plugin.frame import RoiManager

maxDist = 120
minPts = 2

def run():
	global maxDist, minPts
	
	ip = IJ.getImage()
	roi = ip.getRoi();
	points = roi.getContainedPoints()
	pointList = Arrays.asList(points)
	dplist = []
	for p in pointList:
		array = []
		array.append(p.x)
		array.append(p.y)
		jArray = jarray.array(array, 'd')
		dp = DoublePoint(jArray)
		dplist.append(dp)
	
	clusterer = DBSCANClusterer(maxDist, minPts)
	clusters = clusterer.cluster(dplist)
	RoiManager()
	roiManager = RoiManager.getRoiManager()
	for c in clusters:
		xCoordinates = []
		yCoordinates = []
		for dp in c.getPoints():
			p = dp.getPoint()
			xCoordinates.append(p[0])
			yCoordinates.append(p[1])
		roi = PointRoi(xCoordinates, yCoordinates)
		roiManager.addRoi(roi)

if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  maxDist =  float(args[0].split("=")[1])
  minPts = int(args[1].split("=")[1])

run()