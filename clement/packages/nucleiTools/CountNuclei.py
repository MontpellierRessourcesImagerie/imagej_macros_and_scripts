from ij import IJ, ImagePlus, ImageStack
from fiji.util.gui import GenericDialogPlus
from ij.plugin import ZProjector, Concatenator, Duplicator, ImageCalculator, RGBStackMerge
from ij.plugin.filter import ImageMath, MaximumFinder
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
from inra.ijpb.plugins import MorphologicalFilterPlugin
from inra.ijpb.morphology.Morphology import Operation
from inra.ijpb.morphology import Strel
from ij.process import ShortProcessor, FloatProcessor
from inra.ijpb.label.edit import ReplaceLabelValues
from ij.gui import Roi, PolygonRoi, PointRoi
from mriGeneral.RandomLUT import randomLUT
import os

pathPropName = "mri.count-nuclei.path"
idPropName = "mri.count-nuclei.id"

def selectLabel(img, lbl):
    ip = img.getProcessor()
    fp = ip.convertToFloatProcessor()
    fp2 = ip.convertToFloatProcessor()

    fp2.set(1.0)
    buffer = ImagePlus("temp1", fp2)

    fp.subtract(lbl)
    im1 = ImagePlus("temp2", fp)
    im2 = ImageCalculator.run(im1, im1, "mul")
    im2.getProcessor().multiply(-0.5)
    im2.getProcessor().exp()

    imOut = ImageCalculator.run(buffer, im2, "and")

    lp = imOut.getProcessor()
    lp.multiply(lbl / 65535.0)

    im1.close()
    im2.close()

    return ImagePlus("label_{0}".format(lbl), lp.convertToShortProcessor())


## @brief More consise way to write the closing operation.
def closing(img, rad):
    return MorphologicalFilterPlugin().process(img, Operation.CLOSING, Strel.Shape.DISK.fromRadius(rad))


