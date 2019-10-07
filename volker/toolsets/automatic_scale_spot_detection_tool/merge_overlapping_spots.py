##################################################################################
#
# Merge all ROIS that overlap more than a given percentage. 
# The ROIS are expected to be circles.
#
# Expects the ROIS in the roi-manager and the measurements X, Y (centroid) and Feret
# (diameter) in the results-table.
#
# (c) 2019, INSERM
# written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr), Biocampus Montpellier
#
##################################################################################
import math
from ij.measure import ResultsTable
from ij.plugin.frame import RoiManager
from collections import deque

MIN_OVERLAP = 50	# Minimum overlap in percent for two ROIS to be merged.

def main(minOverlap):
	rt = ResultsTable.getResultsTable()
	X = rt.getColumn(ResultsTable.X_CENTROID)
	Y = rt.getColumn(ResultsTable.Y_CENTROID)
	D = rt.getColumn(ResultsTable.FERET)
	width = len(X)
	height = width - 1

	matrix = createGraph(X, Y, D, minOverlap)
	graph = matrix_to_list(matrix)
	components = findConnectedComponents(graph)
	mergeRois(components)

##################################################################################
#
# Merge all ROIS that are in the same component
#
##################################################################################
def mergeRois(components):
	RoiManager()
	roiManager = RoiManager.getRoiManager()
	toBeDeleted = []
	for component in components:
		if len(component)>1:
			roiManager.setSelectedIndexes(component)
			roiManager.runCommand("Combine")
			roiManager.runCommand("Update")
			toBeDeleted = toBeDeleted + component[1:]
	if len(toBeDeleted)>0:
		roiManager.setSelectedIndexes(toBeDeleted)
		roiManager.runCommand("Delete")

##################################################################################
#
# Find the connected components in an undirected graph given as an adjacency-list.
#
# from https://stackoverflow.com/questions/10301000/python-connected-components
# by https://stackoverflow.com/users/244297/eugene-yarmash
#
# example of a result: 
# 
# A generator for 
#
# 	[[0, 7, 8, 4, 5, 3, 1], [2], [6], [9]]
#
##################################################################################

def findConnectedComponents(graph):
    seen = set()
    for root in range(len(graph)):
        if root not in seen:
            seen.add(root)
            component = []
            queue = deque([root])

            while queue:
                node = queue.popleft()
                component.append(node)
                for neighbor in graph[node]:
                    if neighbor not in seen:
                        seen.add(neighbor)
                        queue.append(neighbor)
            yield component

##################################################################################
#
# Convert the adjecency-matrix to an adjacency list. 
# From https://stackoverflow.com/questions/43375515/breadth-first-search-with-adjacency-matrix
# by https://stackoverflow.com/users/3829814/c-wilson
#
# example of a result:
#
# {0: [7, 8], 1: [3, 4], 2: [], 3: [1, 8], 4: [1, 7], 5: [7], 6: [], 7: [0, 4, 5], 8: [0, 3], 9: []}
#
##################################################################################

def matrix_to_list(matrix):
    graph = {}
    for i, node in enumerate(matrix):
        adj = []
        for j, connected in enumerate(node):
            if connected:
                adj.append(j)
        graph[i] = adj
    return graph

##################################################################################
# 
# Create a graph as an adjecency matrix
# 
# Two Rois are connected if their overlap is 
# more than minOverlap
#
# X, Y 			: The coordinates of the centers of the ROIS
# D 			: A list containing the diameters of the ROIS
# minOverlap	: The minimal overlap for two rois to be considered as neighbors
#
##################################################################################
def createGraph(X, Y, D, minOverlap):
	width = len(X)
	height = width - 1
	matrix = [[0 for x in range(width)] for y in range(width)] 
	
	for l in range(0,height):
		for c in range(l+1,width):
			x1 = X[l]
			y1 = Y[l]
			d1 = D[l]
			r1 = d1 / 2.0
			x2 = X[c]
			y2 = Y[c]
			d2 = D[c]
			r2 = d2 / 2.0
			delta_x = x1 - x2
			delta_y = y1 - y2
			distance = math.sqrt((delta_x * delta_x) + (delta_y*delta_y))
			t = (r1+r2)-distance
			p1 = 0
			p2 = 0
			if t>0:
				p1 = (100 * t) / d1
				p2 = (100 * t) / d2 
				if p1<minOverlap and p2<minOverlap:
					p1 = 0
					p2 = 0
				else: 
					p1 = 1
					p2 = 1
			matrix[l][c] = p1
			matrix[c][l] = p2
	return matrix
	
minOverlap = MIN_OVERLAP
if 'getArgument' in globals():
	parameter = getArgument()
	args = parameter.split(",")
	minOverlap = int(args[0].split("=")[1])
main(minOverlap)
