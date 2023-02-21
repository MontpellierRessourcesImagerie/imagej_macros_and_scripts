from ij import IJ
from ij.gui import GenericDialog
from fiji.util.gui import GenericDialogPlus
import os
import json


def makeDefaultSettings():
    return {
        'redSuffix': "_w1Cy3.tif",
        'greenSuffix': "_w2GFP.tif",
        'slicesTol': 3,
        'inDir': IJ.getDirectory("home"),
        'outDir': IJ.getDirectory("home")
    }

# run("Stack Focus MIP", "choose=/home/benedetti/Bureau/ choose_result=/home/benedetti/Bureau/");

def buildSettingsLocation():
    imjDir = IJ.getDirectory("imagej")
    settingsName = "spots-in-neurites.config.json"
    return os.path.join(imjDir, settingsName)


def importSettings():
    path = buildSettingsLocation()

    if os.path.isfile(path):
        f = open(path, 'r')
        p = json.load(f)
        f.close()
        return p
    else:
        return makeDefaultSettings()


def showSettings():
    gui      = GenericDialogPlus("Spots in neurites settings")
    settings = importSettings()

    gui.addStringField("Red suffix", settings['redSuffix'], 16)
    gui.addStringField("Green suffix", settings['greenSuffix'], 16)
    gui.addNumericField("Slices tolerance", settings['slicesTol'], 0)

    gui.showDialog()

    if gui.wasOKed():
        pass


showSettings()