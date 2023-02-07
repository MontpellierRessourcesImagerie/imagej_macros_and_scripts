import os
from java.awt import Color
from ij import IJ, ImagePlus, ImageStack, CompositeImage
from ij.process import ImageProcessor, ByteProcessor
from ij.plugin import ContrastEnhancer, ChannelSplitter, Concatenator
from ij.plugin.frame import RoiManager
from ij.measure import ResultsTable
from util import FindConnectedRegions
from inra.ijpb.label import LabelImages
from inra.ijpb.plugins import MorphologicalFilterPlugin
from inra.ijpb.morphology.Morphology import Operation
from inra.ijpb.morphology import Strel
from ij.gui  import Roi

from mdYeasts.makeNGon import motherDaughterSegmentation
from mdYeasts.userIO import readSettings
from random import randint



def makeLaplacian(img, smth=0.25):

    """
    Function applying a LoG filter to an image, with a certain radius (in um).
    Note: The FeatureJ Laplacian is not available as a function or a class, and necessarily opens a GUI window after its execution.

    @type  img: ImagePlus
    @param img: The image on which the LoG will be applied.
    @type  smth: float
    @param smth: Smoothing scale (in um) of the gaussian filter used by the LoG filter.

    @rtype: ImagePlus
    @return: The C{img} image on which we applied a LoG filter.
    """

    IJ.run(img, "FeatureJ Laplacian", "compute smoothing={0}".format(smth))

    tres = IJ.getImage()
    res = tres.duplicate()
    tres.close()
    img.close()

    return res



def closing(img, rad):
    """
    Shorter way to write a morphological closing with a disk kernel.
    The operation is realized in place, no new image is being created.

    @type  img: ImagePlus
    @param img: Binary mask on which the morphological closing will be applied.
    @type  rad: int
    @param rad: Radius (in pixels) of the disk used as kernel.

    @rtype: void
    """
    return MorphologicalFilterPlugin().process(img, Operation.CLOSING, Strel.Shape.DISK.fromRadius(rad))




def connectedComposAndLargest(imIn):

    """
    This function takes a mask and isolates its biggest component. The input image is closed along this function.

    @type  imIn: ImagePlus
    @param imIn: An 8-bit mask.

    @rtype: ImagePlus
    @return: Another mask containing only the biggest island of `imIn`.
    """

    r = FindConnectedRegions().run(
        imIn,  # Image
        False, # Diagonal (4 or 8 connectivity)
        False, # Image Per Region
        True,  # Image All Regions
        False, # Show Results
        True,  # Must Have Same Value
        False, # Start From Point ROI
        False, # Auto Subtrack
        1,     # Values Over Double
        1,     # Minimum Points In Region
        -1,    # Stop After Number Of Regions
        True   # No UI
    )

    iStack = r.allRegions.imageStack
    conCompos = ImagePlus("Test", iStack)
    imIn.close()
    imOut = LabelImages.keepLargestLabel(conCompos)
    conCompos.close()

    return imOut




def preprocess(d, contrast=True, lapla=True, thresh=True, invt=True, biggest=True, clsg=True):

    """
    Function transforming an image in transmission of a yeast into a mask usable for segmentation.

    Through these steps, we can obtain a binary image representing correctly the halo around our yeasts.
    The mask is not necessarily perfect (it can contain bumps or holes), but works the majority of time.
    It is not excluded that, sometimes, the produced mask is only good to be dumped into the trash.

    @type  d: ImagePlus
    @param d: The original image (one channel) to be transformed into a mask.
    @type  contrast: bool 
    @param contrast: Should the image be equalized and normalized.
    @type  lapla: bool
    @param lapla: Should a LoG filter be applied to the image.
    @type  thresh: bool 
    @param thresh: Should the image be thresholded.
    @type  invt: bool
    @param invt: Should the LUT of the produced mask be inverted.
    @type  biggest: bool
    @param biggest: Should we only keep the biggest island in the mask, or the entire mask.
    @type  clsg: bool
    @param clsg: Should a morphological closing be applied to the mask.

    @rtype: ImagePlus
    @return: An 8-bit image being a mask matching the light halo located around the cells.
    """

    workingCopy = d.duplicate()

    if contrast:
        # 1. Enhance contrast (equalize + normalize)
        ce = ContrastEnhancer()
        ce.setNormalize(True)
        ce.equalize(workingCopy)
        ce.stretchHistogram(workingCopy, 0.35)

    if lapla:
        # 2. Laplacian (@ 0.25)
        workingCopy = makeLaplacian(workingCopy)

    if thresh:
        # 3. Threshold (w/ Otsu)
        workingCopy.getProcessor().setAutoThreshold("Otsu", True, ImageProcessor.ISODATA)
        workingCopy.setProcessor(workingCopy.getProcessor().createMask())

    if invt:
        # 4. Invert
        proc = workingCopy.getProcessor()
        if proc.get(0, 0) == 255: # If there is no light halo, we don't need to invert the image.
            workingCopy.getProcessor().invert()

    if biggest:
        # 5. Label connected components & keep the largest
        workingCopy = connectedComposAndLargest(workingCopy)

    if biggest:
        # 6. Closing
        closing(workingCopy, 3)

    # 7. Return
    return workingCopy




