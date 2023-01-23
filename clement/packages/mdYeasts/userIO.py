import json
import os
from ij import IJ
from ij.plugin.frame import RoiManager
from fiji.util.gui import GenericDialogPlus
from ij.gui  import Roi, PointRoi

md_yeasts_settings = ".md_yeasts_export.temp.txt"

## @brief If the RoiManager contains a polygon roi or a multi-points selection named "seeds", creates a list of tuples representing the points of the ROI.
## @param rm An instance of RoiManager (RoiManager.getInstance())
## @return A list of tuple (possibly empty) containing all starting points.
def seedsFromRoiManager(rm):
    if (rm is None) or (rm.getCount() == 0):
        return []

    roi = None
    for i in range(rm.getCount()):
        if rm.getName(i).lower() == "seeds":
            roi = rm.getRoi(i)
            break

    if roi.getType() == Roi.POLYGON:
        roi = PointRoi(roi.getPolygon())
    
    if roi.getType() != Roi.POINT:
        return []
    
    startingPoints = [(p.x, p.y) for p in roi.getContainedPoints()]
    return startingPoints


def makeDefaultSettings():
    return {
        'shape': "Ellipsis",
        'tolerance': 1,
        'ctr_from_mask': 'MASK',
        'nPoints': 70,
        'stepSize': 0.2,
        'maxThickness': 0.633,
        'exportRois': None
    }


def checkSettings(settings):
    if settings['shape'] not in ['Box', 'Ellipsis']:
        return (False, "Provided shape is invalid. Expecting 'Box' or 'Ellipsis'.")

    if settings['ctr_from_mask'] not in ['MASK', 'POINTS']:
        return (False, "Center position invalid. Expecting 'MASK' or 'POINTS'.")
    
    if settings['tolerance'] < 1:
        return (False, "Tolerance is supposed to be strictly superior to 0.")

    if (settings['nPoints'] < 3) or (settings['nPoints'] > 200):
        return (False, "The number of points is supposed to be between 3 and 200.")

    if settings['stepSize'] <= 0.0:
        return (False, "The step size cannot be negative or 0.")

    if settings['maxThickness'] <= 0.0:
        return (False, "The membrane's thickness can't be negative or 0.")

    if (settings['exportRois'] is None) or (not os.path.isdir(settings['exportRois'])):
        return (False, "Folder containing ROIs can't be left unset.")

    return (True, "DONE.")


def readSettings():
    settings_path = os.path.join(IJ.getDirectory("home"), md_yeasts_settings)

    if not os.path.isfile(settings_path):
        return (None, "Settings need to be set.")
    
    settings_file = open(settings_path, 'r')

    if settings_file.closed:
        return (None, "Failed to read settings file.")

    settings = json.load(settings_file)
    settings_file.close()

    status, verbose = checkSettings(settings)

    if not status:
        return (None, "Invalid settings detected: {0}".format(verbose))

    return (settings, "DONE.")


def askSettings():
    gui = GenericDialogPlus("Segmentation settings")

    settings = makeDefaultSettings()

    gui.addDirectoryField("ROIs Folder", IJ.getDirectory("Home"))
    gui.addChoice("Shape", ["Box", "Ellipsis"], settings['shape'])
    gui.addSlider("Tolerance", 1, 512, settings['tolerance'])
    gui.addSlider("Points", 3, 120, settings['nPoints'])
    gui.addSlider("Step size", 0.01, 1.0, settings['stepSize'])
    gui.addChoice("Centroid from", ['MASK', 'POINTS'], settings['ctr_from_mask'])
    gui.addSlider("Membrane thickness (um)", 0.01, 2.0, settings['maxThickness'])

    gui.showDialog()

    if gui.wasOKed():
        settings['exportRois']    = gui.getNextString()
        settings['shape']         = gui.getNextChoice()
        settings['tolerance']     = int(gui.getNextNumber())
        settings['nPoints']       = int(gui.getNextNumber())
        settings['stepSize']      = gui.getNextNumber()
        settings['ctr_from_mask'] = gui.getNextChoice()
        settings['maxThickness']  = gui.getNextNumber()
    
    else:
        return (False, "Command canceled.")

    status, verbose = checkSettings(settings)

    if not status:
        return (False, "Incorrect settings detected: {0}".format(verbose))

    out_path = os.path.join(IJ.getDirectory("home"), md_yeasts_settings)
    out_file = open(out_path, 'w')

    if out_file.closed:
        return (False, "Settings file could not be edited.")

    json.dump(settings, out_file, indent=4)
    out_file.close()

    return (True, "DONE.")


def exportRoiManager(img, path):
    r = RoiManager.getInstance()

    if (r is None) or (r.getCount() == 0):
        return False

    name = '.'.join(img.getTitle().split('.')[:-1]) + ".zip"
    r.runCommand("Save", os.path.join(path, name))
    return True