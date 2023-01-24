import os
from ij import IJ, ImagePlus, ImageStack, CompositeImage
from ij.process import ImageProcessor, ByteProcessor
from ij.plugin import ContrastEnhancer, ImageCalculator, ChannelSplitter, Concatenator
from ij.plugin.frame import RoiManager
from ij.measure import ResultsTable
from util import FindConnectedRegions
from fiji.util.gui import GenericDialogPlus
from inra.ijpb.label import LabelImages
from inra.ijpb.plugins import MorphologicalFilterPlugin
from inra.ijpb.morphology.Morphology import Operation
from inra.ijpb.morphology import Strel
from ij.plugin.filter import Filler
from mdYeasts.makeNGon import motherDaughterSegmentation
from mdYeasts.userIO import readSettings


def makeLaplacian(img, smth=0.25):
    IJ.run(img, "FeatureJ Laplacian", "compute smoothing={0}".format(smth))

    tres = IJ.getImage()
    res = tres.duplicate()
    tres.close()
    img.close()

    return res


def closing(img, rad):
	return MorphologicalFilterPlugin().process(img, Operation.CLOSING, Strel.Shape.DISK.fromRadius(rad))


def connectedComposAndLargest(imIn):
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

    return imOut


def preprocess(d, contrast=True, lapla=True, thresh=True, invt=True, biggest=True, clsg=True):

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
        workingCopy.getProcessor().invert()

    if biggest:
        # 5. Label connected components & keep the largest
        workingCopy = connectedComposAndLargest(workingCopy)

    if biggest:
        # 6. Closing or find a way to detect gaps
        closing(workingCopy, 3)

    # 7. Return
    return workingCopy


def makeResultsTable(stats):
    r = ResultsTable.getResultsTable("MD Yeasts") or ResultsTable()

    for cell in stats:
        r.addRow()
        keys = sorted(cell.keys())
        for key in keys:
            r.addValue(key, cell[key])

    r.show("MD Yeasts")


def exportControlImage(original, control, path=None):
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



def segmentYeasts(rm, imIn, batch=False):

    # 1. Extracting images
    chunks = imIn.crop(rm.getRoisAsArray(), "stack")
    calib  = imIn.getCalibration()

    control = ImagePlus("Control", ByteProcessor(imIn.getWidth(), imIn.getHeight()))
    control.getProcessor().set(0)

    mergedStats = []

    for idx, (roi, chunk) in enumerate(zip(rm.getRoisAsArray(), chunks)):

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

        newTitle = "{0}${1}${2}".format(imIn.getTitle(), xPos, yPos)
        fluo.setTitle(newTitle)

        # 4. Segment both yeasts as precisely as possible.
        yeastD, yeastM, stats, verbose = motherDaughterSegmentation(preprocessed, fluo, control, (roi.getXBase(), roi.getYBase()))
        mergedStats.append(stats)

        # 5. Close working images
        transmission.close()
        fluo.close()

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
