# DBSCAN applied to the clustering of colors
from ij import IJ, ImagePlus, ImageStack
from org.apache.commons.math3.ml.clustering import DBSCANClusterer
from org.apache.commons.math3.ml.clustering import DoublePoint
from java.util import Arrays
import jarray

maxDist = 800
minPts = 400

pointList=[]
imp = IJ.getImage()
title = imp.getTitle()
stack = imp.getImageStack()
width = imp.getWidth()
height = imp.getHeight()

index = imp.getStackIndex(1, 1, 1)
redProcessor = stack.getProcessor(index)
redPixels = redProcessor.getPixels()

index = imp.getStackIndex(2, 1, 1)
greenProcessor = stack.getProcessor(index)
greenPixels = greenProcessor.getPixels()

index = imp.getStackIndex(3, 1, 1)
blueProcessor = stack.getProcessor(index)
bluePixels = blueProcessor.getPixels()

print "Extracting colors..."

colors = set()
for i in range(0, len(bluePixels)): 
	vec = redPixels[i], greenPixels[i], bluePixels[i]
	colors.add(vec)

dplist = []
for c in colors:
	jArray = jarray.array(c, 'd')
	dp = DoublePoint(jArray)
	dplist.append(dp)
	
print len(dplist)

print "start clustering"

clusterer = DBSCANClusterer(maxDist, minPts)
clusters = clusterer.cluster(dplist)

print "finished clustering"

print len(clusters)

allClusters = []

for c in clusters:
	tupelCluster = set()
	for dp in c.getPoints():
		p = dp.getPoint()
		rgb = p[0], p[1], p[2]
		tupelCluster.add(rgb)
	allClusters.append(tupelCluster)

greyPixels = []
for i in range(0, len(bluePixels)): 
	vec = redPixels[i], greenPixels[i], bluePixels[i]
	clusterNr = 0
	for c in allClusters:
		if vec in c:
			break
		clusterNr = clusterNr + 1
	greyPixels.append(clusterNr)

jArray = jarray.array(greyPixels, 'h')
indexedMask = IJ.createImage("Indexed mask of " + title, "16-bit white", width, height, 1)
indexedMask.getProcessor().setPixels(jArray)
indexedMask.show();
IJ.run(indexedMask, "Rainbow RGB", "");
IJ.run(indexedMask, "Enhance Contrast", "saturated=0.35");