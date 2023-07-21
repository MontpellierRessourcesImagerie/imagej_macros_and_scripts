import unittest
import sys
from ij import IJ
from ij.gui import Roi
from ij.gui import WaitForUserDialog
from fr.cnrs.mri.cialib.unittests.testdata import createTestHyperStack
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


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
        
        self.assertEquals(nChannels+1, nChannels2)
        self.assertEquals(3, segmentation.getLabelChannelIndex())
        self.assertEquals(1, segmentation.nextLabel)    
        
        segmentation = InstanceSegmentation(self.stack)
        _, _, nChannels2, _, _ = self.stack.getDimensions()
        
        self.assertEquals(nChannels+1, nChannels2)
        self.assertEquals(3, segmentation.getLabelChannelIndex())
        self.assertEquals(1, segmentation.nextLabel)    
         
        currentC2, currentZ2, currentT2 = (self.stack.getC(), self.stack.getZ(), self.stack.getT())
        self.assertEquals(currentC, currentC2)
        self.assertEquals(currentZ, currentZ2)
        self.assertEquals(currentT, currentT2)


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
        
        labels = segmentation.getLabels()
        self.assertEquals(1, labels[0])
        self.assertEquals(3, labels[1])
        self.assertEquals(5, labels[2])
        self.assertEquals(3, len(labels))
  
  
        segmentation.replaceLabel(196, 95, 1, 1, 0)
        print(labels)
        self.assertEquals(1, labels[0])
        self.assertEquals(3, labels[1])
        self.assertEquals(2, len(labels))
            

def suite():
    suite = unittest.TestSuite()

    suite.addTest(InstanceSegmentationTest('testConstructor'))
    suite.addTest(InstanceSegmentationTest('testAddFromAutoThresholdInRoi'))
    suite.addTest(InstanceSegmentationTest('testReplaceLabel'))
   
    return suite

runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
runner.run(suite())