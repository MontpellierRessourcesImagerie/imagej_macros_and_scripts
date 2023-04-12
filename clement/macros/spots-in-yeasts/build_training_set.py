from ij import IJ, ImageStack, ImagePlus
from java.awt import Color
import os
import random

_SOURCE_FOLDER_        = "/home/benedetti/Documents/projects/10-spots-in-yeasts/testing-set-2"
_DESTINATION_FOLDER_   = "/home/benedetti/Documents/projects/10-spots-in-yeasts"
_FILES_EXTENSION_      = ".tif"
_TARGET_CHANNEL_INDEX_ = 2 # -1 == random
_TARGET_SLICE_INDEX_   = 1 # -1 == random
_TARGET_FRAME_INDEX    = 1 # -1 == random
_PRODUCTION_TITLE_     = "spots-detection.tif" # Name given to the output
_IGNORE_HIDDEN_        = True  # Ignore hidden files
_IN_ORDER_             = False  # Sorts the content of the folder lexicographically
_TEXT_INFOS_ = { # Displays the name of the source file in the corner of each image
    'display': False,
    'font-size': 40,
    'color': Color(1.0, 1.0, 1.0),
    'background-color': Color(0.0, 0.0, 0.0)
}


def preprocess(imgPrcr):
    from ij.plugin import ContrastEnhancer
    from ij.plugin.filter import RankFilters

    # Normalizing
    ce = ContrastEnhancer()
    ce.setNormalize(True)
    ce.stretchHistogram(imgPrcr, 0.35)
    # ce.equalize(imgPrcr)

    # Denoising
    rk = RankFilters()
    rk.rank(imgPrcr, 2, RankFilters.MEDIAN)

    # Setting values between 0 and 1
    fltPrc = imgPrcr.convertToFloatProcessor()
    fltPrc.multiply(1.0/65535.0)
    return fltPrc


def browse():
    if not os.path.isdir(_SOURCE_FOLDER_):
        print("`{0}` is not a valid folder path.".format(_SOURCE_FOLDER_))
    
    content = []
    for f in os.listdir(_SOURCE_FOLDER_):
        if _IGNORE_HIDDEN_ and f.startswith("."):
            continue
        fullpath = os.path.join(_SOURCE_FOLDER_, f)
        if os.path.isfile(fullpath) and f.lower().endswith(_FILES_EXTENSION_):
            content.append(fullpath)
    
    if _IN_ORDER_:
        content.sort()

    assembled = None
    for path in content:
        IJ.log("Opening `{0}`".format(path))
        srcImage   = IJ.openImage(path)
        tgtFrame   = _TARGET_FRAME_INDEX if (_TARGET_FRAME_INDEX > 0) else random.randint(1, srcImage.getNFrames())
        tgtSlice   = _TARGET_SLICE_INDEX_ if (_TARGET_SLICE_INDEX_ > 0) else random.randint(1, srcImage.getNSlices())
        tgtChannel = _TARGET_CHANNEL_INDEX_ if (_TARGET_CHANNEL_INDEX_ > 0) else random.randint(1, srcImage.getNChannels())
        index      = srcImage.getStackIndex(tgtChannel, tgtSlice, tgtFrame)
        stack      = srcImage.getStack()
        isolateSlc = preprocess(stack.getProcessor(index))

        if _TEXT_INFOS_['display']:
            isolateSlc.setColor(_TEXT_INFOS_['color'])
            isolateSlc.setFontSize(_TEXT_INFOS_['font-size'])
            isolateSlc.drawString(srcImage.getTitle(), 10, srcImage.getHeight()-10, _TEXT_INFOS_['background-color'])
        
        if assembled is None:
            assembled = ImageStack(srcImage.getWidth(), srcImage.getHeight())
        
        assembled.addSlice(isolateSlc)
        srcImage.close()

    production = ImagePlus(_PRODUCTION_TITLE_, assembled)
    production.setDimensions(1, 1, assembled.size())

    return production


ts = browse()
IJ.save(ts, os.path.join(_DESTINATION_FOLDER_, _PRODUCTION_TITLE_))
ts.show()