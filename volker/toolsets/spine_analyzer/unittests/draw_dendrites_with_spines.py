import random
from java.awt import Color
from ij.gui import NewImage,PolygonRoi, Roi
from ij.plugin import HyperStackConverter
from ij.plugin import Duplicator
from ij.process import LUT 
from ij.plugin import LutLoader
from inra.ijpb.binary import BinaryImages
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils

# IMAGE
WIDTH = 256
HEIGHT = 256
CHANNELS = 2
SLICES = 6
FRAMES = 5

# DENDRITES
ROIS_X = [[118,130,147,156,177,173,199,205], [93,85,74,84,65]]
ROIS_Y = [[35,62,98,138,181,215,240,248], [44,96,142,187,226]]

# SPINE PARAMETERS
MIN_WIDTH = 5
MAX_WIDTH = 15
MIN_HEIGHT = 3
MAX_HEIGHT = 6
Z_DEPTHS = [4, 3]
Z_STARTS = [1, 2]


def main():
    segmentation = createImageWithEmptySegmentation(WIDTH, HEIGHT, CHANNELS, SLICES, FRAMES)   
    rois = getROIS()
    drawDendritesFromSegmentedLineRois(segmentation, rois)
    labelSpines(segmentation)
    segmentation.show()
        
        
def getROIS():
    rois = []
    for xpoints, ypoints in zip(ROIS_X, ROIS_Y):    
        rois.append(PolygonRoi(xpoints,ypoints,Roi.POLYLINE))
    return rois
    
    
def createImageWithEmptySegmentation(width, height, channels, slices, frames):
    image = NewImage.createShortImage ("test hyperstack", width, height, channels*slices*frames, NewImage.FILL_BLACK)
    hyperStack = HyperStackConverter.toHyperStack(image, channels, slices, frames)  
    segmentation = InstanceSegmentation(hyperStack)
    hyperStack.setC(channels+1)
    return segmentation
   

def drawDendritesFromSegmentedLineRois(segmentation, rois):
    for index, roi in enumerate(rois):
        drawDendriteFromSegmentedLineRoi(segmentation, roi, Z_STARTS[index], Z_DEPTHS[index])
        
   
def drawDendriteFromSegmentedLineRoi(segmentation, roi, zStart, zDepth):
    segmentation.image.setRoi(roi);
    coords = zip(roi.getPolygon().xpoints, roi.getPolygon().ypoints)    
    segmentation.image.setColor(Color.white)    
    processor = segmentation.image.getProcessor()    
    offsetX = 0
    offsetY = 0
    for t in range(1, FRAMES):
        segmentation.image.setT(t)
        for z in range(zStart, zDepth+1):
            segmentation.image.setZ(z)
            for index, coord in enumerate(coords):
                label = index + 1
                w = random.randint(MIN_WIDTH, MAX_WIDTH)
                h = random.randint(MIN_HEIGHT, MAX_HEIGHT)
                processor.fillOval(coord[0] + offsetX, coord[1] + offsetY, w, h)
        offsetX = offsetX + random.randint(-5, 5)
        offsetY = offsetY + random.randint(-5, 5)    


def labelSpines(segmentation):
    image = segmentation.image
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    lut = LUT(LutLoader.getLut( "glasbey on dark" ), 0, 255)
    image.setC(nChannels)
    for frame in range(1, nFrames + 1):
        imp = Duplicator().run(image, nChannels, nChannels, 1, nSlices, frame, frame);
        labeled = BinaryImages.componentsLabeling(imp, 6, 16)
        HyperstackUtils.copyStackTo(image, labeled, nChannels, frame, lut=lut)


main()
