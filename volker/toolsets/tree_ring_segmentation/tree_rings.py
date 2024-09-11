import os
from java.awt import Color
from ij import IJ
from ij.gui import NewImage
from ij.gui import Roi
from ij.gui import PolygonRoi
from ij.gui import Overlay
from ij.gui import GenericDialog
from ij.plugin.filter import ThresholdToSelection
from inra.ijpb.morphology import Strel
from inra.ijpb.morphology.filter import Closing
from inra.ijpb.morphology.filter import InternalGradient
from inra.ijpb.morphology.filter import Dilation



class TreeTrunkGroundTruthHelper:


    def __init__(self, image):
        self.image = image
        self.ringsOnly = True
        self.closingRadius = 2
        self.gradiantRadius = 2
        self.dilationRadius = 1
        self.interval = 50
        self.closing = Closing(Strel.Shape.OCTAGON.fromRadius(self.closingRadius))
        self.internalGradient = InternalGradient(Strel.Shape.DISK.fromRadius(self.gradiantRadius))
        self.dilation = Dilation(Strel.Shape.DISK.fromRadius(self.dilationRadius))
        self.helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Tree-Ring-Tools"
    
    
    def createMaskFromRois(self):
        mask, overlay = self.createMaskWithOverlay()
        rois = []   
        for i in range(0, self.image.getOverlay().size()):
            roi = self.interpolateAndMakeBand(self.image.getOverlay().get(i))    
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
        tmp = NewImage.createByteImage ("tmp mask of rings", self.image.getWidth(), self.image.getHeight(), 1, NewImage.FILL_BLACK) 
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
                polygon.addPoint(polygon.xpoints[0], polygon.ypoints[0])
                
                
                
    def showCreateMaskFromRoisDialog(self, saveOptions):        
        if not os.path.exists(self.getCMFROptionsPath()):
            self.saveCMFROptions()
        else:
            self.readCMFROptionsFromFile()
        gd = GenericDialog("Create Maks From Rois Options")
        gd.addNumericField("Interval (roi interpolation):", self.interval)
        gd.addNumericField("Closing radius:", self.closingRadius)
        gd.addNumericField("Gradiant radius:", self.gradiantRadius)
        gd.addNumericField("Dilation radius:", self.dilationRadius)
        print("ringsOnly", self.ringsOnly)
        gd.addCheckbox("Rings only", self.ringsOnly)
        gd.addCheckbox("Save Options", saveOptions)
        gd.addHelp(self.helpURL)        
        gd.showDialog()
        if gd.wasCanceled():
            return False    
        self.interval = int(gd.getNextNumber())
        self.closingRadius = int(gd.getNextNumber())
        self.gradiantRadius = int(gd.getNextNumber())
        self.dilationRadius = int(gd.getNextNumber())
        self.ringsOnly = gd.getNextBoolean()
        self.saveOptions = gd.getNextBoolean()
        if saveOptions:
            self.saveCMFROptions()
        return True         
        
    
    def saveCMFROptions(self):
        options = "interval=" + str(self.interval) + " closing=" + str(self.closingRadius) + " gradiant=" + str(self.gradiantRadius) + " dilation=" + str(self.dilationRadius)
        if self.ringsOnly:
            options = options +  " rings"
        path = self.getCMFROptionsPath()
        with open(path, "w") as text_file:
            text_file.write(options) 
    
    
    def readCMFROptionsFromFile(self):
        optionsString = self.loadCFMROptions()
        options = optionsString.split(" ")
        for line in options:
            parts = line.split("=")
            name = parts[0]
            value = ""
            if len(parts) > 1:
                value = parts[1]
            if name == 'interval':
                self.interval = int(value)
            if name == 'closing':
                self.closingRadius = int(value)
            if name == 'gradiant':
                self.gradiantRadius = int(value)                
            if name == 'dilation':
                self.dilationRadius = int(value)
            self.ringsOnly = False
            if name == "rings":
                print("ring a ling a ling a ding dong");
                self.ringsOnly = True
                
                
    def loadCFMROptions(self):
        with open(self.getCMFROptionsPath(), "r") as optionsFile:
            optionsString = optionsFile.read().replace("\n", "")
        return optionsString
        
        
    def getCMFROptionsPath(self):
        path = os.path.join(IJ.getDir("plugins"), "mri-tree-rings-tool", "cmfr-options.txt")
        return path