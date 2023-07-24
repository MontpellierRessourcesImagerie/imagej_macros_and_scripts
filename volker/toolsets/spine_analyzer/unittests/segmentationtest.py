import unittest
import sys
from ij import IJ
from ij.gui import Roi
from ij.gui import WaitForUserDialog
from fr.cnrs.mri.cialib.unittests.testdata import createTestHyperStack
from fr.cnrs.mri.cialib.unittests.testdata import createTestParticlesAndRoi
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils


class InstanceSegmentationTest(unittest.TestCase):


    def setUp(self):
        unittest.TestCase.setUp(self)
        IJ.run("Close All");
        self.stack = createTestHyperStack()


    def tearDown(self):
        unittest.TestCase.tearDown(self)
        IJ.run("Close All");


    def createSegmentation(self):
        segmentation = InstanceSegmentation(self.stack.clone())
        self.stack.setPosition(2, 1, 1)
        roi = Roi(0, 64, 128, 128)
        segmentation.addFromAutoThresholdInRoi(roi)
        roi = Roi(148, 64, 64, 64)
        segmentation.addFromAutoThresholdInRoi(roi)
        roi = Roi(148, 148, 64, 64)
        segmentation.addFromAutoThresholdInRoi(roi)        
        return segmentation
        
        
    def testConstructor(self):
        currentC, currentZ, currentT = (self.stack.getC(), self.stack.getZ(), self.stack.getT())
        _, _, nChannels, _, _ = self.stack.getDimensions()
        segmentation = InstanceSegmentation(self.stack)
        _, _, nChannels2, _, _ = self.stack.getDimensions()
        
        self.assertEquals(nChannels+1, nChannels2)                                                      # The label channel should be 3 and the next label should be 1, since the segmentation is empty 
        self.assertEquals(3, segmentation.getLabelChannelIndex())
        self.assertEquals(1, segmentation.nextLabel)    
        
        segmentation = InstanceSegmentation(self.stack)
        _, _, nChannels2, _, _ = self.stack.getDimensions()
        
        self.assertEquals(nChannels+1, nChannels2)                                                     # Call on existing segmentation should modify nothing
        self.assertEquals(3, segmentation.getLabelChannelIndex())
        self.assertEquals(1, segmentation.nextLabel)    
         
        currentC2, currentZ2, currentT2 = (self.stack.getC(), self.stack.getZ(), self.stack.getT())    # The initial position should have been restored
        self.assertEquals(currentC, currentC2)
        self.assertEquals(currentZ, currentZ2)
        self.assertEquals(currentT, currentT2)

    
    def testGetLabelAt(self):
        segmentation = self.createSegmentation()            # should answer the label 2 of the object at the position
        label = segmentation.getLabelAt(196, 95, 1, 1)
        self.assertEquals(2, label)
        
        label = segmentation.getLabelAt(1, 1, 1, 1)         # should answer the label 0 of the background
        self.assertEquals(0, label)
    
    
    def testGetLabels(self):
        segmentation = self.createSegmentation()
        
        labels = segmentation.getLabels()           # The image should contain 3 labels, 1, 2 and 3
        self.assertEquals(1, labels[0])
        self.assertEquals(2, labels[1])
        self.assertEquals(3, labels[2])
        self.assertEquals(3, len(labels))
        
        segmentation.replaceLabel(196, 95, 1, 1, 0) # The image should contain 2 labels, 1 and 3
        labels = segmentation.getLabels()
        self.assertEquals(1, labels[0])
        self.assertEquals(3, labels[1])
        self.assertEquals(2, len(labels))

        segmentation.replaceLabel(94, 124, 1, 1, 0) # The image should contain 1 label, 3
        labels = segmentation.getLabels()
        self.assertEquals(3, labels[0])
        self.assertEquals(1, len(labels))
        
        segmentation.replaceLabel(194, 197, 1, 1, 0) # The image should contain 0 labels
        labels = segmentation.getLabels()
        self.assertEquals(0, len(labels))

    
    def testAddFromMask(self):
        segmentation = self.createSegmentation()
        image, roi = createTestParticlesAndRoi()
        mask = HyperstackUtils.segmentObjectInRegion(image, roi)
        
        segmentation.addFromMask(mask)                              # A new object should have been added 
        label = segmentation.getLabelAt(80, 80, 1, 1)
        self.assertEquals(4, label)
        
    
    def testAddFromAutoThresholdInRoi(self):
        segmentation = self.createSegmentation()
        label = segmentation.getLabelAt(196, 95, 1, 1)
        self.assertEquals(2, label)
        labels = segmentation.getLabels()
        self.assertEquals(1, labels[0])
        self.assertEquals(2, labels[1])
        self.assertEquals(3, labels[2])
        self.assertEquals(3, len(labels))


    def testReplaceLabel(self):
        segmentation = self.createSegmentation()
        segmentation.replaceLabel(196, 95, 1, 1, 5)
        
        labels = segmentation.getLabels()                # label 3 should be replaced with label 5
        self.assertEquals(1, labels[0])
        self.assertEquals(3, labels[1])
        self.assertEquals(5, labels[2])
        self.assertEquals(3, len(labels))
  
        segmentation.replaceLabel(196, 95, 1, 1, 0)      # label 5 should be removed
        labels = segmentation.getLabels()
        self.assertEquals(1, labels[0])
        self.assertEquals(3, labels[1])
        self.assertEquals(2, len(labels))
        
        segmentation.replaceLabel(196, 95, 1, 1, 3)      # replacing the background (label 0) should be refused
        labels = segmentation.getLabels()
        self.assertEquals(1, labels[0])
        self.assertEquals(3, labels[1])
        self.assertEquals(2, len(labels))
            
    
    def testSetLUT(self):
        segmentation = self.createSegmentation()
        segmentation.setLUT("Ice")
        
        self.assertEquals("Ice", segmentation.lutName)      # The name of the lut should be Ice and it should be loaded
        self.assertEquals(False, segmentation.lut is None)
    
    
    def testSetThresholdingMethod(self):
        segmentation = self.createSegmentation()
        segmentation.setThresholdingMethod("Otsu")
        
        self.assertEquals("Otsu", segmentation.thresholdingMethod)
        
        
    def testGetLabelChannelIndex(self):
        segmentation = self.createSegmentation()
        self.assertEquals(3, segmentation.getLabelChannelIndex())
        
        
    def testGetCopyOfLabelsChannel(self):
        segmentation = self.createSegmentation()
        width, height, nChannels, nSlices, nFrames = segmentation.image.getDimensions()
        labels = segmentation.getCopyOfLabelsChannel()
        width2, height2, nChannels2, nSlices2, nFrames2 = labels.getDimensions()
        
        self.assertEquals(width, width2)
        self.assertEquals(height, height2)
        self.assertEquals(1, nChannels2)
        self.assertEquals(nSlices, nSlices2)
        self.assertEquals(1, nFrames2)
       
        label = labels.getProcessor().get(196, 95)  # Should have the same content as the original label-channel
        self.assertEquals(2, label)
        label = labels.getProcessor().get(1, 1)  
        self.assertEquals(0, label)
        
    
def suite():
    suite = unittest.TestSuite()

    suite.addTest(InstanceSegmentationTest('testConstructor'))
    suite.addTest(InstanceSegmentationTest('testGetLabelAt'))
    suite.addTest(InstanceSegmentationTest('testGetLabels'))
    suite.addTest(InstanceSegmentationTest('testAddFromMask'))
    suite.addTest(InstanceSegmentationTest('testAddFromAutoThresholdInRoi'))
    suite.addTest(InstanceSegmentationTest('testReplaceLabel'))
    suite.addTest(InstanceSegmentationTest('testSetLUT'))
    suite.addTest(InstanceSegmentationTest('testSetThresholdingMethod'))
    suite.addTest(InstanceSegmentationTest('testGetLabelChannelIndex'))
    suite.addTest(InstanceSegmentationTest('testGetCopyOfLabelsChannel'))
    return suite



def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    runner.run(suite())



if __name__ == "__main__":
    main()