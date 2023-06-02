import sys
from ij import IJ
from ij import ImagePlus
from ij.plugin import Duplicator;
from ij.process import ImageStatistics
from ij.process import Blitter
from ij.plugin import LutLoader
from ij.process import LUT 
from ij.gui import  WaitForUserDialog
from ij.gui import Roi
from inra.ijpb.label import LabelImages


THRESHOLDING_METHOD = "Default"
LOOKUP_TABLE_NAME = "glasbey on dark"
LOOKUP_TABLE = LUT(LutLoader.getLut( "glasbey on dark" ), 0, 255);

def main():
    inputImage = IJ.getImage()
    currentC, currentZ, currentT = (inputImage.getC(), inputImage.getZ(), inputImage.getT())
    spineChannel = inputImage.getProp("spine-channel")
    if spineChannel and currentC == int(spineChannel):
        IJ.error("Please run the segmentation on a greyscale channel!")
        sys.exit()
    roi = inputImage.getRoi();
    if not roi:
        IJ.error("Please draw a ROI around a spine!")
        sys.exit()
    spineImage = segmentObjectInRegion(inputImage, roi)
    addSpine(inputImage, spineImage)
    spineImage.close()


def segmentObjectInRegion(image, roi):
    """Segment the largest 3D object in the region given by the roi. 
    Each slice is cleared outside of the 2D roi before the thresholding is done.
    """
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    image.killRoi()
    maskImage = Duplicator().run(image, currentC, currentC, 0, image.getNSlices()-1, currentT, currentT)
    for z in range(1, maskImage.getNSlices()+1):
        maskImage.getStack().getProcessor(z).fillOutside(roi)
    IJ.setAutoThreshold(maskImage, THRESHOLDING_METHOD + " dark stack");
    IJ.run(maskImage, "Convert to Mask", "method="+THRESHOLDING_METHOD+" background=Dark black")
    labelsImage = LabelImages.regionComponentsLabeling(maskImage, 255, 6, 8)
    labelsImage = LabelImages.keepLargestLabel(labelsImage)
    return labelsImage


def addEmptyChannel(image):
    """Add a new, empty channel to the image and restore the original position.
    """
    width, height, nChannels, nSlices, nFrames  = image.getDimensions()
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    image.setPosition(nChannels, currentZ, currentT)
    IJ.run(image, "Add Slice", "add=channel")
    image.setPosition(currentC, currentZ, currentT)
    return nChannels + 1


def addSpine(image, spineImage):
    """Add the spine from the spineImage to the spine-channel of image. The new spine will have the next available index.
    """
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    spineChannel = image.getProp("spine-channel")
    if not spineChannel:
        channel = addEmptyChannel(image)
        image.setProp("spine-channel", channel)
        label = 1
    else:
        channel = int(spineChannel)
        image.setC(channel)
        stats = image.getStatistics(ImageStatistics.MIN_MAX)
        label = stats.max + 1
    copyStackTo(image, spineImage, channel, currentT, label)


def copyStackTo(image, stack, channel, frame, label):
    """Copy the stack into the given channel and frame of image. The slices of the stack are copied with a transparent zero.
    """
    LabelImages.replaceLabels(stack, [255], label)
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    offset = ((currentT-1) * nChannels*nSlices) + channel;
    for sliceNumber in range(1, stack.getStack().size()+1):
        image.getStack().getProcessor(offset + ((sliceNumber-1) * nChannels)).copyBits(stack.getStack().getProcessor(sliceNumber), 0, 0, Blitter.COPY_ZERO_TRANSPARENT)
    image.setC(channel)
    image.getChannelProcessor().setLut(LOOKUP_TABLE)
    image.getChannelProcessor().setMinAndMax(0, label)
    image.setPosition(currentC, currentZ, currentT)
    image.updateAndDraw()
    
    
main()


