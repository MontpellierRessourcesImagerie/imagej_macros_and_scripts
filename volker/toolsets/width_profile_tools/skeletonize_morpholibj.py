from ij import IJ
from inra.ijpb.binary.skeleton import ImageJSkeleton
from inra.ijpb.label import LabelImages

image = IJ.getImage()
imageCopy = image.duplicate()
skeletonizer = ImageJSkeleton()
ip = skeletonizer.process(image.getProcessor())
dMap = LabelImages.distanceMap(image.getProcessor())

image.setProcessor(ip)
imageCopy.setProcessor(dMap)
imageCopy.show()