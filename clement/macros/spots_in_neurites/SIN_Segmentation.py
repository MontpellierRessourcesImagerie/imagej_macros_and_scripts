from ij import IJ
from spotsInNeurites.settingsManager import importSettings, getDefaultNames
import os
import subprocess

def run():
    settings = importSettings()
    defNames = getDefaultNames()
    opj = os.path.join

    mipDir     = opj(settings['workingDir'], defNames['mip'])
    redMipDir  = settings['redSuffix'].split('.')[0]
    redDirPath = opj(mipDir, redMipDir)

    scriptPath = opj(IJ.getDirectory("imagej"), "spotsInNeurites")
    pythonPath = opj(settings['condaPath'], os.sep.join(["envs", "dl4mic", "bin", "python"]))
    maskPath   = opj(settings['workingDir'], defNames['segmentation'])

    if not os.path.isdir(maskPath):
        os.mkdir(maskPath)
    elif len(os.listdir(maskPath)) > 0:
        IJ.log("'{0}' already exists, beware of possible file collisions.".format(defNames['segmentation']))

    commandLine = "cd {0}; {1} -u predict.py --name 11-03-22_unet2D_model --baseDir ./ --dataPath {2} --output {3} --threshold 180".format(
        scriptPath,
        pythonPath,
        redDirPath,
        maskPath
    )
    
    if subprocess.call(commandLine, shell=True) != 0:
        IJ.log("An error occured")
        return False
    
    IJ.log("Segmentation: DONE.")
    return True

run()