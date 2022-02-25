import math, pprint
from fr.cnrs.mri.datastructures.spotnode import SpotNode
from ij import IJ
from ij.measure import ResultsTable
from ij.plugin.frame import RoiManager

image = IJ.getImage()
rt = ResultsTable.getResultsTable()
scaleSpaceSpotsTree = SpotNode.fromImageAndResultsTable(image, rt)

# spotList = scaleSpaceSpotsTree.asList()
# pp = pprint.PrettyPrinter(indent=2)
# pp.pprint(spotList)
isolatedSpots = scaleSpaceSpotsTree.getIsolatedSpots()
roiManager = RoiManager.getRoiManager()
while isolatedSpots:
	for spot in isolatedSpots:
		spot.remove()
		roiManager.select(spot.spotID-1)
		roiManager.runCommand("Set Fill Color", "red");
	isolatedSpots = scaleSpaceSpotsTree.getIsolatedSpots()	
scaleSpaceSpotsTree.colorizeRoisBySubtree()
scaleSpaceSpotsTree.calculateSubtreeMinima()
scaleSpaceSpotsTree.drawMinima()