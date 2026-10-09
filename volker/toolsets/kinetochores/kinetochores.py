from ij import IJ
from java.lang import Math
from java.awt import Color
from ij import ImagePlus
from ij.gui import Overlay
from ij.plugin import Duplicator
from ij.plugin import ImageCalculator
from ij.plugin import ZProjector
from ij.measure import ResultsTable
from ij.plugin.filter import RankFilters
from inra.ijpb.label import LabelImages
from inra.ijpb.measure import IntensityMeasures
from inra.ijpb.color.ColorMaps import CommonLabelMaps
from inra.ijpb.color import ColorMaps
from inra.ijpb.label.conncomp import LabelBoundariesLabeling2D



class KinetochoreAnalyzer(object):


    def __init__(self, cellSegmenter, spotSegmenter, image, options=None):
        super(KinetochoreAnalyzer, self).__init__()
        self.cellSegmenter = cellSegmenter
        self.spotSegmenter = spotSegmenter
        self.image = image
        self.imageTool = ImageTool(self.image)
        self.cellChannelNr = 1
        self.kinetochoreChannelNr = 2
        self.signalChannelNr = 1
        self.spotLabel = 1
        self.cellLabels = None
        self.kinetochoreMask = None
        self.signalMask = None
        self.signal = None
        self.signalLabels = None
        self.table =None
        self.controlImage = None
        self.subtractBackgroundValue = "max"
        if options:
            self.setOptions(options)


    def setOptions(self, options):
        self.cellChannelNr = options.value("cell channel")
        self.kinetochoreChannelNr = options.value("kinetochore channel")
        self.signalChannelNr = options.value("signal channel")
        self.subtractBackgroundValue = options.value("background subtraction value")
        self.spotLabel = options.value("spot label")


    def run(self):
        IJ.log("Segmenting cells...")
        self.segmentCells()
        IJ.log("Segmenting kinetochores...")
        self.segmentKinetochores()
        IJ.log("Segmenting the signal...")
        self.segmentSignal()
        IJ.log("Removing kinetochores out of cells...")
        self.removeKinetochoresOutOfCells()
        IJ.log("Removing signal out of cells...")
        self.removeSignalOutOfCells()
        IJ.log("Removing signal background...")
        self.createSignalImageWithCellBackgroundRemoved()
        IJ.log("Measuring kinetochores...")
        self.measureSignalInKinetochores()
        IJ.log("Creating the control image...")
        self.createControlImage()
        

    def createControlImage(self):
        self.controlImage = ImageTool.getMaxProjection(self.image)
        self.addCellContoursToControlImage()
        self.adjustControlImageDisplay()
        overlay = self.addKinetochoreRoiToControlImage()
        self.addSignalRoiToControlImage(overlay)


    def addSignalRoiToControlImage(self, overlay):
        IJ.setThreshold(self.signalLabels, 1.0000, 1000000000000000000000000000000.0000)
        IJ.run(self.signalLabels, "Create Selection", "")
        roi = self.signalLabels.getRoi()
        self.signalLabels.getProcessor().resetThreshold()
        roi.setStrokeColor(Color.GREEN)
        overlay.add(roi, "signal")
        self.controlImage.setOverlay(overlay)
        self.controlImage.resetRoi()


    def addKinetochoreRoiToControlImage(self):
        IJ.run(self.kinetochoreMask, "Create Selection", "")
        roi = self.kinetochoreMask.getRoi()
        roi.setStrokeColor(Color.RED)
        overlay = Overlay()
        overlay.add(roi, "kinetochores")
        self.controlImage.setRoi(roi)
        return overlay


    def adjustControlImageDisplay(self):
        nChannels = self.controlImage.getNChannels()
        for i in range(2, nChannels+1):
            self.controlImage.setPosition(i,1,1)
            IJ.resetMinAndMax(self.controlImage)
        self.controlImage.setPosition(1, 1, 1)
        IJ.resetMinAndMax(self.controlImage)
        self.controlImage.setProp("CompositeProjection", "Sum")
        self.controlImage.setDisplayMode(IJ.COMPOSITE)


    def addCellContoursToControlImage(self):
        IJ.run(self.cellLabels, "Label Morphological Filters", "operation=Erosion radius=1 from_any_label")
        cellLabelErosion = IJ.getImage()
        cellLabelContours = self.doRegionBoundaryLabeling(cellLabelErosion)
        cellLabelErosion.close()
        shortProcessor = cellLabelContours.getProcessor().convertToShortProcessor(False)
        cellLabelContours.setProcessor(shortProcessor)
        IJ.run(self.controlImage, "Add Slice", "add=channel prepend")
        self.controlImage.setPosition(1, 1, 1)
        self.controlImage.setProcessor(shortProcessor)
        IJ.run(self.controlImage, "glasbey on dark", "")
        cellLabelContours.close()


    def doRegionBoundaryLabeling(self, cellLabelContours):
        colorMap = CommonLabelMaps.GLASBEY_BRIGHT.computeLut(255, False)
        cm = ColorMaps.createColorModel(colorMap, Color.BLACK)
        algo = LabelBoundariesLabeling2D()
        res = algo.process(cellLabelContours.getProcessor())
        boundaries = res.boundaryLabelMap
        newName = cellLabelContours.getShortTitle() + "-bnd"
        resultPlus = ImagePlus(newName, boundaries)
        resultPlus.getProcessor().setColorModel(cm)
        resultPlus.setDisplayRange(0, Math.max(res.boundaries.size(), 255))
        return resultPlus


    def segmentCells(self):
        inFocusImage = self.imageTool.getInFocusSlice(self.cellChannelNr)
        self.cellSegmenter.run(inFocusImage)
        inFocusImage.close()
        self.cellLabels = self.cellSegmenter.labels
        self.cellLabels.setTitle("cell labels")


    def segmentKinetochores(self):
        image = self.imageTool.getMaxProjectionOf(self.kinetochoreChannelNr)
        self.spotSegmenter.run(image)
        image.close()
        self.kinetochoreMask = self.spotSegmenter.mask
        self.kinetochoreMask.setTitle("kinetochore mask")


    def segmentSignal(self):
        image = self.imageTool.getMaxProjectionOf(self.signalChannelNr)
        self.spotSegmenter.run(image)
        image.close()
        self.signalMask = self.spotSegmenter.mask
        self.signalMask.setTitle("signal mask")
        

    def removeKinetochoresOutOfCells(self):
        self.kinetochoreMask = self.removeOutOfCells(self.kinetochoreMask)
        
        
    def removeSignalOutOfCells(self):
        self.signalMask = self.removeOutOfCells(self.signalMask)
        
        
    def removeOutOfCells(self, mask):
        cellMask = self.getCellMask()
        result = ImageCalculator.run(cellMask, mask, "and")
        return result


    def getCellMask(self):
        cellMask = ImageTool.copyImage(self.cellLabels)
        cellMask.getProcessor().setThreshold(1.0000, 1000000000000000000000000000000.0000)
        cellMask.setProcessor(cellMask.createThresholdMask())
        return cellMask


    def createSignalImageWithCellBackgroundRemoved(self):
        self.signal = self.imageTool.getMaxProjectionOf(self.signalChannelNr)
        labelsWithHoles = self.getLabelsWithHoles()
        measurements = IntensityMeasures(self.signal, labelsWithHoles)
        table = measurements.getMean()
        if self.subtractBackgroundValue=="max":
            table = measurements.getMax()
        if self.subtractBackgroundValue=="mode":
            table = measurements.getMode()
        if self.subtractBackgroundValue=="median":
            table = measurements.getMedian()
        maxValues = table.getColumn(self.subtractBackgroundValue.capitalize())
        for label, intensity in enumerate(maxValues, start=1):
            labelImage = LabelImages.keepLabels(self.cellLabels, [label])
            IJ.setThreshold(labelImage, label, 1000000000000000000000000000000.0000)
            IJ.run(labelImage, "Create Selection", "")
            roi = labelImage.getRoi()
            self.signal.setRoi(roi)
            IJ.run(self.signal, "Subtract...", "value=" + str(intensity))
        self.signal.resetRoi()
        self.signal.setTitle("signal with background removed")


    def getLabelsWithHoles(self):
        labels = self.imageTool.copyImage(self.cellLabels)
        cellMask = self.getCellMask()
        cellMask = ImageCalculator.run(cellMask, self.kinetochoreMask, "subtract create")
        cellMask = ImageCalculator.run(cellMask, self.signalMask, "subtract create")
        cellLabelsWithHoles = ImageCalculator.run(labels, cellMask, "and create")
        return cellLabelsWithHoles


    def measureSignalInKinetochores(self):
        kLabels = ImageCalculator.run(self.cellLabels, self.kinetochoreMask, "and create")
        sLabels = ImageCalculator.run(self.cellLabels, self.signalMask, "and create")
        measurements = IntensityMeasures(kLabels, sLabels)
        table = measurements.getMax()
        maxValues = table.getColumn("Max")
        labels = []
        for i, maxValue in enumerate(maxValues):
            if maxValue < 1:
                continue
            label = table.getLabel(i)
            labels.append(int(label))
        self.signalLabels = LabelImages.keepLabels(sLabels, labels)
        self.signalLabels.setTitle("co-occuring signal labels")
        iMeasurements = IntensityMeasures(self.signal, self.signalLabels)
        self.table = ResultsTable()
        maxValues = iMeasurements.getMax()
        meanValues = iMeasurements.getMean()
        medianValues = iMeasurements.getMedian()
        minValues = iMeasurements.getMin()
        modeValues = iMeasurements.getMode()
        stdDevValues = iMeasurements.getStdDev()
        index = 0
        for maxValue, meanValue, medianValue, minValue, modeValue, stdValue in zip(maxValues.getColumn("Max"),
                                                                                   meanValues.getColumn("Mean"),
                                                                                   medianValues.getColumn("Median"),
                                                                                   minValues.getColumn("Min"),
                                                                                   modeValues.getColumn("Mode"),
                                                                                   stdDevValues.getColumn("StdDev")):
            self.table.addRow()
            self.table.addLabel(maxValues.getLabel(index))
            self.table.addValue("image", self.image.getTitle())
            self.table.addValue("Max", maxValue)
            self.table.addValue("Mean", meanValue)
            self.table.addValue("StdDev", stdValue)
            self.table.addValue("Median", medianValue)
            self.table.addValue("Min", minValue)
            self.table.addValue("Mode", modeValue)
            index = index + 1



