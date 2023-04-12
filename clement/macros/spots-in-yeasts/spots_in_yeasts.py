import os
from datetime import datetime
from tempfile import gettempdir
import urllib2
import re
import hashlib

from ij import IJ, ImagePlus
from ij.plugin.Commands import closeAll
from ij.WindowManager import getImageCount
from ij.plugin import ChannelSplitter, ContrastEnhancer, ImageCalculator
from ij.plugin.filter import RankFilters, MaximumFinder
from inra.ijpb.label import LabelImages
from inra.ijpb.morphology import Strel, Reconstruction
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator

import unittest

_MACRO_FOLDER_NAME_ = "spots-in-yeasts"
_CORRECT_NAME_REGEX_ = re.compile("^[a-zA-Z]+([a-zA-Z0-9_-]+)?$")


class Segmentor(object):

    """
    Base class splitting the basic phases of a segmentation into different methods.
    """

    def __init__(self, image=None, nm="Segmentor"):
        """
        Constructor

        @type  image: ImagePlus
        @param image: This image is the one that's going to be segmented. It will be cloned along the process, so you will still hold an unmodified reference by the end of the execution.
        @type  nm: str
        @param nm: The name of the segmentor. This is optional and only useful for display purposes.

        @rtype: void
        """
        self.status = []
        self.name = "Segmentor"
        self.setName(nm)
        self.setInput(image)

    def __del__(self):
        """
        Destructor
        """
        self.cleanup()

    def getName(self):
        """
        @rtype: void
        @return: The name given to this segmentor.
        """
        return self.name

    def setName(self, nn):
        """
        Setter for the segmentor's name.
        A validity check is performed before modifying the name to determine if it is acceptable.
        The new name must match the _CORRECT_NAME_REGEX_ regex.

        @type  nn: str
        @param nn: The new name that this segmentor will hold.

        @rtype: void
        """
        if _CORRECT_NAME_REGEX_.match(nn):
            old = self.name
            self.name = nn
            self.setStatus("Name of '{0}' set to: '{1}'.".format(old, nn))

    def setInput(self, image):
        """
        Resets the segmentor and sets its base image to the provided one.

        @rtype: void
        """
        self.cleanup()
        self.setStatus("Input set to: {0}".format(image.getTitle() if (type(image) is ImagePlus) else "None"))
        self.original        = image.duplicate() if (type(image) is ImagePlus) else None

    def getInput(self):
        """
        Accessor to a copy of the input used by the segmentor. The image owned by this instance will stay untouched.

        @rtype: ImagePlus
        @return: A copy of the original, or None is no image was provided.
        """
        return self.original.duplicate() if (type(self.original) is ImagePlus) else None

    def acquireInput(self):
        """
        @rtype: ImagePlus
        @return: A reference to the actual image owned by the instance.
        """
        return self.original

    def cleanup(self):
        """
        Destroys all the images stored into this instance.
        Also sets all the attributes to None to avoid errors by trying to call methods from dead references.

        @rtype: void
        """
        self.setStatus("Cleaning owned images.")
        if self.original is not None:
            self.original.close()
            self.original = None
        if self.preprocessed is not None:
            self.preprocessed.close()
            self.preprocessed = None
        if self.rawSegmentation is not None:
            self.rawSegmentation.close()
            self.rawSegmentation = None
        if self.postprocessed is not None:
            self.postprocessed.close()
            self.postprocessed = None
        self.status = []
        self.setInput(None)

    def clearStatus(self):
        """
        Clears the list that contains the logs.

        @rtype: void
        """
        self.status = []

    def getStatus(self):
        """
        @rtype: str
        @return: A string that is a concatenated version of the list representing the logs. All lines are separated with line breaks.
        """
        return "\n".join(self.status)

    def setStatus(self, s):
        """
        Adds a new line to the status list.

        @type  s: str
        @param s: A string that doesn't end with a line break.
        """
        self.status.append("  | ({0}): {1}".format(self.name, s))

    def _preprocess(self):
        """
        This function's purpose is to be overriden by an actual preprocessing phase in a segmentation process.
        It starts by duplicating the image produced at the previous step, which in this case, is the original.
        The specialized versions should always call the parent anyway, to trigger the copy of the previous step.

        @rtype: bool
        @return: A boolean representing whether this step ended correctly or not.
        """
        if self.original is None:
            return False
        else:
            self.preprocessed = self.original.duplicate()
            self.preprocessed.setTitle("Preprocessed")
        return True
    
    def _segment(self):
        """
        This function's purpose is to be overriden by an actual segmentation phase in a segmentation workflow.
        It starts by duplicating the image produced at the previous step, which in this case, is the preprocessed image.
        The specialized versions should always call the parent anyway, to trigger the copy of the previous step.
        
        @rtype: bool
        @return: A boolean representing whether this step ended correctly or not.
        """
        self.rawSegmentation = self.preprocessed.duplicate()
        self.rawSegmentation.setTitle("Segmented")
        return True

    def _postprocess(self):
        """
        This function's purpose is to be overriden by an actual postprocessing phase in a segmentation process.
        It starts by duplicating the image produced at the previous step, which in this case, is the raw segmented image.
        The specialized versions should always call the parent anyway, to trigger the copy of the previous step.
        
        @rtype: bool
        @return: A boolean representing whether this step ended correctly or not.
        """
        self.postprocessed = self.rawSegmentation.duplicate()
        self.postprocessed.setTitle("Postprocessed")
        return True

    def run(self):
        """
        Runs all the phases of the segmentation workflow as a sequence, by checking after each one if its execution ended succesfully.

        @rtype: bool
        @return: A boolean representing whether the workflow ended correctly or not.
        """
        if not self._preprocess():
            return False
        self.setStatus("Preprocessing phase done.")
        if not self._segment():
            return False
        self.setStatus("Segmentation phase done.")
        if not self._postprocess():
            return False
        self.setStatus("Postprocessing phase done.")
        return True

    def getResult(self):
        return self.postprocessed.duplicate() if (type(self.postprocessed) is ImagePlus) else None


