from java.awt import Color
from ij.gui import NewImage
from ij.gui import Roi
from ij.gui import PolygonRoi
from ij.gui import Overlay
from ij.plugin.filter import ThresholdToSelection
from inra.ijpb.morphology import Strel
from inra.ijpb.morphology.filter import Closing
from inra.ijpb.morphology.filter import InternalGradient
from inra.ijpb.morphology.filter import Dilation



class TreeTrunkGroundTruthHelper:


    def __init__(self, image):
        self.image = image
        self.ringsOnly = True
        self.closing_radius = 2
        self.gradiant_radius = 2
        self.dilation_radius = 1
        self.interval = 50
        self.closing = Closing(Strel.Shape.OCTAGON.fromRadius(self.closing_radius))
        self.internalGradient = InternalGradient(Strel.Shape.DISK.fromRadius(self.gradiant_radius))
        self.dilation = Dilation(Strel.Shape.DISK.fromRadius(self.dilation_radius))
    
    
    def createMaskFromRois(self):
        mask, overlay = self.createMaskWithOverlay()
        rois = []   
        for i in range(0, overlay.size()):
            roi = self.interpolateAndMakeBand(overlay.get(i))    
            rois.append(roi)
        if self.ringsOnly:
            rois = self.removeSmallestAndBiggestRing(rois)                             
        for roi in rois:
            overlay.add(roi)
        mask.setRoi(None)   
        mask.getOverlay().fill(mask, Color.WHITE, Color.BLACK)
        mask.setOverlay(None)
        return mask
        
        
    def removeSmallestAndBiggestRing(self, rois):
        newRois = []
        smallestIndex = -1
        biggestIndex = -1
        smallestLength = self.image.getWidth() * self.image.getHeight()
        biggestLength = 0
        for index, roi in enumerate(rois):
            length = roi.getLength()
            if length < smallestLength:
                smallestLength = length
                smallestIndex = index
            if length > biggestLength:
                biggestLength = length
                biggestIndex = index
        toBeRemoved = [smallestIndex, biggestIndex]
        for index, roi in enumerate(rois):
            if index in toBeRemoved:
                continue
            newRois.append(roi)
        return newRois
        
        
    def interpolateAndMakeBand(self, roi):
        tmp = NewImage.createByteImage ("tmp mask of rings", image.getWidth(), image.getHeight(), 1, NewImage.FILL_BLACK) 
        poly = roi.getInterpolatedPolygon(self.interval, True)
        self.closePolygon(poly)
        roi = PolygonRoi(poly, Roi.POLYGON)
        tmp.setRoi(roi)
        tmpMask = tmp.createRoiMask()
        ip = self.closing.process(tmpMask)
        ip = self.internalGradient.process(ip)
        ip = self.dilation.process(ip)
        ip.setThreshold(1, 255)
        tmp.setProcessor(ip)
        roi = ThresholdToSelection().run(tmp)
        return roi
            
            
    def createMaskWithOverlay(self):
        mask = NewImage.createByteImage ("mask of rings", self.image.getWidth(), self.image.getHeight(), 1, NewImage.FILL_BLACK)        
        overlay = Overlay()
        mask.setOverlay(overlay)
        return mask, overlay
        
        
    def closePolygon(self, polygon):
        if not polygon.xpoints[-1] == polygon.xpoints[0] or not polygon.ypoints[-1] == polygon.ypoints[0]:
                polygon.addPoint(poly.xpoints[0], poly.ypoints[0])