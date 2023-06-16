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
from ij.process import LUT 
from ij.plugin import LutLoader
from ij.process import ImageStatistics
from ij.plugin import Duplicator
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils
from inra.ijpb.label import LabelImages
from inra.ijpb.morphology.geodrec import GeodesicReconstruction3DHybrid0Gray16

from ij.gui import WaitForUserDialog

class InstanceSegmentation:
    """An instance segmentation of the individual objects in an image, represented by labels in an additional channel.
    """
    
    DEFAULT_LUT_NAME = "glasbey on dark"
    DEFAULT_THRESHOLDING_METHOD = "Default"
    
    
    def __init__(self, image):
        """Create a new instance segmentation for the given image. If the image already has a label-channel it is used for the
        instance segmentation, otherwise an empty label-channel is added to the image.
        """
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
        
    
    def getLabelAt(self, x, y, z, frame):
        currentC, currentZ, currentT = (self.image.getC(), self.image.getZ(), self.image.getT())
        image.setPosition( self.labelChannelIndex, z, frame)
        label = image.getProcessor().get(x ,y)
        image.setPosition(currentC, currentZ, currentT)    
        return label
        
                
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
        if not overwrite:
            seedImage = NewImage.createShortImage("seed", width, height, nSlices, NewImage.FILL_BLACK)
            seedImage.getStack().setVoxel(x, y, z, 65535)
            reconstructor = GeodesicReconstruction3DHybrid0Gray16(6)
            isolatedLabelStack = reconstructor.applyTo(seedImage.getStack(), labels.getStack())
            isolatedLabelImage = ImagePlus("isolated label", isolatedLabelStack)
            isolatedLabelImage.show()
            WaitForUserDialog("ok").show()
            LabelImages.replaceLabels(isolatedLabelImage, [label], newLabel)
            label = isolatedLabelImage
        LabelImages.replaceLabels(labels, [label], newLabel)
        HyperstackUtils.copyStackTo(self.image, labels,  self.labelChannelIndex, frame, lut=self.lut, overwrite=overwrite)
    
    
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
    
