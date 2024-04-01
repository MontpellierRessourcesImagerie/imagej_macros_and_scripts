import os
from ij import IJ
from ij import Prefs
from ij.gui import GenericDialog
from ij import WindowManager
from ij.plugin import Duplicator
from ij.plugin import RGBStackMerge


SIGNAL_CHANNEL = 2
NUCLEI_CHANNEL = 1
LAMBDA_FLAT = 0.50
LAMBDA_DARK = 0.50
SAVE_OPTIONS = True
URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure-Intensity-Without-Spots"


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if not showDialog():
        return
    if optionsOnly=="true":
        return
    return
    image = IJ.getImage()
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    spotsChannelImage = Duplicator().run(image, SIGNAL_CHANNEL, SIGNAL_CHANNEL, 1, nSlices, 1, nFrames)
    spotsChannelImage.show()
    title = spotsChannelImage.getTitle()
    IJ.run(spotsChannelImage, "BaSiC ", "processing_stack=[" + spotsChannelImage.getTitle() + "] flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=[Replace with zero] correction_options=[Compute shading and correct images] lambda_flat=" + str(LAMBDA_FLAT) + " lambda_dark=" + str(LAMBDA_DARK))
    correctedSpotsImage = IJ.getImage()
    closeWindow("Dark-field:" + title)
    closeWindow("Flat-field:" + title)
    closeWindow("Basefluor")
    closeWindow("Temporal components")
    spotsChannelImage.close()
    nucleiChannelImage = Duplicator().run(image, NUCLEI_CHANNEL, NUCLEI_CHANNEL, 1, nSlices, 1, nFrames)
    resultImage = RGBStackMerge.mergeChannels([nucleiChannelImage, correctedSpotsImage], False)
    correctedSpotsImage.close()
    image.close()
    resultImage.setTitle(title)
    resultImage.show()
    
    
def showDialog():
    global NUCLEI_CHANNEL, SIGNAL_CHANNEL, LAMBDA_FLAT, SAVE_OPTIONS, LAMBDA_DARK, URL
        
    if  os.path.exists(getOptionsPath()):
        loadOptions()
    gd = GenericDialog("Remove Background Options"); 
    gd.addNumericField("Nuclei Channel: ", NUCLEI_CHANNEL)
    gd.addNumericField("Signal Channel: ", SIGNAL_CHANNEL)
    gd.addNumericField("Lambda_Flat: ", LAMBDA_FLAT)
    gd.addNumericField("Lambda_Dark: ", LAMBDA_DARK)
    gd.addCheckbox("Save Options", SAVE_OPTIONS)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    NUCLEI_CHANNEL = int(gd.getNextNumber())
    SIGNAL_CHANNEL = int(gd.getNextNumber())
    LAMBDA_FLAT = float(gd.getNextNumber())
    LAMBDA_DARK = float(gd.getNextNumber())
    SAVE_OPTIONS = gd.getNextBoolean()
    if SAVE_OPTIONS:
        saveOptions()
    return True
    

def getOptionsPath():
    pluginsPath = IJ.getDirectory("plugins");
    optionsPath = pluginsPath + "Measure-Intensity-Without-Spots/rb-options.txt";
    return optionsPath;
    

def getOptionsString():
    optionsString = ""
    optionsString = optionsString + "nuclei=" + str(NUCLEI_CHANNEL)
    optionsString = optionsString + " signal=" + str(SIGNAL_CHANNEL)
    optionsString = optionsString + " lambda_flat=" + str(LAMBDA_FLAT)
    optionsString = optionsString + " lambda_dark=" + str(LAMBDA_DARK)
    return optionsString 
    
    
def closeWindow(title):
    win = WindowManager.getWindow(title)
    win.close()
 
 
def loadOptions(): 
    global NUCLEI_CHANNEL, SIGNAL_CHANNEL, LAMBDA_FLAT, LAMBDA_DARK
    
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
        if key=="lambda_flat":
            LAMBDA_FLAT = float(value)
        if key=="lambda_dark":
            LAMBDA_DARK = float(value)
    

def saveOptions():
    optionsString = getOptionsString()
    optionsPath = getOptionsPath()
    IJ.saveString(optionsString, getOptionsPath())
    
    
main()