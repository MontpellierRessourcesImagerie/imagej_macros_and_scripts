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
import os
from ij.process import LUT


def createLUT():
    import random
    r = [random.randint(-128, 127) for i in range(0, 256)]
    g = [random.randint(-128, 127) for i in range(0, 256)]
    b = [random.randint(-128, 127) for i in range(0, 256)]
    r[0] = g[0] = b[0] = 0
    lut = LUT(r, g, b)
    return lut


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
        self.exportMaps = False
        self.current = None


    def checkState(self):
        if (self.rootFolder is None) or (not os.path.isdir(self.rootFolder)):
            self.state = "Provided folder does not exist."
            return False

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

        gui.addDirectoryField("Folder:", IJ.getDirectory("home"))
        gui.addStringField("Extension:", self.extension)
        gui.addFileField("Classifier", "")
        gui.addSlider("Min size:", 0, 500000, self.minSize)
        gui.addSlider("Max size:", 0, 500000, self.maxSize)
        gui.addStringField("Output name:", self.outputName, 25)

        gui.showDialog()

        if gui.wasOKed():
            self.rootFolder = gui.getNextString()
            self.extension = gui.getNextString()
            self.classifierPath = gui.getNextString()
            self.minSize = gui.getNextNumber()
            self.maxSize = gui.getNextNumber()
            self.outputName = gui.getNextString()
            return self.checkState()

        self.state = "Command was canceled."
        return False


    def preprocess(self, img):
        IJ.run(img, "Enhance Contrast...", "saturated=0.35 normalize equalize process_all")
        IJ.run(img, "32-bit", "")
        IJ.run(img, "Divide...", "value=65535")
        return img


    def segment(self, img):
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
        IJ.run(img, "Connected Components Labeling", "connectivity=4 type=[16 bits]")
        temp = IJ.getImage()
        compos = temp.duplicate()
        temp.close()
        
        labels = []
        stats = compos.getStatistics()
        print(int(stats.histMin), int(stats.histMax)+1)

        for i in range(int(stats.histMin), int(stats.histMax)+1):

            if i % 50 == 0:
                print(str(100 * (i / (stats.histMax+1 - stats.histMin)))+"%")
            
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
        expPath = os.path.join(self.rootFolder, self.outputName)
        f = open(expPath, 'w')

        if f.closed:
            self.state = "Failed to export results in: {0}".format()
            return False

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

    
    def assembling(img, labels):
        lut = createLUT()
        labels.setLut(lut)

        newName = path.lower().replace(self.extension, "_map"+self.extension)
        newPath = os.path.join(self.rootFolder, newName)

        assembled = RGBStackMerge.mergeChannels([labels, img], False)
        poly = MaximumFinder().getMaxima(assembled.getProcessor(), 1.0, False)
        assembled.setRoi(PointRoi(poly))

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
        self.results[path] = count
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
        IJ.log("Starting.")

        if settings is not None:
            self.copySettings(settings)
        elif not self.getSettings():
            return False
        IJ.log("p0.")
        if not self.acquireImages():
            return False
        IJ.log("P1")
        for path in self.filesList:
            self.current = path
            if not self.launchImageProcess(path):
                IJ.log("Skipping: {0}".format(path))
            else:
                IJ.log("{0} finished.".format(path))

        if not self.outputToFile():
            return False
        
        self.state = "DONE."
        return True



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

settings = {
    "rootFolder": "/home/benedetti/Documents/projects/6-solange-counting/Testing/test_script_2",
    "minSize": 3200,
    "maxSize": 12000,
    "extension": ".tif",
    "outputName": "someName.csv",
    "classifierPath": "/home/benedetti/Bureau/counting-nuclei/iter-3.classifier",
    "exportMaps": True
}

# cn = CountNuclei()
# cn.run(settings)
# IJ.log(cn.getState())



def assembling(img, labels):
    lut = createLUT()
    labels.setLut(lut)

    assembled = RGBStackMerge.mergeChannels([labels, img], False)
    poly = MaximumFinder().getMaxima(assembled.getProcessor(), 1.0, False)
    assembled.setRoi(PointRoi(poly))

    IJ.saveAs(assembled, "tiff", "/home/benedetti/Bureau/test.tif")

lbl = IJ.openImage("/home/benedetti/Documents/projects/6-solange-counting/Testing/test_script_2/48_w3dapi_map.tif")
ori = IJ.openImage("/home/benedetti/Documents/projects/6-solange-counting/Testing/test_script_2/48_w3DAPI.TIF")

assembling(ori, lbl)