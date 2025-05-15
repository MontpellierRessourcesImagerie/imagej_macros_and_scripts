from ij import IJ, ImagePlus
from ij.measure import ResultsTable
import math
from java.awt import Color

def distance(points):
	p1, p2 = points
	return math.sqrt((p2[0] - p1[0])**2 + (p2[1] - p1[1])**2)

t_name = "Branch information"

dist_threshold = 30
imIn = IJ.getImage()
print(imIn)

branches = []
measures = ResultsTable.getActiveTable()
for i in range(0, measures.size()):
	x1 = measures.getValue("V1 x", i)
	x2 = measures.getValue("V2 x", i)
	y1 = measures.getValue("V1 y", i)
	y2 = measures.getValue("V2 y", i)
	branches.append([(x1, y1), (x2, y2)])
	
# Pairs of points that should get linked.
candidates = []
for index, pts1 in enumerate(branches):
	for j, pts2 in enumerate(branches):
		if index == j:
			continue
		for p1 in pts1:
			for p2 in pts2:
				if p1 == p2:
					continue
				d_sep = distance([p1, p2])
				if d_sep < dist_threshold:
					candidates.append((p1, p2))
white = Color(255, 255, 255)

for p1, p2 in candidates:
	imIn.getProcessor().setColor(white)
	imIn.getProcessor().drawLine(int(p1[0]), int(p1[1]), int(p2[0]), int(p2[1]))
					
print(candidates)