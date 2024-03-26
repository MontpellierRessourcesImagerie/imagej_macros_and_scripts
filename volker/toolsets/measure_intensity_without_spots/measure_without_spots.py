import os
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
from ij.measure import ResultsTable
from fr.cnrs.mri.cialib.quantification import StainingAnalyzer
from fr.cnrs.mri.cialib.quantification import NucleiSegmentationMethod


NUCLEI_CHANNEL = 1
SIGNAL_CHANNEL = 2
NUCLEUS_MIN_AREA = 50
SHOW_LABELS = False
SAVE_OPTIONS = True
URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure-Intensity-Without-Spots"


cls = NucleiSegmentationMethod
methodClasses = list(set(cls.__subclasses__()))
METHODS = [methodClass.name() for methodClass in methodClasses]
METHOD = METHODS[0]


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if  not showDialog():
        return
    if optionsOnly=="true":
        return
    image = IJ.getImage()
    title = image.getTitle()
    analyzer = StainingAnalyzer(image, NUCLEI_CHANNEL, SIGNAL_CHANNEL)
    table = ResultsTable.getResultsTable("intensity measurements without spots")
    if table:
        analyzer.results = table
    analyzer.setMinAreaNucleus(NUCLEUS_MIN_AREA)
    analyzer.measure()
    analyzer.createOverlayOfResults()
    analyzer.results.show("intensity measurements without spots")
    if SHOW_LABELS:
        analyzer.labels.show()


def showDialog():
    global NUCLEI_CHANNEL, SIGNAL_CHANNEL, NUCLEUS_MIN_AREA, METHODS, METHOD, SAVE_OPTIONS, URL
    
    cls = NucleiSegmentationMethod
    methodClasses = list(set(cls.__subclasses__()))
    for methodClass in methodClasses:
        print(methodClass.name(), methodClass.options())
        
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Measure Without Spots Options"); 
    gd.addNumericField("Nuclei Channel: ", NUCLEI_CHANNEL)
    gd.addNumericField("Signal Channel: ", SIGNAL_CHANNEL)
    gd.addNumericField("Min. Area Nucleus: ", NUCLEUS_MIN_AREA)
    gd.addChoice("Method: ", METHODS, METHOD)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    NUCLEI_CHANNEL = int(gd.getNextNumber())
    SIGNAL_CHANNEL = int(gd.getNextNumber())
    NUCLEUS_MIN_AREA = float(gd.getNextNumber())
    METHOD = gd.getNextChoice()
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
    optionsString = optionsString + " method.=" + str(METHOD)
    return optionsString    
    
    
def loadOptions(): 
    global NUCLEI_CHANNEL, SIGNAL_CHANNEL, NUCLEUS_MIN_AREA, METHOD
    
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
        if key=="method":
            METHOD = str(value)
    
    
def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
main()