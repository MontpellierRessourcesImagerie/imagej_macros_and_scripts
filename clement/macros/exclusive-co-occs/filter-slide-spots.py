import math
from ij import IJ
from ij.measure import ResultsTable
from inra.ijpb.label.LabelImages import keepLabels, findAllLabels, remapLabels
from inra.ijpb.measure.region3d import Centroid3D

# Of how many slices should we remove spots starting from the most populated one?
up_to = 3

# ------------------------------------------------------------------

img = IJ.getImage()
calib = img.getCalibration()
c3d = Centroid3D()

# Creating the histogram of spots repartition on the Z axis
d_clb = calib.copy()
d_clb.pixelWidth  = 1
d_clb.pixelHeight = 1
d_clb.pixelDepth  = 1
d_clb.setUnit("pixel")

all_lbls = findAllLabels(img)
pts = c3d.analyzeRegions(img.getStack(), all_lbls, d_clb)
vals = [int(round(p.getZ())) for p in pts]

histo = [0 for _ in range(1 + int(math.ceil(max(vals))))]
for val in vals:
	histo[int(round(val))] += 1

# Sorting slices by the number of spots they contain
sliced = [(v, i) for i, v in enumerate(histo)]
sliced = list(sorted(sliced))
n_spots, last = sliced[-1]
last += up_to
print("Removing all spots below slice " + str(last))

to_keep = []
for lbl, pt in zip(all_lbls, pts):
	if pt.getZ() > last:
		to_keep.append(lbl)

print("Keeping " + str(len(to_keep)) + " items from " + str(len(vals)))

res_img = keepLabels(img, to_keep)
remapLabels(res_img)
res_img.show()