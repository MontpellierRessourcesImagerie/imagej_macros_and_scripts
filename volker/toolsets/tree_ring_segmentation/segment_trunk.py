from ij import IJ
from ij.gui import Overlay
from ij.gui import PolygonRoi
from ij.gui import Roi
from ij.plugin import Duplicator
from ij.plugin import Scaler
from ij.process import ImageConverter
from ij.plugin.filter import ThresholdToSelection
from ij.plugin import RoiEnlarger
from inra.ijpb.binary import BinaryImages
from inra.ijpb.morphology import Reconstruction
from inra.ijpb.morphology.filter import Opening
from inra.ijpb.morphology import Strel


SIGMA = 2;
OPENING_RADIUS = 16
SCALE_FACTOR = 8
INTERPOLATION_INTERVAL = 100


class TreeRingAnalyzer:
    
    def __init__(self, image, sigma=2, openingRadius=16, scaleFactor=8, 
                       strokeWidth=8, interpolationInterval=100):
        self.image = image
        self.sigma = sigma
        self.openingRadius = openingRadius
        self.scaleFactor = scaleFactor
        self.strokeWidth = strokeWidth
        self.strel = Strel.Shape.DISK.fromRadius(self.openingRadius);       
        self.interpolationInterval = interpolationInterval
            
    def segmentTrunk(self):
        self.image.setRoi(None)
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()        
        image = Duplicator().run(self.image, 1, nChannels, 1, nSlices, 1, nFrames)
        ImageConverter(image).convertToGray8()
        image = Scaler.resize(image, width/self.scaleFactor, height/self.scaleFactor, 1, 'bilinear')
        image.getProcessor().blurGaussian(self.sigma)
        image.getProcessor().setAutoThreshold("Default")
        ip = image.getProcessor().createMask()
        ip = BinaryImages.keepLargestRegion(ip)
        ip = Reconstruction.fillHoles(ip)
        ip = Opening(self.strel).process(ip)
        image.setProcessor(ip)
        image = Scaler.resize(image, width, height, 1, 'bilinear')
        image.getProcessor().setThreshold(1, 255)
        roi = ThresholdToSelection.run(image)
        image.close()
        roi = RoiEnlarger.enlarge(roi, -self.openingRadius/2)
        poly = roi.getInterpolatedPolygon(-100, True)
        roi = PolygonRoi(poly, Roi.POLYGON)
        roi.setName("bark - outer border")
        roi.setStrokeWidth(self.strokeWidth)
        overlay = self.image.getOverlay()
        if not overlay:
            overlay = Overlay()
        overlay.add(roi)
        self.image.setOverlay(overlay)
        
        
image = IJ.getImage()
image.setOverlay(None)
analyzer = TreeRingAnalyzer(image, sigma=SIGMA, 
                                   openingRadius=OPENING_RADIUS, 
                                   scaleFactor=SCALE_FACTOR, 
                                   interpolationInterval=INTERPOLATION_INTERVAL)
analyzer.segmentTrunk()
