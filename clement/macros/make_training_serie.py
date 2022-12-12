from __future__ import with_statement, division, print_function

from ij import IJ, WindowManager, ImagePlus, ImageStack
from ij.gui import GenericDialog
from ij.io import OpenDialog
from ij.plugin import ChannelSplitter, ZProjector, Concatenator, Duplicator
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
import os



def buildAFrame(image, frames):
    # Throwing away data channel
    segmentationChannel, dataChannel = ChannelSplitter.split(image)
    image.close()
    dataChannel.close()

    # Z-projection according the maximal intensity in the stack
    segmentationChannel = ZProjector.run(segmentationChannel, "max all")

    # Pick the first frame and add it to a stack
    stack = segmentationChannel.getImageStack()
    index = segmentationChannel.getStackIndex(1, 1, 1)

    frame = stack.getProcessor(index)
    IJ.run(frame, "Enhance Contrast", "saturated=0.35")
    IJ.run(frame, "Apply LUT", "")
    IJ.run(frame, "32-bit", "")
    IJ.run(frame, "Divide...", "value=65535")

    frames.addSlice(str(frames.getSize()), frame)


def launchBuildingTimeSeries():
    base = "/home/benedetti/Documents/first-project/ThomasS_Pour_Volker/220926_RmS_ThomasS/NoAux"
    indices = [9, 17, 3, 6, 8, 12, 15, 1]
    imagePaths = ["20220926-1106_NoAux_p{0}.tif".format(str(i).rjust(3, '0')) for i in indices]
    frames = ImageStack(1024, 1024)

    for imgP in imagePaths:
        fullPath = os.path.join(base, imgP)
        img = IJ.openImage(fullPath)
        buildAFrame(img, frames)

    return ImagePlus("Slices", frames)


result = launchBuildingTimeSeries()
result.show()