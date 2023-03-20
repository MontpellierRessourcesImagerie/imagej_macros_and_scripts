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

    if not os.path.isdir(roiDir):
        os.mkdir(roiDir)
    elif len(os.listdir(roiDir)) > 0:
        IJ.log("'{0}' already exists, beware of possible file collisions.".format(defNames['rois']))

    args = "mip=[{0}] mask=[{1}] roi=[{2}]".format(
        redMip,
        segDir,
        roiDir
    )

    IJ.run("Verif Segmentation", args);
    return True

run()