class CellposeSegmenter(object):
    

    def __init__(self, options=None):
        super(CellposeSegmenter, self).__init__()
        self.env_path = ""
        self.env_type = "conda"
        self.model= "cyto"
        self.model_path = ""
        self.diameter = 50
        self.useGPU = False
        self.ch1 = 0
        self.ch2 = 0
        self.labels = None
        if options:
            self.setOptions(options)
        
        
    def setOptions(self, options):
        self.env_path = options.value("conda env path")
        self.model_path = options.value("model path")
        self.diameter = options.value("cell diameter")
        self.useGPU = options.value("use gpu")


    def run(self, image):
        image.show()
        args = self.getParameterString()
        IJ.run(image, "Cellpose ...", args)
        self.labels = IJ.getImage()
        self.labels.hide()


    def getParameterString(self):
        parameters = (
                "env_path=" + self.env_path + " "
                "env_type=" + self.env_type + " "
                "model=" + self.model + " "
                "model_path=" + self.model_path + " "
                "diameter=" + str(self.diameter) + " "
        )
        if self.useGPU:
            parameters = parameters + "additional_flags=--use_gpu "
        parameters = parameters + "ch1=" + str(self.ch1) + " " + "ch2=" + str(self.ch2)
        return parameters



class LabKitSpotSegmenter(object):


    def __init__(self, options=None):
        super(LabKitSpotSegmenter, self).__init__()
        self.useGPU = False
        self.mask = None
        self.classifierPath = ""
        self.labelOfInterest = 2
        if options:
            self.setOptions(options)


    def setOptions(self, options):
        self.labelOfInterest = options.value("spot label")
        self.classifierPath = options.value("labkit classifier path")


    def run(self, image):
        image.show()
        parameters = self.getParameterString()
        IJ.run(image,
               "Segment Image With Labkit",
               "input =" + image.getTitle() + " " + parameters)
        labels = IJ.getImage()
        self.mask = LabelImages.keepLabels(labels, [self.labelOfInterest])
        labels.close()
        self.mask.setAutoThreshold("Default dark")
        IJ.run(self.mask, "Convert to Mask", "")


    def getParameterString(self):
        useGPUString = "false"
        if self.useGPU:
            useGPUString = "true"
        parameters = ("segmenter_file=" + self.classifierPath + " "
                      "use_gpu=" + useGPUString)
        print(parameters)
        return parameters


