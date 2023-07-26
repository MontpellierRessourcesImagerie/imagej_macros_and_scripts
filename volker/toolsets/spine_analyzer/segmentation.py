###############################################################################################
##
## segmentation.py
##
## The module contains classes representing segmentations of images. 
##
## (c) 2023 INSERM
##
## written by Volker Baecker at the MRI-Center for Image Analysis (MRI-CIA - https://www.mri.cnrs.fr/en/data-analysis.html)
##
## segmentation.py is free software under the MIT license.
## 
## MIT License
##
## Copyright (c) 2023 INSERM
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
## 
################################################################################################

from ij import IJ
from ij import ImagePlus
from ij.gui import NewImage
from ij.gui import WaitForUserDialog
from ij.measure import Calibration
from ij.plugin import LutLoader
from ij.plugin import Duplicator
from ij.process import LUT 
from ij.process import ImageStatistics
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils
from inra.ijpb.label import LabelImages
from inra.ijpb.measure.region3d import Centroid3D
from inra.ijpb.morphology.geodrec import GeodesicReconstruction3DHybrid0Gray16


class InstanceSegmentation:
    """An instance segmentation of the individual objects in an image, represented by labels in an additional channel.
    """
    
    DEFAULT_LUT_NAME = "glasbey_on_dark"
    DEFAULT_THRESHOLDING_METHOD = "Default"
    MAX_DISTANCE = 15
    
    
    def __init__(self, image):
        """Create a new instance segmentation for the given image. If the image already has a label-channel it is used for the
        instance segmentation, otherwise an empty label-channel is added to the image.
        """
        self.maxDistance = self.MAX_DISTANCE
        self.setLUT(self.DEFAULT_LUT_NAME)
        self.setThresholdingMethod(self.DEFAULT_THRESHOLDING_METHOD)
        self.image = image
        currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
        labelChannel = image.getProp("mricia-label-channel")
        if not labelChannel:
            self.labelChannelIndex = HyperstackUtils.addEmptyChannel(image)
            self.nextLabel = 1
            image.setProp("mricia-label-channel", self.labelChannelIndex)
        else:
            self.labelChannelIndex = int(labelChannel)
            roi = image.getRoi()
            image.killRoi()
            image.setC(self.labelChannelIndex)
            stats = image.getStatistics(ImageStatistics.MIN_MAX)
            if roi:
                image.setRoi(roi)
            self.nextLabel = stats.max + 1
        image.setPosition(currentC, currentZ, currentT)
        
        
    def getMaxDistance(self):
        return self.maxDistance
        
        
    def setMaxDistance(self, distance):
        self.maxDistance = distance
    
    
    def getLabelAt(self, x, y, z, frame):
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())
        self.image.setPosition( self.labelChannelIndex, z, frame)
        label = self.image.getProcessor().get(x ,y)
        self.image.setPosition(currentC, currentZ, currentT)    
        return label
        
    
    def getLabels(self):
        """Answer a list of the labels in the segmentation.
        """
        labels = set({})
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()
        for t in range(1, nFrames+1):
            self.image.setPosition(self.labelChannelIndex, currentZ, t)
            histo = self.image.getStatistics().histogram16[1:]
            currentLabels = [index+1 for (index, count) in enumerate(histo) if count>0]
            for label in currentLabels:
                labels.update((label, ))
        self.image.setPosition(currentC, currentZ, currentT)    
        labels = list(labels)
        return labels
    
    
    def addFromMask(self, mask):
        """Add the biggest connected object in the mask as a an object to the segmentation with the next unused label.
        """
        LabelImages.replaceLabels(mask, [255], self.nextLabel)
        HyperstackUtils.copyStackTo(self.image, mask, self.labelChannelIndex,  self.image.getT(), lut=self.lut)
        self.nextLabel = self.nextLabel + 1
        
    
    def addFromAutoThresholdInRoi(self, roi):
        """Create a 3D mask in the region of the 2D roi, using the auto-thresholding method.
        Add the biggest object to the segmentation.
        """
        mask = HyperstackUtils.segmentObjectInRegion(self.image, roi)
        self.addFromMask(mask)
        
    
    def replaceLabel(self, x, y, z, frame, newLabel):
        """Replace a label in a frame by another label. Also allows to delete a label by setting it to zero.
        """
        overwrite = (newLabel == 0)
        labels = Duplicator().run(self.image, self.labelChannelIndex, self.labelChannelIndex, 1, self.image.getNSlices(), frame, frame)
        width, height, nChannels, nSlices, nFrames = labels.getDimensions()
        label = int(labels.getStack().getVoxel(x, y, z))     
        if label == 0:
            IJ.log("Refusing to replace label 0!")
            return
        if not overwrite:
            seedImage = NewImage.createShortImage("seed", width, height, nSlices, NewImage.FILL_BLACK)
            seedImage.getStack().setVoxel(x, y, z, 65535)
            reconstructor = GeodesicReconstruction3DHybrid0Gray16(6)
            isolatedLabelStack = reconstructor.applyTo(seedImage.getStack(), labels.getStack())
            isolatedLabelImage = ImagePlus("isolated label", isolatedLabelStack)
            LabelImages.replaceLabels(isolatedLabelImage, [label], newLabel)
            HyperstackUtils.copyStackTo(self.image, isolatedLabelImage,  self.labelChannelIndex, frame, lut=self.lut, overwrite=False)
        else:
            LabelImages.replaceLabels(labels, [label], 0)
            HyperstackUtils.copyStackTo(self.image, labels,  self.labelChannelIndex, frame, lut=self.lut, overwrite=True) 
       
    
    def setLUT(self, lutName):
        """Set the lookup-table.
        """
        self.lutName = lutName
        self.lut = LUT(LutLoader.getLut( self.lutName ), 0, 255);
        
        
    def setThresholdingMethod(self, methodName):
        """Set the auto-thresholding method.
        """
        self.thresholdingMethod = methodName


    def getLabelChannelIndex(self):
        """Answer the (one based) index of the channel containing the labels"
        """
        return self.labelChannelIndex
    

    def getCopyOfLabelsChannel(self):
        """Answer a copy of the labels for the current frame.
        """
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())
        roi = self.image.getRoi()
        self.image.killRoi()
        labels = Duplicator().run(self.image, self.getLabelChannelIndex(), self.getLabelChannelIndex(), 1, self.image.getNSlices(), currentT, currentT) # currentT?
        self.image.setPosition(currentC, currentZ, currentT)    
        if roi:
            self.image.setRoi(roi)
        return labels
        
        
    def show(self):
        """Display the segmentation, by displaying the image that contains the channel with the labels."""
        self.image.show()
        
        
    def trackLabels(self):
        width, height, nChannels, nSlices, nFrames = self.image.getDimensions()
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())
        self.image.setT(nFrames)
        cal = self.image.getCalibration()
        tmpCal = Calibration()
        self.image.setCalibration(tmpCal)
        analyzer = Centroid3D()
        
        for frame in range(2, nFrames):
            imp = Duplicator().run(self.image, nChannels, nChannels, 1, nSlices, frame, frame);    
            measurementsCurrent = analyzer.analyzeRegions(imp)
            if len(measurementsCurrent.values()) < 1:
                continue
            imp2 = Duplicator().run(self.image, nChannels, nChannels, 1, nSlices, frame-1, frame-1);            
            measurementsPrevious = analyzer.analyzeRegions(imp2)
            closestLabels = {}
            maxDistance = self.getMaxDistance()
            for label in measurementsCurrent.keySet():
                point = measurementsCurrent.get(label)
                minDist = 9999999999999
                closestLabel = -1
                for otherLabel in measurementsPrevious.keySet():
                    otherPoint = measurementsPrevious.get(otherLabel)
                    dist = point.distance(otherPoint)
                    if dist < maxDistance and dist < minDist:
                        minDist = dist
                        closestLabel = otherLabel
                if closestLabel > -1:
                    closestLabels[label] = closestLabel
            for oldLabel, newLabel in closestLabels.items():
                LabelImages.replaceLabels(imp, [oldLabel], newLabel)
            HyperstackUtils.copyStackTo(self.image, imp, nChannels, frame)
        self.image.setCalibration(cal)
        self.image.setDisplayRange(0, 255)
        self.image.setPosition(currentC, currentZ, currentT)    
        self.image.updateAndDraw()