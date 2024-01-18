from ij import IJ
from ij.gui import GenericDialog
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


X, Y, Z, FRAME, NEW_LABEL = (1, 1, 1, 1, 1)
URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine-Analyzer"


def main():
    if not showDialog():
        return
    image = IJ.getImage()
    image.killRoi()
    
    image = IJ.getImage()
    originalC = image.getC()
    segmentation = InstanceSegmentation(image)
    spineChannel = segmentation.getLabelChannelIndex()
    segmentation.replaceLabel(X, Y, Z, FRAME, NEW_LABEL)
    image.setC(spineChannel)
    image.setDisplayRange(0, 255)
    image.setC(originalC)
    image.updateAndDraw()
    

def showDialog():
    global X, Y, Z, FRAME, NEW_LABEL
    
    gd = GenericDialog("Replace Label Options")
    gd.addNumericField("x: ", X)
    gd.addNumericField("y: ", Y)
    gd.addNumericField("z: ", Z)
    gd.addNumericField("frame: ", FRAME)
    gd.addNumericField("new label: ", NEW_LABEL)
    gd.addHelp(URL)
    gd.showDialog()
    if gd.wasCanceled():
        return False
    X = int(gd.getNextNumber())
    Y = int(gd.getNextNumber())
    Z = int(gd.getNextNumber())
    FRAME = int(gd.getNextNumber())
    NEW_LABEL = int(gd.getNextNumber())
    return True
    

main()

