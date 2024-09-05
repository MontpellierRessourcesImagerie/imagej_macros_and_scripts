from ij import IJ
from ij import ImagePlus
from sc.fiji.colourDeconvolution import StainMatrix

CHANNEL = 3
# vectors = (0.7372839, 0.63264143, 0.23701741,
#           0.91958255, 0.35537627, 0.16755785,
#           0.69067574, 0.64728355, 0.3224746)

vectors = (0.7898954, 0.5587874, 0.25262988,
           0.5932292, 0.7353205, 0.3276933,
           0.57844025, 0.5767322, 0.5768768)

image = IJ.getImage()
sm = StainMatrix()
sm.init("wood", *vectors)
stack = sm.compute(False, True, image);      
result = ImagePlus(image.getTitle() + "-(Colour_" + str(CHANNEL) + ")", stack[CHANNEL-1])
result.show()
                