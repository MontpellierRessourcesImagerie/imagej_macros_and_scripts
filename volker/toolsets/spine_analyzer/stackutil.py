###############################################################################################
##
## stackutil.py
##
## Utility methods for working with 5D-images (Hyperstacks)
##
## (c) 2023 INSERM
##
## written by Volker Baecker at the MRI-Center for Image Analysis (MRI-CIA - https://www.mri.cnrs.fr/en/data-analysis.html)
##
## stackutil.py is free software under the MIT license.
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
from ij import Prefs
from ij.plugin import Duplicator
from ij.process import Blitter
from inra.ijpb.label import LabelImages


class HyperstackUtils:
    """ A collection of utility methods for working with 5D-images (Hyperstacks)
    """
    @staticmethod
    def addEmptyChannel(image):
        """Add a new, empty channel to the image and restore the original position.
        """
        image.setDisplayMode(IJ.COMPOSITE);
        width, height, nChannels, nSlices, nFrames  = image.getDimensions()
        currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
        image.setPosition(nChannels, currentZ, currentT)
        IJ.run(image, "Add Slice", "add=channel")
        image.setPosition(currentC, currentZ, currentT)
        return nChannels + 1
    
    
    @staticmethod
    def copyStackTo(image, stack, channel, frame, lut=None, overwrite=False, startSlice=None, endSlice=None):
        """Copy the stack into the given channel and frame of image. 
        The slices of the stack are copied with a transparent zero if overwrite is false.
        """
        currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
        width, height, nChannels, nSlices, nFrames = image.getDimensions()
        offset = ((frame-1) * nChannels*nSlices) + channel
        pasteMethod = Blitter.COPY_ZERO_TRANSPARENT
        if overwrite:
            pasteMethod = Blitter.COPY
        rangeStart = startSlice    
        if not rangeStart:
            rangeStart = 1
        rangeEnd = endSlice
        if not rangeEnd:
            rangeEnd = stack.getStack().size()
        stackSliceNumber = 1
        for sliceNumber in range(rangeStart, rangeEnd + 1): 
            image.getStack().getProcessor(offset + ((sliceNumber-1) * nChannels)).copyBits(stack.getStack().getProcessor(stackSliceNumber), 0, 0, pasteMethod)
            stackSliceNumber = stackSliceNumber + 1
        image.setC(channel)
        if lut:
            image.getChannelProcessor().setLut(lut)
        IJ.resetMinAndMax(image);    
        image.setPosition(currentC, currentZ, currentT)
        image.updateAndDraw()
        
        
    @staticmethod
    def segmentObjectInRegion(image, roi, method="Default", firstZ=None, lastZ=None, threshold=None):
        """Segment the largest 3D object in the region given by the roi. 
        Each slice is cleared outside of the 2D roi before the thresholding is done.
        """
        currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
        startSlice = 1
        endSlice = image.getNSlices()
        if firstZ:
           startSlice = firstZ
        if lastZ:
           endSlice = lastZ 
        image.killRoi()
        maskImage = Duplicator().run(image, currentC, currentC, startSlice, endSlice, currentT, currentT)
        for z in range(1, maskImage.getNSlices()+1):
            processor = maskImage.getStack().getProcessor(z)
            processor.fillOutside(roi)
        if threshold:
            IJ.setRawThreshold(maskImage, threshold, 65535)
            IJ.run(maskImage, "Convert to Mask", "background=Dark Black")
        else:
            IJ.setAutoThreshold(maskImage, method + " dark stack");
            IJ.run(maskImage, "Convert to Mask", "method="+method+" background=Dark black")
        labelsImage = LabelImages.regionComponentsLabeling(maskImage, 255, 6, 32)
        labelsImage = LabelImages.keepLargestLabel(labelsImage)
        return labelsImage
   

    