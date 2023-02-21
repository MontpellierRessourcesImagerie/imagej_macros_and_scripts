import os
from ij import IJ
from ij.plugin.frame import RoiManager
from mdYeasts.makeSegmentation import segmentYeasts
from mdYeasts.userIO import readSettings
from fiji.util.gui import GenericDialogPlus


def run():
    settings, verbose = readSettings()
    if settings is None:
        IJ.log("Impossible to read settings: {0}".format(verbose))
        return False

    rm = RoiManager.getRoiManager()
    if rm is not None:
        rm.close()
    rm = None
    
    roisPath = os.path.join(settings['exportRois'], "rois")
    exts = "tif"
    
    gui = GenericDialogPlus("Folder of images...")
    gui.addDirectoryField("Folder of yeasts", IJ.getDirectory("Home"))
    gui.addMessage("Folder of ROIs: {0}".format(roisPath))
    gui.addStringField("Extension", "tif")

    gui.showDialog()

    if gui.wasOKed():
        imagesPath = gui.getNextString()
        exts = gui.getNextString().lower()
    else:
        IJ.log("Command canceled")
        return False

    if not os.path.isdir(imagesPath):
        IJ.log("The images' folder doesn't exist.")
        return False

    if not os.path.isdir(roisPath):
        IJ.log("The rois' folder doesn't exist.")
        return False

    content = sorted([f for f in os.listdir(imagesPath) if os.path.isfile(os.path.join(imagesPath, f)) and f.lower().endswith(exts)])
    
    for idx, c in enumerate(content):

        IJ.log(" = = = Processing {0} ({1}/{2})... = = = ".format(c, str(idx+1).zfill(3), str(len(content)).zfill(3)))
        
        roiName = '.'.join(c.split('.')[:-1]) + ".zip"
        rmPath = os.path.join(roisPath, roiName)

        if not os.path.isfile(rmPath):
            IJ.log(" > {0} not found (or empty) in ROIs folder.".format(rmPath))
            continue
        
        rm = RoiManager(False)
        status = rm.open(rmPath)

        if not status:
            IJ.log(" > Failed to open {0}".format(roiName))
            continue

        if rm.getCount() <= 0:
            IJ.log(" > Failed to get a reference to the RoiManager.")
            rm.close()
            continue

        imIn = IJ.openImage(os.path.join(imagesPath, c))

        segmentYeasts(rm, imIn, True)

        IJ.log(" > {0} processed.".format(c))

    IJ.log("DONE.")
    return True


run()