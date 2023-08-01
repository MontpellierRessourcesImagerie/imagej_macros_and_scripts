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
from fr.cnrs.mri.cialib.neurons import Spine

class DendritesTest(unittest.TestCase):


    def setUp(self):
        unittest.TestCase.setUp(self)
        IJ.run("Close All");
        self.dendriteGenerator = DendriteGenerator()
        self.segmentation =  self.dendriteGenerator.next()        
        self.dendrites = Dendrites(self.segmentation)
        

    def tearDown(self):
        unittest.TestCase.tearDown(self)
        IJ.run("Close All");
        
    
    def addDendrites(self):
        rois = self.dendriteGenerator.getROIs()
        width, height, nChannels, nSlices, nFrames =  self.segmentation.image.getDimensions()
        for roi in rois:
            for frame in range(1, nFrames + 1):
                self.dendrites.addElement(Dendrite(roi), frame)
        
        
    def addRois(self):
        roi1 = Roi(10,10,10,10)
        roi1.setName('5634-2252')
        roi1.setImage(self.dendrites.image)
        self.dendrites.overlay.add(roi1)
        roi2 = Roi(10,10,10,10)
        roi2.setName('1226-2562')
        roi2.setImage(self.dendrites.image)
        self.dendrites.overlay.add(roi2)
        roi3 = Roi(10,10,10,10)
        roi3.setName('8373-1212')
        roi3.setImage(self.dendrites.image)
        self.dendrites.overlay.add(roi3)
        
        
    def testConstructorNoMetadata(self):
        dendrites = Dendrites(self.segmentation)
        
        self.assertEquals(self.segmentation, dendrites.segmentation)
        self.assertEquals(self.segmentation.image, dendrites.image)
        self.assertTrue(dendrites.maxDistanceForTracking)
        self.assertTrue(dendrites.overlay)
        
        
    def testAdd(self):
        self.addDendrites() 
        dendrites = self.dendrites.asList()
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
        for dendrite in self.dendrites.asList():
            self.assertFalse(dendrite.isOnTrack())      # dendrites should not belong to tracks yet
        self.dendrites.track()
        for dendrite in self.dendrites.asList():
            self.assertTrue(dendrite.isOnTrack())       # each dendrite should belong to a track now
        tracks = [dendrite.getTrack() for dendrite in self.dendrites.asList()]
        tracks = set(tracks)
        self.assertEquals(2, len(tracks))               # there should be two tracks (of dendrites)
        colors = [Colors.colorToString(dendrite.roi.getStrokeColor()) for dendrite in self.dendrites.asList()]
        colors = set(colors)
        self.assertEquals(2, len(colors))               # the two tracks should have different colors
       
    
    def testReadDendritesFromString(self):
        self.addDendrites()
        dendritesStringOne = " 5634-2252=1,2,3; 1226-2562=4,5; 8373-1212=1,2"
        self.addRois()  
        spineMapping = self.dendrites.readDendritesFromString(dendritesStringOne)
        self.assertEquals(len(spineMapping.keys()), 3)              # The string should have been parsed into a dictonary with the dendrite ids as keys and lists of spines as values.
        self.assertEquals(len(spineMapping['5634-2252'].getSpines()), 3)
        self.assertEquals(len(spineMapping['1226-2562'].getSpines()), 2)
        self.assertEquals(len(spineMapping['8373-1212'].getSpines()), 2)
        self.assertEquals(spineMapping['1226-2562'].getSpines()[5].label, 5)
        self.assertEquals(spineMapping['8373-1212'].getSpines()[1].label, 1)
        
        
    def testGetSpineMapping(self):
        dendritesStringOne = " 5634-2252=1,2,3; 1226-2562=4,5; 8373-1212=1,2"
        self.segmentation.image.setProp('mricia-dendrites', dendritesStringOne)
        self.addRois()
        self.dendrites.readDendritesFromMetadata()
        spineMapping = self.dendrites.elements
        self.assertEquals(len(spineMapping.keys()), 3)
        self.assertEquals(len(spineMapping['5634-2252'].getSpines()), 3)
        self.assertEquals(len(spineMapping['1226-2562'].getSpines()), 2)
        self.assertEquals(len(spineMapping['8373-1212'].getSpines()), 2)
        self.assertEquals(spineMapping['1226-2562'].getSpines()[5].label, 5)
        self.assertEquals(spineMapping['8373-1212'].getSpines()[1].label, 1)
        
        
    def testGetElementByID(self):
        dendritesStringOne = " 5634-2252=1,2,3; 1226-2562=4,5; 8373-1212=1,2"
        self.segmentation.image.setProp('mricia-dendrites', dendritesStringOne)
        self.addRois()
        self.dendrites.readDendritesFromMetadata()
        spines = self.dendrites.getElementByID('1226-2562').getSpines().values()
        self.assertEquals(len(spines), 2)
        self.assertEquals(spines[0].label, 4)
        self.assertEquals(spines[1].label, 5)
        spines = self.dendrites.getElementByID('5634-2252').getSpines().values()
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
        dendrites = self.dendrites.elements        
        self.assertEquals(len(dendrites[id1].spines.values()), 3)
        self.assertEquals(len(dendrites[id2].spines.values()), 2)
       
        
    def testAddElement(self):
        dendrites = Dendrites(self.segmentation)
        d1 = Dendrite(self.dendriteGenerator.getROIs()[0])
        dendrites.addElement(d1, 1)
        self.assertTrue("-" in d1.getID())
        self.assertEquals(1, len(dendrites.elements.values()))
        self.assertEquals(1, dendrites.getElementByID(d1.getID()).getFrame())
        d2 = Dendrite(self.dendriteGenerator.getROIs()[1])
        d2.addSpine(Spine(3, self.segmentation.image))
        d2.addSpine(Spine(4, self.segmentation.image))
        dendrites.addElement(d2, 3)
        self.assertEquals(3, dendrites.getElementByID(d2.getID()).getFrame())
        self.assertEquals(2, len(dendrites.elements.values()))
        self.assertEquals(2, len(dendrites.getElementByID(d2.getID()).getSpines()))
        
                
    def testCreateSpineMappingString(self):
        dendrites = Dendrites(self.segmentation)
        d1 = Dendrite(self.dendriteGenerator.getROIs()[0])
        d1.addSpine(Spine(1, self.segmentation.image))
        d1.addSpine(Spine(2, self.segmentation.image))
        d1.addSpine(Spine(3, self.segmentation.image))
        d2 = Dendrite(self.dendriteGenerator.getROIs()[1])
        d2.addSpine(Spine(3, self.segmentation.image))
        d2.addSpine(Spine(4, self.segmentation.image))
        dendrites.addElement(d1, 1)
        dendrites.addElement(d2, 1)        
        string = self.dendrites.createSpineMappingString(dendrites.elements)
        self.assertTrue(d1.getID() + '=1,2,3' in string)
        self.assertTrue(d2.getID() + '=3,4' in string)
     
     
    def testAttachSpinesToClosestDendrite(self):
        self.addDendrites() 
        self.dendrites.track()
        self.dendrites.attachSpinesToClosestDendrite()
        dendritesByTime = self.dendrites.getByTime()
        for i in range(0, 4):
            d1 = dendritesByTime[i][0]
            d2 = dendritesByTime[i][1]
            if d1.getRoi().size() == 5:
                dt = d1
                d1 = d2
                d2 = dt
            self.assertTrue(d1.nrOfSpines()>6)
            self.assertTrue(d1.nrOfSpines()<9)
            self.assertTrue(d2.nrOfSpines()>4)
            self.assertTrue(d2.nrOfSpines()<6)
        d1 = dendritesByTime[4][0]
        d2 = dendritesByTime[4][1]
        if d1.getRoi().size() == 5:
            dt = d1
            d1 = d2
            d2 = dt
        self.assertEquals(0, d1.nrOfSpines())
        self.assertEquals(0, d2.nrOfSpines())
     
         
     
def suite():
    suite = unittest.TestSuite()

    suite.addTest(DendritesTest('testConstructorNoMetadata'))
    suite.addTest(DendritesTest('testAdd'))
    suite.addTest(DendritesTest('testMaxDistanceForTracking'))
    suite.addTest(DendritesTest('testTrack'))
    suite.addTest(DendritesTest('testReadDendritesFromString'))
    suite.addTest(DendritesTest('testGetSpineMapping'))
    suite.addTest(DendritesTest('testGetElementByID'))
    suite.addTest(DendritesTest('testGetDendrites'))
    suite.addTest(DendritesTest('testCreateSpineMappingString'))
    suite.addTest(DendritesTest('testAttachSpinesToClosestDendrite'))
    suite.addTest(DendritesTest('testAddElement'))
    return suite



def main(): 
    runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
    runner.run(suite())



if __name__ == "__main__":
    main()