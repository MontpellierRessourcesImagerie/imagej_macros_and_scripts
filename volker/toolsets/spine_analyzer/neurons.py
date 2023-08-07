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
        self.readFromMetadata()
        
            
    def addElement(self, dendrite, addRoi=True):
        """Add a new  dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        if addRoi:
            self.overlay.add(dendrite.roi)
        self.elements[dendrite.getID()] = dendrite
        dendrite.setParent(self)
        self.writeToImageMetadata()
        
        
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
                if not dists:
                    continue
                indexClosest = dists.index(min(dists))
                minDist = dists[indexClosest]
                if minDist < self.maxDistanceForTracking:
                   dendritesByTime[time-1][indexClosest].addToTrack(dendrite.getTrack())
        self.colorTracks()
        self.image.updateAndDraw()
        
        
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
        roi.setImage(self.image)
        return roi
        
    
    def getElementByID(self, anID):
        if not self.elements or not anID in self.elements:
            return None
        return self.elements[anID]
        
   
    def getElementByTrackAndFrame(self, aTrack, aFrame):
        for element in self.elements:
            for dendrite in self.elements.values:
                if dendrite.getTrack() == aTrack and dendrite.getFrame() == aFrame:
                    return dendrite
        return None
    
    
    def getByTime(self):
        """Answer an array containing a list of dendrites for each frame.
        """
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()              
        dendritesByTime = [[] for x in range(0, nFrames)]        
        for element in self.elements.values():
            t = element.getFrame()
            dendritesByTime[t-1].append(element)
        return dendritesByTime       
       
       
    def asList(self):
        return self.elements.values()
        
    
    def readFromMetadata(self):
        """Read the string defining the mapping of spines to dendrites from the image props
        and answer a dictionary with the dendrite ids as keys and lists of spines as values.
        """
        self.isReading = True
        stringRepresentation = self.image.getProp("mricia-dendrites")
        if not stringRepresentation:
            self.isReading = False
            return None
        self.readFromString(stringRepresentation)
        self.isReading = False


    def readFromString(self, stringRepresentation):
        """Read the dendrites from a string of the form
               'dendriteID1=spineLabel1,spineLabel2,...;dendriteID2=spineLabel1,spineLabel2,...;...'
        """
        self.elements = {}
        if stringRepresentation and len(stringRepresentation) > 1:
            stringRepresentation = stringRepresentation.strip()
            dendriteStrings = stringRepresentation.split(';')
            for dendriteString in dendriteStrings:
                parts = dendriteString.split('=')
                dendriteID = parts[0].strip()
                dendrite = Dendrite(self.getROIWithName(dendriteID), id=dendriteID)
                self.addElement(dendrite, addRoi=False)
                listString = parts[1].strip()
                if listString:
                    spineLabels = [int(id) for id in listString.split(',')]
                    spines = [Spine(label, self.image) for label in spineLabels]
                    dendrite.addSpines(spines)


    def writeToImageMetadata(self):
        if self.isReading:
            return
        stringRepresentation = self.createStringRepresentation(self.elements)
        self.segmentation.image.setProp("mricia-dendrites", stringRepresentation)

    
    def createStringRepresentation(self, spineMapping):
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
        
        
    def getMeasurements(self):
        """Answer the measurements of the spines as a dictonary of the form:
        {Channel1: {Frame1: {label: (nrOfVoxels, volume, intDen, meanInt, min, max, stdDev, mode, kurtosis, skewness), ...
                    Frame2: {label: (nrOfVoxels, volume, intDen, meanInt, min, max, stdDev, mode, kurtosis, skewness), ...
                  ...
                    FrameN: {label: (nrOfVoxels, volume, intDen, meanInt, min, max, stdDev, mode, kurtosis, skewness), ...},
         Channel2: {Frame1: {label: (nrOfVoxels, volume, intDen, meanInt, min, max, stdDev, mode, kurtosis, skewness), ...
                  Frame2: {label: (nrOfVoxels, volume, intDen, meanInt, min, max, stdDev, mode, kurtosis, skewness), ...
                  ...
                  FrameN: {label: (nrOfVoxels, volume, intDen, meanInt, min, max, stdDev, mode, kurtosis, skewness), ...}}
        """                  
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())     
        labels = self.segmentation.getLabels()
        measurements = {}
        labelChannel = segmentation.getLabelChannelIndex()
        for channel in range(1, nChannels + 1):
            if channel == labelChannel:
                continue
            measurements[channel] = {}
            for label in labels:
                frames = {}
                for frame in range(1, nFrames + 1):
                    frames[frame] = []
                measurements[channel][frame] = frames               
        for channel in range(1, nChannels + 1):
            if channel == labelChannel:
                continue
            for frame in range(1, nFrames + 1):                
                measurements[channel][frame] = segmentation.measureLabelsForChannelAndFrame(channel, frame)        
        self.image.setPosition(currentC, currentZ, currentT)                
        return measurements
     
     
    def measure(self):
        measurements = self.getMeasurements()
        for element in self.elements:
            for spine in elements.getSpines():
                values = measurements[channel][element.getFrame()][spine.getLabel()]
                spine.nrOfPixels = values[0]
                spine.volume = values[1]
                spine.resetIntensityMeasurements()
                for channel in measurements.keys():
                    values = measurements[channel][element.getFrame()][spine.getLabel()]
                    intensityMeasurements = IntensityMeasurements(channel)
                    intensityMeasurements.intDen =  values[2]
                    intensityMeasurements.meanInt =  values[3]
                    intensityMeasurements.min =  values[4]
                    intensityMeasurements.max =  values[5]
                    intensityMeasurements.stdDev =  values[6]
                    intensityMeasurements.mode =  values[7]
                    intensityMeasurements.kurtosis =  values[8]
                    intensityMeasurements.skewness =  values[9]
                    spine.addIntensityMeasurements(intensityMeasurements)
        
                
    def report(self):
        table = ResultsTable()
        dendritesByTime = self.getByTime()
        for frame in dendritesByTime:
            for dendrite in frame:
                dendrite.addToReport(table)
  
  
class Dendrite:
    """A dendrite has spines and can belong to a track. Dendrites on the same track are the same
    dendrite at different timepoints."""

          
    def __init__(self, roi, id=None):
       """When a dendrite is created without an id, the roi will be cloned and an id will be created. 
       Otherwise the roi object is directly used, so that the roi is the same object as the one in the 
       overlay, when the dendrites are re-created from the text in the metadata.
       """
       self.image = roi.getImage()
       if id is None:
            self.roi = roi.clone()
            self.roi.setName(UUID.randomUUID().toString())
       else:
            self.roi = roi
            self.roi.setName(id)
       self.roi.setImage(self.image)
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
        pixelWidth = self.image.getCalibration().pixelWidth
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
        self.parent.writeToImageMetadata()
        
            
    def nrOfSpines(self):
        return len(self.spines.keys())
    
    
    def getRoi(self):
        return self.roi
        
        
    def getSpine(self, aLabel):
        return self.spines[aLabel]
       
       
    def sortedSpines(self):
        return sorted(self.spines.items())
    
    
    def addToReport(self, table):
        spines = self.sortedSpines()
        for spine in spines:
            table.addRow()
            table.addValue("Dendrite", self.getTrack())
            table.addValue("Frame", self.getFrame())
            spine.addToReport(table)
        
        
        
class Spine:
    """A dendritic spines is a tiny protrusions from a dendrite, 
    which forms functional contacts with neighboring axons of other neurons.
    A spine has a label, and a label mask"""
    
    
    def __init__(self, label, image):
        self.label = label
        self.image = image
        self.nrOfVoxels = float('NaN')
        self.volume = float('NaN')
        self.intensityMeasurement = []
        
        
    def __eq__(self, aSpine):
        if isinstance(aSpine, Spine):
            return (self.label, self.image) == (aSpine.label, aSpine.image)
        return NotImplemented
           
    
    def __hash__(self):
        return (hash(self.label) ^ hash(self.image))
        
        
    def getLabel(self):
        return self.label
        
        
    def resetIntensityMeasurements(self):
        self.intensityMeasurements = []
        
        
    def addIntensityMeasurement(self, aMeasurement):
        self.intensityMeasurements.append(aMeasurement)
        
        
    def addtoReport(self, table):
        table.addValue("Label", self.getLabel())
        table.addValue("Nr. of Voxels", self.nrOfVoxels)
        table.addValue("Volume", self.volume)
        for measurements in self.intensityMeasurements:
            measurements.addToReport(table)
        
        
 
class IntensityMeasurements:


    def __init__(self, channel):
        self.channel = channel
        self.intDen = float('NaN')
        self.meanInt = float('NaN')
        self.stdDev = float('NaN')
        self.min = float('NaN')
        self.max = float('NaN')
        self.mode = float('NaN')
        self.kurtosis = float('NaN')
        self.skewness = float('NaN')
        
        
    def addToReport(self, table):
        table.addValue("IntDen (C" + self.channel + ")", self.intDen)
        table.addValue("Mean (C" + self.channel + ")", self.meanInt)
        table.addValue("StdDev (C" + self.channel + ")", self.stdDev)
        table.addValue("Min (C" + self.channel + ")", self.min)
        table.addValue("Max (C" + self.channel + ")", self.max)
        table.addValue("Mode (C" + self.channel + ")", self.mode)
        table.addValue("Kurtosis" + self.channel + ")", self.kurtosis)
        table.addValue("Skewness (C" + self.channel + ")", self.skewness)
        