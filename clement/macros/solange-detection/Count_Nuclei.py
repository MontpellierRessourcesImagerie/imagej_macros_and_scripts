from ij import IJ
from nucleiTools.CountNuclei import launchCounting, makeDefaultSettings

def run():
    try:
        from mriGeneral.RandomLUT import randomLUT
    except e:
        IJ.log("The package 'mriGeneral.RandomLUT' is required.")
        return

    # launchCounting(makeDefaultSettings())
    launchCounting()

run()