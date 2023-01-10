from ij import IJ
from ij.plugin.frame import RoiManager
from fiji.util.gui import GenericDialogPlus
from ij.gui  import Roi, PointRoi


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
        'shape': "Box",
        'tolerance': 1,
        'ctr_from_mask': 'MASK',
        'nPoints': 70,
        'stepSize': 0.2
    }


def checkSettings(settings):
    if settings['shape'] not in ['Box', 'Ellipsis']:
        return False

    if settings['ctr_from_mask'] not in ['MASK', 'POINTS']:
        return False
    
    if settings['tolerance'] < 1:
        return False

    if (settings['nPoints'] < 3) or (settings['nPoints'] > 200):
        return False

    if settings['stepSize'] <= 0.0:
        return False

    return True


def askSettings():
    gui = GenericDialogPlus("Segmentation settings")

    settings = makeDefaultSettings()

    gui.addChoice("Shape", ["Box", "Ellipsis"], settings['shape'])
    gui.addSlider("Tolerance", 1, 512, settings['tolerance'])
    gui.addSlider("Points", 3, 120, settings['nPoints'])
    gui.addSlider("Step size", 0.01, 1.0, settings['stepSize'])
    gui.addChoice("Centroid from", ['MASK', 'POINTS'], settings['ctr_from_mask'])

    gui.showDialog()

    if gui.wasOKed():
        settings['shape'] = gui.getNextChoice()
        settings['tolerance'] = int(gui.getNextNumber())
        settings['nPoints'] = int(gui.getNextNumber())
        settings['stepSize'] = gui.getNextNumber()
        settings['ctr_from_mask'] = gui.getNextChoice()
        return settings
    
    return None
