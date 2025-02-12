import os
from java.awt import Color
from ij import IJ
from ij import ImagePlus
from ij.gui import NewImage
from ij.gui import Roi
from ij.gui import PolygonRoi
from ij.gui import Overlay
from ij.gui import GenericDialog
from ij.plugin import Duplicator
from ij.plugin import RoiEnlarger
from ij.plugin import Scaler
from ij.plugin.filter import ThresholdToSelection
from ij.process import AutoThresholder
from ij.process import ImageConverter
from sc.fiji.colourDeconvolution import StainMatrix
from inra.ijpb.binary import BinaryImages
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling
from inra.ijpb.label import LabelImages
from inra.ijpb.label.select import LabelSizeFiltering
from inra.ijpb.label.select import RelationalOperator
from inra.ijpb.measure.region2d import BoundingBox
from inra.ijpb.morphology import Reconstruction
from inra.ijpb.morphology import Strel
from inra.ijpb.morphology.filter import Closing
from inra.ijpb.morphology.filter import InternalGradient
from inra.ijpb.morphology.filter import Dilation
from inra.ijpb.morphology.filter import Opening



class TreeTrunkGroundTruthHelper:
    ''' The ground truth comes in the form of manually created rois. This tool creates binary masks from the rois. 
        These masks can then be used to train a machine learning classifier.
    '''

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
                self.ringsOnly = True
                
                
    def loadCFMROptions(self):
        with open(self.getCMFROptionsPath(), "r") as optionsFile:
            optionsString = optionsFile.read().replace("\n", "")
        return optionsString
        
        
    def getCMFROptionsPath(self):
        path = os.path.join(IJ.getDir("plugins"), "mri-tree-rings-tool", "cmfr-options.txt")
        return path
        
        

