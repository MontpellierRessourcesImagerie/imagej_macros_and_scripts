import unittest
import sys
from java.util import UUID
from ij import IJ
from ij.gui import Roi
from ij.plugin import Colors
from ij.gui import WaitForUserDialog
from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.neurons import Dendrite

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
       
    
    def testReadDendritesFromString(self):
        dendritesStringOne = " 5634-2252=1,2,3; 1226-2562=4,5; 8373-1212=1,2"
        spineMapping = self.dendrites.readDendritesFromString(dendritesStringOne)
        self.assertEquals(len(spineMapping.keys()), 3)              # The string should have been parsed into a dictonary with the dendrite ids as keys and lists of spines as values.
        self.assertEquals(len(spineMapping['5634-2252']), 3)
        self.assertEquals(len(spineMapping['1226-2562']), 2)
        self.assertEquals(len(spineMapping['8373-1212']), 2)
        self.assertEquals(spineMapping['1226-2562'][1].label, 5)
        self.assertEquals(spineMapping['8373-1212'][0].label, 1)
        
        
    def testGetSpineMapping(self):
        dendritesStringOne = " 5634-2252=1,2,3; 1226-2562=4,5; 8373-1212=1,2"
        self.segmentation.image.setProp('mricia-dendrites', dendritesStringOne)
        self.dendrites.readDendritesFromMetadata()
        spineMapping = self.dendrites.getSpineMapping()
        self.assertEquals(len(spineMapping.keys()), 3)
        self.assertEquals(len(spineMapping['5634-2252']), 3)
        self.assertEquals(len(spineMapping['1226-2562']), 2)
        self.assertEquals(len(spineMapping['8373-1212']), 2)
        self.assertEquals(spineMapping['1226-2562'][1].label, 5)
        self.assertEquals(spineMapping['8373-1212'][0].label, 1)
        
        
    def testGetSpinesFor(self):
        dendritesStringOne = " 5634-2252=1,2,3; 1226-2562=4,5; 8373-1212=1,2"
        self.segmentation.image.setProp('mricia-dendrites', dendritesStringOne)
        self.dendrites.readDendritesFromMetadata()
        roi = Roi(1, 2, 10, 20)
        roi.setName('1226-2562')
        dendrite = Dendrite(roi)
        spines = self.dendrites.getSpinesFor(dendrite)
        self.assertEquals(len(spines), 2)
        self.assertEquals(spines[0].label, 4)
        self.assertEquals(spines[1].label, 5)
        roi = Roi(1, 2, 10, 20)
        roi.setName('5634-2252')
        dendrite = Dendrite(roi)
        spines = self.dendrites.getSpinesFor(dendrite)
        self.assertEquals(len(spines), 3)
        self.assertEquals(spines[0].label, 1)
        self.assertEquals(spines[1].label, 2)
        self.assertEquals(spines[2].label, 3)
        
        
    def testGetDendrites(self):
        self.addDendrites() 
        dendritesString = ""
        rois = self.segmentation.image.getOverlay().toArray()
        id1 = rois[0].getName()
        id2 = rois[2].getName()
        dendritesString = id1 + "=1,2,3; " + id2 + "=4,5"
        self.segmentation.image.setProp('mricia-dendrites', dendritesString)
        self.dendrites.readDendritesFromMetadata()
        dendrites = self.dendrites.getDendrites()
        
        self.assertEquals(len(dendrites[0].spines), 3)
        self.assertEquals(len(dendrites[2].spines), 2)
       
        
    def testCreateSpineMappingString(self):
        spineMapping = {'5634-2252': [1, 2, 3], '1226-2562': [4, 5], '8373-1212': [1, 2]}
        string = self.dendrites.createSpineMappingString(spineMapping)
        #@todo
     
     
     
def suite():
    suite = unittest.TestSuite()

    suite.addTest(DendritesTest('testConstructorNoMetadata'))
    suite.addTest(DendritesTest('testAdd'))
    suite.addTest(DendritesTest('testMaxDistanceForTracking'))
    suite.addTest(DendritesTest('testTrack'))
    suite.addTest(DendritesTest('testReadDendritesFromString'))
    suite.addTest(DendritesTest('testGetSpineMapping'))
    suite.addTest(DendritesTest('testGetSpinesFor'))
    suite.addTest(DendritesTest('testGetDendrites'))
    suite.addTest(DendritesTest('testCreateSpineMappingString'))
   
    return suite



def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    runner.run(suite())



if __name__ == "__main__":
    main()