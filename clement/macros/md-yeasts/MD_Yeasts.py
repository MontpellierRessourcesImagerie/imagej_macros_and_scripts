from ij import IJ
from ij.plugin.frame import RoiManager
from mdYeasts.makeSegmentation import segmentYeasts

def run():
    rm = RoiManager.getInstance()
    if (rm is None) or (rm.getCount() == 0):
        IJ.log("An ROI manager containing at least one ROI is required.")
        return False

    imIn = IJ.getImage()
    imIn.setTitle(imIn.getTitle().replace('$', '_'))
    
    if imIn is None:
        IJ.log("An image is required to work")
        return False

    segmentYeasts(rm, imIn)
    rm.runCommand("Deselect")
    return True


run()
