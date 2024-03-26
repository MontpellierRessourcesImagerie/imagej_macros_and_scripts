from ij import IJ
from ij import ImagePlus
from ij.gui import ImageRoi
from ij.gui import Overlay
from ij.measure import ResultsTable
from ij.process import AutoThresholder
from ij.plugin import ImageCalculator
from ij.plugin.filter import Binary as BinaryPlugin
from ij.plugin.filter import ThresholdToSelection
from inra.ijpb.measure import IntensityMeasures
from inra.ijpb.binary import BinaryImages
from inra.ijpb.label import LabelImages
from inra.ijpb.measure.region2d import IntrinsicVolumesAnalyzer2D
from inra.ijpb.label.conncomp import LabelBoundariesLabeling2D
from fr.cnrs.mri.cialib.metadata import ImageInfo


class Binary:


    @staticmethod
    def fillHoles(image):
        plugin = BinaryPlugin()
        plugin.setup("fill", image)
        plugin.run(image.getProcessor())
        image.updateAndDraw()


    @staticmethod
    def dilate(image):
        plugin = BinaryPlugin()
        plugin.setup("dilate", image)
        plugin.run(image.getProcessor())
        image.updateAndDraw()
        
        
    @staticmethod
    def toROI(image):
        processor = image.getProcessor()
        processor.setThreshold(1, 255)
        plugin = ThresholdToSelection()
        roi = plugin.convert(processor)        
        processor.resetThreshold()
        return roi
        
        

