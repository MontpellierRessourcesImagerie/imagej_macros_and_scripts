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
        if not self.overlay:
            self.overlay = Overlay()
            self.image.setOverlay(self.overlay)
        self.readSpinesFromImageMetadata()
        
            
    def add(self, roi, frame):
        """Add a new  dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        roi = roi.clone()
        roi.setPosition(0, 0, frame)
        roi.setName(UUID.randomUUID().toString())
        self.overlay.add(roi)
       
        
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
        colorNames = list(Colors.getColors())
        colorNames.remove(u'Black')
        colors = [Colors.decode(name) for name in colorNames]
        overlay = self.image.getOverlay()
        rois = overlay.toArray()
        for index, roi in enumerate(rois):
            roi.setStrokeColor(colors[roi.getGroup() % len(colors)]);
    
    
    def getDendrites(self):
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
        return spineMapping[dendrite.getID()]
    
   
    def getByTime(self):
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
        spinesString = self.image.getProp("mricia-dendrites")
        if not spinesString:
            return None
        return self.readSpinesFromString(spinesString)


    def readSpinesFromString(self, spinesString):
        spineMapping = {}
        if spinesString and len(spinesString) > 1:
            spinesString = spinesString.split(':')[1].strip()
            spineStrings = spinesString.split(';')
            for spineString in spineStrings:
                parts = spineString.split('=')
                dendriteID = parts[0].strip()
                listString = parts[1].strip()
                spineLabels = [int(id) for id in listString.split(',')]
                spines = [Spine(label, self.image) for label in spineLabels]
                spineMapping[dendriteID] = spines
        return spineMapping       


    def writeSpinesToImageMetadata(self):
        pass
    
    
    def attachSpinesToClosestDendrite(self):
        cal = self.image.getCalibration()
        tmpCal = Calibration()
        self.image.setCalibration(tmpCal)
        analyzer = Centroid3D()
        
        measurements = analyzer.analyzeRegions(image)
        
        print(measurements.values())
        
        overlay = image.getOverlay()
        dendrites = overlay.toArray()
        
        for label, centroid in measurements.items():
            minDist = sys.maxsize
            closestDendrite = None
            for dendrite in dendrites:
                dist = distance(dendrite, centroid)
                if dist < minDist:
                    minDist = dist
                    closestDendrite = dendrite
            print(label, closestDendrite.getGroup(), minDist)        
        self.image.setCalibration(cal)
    
    
    def addSpineToDendrite(label, roi):
        dendriteID = roi.getName()
        
    
    def readSpinesFromImageMetadata(self):
        pass
        
        
    
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
        
    
    def addSpine(self, aSpine):
        self.spines[aSpine.label] = aSpine
            
    
    def addSpines(self, spines):
        if not spines:
            return
        for spine in spines:
            self.addSpine(spine)
            
    
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