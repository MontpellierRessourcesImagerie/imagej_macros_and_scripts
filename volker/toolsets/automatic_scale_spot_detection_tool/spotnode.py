'''
SpotNode is a datastructure to represent the spots in the scale-space of an image.
'''
import math
from ij import IJ
from ij.measure import ResultsTable
from ij.plugin.frame import RoiManager
from ij.gui import OvalRoi, Overlay

def flatten(l): 
	return flatten(l[0]) + (flatten(l[1:]) if len(l) > 1 else []) if type(l) is list else [l]

class SpotNode(object):
	'''
	A spot-node is a node in a tree in which each
	node represents a spot in the scale-space image.
	'''
	
	def __init__(self, spotID, centerX, centerY, zSlice, radius, value=float('nan')):
		self.spotID = spotID
		self.x = centerX
		self.y = centerY
		self.z = zSlice
		self.radius = radius
		self.parent = None
		self.children = []
		self.value = value
		self.minima = []
		
	@classmethod
	def fromImageAndResultsTable(cls, image, rt):
		width = image.getWidth()
		height = image.getHeight()
		centerX = width / 2.0
		centerY = height / 2.0
		radius = math.sqrt(centerX * centerX + centerY * centerY)
		X = rt.getColumn(ResultsTable.X_CENTROID)[::-1]
		Y = rt.getColumn(ResultsTable.Y_CENTROID)[::-1]
		Z = rt.getColumn(ResultsTable.SLICE)[::-1]
		D = rt.getColumn(ResultsTable.FERET)[::-1]
		V = rt.getColumn(ResultsTable.MIN)[::-1]
		scaleSpaceSpotsTree = SpotNode(0, centerX, centerY, Z[0]+1, radius)
		spotID = len(X)
		for x, y, z, d, v in zip(X, Y, Z, D, V):
			scaleSpaceSpotsTree.addChild(SpotNode(spotID, x, y, z, d/2.0, v))
			spotID -= 1
		return scaleSpaceSpotsTree
	 
	def isRoot(self): 
		return not self.parent
		
	def includes(self, aSpotNode):
		'''
		Answer true if the center of aSpotNode falls within the radius of this spot.
		'''
		deltaX = self.x-aSpotNode.x
		deltaY = self.y-aSpotNode.y
		dist = math.sqrt((deltaX * deltaX) + (deltaY*deltaY))
		return dist<=self.radius

	def addChild(self, aSpotNode):
		if not self.includes(aSpotNode):
			return False
		includedInChild = False
		for child in self.children:
			includedInChild = includedInChild or child.addChild(aSpotNode)
		if not includedInChild:
			self.children.append(aSpotNode) 
			aSpotNode.parent = self
			return True
		return includedInChild

	def asList(self):
		tail = self.__getSubtreeAsList()
		res = [self]
		res.append(tail)
		return res

	def __getSubtreeAsList(self):
		result = []
		for child in self.children:
			result.append(child)
			sublist = child.__getSubtreeAsList()
			if sublist:
				result.append(sublist)
		return result

	def isIsolated(self):
		result = (self.parent.isRoot() or self.parent.z != self.z+1)
		zLevelsOfChildren = [spot.z for spot in self.children]
		result = result and self.z-1 not in zLevelsOfChildren
		return result
		
	def getIsolatedSpots(self):
		spotList = flatten(self.__getSubtreeAsList())
		result = [spot for spot in spotList if spot.isIsolated()]
		return result

	def remove(self):
		if not self.parent:
			return
		self.parent.children.remove(self)
		for child in self.children:
			self.parent.addChild(child)
		self.parent = None

	def flatten(self):
		return flatten(self.asList())

	def colorizeRoisBySubtree(self):
		roiManager = RoiManager.getRoiManager()
		colors = {0 : "red", 1 : "green", 2 : "blue", 3 : "yellow", 4 : "magenta", 5 : "cyan", 6 : "orange", 7 : "black", 8 : "white"}
		currentColor = 0
		for subtree in self.children:
			for spot in subtree.flatten():
				roiManager.select(spot.spotID - 1)
				roiManager.runCommand("Set Color", colors[currentColor])
			currentColor = (currentColor + 1) % len(colors)

	def getSpot(self, spotID):
		return next((spot for spot in self.flatten() if spot.spotID==spotID), None)

	def getSubtreeMinimumValue(self):
		return sum([node.value for node in self.minima]) 

	def calculateSubtreeMinima(self):
		if not self.children:
			self.minima = [self]
		else:
			if not self.children[0].minima:
				for child in self.children:
					child.calculateSubtreeMinima()
		if self.value < sum([child.getSubtreeMinimumValue() for child in self.children]):
			self.minima = [self]
		else:
			self.minima = []
			for child in self.children:
				self.minima = self.minima + child.minima

	def drawMinima(self):
		IJ.run("Remove Overlay", "")
		self.calculateSubtreeMinima()
		overlay = Overlay()			
		for child in self.children:
			for spot in child.minima:
				roi = OvalRoi(spot.x-spot.radius, spot.y-spot.radius, 2*spot.radius, 2*spot.radius)	
				overlay.add(roi)
		IJ.getImage().setOverlay(overlay)
		
	def __repr__(self):
		'''
		Print the node.
		'''
		res = "SpotNode({}, {}, {}, {}, {}, {})".format(self.spotID, self.x, self.y, self.z, self.radius, self.value)
		return res
	