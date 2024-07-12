from ij import IJ
from nucleiTools.CountNuclei import makePointsROI

def run():
    makePointsROI(IJ.getImage())

run()