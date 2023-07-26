import random
from java.awt import Color
from ij import IJ
from ij.gui import NewImage
from ij.gui import PolygonRoi
from ij.gui import Roi
from ij.plugin import Duplicator
from ij.plugin import HyperStackConverter
from ij.plugin import LutLoader
from ij.process import LUT 
from inra.ijpb.binary import BinaryImages
from inra.ijpb.label import LabelImages
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils


def createTestHyperStack():
        image = NewImage.createShortImage ("test hyperstack", 256, 256, 60, NewImage.FILL_RAMP)
        hyperStack = HyperStackConverter.toHyperStack(image, 2, 3, 10)  
        return hyperStack
        


def createTestCuboid(x, y, z, w, h):
        image = NewImage.createShortImage ("test hyperstack", 256, 256, 3, NewImage.FILL_BLACK)
        image = HyperStackConverter.toHyperStack(image, 1, 3, 1)  
        image.setColor(Color.white)
        image.setSlice(z)
        image.getProcessor().fillRect(x, y, w, h)
        image.setSlice(z+1)
        image.getProcessor().fillRect(x, y, w, h)
        return image
        
       
       
def createTestParticlesAndRoi():
    image = NewImage.createShortImage ("test hyperstack", 256, 256, 3, NewImage.FILL_BLACK)
    hyperStack = HyperStackConverter.toHyperStack(image, 1, 3, 1)  
    hyperStack.setColor(Color.white)
    hyperStack.setSlice(1)
    hyperStack.getProcessor().fillOval(64, 64, 32, 32)
    hyperStack.setSlice(2)
    hyperStack.getProcessor().fillOval(64, 64, 32, 32)
    hyperStack.setSlice(2)
    hyperStack.getProcessor().fillOval(96, 96, 16, 16)
    hyperStack.setSlice(3)
    hyperStack.getProcessor().fillOval(96, 96, 16, 16)
    hyperStack.setSlice(1)
    hyperStack.getProcessor().fillOval(128, 128, 32, 32)
    hyperStack.setSlice(2)
    hyperStack.getProcessor().fillOval(128, 128, 32, 32)
    IJ.run(hyperStack, "Add Noise", "stack")
    IJ.run(hyperStack, "Gaussian Blur...", "sigma=3 stack")
    roi = Roi(47,47,74,74)
    return hyperStack, roi
    

class DendriteGenerator:

    # IMAGE
    WIDTH = 256
    HEIGHT = 256
    CHANNELS = 2
    SLICES = 6
    FRAMES = 5 

    # DENDRITES
    ROIS_X = [[118,130,147,156,177,173,199,205], [93,85,74,84,65]]
    ROIS_Y = [[35,62,98,138,181,215,240,248], [44,96,142,187,226]]    
    
    # SPINE PARAMETERS
    MIN_WIDTH = 5
    MAX_WIDTH = 15
    MIN_HEIGHT = 3
    MAX_HEIGHT = 6
    Z_DEPTHS = [4, 3]
    Z_STARTS = [1, 2]
    

    def next(self):
        segmentation = self.createImageWithEmptySegmentation(self.WIDTH, self.HEIGHT, 
                                                        self.CHANNELS, self.SLICES, self.FRAMES)   
        rois = self.getROIs()
        self.drawDendritesFromSegmentedLineRois(segmentation, rois)
        self.labelSpines(segmentation)
        segmentation.image.killRoi()
        return segmentation        
        
        
    def getROIs(self):
        rois = []
        for xpoints, ypoints in zip(self.ROIS_X, self.ROIS_Y):    
            rois.append(PolygonRoi(xpoints, ypoints, Roi.POLYLINE))
        return rois
        
    
    def createImageWithEmptySegmentation(self, width, height, channels, slices, frames):
        image = NewImage.createShortImage ("test hyperstack", width, height, channels*slices*frames, NewImage.FILL_BLACK)
        hyperStack = HyperStackConverter.toHyperStack(image, channels, slices, frames)  
        segmentation = InstanceSegmentation(hyperStack)
        hyperStack.setC(channels+1)
        return segmentation
        
        
    def drawDendritesFromSegmentedLineRois(self, segmentation, rois):
        for index, roi in enumerate(rois):
            self.drawDendriteFromSegmentedLineRoi(segmentation, roi, self.Z_STARTS[index], self.Z_DEPTHS[index])
            
            
    def drawDendriteFromSegmentedLineRoi(self, segmentation, roi, zStart, zDepth):
        segmentation.image.setRoi(roi);
        coords = zip(roi.getPolygon().xpoints, roi.getPolygon().ypoints)    
        segmentation.image.setColor(Color.white)    
        processor = segmentation.image.getProcessor()    
        offsetX = 0
        offsetY = 0
        for t in range(1, self.FRAMES):
            segmentation.image.setT(t)
            for z in range(zStart, zDepth + 1):
                segmentation.image.setZ(z)
                for index, coord in enumerate(coords):
                    label = index + 1
                    w = random.randint(self.MIN_WIDTH, self.MAX_WIDTH)
                    h = random.randint(self.MIN_HEIGHT, self.MAX_HEIGHT)
                    processor.fillOval(coord[0] + offsetX, coord[1] + offsetY, w, h)
            offsetX = offsetX + random.randint(-5, 5)
            offsetY = offsetY + random.randint(-5, 5)   
            
            
        
    def labelSpines(self, segmentation):
        image = segmentation.image
        width, height, nChannels, nSlices, nFrames = image.getDimensions()
        lut = LUT(LutLoader.getLut( "glasbey on dark" ), 0, 255)
        image.setC(nChannels)
        nextNewLabel = 1
        for frame in range(1, nFrames + 1):
            imp = Duplicator().run(image, nChannels, nChannels, 1, nSlices, frame, frame);
            labeled = BinaryImages.componentsLabeling(imp, 6, 16)
            labels = LabelImages.findAllLabels(labeled)
            for index, label in enumerate(labels):
                LabelImages.replaceLabels(labeled, [label], nextNewLabel)
                nextNewLabel = nextNewLabel + 1
            HyperstackUtils.copyStackTo(image, labeled, nChannels, frame, lut=lut, overwrite=True)
            
