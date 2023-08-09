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
from ij.process import AutoThresholder
from ij.gui import GenericDialog
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


SPINE_SEGMENTATION_CHANNEL = 1
THRESHOLDING_METHOD = "Default"
THRESHOLDING_METHODS = AutoThresholder.getMethods()
LOOKUP_TABLE_NAME = "glasbey on dark"
LOOKUP_TABLE_NAMES = IJ.getLuts()
START_SLICE = 0
END_SLICE = 0
SAVE_OPTIONS = True

URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine_Analyzer";


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if  not showDialog():
        return
    if optionsOnly=="true":
        return
    inputImage = IJ.getImage()
    currentC = inputImage.getC()
    originalC = currentC
    if SPINE_SEGMENTATION_CHANNEL > 0:
        inputImage.setC(SPINE_SEGMENTATION_CHANNEL)
        currentC = SPINE_SEGMENTATION_CHANNEL
    segmentation = InstanceSegmentation(inputImage)    
    spineChannel = segmentation.getLabelChannelIndex()
    if spineChannel and currentC == spineChannel:
        IJ.error("Please run the segmentation on a greyscale channel!")
        sys.exit()
    roi = inputImage.getRoi();
    if not roi:
        IJ.error("Please draw a ROI around a spine!")
        sys.exit()
    segmentation.setThresholdingMethod(THRESHOLDING_METHOD)
    segmentation.setLUT(LOOKUP_TABLE_NAME)
    if START_SLICE and END_SLICE and END_SLICE>=START_SLICE:
        segmentation.addFromAutoThresholdInRoi(roi, firstZ=START_SLICE, lastZ=END_SLICE)
    else:
        segmentation.addFromAutoThresholdInRoi(roi)
    inputImage.setC(spineChannel)
    inputImage.setDisplayRange(0, 255)
    inputImage.setC(originalC)
    inputImage.updateAndDraw()


def showDialog():
    global LOOKUP_TABLE_NAME, THRESHOLDING_METHOD, LOOKUP_TABLE, SAVE_OPTIONS, SPINE_SEGMENTATION_CHANNEL, START_SLICE, END_SLICE
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Segment Spine Options"); 
    gd.addNumericField("Spine Segmetation Channel (0 for active): ", SPINE_SEGMENTATION_CHANNEL)
    gd.addChoice("Auto-Thresholding Method: ", THRESHOLDING_METHODS, THRESHOLDING_METHOD)
    gd.addChoice("Lookup Table: ", LOOKUP_TABLE_NAMES, LOOKUP_TABLE_NAME)
    gd.addNumericField("Start Slice (0 for first): ", START_SLICE)
    gd.addNumericField("End Slice (0 for last): ", END_SLICE)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    SPINE_SEGMENTATION_CHANNEL = int(gd.getNextNumber())
    THRESHOLDING_METHOD = gd.getNextChoice()
    LOOKUP_TABLE_NAME = gd.getNextChoice()
    START_SLICE = int(gd.getNextNumber())
    END_SLICE = int(gd.getNextNumber())
    SAVE_OPTIONS = gd.getNextBoolean()
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
    optionsString = optionsString + "spine=" + str(SPINE_SEGMENTATION_CHANNEL)
    optionsString = optionsString + " auto-thresholding=" + THRESHOLDING_METHOD
    optionsString = optionsString + " lookup=" + lutName 
    optionsString = optionsString + " start=" + str(START_SLICE) 
    optionsString = optionsString + " end=" + str(END_SLICE) 
    return optionsString


def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
def loadOptions(): 
    global THRESHOLDING_METHOD, LOOKUP_TABLE_NAME, SPINE_SEGMENTATION_CHANNEL, START_SLICE, END_SLICE
    
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
        if key=="spine":
            SPINE_SEGMENTATION_CHANNEL = int(value)
        if key=="start":
            START_SLICE = int(value)
        if key=="end":
            END_SLICE = int(value)
    

main()


