import json
import os
from ij import IJ
from ij.plugin.frame import RoiManager
from fiji.util.gui import GenericDialogPlus
from ij.gui import Roi, PointRoi

md_yeasts_settings = ".md_yeasts_export.temp.txt"


def seedsFromRoiManager(rm):

    """
    If the RoiManager contains a polygon roi or a multi-points selection named "seeds", creates a list of tuples representing the points of the ROI.
    
    This point selection can be located in any slot of the RoiManager as long as it is named properly.
    The name is not case sensitive (seeds == Seeds == SeEdS == ...).
    The provided ROI can be a polygon, and will implicitely converted into points.

    @type  rm: RoiManager
    @param rm: An instance of RoiManager containing a points selection named 'seeds'.
    
    @rtype: list((float, float))
    @return: A list (possibly empty) of tuple (Vec2) containing all starting points.
    """

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

    """
    Default settings used with the moving n-gon.

    @rtype: void
    """

    return {
        'shape': "Box",
        'tolerance': 1,
        'ctr_from_mask': 'MASK',
        'nPoints': 70,
        'stepSize': 0.2,
        'maxThickness': 0.8,
        'exportRois': None,
        'showControl': True,
        'exportControl': True,
        'closeOri': True,
        'closeRoiMngr': True
    }


def checkSettings(settings):

    """
    Verifies that each parameter in the settings has a valid value that won't break the script.

    @type  settings: dict((str, obj))
    @param settings: A dictionary representing the settings.

    @rtype: (bool, str)
    @return: The boolean describes whether the parameters are valid or not. The string contains the error message if the settings happen to be bad.
    """

    if settings['shape'] not in ['Box', 'Ellipse']:
        return (False, "Provided shape is invalid. Expecting 'Box' or 'Ellipse'.")

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

    """
    Reads the settings file and returns its content under the form of a dictionary.
    Settings are exported in the user's home directory, in a folder named ".md_yeasts_export.temp.txt".

    @rtype: (dict((str, obj)), str)
    @return: On success, a dictionary of settings and a string containing C{"DONE."}. Otherwise, C{None} and a string containing an error message.
    """

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

    """
    Displays the GUI for the user to chose his settings.
    Also exports them in a file, in the user's home directory.

    @rtype: (bool, str)
    @return: The boolean represents whether the operation was successful or not. The string contains an error message in case of fail.
    """

    gui = GenericDialogPlus("Segmentation settings")

    settings = makeDefaultSettings()

    gui.addDirectoryField("Working directory", IJ.getDirectory("Home"))
    gui.addChoice("Shape", ["Box", "Ellipse"], settings['shape'])
    gui.addSlider("Tolerance", 1, 512, settings['tolerance'])
    gui.addSlider("Points", 3, 120, settings['nPoints'])
    gui.addSlider("Step size", 0.01, 1.0, settings['stepSize'])
    gui.addChoice("Centroid from", ['MASK', 'POINTS'], settings['ctr_from_mask'])
    gui.addSlider("Membrane thickness (um)", 0.01, 2.0, settings['maxThickness'])
    gui.addCheckboxGroup(2, 2, 
        ["Show control", "Export control", "Close original", "Close ROI Manager"], 
        [settings['showControl'], settings['exportControl'], settings['closeOri'], settings['closeRoiMngr']]
    )

    gui.showDialog()

    if gui.wasOKed():
        settings['exportRois']    = gui.getNextString()
        settings['shape']         = gui.getNextChoice()
        settings['tolerance']     = int(gui.getNextNumber())
        settings['nPoints']       = int(gui.getNextNumber())
        settings['stepSize']      = gui.getNextNumber()
        settings['ctr_from_mask'] = gui.getNextChoice()
        settings['maxThickness']  = gui.getNextNumber()
        settings['showControl']   = gui.getNextBoolean()
        settings['exportControl'] = gui.getNextBoolean()
        settings['closeOri']      = gui.getNextBoolean()
        settings['closeRoiMngr']  = gui.getNextBoolean()
    
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


def exportRoiManager(img, rootDir):

    """
    Exports the content of an RoiManager in the "rois" folder of the script's working directory.
    If the RoiManager is empty, no useless file is instanciated on the disk.
    The produced file has the same name as the image, at the difference of the extension (.zip).

    @rtype: bool
    @return: C{True} if the export ended correctly, C{False} otherwise.
    """

    r = RoiManager.getInstance()

    if (r is None) or (r.getCount() == 0):
        return False

    path = os.path.join(rootDir, "rois")
    if not os.path.isdir(path):
        os.mkdir(path)

    name = '.'.join(img.getTitle().split('.')[:-1]) + ".zip"
    r.runCommand("Save", os.path.join(path, name))
    r.close()

    return True