from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation

segmentation = DendriteGenerator().next()
segmentation.show()
segmentation.trackLabels()
