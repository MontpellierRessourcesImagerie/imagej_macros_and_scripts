from ij import IJ
from ij import ImagePlus
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation

def main():
    image = IJ.getImage()
    spines = InstanceSegmentation(image)    
    currentC, currentZ, currentT = image.getC(), image.getZ(), image.getT()
    label = int(IJ.getNumber("Find spine nr.:", 1))
    spines.findLabel(label, currentT)
    

main()