def makeResultsTable(stats):

    """
    Function building the table of results representing the statistics over pairs of yeast cells.
    The actual Result table cannot be used due to the method FindConnectedRegions::run() used above that clears the Results table at each execution.
    
    @type  stats: list(dict((str, float)))
    @param stats: A list of dictionary. Each dictionary represents the statistics over a unique pair of yeasts.

    @rtype: void
    """

    r = ResultsTable.getResultsTable("MD-Yeasts") or ResultsTable()

    for cell in stats:
        r.addRow()
        keys = sorted(cell.keys())
        for key in keys:
            r.addValue(key, cell[key])

    r.show("MD-Yeasts")




def exportControlImage(original, control, path=None):

    """
    Assembles a 3-channeled assessment image from the original image and the control image.

    @type  original: ImagePlus
    @param original: A 2-channeled image being the original image to be segmented.
    @type  control: ImagePlus
    @param control: An 8-bit single-channeled image created by the `segmentYeats` function.
    @type  path: str
    @param path: Path to a folder in which the produced image will be exported. If None, the image is simply not exported.

    @rtype:  ImagePlus
    @return: A composite image counting 3 channels (transmission, fluorescence, control).
    """

    transmission, fluo = ChannelSplitter.split(original)

    transmission.setProcessor(transmission.getProcessor().convertToByte(True))
    fluo.setProcessor(fluo.getProcessor().convertToByte(True))

    result = Concatenator.run(transmission, fluo, control)

    transmission.close()
    fluo.close()
    control.close()

    newTitle = original.getTitle().split('.')[0].lower() + "-control.tif"
    result.setTitle(newTitle)
    result.setDimensions(3, 1, 1)

    compoRes = CompositeImage(result, IJ.COMPOSITE)
    result.close()

    if path is not None and os.path.isdir(path):
        IJ.saveAs(compoRes, "tiff", os.path.join(path, newTitle))

    return compoRes




