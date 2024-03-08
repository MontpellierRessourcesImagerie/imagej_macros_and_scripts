from ij import IJ
from fr.cnrs.mri.cialib.quantification import StainingAnalyzer

image = IJ.getImage()
analyzer = StainingAnalyzer(image, 1, 2)
analyzer.createNucleiWithoutSpotsMask()

analyzer.nucleiMask.show()
analyzer.spotsMask.show()
analyzer.nucleiWithoutSpotsMask.show()