class LabKitSegmentor(Segmentor):

    """
    Specialization of Segmentor that uses LabKit to produced the raw segmentation from the preprocessed image.
    """

    def __init__(self, nm="LabKitSegmentor", path="", g=False):
        """
        Constructor.

        @type  nm: str
        @param nm: The name attributed to this instance of segmentor.
        @type  path: str
        @param path: Absolute path to a LabKit classifier.
        @type  g: bool
        @param g: A boolean activating the usage of GPU for segmentation.
        """
        super(LabKitSegmentor, self).__init__(nm=nm)
        self.classifierPath = None
        if not self.setClassifier(path):
            raise Exception("Failed to set classifier path.")
        self.gpu = g

    def isUsingGPU(self):
        """
        @rtype: bool
        @return: Boolean representing the usage of GPU for segmentation.
        """
        return self.gpu

    def getClassifier(self):
        """
        @rtype: str
        @return: The absolute path to the classifier used to segment images.
        """
        return self.classifierPath

    def setClassifier(self, path):
        """
        Method modifying the path to the classifier used to segment images.
        A validity check is performed over the provided path to ensure that it points to a valid file.

        @type  path: str
        @param path: The absolute path of a LabKit classifier (has the ".classifier" extension)

        @rtype: bool
        @return: True if the path was succesfully updated, False otherwise.
        """
        if path is None:
            self.setStatus("Failed to set classifier to: None object is not a valid path...")
            return False
        
        if os.path.isfile(path) and path.endswith(".classifier"):
            self.classifierPath = path
            self.setStatus("Classifier path set to: `{0}`.".format(path))
            return True
        
        self.setStatus("Failed to set classifier to: `{0}`, this path is not valid.".format(path))
        return False
    
    def _segment(self):
        """
        Launches LabKit on the preprocessed image and stores the result.

        @rtype: bool
        @return: True if the segmentation was performed, False if LabKit could't be launched or the segmentation failed.
        """
        super(LabKitSegmentor, self)._segment()
        self.rawSegmentation.show()
        try:
            IJ.run(self.rawSegmentation, "Segment Image With Labkit", "segmenter_file={0} use_gpu={1}".format(
                self.classifierPath,
                "true" if self.gpu else "false"
            ))
        except:
            self.setStatus("Failed to launch LabKit")
            return False

        result = IJ.getImage()
        self.rawSegmentation.close()
        self.rawSegmentation = result.duplicate()
        self.rawSegmentation.setTitle("Segmented")
        result.close()
        self.setStatus("Raw segmentation successfuly created by LabKit.")

        return True


