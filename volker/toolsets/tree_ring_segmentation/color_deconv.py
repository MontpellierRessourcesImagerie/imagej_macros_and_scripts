from ij import IJ
from ij import ImagePlus
from sc.fiji.colourDeconvolution import StainMatrix

vectors = (0.7372839, 0.63264143, 0.23701741,
           0.91958255, 0.35537627, 0.16755785,
           0.69067574, 0.64728355, 0.3224746)
image = IJ.getImage()
sm = StainMatrix()
sm.init("wood", *vectors)
stack = sm.compute(False, True, image);      
result = ImagePlus(image.getTitle() + "-(Colour_2)", stack[1])
result.show()
                