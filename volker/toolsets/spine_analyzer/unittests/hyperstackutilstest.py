import unittest
import sys
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils
from ij import IJ
from ij.process import LUT 
from ij.plugin import LutLoader
from inra.ijpb.label import LabelImages
from fr.cnrs.mri.cialib.unittests.testdata import createTestHyperStack
from fr.cnrs.mri.cialib.unittests.testdata import createTestCuboid*
from fr.cnrs.mri.cialib.unittests.testdata import createTestParticlesAndRoi

    
    
class AddEmptyChannelTest(unittest.TestCase):


    def setUp(self):
        unittest.TestCase.setUp(self)
        IJ.run("Close All");
        self.stack = createTestHyperStack()


    def tearDown(self):
        unittest.TestCase.tearDown(self)
        IJ.run("Close All");
        
    
    def testAddToHyperstack(self):
        width, height, nChannels, nSlices, nFrames = self.stack.getDimensions()
       
        channelNumber = HyperstackUtils.addEmptyChannel(self.stack)       
        width2, height2, nChannels2, nSlices2, nFrames2 = self.stack.getDimensions()
        
        self.assertEquals(3, channelNumber)
        self.assertEquals(nChannels+1, nChannels2)    
        self.assertEquals(nSlices, nSlices2)
        self.assertEquals(nFrames, nFrames2)
    
    
    def testAddToHyperstackPosition(self):
        self.stack.setPosition(1, 2, 5)
        channelNumber = HyperstackUtils.addEmptyChannel(self.stack)       
        currentC, currentZ, currentT = (self.stack.getC(), self.stack.getZ(), self.stack.getT())
        
        self.assertEquals(1, currentC)
        self.assertEquals(2, currentZ)
        self.assertEquals(5, currentT)
    


class CopyStackToTest(unittest.TestCase):


    def setUp(self):
        unittest.TestCase.setUp(self)
        IJ.run("Close All");
        self.stack = createTestHyperStack()
        HyperstackUtils.addEmptyChannel(self.stack)
        self.mask1 = createTestCuboid(64, 64, 2, 128, 128)
        self.mask2 = createTestCuboid(32, 32, 1, 128, 128)
        

    def tearDown(self):
        unittest.TestCase.tearDown(self)
        IJ.run("Close All");


    def testCopyStackToNoOverwrite(self):
        HyperstackUtils.copyStackTo(self.stack, self.mask1, 3, 1)
        HyperstackUtils.copyStackTo(self.stack, self.mask2, 3, 1)
        self.stack.setPosition(3, 1, 1) 
        val1 = self.stack.getPixel(32, 32)[0]
        val2 = self.stack.getPixel(128, 128)[0]
        val3 = self.stack.getPixel(192, 192)[0]
        self.assertEquals(65535, val1)
        self.assertEquals(65535, val2)
        self.assertEquals(0, val3)
        self.stack.setPosition(3, 2, 1) 
        val1 = self.stack.getPixel(32, 32)[0]
        val2 = self.stack.getPixel(128, 128)[0]
        val3 = self.stack.getPixel(191, 191)[0]
        self.assertEquals(65535, val1)
        self.assertEquals(65535, val2)
        self.assertEquals(65535, val3)
        self.stack.setPosition(3, 3, 1) 
        val1 = self.stack.getPixel(32, 32)[0]
        val2 = self.stack.getPixel(128, 128)[0]
        val3 = self.stack.getPixel(191, 191)[0]
        self.assertEquals(0, val1)
        self.assertEquals(65535, val2)
        self.assertEquals(65535, val3)
    
    
    def testCopyStackToOverwrite(self):
        HyperstackUtils.copyStackTo(self.stack, self.mask1, 3, 1, overwrite=True)
        HyperstackUtils.copyStackTo(self.stack, self.mask2, 3, 1, overwrite=True)
        self.stack.setPosition(3, 1, 1) 
        val1 = self.stack.getPixel(32, 32)[0]
        val2 = self.stack.getPixel(128, 128)[0]
        val3 = self.stack.getPixel(192, 192)[0]
        self.assertEquals(65535, val1)
        self.assertEquals(65535, val2)
        self.assertEquals(0, val3)
        self.stack.setPosition(3, 2, 1) 
        val1 = self.stack.getPixel(32, 32)[0]
        val2 = self.stack.getPixel(128, 128)[0]
        val3 = self.stack.getPixel(191, 191)[0]
        self.assertEquals(65535, val1)
        self.assertEquals(65535, val2)
        self.assertEquals(0, val3)
        self.stack.setPosition(3, 3, 1) 
        val1 = self.stack.getPixel(32, 32)[0]
        val2 = self.stack.getPixel(128, 128)[0]
        val3 = self.stack.getPixel(191, 191)[0]
        self.assertEquals(0, val1)
        self.assertEquals(0, val2)
        self.assertEquals(0, val3)
        
        
    def testCopyStackToLUT(self):
        lut = LUT(LutLoader.getLut( "glasbey on dark" ), 0, 255)
        HyperstackUtils.copyStackTo(self.stack, self.mask1, 3, 1, overwrite=True, lut=lut)
        HyperstackUtils.copyStackTo(self.stack, self.mask2, 3, 1, overwrite=True, lut=lut)
        self.stack.setPosition(3, 1, 1) 
        lut2 = self.stack.getProcessor().getLut()
        self.assertEquals(lut, lut2)
        

    def testSegmentObjectInRegion(self):
        image, roi = createTestParticlesAndRoi()
        labels = HyperstackUtils().segmentObjectInRegion(image, roi)
        labelsImage = LabelImages.regionComponentsLabeling(labels, 255, 6, 8)
        maxLabel = labelsImage.getStatistics().max
        self.assertEquals(1, maxLabel)
        

def suite():
    suite = unittest.TestSuite()

    suite.addTest(AddEmptyChannelTest('testAddToHyperstack'))
    suite.addTest(AddEmptyChannelTest('testAddToHyperstackPosition'))
    suite.addTest(CopyStackToTest('testCopyStackToNoOverwrite'))
    suite.addTest(CopyStackToTest('testCopyStackToOverwrite'))
    suite.addTest(CopyStackToTest('testCopyStackToLUT'))
    suite.addTest(CopyStackToTest('testSegmentObjectInRegion'))
    
    return suite



def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    runner.run(suite())



if __name__ == "__main__":
    main()