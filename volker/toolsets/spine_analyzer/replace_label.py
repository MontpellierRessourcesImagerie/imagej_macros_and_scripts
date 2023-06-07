from ij import IJ
from ij import ImagePlus
from ij.process import Blitter
from ij.gui import NewImage
from ij.plugin import Duplicator
from inra.ijpb.label import LabelImages
from inra.ijpb.morphology.geodrec import GeodesicReconstruction3DHybrid0Gray16

def main():
    image = IJ.getImage()
    image.killRoi()
    
    newLabel = 8
    
    x = 1064
    y = 724
    z = 11
    frame = 1
    channel = 3
    
    labels = Duplicator().run(image, channel, channel, 1, image.getNSlices(), frame, frame)
    width, height, nChannels, nSlices, nFrames = labels.getDimensions()
    label = labels.getStack().getVoxel(x, y, z)
    
    seedImage = NewImage.createShortImage("seed", width, height, nSlices, NewImage.FILL_BLACK)
    seedImage.getStack().setVoxel(x, y, z, 255)
    
    reconstructor = GeodesicReconstruction3DHybrid0Gray16(6)
    isolatedLabelStack = reconstructor.applyTo(seedImage.getStack(), labels.getStack())
    isolatedLabelImage = ImagePlus("isolated label", isolatedLabelStack)
    
    LabelImages.replaceLabels(isolatedLabelImage, [label], newLabel)
    
    copyStackTo(image, isolatedLabelImage, channel, frame, newLabel)



def copyStackTo(image, stack, channel, frame, label):
    """Copy the stack into the given channel and frame of image. The slices of the stack are copied with a transparent zero.
    """
#    LabelImages.replaceLabels(stack, [255], label)
    currentC, currentZ, currentT = (image.getC(), image.getZ(), image.getT())
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    offset = ((currentT-1) * nChannels*nSlices) + channel;
    for sliceNumber in range(1, stack.getStack().size()+1):
        image.getStack().getProcessor(offset + ((sliceNumber-1) * nChannels)).copyBits(stack.getStack().getProcessor(sliceNumber), 0, 0, Blitter.COPY_ZERO_TRANSPARENT)
    image.setC(channel)
#    image.getChannelProcessor().setLut(LOOKUP_TABLE)
    image.getChannelProcessor().resetMinAndMax()
    image.setPosition(currentC, currentZ, currentT)
    image.updateAndDraw()    


main()

