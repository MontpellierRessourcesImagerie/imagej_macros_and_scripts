from ij import IJ
from ij.gui import GenericDialog
from fiji.util.gui import GenericDialogPlus
import os
import json


def makeDefaultSettings():
    return {
        'redSuffix': "w1Cy3.tif",
        'greenSuffix': "w2GFP.tif",
        'slicesTol': 3,
        'workingDir': IJ.getDirectory("home"),
        'rawDirName': "1-raw",
        'condaPath': IJ.getDirectory("home"),
        'sizeCh1': 3,
        'intCh1': 5,
        'sizeCh2': 4,
        'intCh2': 11
    }


def buildSettingsLocation():
    imjDir = IJ.getDirectory("imagej")
    settingsName = "spots-in-neurites.config.json"
    return os.path.join(imjDir, settingsName)


def removeSettings():
    path = buildSettingsLocation()
    if os.path.isfile(path):
        os.remove(path)


def exportSettings(newSettings):
    path = buildSettingsLocation()
    f = open(path, 'w')
    json.dump(newSettings, f)
    f.close()


def importSettings():
    path = buildSettingsLocation()

    if os.path.isfile(path):
        f = open(path, 'r')
        p = json.load(f)
        f.close()
        return p
    else:
        return makeDefaultSettings()


def checkSettings(newSettings):
    if newSettings['slicesTol'] <= 0:
        IJ.log("Slices tolerance can't be 0 or negative.")
        return False
    
    if not os.path.isdir(newSettings['workingDir']):
        IJ.log("Working directory '{0}' doesn't exist.".format(newSettings['workingDir']))
        return False

    rawDirectory = os.path.join(newSettings['workingDir'], newSettings['rawDirName'])
    
    if not os.path.isdir(rawDirectory):
        IJ.log("Raw data directory '{0}' doesn't exist.".format(rawDirectory))
        return False

    sp1 = newSettings['redSuffix'].split('.')
    sp2 = newSettings['greenSuffix'].split('.')

    if (len(sp1) != 2) or (len(sp2) != 2):
        IJ.log("A suffix should only contain one dot, corresponding to the extension. Got: '{}' and '{}'".format(newSettings['redSuffix'], newSettings['greenSuffix']))
        return False
    
    r = newSettings['redSuffix']
    g = newSettings['greenSuffix']

    if (not sp1[0].isalnum()) or (not sp2[0].isalnum()):
        IJ.log("The first part of suffixes should be exclusively alpha-numeric (only letters and numbers, no '_', '-', ...)")
        return False

    if not os.path.isdir(newSettings['condaPath']):
        IJ.log("The provided path to conda doesn't exist (execting a directory)")
        return False

    if not "envs" in os.listdir(newSettings['condaPath']):
        IJ.log("A folder named 'envs' should be present in the anaconda's directory")
        return False

    return True


def getDefaultNames():
    return {
        'raw':          "1-raw",
        'mip':          "2-mip",
        'segmentation': "3-masks",
        'rois':         "4-rois",
        'spots':        "5-spots"
    }


def showSettings():
    gui      = GenericDialogPlus("Spots in neurites settings")
    settings = importSettings()

    gui.addMessage("Give the suffix used by raw files, including the extension.")
    gui.addStringField("Red suffix", settings['redSuffix'], 12)
    gui.addStringField("Green suffix", settings['greenSuffix'], 12)
    gui.addMessage("")

    gui.addMessage("How many slices are used around the focused one.")
    gui.addNumericField("Slices tolerance", settings['slicesTol'], 0)
    gui.addMessage("")

    gui.addMessage("Directory in which all folders will be created.")
    gui.addDirectoryField("Working directory", settings['workingDir'])
    gui.addMessage("")

    gui.addMessage("Name of the folder containing raw images inside the previous folder.")
    gui.addStringField("Raw directory name", settings['rawDirName'], 12)
    gui.addMessage("")

    gui.addMessage("Path to the folder where conda is installed.")
    gui.addDirectoryField("Conda directory", settings['condaPath'])

    gui.addMessage("                           Channel 1                Channel 2")

    gui.addNumericField("Size", settings['sizeCh1'], 0)
    gui.addToSameRow()
    gui.addNumericField("Size", settings['sizeCh2'], 0)

    gui.addNumericField("Intensity", settings['intCh1'], 0)
    gui.addToSameRow()
    gui.addNumericField("Intensity", settings['intCh2'], 0)

    gui.showDialog()

    if gui.wasOKed():

        settings['redSuffix']   = gui.getNextString()
        settings['greenSuffix'] = gui.getNextString()
        settings['slicesTol']   = int(gui.getNextNumber())
        settings['workingDir']  = gui.getNextString()
        settings['rawDirName']  = gui.getNextString()
        settings['condaPath']   = gui.getNextString()
        settings['sizeCh1']     = int(gui.getNextNumber())
        settings['sizeCh2']     = int(gui.getNextNumber())
        settings['intCh1']      = int(gui.getNextNumber())
        settings['intCh2']      = int(gui.getNextNumber())

        if checkSettings(settings):
            exportSettings(settings)
