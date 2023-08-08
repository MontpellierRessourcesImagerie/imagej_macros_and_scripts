from ij import IJ
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine_Analyzer"
SAVE_OPTIONS = True


def main():   
    image = IJ.getImage()
    segmentation = InstanceSegmentation(image)
    dendrites = Dendrites(segmentation)
    dendrites.measure()
    table = dendrites.reportSpines()
    table.show("Spine Measurements")
    table = dendrites.reportDendrites()
    table.show("Dendrite Measurements")
    
    
main()