class TreeRingAnalyzer:
    ''' Segment the trunk and the pith. There are no methods for the annual rings or the bark here, since machine learning is used for their segmentation.
    '''
    
    def __init__(self, image):
        self.image = image
        self.width, self.height, self.nChannels, self.nSlices, self.nFrames = self.image.getDimensions() 
        self.scaledDownMask = None
        self.helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Tree-Ring-Tools" 
        # Options
        self.scaleFactor = 8
        self.sigma = 2
        self.thresholdingMethod = "Mean"
        self.thresholdingMethods = AutoThresholder.getMethods()
        self.openingRadius = 16
        self.closingRadius = 8
        self.strokeWidth = 8
        self.interpolationInterval = 100
            # R1, G1, B1, R2, G2, B2, R3, G3, B3
        self.vectors = (0.7372839, 0.63264143, 0.23701741,
                          0.91958255, 0.35537627, 0.16755785,
                           0.69067574, 0.64728355, 0.3224746)
            # R1, G1, B1, R2, G2, B2, R3, G3, B3
        self.barkVectors = (0.7898954, 0.5587874, 0.25262988,
                            0.5932292, 0.7353205, 0.3276933,
                            0.57844025, 0.5767322, 0.5768768)          
        self.doPithSegmentation = False                            
        self.pithMinSize = 200
        
        
    def run(self):
        self.segmentTrunk()
        if self.doPithSegmentation:
            self.segmentPith()
        
        
    def getScaledDownMask(self):
        if not self.scaledDownMask:
            self.createScaledDownMask()
        return self.scaledDownMask
    
    
    def createScaledDownMask(self):
        image = Duplicator().run(self.image, 1, self.nChannels, 1, self.nSlices, 1, self.nFrames)
        ImageConverter(image).convertToGray8()
        self.scaledDownMask = self.calculateScaledDownMask(image)
    
    
    def calculateScaledDownMask(self, image):
        mask = image
        mask = Scaler.resize(mask, self.width/self.scaleFactor, self.height/self.scaleFactor, 1, 'bilinear')
        mask.getProcessor().blurGaussian(self.sigma)
        mask.getProcessor().setAutoThreshold(self.thresholdingMethod)
        mask.setProcessor(mask.getProcessor().createMask())
        return mask
    
    
    def segmentTrunk(self):
        strel = Strel.Shape.DISK.fromRadius(self.openingRadius)
        self.image.setRoi(None)               
        image = self.getScaledDownMask()
        image = Duplicator().run(image, 1, self.nChannels, 1, self.nSlices, 1, self.nFrames)
        ip = BinaryImages.keepLargestRegion(image.getProcessor())
        ip = Reconstruction.fillHoles(ip)
        ip = Opening(strel).process(ip)
        image.setProcessor(ip)
        image = Scaler.resize(image, self.width, self.height, 1, 'bilinear')
        image.getProcessor().setThreshold(1, 255)
        roi = ThresholdToSelection.run(image)
        image.close()
        roi = RoiEnlarger.enlarge(roi, -self.openingRadius/2)
        poly = roi.getInterpolatedPolygon(-100, True)
        roi = PolygonRoi(poly, Roi.POLYGON)
        roi.setName("bark - outer border")
        roi.setStrokeWidth(self.strokeWidth)
        self.addRoiToOverlay(roi)
        
    
    def addRoiToOverlay(self, roi):
        overlay = self.image.getOverlay()
        if not overlay:
            overlay = Overlay()
        overlay.add(roi)
        self.image.setOverlay(overlay)
    
    
    def segmentPith(self):
        closingStrel = Strel.Shape.DISK.fromRadius(self.closingRadius)
        componentsLabeling = FloodFillComponentsLabeling(4, 16)
        sm = ()
        sm.init("wood", *self.vectors)
        labelFiltering = LabelSizeFiltering(RelationalOperator.GT, self.pithMinSize)        
        stack = sm.compute(False, True, self.image)
        imp = ImagePlus(self.image.getTitle() + "-(Colour_2)", stack[1])
        mask = self.calculateScaledDownMask(imp)        
        labelsProcessor = componentsLabeling.computeLabels(mask.getProcessor())
        labelsProcessor = labelFiltering.process(labelsProcessor)
        LabelImages.remapLabels(labelsProcessor)
        labels = LabelImages.findAllLabels(labelsProcessor)
        label = self.getLabelClosestToCenter(labelsProcessor, labels)
        ip = LabelImages.binarize(labelsProcessor, label)
        ip = Closing(closingStrel).process(ip)
        image = ImagePlus("segmented", ip)
        image = Scaler.resize(image, self.width, self.height, 1, 'bilinear')
        image.getProcessor().setThreshold(1, 255)
        roi = ThresholdToSelection.run(image)
        image.close()
        roi.setName("pith - outer border")
        roi.setStrokeWidth(self.strokeWidth)
        self.addRoiToOverlay(roi)
        
    
    def segmentBark(self):
        sm = StainMatrix()
        sm.init("bark", *self.barkVectors)
        stack = sm.compute(False, True, self.image)
        
        
    def getLabelClosestToCenter(self, labelsProcessor, labels):
        boxes = BoundingBox.boundingBoxes(labelsProcessor, labels, None)
        imageCenterX = labelsProcessor.getWidth() / 2.0
        imageCenterY = labelsProcessor.getHeight() / 2.0
        closestDistance = 2 * self.width * self.width
        closestIndex = -1
        index = 1
        for box in boxes:
            x = box.getXMin()
            y = box.getYMin()
            deltaX = x - imageCenterX
            deltaY = y - imageCenterY
            dist = (deltaX*deltaX) + (deltaY*deltaY)
            if dist < closestDistance:
                closestDistance = dist
                closestIndex = index
            index = index + 1
        return closestIndex
        
        
    def showDialog(self, saveOptions):        
        if not os.path.exists(self.getTRAOptionsPath()):
            self.saveTRAOptions()
        else:
            self.readTRAOptionsFromFile()
        gd = GenericDialog("Tree Ring Analyzer Options")
        gd.addNumericField("Scale Factor:", self.scaleFactor)
        gd.addNumericField("Sigma:", self.sigma)
        gd.addChoice("Thresholding Method:", self.thresholdingMethods, self.thresholdingMethod)
        gd.addNumericField("Opening Radius:", self.openingRadius)
        gd.addNumericField("Closing Radius:", self.closingRadius)
        gd.addNumericField("Stroke Width:", self.strokeWidth)
        gd.addNumericField("Interpolation Interval:", self.interpolationInterval)
        gd.addStringField("Vectors", ",".join([str(x) for x in self.vectors]), 96)
        gd.addStringField("Bark Vectors", ",".join([str(x) for x in self.barkVectors]), 96)
        gd.addNumericField("Min. Pith Size:", self.pithMinSize)
        
        gd.addCheckbox("Do Pith Segmentation", self.doPithSegmentation)
        gd.addCheckbox("Save Options", saveOptions)
        gd.addHelp(self.helpURL)        
        gd.showDialog()
        if gd.wasCanceled():
            return False    
        self.scaleFactor = int(gd.getNextNumber())
        self.sigma = float(gd.getNextNumber())
        self.thresholdingMethod = gd.getNextChoice()
        self.openingRadius = int(gd.getNextNumber())
        self.closingRadius = int(gd.getNextNumber())
        self.strokeWidth = int(gd.getNextNumber())
        self.interpolationInterval = int(gd.getNextNumber())
        vectorText = gd.getNextString()
        self.vectors = tuple([float(x) for x in vectorText.split(",")])
        barkVectorText = gd.getNextString()
        self.barkVectors = tuple([float(x) for x in barkVectorText.split(",")])
        self.doPithSegmentation = gd.getNextBoolean()
        self.saveOptions = gd.getNextBoolean()
        if saveOptions:
            self.saveTRAOptions()
        return True
        
        
    def saveTRAOptions(self):
        options = "scale=" + str(self.scaleFactor) + \
                  " sigma=" + str(self.sigma) + \
                  " thresholding=" + self.thresholdingMethod + \
                  " opening=" + str(self.openingRadius) + \
                  " closing=" + str(self.closingRadius) + \
                  " stroke=" + str(self.strokeWidth) + \
                  " interpolation=" + str(self.interpolationInterval) + \
                  " vectors=" + ",".join([str(x) for x in self.vectors]) + \
                  " bark=" + ",".join([str(x) for x in self.barkVectors]) + \
                  " min=" + str(self.pithMinSize)
        if self.doPithSegmentation:
            options = options + " do"
        path = self.getTRAOptionsPath()
        with open(path, "w") as text_file:
            text_file.write(options) 
    
    
    def readTRAOptionsFromFile(self):
        optionsString = self.loadTRAOptions()
        options = optionsString.split(" ")
        for line in options:
            parts = line.split("=")
            name = parts[0]
            value = ""
            if len(parts) > 1:
                value = parts[1]
            if name == 'scale':
                self.scaleFactor = int(value)
            if name == 'sigma':
                self.sigma = float(value)
            if name == 'thresholding':
                self.thresholdingMethod  = value
            if name == 'opening':
               self.openingRadius = int(value)
            if name == 'closing':
                self.closingRadius = int(value)
            if name == 'stroke':
                self.strokeWidth = int(value)    
            if name == 'interpolation':
                self.interpolationInterval = int(value)
            if name == 'vectors':
                self.vectors = tuple([float(x) for x in value.split(",")])
            if name == 'bark':
                self.barkVectors = tuple([float(x) for x in value.split(",")])    
            if name == 'min':
                self.pithMinSize = int(value)
            self.doPithSegmentation = False
            if name == "do":
                self.doPithSegmentation = True
                
                
    def loadTRAOptions(self):
        with open(self.getTRAOptionsPath(), "r") as optionsFile:
            optionsString = optionsFile.read().replace("\n", "")
        return optionsString
        
        
    def getTRAOptionsPath(self):
        path = os.path.join(IJ.getDir("plugins"), "mri-tree-rings-tool", "tra-options.txt")
        return path