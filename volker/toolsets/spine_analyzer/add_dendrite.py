from ij import IJ
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.neurons import Dendrite
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation

def main():
    image = IJ.getImage()
    spines = InstanceSegmentation(image)
    roi = image.getRoi()
    if not roi:
        return
    currentC, currentZ, currentT = image.getC(), image.getZ(), image.getT()
    roi.setPosition(0, 0, currentT)
    dendrites = Dendrites(spines)
    dendrites.addElement(Dendrite(roi))
    image.killRoi()
    

main()