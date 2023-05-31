from ij import IJ
from spotsInNeurites.settingsManager import importSettings, getDefaultNames
import os

def run():
    settings = importSettings()
    defNames = getDefaultNames()

    rawDir = os.path.join(settings['workingDir'], settings['rawDirName'])
    mipDir = os.path.join(settings['workingDir'], defNames['mip'])

    args = "redsuffix={0} greensuffix={1} choose_mip_source=[{2}] choose_raw_source=[{3}] slices={4}".format(
        settings['redSuffix'],
        settings['greenSuffix'],
        mipDir,
        rawDir,
        settings['slicesTol']
    )

    IJ.run("verif mip", args)
    return True

run()