class StainingAnalyzer:


    def __init__(self, image, nucleiChannel, signalChannel):
        self.image = image
        self.nucleiChannel = nucleiChannel
        self.signalChannel = signalChannel
        self.nucleiMask = None
        self.spotsMask = None
        self.nucleiWithoutSpotsMask = None
        self.labels = None
        self.segmentNucleiMethod = None
        self.segmentSpotsMethod = None
        self.neighbors = 4
        self.bitDepthLabels = 16
        self.minAreaNucleus = 0
        self.minAreaNucleusPixel = 0
        self.setMinAreaNucleus(50)
        self.results = ResultsTable()
        

    def measure(self):
        self.createNucleiWithoutSpotsMask()
        components = BinaryImages.componentsLabeling(self.nucleiWithoutSpotsMask,  self.neighbors,  self.bitDepthLabels)
        self.labels = LabelImages.sizeOpening(components, self.minAreaNucleusPixel)
        LabelImages.remapLabels(self.labels)
        IJ.run(self.labels, "Set Label Map", "colormap=[Glasbey (Dark)] background=Black shuffle")
        analyzer = IntrinsicVolumesAnalyzer2D()
        shapeResults = analyzer.computeTable(self.labels)
        currentChannel = self.image.getC()
        signalChannelImage = self.getCopyOfSignalChannel()
        self.image.setC(currentChannel)
        originalFileInfo = self.image.getOriginalFileInfo()
        folder = originalFileInfo.directory
        filename = originalFileInfo.fileName
        info = ImageInfo(self.image)
        well = info.getWell()
        field = int(info.getField())
        analyzer = IntensityMeasures(signalChannelImage, self.labels)
        means = analyzer.getMean().getColumn("Mean") 
        labels = [shapeResults.getLabel(i) for i in range(len(means))]
        areas = shapeResults.getColumn("Area")
        perimeters = shapeResults.getColumn("Perimeter")
        eulerNumbers = shapeResults.getColumn("EulerNumber")        
        stdDevs = analyzer.getStdDev().getColumn("StdDev") 
        mins = analyzer.getMin().getColumn("Min") 
        maxs = analyzer.getMax().getColumn("Max") 
        medians = analyzer.getMedian().getColumn("Median") 
        modes = analyzer.getMode().getColumn("Mode") 
        skewnesses = analyzer.getSkewness().getColumn("Skewness") 
        kurtosis = analyzer.getKurtosis().getColumn("Kurtosis") 
        for row in range(len(means)):  
            self.results.addRow()
            self.results.addValue("Label", labels[row])
            self.results.addValue("Image", filename)
            self.results.addValue("Well", well)
            self.results.addValue("Field", field)
            self.results.addValue("Area", areas[row])
            self.results.addValue("Perimeter", perimeters[row])
            self.results.addValue("EulerNumber", eulerNumbers[row])
            self.results.addValue("Mean", means[row])
            self.results.addValue("StdDev", stdDevs[row])
            self.results.addValue("Min", mins[row])
            self.results.addValue("Max", maxs[row])
            self.results.addValue("Median", medians[row])
            self.results.addValue("Modes", modes[row])
            self.results.addValue("Skewness", skewnesses[row])
            self.results.addValue("Kurtosis", kurtosis[row])
            self.results.addValue("ID", int(labels[row]))
            self.results.addValue("folder", folder)
    
    
    def createOverlayOfResults(self):
        self.image.setOverlay(None)
        bounderies = self.getBoundariesOfLabels()
        roi = ImageRoi(0, 0, bounderies.getProcessor());
        roi.setZeroTransparent(True)
        self.addRoiToOverlayOfInputImage(roi)
        title = self.labels.getTitle()
        self.labels.show()
        IJ.run(None, "Draw Labels As Overlay", "label=" + title + " image=" + title + " x-offset=0 y-offset=0");
        self.labels.hide()
        overlay = self.labels.getOverlay()
        self.labels.setOverlay(None)
        self.image.getOverlay().add(overlay)
        self.image.updateAndDraw()
        
    
    def getBoundariesOfLabels(self):
        boundaryCreator = LabelBoundariesLabeling2D()
        res = boundaryCreator.process(self.labels.getProcessor())
        resImage = ImagePlus("outlines", res.boundaryLabelMap )
        resImage.setLut(self.labels.getLuts()[0])
        return resImage
    
    
    def addRoiToOverlayOfInputImage(self, roi):
        overlay = self.image.getOverlay()
        if not overlay:
            overlay = Overlay(roi)
            self.image.setOverlay(overlay)
        else:
            overlay.add(roi)
    
    
    def setMinAreaNucleus(self, minArea):
        self.minAreaNucleus = minArea
        self.minAreaNucleusPixel = int(round(self.image.getCalibration().getRawX(minArea)))
        
    
    def getMinAreaNucleus(self):
        return self.minAreaNucleus
    
        
    def createNucleiMask(self):
        currentChannel = self.image.getC()
        self.image.setC(self.nucleiChannel)
        method = self.getSegmentNucleiMethod()
        method.run()
        self.nucleiMask = method.getResultMask()
        self.image.setC(currentChannel)


    def createSpotsMask(self):
        if not self.nucleiMask:
            self.createNucleiMask()
        currentChannel = self.image.getC()
        self.image.setC(self.signalChannel)
        method = self.getSegmentSpotsMethod()
        method.run()
        self.spotsMask = method.getResultMask()
        self.image.setC(currentChannel)
            
    
    def createNucleiWithoutSpotsMask(self):
        if not self.nucleiMask:
            self.createNucleiMask()
        if not self.spotsMask:
            self.createSpotsMask()
        self.nucleiWithoutSpotsMask = ImageCalculator.run(self.nucleiMask, self.spotsMask, "subtract create")    
        
    
    def setSegmentNucleiMethod(self, method):
        self.segmentNucleiMethod = method
        
        
    def setSegmentSpotsMethod(self, method):
        self.segmentSpotsMethod = method
        
        
    def getSegmentSpotsMethod(self):
        if not self.segmentSpotsMethod:
            self.segmentSpotsMethod = self.getDefaultSpotSegmentationMethod()
        return self.segmentSpotsMethod    
    
    
    def getSegmentNucleiMethod(self):
        if not self.segmentNucleiMethod:
            self.segmentNucleiMethod = self.getDefaultNucleiSegmentationMethod()
        return self.segmentNucleiMethod
        
        
    def getDefaultNucleiSegmentationMethod(self):
        currentChannel = self.image.getC()
        self.image.setC(self.nucleiChannel)
        method = SubtractGaussianAndThresholdSegmentation(self.image)
        self.image.setC(currentChannel)
        return method
     
     
    def getDefaultSpotSegmentationMethod(self):
        currentChannel = self.image.getC()
        image = self.getCopyOfSignalChannel()
        method = YenThresholdOnForegroundSegmentation(image, self.nucleiMask)
        self.image.setC(currentChannel)
        return method 


    def getCopyOfSignalChannel(self):       
        self.image.setC(self.signalChannel)
        processor = self.image.getProcessor().duplicate()
        image = ImagePlus("tmp image", processor)
        return image
    
    
