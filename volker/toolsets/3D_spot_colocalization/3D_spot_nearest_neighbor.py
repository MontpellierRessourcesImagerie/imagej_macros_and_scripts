import math
import jarray
from ij import WindowManager, IJ, ImageStack, ImagePlus
from ij.measure import ResultsTable

from org.apache.commons.math3.ml.clustering import DoublePoint
from itertools import groupby
from operator import itemgetter

def main(action,tableName1,tableName2,moreArgs):
	if action == "DistanceMatrix":
		calculateDistanceMatrix(tableName1,tableName2)

	if action == "CumulatedNeighbors":
		calculateCumulatedNeighbors(tableName1,tableName2)

	if action == "PlotDistanceDistribution":
		plotDistanceDistribution(tableName1,tableName2,moreArgs)

	if action == "CountCloserNeighbors":
		countCloserNeighbors(tableName1,tableName2,moreArgs)

	if action == "GetCloserPairs":
		getCloseCoordPairs(tableName1,tableName2,moreArgs)

def calculateDistanceMatrix(tableName1,tableName2):
	pointsA = pointList3DFromRT(tableName1)
	pointsB = pointList3DFromRT(tableName2)

	matrix = getDistanceMatrix(pointsA,pointsB)

	copyMatrixToImage2D(matrix,"Distance Matrix",len(matrix),len(matrix[0]))
	copyMatrixToRt2D(matrix,"Distance Matrix")


def calculateCumulatedNeighbors(tableName1,tableName2):
	xShift = [-15,16,1]
	yShift = [-15,16,1]
	zShift = [-4 ,5 ,1]

	cumulatedNeighbors, _ = getNeighborsWhileShifting(tableName1,tableName2,xShift,yShift,zShift,-1)
	copyMatrixToImage3D(cumulatedNeighbors,"Cumulated Neighbors Distance")

def countCloserNeighbors(tableName1,tableName2,threshold):
	if threshold != "":
		distanceThreshold = float(threshold)
	else:
		distanceThreshold = 1
	xShift = [-15,16,1]
	yShift = [-15,16,1]
	zShift = [-4 ,5 ,1]

	_, closeNeighborsCount = getNeighborsWhileShifting(tableName1,tableName2,xShift,yShift,zShift,distanceThreshold)
	copyMatrixToImage3D(closeNeighborsCount,"Neighbors Count with distance <"+str(distanceThreshold))


def getCloseCoordPairs(tableName1,tableName2,threshold):
	if threshold != "":
		distanceThreshold = float(threshold)
	else:
		distanceThreshold = 1
	
	pointsA = pointList3DFromRT(tableName1)
	pointsB = pointList3DFromRT(tableName2)

	neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB = calculateNearestNeighbors(pointsA,pointsB)
	
	pairs = getPairsCloserThan(distanceThreshold,neighborsDistancesA,idNearestA)+getPairsCloserThan(distanceThreshold,neighborsDistancesB,idNearestB,True)

	pairsCoords = getCoordsOfPairs(pointsA,pointsB,pairs)
	copyMatrixToRt2D(pairsCoords,"Pairs Coords",useFirstRowAsHeader=True)

def plotDistanceDistribution(tableName1,tableName2,nbCategories):
	if nbCategories != "":
		histogramSize = int(nbCategories)
	else:
		histogramSize = 256

	pointsA = pointList3DFromRT(tableName1)
	pointsB = pointList3DFromRT(tableName2)

	neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB = calculateNearestNeighbors(pointsA,pointsB)
	histo1 = makeHistogram(neighborsDistancesA,histogramSize)
	copyMatrixToRt2D(histo1,"Distance Distribution "+tableName1+">"+tableName2,useFirstRowAsHeader=True)
	histo2 = makeHistogram(neighborsDistancesB,histogramSize)
	copyMatrixToRt2D(histo2,"Distance Distribution "+tableName2+">"+tableName1,useFirstRowAsHeader=True)

def makeHistogram(neighborsDistances,nbCategories):
	count = [0] * nbCategories
	matrix = []
	matrix.append(("Values",))
	matrix.append(("Count",))
	matrix.append(("Probability",))
	minD,maxD = getMinMax(neighborsDistances)
	stepD = (maxD - minD)/nbCategories
	
	for d in neighborsDistances:
		correctI = (d - minD)/stepD
		count[int(correctI-1)]+=1

	for i in range(nbCategories):
		val = minD + stepD * i
		matrix[0]=(matrix[0]+(val,))
		matrix[1]=(matrix[1]+(count[i],))
		proba = float(count[i])/float(len(neighborsDistances))
		matrix[2]=(matrix[2]+(proba,))
	return matrix


