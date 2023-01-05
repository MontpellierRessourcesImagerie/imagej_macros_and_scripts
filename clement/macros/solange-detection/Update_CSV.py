from ij import IJ
from nucleiTools.CountNuclei import updatePointsCount

def run():
    updatePointsCount(IJ.getImage())

run()