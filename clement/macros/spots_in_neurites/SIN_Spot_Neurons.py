from ij import IJ
from spotsInNeurites.settingsManager import importSettings, getDefaultNames
import os

def run():
    settings = importSettings()
    defNames = getDefaultNames()

    mipDir   = os.path.join(settings['workingDir'], defNames['mip'])
    maskDir  = os.path.join(settings['workingDir'], defNames['segmentation'])
    spotsDir = os.path.join(settings['workingDir'], defNames['spots'])

    if not os.path.isdir(spotsDir):
        os.mkdir(spotsDir)
    elif len(os.listdir(spotsDir)) > 0:
        IJ.log("'{0}' already exists, beware of possible file collisions.".format(defNames['spots']))

    args = "redsuffix={0} greensuffix={1} mipdirectory=[{2}] maskdirectory=[{3}] spotsdirectory=[{4}] ch1a={5} ch1s={6} ch2a={7} ch2s={8}".format(
        settings['redSuffix'],
        settings['greenSuffix'],
        mipDir,
        maskDir,
        spotsDir,
        settings['sizeCh1'],
        settings['intCh1'],
        settings['sizeCh2'],
        settings['intCh2']
    )

    IJ.run("Neurons Spots", args);
    return True

run()
