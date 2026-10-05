from ij import IJ
from ij.plugin import Duplicator
from ij.plugin import ImageCalculator
from ij.plugin import ZProjector
from ij.measure import ResultsTable
from ij.plugin.filter import RankFilters
from inra.ijpb.label import LabelImages
from inra.ijpb.measure import IntensityMeasures



class KinetochoreAnalyzer(object):


    def __init__(self, cellSegmenter, spotSegmenter, image):
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
        self.table =None


    def run(self):
        self.segmentCells()
        self.segmentKinetochores()
        self.segmentSignal()
        self.removeKinetochoresOutOfCells()
        self.removeSignalOutOfCells()
        self.createSignalImageWithCellBackgroundRemoved()
        self.measureSignalInKinetochores()
        
        
    def segmentCells(self):
        inFocusImage = self.imageTool.getInFocusSlice(self.cellChannelNr)
        self.cellSegmenter.run(inFocusImage)
        inFocusImage.close()
        self.cellLabels = self.cellSegmenter.labels


    def segmentKinetochores(self):
        image = self.imageTool.getMaxProjectionOf(self.kinetochoreChannelNr)
        self.spotSegmenter.run(image, self.spotLabel)
        image.close()
        self.kinetochoreMask = self.spotSegmenter.mask


    def segmentSignal(self):
        image = self.imageTool.getMaxProjectionOf(self.signalChannelNr)
        self.spotSegmenter.run(image, self.spotLabel)
        image.close()
        self.signalMask = self.spotSegmenter.mask
        

    def removeKinetochoresOutOfCells(self):
        self.kinetochoreMask = self.removeOutOfCells(self.kinetochoreMask)
        
        
    def removeSignalOutOfCells(self):
        self.signalMask = self.removeOutOfCells(self.signalMask)
        
        
    def removeOutOfCells(self, mask):
        cellMask = self.getCellMask()
        result = ImageCalculator.run(cellMask, mask, "and")
        return result


    def getCellMask(self):
        cellMask = self.imageTool.copyImage(self.cellLabels)
        cellMask.getProcessor().setThreshold(1.0000, 1000000000000000000000000000000.0000)
        cellMask.setProcessor(cellMask.createThresholdMask())
        return cellMask


    def createSignalImageWithCellBackgroundRemoved(self):
        self.signal = self.imageTool.getMaxProjectionOf(self.signalChannelNr)
        labelsWithHoles = self.getLabelsWithHoles()
        measurements = IntensityMeasures(self.signal, labelsWithHoles)
        table = measurements.getMax()
        table.show("max")
        maxValues = table.getColumn("Max")
        for label, intensity in enumerate(maxValues, start=1):
            labelImage = LabelImages.keepLabels(self.cellLabels, [label])
            IJ.setThreshold(labelImage, label, 1000000000000000000000000000000.0000)
            IJ.run(labelImage, "Create Selection", "")
            roi = labelImage.getRoi()
            self.signal.setRoi(roi)
            IJ.run(self.signal, "Subtract...", "value=" + str(intensity))
        self.signal.resetRoi()


    def getLabelsWithHoles(self):
        labels = self.imageTool.copyImage(self.cellLabels)
        cellMask = self.getCellMask()
        cellMask = ImageCalculator.run(cellMask, self.kinetochoreMask, "subtract create")
        cellMask = ImageCalculator.run(cellMask, self.signalMask, "subtract create")
        cellLabelsWithHoles = ImageCalculator.run(labels, cellMask, "and create")
        return cellLabelsWithHoles


    def measureSignalInKinetochores(self):
        kLabels = ImageCalculator.run(self.kinetochoreMask, self.cellLabels, "and create")
        sLabels = ImageCalculator.run(self.signalMask, self.cellLabels, "and create")
        sLabels.show()
        print("signal mask", self.signalMask, type(self.signalMask))
        print("slabels", sLabels, type(sLabels))
        measurements = IntensityMeasures(kLabels, sLabels)
        table = measurements.getMax()
        maxValues = table.getColumn("Max")
        labels = []
        for i, maxValue in enumerate(maxValues):
            if maxValue < 1:
                continue
            label = table.getLabel(i)
            labels.append(int(label))
        print("labels", labels)
        labelsToBeMeasured = LabelImages.keepLabels(sLabels, labels)
        iMeasurements = IntensityMeasures(self.signal, labelsToBeMeasured)
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
    

    def __init__(self):
        super(CellposeSegmenter, self).__init__()
        self.env_path = ""
        self.env_type = "conda"
        self.model= "cyto"
        self.model_path = " "
        self.diameter = 50
        self.useGPU = False
        self.ch1 = 0
        self.ch2 = 0
        self.labels = None


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


    def __init__(self, classifierPath):
        super(LabKitSpotSegmenter, self).__init__()
        self.classifierPath = classifierPath
        self.useGPU = False
        self.mask = None


    def run(self, image, labelOfInterest):
        image.show()
        parameters = self.getParameterString()
        IJ.run(image,
               "Segment Image With Labkit",
               "input =" + image.getTitle() + " " + parameters)
        labels = IJ.getImage()
        self.mask = LabelImages.keepLabels(labels, [labelOfInterest])
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
        projection = ZProjector.run(image, "max")
        return projection
        
        
    def copyImage(self, anImage):
        return self.duplicator.run(anImage)