class ImageTool(object):


    def __init__(self,  image):
        super(ImageTool, self).__init__()
        self.image = image
        self.width, self.height, self.channels, self.slices, self.frames = self.image.getDimensions()
        self.rankFilters = RankFilters()
        self.duplicator = Duplicator()


    def getChannel(self, channelNr):
        channel = self.duplicator.run(self.image, channelNr, channelNr, 1, self.slices, 1, self.frames)
        return channel


    def getInFocusSlice(self, channelNr):
        stack = self.getChannel(channelNr).getStack()
        index = self.getIndexOfMaxStdDevOfVariance(stack)
        stackSlice = self.duplicator.run(self.image, channelNr, channelNr, index, index, 1, self.frames)
        return stackSlice


    def getIndexOfMaxStdDevOfVariance(self, stack):
        stdDeviations = []
        for i in range(1, self.slices + 1):
            processor = stack.getProcessor(i)
            self.rankFilters.rank(processor, 1.0, RankFilters.VARIANCE)
            stats = processor.getStats()
            stdDeviations.append(stats.stdDev)
        return stdDeviations.index(max(stdDeviations)) + 1


    def getMaxProjectionOf(self, channelNr):
        image = self.getChannel(channelNr)
        projection =self.getMaxProjection(image)
        return projection
        

    @classmethod
    def getMaxProjection(cls, image):
        projection = ZProjector.run(image, "max")
        return projection


    @classmethod
    def copyImage(cls, anImage):
        return Duplicator().run(anImage)