class CountNuclei:

    def __init__(self):
        self.state = "Uninitialized."
        self.rootFolder = None
        self.filesList = []
        self.minSize = 3200
        self.maxSize = 12000
        self.results = {}
        self.extension = ".tif"
        self.outputName = "untitled.csv"
        self.classifierPath = None
        self.exportMaps = True
        self.current = None
        self.exportFolder = ""


    def checkState(self):
        if (self.rootFolder is None) or (not os.path.isdir(self.rootFolder)):
            self.state = "Provided folder does not exist."
            return False

        self.exportFolder = os.path.join(self.rootFolder, "results")
        if not os.path.isdir(self.exportFolder):
            os.mkdir(self.exportFolder)

        if (self.minSize >= self.maxSize):
            self.state = "Min size can't be equal or bigger than max size."
            return False

        self.outputName = self.outputName.lower().strip()
        if not self.outputName.endswith(".csv"):
            self.outputName += ".csv"
        if os.path.sep in self.outputName:
            self.state = "You must provide a name, not a path."
            return False

        self.extension = self.extension.lower()
        if not self.extension[0] == ".":
            self.extension = "." + self.extension

        if (self.classifierPath is None) or (not os.path.isfile(self.classifierPath) or (not self.classifierPath.endswith(".classifier"))):
            self.state = "The classifier path is not valid. It must be a file having the extension \".classifier\""
            return False

        return True


    def getSettings(self):
        gui = GenericDialogPlus("Count Nuclei Settings")

        defaultClassif = os.path.join(IJ.getDirectory("plugins"), "solange-detection")
        defaultClassif = os.path.join(defaultClassif, "current.classifier")

        gui.addDirectoryField("Folder:", IJ.getDirectory("home"))
        gui.addStringField("Extension:", self.extension)
        gui.addFileField("Classifier", defaultClassif)
        gui.addSlider("Min size:", 0, 500000, self.minSize)
        gui.addSlider("Max size:", 0, 500000, self.maxSize)
        gui.addStringField("Output name:", self.outputName, 25)
        gui.addCheckbox("Export maps:", self.exportMaps)
        gui.addHelp(r"http://www.rule94.com/documentation-html/nucleicount/index.html")

        gui.showDialog()

        if gui.wasOKed():
            self.rootFolder = gui.getNextString()
            self.extension = gui.getNextString()
            self.classifierPath = gui.getNextString()
            self.minSize = gui.getNextNumber()
            self.maxSize = gui.getNextNumber()
            self.outputName = gui.getNextString()
            self.exportMaps = gui.getNextBoolean()
            return self.checkState()

        self.state = "Command was canceled."
        return False


    def preprocess(self, img):
        IJ.log("Preprocessing...");
        IJ.run(img, "Enhance Contrast...", "saturated=0.35 normalize equalize process_all")
        IJ.run(img, "32-bit", "")
        IJ.run(img, "Divide...", "value=65535")
        return img


    def segment(self, img):
        IJ.log("Segmentation...");
        img.show() # Mandatory to get LabKit working...

        try:
            IJ.run(img, "Segment Image With Labkit", "segmenter_file={0} use_gpu=false".format(self.classifierPath))
        except:
            IJ.log("Failed to launch LabKit")
            return None
        
        segmentationVirtual = IJ.getImage()
        rawSegmentation = segmentationVirtual.duplicate()

        segmentationVirtual.changes = False
        img.changes = False

        segmentationVirtual.close()
        img.close()

        ReplaceLabelValues().process(rawSegmentation, [2], 0)

        return rawSegmentation


    def postprocess(self, img):
        IJ.log("Postprocessing...");
        IJ.run(img, "Connected Components Labeling", "connectivity=4 type=[16 bits]")
        temp = IJ.getImage()
        compos = temp.duplicate()
        temp.close()
        
        labels = []
        stats = compos.getStatistics()

        for i in range(int(stats.histMin), int(stats.histMax)+1):

            if i % 100 == 0:
                IJ.log(str(100 * (i / (stats.histMax+1 - stats.histMin)))+"%")
            
            if stats.histogram16[i] < 1800:
                continue
            
            isolatedLabel = selectLabel(compos, i)

            fixedLabel = closing(isolatedLabel, 15)
            isolatedLabel.close()

            area = fixedLabel.getStatistics().histogram16[i]

            if (area < self.minSize) or (area > self.maxSize):
                fixedLabel.close()
            else:
                labels.append(fixedLabel)

        compos.close()
        filtered = Concatenator().concatenate(labels, False)
        
        for img in labels:
            img.close()

        assembled = ZProjector.run(filtered, "max all")
        filtered.close()
        
        return assembled, len(labels)


    def outputToFile(self):
        IJ.log("Exporting results...");
        expPath = os.path.join(self.exportFolder, self.outputName)
        f = open(expPath, 'w')

        if f.closed:
            self.state = "Failed to export results in: {0}".format()
            return False

        f.write("File, Count\n")
        keys = sorted(self.results.keys())
        for key in keys:
            f.write("{0},{1}\n".format(key, str(self.results[key])))

        f.close()

        return True


    def getState(self):
        return self.state

    
    def acquireImages(self):
        content = [f for f in os.listdir(self.rootFolder) if f.lower().endswith(self.extension)]

        if len(content) > 0:
            self.filesList = content
            return True
        else:
            self.state = "The folder doesn't contain anything for the given extension."
            return False

    
    def assembling(self, img, labels):
        randomLUT(labels)

        newName = self.current.lower().replace(self.extension, "_map"+self.extension)
        newPath = os.path.join(self.exportFolder, newName)

        assembled = RGBStackMerge.mergeChannels([labels, img], False)
        
        assembled.setProp(pathPropName, os.path.join(self.exportFolder, self.outputName))
        assembled.setProp(idPropName, self.current)

        IJ.saveAs(assembled, "tiff", newPath)


    def launchImageProcess(self, path):
        # Opening image
        fullPath = os.path.join(self.rootFolder, path)
        img = IJ.openImage(fullPath)
        if img is None:
            return False

        original = img.duplicate()

        # Preprocessing
        img = self.preprocess(img)
        if img is None:
            return False

        # Segmentation / detection
        img = self.segment(img)
        if img is None:
            return False

        # Postprocess
        img, count = self.postprocess(img)
        if img is None:
            return False

        if self.exportMaps == True:
            self.assembling(original, img)

        # Recording number
        self.results[self.current] = count
        img.close()

        return True

    
    def copySettings(self, settings):
        self.rootFolder = settings["rootFolder"]
        self.minSize = settings["minSize"]
        self.maxSize = settings["maxSize"]
        self.extension = settings["extension"]
        self.outputName = settings["outputName"]
        self.classifierPath = settings["classifierPath"]
        self.exportMaps = settings["exportMaps"]


    def run(self, settings=None):

        if settings is not None:
            self.copySettings(settings)
            if not self.checkState():
                return False
        elif not self.getSettings():
            return False

        IJ.log("Starting.")
        
        if not self.acquireImages():
            return False
        
        for path in self.filesList:
            self.current = path
            IJ.log("= = = = = Starting processing on: {0} = = = = =".format(self.current))
            if not self.launchImageProcess(path):
                IJ.log("Skipping: {0}".format(path))
            else:
                IJ.log("= = = = = {0} finished. = = = = =".format(path))

        if not self.outputToFile():
            return False
        
        self.state = "DONE."
        return True



