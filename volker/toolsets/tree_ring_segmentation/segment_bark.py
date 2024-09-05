from ij import IJ
from ij import ImagePlus
from ij.gui import Overlay
from ij.gui import PolygonRoi
from ij.gui import Roi
from ij.plugin import Duplicator
from ij.plugin import Scaler
from ij.process import ImageConverter
from ij.plugin.filter import ThresholdToSelection
from ij.plugin import RoiEnlarger
from sc.fiji.colourDeconvolution import StainMatrix
from inra.ijpb.binary import BinaryImages
from inra.ijpb.morphology import Reconstruction
from inra.ijpb.morphology.filter import Opening
from inra.ijpb.morphology.filter import Closing
from inra.ijpb.morphology import Strel
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling
from inra.ijpb.measure.region2d import BoundingBox
from inra.ijpb.label.select import LabelSizeFiltering
from inra.ijpb.label.select import RelationalOperator
from inra.ijpb.label import LabelImages
from inra.ijpb.morphology.directional import DirectionalFilter

componentsLabeling = FloodFillComponentsLabeling(4, 16)
directionalFilter = DirectionalFilter(DirectionalFilter.Type.MAX, DirectionalFilter.Operation.MEDIAN, 40, 32)

image = IJ.getImage()
width, height, nChannels, nSlices, nFrames = image.getDimensions() 
imp = image.crop("1-1")
IJ.run(imp, "HSB Stack", "");
imp = imp.crop("3-3")
imp = imp.resize(width // 8, height // 8, "bilinear");
imp.setAutoThreshold("Default");
IJ.run(imp, "Convert to Mask", "");
IJ.run(imp, "Despeckle", "");
ip = directionalFilter.process(imp.getProcessor())
'''IJ.run(imp, "Invert", "");
labelsProcessor = componentsLabeling.computeLabels(imp.getProcessor())
LabelImages.removeBorderLabels(labelsProcessor)
maskProcessor = BinaryImages.keepLargestRegion(labelsProcessor)'''
imp = ImagePlus("work", ip)
imp.show()
