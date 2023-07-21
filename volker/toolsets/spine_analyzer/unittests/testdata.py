from ij.gui import NewImage
from ij.plugin import HyperStackConverter
from java.awt import Color
from ij import IJ
from ij.gui import Roi



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