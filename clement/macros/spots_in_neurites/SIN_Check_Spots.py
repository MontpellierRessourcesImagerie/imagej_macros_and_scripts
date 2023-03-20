from ij import IJ
from spotsInNeurites.settingsManager import importSettings, getDefaultNames
import os

def run():
    settings = importSettings()
    defNames = getDefaultNames()

    red         = settings['redSuffix'].split('.')[0]
    green       = settings['greenSuffix'].split('.')[0]
    mipDir      = os.path.join(settings['workingDir'], defNames['mip'])
    redMipDir   = os.path.join(mipDir, red)
    greenMipDir = os.path.join(mipDir, green)
    maskDir     = os.path.join(settings['workingDir'], defNames['segmentation'])
    spotsDir    = os.path.join(settings['workingDir'], defNames['spots'])

    args = "mipredsuffix={0} mipgreensuffix={1} redmipdir=[{2}] greenmipdir=[{3}] maskdir=[{4}] spotsdir=[{5}]".format(
        settings['redSuffix'],
        settings['greenSuffix'],
        redMipDir,
        greenMipDir,
        maskDir,
        spotsDir
    )

    IJ.run("Verif Spots", args)
    return True

run()
