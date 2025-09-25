import math
from ij import IJ
from ij.measure import ResultsTable
from inra.ijpb.label.LabelImages import keepLabels

up_to = 2
bottom_first = True

# Creating the histogram of spots repartition on the Z axis
rt    = ResultsTable.getActiveTable()
vals  = rt.getColumn("Centroid.Z")
histo = [0 for _ in range(1 + int(math.ceil(max(vals))))]

for val in vals:
	histo[int(round(val))] += 1

# Sorting slices by the number of spots they contain
sliced = [(v, i) for i, v in enumerate(histo)]
sliced = list(reversed(sorted(sliced)))
n_spots, last = sliced[up_to-1]
last += 1

to_keep = []
for l in range(len(vals)):
	lbl = int(rt.getLabel(l))
	val = rt.getValue('Centroid.Z', l)
	if val > last:
		to_keep.append(lbl)

print("Keeping " + str(len(to_keep)) + " items from " + str(len(vals)))

img = IJ.getImage()
IJ.run("Select Label(s)", "label(s)="+",".join([str(l) for l in to_keep]))




