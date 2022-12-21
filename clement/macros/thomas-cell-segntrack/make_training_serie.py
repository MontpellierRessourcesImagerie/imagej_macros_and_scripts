from __future__ import with_statement, division, print_function

from ij import IJ, WindowManager, ImagePlus, ImageStack
from ij.gui import GenericDialog
from ij.io import OpenDialog
from ij.plugin import ChannelSplitter, ZProjector, Concatenator, Duplicator
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
import os
import random



def buildAFrame(image, frames, rg):
    shift = 2

    if rg[1] - rg[0] <= 2 * shift:
        print("Impossible to find enough in-focus slices in this image")
        return False
    
    focus = Duplicator().run(image, 1, 1, rg[0]+shift, rg[1]-shift, 1, image.getNFrames())
    print(rg[0]+shift, rg[1]-shift)
    
    # Z-projection according the maximal intensity in the stack
    segmentationChannel = ZProjector.run(focus, "max all")
    focus.close()

    # Pick the first frame and add it to a stack
    frameIndex = random.randint(1, segmentationChannel.getNFrames())
    stack = segmentationChannel.getImageStack()
    index = segmentationChannel.getStackIndex(1, 1, frameIndex)

    frame = ImagePlus(str(frames.getSize()), stack.getProcessor(index))
    IJ.run(frame, "Enhance Contrast...", "saturated=0.35 normalize equalize process_all")
    IJ.run(frame, "32-bit", "")
    IJ.run(frame, "Divide...", "value=65535")

    stackChunk = frame.getImageStack()
    indexChunk = frame.getStackIndex(1, 1, 1)

    frames.addSlice(str(frames.getSize()), stackChunk.getProcessor(indexChunk))

    return True


def makeAllPaths(base, order='SORTED'):
    content = os.listdir(base)
    res = []

    for head in content:
        path = os.path.join(base, head)
        if head.endswith('.tif') and os.path.isfile(path):
            res.append(path)

    if order == 'SORTED':
        res.sort()
    elif order == 'SHUFFLED':
        random.shuffle(res)

    return res


def writeLists(base, tr, ts):
    path = os.path.join(base, "lists.txt")
    f = open(path, 'w')
    f.write("Training: " + str(tr) + '\n' + "Testing: " + str(ts))
    f.close()


def readRange(base, idx):
    path = os.path.join(base, "focusInfos_{0}.txt".format(str(idx).zfill(3)))
    f = open(path, 'r')
    content = f.read()
    f.close()
    return tuple(int(i) for i in content.split(','))


def launchBuildingTimeSeries():
    base = "/home/benedetti/Bureau/training_series"
    imagePaths = makeAllPaths(os.path.join(base, "median"), 'SHUFFLED')
    
    trainingFrames = ImageStack(1024, 1024)
    testingFrames  = ImageStack(1024, 1024)

    trainingList = []
    testingList = []

    for idx, imgP in enumerate(imagePaths):
        img = IJ.openImage(imgP)
        rg = readRange(base, idx)

        if buildAFrame(img, trainingFrames, rg):
            trainingList.append(idx+1)

        if buildAFrame(img, testingFrames, rg):
            testingList.append(idx+1)

        img.close()

    training = ImagePlus("Training", trainingFrames)
    testing = ImagePlus("Testing", testingFrames)
    writeLists(base, trainingList, testingList)

    print("Before: ", training.getNSlices(), training.getNFrames())
    if (training.getNSlices() > 1):
        print("List: ", len(trainingList))
        training.setDimensions(1, 1, len(trainingList))
        testing.setDimensions(1, 1, len(testingList))
    print("After: ", training.getNSlices(), training.getNFrames())

    return (training, testing)


training, testing = launchBuildingTimeSeries()
training.show()
testing.show()

print("Out1: ", training.getNSlices(), training.getNFrames())
training.setDimensions(1, 1, 19)
print("Out2: ", training.getNSlices(), training.getNFrames())