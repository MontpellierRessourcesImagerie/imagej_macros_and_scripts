from ij import IJ
from spotsInNeurites.settingsManager import importSettings, getDefaultNames
import os

def run():
    settings = importSettings()
    defNames = getDefaultNames()
    
    rawDir = os.path.join(settings['workingDir'], settings['rawDirName'])
    mipDir = os.path.join(settings['workingDir'], defNames['mip'])

    if not os.path.isdir(mipDir):
        os.mkdir(mipDir)
    elif len(os.listdir(mipDir)) > 0:
        IJ.log("'{0}' already exists, beware of possible file collisions.".format(defNames['mip']))

    args = "choose={0} choose_result={1} slices={2} redsuffix={3} greensuffix={4}".format(
        rawDir, 
        mipDir, 
        settings['slicesTol'],
        settings['redSuffix'],
        settings['greenSuffix']
    )
    IJ.run("stack-focus mip", args)
    return True

run()