def hexa(size=8):
    """
    Function building a string representing an hexadecimal number. (i.e. Containing characters in [a-f] and [0-9])

    @type  size: int
    @param size: Number of characters for this number (default=8).

    @rtype: str
    @return: A string representing an hexadecimal number.
    """
    hexaBasis = ['a', 'b', 'c', 'd', 'e', 'f', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    return "#" + "".join([hexaBasis[randint(0, 15)] for i in range(size)])




def drawID(canvas, xPos, yPos, width, height, idTxt, fontSize=25):

    """
    Draws an ID on a canvas image, at a precise location.
    This function is deisgned to prevent the ID from being cut by going out of the image, or going over a certain area described by the given box.

    @type  canvas: ImagePlus
    @param canvas: Image on which the ID must be drawn.
    @type  xPos: float
    @param xPos: Position on the x-axis of the bounding-box in which the ID must not overlap.
    @type  yPos: float
    @param yPos: Position on the y-axis of the bounding-box in which the ID must not overlap.
    @type  width: float
    @param width: Width of the bounding-box with which the ID must not overlap.
    @type  height: float
    @param height: Height of the bounding-box with which the ID must not overlap.
    @type  idTxt: str
    @param idTxt: String to be drawn on the canvas. In this case it is a 6-characters long hexadecimal number.
    @type  fontSize: int
    @param fontSize: Height (in pixels) of the drawn text.

    @rtype: void
    """

    xDraw = xPos
    yDraw = yPos

    proc = canvas.getProcessor()
    textWidth = proc.getFontMetrics().charsWidth(idTxt, 0, len(idTxt))

    if xPos + textWidth + 10 >= canvas.getWidth():
        xDraw = canvas.getWidth() - textWidth - 10

    if xPos - 10 <= 0:
        xDraw = 10

    if yPos - fontSize - 10 <= 0:
        yDraw = yPos + height + fontSize + 10

    clr = proc.get(int(xDraw), int(yDraw))
    clr = int(255 - clr)
    proc.setColor(Color(clr, clr, clr))
    proc.setAntialiasedText(True)
    proc.setFontSize(fontSize)
    proc.drawString(idTxt, int(xDraw), int(yDraw))



def segmentYeasts(rm, imIn, batch=False):
    """
    Function executing the segmentation procedure for each ROI present in the RoiManager.

    We start by creating a list of images which are croped versions of the original image according to what was found in the ROI Manager.
    The control image is generated before we start segmentation.
    For each sub-image, we separate the transmission of the fluorescence. Then, we turn the transmission channel into a mask through several steps.
    (Equalization + Normalization > Laplacian > Threshold > Label connected components > Keep largest component > Morphological closing)
    On the mask, we instanciate a moving n-gon. Its behavior is explained in the function motherDaughterSegmentation from the module "makeNGon" from the package "mdYeasts".
    The stats of every pairs are aggregated into a unique table, persistent across executions.

    @type  rm: RoiManager
    @param rm: An instance of RoiManager containing a list of rectangle selections around pairs of yeasts.
    @type  imIn: ImagePlus
    @param imIn: Image containing two channels (or stack containing two slices) on which there is a transmission image, and a data image.
    @type  batch: bool
    @param batch: Has this function be launched by the batch launcher?
    
    @rtype: (bool, str)
    @return: In this tuple, the boolean is the execution status (success or fail) and the string is the reason why the execution failed. (or "DONE." on success.)
    """

    # 0. Checking that the image is calibrated.
    calib = imIn.getCalibration()
    unit  = calib.getUnit()

    if unit.lower() in ["pixel", "pixels", "px", "pxl"]:
        IJ.log("{0} is not calibrated. Abort.".format(imIn.getTitle()))
        return

    # 1. Extracting images
    chunks  = imIn.crop(rm.getRoisAsArray(), "stack")
    control = ImagePlus("Control", ByteProcessor(imIn.getWidth(), imIn.getHeight()))
    control.getProcessor().set(0)

    mergedStats = []

    for idx, (roi, chunk) in enumerate(zip(rm.getRoisAsArray(), chunks)):

        if roi.getType() != Roi.RECTANGLE:
            IJ.log("Skipping ROI '{0}'. Only rectangles are expected.".format(roi.getName()))
            continue

        # 2. Splitting channels:
        transmission, fluo = ChannelSplitter.split(chunk)
        transmission.setCalibration(calib)
        fluo.setCalibration(calib)
        chunk.close()
        xPos = int((2 * roi.getXBase() + roi.getFloatWidth()) / 2)
        yPos = int((2 * roi.getYBase() + roi.getFloatHeight()) / 2)

        # 3. Preprocess segmentation channel.
        preprocessed = preprocess(transmission)
        preprocessed.setCalibration(calib)
        preprocessed.setTitle(imIn.getTitle().split('.')[0])

        newTitle = "{0}${1}${2}".format(imIn.getTitle(), xPos, yPos)
        fluo.setTitle(newTitle)

        # 4. Segment both yeasts as precisely as possible.
        yeastD, yeastM, stats, verbose = motherDaughterSegmentation(preprocessed, fluo, control, (roi.getXBase(), roi.getYBase()), idx)

        if yeastD is None or yeastM is None:
            IJ.log("Roi {0} skipped (count starts from 0).".format(str(idx)))
            continue
        
        stats['id'] = hexa(6)
        mergedStats.append(stats)

        # 5. Close working images
        transmission.close()
        fluo.close()

        drawID(control, roi.getXBase(), roi.getYBase(), roi.getFloatWidth(), roi.getFloatHeight(), stats['id'])

    settings, verbose = readSettings()
    expPath = None

    if (settings is not None) and (settings['exportControl']):
        expPath = os.path.join(settings['exportRois'], 'control')
        if not os.path.isdir(expPath):
            os.mkdir(expPath)
    
    produced = exportControlImage(imIn, control, expPath)

    if (not batch) and (settings is not None) and (settings['showControl']):
        produced.show()
    else:
        produced.close()

    imIn.resetRoi()
    makeResultsTable(mergedStats)

    if batch or settings['closeOri']:
        imIn.close()
    
    if batch or settings['closeRoiMngr']:
        rm.reset()
        rm.close()
