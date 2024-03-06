


class StainingAnalyzer:


    def __init__(self, image, nucleiChannel, signalChannel):
        self.image = image
        self.nucleiChannel = nucleiChannel
        self.signalChannel = signalChannel
        self.nucleiMask = None
        self.spotsMask = None
        self.nucleiWithoutSpotsMask = None
        

    def createNucleiMask(self):
        currentChannel = self.image.getC()
        self.image.setC(self.nucleiChannel)
        method = self.getNucleiSegmentationMethod()
        method.run()
        self.nucleiMask = method.getResultMask()
        self.image.setC(currentChannel)

                       
     def setMethod(self, method):
        self.method = method
        
        
     def getMethod(self):
        if not self.method:
            self.method = self.getDefaultNucleiSegmentationMethd()
        return self.method
        
        
     def getDefaultNucleiSegmentationMethd(self):
        currentChannel = self.image.getC()
        self.image.setC(self.nucleiChannel)
        method = SubtractGaussianAndThresholdSegmentation(self.image.getTitle(), self.image.getProcessor())
        self.image.setC(currentChannel)
     
     
     
def NucleiSegmentationMethod():


    def __init__(self, title, processor):
        self.processor = processor
        self.resultMask = None
        self.title = "Mask of " + title
        
        
    def getOptions(self):
        return {}
        
    
    def getResultMask(self):
        return self.resultMask
    
    
    def run(self):
        pass
    
    
    
class SubtractGaussianAndThresholdSegmentation(NucleiSegmentationMethod):


    def __init__(self, title, processor):
        super(SubtractGaussianAndThresholdSegmentation, self).__init__(title, processor)
        self.sigma = 40.86
        
    
    def setSigma(self, sigma):
        """Set the sigma of the Gaussian Blur Filter in physical units (for example micron).
        """
        self.sigma = sigma
        
        
    def getSigma(self):
        return sigma
       
       
    def run(self):
        self.resultMask = ImagePlus("Mask of ", )