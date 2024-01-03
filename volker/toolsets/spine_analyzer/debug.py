from ij import IJ
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.neurons import Dendrite
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


image = IJ.getImage()
spines = InstanceSegmentation(image)
dendrites = Dendrites(spines)
dendritesByTime = dendrites.getByTime()
values = [str(value) for value in dendritesByTime]
out = "\n".join(values)
print(out)