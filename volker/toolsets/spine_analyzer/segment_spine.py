###############################################################################################
##
## segment_spine.py
##
## Segment a single dendritic spine within the selection and add a corresponding new label to 
## a spine-label channel. The image can be 5D. The spine is segmented on the active channel within the
## active roi, replicated on each z-slice.
##
## (c) 2023 INSERM
##
## written by Volker Baecker at the MRI-Center for Image Analysis (MRI-CIA - https://www.mri.cnrs.fr/en/data-analysis.html)
##
## segment_spine.py is free software under the MIT license.
## 
## MIT License
##
## Copyright (c) 2023 INSERM
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.
## 
################################################################################################

import sys
import os
from ij import IJ
from ij import Prefs
from ij import ImagePlus
from ij.plugin import Duplicator
from ij.process import ImageStatistics
from ij.process import Blitter
from ij.process import AutoThresholder
from ij.plugin import LutLoader
from ij.process import LUT 
from ij.gui import  WaitForUserDialog
from ij.gui import Roi
from ij.gui import GenericDialog
from inra.ijpb.label import LabelImages


THRESHOLDING_METHOD = "Default"
THRESHOLDING_METHODS = AutoThresholder.getMethods()
LOOKUP_TABLE_NAME = "glasbey on dark"
LOOKUP_TABLE_NAMES = IJ.getLuts()
SAVE_OPTIONS = True

URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine_Analyzer";

LOOKUP_TABLE = LUT(LutLoader.getLut( LOOKUP_TABLE_NAME ), 0, 255);

def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    print(optionsOnly)
    if  not showDialog():
        return
    if optionsOnly=="true":
        return
    inputImage = IJ.getImage()
    currentC, currentZ, currentT = (inputImage.getC(), inputImage.getZ(), inputImage.getT())
    spineChannel = inputImage.getProp("spine-channel")
    if spineChannel and currentC == int(spineChannel):
        IJ.error("Please run the segmentation on a greyscale channel!")
        sys.exit()
    roi = inputImage.getRoi();
    if not roi:
        IJ.error("Please draw a ROI around a spine!")
        sys.exit()
    spineImage = segmentObjectInRegion(inputImage, roi)
    addSpine(inputImage, spineImage)
    spineImage.close()


def segmentObjectInRegion(image, roi):
    """Segment the largest 3D object in the region given by the roi. 
    Each slice is cleared outside of the 2D roi before the thresholding is done.
    """
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    image.killRoi()
    maskImage = Duplicator().run(image, currentC, currentC, 0, image.getNSlices()-1, currentT, currentT)
    for z in range(1, maskImage.getNSlices()+1):
        maskImage.getStack().getProcessor(z).fillOutside(roi)
    IJ.setAutoThreshold(maskImage, THRESHOLDING_METHOD + " dark stack");
    IJ.run(maskImage, "Convert to Mask", "method="+THRESHOLDING_METHOD+" background=Dark black")
    labelsImage = LabelImages.regionComponentsLabeling(maskImage, 255, 6, 8)
    labelsImage = LabelImages.keepLargestLabel(labelsImage)
    return labelsImage


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


def addSpine(image, spineImage):
    """Add the spine from the spineImage to the spine-channel of image. The new spine will have the next available index.
    """
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    spineChannel = image.getProp("spine-channel")
    if not spineChannel:
        channel = addEmptyChannel(image)
        image.setProp("spine-channel", channel)
        label = 1
    else:
        channel = int(spineChannel)
        image.setC(channel)
        stats = image.getStatistics(ImageStatistics.MIN_MAX)
        label = stats.max + 1
    copyStackTo(image, spineImage, channel, currentT, label)
    image.setPosition(currentC, currentZ, currentT);


def copyStackTo(image, stack, channel, frame, label):
    """Copy the stack into the given channel and frame of image. The slices of the stack are copied with a transparent zero.
    """
    LabelImages.replaceLabels(stack, [255], label)
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    offset = ((currentT-1) * nChannels*nSlices) + channel;
    for sliceNumber in range(1, stack.getStack().size()+1):
        image.getStack().getProcessor(offset + ((sliceNumber-1) * nChannels)).copyBits(stack.getStack().getProcessor(sliceNumber), 0, 0, Blitter.COPY_ZERO_TRANSPARENT)
    image.setC(channel)
    image.getChannelProcessor().setLut(LOOKUP_TABLE)
    image.getChannelProcessor().setMinAndMax(0, label)
    image.setPosition(currentC, currentZ, currentT)
    image.updateAndDraw()
   

def showDialog():
    global LOOKUP_TABLE_NAME, THRESHOLDING_METHOD, LOOKUP_TABLE, SAVE_OPTIONS
    
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Segment Spine Options"); 
    gd.addChoice("Auto-Thresholding Method: ", THRESHOLDING_METHODS, THRESHOLDING_METHOD)
    gd.addChoice("Lookup Table: ", LOOKUP_TABLE_NAMES, LOOKUP_TABLE_NAME)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    THRESHOLDING_METHOD = gd.getNextChoice()
    LOOKUP_TABLE_NAME = gd.getNextChoice()
    SAVE_OPTIONS = gd.getNextBoolean()
    LOOKUP_TABLE = LUT(LutLoader.getLut( LOOKUP_TABLE_NAME ), 0, 255);
    if SAVE_OPTIONS:
        saveOptions()
    return True
    
    
def getOptionsPath():
    pluginsPath = IJ.getDirectory("plugins");
    optionsPath = pluginsPath + "Spine-Analyzer/sass-options.txt";
    return optionsPath;


def getOptionsString():
    optionsString = ""
    lutName = LOOKUP_TABLE_NAME.replace(" ", "_");
    optionsString = optionsString + "auto-thresholding="+ THRESHOLDING_METHOD
    optionsString = optionsString + " lookup="+ lutName 
    return optionsString


def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
def loadOptions(): 
    global THRESHOLDING_METHOD, LOOKUP_TABLE_NAME
    
    optionsPath = getOptionsPath()
    optionsString = IJ.openAsString(optionsPath)
    optionsString = optionsString.replace("\n", "")
    options = optionsString.split(" ")
    for option in options:
        parts = option.split("=")
        key = parts[0]
        value = ""
        if "=" in option:
            value = parts[1]
        if key=="auto-thresholding":
            THRESHOLDING_METHOD = value
        if key=="lookup":
            LOOKUP_TABLE_NAME = value
            LOOKUP_TABLE_NAME = LOOKUP_TABLE_NAME.replace("_", " ")
    

main()


