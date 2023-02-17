from ij import IJ
from ij.process import ImageConverter
from  ij.process import StackStatistics
RADIUS = 7
SIGMA = 0.45
DYNAMIC = 5000
CONNECTIVITY = 6

image = IJ.getImage()
IJ.run(image, "Subtract Background...", "rolling={} stack".format(RADIUS))
IJ.run("FeatureJ Options", "isotropic progress log")
IJ.run("FeatureJ Laplacian", "compute smoothing={}".format(SIGMA))
spotImage = IJ.getImage()
IJ.run(spotImage, "Invert", "stack")
ImageConverter.setDoScaling(True)
IJ.run(spotImage, "16-bit", "")
IJ.run("Extended Min & Max 3D", "operation=[Extended Maxima] dynamic={} connectivity={}".format(DYNAMIC, CONNECTIVITY))
IJ.run("Connected Components Labeling", "connectivity=6 type=float");
labelsImage = IJ.getImage()
stats = StackStatistics(labelsImage)
numberOfSpots = stats.max
print(numberOfSpots)