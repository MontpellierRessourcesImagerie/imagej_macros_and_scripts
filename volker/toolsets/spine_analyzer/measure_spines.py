import os
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine_Analyzer"
SAVE_OPTIONS = True
SHOW_DENDRITE_MEASUREMENTS = False
SHOW_SPINE_MEASUREMENTS = False
SHOW_ALL_SPINE_MEASUREMENTS = True


def main():   
    optionsOnly = Prefs.get("mri.options.only", "false")
    if  not showDialog():
        return
    if optionsOnly=="true":
        return
    image = IJ.getImage()
    segmentation = InstanceSegmentation(image)
    dendrites = Dendrites(segmentation)
    if SHOW_DENDRITE_MEASUREMENTS or SHOW_SPINE_MEASUREMENTS:
        dendrites.measure()
    if SHOW_SPINE_MEASUREMENTS:
        table = dendrites.reportSpines()
        table.show("Spine Measurements")
    if SHOW_DENDRITE_MEASUREMENTS:
        table = dendrites.reportDendrites()
        table.show("Dendrite Measurements")
    if SHOW_ALL_SPINE_MEASUREMENTS:
        table = dendrites.reportAllSpines()
        table.show("All Spines Measurements")


def showDialog():
    global SHOW_DENDRITE_MEASUREMENTS, SHOW_SPINE_MEASUREMENTS, SHOW_ALL_SPINE_MEASUREMENTS, URL, SAVE_OPTIONS
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Measure Spines Options"); 
    gd.addCheckbox("Show_Dendrite Measurements", SHOW_DENDRITE_MEASUREMENTS)
    gd.addCheckbox("Show_Spine Measurements", SHOW_SPINE_MEASUREMENTS)
    gd.addCheckbox("Show_All Spine Measurements", SHOW_ALL_SPINE_MEASUREMENTS)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    SHOW_DENDRITE_MEASUREMENTS = gd.getNextBoolean()
    SHOW_SPINE_MEASUREMENTS = gd.getNextBoolean()
    SHOW_ALL_SPINE_MEASUREMENTS = gd.getNextBoolean()
    SAVE_OPTIONS = gd.getNextBoolean()
    if SAVE_OPTIONS:
        saveOptions()
    return True


def getOptionsPath():
    pluginsPath = IJ.getDirectory("plugins");
    optionsPath = pluginsPath + "Spine-Analyzer/sams-options.txt";
    return optionsPath;


def getOptionsString():
    global SHOW_DENDRITE_MEASUREMENTS, SHOW_SPINE_MEASUREMENTS, SHOW_ALL_SPINE_MEASUREMENTS
    optionsString = ""
    if SHOW_DENDRITE_MEASUREMENTS:
        optionsString = optionsString + "show_dendrite "
    if SHOW_SPINE_MEASUREMENTS:
        optionsString = optionsString + "show_spine "
    if SHOW_ALL_SPINE_MEASUREMENTS:
        optionsString = optionsString + "show_all "
    return optionsString



def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
def loadOptions(): 
    global SHOW_DENDRITE_MEASUREMENTS, SHOW_SPINE_MEASUREMENTS, SHOW_ALL_SPINE_MEASUREMENTS
    optionsPath = getOptionsPath()
    optionsString = IJ.openAsString(optionsPath)
    optionsString = optionsString.replace("\n", "")
    options = optionsString.split(" ")
    SHOW_DENDRITE_MEASUREMENTS = False
    SHOW_SPINE_MEASUREMENTS = False
    SHOW_ALL_SPINE_MEASUREMENTS = False
    for option in options:
        if option == "show_dendrite":
            SHOW_DENDRITE_MEASUREMENTS = True
        if option == "show_spine":    
            SHOW_SPINE_MEASUREMENTS = True
        if option == "show_all":
            SHOW_ALL_SPINE_MEASUREMENTS = True
            
            
main()