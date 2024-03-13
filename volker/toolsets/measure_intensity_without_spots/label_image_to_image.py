from ij import IJ
from ij import ImagePlus

image = IJ.getImage()
title = image.getTitle()
overlay = image.getOverlay()
labelOutlinesImageRoi = overlay.get(0)
processor = labelOutlinesImageRoi.getProcessor()
labels = ImagePlus("labels of " + title, processor)
labels.show()