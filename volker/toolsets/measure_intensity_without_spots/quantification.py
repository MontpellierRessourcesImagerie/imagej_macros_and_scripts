from ij import ImagePlus
from ij.process import AutoThresholder
from ij.plugin import ImageCalculator
from ij.plugin.filter import Binary as BinaryPlugin
from ij.plugin.filter import ThresholdToSelection


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
        self.segmentNucleiMethod = None
        self.segmentSpotsMethod = None


    def measure(self):
        self.createNucleiWithoutSpotsMask()
        #TODO: to be continued
    
    
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
        self.image.setC(self.signalChannel)
        processor = self.image.getProcessor().duplicate()
        image = ImagePlus("tmp image", processor)
        method = YenThresholdOnForegroundSegmentation(image, self.nucleiMask)
        self.image.setC(currentChannel)
        return method 



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
        
        
        