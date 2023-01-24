from mdYeasts.userIO import askSettings
from ij import IJ

def run():
    status, verbose = askSettings()

    if not status:
        IJ.log(verbose)
        return False
    
    return True

run()