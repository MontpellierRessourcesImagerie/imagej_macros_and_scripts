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


SIGMA = 2
OPENING_RADIUS = 16
CLOSING_RADIUS = 8
SCALE_FACTOR = 8
INTERPOLATION_INTERVAL = 100
VECTORS = (0.7372839, 0.63264143, 0.23701741,
           0.91958255, 0.35537627, 0.16755785,
           0.69067574, 0.64728355, 0.3224746)
PITH_MIN_SIZE = 200
AUTO_THRESHOLDING_METHOD = "Mean"           


class TreeRingAnalyzer:
    
    
    def __init__(self, image, sigma=2, openingRadius=16, closingRadius=8, scaleFactor=8, 
                              strokeWidth=8, interpolationInterval=100, thresholdingMethod="Huang"):
        self.image = image
        self.width, self.height, self.nChannels, self.nSlices, self.nFrames = self.image.getDimensions() 
        self.sigma = sigma
        self.openingRadius = openingRadius
        self.closingRadius = closingRadius
        self.scaleFactor = scaleFactor
        self.strokeWidth = strokeWidth
        self.strel = Strel.Shape.DISK.fromRadius(self.openingRadius)    
        self.closingStrel = Strel.Shape.DISK.fromRadius(self.closingRadius)
        self.interpolationInterval = interpolationInterval
        self.scaledDownMask = None
        self.vectors = None
        self.thresholdingMethod = thresholdingMethod
        self.pithMinSize = 500
        
    
    def getScaledDownMask(self):
        if not self.scaledDownMask:
            self.createScaledDownMask()
        return self.scaledDownMask
    
    
    def createScaledDownMask(self):
        image = Duplicator().run(self.image, 1, self.nChannels, 1, self.nSlices, 1, self.nFrames)
        ImageConverter(image).convertToGray8()
        self.scaledDownMask = self.calculateScaledDownMask(image)
    
    
    def calculateScaledDownMask(self, image):
        mask = image
        mask = Scaler.resize(mask, self.width/self.scaleFactor, self.height/self.scaleFactor, 1, 'bilinear')
        mask.getProcessor().blurGaussian(self.sigma)
        mask.getProcessor().setAutoThreshold(self.thresholdingMethod)
        mask.setProcessor(mask.getProcessor().createMask())
        return mask
    
    
    def segmentTrunk(self):
        self.image.setRoi(None)               
        image = self.getScaledDownMask()
        image = Duplicator().run(image, 1, self.nChannels, 1, self.nSlices, 1, self.nFrames)
        ip = BinaryImages.keepLargestRegion(image.getProcessor())
        ip = Reconstruction.fillHoles(ip)
        ip = Opening(self.strel).process(ip)
        image.setProcessor(ip)
        image = Scaler.resize(image, self.width, self.height, 1, 'bilinear')
        image.getProcessor().setThreshold(1, 255)
        roi = ThresholdToSelection.run(image)
        image.close()
        roi = RoiEnlarger.enlarge(roi, -self.openingRadius/2)
        poly = roi.getInterpolatedPolygon(-100, True)
        roi = PolygonRoi(poly, Roi.POLYGON)
        roi.setName("bark - outer border")
        roi.setStrokeWidth(self.strokeWidth)
        self.addRoiToOverlay(roi)
        
    
    def addRoiToOverlay(self, roi):
        overlay = self.image.getOverlay()
        if not overlay:
            overlay = Overlay()
        overlay.add(roi)
        self.image.setOverlay(overlay)
    
    
    def segmentPith(self):
        componentsLabeling = FloodFillComponentsLabeling(4, 16)
        sm = StainMatrix()
        sm.init("wood", *self.vectors)
        labelFiltering = LabelSizeFiltering(RelationalOperator.GT, self.pithMinSize)
        
        stack = sm.compute(False, True, self.image);
        imp = ImagePlus(self.image.getTitle() + "-(Colour_2)", stack[1])
        mask = self.calculateScaledDownMask(imp)        
        labelsProcessor = componentsLabeling.computeLabels(mask.getProcessor())
        labelsProcessor = labelFiltering.process(labelsProcessor)
        labels = LabelImages.findAllLabels(labelsProcessor)
        label = self.getLabelClosestToCenter(labelsProcessor, labels)
        ip = LabelImages.binarize(labelsProcessor, label)
        ip = Closing(self.closingStrel).process(ip)
        image = ImagePlus("segmented", ip)
        image = Scaler.resize(image, self.width, self.height, 1, 'bilinear')
        image.getProcessor().setThreshold(1, 255)
        roi = ThresholdToSelection.run(image)
        image.close()
        roi.setName("pith - outer border")
        roi.setStrokeWidth(self.strokeWidth)
        self.addRoiToOverlay(roi)
        
    
    def getLabelClosestToCenter(self, labelsProcessor, labels):
        boxes = BoundingBox.boundingBoxes(labelsProcessor, labels, None)
        imageCenterX = labelsProcessor.getWidth() / 2.0
        imageCenterY = labelsProcessor.getHeight() / 2.0
        closestDistance = 2 * self.width * self.width
        closestIndex = -1
        index = 1
        for box in boxes:
            x = box.getXMin()
            y = box.getYMin()
            deltaX = x - imageCenterX
            deltaY = y - imageCenterY
            dist = (deltaX*deltaX) + (deltaY*deltaY)
            if dist < closestDistance:
                closestDistance = dist
                closestIndex = index
            index = index + 1
        return closestIndex


image = IJ.getImage()
image.setOverlay(None)
analyzer = TreeRingAnalyzer(image, sigma=SIGMA, 
                                   openingRadius=OPENING_RADIUS, 
                                   closingRadius=CLOSING_RADIUS,
                                   scaleFactor=SCALE_FACTOR, 
                                   interpolationInterval=INTERPOLATION_INTERVAL,
                                   thresholdingMethod=AUTO_THRESHOLDING_METHOD)
analyzer.vectors = VECTORS   
analyzer.pithMinSize = PITH_MIN_SIZE
analyzer.segmentTrunk()
analyzer.segmentPith()