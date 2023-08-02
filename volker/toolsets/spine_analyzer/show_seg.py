from ij import IJ
from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator
from fr.cnrs.mri.cialib.neurons import Dendrites 
from fr.cnrs.mri.cialib.neurons import Dendrite 

generator = DendriteGenerator()
segmentation = generator.next()
segmentation.trackLabels()
segmentation.show()
rois = generator.getROIs()
dendrites = Dendrites(segmentation)

width, height, nChannels, nSlices, nFrames = segmentation.image.getDimensions()

offset = 0;
for frame in range(1, nFrames+1):
    for roi in rois:
        roi.setLocation(roi.bounds.x + offset, roi.bounds.y + offset)
        roi.setPosition(0, 0, frame)
        dendrites.addElement(Dendrite(roi))    
  
dendrites.track()

# dendrites.attachSpinesToClosestDendrite()
# for element in dendrites.elements.values():
#    print(element.getSpines())

dendritesByTime = dendrites.getByTime()
d2 = dendritesByTime[2][1]
print("parent", d2.parent)