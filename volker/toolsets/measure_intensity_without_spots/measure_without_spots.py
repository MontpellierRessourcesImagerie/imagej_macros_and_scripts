import os
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
from fr.cnrs.mri.cialib.quantification import StainingAnalyzer


NUCLEI_CHANNEL = 1
SIGNAL_CHANNEL = 2
NUCLEUS_MIN_AREA = 50
SHOW_LABELS = False
SAVE_OPTIONS = True
URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure-Intensity-Without-Spots"


def main():
    image = IJ.getImage()
    title = image.getTitle()
    optionsOnly = Prefs.get("mri.options.only", "false")
    if  not showDialog():
        return
    if optionsOnly=="true":
        return
    analyzer = StainingAnalyzer(image, NUCLEI_CHANNEL, SIGNAL_CHANNEL)
    analyzer.setMinAreaNucleus(NUCLEUS_MIN_AREA)
    analyzer.measure()
    analyzer.createOverlayOfResults()
    analyzer.results.show("measurements of " + title)
    if SHOW_LABELS:
        analyzer.labels.show()


def showDialog():
    global NUCLEI_CHANNEL, SIGNAL_CHANNEL, NUCLEUS_MIN_AREA, SAVE_OPTIONS, URL
    
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Measure Without Spots Options"); 
    gd.addNumericField("Nuclei Channel: ", NUCLEI_CHANNEL)
    gd.addNumericField("Signal Channel: ", SIGNAL_CHANNEL)
    gd.addNumericField("Min. Area Nucleus: ", NUCLEUS_MIN_AREA)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    NUCLEI_CHANNEL = int(gd.getNextNumber())
    SIGNAL_CHANNEL = int(gd.getNextNumber())
    NUCLEUS_MIN_AREA = float(gd.getNextNumber())
    SAVE_OPTIONS = gd.getNextBoolean()
    if SAVE_OPTIONS:
        saveOptions()
    return True


def getOptionsPath():
    pluginsPath = IJ.getDirectory("plugins");
    optionsPath = pluginsPath + "Measure-Intensity-Without-Spots/mws-options.txt";
    return optionsPath;
    
    
def getOptionsString():
    optionsString = ""
    optionsString = optionsString + "nuclei=" + str(NUCLEI_CHANNEL)
    optionsString = optionsString + " signal=" + str(SIGNAL_CHANNEL)
    optionsString = optionsString + " min.=" + str(NUCLEUS_MIN_AREA)
    return optionsString    
    
    
def loadOptions(): 
    global NUCLEI_CHANNEL, SIGNAL_CHANNEL, NUCLEUS_MIN_AREA
    
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
        if key=="nuclei":
            NUCLEI_CHANNEL = int(value)
        if key=="signal":
            SIGNAL_CHANNEL = int(value)
        if key=="min.":
            NUCLEUS_MIN_AREA = float(value)
    
    
def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
main()