class NucleiSegmentationMethod(object):


    def __init__(self, image):
        self.inputImage = image
        self.resultProcessor = self.inputImage.getProcessor().duplicate()
        self.title = "Mask of " + self.inputImage.getTitle()
        self.resultMask = ImagePlus(self.title, self.resultProcessor)
       
                
    def getOptions(self):
        return {}
        
    
    def getResultMask(self):
        return self.resultMask
    
    
    def run(self):
        pass
    
    
    
class SubtractGaussianAndThresholdSegmentation(NucleiSegmentationMethod):


    @classmethod
    def name(cls):
        return "subtract Gaussian and threshold"
    
    
    @classmethod
    def options(cls):
        return { 1 : {'name': 'sigma', 'defaultValue': 40.86, 'type' : int}}
    
    
    def __init__(self, image):
        super(SubtractGaussianAndThresholdSegmentation, self).__init__(image)
        self.setSigma(40.86)
           
              
    def getSigma(self):
        return sigma
       
       
    def setSigma(self, sigma):
        """ Set the sigma of the Gaussian Blur. The value has to be in physical units (for example microns).
        """
        self.sigma = sigma
        self.sigmaInPixel = self.inputImage.getCalibration().getRawX(self.sigma)
        
                
    def run(self):
        resultProcessor = self.resultMask.getProcessor()
        resultProcessor.blurGaussian(self.sigmaInPixel)
        self.resultMask = ImageCalculator.run(self.inputImage, self.resultMask, "subtract create")
        resultProcessor = self.resultMask.getProcessor()
        resultProcessor.setAutoThreshold(AutoThresholder.Method.Huang, True)
        mask = resultProcessor.createMask()
        self.resultMask.setProcessor(mask)
        Binary.fillHoles(self.resultMask)
        
        
        
class SpotSegmentationMethod(object):


     def __init__(self, image, mask):
        self.inputImage = image
        self.inputMask = mask
        
        self.resultProcessor = self.inputImage.getProcessor().duplicate()
        self.title = "Mask of " + self.inputImage.getTitle()
        self.resultMask = ImagePlus(self.title, self.resultProcessor)
        
                
     def getResultMask(self):
        return self.resultMask
        
        
     def getOptions(self):
        return {}
        
        
     def run(self):
        pass
        
        
        
class YenThresholdOnForegroundSegmentation(SpotSegmentationMethod):

    def __init__(self, image, mask):
        super(YenThresholdOnForegroundSegmentation, self).__init__(image, mask)
        
               
    def run(self):
        roi = Binary.toROI(self.inputMask)
        self.resultMask.setRoi(roi)
        resultProcessor = self.resultMask.getProcessor()
        resultProcessor.setAutoThreshold(AutoThresholder.Method.Yen, True)
        self.resultMask.resetRoi()
        mask = resultProcessor.createMask()
        self.resultMask.setProcessor(mask)
        Binary.dilate(self.resultMask)
        
        
        