from inra.ijpb.label.LabelImages import mergeLabels
from ij.plugin.frame import RoiManager
from ij import IJ

rm = RoiManager.getInstance()
rois = rm.getSelectedRoisAsArray()
img = IJ.getImage()

for i in range(len(rois)):
	img.setRoi(rois[i])
	roi = img.getRoi()
	mergeLabels(img, roi, False)

rm.reset()
img.updateImage()
img.updateAndRepaintWindow()
img.draw()
img.show()
img.setRoi(None)