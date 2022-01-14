import math
import jarray
from ij import WindowManager, IJ, ImageStack, ImagePlus
from ij.measure import ResultsTable

from org.apache.commons.math3.ml.clustering import DoublePoint
from itertools import groupby
from operator import itemgetter

def main(action,tableName1,tableName2,moreArgs):
	IJ.log(action+">("+tableName1+","+tableName2+","+moreArgs+")")
	
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

	if action == "GetNearestNeighbors":
		getNearestNeighbors(tableName1,tableName2)

	if action == "GetMeanDistances":
		getMeanDistances(tableName1,tableName2)

	if action == "CalculateRipley":
		calculateRipley(tableName1,tableName2,moreArgs)
	IJ.log("Execution Finished")

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
	IJ.log("Entering Get Close Pairs")
	if threshold != "":
		distanceThreshold = float(threshold)
	else:
		distanceThreshold = 1
	
	pointsA = pointList3DFromRT(tableName1)
	pointsB = pointList3DFromRT(tableName2)

	neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB =  calculateNearestNeighbors(pointsA,pointsB)

	pairs = getPairsCloserThan(distanceThreshold,neighborsDistancesA,idNearestA)+getPairsCloserThan(distanceThreshold,neighborsDistancesB,idNearestB,True)

	pairsCoords = getCoordsOfPairs(pointsA,pointsB,pairs)
	copyMatrixToRt2D(pairsCoords,"Pairs Coords",useFirstRowAsHeader=True)


def getNearestNeighbors(tableName1,tableName2):

	neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB = calculateNearestNeighborsFromRT(tableName1,tableName2)

	nearestNeighborsA = []
	nearestNeighborsA.append(("Distance",))
	nearestNeighborsA.append(("ID Neighbor",))
	nearestNeighborsA[0]=(nearestNeighborsA[0]+tuple(neighborsDistancesA))
	nearestNeighborsA[1]=(nearestNeighborsA[1]+tuple(idNearestA))
	copyMatrixToRt2D(nearestNeighborsA,"Nearest Neighbors "+tableName1+">"+tableName2,useFirstRowAsHeader=True)

	nearestNeighborsB = []
	nearestNeighborsB.append(("Distance",))
	nearestNeighborsB.append(("ID Neighbor",))
	nearestNeighborsB[0]=(nearestNeighborsB[0]+tuple(neighborsDistancesB))
	nearestNeighborsB[1]=(nearestNeighborsB[1]+tuple(idNearestB))
	copyMatrixToRt2D(nearestNeighborsB,"Nearest Neighbors "+tableName2+">"+tableName1,useFirstRowAsHeader=True)

	return nearestNeighborsA,nearestNeighborsB


def calculateNearestNeighborsFromRT(tableName1,tableName2):
	pointsA = pointList3DFromRT(tableName1)
	pointsB = pointList3DFromRT(tableName2)

	return calculateNearestNeighbors(pointsA,pointsB)

def getMeanDistances(tableName1,tableName2):
	neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB = calculateNearestNeighborsFromRT(tableName1,tableName2)

	minA, maxA, sumA, meanA, varianceA, stdDevA = getStatistics(neighborsDistancesA)
	IJ.log("Statistics Distances from "+tableName1+">"+tableName2)
	IJ.log("Min ="+str(minA))
	IJ.log("Max ="+str(maxA))
	IJ.log("Sum ="+str(sumA))
	IJ.log("Mean ="+str(meanA))
	IJ.log("Variance ="+str(varianceA))
	IJ.log("Std Dev ="+str(stdDevA))
	IJ.log(" ")

	minA, maxA, sumA, meanA, varianceA, stdDevA = getStatistics(neighborsDistancesB)
	IJ.log("Statistics Distances from "+tableName2+">"+tableName1)
	IJ.log("Min ="+str(minA))
	IJ.log("Max ="+str(maxA))
	IJ.log("Sum ="+str(sumA))
	IJ.log("Mean ="+str(meanA))
	IJ.log("Variance ="+str(varianceA))
	IJ.log("Std Dev ="+str(stdDevA))

def getStatistics(dataset):
	min = dataset[0]
	max = dataset[0]
	sum = 0

	for d in dataset:
		sum += d
		if d < min:
			min = d
		if d > max:
			max = d

	mean = sum / len(dataset)

	sumOfSquare = 0
	for d in dataset:
		sumOfSquare += (d - mean)**2

	variance = sumOfSquare / len(dataset)-1
	stdDev = math.sqrt(variance)

	return min, max, sum, mean, variance, stdDev


def plotDistanceDistribution(tableName1,tableName2,nbCategories):
	if nbCategories != "":
		histogramSize = int(nbCategories)
	else:
		histogramSize = 256
	
	neighborsDistancesA, neighborsDistancesB, idNearestA, idNearestB = calculateNearestNeighborsFromRT(tableName1,tableName2)
	
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
	# X = rt.getColumn(XColumn)
	# Y = rt.getColumn(YColumn)
	# Z = rt.getColumn(ZColumn)
	
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


def calculateRipley(tableName1,tableName2,volume,radiusMax=2,nbSteps=20):
	pointsA = pointList3DFromRT(tableName1)
	pointsB = pointList3DFromRT(tableName2)
	table = ResultsTable()
	step = float(radiusMax) / nbSteps
	idx = 0
	IJ.log("Radius Max = "+str(radiusMax))
	IJ.log("Step = "+str(step))
	nbPoints = len(pointsA+pointsB)
	density = float(nbPoints)/float(volume)
	print(str(density))
	#density = getDensity(pointsA,pointsB)
	#nbPoints = len(pointsA+pointsB)
	
	for i in range(1,nbSteps+1):
		radius = i*step
		table.setValue("Radius",idx,radius)
		
		count = countPointsCloser(pointsA,pointsB,radius)
		table.setValue("Count",idx,count)

		K = count/(density*nbPoints)
		table.setValue("Ripley's K",idx,K)

		expected = (4/3) * math.pi * radius * radius * radius
		table.setValue("Expected Ripley's K",idx,expected)
		
		table.setValue("Ripley's L",idx,pow(K/math.pi,1./3)-radius)
		idx = idx+1
	table.show("Ripley's Table")

def getDensity(pointsA,pointsB):
	minX = None
	minY = None
	minZ = None
	maxX = None
	maxY = None
	maxZ = None
	initialised = False
	nbPoints = len(pointsA+pointsB)
	for p in pointsA+pointsB:
		point = p.getPoint()
		if(not initialised):
			minX = point[0]
			maxX = point[0]
			minY = point[1]
			maxY = point[1]
			minZ = point[2]
			maxZ = point[2]
			initialised = True
			continue
		if(point[0]>maxX):
			maxX = point[0]
		elif (point[0]<minX):
			minX = point[0]
		if(point[1]>maxY):
			maxY = point[1]
		elif (point[1]<minY):
			minY = point[1]
		if(point[2]>maxZ):
			maxZ = point[2]
		elif (point[2]<minZ):
			minZ = point[2]
	IJ.log("Bounding Box: ("+str(minX)+","+str(minY)+","+str(minZ)+"),("+str(maxX)+","+str(maxY)+","+str(maxZ)+")")
	area = (maxX-minX)*(maxY-minY)*(maxZ-minZ)
	density = area/nbPoints
	return density

def countPointsCloser(pointsA,pointsB,radius):
	count = 0
	for indexA in range(len(pointsA)):
		for indexB in range(len(pointsB)):
			dist = getDistance(pointsA[indexA],pointsB[indexB])
			if(dist < radius):
				count = count + 1;
	return count



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
