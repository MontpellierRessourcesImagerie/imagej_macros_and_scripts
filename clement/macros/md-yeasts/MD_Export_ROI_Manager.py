from ij import IJ
from mdYeasts.userIO import exportRoiManager, readSettings

def run():
    settings, verbose = readSettings()

    if settings is None:
        IJ.log("Impossible to read settings: {0}".format(verbose))
        return False

    exportRoiManager(IJ.getImage(), settings['exportRois'])
    return True

run()