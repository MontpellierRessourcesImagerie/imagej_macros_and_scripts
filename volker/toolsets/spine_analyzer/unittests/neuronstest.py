import unittest
import sys
from java.util import UUID
from ij import IJ
from ij.plugin import Colors
from ij.gui import WaitForUserDialog
from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator
from fr.cnrs.mri.cialib.neurons import Dendrites


class DendritesTest(unittest.TestCase):


    def setUp(self):
        unittest.TestCase.setUp(self)
        IJ.run("Close All");
        self.segmentation = DendriteGenerator().next()
        self.dendrites = Dendrites(self.segmentation)
        

    def tearDown(self):
        unittest.TestCase.tearDown(self)
        IJ.run("Close All");
        
    
    def addDendrites(self):
        rois = DendriteGenerator().getROIs()
        width, height, nChannels, nSlices, nFrames =  self.segmentation.image.getDimensions()
        for roi in rois:
            for frame in range(1, nFrames + 1):
                self.dendrites.add(roi, frame)
        
        
    def testConstructorNoMetadata(self):
        dendrites = Dendrites(self.segmentation)
        
        self.assertEquals(self.segmentation, dendrites.segmentation)
        self.assertEquals(self.segmentation.image, dendrites.image)
        self.assertTrue(dendrites.maxDistanceForTracking)
        self.assertTrue(dendrites.overlay)
        
        
    def testAdd(self):
        self.addDendrites() 
        dendrites = self.dendrites.getDendrites()
        self.assertEquals(10, len(dendrites))    # Should have 10 dendrites for the 5 frames
        self.assertTrue(UUID.fromString(dendrites[0].getID()))
        self.assertEquals(self.dendrites.overlay.size(), len(dendrites))
        
        
    def testMaxDistanceForTracking(self):
        oldMaxDist = self.dendrites.getMaxDistanceForTracking()
        self.dendrites.setMaxDistanceForTracking(15)
        self.assertEquals(15, self.dendrites.getMaxDistanceForTracking())
        self.dendrites.setMaxDistanceForTracking(oldMaxDist)
        self.assertEquals(oldMaxDist, self.dendrites.getMaxDistanceForTracking())
    
    
    def testTrack(self):
        self.addDendrites()
        for dendrite in self.dendrites.getDendrites():
            self.assertFalse(dendrite.isOnTrack())      # dendrites should not belong to tracks yet
        self.dendrites.track()
        for dendrite in self.dendrites.getDendrites():
            self.assertTrue(dendrite.isOnTrack())       # each dendrite should belong to a track now
        tracks = [dendrite.getTrack() for dendrite in self.dendrites.getDendrites()]
        tracks = set(tracks)
        self.assertEquals(2, len(tracks))               # there should be two tracks (of dendrites)
        colors = [Colors.colorToString(dendrite.roi.getStrokeColor()) for dendrite in self.dendrites.getDendrites()]
        colors = set(colors)
        self.assertEquals(2, len(colors))               # the two tracks should have different colors
       
               
        
def suite():
    suite = unittest.TestSuite()

    suite.addTest(DendritesTest('testConstructorNoMetadata'))
    suite.addTest(DendritesTest('testAdd'))
    suite.addTest(DendritesTest('testMaxDistanceForTracking'))
    suite.addTest(DendritesTest('testTrack'))
   
    return suite



def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    runner.run(suite())



if __name__ == "__main__":
    main()