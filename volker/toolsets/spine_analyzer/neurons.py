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
        self.elements = {}
        self.image = segmentation.image
        self.overlay = self.image.getOverlay()
        self.maxDistanceForTracking = 10
        if not self.overlay:
            self.overlay = Overlay()
            self.image.setOverlay(self.overlay)
        self.isReading = False
        self.readDendritesFromMetadata()
        
            
    def addElement(self, dendrite, frame):
        """Add a new  dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        dendrite.setFrame(frame)
        self.overlay.add(dendrite.roi)
        self.elements[dendrite.getID()] = dendrite
        dendrite.setParent(self)
        self.writeDendritesToImageMetadata()
        
        
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
    
    
    def getROIWithName(self, name):
        """Find and answer the roi with the given name in the overlay.
        """
        roi = None
        rois = self.image.getOverlay().toArray()
        for aRoi in rois:
            if aRoi.getName() == name:
                roi = aRoi
        return roi
        
    
    def getElementByID(self, anID):
        if not self.elements or not anID in self.elements:
            return None
        return self.elements[anID]
        
   
    def getByTime(self):
        """Answer an array containing a list of dendrites for each frame.
        """
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()              
        dendritesByTime = [[] for x in range(0, nFrames)]        
        for element in self.elements.values():
            t = element.roi.getTPosition()
            dendritesByTime[t-1].append(element)
        return dendritesByTime       
       
       
    def asList(self):
        return self.elements.values()
        
    
    def readDendritesFromMetadata(self):
        """Read the string defining the mapping of spines to dendrites from the image props
        and answer a dictionary with the dendrite ids as keys and lists of spines as values.
        """
        self.isReading = True
        spinesString = self.image.getProp("mricia-dendrites")
        if not spinesString:
            self.isReading = False
            return None
        self.elements = self.readDendritesFromString(spinesString)
        self.isReading = False


    def readDendritesFromString(self, spinesString):
        """Read the dendrites from a string of the form
               'dendriteID1=spineLabel1,spineLabel2,...;dendriteID2=spineLabel1,spineLabel2,...;...'
        """
        dendrites = {}
        if spinesString and len(spinesString) > 1:
            spinesString = spinesString.strip()
            spineStrings = spinesString.split(';')
            for spineString in spineStrings:
                parts = spineString.split('=')
                dendriteID = parts[0].strip()
                listString = parts[1].strip()
                spineLabels = [int(id) for id in listString.split(',')]
                spines = [Spine(label, self.image) for label in spineLabels]
                dendrite =  Dendrite(self.getROIWithName(dendriteID))
                dendrite.addSpines(spines)
                dendrites[dendriteID] = dendrite
        return dendrites       


    def writeDendritesToImageMetadata(self):
        if self.isReading:
            return
        self.writeSpineMapping(self.elements)


    def writeSpineMapping(self, spineMapping):
        spineMappingString = self.createSpineMappingString(spineMapping)
        self.segmentation.image.setProp("mricia-dendrites", spineMappingString)
            
    
    def createSpineMappingString(self, spineMapping):
        result = ""
        for key, dendrite in spineMapping.items():
            result = result + key + "="
            for valueIndex, value in enumerate(dendrite.getSpines().values()):
                result = result + str(value.getLabel())
                if valueIndex < len(dendrite.getSpines().values()) - 1:
                    result = result + ","
            if not key == spineMapping.keys()[-1]:
                result = result + ";"
        return result                
                
    
    def attachSpinesToClosestDendrite(self):
        width, height, nChannels, nSlices, nFrames =  self.image.getDimensions()
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())
        cal = self.image.getCalibration()
        tmpCal = Calibration()
        self.image.setCalibration(tmpCal)
        analyzer = Centroid3D()
        
        for frame in range(1, nFrames + 1):
            self.image.setT(frame)
            currentFrame = self.segmentation.getCopyOfLabelsChannel()
            measurements = analyzer.analyzeRegions(currentFrame)
            dendritesInFrame = self.getByTime()[frame-1]
            dendrites = self.elements.values()            
            for label, centroid in measurements.items():
                minDist = sys.maxsize
                closestDendrite = None
                for dendrite in dendritesInFrame:
                    distance = dendrite.distanceToPoint(centroid)
                    if distance < minDist:
                        minDist = distance
                        closestDendrite = dendrite
                if closestDendrite:
                    closestDendrite.addSpine(Spine(label,  self.image))
        self.image.setCalibration(cal)
        self.image.setPosition(currentC, currentZ, currentT)
        
        
class Dendrite:
    "A dendrite has spines and can belong to a track."

          
    def __init__(self, roi):
       image = roi.getImage()
       self.roi = roi.clone()
       self.roi.setImage(image)
       self.roi.setName(UUID.randomUUID().toString())
       self.spines = {}
       self.parent = None
     
    
    def setParent(self, dendrites):
        self.parent = dendrites
    
    
    def getID(self):
       return self.roi.getName()
    
    
    def getFrame(self):
       return self.roi.getTPosition()
       
    
    def setFrame(self, frame):
        self.roi.setPosition(0, 0, frame)
    
    
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
        if not self.parent:
            return
        self.parent.writeDendritesToImageMetadata()
            
            
    def nrOfSpines(self):
        return len(self.spines.keys())
    
    
    def getRoi(self):
        return self.roi
        
        
    
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
        
        
    def getLabel(self):
        return self.label