def getMinMax(distribution):
	minD = distribution[0]
	maxD = distribution[0]
	for d in distribution:
		if d > maxD:
			maxD = d
		if d < minD:
			minD = d
	return minD,maxD

def getNeighborsWhileShifting(tableName1,tableName2,xShift,yShift,zShift,distanceThreshold):

	minModifierX = xShift[0]
	maxModifierX = xShift[1]
	stpModifierX = xShift[2]

	minModifierY = yShift[0]
	maxModifierY = yShift[1]
	stpModifierY = yShift[2]

	minModifierZ = zShift[0]
	maxModifierZ = zShift[1]
	stpModifierZ = zShift[2]

	cumulatedNeighbors = []
	closeNeighbors = []

	for modifierX in range(minModifierX,maxModifierX,stpModifierX):
		idX = (modifierX - minModifierX)/stpModifierX
		cumulatedNeighbors.append([])
		closeNeighbors.append([])
		for modifierY in range(minModifierY,maxModifierY,stpModifierY):
			idY = (modifierY - minModifierY)/stpModifierY
			cumulatedNeighbors[idX].append([])
			closeNeighbors[idX].append([])
			for modifierZ in range(minModifierZ,maxModifierZ,stpModifierZ):
				idZ = (modifierZ - minModifierZ)/stpModifierZ

				pointsA = pointList3DFromRT(tableName1,modifierX,modifierY,modifierZ)
				pointsB = pointList3DFromRT(tableName2)

				neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB = calculateNearestNeighbors(pointsA,pointsB)

				#Cumulated Neighbors
				distanceA = sum(neighborsDistancesA)
				distanceB = sum(neighborsDistancesB)

				cumulatedNearestDistance = (distanceA+distanceB)
				cumulatedNeighbors[idX][idY].append(cumulatedNearestDistance)

				#Count neighbor close to each other
				closeNeighbors[idX][idY].append(countNeighborCloserThan(distanceThreshold,neighborsDistancesA)+countNeighborCloserThan(distanceThreshold,neighborsDistancesB))

	return cumulatedNeighbors, closeNeighbors



def getCoordsOfPairs(pointsA,pointsB,pairs):
	coords = []
	coords.append(("xA",))
	coords.append(("yA",))
	coords.append(("zA",))
	coords.append(("xB",))
	coords.append(("yB",))
	coords.append(("zB",))
	coords.append(("Dist",))
	for indexP in range(len(pairs)):
		indexA = pairs[indexP][0]
		indexB = pairs[indexP][1]

		coordsA = pointsA[indexA].getPoint()
		coordsB = pointsB[indexB].getPoint()

		coords[0]=(coords[0]+(coordsA[0],))
		coords[1]=(coords[1]+(coordsA[1],))
		coords[2]=(coords[2]+(coordsA[2],))
		coords[3]=(coords[3]+(coordsB[0],))
		coords[4]=(coords[4]+(coordsB[1],))
		coords[5]=(coords[5]+(coordsB[2],))
		coords[6]=(coords[6]+(pairs[indexP][2],))

		#coords.append([coordsA[0],coordsA[1],coordsA[2],coordsB[0],coordsB[1],coordsB[2],pairs[indexP][2]])
	return coords


def countNeighborCloserThan(value,neighborsDistances):
	count = 0
	neighbors = sorted(neighborsDistances)
	
	for i in neighbors:
		if i < value:
			count+=1
		else:
			break 
	return count 

def getPairsCloserThan(threshold,neighborsDistances,idNearest,reverseOrder=False):
	pairs = []
	for i in range(len(neighborsDistances)):
		# IJ.log(str(neighborsDistances[i])+"<"+str(threshold)+" ?")
		if neighborsDistances[i] < threshold:
			# IJ.log("Small enough")
			if reverseOrder:
				pairs.append([idNearest[i],i,neighborsDistances[i]])
			else:	
				pairs.append([i,idNearest[i],neighborsDistances[i]])
	return pairs

