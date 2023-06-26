import math
from ij.gui import Overlay
from ij.plugin import Colors
from java.awt import Color


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
            
    
    def add(self, roi, frame):
        """Add a new dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        roi.setPosition(0, 0, frame)
        self.overlay.add(roi)
        
        
    def setMaxDistanceForTracking(self, maxDist):
        self.maxDistanceForTracking = maxDist
        
        
    def getMaxDistanceForTracking(self):
        return self.maxDistanceForTracking
        
        
    def track(self):
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
       
                             

class Dendrite:
    "A dendrite has spines and can belong to a track."
     
    def __init__(self, roi):
       self.roi = roi
       self.track = 0
     
         
    def getFrame(self):
       return self.roi.getTPosition
       
         
    def getCenter(self):
       return (self.roi.getBounds().getCenterX(), self.roi.getBounds().getCenterY())
        
        
    def getTrack(self):
        return self.track
       
       
    def isOnTrack(self):
        return not self.track == 0
       
         
    def addToTrack(self, trackNr):
        self.track = trackNr
        self.roi.setGroup(trackNr)
        
        
    def resetTrack(self):
        self.track = 0
       
       
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