from ij import IJ
from ij.plugin import Duplicator
from ij.plugin.filter import RankFilters
from ij.plugin import ZProjector
from inra.ijpb.label import LabelImages


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


    def run(self):
        self.segmentCells()
        self.segmentKinetochores()
        self.segmentSignal()
        
        
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
        # if self.useGPU:
        #    useGPUString = "true"
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