class YeastsSegmentor(LabKitSegmentor):
    """
    Specialized version of the LabKit segmentor that will be used to segment yeast cells.
    """

    def __init__(self, nm="YeastsSegmentor", path="", g=False):
        """
        Constructor.

        @type  nm: str
        @param nm: The name that this instance is supposed to have.
        @type  path: str
        @param path: The path of a LabKit classifier able to segment yeasts.
        @type  g: bool
        @param g: Should we use the GPU with LabKit?
        """
        super(YeastsSegmentor, self).__init__(nm=nm, path=path, g=g)

    def _preprocess(self):
        super(LabKitSegmentor, self)._preprocess()
        self.setStatus("Starting preprocessing...")

        # Normalizing image
        ce = ContrastEnhancer()
        ce.setNormalize(True)
        ce.stretchHistogram(self.preprocessed, 0.35)
        self.setStatus("Normalizing image")

        # Denoising
        rk = RankFilters()
        rk.rank(self.preprocessed.getProcessor(), 2, RankFilters.MEDIAN)
        self.setStatus("Denoising image")

        # Setting values between 0 and 1
        fltPrc = self.preprocessed.getProcessor().convertToFloatProcessor()
        fltPrc.multiply(1.0/65535.0)
        self.preprocessed.close()
        self.preprocessed = ImagePlus("Preprocessed", fltPrc)
        self.setStatus("Scaling between 0 and 1.")

        self.setStatus("Preprocessing done.")
        return True

    def _postprocess(self):
        super(LabKitSegmentor, self)._postprocess()
        
        # Deleting useless labels, only keeping FG.
        LabelImages.replaceLabels(self.postprocessed, [2], 0)
        # Thresholding
        self.postprocessed.getProcessor().threshold(0)
        # Erosion (removes crumbs of FG from LabKit segmentation)
        strel   = Strel.Shape.DISK.fromRadius(2)
        imErode = strel.erosion(self.postprocessed.getProcessor())
        self.postprocessed.close()
        # Fill holes
        filled = Reconstruction.fillHoles(imErode)
        # Connected components labeling
        compLab = FloodFillComponentsLabeling(4, 16)
        labeled = compLab.computeLabels(filled)
        # Removing small labels
        lsf   = LabelSizeFiltering(RelationalOperator.GT, 500)
        sized = lsf.process(labeled)
        # Dilating labels (yeasts are only partially caught by LabKit)
        dilated = LabelImages.dilateLabels(sized, 10)
        LabelImages.remapLabels(dilated)
        LabelImages.removeBorderLabels(dilated)

        self.postprocessed = ImagePlus("Postprocessed", dilated)

        return True


class YFPSpotsSegmentor(Segmentor):
    """
    This segmentor is specialized to be able to segment YFP spots present in the fluo channel of yeast cells.
    """
    def __init__(self, nm="YFPSpotsSegmentor", prm=0.3, lp=7):
        """
        Constructor.

        @type nm: str
        @param nm: The name of this instance of segmentor.
        @type prm: float
        @param prm: The tolerance used to detect the top of spots.
        @type lp: int
        @param lp: The sigma of the LoG filter used 
        """
        super(Segmentor, self).__init__(nm)
        self.prominence = prm
        self.lFilter = lp
        self.points  = None

    def _preprocess(self):
        super(Segmentor, self)._preprocess()

        # Applying Laplacian to highlight spots
        IJ.run(self.preprocessed, "FeatureJ Laplacian", "compute smoothing={0}".format(
            self.lFilter
        ))
        res = IJ.getImage()
        self.preprocessed.close()
        self.preprocessed = res.duplicate()
        res.close()

        return True

    def _segment(self):
        super(Segmentor, self)._segment()

        # Finding maxima, corresponding to center of spots.
        mf  = MaximumFinder()
        self.points = mf.getMaxima(self.rawSegmentation.getProcessor(), self.prominence, True)

    def getSpots(self):
        return self.points
        