def makeDefaultSettings():
    settings = {
        "rootFolder": "/home/benedetti/Documents/projects/6-solange-counting/Testing/test_script_2",
        "minSize": 3200,
        "maxSize": 12000,
        "extension": ".tif",
        "outputName": "untitled.csv",
        "classifierPath": "/home/benedetti/Bureau/counting-nuclei/iter-3.classifier",
        "exportMaps": True
    }
    return settings


def makeNewLines(lines, idLine, val):
    newLines = []

    for line in lines:
        if not line.startswith(idLine):
            newLines.append(line)
            continue
        newLines.append(idLine + "," + str(val))
    
    return"\n".join(newLines)
        


def updatePointsCount(img):
    if img is None:
        return

    csvPath = img.getProp(pathPropName)
    if (csvPath is None) or (csvPath == ""):
        IJ.log("CSV path not found in properties.")

    idLine = img.getProp(idPropName)
    if (idLine is None) or (idLine == ""):
        IJ.log("Image's ID couldn't be found in properties.")
        return

    roi = img.getRoi()
    if roi.getType() != Roi.POINT:
        IJ.log("Roi should be a multi-point selection.")
        return
    
    nPoints = roi.size()
    
    f = open(csvPath, 'r')
    if f.closed:
        IJ.log("Failed to open CSV")
        return
    raw = f.read()
    f.close()

    lines = raw.split('\n')
    newLines = makeNewLines(lines, idLine, nPoints)

    f = open(csvPath, 'w')
    if f.closed:
        IJ.log("Failed to open CSV")
        return

    f.write(newLines)
    f.close()


def makePointsROI(img):
    img.setC(1)
    IJ.setTool("multipoint")

    poly = MaximumFinder().getMaxima(img.getProcessor(), 1.0, False)
    
    pt = PointRoi(poly)
    pt.setHandleSize(4)
    pt.setShowLabels(True)

    img.setRoi(pt, True)


def launchCounting(settings=None):
    cn = CountNuclei()
    status = cn.run(settings)

    if status:
        IJ.log("Execution successful.")
    else:
        IJ.log("Something went wrong. Abort.")

    IJ.log(cn.getState())


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#
#       TO DO:
#
# - [X] Add CSV apth in the properties of each image.
# - [ ] Le package "mriGeneral.RandomLUT" est requis pour que le script fonctionne.
# - [ ] Faire un script d'installation qui va chercher les bons packages sur GitHub.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
