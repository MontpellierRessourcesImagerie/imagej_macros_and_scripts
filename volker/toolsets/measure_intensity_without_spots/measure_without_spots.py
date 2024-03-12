import os
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
from fr.cnrs.mri.cialib.quantification import StainingAnalyzer


NUCLEI_CHANNEL = 1
SIGNAL_CHANNEL = 2
NUCLEUS_MIN_AREA = 50
SAVE_OPTIONS = True
URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure-Intensity-Without-Spots";


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
    
    
def loadOptions():
    pass
    
    
def saveOptions():  
    pass
    
    
main()