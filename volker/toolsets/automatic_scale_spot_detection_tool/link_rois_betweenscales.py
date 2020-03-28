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
#	print(linkedSpots)
#	drawSpots(linkedSpots)
	objects = createObjects(linkedSpots)
	print(objects)
	minima = getMinima(objects)
	print(minima)
	
def linkSpots():
	rt = ResultsTable.getResultsTable()
	X = rt.getColumn(ResultsTable.X_CENTROID)
	Y = rt.getColumn(ResultsTable.Y_CENTROID)
	D = rt.getColumn(ResultsTable.FERET)
	SLICE = rt.getColumn(ResultsTable.SLICE)
	spotsByScale = getRoisBySlice(SLICE)
	print(spotsByScale)
	## set objects of spots i scale 1 to the id of the spot
	spots = spotsByScale[1]
	for spot in spots:
		spot['object']=spot['id']
	for s in range(2, len(spotsByScale)+1):
		spots = spotsByScale[s]
		for spot in spots:
			spot['object']=spot['id']						# initially set the object to which the spot belong to the spot id
			spotsLastScale = spotsByScale[s-1]
			minDist = float("inf")
			minObject = None
			for spotLastScale in spotsLastScale:
			# for each spot on the next scale
				deltaX = X[spotLastScale['id']]-X[spot['id']]
				deltaY = Y[spotLastScale['id']]-Y[spot['id']]
				dist = math.sqrt((deltaX * deltaX) + (deltaY*deltaY))
				print("spot", spot['id'], "spot s-1", spotLastScale['id'], dist)   
				if (dist<(D[spot['id']])/2.0):
					if (dist<minDist):
						minDist = dist
						minObject = spotLastScale['object']
						print('hit', minDist, minObject)
			if minObject is not None:
				spot['object'] = minObject	
				print("minObject", minObject)
	return spotsByScale 

def drawSpots(spotsByScale):
	RoiManager()
	roiManager = RoiManager.getRoiManager()
	colors = {0 : "red", 1 : "green", 2 : "blue", 3 : "yellow", 4 : "magenta", 5 : "cyan", 6 : "orange", 7 : "black", 8 : "white"}
	print("len-col", len(colors))
	for s in range(1, len(spotsByScale)+1):
		spots = spotsByScale[s]
		for spot in spots:
			roiManager.select(spot['id']);
			currentColor = spot['object'] % len(colors)
			print(spot['id'], spot['object'], currentColor)
			roiManager.runCommand("Set Color", colors[currentColor])
			
def getRoisBySlice(slice):
	roisBySlice = {}
	for i in range(0, len(slice)):
		if not roisBySlice.has_key(slice[i]): 
			roisBySlice[slice[i]]=[]
		roisBySlice[slice[i]].append({'id': i, 'object': None})
	return roisBySlice

def createObjects(spotsByScale):
	objects = {}
	for s in range(1, len(spotsByScale)+1):
		spots = spotsByScale[s]
		for spot in spots:
			if not spot['object'] in objects:
				objects[spot['object']] = []
			objects[spot['object']].append(spot['id'])
	return objects

def getMinima(objects):
	minIndices = {}
	
	rt = ResultsTable.getResultsTable()
	minIntensities = rt.getColumn(ResultsTable.MIN)
	
	for key in objects:
		ids = objects[key]
		minIndex = -1
		minimum = float('inf')
		for anID in ids:
			if minIntensities[anID]<minimum:
				minimum = minIntensities[anID]
				minIndex = anID
		minIndices[key] = minIndex
	return minIndices
		
main()