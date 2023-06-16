from ij import IJ
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation

def main():
    image = IJ.getImage()
    spines = InstanceSegmentation(image)
    roi = image.getRoi()
    if not roi:
        return
    currentC, currentZ, currentT = image.getC(), image.getZ(), image.getT()
    dendrites = Dendrites(spines)
    dendrites.add(roi, currentT)


main()