class SpotsInYeasts(object):
    """
    Class used to segment and aggregate statistics over yeast cells.
    It is able to manage batching and handles the process in its globality.
    """
    def __init__(self, target=None, lg=os.devnull):
        """
        Constructor.
        If a directory is passed as parameter, the batch mode will automatically be activated.

        @type  target: str
        @param target: The path either to a tiff or a folder containing tiffs.
        @type  lg: str
        @param lg: Path to the file in which the logs are going to be written.
        """
        self.queue    = []
        self.current  = {
            'original'    : None,
            'transmission': None,
            'fluo'        : None,
            'yeastsLabels': None,
            'yfpSpots'    : None
        }
        self.yfpSpots = None
        self.logFile  = lg
        self.clPath   = os.sep.join([
            IJ.getDirectory("plugins"),
            "spots-in-yeasts",
            "classifiers",
            "current.classifier"
        ])
        self.yeastSegmentor = YeastsSegmentor(path=self.clPath)
        self.spotsSegmentor = YFPSpotsSegmentor()
        self.setQueue(target)

    def setQueue(self, target):
        """
        Defines the content of the processing queue.
        If the path to a unique file was provided, the queue will only contain it. Otherwise, it will contain all the tiff found in the folder.

        @type  target: str
        @param target: Path to a tiff or a folder containing tiffs.

        @rtype: bool
        @return: True if a processing queue was built, False if the path doesn't exist or doesn't contain anything.
        """
        # Empty queue, nothing to process
        if target is None:
            self.queue = []
            self.log("Queue is empty, nothing to process.")
            return True

        # If a path is directly provided
        if type(target) is str:
            # A unique file has to be processed.
            if os.path.isfile(target):
                self.queue = [target]
                return True

            # All the files present in the directory will be processed.
            if os.path.isdir(target):
                content = os.listdir(target)
                self.queue = [c for c in content if os.path.isfile(c)]
                return True

            self.log("The provided path: `{0}` doesn't correspond to anything.")
            return False

        # If it is a list, we expect it to contain file paths.
        if type(target) is list:
            self.queue = [c for c in content if os.path.isfile(c)]
            return True

        # Unhandled type encountered.
        self.log("The provided type provided for the target is not handled ({0})".format(str(type(target))))
        return False
    
    def splitImage(self):
        """
        Separates the channels of original image.

        @rtype: void
        """
        self.current['transmission'], self.current['fluo'] = ChannelSplitter.split(self.current['original'])
        self.closeImage('original')
    
    def resetLogFile(self):
        """
        Clears the content of the logs file before a new execution.

        @rtype: void
        """
        now = datetime.now()
        with open(self.logFile, 'w') as f:
            f.write("==== {0} ====\n".format(str(now)))

    def log(self, message="\n", eol="\n", terminal=True, file=False):
        """
        Inserts a new line in the logs of the execution.

        @type  message: str
        @param message: The text inserted in the logs.
        @type  eol: char
        @param eol: The character inserted at the end of every message.
        @type  terminal: bool
        @param terminal: Will the message be displayed in the terminal?
        @type  file: bool
        @param file: Will the message be displayed in the logs file?

        @rtype: void
        """
        if file:
            with open(self.logFile, 'a') as f:
                f.write(message+eol)
        if terminal:
            print(message)

    def nextImage(self):
        """
        Clears the current state and picks a new item to process in the queue.
        The current state is initialized containing a new unprocessed image.
        The content of the queue is managed by this function.

        @rtype: bool
        @return: True if there is an image to process, False if all images have been processed.
        """
        if (self.queue is None) or (len(self.queue) == 0):
            return False
        
        img = None
        while (len(self.queue) > 0) and (img is None):
            try:
                img = IJ.openImage(self.queue.pop(0))
            except:
                img = None
        
        if img is not None:
            self.current['original'] = img
            return True

        return False
    
    def closeImage(self, key):
        """
        In this class, all references to images are stored in a dictionary.
        Instead of closing an image at any location in the code, the data is freed by a method by specifying a key.
        """
        img = self.current.get(key)
        if img is not None:
            self.log("Closed: {0}".format(key))
            img.close()
            self.current[key] = None
        else:
            self.log("Key: '{0}' not found or already closed.".format(key))

    def segmentYeastCells(self):
        """
        Uses an instance of segmentor to segment yeast cells.
        """
        self.yeastSegmentor.setInput(self.current['transmission'])
        success = self.yeastSegmentor.run()
        self.closeImage('transmission')

        if not success:
            self.log("Failed to create mask from transmission channel.")
            self.log("Segmentor: ============== \n{0}\n==============\n".format(self.yeastSegmentor.getStatus()))
            return False
        
        self.current['yeastsLabels'] = self.yeastSegmentor.getResult()
        self.yeastSegmentor.cleanup()

        return True

    def findYFPSpots(self):
        """
        Uses an instance of segmentor to find YFP spots in the fluo.
        """
        self.spotsSegmentor.setInput(self.current['fluo'])
        success = self.spotsSegmentor.run()
        self.closeImage('fluo')

        if not success:
            self.log("Failed to find spots from fluo channel.")
            self.log("Segmentor: ============== \n{0}\n==============\n".format(self.spotsSegmentor.getStatus()))
            return False
        
        self.current['yfpSpots'] = self.spotsSegmentor.getResult()
        self.yfpSpots            = self.spotsSegmentor.getSpots()
        self.spotsSegmentor.cleanup()

        return True

    def cleanUp(self):
        """
        Releases all the ressources owned by this instance.
        """
        for key, item in self.current.items():
            if item is not None:
                item.close()
                self.log("Closed: {0}".format(key))
        self.yfpSpots = None
    
    def run(self):
        self.resetLogFile()
        valid = True

        while self.nextImage():
            valid = True

            if valid:
                valid = self.splitImage()
            if valid:
                valid = self.segmentYeastCells()
            if valid:
                valid = self.findYFPSpots()

            self.cleanUp()
        
        return True


