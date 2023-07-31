import sys
import math
from java.awt import Color
from java.util import UUID
from ij.gui import Overlay
from ij.plugin import Colors
from ij.measure import Calibration
from inra.ijpb.measure.region3d import Centroid3D



class Dendrites:
    """Dendrites are represented as line rois in the overlay of the image.
    The spines are part of the segmentation"""
    

    def __init__(self, segmentation):
        """Create new dendrites from a (possibly empty) segmentation.
        """
        self.segmentation = segmentation
        self.image = segmentation.image
        self.overlay = self.image.getOverlay()
        self.maxDistanceForTracking = 10
        self.spineMapping = {}
        if not self.overlay:
            self.overlay = Overlay()
            self.image.setOverlay(self.overlay)
        self.readDendritesFromMetadata()
        
            
    def add(self, roi, frame):
        """Add a new  dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        roi = roi.clone()
        roi.setPosition(0, 0, frame)
        roi.setName(UUID.randomUUID().toString())
        self.overlay.add(roi)
        self.spineMapping[roi.getName()] = []
        
        
    def setMaxDistanceForTracking(self, maxDist):
        """Set the max. distance in physical units that a dendrite can have 
        moved between two frames.
        """
        self.maxDistanceForTracking = maxDist
        
        
    def getMaxDistanceForTracking(self):
        """Get the max. distance in physical units that a dendrite can have 
        moved between two frames.
        """
        return self.maxDistanceForTracking
        
        
    def track(self):
        """Track the dendrites. The dendrites in each frame will be assigned to groups. Each group represents a 
        dendrite over time. Each group will be displayed in a different color.
        """
        dendritesByTime = self.getByTime()
        for dendrites in dendritesByTime:
            for dendrite in dendrites:
                dendrite.resetTrack()
                
        currentTrack = 1
        for time, dendrites in zip(reversed(range(len(dendritesByTime))), list(reversed(dendritesByTime))):
            for dendrite in dendrites:     
                if not dendrite.isOnTrack():
                   dendrite.addToTrack(currentTrack)
                   currentTrack = currentTrack + 1                   
                dists = [dendrite.distanceTo(other) for other in dendritesByTime[time-1]]
                indexClosest = dists.index(min(dists))
                minDist = dists[indexClosest]
                if minDist < self.maxDistanceForTracking:
                   dendritesByTime[time-1][indexClosest].addToTrack(dendrite.getTrack())
        self.colorTracks()
        
        
    def colorTracks(self):
        """Color the dendrites according to the track they belong to.
        """
        colorNames = list(Colors.getColors())
        colorNames.remove(u'Black')
        colors = [Colors.decode(name) for name in colorNames]
        overlay = self.image.getOverlay()
        rois = overlay.toArray()
        for index, roi in enumerate(rois):
            roi.setStrokeColor(colors[roi.getGroup() % len(colors)]);
    
    
    def getDendrites(self):
        """Answer the dendrites as a list of Dendrite objects.
        """
        rois = self.image.getOverlay().toArray()
        dendrites = [Dendrite(roi) for roi in rois]
        for dendrite in dendrites:
            spines = self.getSpinesFor(dendrite)
            dendrite.addSpines(spines)
        return dendrites
        
    
    def getSpinesFor(self, dendrite):
        spineMapping = self.getSpineMapping()
        if not spineMapping:
            return None
        if dendrite.getID() in spineMapping:
            return spineMapping[dendrite.getID()]
        else:
            return []
    
   
    def getByTime(self):
        """Answer an array containing a list of dendrites for each frame.
        """
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()
        overlay = self.image.getOverlay()
        rois = overlay.toArray()
        
        minT = 999999999
        maxT = -999999999
        for i in range(0, len(rois)):
            roi = rois[i]
            roi.setImage(self.image)
            t = roi.getTPosition()
            if t > maxT:
                maxT = t
            if t < minT:
                minT = t
        
        dendritesByTime = [[] for x in range(0, nFrames)]        
        for i in range(0, len(rois)):
            t = rois[i].getTPosition()
            dendritesByTime[t-1].append(Dendrite(rois[i]))

        return dendritesByTime       
       
       
    def getSpineMapping(self):
        return self.spineMapping
        
    
    def readDendritesFromMetadata(self):
        """Read the string defining the mapping of spines to dendrites from the image props
        and answer a dictionary with the dendrite ids as keys and lists of spines as values.
        """
        spinesString = self.image.getProp("mricia-dendrites")
        if not spinesString:
            return None
        self.spineMapping = self.readDendritesFromString(spinesString)


    def readDendritesFromString(self, spinesString):
        """Read the dendrites from a string of the form
               'dendriteID1=spineLabel1,spineLabel2,...;dendriteID2=spineLabel1,spineLabel2,...;...'
        """
        spineMapping = {}
        if spinesString and len(spinesString) > 1:
            spinesString = spinesString.strip()
            spineStrings = spinesString.split(';')
            for spineString in spineStrings:
                parts = spineString.split('=')
                dendriteID = parts[0].strip()
                listString = parts[1].strip()
                spineLabels = [int(id) for id in listString.split(',')]
                spines = [Spine(label, self.image) for label in spineLabels]
                spineMapping[dendriteID] = spines
        return spineMapping       


    def writeDendritesToImageMetadata(self):
        pass
    

    def writeSpineMapping(self, spineMapping):
        spineMappingString = self.createSpineMappingString(spineMapping)
        self.segmentatio.image.setProp("mricia-dendrites", spineMappingString)
            
    
    def createSpineMappingString(self, spineMapping):
        result = ""
        for key, values in spineMapping.items():
            result = result + key + "="
            for valueIndex, value in enumerate(values):
                result = result + str(value)
                if valueIndex < len(values) - 1:
                    result = result + ","
            if not key == spineMapping.keys()[-1]:
                result = result + ";"
        return result                
                
    
    def attachSpinesToClosestDendrite(self):
        cal = self.image.getCalibration()
        tmpCal = Calibration()
        self.image.setCalibration(tmpCal)
        analyzer = Centroid3D()
        
        measurements = analyzer.analyzeRegions(self.image)
        
        dendrites = self.getDendrites()
        
        for label, centroid in measurements.items():
            minDist = sys.maxsize
            closestDendrite = None
            for dendrite in dendrites:
                distance = dendrite.distanceToPoint(centroid)
                if distance < minDist:
                    minDist = distance
                    closestDendrite = dendrite
            if closestDendrite:
                closestDendrite.addSpine(Spine(label,  self.image))
        self.image.setCalibration(cal)
        
        
    
class Dendrite:
    "A dendrite has spines and can belong to a track."

          
    def __init__(self, roi):
       self.roi = roi
       self.spines = {}
     
    
    def getID(self):
       return self.roi.getName()
    
    
    def getFrame(self):
       return self.roi.getTPosition()
       
         
    def getCenter(self):
       return (self.roi.getBounds().getCenterX(), self.roi.getBounds().getCenterY())
        
        
    def getTrack(self):
        return self.roi.getGroup()
       
       
    def isOnTrack(self):
        return not self.getTrack() == 0
       
         
    def addToTrack(self, trackNr):
        self.roi.setGroup(trackNr)
        
        
    def resetTrack(self):
        self.roi.setGroup(0)
       
       
    def distanceTo(self, other):
        pixelWidth = self.roi.getImage().getCalibration().pixelWidth;
        x1, y1 = self.getCenter()
        x2, y2 = other.getCenter()
        x1 = x1 * pixelWidth
        x2 = x2 * pixelWidth
        y1 = y1 * pixelWidth
        y2 = y2 * pixelWidth
        dx = x1 - x2
        dy = y1 - y2
        d = math.sqrt((dx * dx) + (dy * dy))
        return d
        
    
    def distanceToPoint(self, aPoint):
        points = self.roi.getContainedPoints()
        minDist = sys.maxsize
        for point in points:
            dx = point.getX() - aPoint.getX()
            dy = point.getY() - aPoint.getY()
            dist = math.sqrt((dx * dx) + (dy * dy))
            if dist < minDist:
                minDist = dist
        return minDist
        
    
    def addSpine(self, aSpine):
        self.spines[aSpine.label] = aSpine
        self.saveToMetadata()
        
    
    def addSpines(self, spines):
        if not spines:
            return
        for spine in spines:
            self.addSpine(spine)
            
    
    
    def getSpines(self):
        return self.spines
        
        
    def saveToMetadata(self):
        pass
            
    def readFromMetadata(self):        
        pass   
    
    
class Spine:
    """A dendritic spines is a tiny protrusions from a dendrite, 
    which forms functional contacts with neighboring axons of other neurons.
    A spine has a label, and a label mask"""
    
    def __init__(self, label, image):
        self.label = label
        self.image = image
        
        
    def __eq__(self, aSpine):
        if isinstance(aSpine, Spine):
            return (self.label, self.image) == (aSpine.label, aSpine.image)
        return NotImplemented
           
    
    def __hash__(self):
        return (hash(self.label) ^ hash(self.image))