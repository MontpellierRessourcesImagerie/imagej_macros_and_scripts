from inra.ijpb.label.LabelImages import (
    removeLabels,
    remapLabels
)
from ij import IJ

img = IJ.getImage()
roi = img.getRoi()

removeLabels(img, roi, False)
remapLabels(img)

img.updateImage()
img.updateAndRepaintWindow()
img.draw()
img.show()
img.setRoi(None)