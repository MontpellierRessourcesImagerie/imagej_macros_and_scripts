from java.lang import Math
from java.awt import Color
from ij import IJ
from ij import ImagePlus
from ij import WindowManager
from ij.gui import Overlay
from ij.plugin import Duplicator
from ij.plugin import ImageCalculator
from ij.plugin import ZProjector
from ij.measure import ResultsTable
from ij.measure import Measurements
from ij.plugin.filter import RankFilters
from inra.ijpb.label import LabelImages
from inra.ijpb.measure import IntensityMeasures
from inra.ijpb.morphology import Morphology
from inra.ijpb.morphology.strel import DiskStrel
from inra.ijpb.color.ColorMaps import CommonLabelMaps
from inra.ijpb.color import ColorMaps
from inra.ijpb.label.conncomp import LabelBoundariesLabeling2D



class KinetochoreAnalyzer(object):
    """Base class for kinetochore signal analysis.

    Handles everything shared by the two measurement approaches: cell,
    kinetochore and signal segmentation, removal of structures outside the
    cells, per-cell background subtraction, the per-cell results table and the
    control image scaffold. Subclasses must implement `measureSignal()` and
    `addMeasuredSignalRoiToControlImage()`.
    """

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
        self.table = None
        self.controlImage = None
        self.subtractBackgroundValue = "mean"
        self.kinetochoreDilationRadius = 3
        self.signalThreshold = 0
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
        IJ.log("Measuring signal...")
        self.measureSignal()
        IJ.log("Creating the control image...")
        self.createControlImage()


    def measureSignal(self):
        raise NotImplementedError("Subclasses must implement measureSignal()!")


    def createControlImage(self):
        self.controlImage = ImageTool.getMaxProjection(self.image)
        self.replaceSignalWithBackgroundCorrectedSignal()
        self.addCellContoursToControlImage()
        self.adjustControlImageDisplay()
        overlay = self.addKinetochoreRoiToControlImage()
        self.addMeasuredSignalRoiToControlImage(overlay)


    def replaceSignalWithBackgroundCorrectedSignal(self):
        """Show the per-cell background corrected signal in the control image.

        The control image starts as the max projection of the input image. This
        replaces the raw signal channel with `self.signal` (the signal after the
        per-cell background subtraction), so the intensities displayed and
        overlaid with the measured zones are exactly the values being measured.
        """
        if self.signal is None:
            return
        self.controlImage.setPosition(self.signalChannelNr, 1, 1)
        corrected = self.signal.getProcessor().duplicate()
        self.controlImage.setProcessor(corrected)
        self.controlImage.setPosition(1, 1, 1)


    def addMeasuredSignalRoiToControlImage(self, overlay):
        raise NotImplementedError("Subclasses must implement addMeasuredSignalRoiToControlImage()!")


    def addKinetochoreRoiToControlImage(self):
        IJ.run(self.kinetochoreMask, "Create Selection", "")
        roi = self.kinetochoreMask.getRoi()
        overlay = Overlay()
        if roi:
            roi.setStrokeColor(Color.RED)
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


    def addToTable(self, label=0, nrOfPixel=0, area=0, integratedDensity=0, rawIntegratedDensity=0, max=0, mean=0, median=0, min=0, mode=0, stdDev=0):
        labelKey = label
        if not isinstance(labelKey, int):
            try:
                labelKey = int(label)
            except (TypeError, ValueError):
                labelKey = -1
        self.table.addRow()
        self.table.addLabel(str(label))
        self.table.addValue("image", self.image.getTitle())
        self.table.addValue("Pixels", nrOfPixel)
        self.table.addValue("Area", area)
        self.table.addValue("IntDen", integratedDensity)
        self.table.addValue("RawIntDen", rawIntegratedDensity)
        self.table.addValue("Max", max)
        self.table.addValue("Mean", mean)
        self.table.addValue("StdDev", stdDev)
        self.table.addValue("Median", median)
        self.table.addValue("Min", min)
        self.table.addValue("Mode", mode)
        self.table.addValue("Cell", int(label))


    def finishTable(self):
        self.table.sort("Cell")
        self.table.deleteColumn("Cell")
        self.table.updateResults()
        frame = WindowManager.getFrame("Results")
        if frame:
            frame.close()



