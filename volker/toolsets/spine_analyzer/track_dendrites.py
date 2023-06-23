from ij import IJ
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation

image = IJ.getImage()
segmentation = InstanceSegmentation(image)
dendrites = Dendrites(segmentation)
dendrites.setMaxDistanceForTracking(10)

dendrites.track()
