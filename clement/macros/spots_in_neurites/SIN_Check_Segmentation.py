from ij import IJ
from spotsInNeurites.settingsManager import importSettings, getDefaultNames
import os

def run():
    settings = importSettings()
    defNames = getDefaultNames()

    red    = settings['redSuffix'].split('.')[0]
    green  = settings['greenSuffix'].split('.')[0]
    mipDir = os.path.join(settings['workingDir'], defNames['mip'])
    redMip = os.path.join(mipDir, red)
    segDir = os.path.join(settings['workingDir'], defNames['segmentation'])
    roiDir = os.path.join(settings['workingDir'], defNames['rois'])

    # Creating ROIs directory if it doesn't exist already
    if not os.path.isdir(roiDir):
        os.mkdir(roiDir)
    elif len(os.listdir(roiDir)) > 0:
        IJ.log("'{0}' already exists, beware of possible file collisions.".format(defNames['rois']))

    # Removing the result of prediction that is not a mask.
    content = os.listdir(segDir)
    for c in content:
        if c.startswith("mask_"): # This prefix is defined in "Verif_Segmentation.ijm".
            continue
        fullPath = os.path.join(segDir, c)
        if os.path.isfile(fullPath):
            os.remove(fullPath)

    # Building arguments and launching command.
    args = "mip=[{0}] mask=[{1}] roi=[{2}]".format(
        redMip,
        segDir,
        roiDir
    )

    IJ.run("Verif Segmentation", args);
    return True

run()