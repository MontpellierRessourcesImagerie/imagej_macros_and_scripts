from ij import IJ
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


def main():
    image = IJ.getImage()
    spines = InstanceSegmentation(image)  
    maxLabel = spines.nextLabel-1
    message = "max. label = " +  str(maxLabel)
    IJ.showStatus(message)
    IJ.log(message)


main()
    