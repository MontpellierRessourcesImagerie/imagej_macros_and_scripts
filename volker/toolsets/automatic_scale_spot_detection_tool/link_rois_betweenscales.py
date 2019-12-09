###################################################################################
#
# Link rois between scales. A roi r1 on scale s1 is linked with a roi r2 
# on scale s2, if the center of r1 is within the radius of r2 and there
# is no other roi on s2 whose center is closer to the center of r1.
#
# Expects the measurements X, Y (centroid), Feret (diameter) and Slice
# in the results-table.
#
# (c) 2019, INSERM
# written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr), Biocampus Montpellier
#
##################################################################################

from ij.measure import ResultsTable
import math
from ij.plugin.frame import RoiManager

def main():
	linkedSpots = linkSpots()

def linkSpots():
	rt = ResultsTable.getResultsTable()
	X = rt.getColumn(ResultsTable.X_CENTROID)
	Y = rt.getColumn(ResultsTable.Y_CENTROID)
	D = rt.getColumn(ResultsTable.FERET)
	SLICE = rt.getColumn(ResultsTable.SLICE)
	spotsByScale = getRoisBySlice(SLICE)
	print(spotsByScale)
	for s in range(1, len(spotsByScale)):
		print('scale', s)
		spots = spotsByScale[s]
		for spot in spots:
			print('spot', spot)
			if not spot['object']:
				spot['object']=spot['id']
			spotsNextScale = spotsByScale[s+1]
			for spotNextScale in spotsNextScale:
				print('spot next scale', spotNextScale)
				deltaX = X[spotNextScale['id']]-X[spot['id']]
				deltaY = Y[spotNextScale['id']]-Y[spot['id']]
				dist = math.sqrt((deltaX * deltaX) + (deltaY*deltaY))
				print('dist', dist)
				if (dist<(D[spotNextScale['id']]/2.0)):
					print('hit')
					minDist = dist
					minObject = spot['object']
				if (minObject):
					spotNextScale['object'] = minObject	
					print(spot['id']+1, spotNextScale['id']+1, minObject+1, minDist)
		print(spotsByScale) 
	RoiManager()
	roiManager = RoiManager.getRoiManager()
	colors = {0 : "red", 1 : "green", 2 : "blue", 3 : "yellow", 4 : "magenta", 5 : "cyan"}
	for s in range(1, len(spotsByScale)):
		spots = spotsByScale[s]
		for spot in spots:
			if (spot['object']):
				roiManager.select(spot['id']+1);
				currentColor = spot['object'] % len(colors)
				roiManager.runCommand("Set Color", colors[currentColor])
def getRoisBySlice(slice):
	roisBySlice = {}
	for i in range(0, len(slice)):
		if not roisBySlice.has_key(slice[i]): 
			roisBySlice[slice[i]]=[]
		roisBySlice[slice[i]].append({'id': i, 'object': None})
	return roisBySlice

main()