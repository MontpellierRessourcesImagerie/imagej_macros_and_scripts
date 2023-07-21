###############################################################################################
##
## HyperstackUtils.py
##
## Utility methods for working with 5D-images (Hyperstacks)
##
## (c) 2023 INSERM
##
## written by Volker Baecker at the MRI-Center for Image Analysis (MRI-CIA - https://www.mri.cnrs.fr/en/data-analysis.html)
##
## HyperstackUtils.py is free software under the MIT license.
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
    def copyStackTo(image, stack, channel, frame, lut=None, overwrite=False):
        """Copy the stack into the given channel and frame of image. 
        The slices of the stack are copied with a transparent zero if overwrite is false.
        """
        currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
        width, height, nChannels, nSlices, nFrames = image.getDimensions()
        offset = ((currentT-1) * nChannels*nSlices) + channel
        pasteMethod = Blitter.COPY_ZERO_TRANSPARENT
        if overwrite:
            pasteMethod = Blitter.COPY
        for sliceNumber in range(1, stack.getStack().size()+1):
            image.getStack().getProcessor(offset + ((sliceNumber-1) * nChannels)).copyBits(stack.getStack().getProcessor(sliceNumber), 0, 0, pasteMethod)
        image.setC(channel)
        if lut:
            image.getChannelProcessor().setLut(lut)
        IJ.resetMinAndMax(image);    
        image.setPosition(currentC, currentZ, currentT)
        image.updateAndDraw()
        
        
    @staticmethod
    def segmentObjectInRegion(image, roi, method="Default"):
        """Segment the largest 3D object in the region given by the roi. 
        Each slice is cleared outside of the 2D roi before the thresholding is done.
        """
        currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
        image.killRoi()
        maskImage = Duplicator().run(image, currentC, currentC, 1, image.getNSlices(), currentT, currentT)
        for z in range(1, maskImage.getNSlices()+1):
            maskImage.getStack().getProcessor(z).fillOutside(roi)
        IJ.setAutoThreshold(maskImage, method + " dark stack");
        IJ.run(maskImage, "Convert to Mask", "method="+method+" background=Dark black")
        labelsImage = LabelImages.regionComponentsLabeling(maskImage, 255, 6, 8)
        labelsImage = LabelImages.keepLargestLabel(labelsImage)
        return labelsImage
   
    