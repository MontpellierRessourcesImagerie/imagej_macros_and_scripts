import os
from fr.cnrs.mri.cialib.metadata import ImageInfo;
from ij import ImagePlus
from ij import ImageStack 
from ij.io import FileSaver
from ij.plugin import RGBStackMerge
from loci.plugins import BF
from loci.plugins.in import ImporterOptions
from loci.formats import ImageReader


class BFWellsSeriesToTifStackSeries(object):


    def __init__(self, path):
        self.inputPath = path
        self.outputFolderName = "export"
        
        
    def setOutputFolderName(self, name):
        self.outputFolderName = name
        
        
    def getOutputPath(self):
         outputPath = os.path.join(os.path.dirname(self.inputPath), self.outputFolderName)
         if not os.path.exists(outputPath):
            os.makedirs(outputPath)
         return outputPath
         
        
    def getNumberOfChannels(self):        
        reader = ImageReader()
        reader.setId(self.inputPath)
        nrOfChannels = reader.getSizeC()
        return nrOfChannels
    
    
    def getOptions(self):
        options = ImporterOptions()
        options.setId(self.inputPath)
        options.setOpenAllSeries(True)
        options.setSplitChannels(True)
        return options
        
        
    def getImages(self):
        images = list(BF.openImagePlus(self.getOptions()))
        width = images[0].getWidth()
        height = images[0].getHeight()
        return images, width, height
    
    
    def run(self):
        nrOfChannels = self.getNumberOfChannels()
        options = self.getOptions()
        images, width, height = self.getImages()
        cStacks = [None]*nrOfChannels
        for c in range(nrOfChannels):
            cStacks[c] = ImageStack(width, height)
        lastWell = None
        title = ""
        cImages = [None]*nrOfChannels
        for c in range(nrOfChannels):
            cImages[c] = [image for i, image in enumerate(images) if i%2==c]
        for c in range(nrOfChannels):
            cImages[c].append(images[0])
        
        for cImageTupel in zip(*cImages):            
            title = cImageTupel[0].getTitle()
            imageInfo = ImageInfo(cImageTupel[0])
            calibration = cImageTupel[0].getCalibration()
            well = imageInfo.getWell()
            if well == lastWell or lastWell==None: 
                for c in range(nrOfChannels):
                    cStacks[c].addSlice(cImageTupel[c].getProcessor())             
            else:
                imagesC = [ImagePlus(title.replace("C=0", "C=" + str(c)), cStacks[c]) for c in range(nrOfChannels)]
                resultImage = RGBStackMerge.mergeChannels(imagesC, False)
                resultImage.setCalibration(calibration)
                title = lastImageTupel[0].getTitle()
                saver = FileSaver(resultImage)
                print(os.path.join(self.getOutputPath(), title.replace(" - C=0", "")))
                saver.saveAsTiffStack(os.path.join(self.getOutputPath(), title.replace(" - C=0", "")) + ".tif")
                cStacks = [None]*nrOfChannels
                for c in range(nrOfChannels):
                    cStacks[c] = ImageStack(width, height)
                    cStacks[c].addSlice(cImageTupel[c].getProcessor())  
            lastWell = well
            lastImageTupel = cImageTupel
           