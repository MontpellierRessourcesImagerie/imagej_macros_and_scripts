from ij import IJ
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation
from fr.cnrs.mri.cialib.neurons import Dendrites



URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine_Analyzer"



def main():
    image = IJ.getImage()
    dendrites = Dendrites(InstanceSegmentation(image))
    dendrites.attachSpinesToClosestDendrite()



main()