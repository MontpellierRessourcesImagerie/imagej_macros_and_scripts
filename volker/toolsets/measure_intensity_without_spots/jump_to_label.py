import os
from ij import IJ
from ij import ImagePlus
from ij import Prefs
from ij.gui import GenericDialog
from ij.gui import Roi
from  ij.plugin import Zoom


LABEL = 1
NR_OF_ZOOM_OUTS = 4
SAVE_OPTIONS = True


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if not showDialog():
        return
    if optionsOnly=="true":
        return
    print("Label", LABEL)
    image = IJ.getImage()
    title = image.getTitle()
    overlay = image.getOverlay()
    roi = overlay.get(LABEL)
    bounds = roi.getBounds()
    targetRoi = Roi(bounds)
    image.setRoi(roi)
    Zoom.toSelection(image)
    IJ.run(image, "Select None", "")
    for _ in range(NR_OF_ZOOM_OUTS):
        Zoom.out(image)
    
    
def showDialog():
    global LABEL, NR_OF_ZOOM_OUTS, SAVE_OPTIONS
    
    optionsPath = getOptionsPath()
    if os.path.exists(optionsPath):
        loadOptions()
    gd = GenericDialog("Jump To Label Options"); 
    gd.addNumericField("Label: ", LABEL)
    gd.addNumericField("Zoom out: ", NR_OF_ZOOM_OUTS)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    LABEL = int(gd.getNextNumber())
    NR_OF_ZOOM_OUTS = int(gd.getNextNumber())
    SAVE_OPTIONS = gd.getNextBoolean()
    if SAVE_OPTIONS:
        saveOptions()
    return True
    

def getOptionsPath():
    pluginsPath = IJ.getDirectory("plugins")
    optionsPath = pluginsPath + "Measure-Intensity-Without-Spots/jtl-options.txt"
    return optionsPath
    
    
def getOptionsString():
    optionsString = ""
    optionsString = optionsString + "label=" + str(LABEL)
    optionsString = optionsString + " zoom=" + str(NR_OF_ZOOM_OUTS)
    return optionsString    
    
    
def loadOptions(): 
    global LABEL, NR_OF_ZOOM_OUTS
    
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
        if key=="label":
            Label = int(value)
        if key=="zoom":
            NR_OF_ZOOM_OUTS = int(value)
               
    
def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())


main()   
