from __future__ import with_statement, division, print_function

from ij import IJ, WindowManager, ImagePlus, ImageStack
from ij.gui import GenericDialog
from ij.io import OpenDialog
from ij.plugin import ChannelSplitter, ZProjector, Concatenator, Duplicator
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
import os
import random



def buildAFrame(image, frames):
    
    stack = image.getImageStack()
    index = image.getStackIndex(1, 1, 1)

    frame = ImagePlus(str(frames.getSize()), stack.getProcessor(index))

    IJ.run(frame, "Enhance Contrast...", "saturated=0.35 normalize equalize process_all")
    IJ.run(frame, "32-bit", "")
    IJ.run(frame, "Divide...", "value=65535")

    stackChunk = frame.getImageStack()
    indexChunk = frame.getStackIndex(1, 1, 1)

    frames.addSlice(str(frames.getSize()), stackChunk.getProcessor(indexChunk))



def makeAllPaths(bases, order='SORTED'):
    res = []
    for base in bases:
        content = [f for f in os.listdir(base) if ("DAPI" in f)]

        for head in content:
            path = os.path.join(base, head)
            if head.lower().endswith('.tif') and os.path.isfile(path):
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


def launchBuildingTimeSeries(proportionTraining=0.5):
    bases = [
        "/home/benedetti/Documents/projects/6-solange-counting/lamelle-4",
        "/home/benedetti/Documents/projects/6-solange-counting/lamelle-5"
    ]

    imagePaths = makeAllPaths(bases, 'SHUFFLED')
    
    trainingFrames = ImageStack(2048, 2048)
    testingFrames  = ImageStack(2048, 2048)

    trainingList = imagePaths[:int(proportionTraining*len(imagePaths))]
    testingList = imagePaths[int(proportionTraining*len(imagePaths)):]

    for idx, imgP in enumerate(trainingList):
        img = IJ.openImage(imgP)
        buildAFrame(img, trainingFrames)
        img.close()

    for idx, imgP in enumerate(testingList):
        img = IJ.openImage(imgP)
        buildAFrame(img, testingFrames)
        img.close()

    training = ImagePlus("Training", trainingFrames)
    testing = ImagePlus("Testing", testingFrames)
    writeLists("/home/benedetti/Bureau", trainingList, testingList)

    print("Before: ", training.getNSlices(), training.getNFrames())
    if (training.getNSlices() > 1):
        training.setDimensions(1, 1, len(trainingList))
        testing.setDimensions(1, 1, len(testingList))
    print("After: ", training.getNSlices(), training.getNFrames())

    return (training, testing)


def main():
    training, testing = launchBuildingTimeSeries(0.75)

    training.show()
    testing.show()

    # print("Out1: ", training.getNSlices(), training.getNFrames())
    # training.setDimensions(1, training.getNFrames(), training.getNSlices())
    # print("Out2: ", training.getNSlices(), training.getNFrames())

main()