###############################################################################################
#          UNIT TESTING                                                                       #
###############################################################################################


class SpotsInYeastsTesting(object):
    """
    Unit tests for the yeasts segmenter. Includes the whole procedure, even the downloading of required ressources.
    """
    ressources = {}
    suite      = None

    class TestSegmentor(unittest.TestCase):

        def setUp(self):
            self.seg1 = Segmentor()
            self.trm1 = SpotsInYeastsTesting.getImage('siy-transmission-1.tif')

        def tearDown(self):
            self.seg1 = None
            self.trm1.close()

        def test_naming(self):
            self.assertEqual(self.seg1.getName(), "Segmentor")

            self.seg1.setName("some-valid1_name")
            self.assertEqual(self.seg1.getName(), "some-valid1_name")

            self.seg1.setName("9invalid")
            self.assertEqual(self.seg1.getName(), "some-valid1_name")

            self.seg1.setName("some invalid1_name")
            self.assertEqual(self.seg1.getName(), "some-valid1_name")

            self.seg1.setName("some-valid1_name")
            self.assertEqual(self.seg1.getName(), "some-valid1_name")

            self.seg1.setName("Other_valid_123")
            self.assertEqual(self.seg1.getName(), "Other_valid_123")
        
        def test_working_image(self):
            self.assertIs(self.seg1.getInput(), None)

            self.seg1.setInput(None)
            self.assertIs(self.seg1.getInput(), None)

            self.seg1.setInput("some string")
            self.assertIs(self.seg1.getInput(), None)

            self.seg1.setInput(self.trm1)

            ipt = self.seg1.getInput()
            self.assertIs(type(ipt), ImagePlus)

            res = ImageCalculator.run(self.trm1, ipt, "difference")
            self.assertEqual(res.getProcessor().getHistogramMax(), 0)
            res.close()

            self.assertNotEqual(self.trm1.getID(), ipt.getID())

        def test_run_assign(self):
            self.assertIs(self.seg1.getInput(), None)
            self.assertIs(self.seg1.getResult(), None)
            self.assertFalse(self.seg1.run())
            self.seg1.setInput(self.trm1)
            self.assertTrue(self.seg1.run())
            inp1 = self.seg1.getInput()
            out1 = self.seg1.getResult()
            self.assertIsInstance(inp1, ImagePlus)
            self.assertIsInstance(out1, ImagePlus)

        def test_clean_up(self):
            self.assertIs(self.seg1.original, None)
            self.assertIs(self.seg1.preprocessed, None)
            self.assertIs(self.seg1.rawSegmentation, None)
            self.assertIs(self.seg1.postprocessed, None)

            closeAll()
            self.assertEqual(getImageCount(), 0)
            self.seg1.cleanup()

            self.seg1.setInput(self.trm1)
            self.seg1.run()
            self.seg1.cleanup()

            self.assertIs(self.seg1.original, None)
            self.assertIs(self.seg1.preprocessed, None)
            self.assertIs(self.seg1.rawSegmentation, None)
            self.assertIs(self.seg1.postprocessed, None)
            self.assertEqual(getImageCount(), 0)


    class TestLabKitSegmentor(unittest.TestCase):

        def setUp(self):
            self.prp1 = SpotsInYeastsTesting.getImage('siy-preprocessed-1.tif')
            self.raw1 = SpotsInYeastsTesting.getImage('siy-rawlabkit-1.tif')
            self.clr1 = SpotsInYeastsTesting.getRessource('siy-try-3.classifier')

        def tearDown(self):
            self.prp1.close()
            self.raw1.close()
        
        def test_labkit_construction(self):
            # A classifier must be provided to the constructor
            with self.assertRaises(Exception) as context:
                l = LabKitSegmentor()
            self.assertEqual('Failed to set classifier path.', str(context.exception))

            # The file is supposed to be a valid classifier.
            with self.assertRaises(Exception) as context:
                l = LabKitSegmentor(path="/some/stupid/path")
            self.assertEqual('Failed to set classifier path.', str(context.exception))

            # The path should be correctly stored.
            l = LabKitSegmentor(path=self.clr1)
            self.assertEqual(l.getClassifier(), self.clr1)
            self.assertEqual(l.getName(), "LabKitSegmentor")
            self.assertFalse(l.isUsingGPU())

        def test_correct_segmentation(self):
            l = LabKitSegmentor(path=self.clr1)
            
            l.setInput(self.prp1)
            self.assertTrue(l.run())

            ipt = l.getInput()
            res = ImageCalculator.run(self.prp1, ipt, "difference")
            self.assertEqual(res.getProcessor().getHistogramMax(), 0)
            res.close()

            seg = l.getResult()
            res = ImageCalculator.run(self.raw1, seg, "difference")
            self.assertEqual(res.getProcessor().getHistogramMax(), 0)
            res.close()

            l.cleanup()

    class TestYeastsSegmentor(unittest.TestCase):

        def setUp(self):
            self.trm1 = SpotsInYeastsTesting.getImage('siy-transmission-1.tif')
            self.prp2 = SpotsInYeastsTesting.getImage('siy-preprocessed-2.tif')
            self.raw2 = SpotsInYeastsTesting.getImage('siy-rawlabkit-2.tif')
            self.clr1 = SpotsInYeastsTesting.getRessource('siy-try-3.classifier')
            self.ppc2 = SpotsInYeastsTesting.getImage('siy-postprocessed-2.tif')

        def tearDown(self):
            self.trm1.close()
            self.prp2.close()
            self.raw2.close()
            self.ppc2.close()
        
        def test_yeasts_construction(self):
            l = YeastsSegmentor(path=self.clr1)
            self.assertEqual(l.getClassifier(), self.clr1)
            self.assertEqual(l.getName(), "YeastsSegmentor")
            self.assertFalse(l.isUsingGPU())

        def test_valid_preprocess(self):
            l = YeastsSegmentor(path=self.clr1)
            
            l.setInput(self.trm1)
            success = l._preprocess()
            prp = l.preprocessed

            self.assertIsNotNone(prp)
            self.assertIsInstance(prp, ImagePlus)
            self.assertEqual(prp.getBitDepth(), 32)
            self.assertLessEqual(prp.getProcessor().getHistogramMax(), 1.0)

            self.assertTrue(success)

            res = ImageCalculator.run(self.prp2, prp, "difference")
            self.assertEqual(res.getProcessor().getHistogramMax(), 0)
            res.close()

        def test_valid_segmentation(self):
            l = YeastsSegmentor(path=self.clr1)
            
            l.setInput(self.trm1)
            successPre = l._preprocess()
            successSeg = l._segment()
            seg = l.rawSegmentation

            self.assertIsNotNone(seg)
            self.assertIsInstance(seg, ImagePlus)
            self.assertEqual(seg.getBitDepth(), 8)
            self.assertEqual(set(LabelImages.findAllLabels(seg.getProcessor())), set([1, 2]))

            self.assertTrue(successSeg)

            res = ImageCalculator.run(self.raw2, seg, "difference")
            self.assertEqual(res.getProcessor().getHistogramMax(), 0)
            res.close()

        def test_valid_results(self):
            l = YeastsSegmentor(path=self.clr1)
            
            l.setInput(self.trm1)
            successRun = l.run()
            seg = l.getResult()

            self.assertIsNotNone(seg)
            self.assertIsInstance(seg, ImagePlus)
            self.assertEqual(seg.getBitDepth(), 16)
            self.assertLessEqual(len(set(LabelImages.findAllLabels(seg.getProcessor()))), 130)
            
            res = ImageCalculator.run(self.ppc2, seg, "difference")
            self.assertEqual(res.getProcessor().getHistogramMax(), 0)
            res.close()

            self.assertTrue(successRun)

    # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    @classmethod
    def getImage(cls, key):
        path = cls.getRessource(key)
        if path is not None:
            return IJ.openImage(path)
        return None

    @classmethod
    def getRessource(cls, key):
        if key not in cls.ressources:
            print("Ressource {0} does not exist.".format(key))
            return None

        tmpDir = os.path.join(gettempdir(), "spotsInYeasts")
        path   = os.path.join(tmpDir, key)

        if not os.path.isfile(path):

            if not os.path.isdir(tmpDir):
                os.mkdir(tmpDir)

            with open(path, 'wb') as fi:
                fi.write(urllib2.urlopen(cls.ressources[key]['url']).read())
                fi.close()

            with open(path, 'r') as fi:
                hexahash = hashlib.md5(fi.read()).hexdigest()
                if hexahash != cls.ressources[key]['md5']:
                    print("Failed to acquire ressource, hash does not match ({0} vs {1}).".format(hexahash, cls.ressources[key]['md5']))
                    return None
            
        return path

    @classmethod
    def reset(cls):
        cls.ressources = {
            'siy-transmission-1.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2925/siy-transmission-1.tif",
                'md5': "f16d7bc3a46618b3ed9d3d45437eac4d"
            },
            'siy-fluo-1.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2924/siy-fluo-1.tif",
                'md5': "721822e23ae79201a20ab2e35e9142e4"
            },
            'siy-preprocessed-1.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2929/siy-preprocessed-1.tif",
                'md5': "9bff415df0bb34d8389161f7b4d2433c"
            },
            'siy-try-3.classifier': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2928/siy-try-3.classifier",
                'md5': "f63fef8eaba571b76e9079d6075d97ef"
            },
            'siy-rawlabkit-1.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2927/siy-rawlabkit-1.tif",
                'md5': "c1a7ee4e76c16b5d361d43de371c9c2f"
            },
            'siy-rawlabkit-2.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2932/siy-rawlabkit-2.tif",
                'md5': "e23728a228358aecb3614704d1e6fb2e"
            },
            'siy-preprocessed-2.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2931/siy-preprocessed-2.tif",
                'md5': "a1514fb98e3420471e07a648516fe060"
            },
            'siy-postprocessed-2.tif': {
                'url': "https://dev.mri.cnrs.fr/attachments/download/2930/siy-postprocessed-2.tif",
                'md5': "81b70f6cca18305a826b4103ed756eba"
            }
        }
        cls.suite = unittest.TestSuite()

        cls.suite.addTest(cls.TestSegmentor("test_naming"))
        cls.suite.addTest(cls.TestSegmentor("test_working_image"))
        cls.suite.addTest(cls.TestSegmentor("test_run_assign"))
        cls.suite.addTest(cls.TestSegmentor("test_clean_up"))

        cls.suite.addTest(cls.TestLabKitSegmentor("test_labkit_construction"))
        cls.suite.addTest(cls.TestLabKitSegmentor("test_correct_segmentation"))

        cls.suite.addTest(cls.TestYeastsSegmentor("test_yeasts_construction"))
        cls.suite.addTest(cls.TestYeastsSegmentor("test_valid_results"))
        cls.suite.addTest(cls.TestYeastsSegmentor("test_valid_preprocess"))
        cls.suite.addTest(cls.TestYeastsSegmentor("test_valid_segmentation"))

    @classmethod
    def run(cls):
        import sys
        runner = unittest.TextTestRunner(sys.stdout, verbosity=2)
        runner.run(cls.suite)
        print("DONE.")



if __name__ == '__main__':
    SpotsInYeastsTesting.reset()
    SpotsInYeastsTesting.run()
