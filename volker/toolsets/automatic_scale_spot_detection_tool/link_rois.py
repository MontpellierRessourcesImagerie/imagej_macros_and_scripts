from ij.measure import ResultsTable
import math
from ij.plugin.frame import RoiManager

def main():
	rt = ResultsTable.getResultsTable()
	X = rt.getColumn(ResultsTable.X_CENTROID)
	Y = rt.getColumn(ResultsTable.Y_CENTROID)
	D = rt.getColumn(ResultsTable.FERET)
	SLICE = rt.getColumn(ResultsTable.SLICE)
	roisBySlice = getRoisBySlice(SLICE)
	keys = roisBySlice.keys()
	keys.reverse()
	treeOfRois = {}
	children = {}
	parent = {}
	for sliceNr in keys:
		rois = roisBySlice[sliceNr]
		if (sliceNr==1):
			break
		for roi in rois:
			x = X[roi]
			y = Y[roi]
			r = D[roi] / 2.0
			childRois = roisBySlice[sliceNr-1]
			siblings = [];
			for childRoi in childRois:
				xC = X[childRoi]
				yC = Y[childRoi]
				delta_x = x - xC
				delta_y = y - yC
				distance = math.sqrt((delta_x * delta_x) + (delta_y*delta_y))
				if (distance<r):
					if (not treeOfRois.has_key(roi)):
						treeOfRois[roi] = roi
					treeOfRois[childRoi] = treeOfRois[roi]
					siblings.append(childRoi)
					parent[childRoi] = roi
			children[roi] = siblings
	colorizeTrees(treeOfRois, children)
		
def colorizeTrees(tree, children):
	RoiManager()
	roiManager = RoiManager.getRoiManager()
	colors = {0 : "red", 1 : "green", 2 : "blue", 3 : "yellow", 4 : "magenta", 5 : "cyan"}
	for root in tree.keys():
		roiManager.select(root);
		currentColor = root % len(colors)
		roiManager.runCommand("Set Color", colors[currentColor])
		
			
	


def getRoisBySlice(slice):
	roisBySlice = {}
	for i in range(0, len(slice)):
		if not roisBySlice.has_key(slice[i]): 
			roisBySlice[slice[i]]=[]
		roisBySlice[slice[i]].append(i)
	return roisBySlice
	
main()