class OverlapKinetochoreAnalyzer(KinetochoreAnalyzer):
    """Measure the signal in cells that contain (un-dilated) kinetochores.

    Kinetochores and signal are segmented independently and restricted to the
    cells. For each cell with kinetochores, the background-corrected signal is
    measured over the complete segmented signal regions of that cell, i.e. not
    only over the part of the signal that overlaps the kinetochores. Cells
    with kinetochores but without any signal are reported with zeros. No
    dilation and no signal threshold are applied. This is the classic
    overlap-based approach.
    """

    def measureSignal(self):
        if not self.table:
            self.table = ResultsTable()
        kLabels = ImageCalculator.run(self.cellLabels, self.kinetochoreMask, "and create")
        sLabels = ImageCalculator.run(self.cellLabels, self.signalMask, "and create")
        measurements = IntensityMeasures(kLabels, sLabels)
        kMeasurements = IntensityMeasures(kLabels, kLabels)
        table = measurements.getMax()
        kTable = kMeasurements.getMax()
        if kTable.getCounter() < 1:
            self.addToTable()
            self.signalLabels = ImagePlus("co-occuring signal labels",
                                          sLabels.getProcessor().createProcessor(sLabels.getWidth(),
                                                                                 sLabels.getHeight()))
            return
        kLabelsList = [kTable.getLabel(row) for row in range(kTable.size())]
        sLabelsList = [table.getLabel(row) for row in range(table.size())]
        zeroValueLabels = list(set(kLabelsList) - set(sLabelsList))
        for label in zeroValueLabels:
            self.addToTable(label=label)
        self.signalLabels = sLabels
        self.signalLabels.setTitle("co-occuring signal labels")
        maxLabel = self.signalLabels.getStatistics(Measurements.MIN_MAX).max
        if maxLabel > 0:
            self.measureCoocuringSignal()
        self.finishTable()


    def measureCoocuringSignal(self):
        iMeasurements = IntensityMeasures(self.signal, self.signalLabels)
        nrOfVoxelsValues = iMeasurements.getNumberOfVoxels()
        sumOfVoxelsValues = iMeasurements.getSumOfVoxels()
        volumeValues = iMeasurements.getVolume()
        maxValues = iMeasurements.getMax()
        meanValues = iMeasurements.getMean()
        medianValues = iMeasurements.getMedian()
        minValues = iMeasurements.getMin()
        modeValues = iMeasurements.getMode()
        stdDevValues = iMeasurements.getStdDev()
        index = 0
        for nrOfVoxelsValue, sumOfVoxelsValue, volumeValue, maxValue, meanValue, medianValue, minValue, modeValue, stdValue in zip(
                       nrOfVoxelsValues.getColumn("NumberOfVoxels"),
                       sumOfVoxelsValues.getColumn("Voxels Sum"),
                       volumeValues.getColumn("Volume"),
                       maxValues.getColumn("Max"),
                       meanValues.getColumn("Mean"),
                       medianValues.getColumn("Median"),
                       minValues.getColumn("Min"),
                       modeValues.getColumn("Mode"),
                       stdDevValues.getColumn("StdDev")):
            self.addToTable(label=maxValues.getLabel(index),
                            nrOfPixel=nrOfVoxelsValue,
                            area=volumeValue,
                            integratedDensity=volumeValue*meanValue,
                            rawIntegratedDensity=sumOfVoxelsValue,
                            max=maxValue,
                            mean=meanValue,
                            stdDev=stdValue,
                            median=medianValue,
                            min=minValue,
                            mode=modeValue)
            index = index + 1


    def addMeasuredSignalRoiToControlImage(self, overlay):
        IJ.setThreshold(self.signalLabels, 1.0000, 1000000000000000000000000000000.0000)
        IJ.run(self.signalLabels, "Create Selection", "")
        roi = self.signalLabels.getRoi()
        self.signalLabels.getProcessor().resetThreshold()
        if roi:
            roi.setStrokeColor(Color.GREEN)
            overlay.add(roi, "signal")
        self.controlImage.setOverlay(overlay)
        self.controlImage.resetRoi()



