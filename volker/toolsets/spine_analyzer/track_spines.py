import os
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine-Analyzer"
MAX_DISTANCE = 3
SAVE_OPTIONS = True


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if  not showDialog():
        return
    if optionsOnly=="true":
        return
    IJ.log("Starting track spines...")
    image = IJ.getImage()
    segmentation = InstanceSegmentation(image)
    segmentation.setMaxDistance(MAX_DISTANCE)
    segmentation.trackLabels()
    IJ.log("...track spines finished")
    
    
    
def showDialog():
    global MAX_DISTANCE, URL, SAVE_OPTIONS
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Track Spines Options"); 
    gd.addNumericField("max. distance between 2 frames: ", MAX_DISTANCE)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    MAX_DISTANCE = gd.getNextNumber()
    SAVE_OPTIONS = gd.getNextBoolean()
    if SAVE_OPTIONS:
        saveOptions()
    return True
    
    
def getOptionsPath():
    pluginsPath = IJ.getDirectory("plugins");
    optionsPath = pluginsPath + "Spine-Analyzer/sats-options.txt";
    return optionsPath;


def getOptionsString():
    global MAX_DISTANCE
    optionsString = ""
    optionsString = optionsString + "max.=" + str(MAX_DISTANCE)
    return optionsString


def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
def loadOptions(): 
    global MAX_DISTANCE
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
        if key=="max.":
            MAX_DISTANCE = float(value)
            

main()