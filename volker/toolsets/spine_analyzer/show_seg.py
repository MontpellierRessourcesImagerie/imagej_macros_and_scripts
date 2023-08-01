from ij import IJ
from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator
from fr.cnrs.mri.cialib.neurons import Dendrites 
from fr.cnrs.mri.cialib.neurons import Dendrite 

generator = DendriteGenerator()
segmentation = generator.next()
segmentation.show()
rois = generator.getROIs()
dendrites = Dendrites(segmentation)

width, height, nChannels, nSlices, nFrames = segmentation.image.getDimensions()

offset = 0;
for frame in range(1, nFrames+1):
    for roi in rois:
        roi.setLocation(roi.bounds.x + offset, roi.bounds.y + offset)
        dendrites.addElement(Dendrite(roi), frame)    
dendrites.track()    
    
dendrites.attachSpinesToClosestDendrite()
for element in dendrites.elements.values():
    print(element.getSpines())