def calculateNearestNeighbors(pointsA,pointsB):

	nearestDistancesA = [10000 for i in range(len(pointsA))]
	nearestDistancesB = [10000 for i in range(len(pointsB))]

	idNearestA = [-1 for i in range(len(pointsA))]
	idNearestB = [-1 for i in range(len(pointsB))]

	for indexA in range(len(pointsA)):
		for indexB in range(len(pointsB)):
			dist = getDistance(pointsA[indexA],pointsB[indexB])
			if nearestDistancesA[indexA]>dist :
				nearestDistancesA[indexA] = dist
				idNearestA[indexA] = indexB
				#IJ.log("Current closer iA A"+str(indexA)+" > B"+str(indexB)+" with dist = "+str(dist))
			if nearestDistancesB[indexB]>dist :
				nearestDistancesB[indexB] = dist 
				idNearestB[indexB] = indexA
				#IJ.log("Current closer iB B"+str(indexB)+" > A"+str(indexA)+" with dist = "+str(dist))
			#IJ.log("Distance between"+str(pointsA[indexA])+"and"+str(pointsB[indexB])+"="+str(dist))

	return nearestDistancesA, nearestDistancesB, idNearestA, idNearestB 


def getDistanceMatrix(pointsA,pointsB):
	matrix = []
	for indexA in range(len(pointsA)):
		matrix.append([])
		for indexB in range(len(pointsB)):
			dist = getDistance(pointsA[indexA],pointsB[indexB])
			matrix[indexA].append(dist)
	return matrix
		

def getDistance(pointA,pointB):
	dist = 0
	pA = pointA.getPoint()
	pB = pointB.getPoint()
	for dim in range(len(pA)):
		dist += (pA[dim]-pB[dim])**2
		#dist += math.fabs(pA[dim]-pB[dim])
	dist=math.sqrt(dist)
	return dist


def copyMatrixToRt2D(matrix,tableName="Results",sizeX=-1,sizeY=-1,useFirstRowAsHeader=False):
	if sizeX == -1:
		sizeX = len(matrix)
	if sizeY == -1:
		sizeY = len(matrix[0])

	table = ResultsTable()

	for indexX in range(sizeX):
		for indexY in range(sizeY):
			if useFirstRowAsHeader:
				if indexY == 0:
					continue
				table.setValue(str(matrix[indexX][0]),indexY-1,matrix[indexX][indexY])
			else:
				table.setValue(indexX,indexY,matrix[indexX][indexY])
	table.show(tableName)


def copyMatrixToImage2D(matrix,imageName,sizeX = -1,sizeY = -1):
	if sizeX == -1:
		sizeX = len(matrix)
	if sizeY == -1:
		sizeY = len(matrix[0])
	imp = ImageStack.create(sizeX, sizeY, 1,16)

	processor = imp.getProcessor(1)

	for indexX in range(sizeX):
		for indexY in range(sizeY):
			processor.set(indexX,indexY,int(matrix[indexX][indexY]))
	ImagePlus(imageName, imp).show()

def copyMatrixToImage3D(matrix,imageName,sizeX = -1,sizeY = -1,sizeZ = -1):
	if sizeX == -1:
		sizeX = len(matrix)
	if sizeY == -1:
		sizeY = len(matrix[0])
	if sizeZ == -1:
		sizeZ = len(matrix[0][0])

	imp = ImageStack.create(sizeX, sizeY, sizeZ,16)

	for indexZ in range(sizeZ):
		processor = imp.getProcessor(indexZ+1)

		for indexX in range(sizeX):
			for indexY in range(sizeY):
				processor.set(indexX,indexY,int(matrix[indexX][indexY][indexZ]))
	ImagePlus(imageName, imp).show()
	

			
def pointList3DFromRT(tableName,modifierX = 0,modifierY = 0,modifierZ = 0, XColumn='X (microns)', YColumn='Y (microns)', ZColumn='Z (microns)'):
	win = WindowManager.getWindow(tableName)
	rt = win.getResultsTable()

	X = rt.getColumn(rt.getColumnIndex(XColumn))
	Y = rt.getColumn(rt.getColumnIndex(YColumn))
	Z = rt.getColumn(rt.getColumnIndex(ZColumn))
	dplist = []
	for x, y, z in zip(X, Y, Z):
		array = []
		array.append(x+modifierX)
		array.append(y+modifierY)
		array.append(z+modifierZ)
		jArray = jarray.array(array, 'd')
		dp = DoublePoint(jArray)
		dplist.append(dp)
	return dplist



XColumn = 'X'
YColumn = 'Y'
ZColumn = 'Z'
if 'getArgument' in globals():
	if not hasattr(zip, '__call__'):
		del zip 					# the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
	parameter = getArgument()
	args = parameter.split(",")
	action = args[0].split("=")[1]
	tableA = args[1].split("=")[1]
	tableB = args[2].split("=")[1]
	moreArgs = args[3].split("=")[1]
main(action,tableA, tableB, moreArgs)