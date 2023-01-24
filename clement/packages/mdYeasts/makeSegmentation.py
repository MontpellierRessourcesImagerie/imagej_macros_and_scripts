import os

from ij import IJ, ImagePlus, ImageStack
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
    # 1. Clearing results table.
    r = ResultsTable.getResultsTable()

    for cell in stats:
        r.addRow()
        for key, item in cell.items():
            r.addValue(key, item)

    r.show("Results")



def segmentYeasts(rm, imIn):
    # 1. Extracting images
    chunks = imIn.crop(rm.getRoisAsArray(), "stack")
    calib = imIn.getCalibration()
    

    control = ImagePlus("Control", ByteProcessor(imIn.getWidth(), imIn.getHeight()))
    control.getProcessor().set(0)

    mergedStats = []

    for idx, (roi, chunk) in enumerate(zip(rm.getRoisAsArray(), chunks)):

        # 2. Splitting channels:
        transmission, fluo = ChannelSplitter.split(chunk)
        transmission.setCalibration(calib)
        fluo.setCalibration(calib)

        chunk.close()

        # 3. Preprocess segmentation channel.
        preprocessed = preprocess(transmission)
        preprocessed.setCalibration(calib)

        # 4. Segment both yeasts as precisely as possible.
        yeastD, yeastM, stats, verbose = motherDaughterSegmentation(preprocessed, fluo, control, (roi.getXBase(), roi.getYBase()))
        mergedStats.append(stats)


        # 5. Close working images
        transmission.close()
        fluo.close()

    imIn.resetRoi()
    control.show()

    makeResultsTable(mergedStats)