class DilatedKinetochoreAnalyzer(KinetochoreAnalyzer):
    """Measure the background-corrected signal inside the dilated kinetochores.

    The kinetochore mask is dilated by `kinetochore dilation radius`, restricted
    to the cells, and only background-corrected signal pixels with a value
    >= `signal threshold` are measured. One entry per cell that has
    kinetochores; cells with kinetochores but no signal pixel above the
    threshold are reported with zeros. Reports NrOfVoxels/Area/IntDen/RawIntDen
    as well as Max/Mean/StdDev/Median/Min/Mode of the measured zone.
    """

    def __init__(self, cellSegmenter, spotSegmenter, image, options=None):
        super(DilatedKinetochoreAnalyzer, self).__init__(cellSegmenter, spotSegmenter, image, options=options)
        self.dilatedKtByCell = {}
        self.dilatedKtCells = None


    def setOptions(self, options):
        super(DilatedKinetochoreAnalyzer, self).setOptions(options)
        self.kinetochoreDilationRadius = options.value("kinetochore dilation radius")
        self.signalThreshold = options.value("signal threshold")


    def measureSignal(self):
        if not self.table:
            self.table = ResultsTable()
        kLabels = ImageCalculator.run(self.cellLabels, self.kinetochoreMask, "and create")
        kMeasurements = IntensityMeasures(kLabels, kLabels)
        kTable = kMeasurements.getMax()
        if kTable.getCounter() < 1:
            self.dilatedKtByCell = {0: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0)}
            self.addToTable()
            return
        ktCellLabels = set(int(kTable.getLabel(row)) for row in range(kTable.size()))
        dilatedKtMask = self.imageTool.dilate(self.kinetochoreMask, self.kinetochoreDilationRadius)
        self.dilatedKtCells = ImageCalculator.run(self.cellLabels, dilatedKtMask, "and create")
        thresholdMask = self.imageTool.getThresholdMask(self.signal, self.signalThreshold)
        self.dilatedKtCells = ImageCalculator.run(self.dilatedKtCells, thresholdMask, "and create")
        iMeasurements = IntensityMeasures(self.signal, self.dilatedKtCells)
        nrOfVoxelsValues = iMeasurements.getNumberOfVoxels()
        sumOfVoxelsValues = iMeasurements.getSumOfVoxels()
        volumeValues = iMeasurements.getVolume()
        meanValues = iMeasurements.getMean()
        maxValues = iMeasurements.getMax()
        minValues = iMeasurements.getMin()
        medianValues = iMeasurements.getMedian()
        modeValues = iMeasurements.getMode()
        stdDevValues = iMeasurements.getStdDev()
        self.dilatedKtByCell = {label: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0) for label in ktCellLabels}
        for index in range(meanValues.size()):
            label = int(meanValues.getLabel(index))
            if label not in ktCellLabels:
                continue
            nrOfVoxelsValue = nrOfVoxelsValues.getValue("NumberOfVoxels", index)
            sumOfVoxelsValue = sumOfVoxelsValues.getValue("Voxels Sum", index)
            volumeValue = volumeValues.getValue("Volume", index)
            meanValue = meanValues.getValue("Mean", index)
            maxValue = maxValues.getValue("Max", index)
            minValue = minValues.getValue("Min", index)
            medianValue = medianValues.getValue("Median", index)
            modeValue = modeValues.getValue("Mode", index)
            stdDevValue = stdDevValues.getValue("StdDev", index)
            self.dilatedKtByCell[label] = (nrOfVoxelsValue, volumeValue,
                                           volumeValue * meanValue, sumOfVoxelsValue,
                                           maxValue, meanValue, stdDevValue,
                                           medianValue, minValue, modeValue)
        for cellLabel in self.dilatedKtByCell:
            self.addDilatedRow(cellLabel)
        self.finishTable()


    def addDilatedRow(self, label):
        nrOfPixel, area, integratedDensity, rawIntegratedDensity, maxValue, meanValue, stdDevValue, medianValue, minValue, modeValue = self.dilatedKtByCell[label]
        self.addToTable(label=label,
                        nrOfPixel=nrOfPixel,
                        area=area,
                        integratedDensity=integratedDensity,
                        rawIntegratedDensity=rawIntegratedDensity,
                        max=maxValue,
                        mean=meanValue,
                        median=medianValue,
                        min=minValue,
                        mode=modeValue,
                        stdDev=stdDevValue)


    def addMeasuredSignalRoiToControlImage(self, overlay):
        if self.dilatedKtCells is not None:
            IJ.setThreshold(self.dilatedKtCells, 1.0000, 1000000000000000000000000000000.0000)
            IJ.run(self.dilatedKtCells, "Create Selection", "")
            roi = self.dilatedKtCells.getRoi()
            self.dilatedKtCells.getProcessor().resetThreshold()
            if roi:
                roi.setStrokeColor(Color.MAGENTA)
                overlay.add(roi, "measured zones")
        self.controlImage.setOverlay(overlay)
        self.controlImage.resetRoi()



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


    def dilate(self, mask, radius=1):
        """Return a copy of the binary mask dilated by a disk of the given radius (px)."""
        proc = Morphology.dilation(mask.getProcessor(), DiskStrel.fromRadius(radius))
        result = ImagePlus(mask.getTitle() + "-dilated", proc)
        return result


    def getThresholdMask(self, anImage, threshold=0):
        """Return a binary mask (0/255) marking all pixels with a value >= threshold."""
        duplicate = self.copyImage(anImage)
        duplicate.getProcessor().setThreshold(threshold, 1e30)
        mask = ImagePlus(anImage.getTitle() + "-threshold-mask", duplicate.createThresholdMask())
        return mask
