from ij import IJ
from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator

segmentation = DendriteGenerator().next()
segmentation.show()
