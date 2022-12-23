from __future__ import with_statement, division, print_function

from ij import IJ, WindowManager, ImagePlus, ImageStack
from ij.gui import GenericDialog
from ij.io import OpenDialog
from ij.plugin import ChannelSplitter, ZProjector, Concatenator, Duplicator, ImageCalculator
from ij.plugin.filter import ImageMath
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
from inra.ijpb.plugins import MorphologicalFilterPlugin
from inra.ijpb.morphology.Morphology import Operation
from inra.ijpb.morphology import Strel
from ij.process import ShortProcessor, FloatProcessor
import os
import json
import sys
import threading

from fiji.plugin.trackmate import Model
from fiji.plugin.trackmate import Settings
from fiji.plugin.trackmate import TrackMate
from fiji.plugin.trackmate import SelectionModel
from fiji.plugin.trackmate import Logger
from fiji.plugin.trackmate.detection import LabeImageDetectorFactory
from fiji.plugin.trackmate.tracking import LAPUtils
from fiji.plugin.trackmate.tracking.sparselap import SparseLAPTrackerFactory
from fiji.plugin.trackmate.gui.displaysettings import DisplaySettingsIO
import fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer as HyperStackDisplayer
import fiji.plugin.trackmate.features.FeatureFilter as FeatureFilter
from fiji.plugin.trackmate.tracking.overlap import OverlapTrackerFactory
from fiji.plugin.trackmate.action import LabelImgExporter


dimensions = {
    'vWidth': 0.102, 
    'vHeight': 0.102, 
    'vDepth': 0.4, 
    'lengthUnit': "um",
    'frameInterval': 15,
    'timeUnit': "min"
}

globalVars = {
    'classiPath': None,     # Path of the classifier to use. None to open GUI dialog.
    'useGpu': False,        # Should LabKit use the GPU?
    'exportPath': "",       # Path of the folder in which we will export statistics and final images.
    'baseName': "",         # Name to which an extension is going to be stuck to export something.
    'processFolder': False, # Should we process the whole folder?
    'useLogs': True,        # Should the logs be exported in a file.
    'logsFile': None,       # Descriptor of the log file (None while not opened).
    'generateHTML': True,   # Relicate of a former implementation. Useless.
    'format': 'JSON',       # 'JSON' or 'CSV'. Format to which the stats must be exported.
    'showLogs': True,       # Should the log appear on screen in real time during processing.
    'toleratedSize': 3000   # Minimal area to reach (in number of pixels) for a label to be considered a cell.
}

testGlobalVars = {
    'classiPath': {'val': None, 'type': str, "descr": "Path of the classifier to use"}
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                             #
#       IN-FOCUS AREA PROCESSING FUNCTIONS                                    #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


## @brief Function using the derivative of a function to find its local extremums.
#         It corresponds to all the moment the variation direction of the function changes, 
#         which are the moments the derivative changes of sign.
#         This function doesn't really handles plateaux, the extremum would then be placed at the end of the plateau
## @param data: The original samples in a list (ordinate only).
## @param derivate: The points representing the derivative in a list (ordinate only).
## @return A dictionary containing the sorted minimums and maximums. 
#          Each value of the list is a tuple containing (index, value) with 'value' being the extremum and 'index' being where it is located in the data.
def seekExtremums(data, derivate):
    # Tokens easier to see
    def valToStr(der, last=None):
        if der > 0:
            return 'POS'
        elif der < 0:
            'NEG'
        else:
            if last==None:
                return 'NULL'
            else:
                return last
    
    last = valToStr(derivate[0])
    minimums = []
    maximums = []

    for i in range(0, len(derivate)):
        current = valToStr(derivate[i], last)

        if (last != current):
            if last == 'POS':
                maximums.append((i, data[i]))
            else:
                minimums.append((i, data[i]))
        
        last = current

    minimums.sort(key=lambda a: a[1])
    maximums.sort(key=lambda a: a[1])

    return {
        'minimums': minimums, 
        'maximums': maximums}


## @brief Smoothing by nearest neighbors averaging of the provided points.
## @param curve: A list of samples of a function in a list (ordinate only).
## @param side_range: Number of points considered in the smoothing process. Ex: side_range=2 => 5(2+2+1) points used for smoothing.
## @return A list of numbers representing the smoothed points.
def smoothCurve(curve, side_range):
    
    pointsRaw = curve
    points = []

    for i in range(0, len(pointsRaw)):
        # First and last indices used to process the average.
        start = i - side_range
        end   = i + side_range
        accumulator = 0

        if (start < 0) or (end >= len(pointsRaw)):
            points.append(pointsRaw[i])
            continue

        for j in range(start, end+1):
            accumulator += pointsRaw[j]
        
        accumulator /= (end - start + 1)
        points.append(accumulator)
    
    return points


## @brief Function processing the derivative of a discretly sampled function. The last point is set to 0 to achieve the same size as the original list.
## @param points: List of numbers representing the samples of a function.
def derivate(points):
    derivative = []
    for i in range(0, len(points)):
        if (i == len(points)-1):
            continue
        derivative.append(points[i+1]-points[i])
    derivative.append(0)
    return derivative


## @brief Locates the two caracteristic peaks and the valley within the extremums lists.
## @param extremums: A dictionary containing the structure returned by the function seekExtremums.
## @return A new dictionary storing the informations representing the two Laplacian white peaks (going in/out of focus) and the valley ("middle" of focus range).
def isolateValley(extremums):
    maximums = extremums['maximums'][-2:] # The two biggest maximums
    a2 = max(maximums[0][0], maximums[1][0])
    a1 = min(maximums[0][0], maximums[1][0])
    minimums = [m for m in extremums['minimums'] if (m[0] > a1) and (m[0] < a2)]
    minimum = minimums[0]
    return {
        'peaks': maximums,
        'valley': minimum
    }


## @brief From a tolerance percentage, accepts a range on the left and on the right of the "middle" of the focus range. The tolerance is based on the difference between the minimum and the maximum of the curve.
## @param values: Original (smoothed) data set.
## @param extremums: List of tuples processed byseekExtremums.
## @param tolerance: Value between 0 and 1. If 0, only accepts the range [minimum, minimum] (one value). If 1, accepts the range [max1, max2].
#                       A minimum is necessarily between to local maximums. If you consider that u-shaped piece of curve as a hole, represents the percentage
#                       at which you want to fill that hole.
## @return A dictionary containing the original data, the distance between the max and the min over the whole image, the begining and the end of the in-focus range.
def findAcceptedRange(values, extremums, tolerance):
    # We only want the minimum between the two maximums
    region = isolateValley(extremums)
    absoluteMax = region['peaks'][-1][1] # The absolute (global) maximum
    absoluteMin = region['valley'][1] # The absolute (global) minimum
    distance = absoluteMax - absoluteMin

    upperBoundary = absoluteMin + tolerance * distance # Farthest value accepted from the minimum (we take values on the left and on the right from the minium)
    middle = region['valley'][0] # Index of the absolute minimum
    start = middle
    end = middle

    while (start > 0) and (values[start] < upperBoundary):
        start -= 1

    while (end < len(values)-1) and (values[end] < upperBoundary):
        end += 1

    return {
        'data': values,
        'distance': distance, 
        'start': start, 
        'end': end}


## @brief From a plot along the slices and a tolerance, determines which frames contain proper (in focus) data.
## @param curve: The output of the z-ploting of the laplacian (with zero crossings on) under the shape of a dictionary containing at least a 'Mean' key pointing to a list of numbers.
## @param tolerance: Percentage represented by a float in [0.0, 1.0].
def getFocusInfos(curve, tolerance):

    points = smoothCurve(curve, 2)
    der = derivate(points)
    extremums = seekExtremums(points, der)
    acceptedRange = findAcceptedRange(points, extremums, tolerance)

    logging("Focus infos: " + str(acceptedRange))

    return acceptedRange


## @brief Calculates the z-profile of a stack. Could be deleted if a straight-forward way to use "Plot z-axis" was available in Python
## @param imp: The image in levels of gray on which the ploting has to be realised.
## @return A normalized list on numbers representing the amount of white piexels over the slices.
def zProfileOverLaplacian(imp):

    ori = Duplicator().run(
        imp, 
        1,
        1,
        1, 
        imp.getNSlices(),
        1,
        1)

    IJ.run(ori, "FeatureJ Laplacian", "compute smoothing=1.0 detect")
    lapla = IJ.getImage()

    stack  = lapla.getImageStack()
    width  = stack.getWidth()
    height = stack.getHeight()
    depth  = stack.getSize()

    accumulator = [0 for i in range(0, depth)]

    for s in range(0, depth):
        for c in range(0, width):
            for l in range(0, height):
                accumulator[s] += stack.getVoxel(c, l, s)

    lapla.close()
    
    m = accumulator[0]
    for i in range(0, depth):
        if m < accumulator[i]:
            m = accumulator[i]

    for i in range(0, depth):
        accumulator[i] /= m

    ori.close()

    return accumulator


## @brief Only keeps in-focus slices.
## @param inFocusInfos: Dict as returned by the function getFocusInfos.
## @param old: Original image on which focus infos have been calculated. Will be closed within the process.
## @return The same image as 'old' but by keeping only frames in focus.
def keepInFocusSlices(inFocusInfos, old):
    seg = Duplicator().run(
        old, 
        1,
        1,
        inFocusInfos['start'], 
        inFocusInfos['end'],
        1,
        old.getNFrames())

    old.close()
    return seg


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                             #
#       SEGMENTATION PROCESS                                                  #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


## @brief Ask the user for a file path (in parameter or generic dialog), verifies that it is valid.
## @param path: A string if the path is known, None if a file choosing dialog must be opened.
## @return The path if it is valid, None otherwise.
def askForPath(path=None):
    dataPath = ""

    if path is None:
        dataPath = IJ.getFilePath("Select an image")
        if dataPath is None:
            return None
    else:
        dataPath = path

    if os.path.isfile(dataPath):
        return dataPath
    else:
        return None


## @brief Opens an image given a path and updates its metadata.
## @param path: The path of the image the user wants to work on.
## @return None in case of failure, or the opened image on success.
def acquireImage(path):
    rawImage = None

    try:
        rawImage = IJ.openImage(path)
        if rawImage is None:
            return None
    except:
        logging("Failed to open image: {0}".format(path))
        return None

    width, height, nChannels, nSlices, nFrames = rawImage.getDimensions()

    rawImage.getCalibration().setXUnit("um");
    rawImage.getCalibration().setYUnit("um");
    rawImage.getCalibration().setZUnit("um");
    
    IJ.run(rawImage, "Properties...", "channels={0} slices={1} frames={2} pixel_width={3} pixel_height={4} voxel_depth={5} frame=[{6} {7}]".format(nChannels, nSlices, nFrames, dimensions['vWidth'], dimensions['vHeight'], dimensions['vDepth'], dimensions['frameInterval'], dimensions['timeUnit']))

    return rawImage


## @brief In the case the user wants to process the whole folder, builds the list of images path to be processed.
## @param path The path of an image in the folder to be processed.
## @return A list containing the path of each image to be processed in the folder.
def buildQueue(path):
    if globalVars['processFolder']:
        queue = []
        ext = path.split('.')[-1]
        directory, name = os.path.split(path)
        content = os.listdir(directory)

        for c in content:
            current = os.path.join(directory, c)
            if os.path.isfile(current) and current.endswith(ext):
                queue.append(current)
        
        return queue
    else:
        return [path]


## @brief Allows the user to choose the classifier with which he wants to work.
## @param path: If path == None, opens a dialog box to ask the user to choose a file on his system. Simply opens the classifier otherwise.
## @return None in case of failure, or the chosen path on success.
def acquireClassifier(path=None):
    dataPath = ""

    if path is None:
        dataPath = IJ.getFilePath("Select a classifier")
    else:
        dataPath = path
    
    if (dataPath is None) or (not os.path.isfile(dataPath) or (not dataPath.endswith(".classifier"))):
        return None

    return dataPath


## @brief Preprocessing necessary before being able to segment the image.
## @param rawImage: Image as it was opened from the disk.
## @return A tuple containing the preprocessed segmentation channel and the raw data channel.
def preprocessRawImage(rawImage):
    logging(">>> Starting preprocessing")
    # 1. Splitting channels and closing original image
    if rawImage.getNChannels() != 2:
        logging("Only two channeled images are handled (1:segmentation, 2:data)")
        return (None, None)
    
    segmentationChannel, dataChannel = ChannelSplitter.split(rawImage)
    rawImage.close()

    # 2. Applying median blur to each channel
    logging("Median bluring on segmentation channel")
    IJ.run(segmentationChannel, "Median 3D...", "x=5 y=5 z=1.5")
    logging("Median bluring on data channel")
    IJ.run(dataChannel, "Median 3D...", "x=5 y=5 z=1.5")
 

    # 3. Ditching out-of-focus slices
    logging("Processing in-focus slices")
    inFocusInfos = getFocusInfos(zProfileOverLaplacian(segmentationChannel), 0.2)
    shift = 2

    if inFocusInfos['end'] - inFocusInfos['start'] <= 2 * shift:
        logging("Not enough is-focus slices on {0}".format(globalVars['baseName']))
        return (None, None)

    inFocusInfos['start'] += 2
    inFocusInfos['end'] -= 2
    segmentationChannel = keepInFocusSlices(inFocusInfos, segmentationChannel)

    # 4. Z-projection (max intensity)
    logging("Projection along z-axis")
    segmentationChannel = ZProjector.run(segmentationChannel, "max all")
    dataChannel = ZProjector.run(dataChannel, "max all")

    # 5. Enhance contrast and normalize between 0 and 1 (32-bits)
    logging("Fixing contrast; passing on 32-bits; passing values between 0 and 1")
    IJ.run(segmentationChannel, "Enhance Contrast...", "saturated=0.35 normalize equalize process_all")
    IJ.run(segmentationChannel, "32-bit", "")
    IJ.run(segmentationChannel, "Divide...", "value=65535 stack")

    if globalVars['exportPath'] is not None:
        IJ.saveAs(segmentationChannel, "tiff", os.path.join(globalVars['exportPath'], globalVars['baseName']+"_seg.tif"))
        IJ.saveAs(dataChannel, "tiff", os.path.join(globalVars['exportPath'], globalVars['baseName']+"_data.tif"))

    return (segmentationChannel, dataChannel)


## @brief Launches LabKit and attempts to produce a rough segmentation of the image.
## @param segmentation: The preprocessed channel as produced by preprocessRawImage
## @param classifierPath: The path to the classifier suitable to segment this image.
## @return The segmentation produced by LabKit.
def labkitSegmentation(segmentation, classifierPath):
    logging("Starting LabKit automatic segmentation")
    segmentation.show() # Mandatory to get LabKit working...
    try:
        IJ.run(segmentation, "Segment Image With Labkit", "segmenter_file={0} use_gpu={1}".format(classifierPath, "true" if globalVars['useGpu'] else "false"));
    except:
        logging("Failed to launch LabKit")
        return None
    
    segmentationVirtual = IJ.getImage()
    rawSegmentation = segmentationVirtual.duplicate()

    segmentationVirtual.changes = False
    segmentation.changes = False
    segmentationVirtual.close()
    segmentation.close()

    return rawSegmentation


## @brief Isolate the label having the specified value in the image through a Gaussian function. This function's purpose is to replace MorpholibJ.selectLabel that opens a GUI window with the result.
## @param img A labeled image.
## @param lbl The value of the label to isolate
## @return An image with a black background and only one label, which has the value of lbl.
def selectLabel(img, lbl):
    ip = img.getProcessor()
    fp = ip.convertToFloatProcessor()
    fp2 = ip.convertToFloatProcessor()

    fp2.set(1.0)
    buffer = ImagePlus("temp1", fp2)

    fp.subtract(lbl)
    im1 = ImagePlus("temp2", fp)
    im2 = ImageCalculator.run(im1, im1, "mul")
    im2.getProcessor().multiply(-0.5)
    im2.getProcessor().exp()

    imOut = ImageCalculator.run(buffer, im2, "and")

    lp = imOut.getProcessor()
    lp.multiply(lbl/65535.0)

    im1.close()
    im2.close()

    return ImagePlus("label_{0}".format(lbl), lp.convertToShortProcessor())


## @brief More consise way to write the closing operation.
def closing(img, rad):
	return MorphologicalFilterPlugin().process(img, Operation.CLOSING, Strel.Shape.DISK.fromRadius(rad))


## @brief Filters all the labels contained on a frame by applying multiple transformations.
## @param frame A frame (1 image of 1 channel, 1 slice, 1 frame) containing labels
## @return A new image representing the input frame but with labels filtered and fixed.
def filterLabels(frame):
    IJ.run(frame, "Connected Components Labeling", "connectivity=4 type=[16 bits]")
    temp = IJ.getImage()
    compos = temp.duplicate()
    temp.close()
    
    labels = []

    stats = compos.getStatistics()
    discarded = []

    for i in range(int(stats.histMin), int(stats.histMax)+1):
        
        if stats.histogram16[i] < 500:
            continue
        
        isolatedLabel = selectLabel(compos, i)

        fixedLabel = closing(isolatedLabel, 25)
        isolatedLabel.close()

        area = fixedLabel.getStatistics().histogram16[i]

        if area < globalVars['toleratedSize']:
            discarded.append(i)
            fixedLabel.close() # If the component is less than 6500 pixels of area, we consider that it's not a nuclei
        else:
            labels.append(fixedLabel)

    logging("Discarded due to their size: " + str(discarded))

    compos.close()
    filtered = Concatenator().concatenate(labels, False)
    
    for img in labels:
        img.close()

    assembled = ZProjector.run(filtered, "max all")
    filtered.close()
    
    return assembled


## @brief Function launching the filtering of labels on a given frame and adding it to the frame buffer.
## @param index: Index of the frame to process.
## @param original: The original animation containing all frames.
## @param frames: Buffer in which processed frames will be written.
def buildAFrame(index, original, frames):

    # We split the first frame from the animation
    frame = Duplicator().run(original, 1, 1, 1, 1, index, index)
    filteredLabels = filterLabels(frame)
    frame.close()

    # Pick the new working frame
    stack = filteredLabels.getImageStack()
    stackIndex = filteredLabels.getStackIndex(1, 1, 1)

    pFrame = stack.getProcessor(stackIndex) # Image processor for a precise slice

    frames.addSlice(str(frames.getSize()), pFrame)
    filteredLabels.close()


## @brief Launches the filtering of labels on each frame and reassembles the result.
## @param original: The original, not labelled image (result from LabKit without the 'outline' class).
## @return The fully labelled animation.
def launchFilteringLabels(original):
    frames = ImageStack(original.getWidth(), original.getHeight())
    
    # Forcer la conversion en frames plutôt que slices.
    if original.getNSlices() > 1:
        original.setDimensions(1, original.getNFrames(), original.getNSlices())

    for fIndex in range(1, original.getNFrames()+1):
        buildAFrame(fIndex, original, frames)

    result = ImagePlus("Animation", frames)

    if result.getNSlices() > 1:
        result.setDimensions(1, result.getNFrames(), result.getNSlices())

    return result



## @brief Track objects over a sequence of labeled frames.
## @parap labeledFrames A sequence of 1-slice deep images considered like frames.
## @return A sequence of the same size as the input, but labels are supposed to be consistant in time.
def labelsTracking(labeledFrames):
    reload(sys)
    sys.setdefaultencoding('utf-8')

    model = Model()
    model.setLogger(Logger.VOID_LOGGER) # Kill logging

    settings = Settings(labeledFrames)

    # Configure detector - We use the Strings for the keys
    settings.detectorFactory = LabeImageDetectorFactory()
    settings.detectorSettings = {
        'TARGET_CHANNEL' : 1,
        'SIMPLIFY_CONTOURS': False
    }  

    # Configure tracker - We want to allow merges and fusions
    settings.trackerFactory = SparseLAPTrackerFactory()
    settings.trackerSettings = LAPUtils.getDefaultLAPSettingsMap()

    settings.trackerSettings['LINKING_MAX_DISTANCE'] = 80.0
    settings.trackerSettings['ALLOW_GAP_CLOSING'] = False
    settings.trackerSettings['ALLOW_TRACK_SPLITTING'] = False
    settings.trackerSettings['ALLOW_TRACK_MERGING'] = False

    settings.addAllAnalyzers()

    trackmate = TrackMate(model, settings)

    if not trackmate.checkInput():
        sys.exit(str(trackmate.getErrorMessage()))

    if not trackmate.process():
        sys.exit(str(trackmate.getErrorMessage()))

    exportSpotsAsDots = False
    exportTracksOnly = False
    beUseless = False
    
    # This function doesn't match its documentation in any version. The last boolean is unknown but outputs a binary mask when True...
    return LabelImgExporter.createLabelImagePlus(trackmate, exportSpotsAsDots, exportTracksOnly, beUseless)


## @brief Launches all the procedures required to post-process the animation coming from LabKit.
## @param rawSeg The image as it is produced by LabKit.
## @return The cleaned, labelled and segmented animation.
def postProcessSegmentation(rawSeg):
    if globalVars['exportPath'] is not None:
        IJ.saveAs(rawSeg, "tiff", os.path.join(globalVars['exportPath'], globalVars['baseName']+"_rawseg.tif"))

    rs = rawSeg.duplicate()
    rawSeg.close()
    rawSeg = rs
    logging(">>> Starting postprocessing")
    logging("Removing outline from segmentation")
    ReplaceLabelValues().process(rawSeg, [2], 0)
    logging("Filtering rough labels")
    filteredLabels = launchFilteringLabels(rawSeg)
    logging("Tracking labels across frames")

    if globalVars['exportPath'] is not None:
        IJ.saveAs(filteredLabels, "tiff", os.path.join(globalVars['exportPath'], globalVars['baseName']+"_early.tif"))
    
    tracked = labelsTracking(filteredLabels).duplicate()
    filteredLabels.close()
    rawSeg.close()
    logging("Removing border labels")
    IJ.run(tracked, "Remove Border Labels", "left right top bottom")
    clean = IJ.getImage()
    tracked.close()
    return clean


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                             #
#       AGGREGATE DATA FROM LABELS                                            #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


def makeCleanExport(image, discarded, labels):
    # Check la bit-depth de l'image
    ReplaceLabelValues().process(image, discarded, 0)
    labels = [int(i) for i in labels if i != 'BG']
    labels.sort()
    mapping = {}

    for current, l in enumerate(labels):
        ReplaceLabelValues().process(image, [l], current+1)
        mapping[l] = current + 1

    mapping['BG'] = 'BG'

    IJ.run(image, "8-bit", "")
    return mapping


## @brief Creates statistics over the fluorescence of nuclei in the data's channel.
## @param segmentation: An animation representing tracked labels.
## @param data: The animation of the data channel.
## @return A dictionary, exportable as a JSON, representing the evolution of fluorescence over time.
def aggregateValuesFromLabels(segmentation, data):
    
    logging(">>> Building statistics for: {0}".format(globalVars['baseName']))

    segStack  = segmentation.getImageStack()
    dataStack = data.getImageStack()
    stats = {}
    nFms = segmentation.getNFrames()

    for f in range(1, nFms+1):
        index = segmentation.getStackIndex(1, 1, f)
        segFrame  = segStack.getProcessor(index)
        dataFrame = dataStack.getProcessor(index)
        labelsData = {}

        for c in range(segmentation.getWidth()):
            for l in range(segmentation.getHeight()):
                lbl = segFrame.get(c, l)

                if lbl == 0:
                    lbl = 'BG'
                
                val = dataFrame.get(c, l)
                labelsData.setdefault(lbl, []) 
                labelsData[lbl].append(val)

        for lbl, data in labelsData.items():
            data.sort()
            stats.setdefault(lbl, [])
            stats[lbl].append({
                'min': data[0],
                'max': data[-1],
                'Q1': data[int(len(data)/4)],
                'Q3': data[3*int(len(data)/4)],
                'med': data[int(len(data)/2)],
                'avg': sum(data) / len(data),
                'area': len(data)
            })
        
    toBeDeleted = []
    logging("Checking labels consistency overtime.")

    for lbl, data in stats.items():
        if lbl == 'BG':
            continue
        if len(data) != nFms:
            toBeDeleted.append(lbl)
            continue
        for i in range(len(data)-1):
            # If the difference of area between two frames is too big, two cells were probably aggregated.
            if abs(data[i]['area'] - data[i+1]['area']) > data[i]['area'] * 0.25:
                toBeDeleted.append(lbl)
                break


    if len(toBeDeleted) > 0:
        logging("Labels discarded: {0}".format(str(toBeDeleted)))
    
    for lbl in toBeDeleted:
        del stats[lbl]

    logging("Cleaning tracked image")

    mapping = makeCleanExport(segmentation, toBeDeleted, stats.keys())
    if globalVars['exportPath'] is not None:
        IJ.saveAsTiff(segmentation, os.path.join(globalVars['exportPath'], globalVars['baseName'] + '_cleanTracked.tif'))

    cleanStats = {}
    for key, item in stats.items():
        cleanStats[mapping[key]] = item

    return cleanStats


## @brief Takes a dictionary of stats built by aggregateValuesFromLabels() and formats it in a JSON form before exporting it.
## @param stats The output of aggregateValuesFromLabels()
def exportAsJSON(stats):
    pathJSON = os.path.join(globalVars['exportPath'], globalVars['baseName']+"_stats.json")
    logging("Exporting data to: {0}".format(pathJSON))
    data = json.dumps(stats, indent=4)

    fJSON = open(pathJSON, 'w')
    fJSON.write(data)
    fJSON.close()


## @brief Takes a dictionary of stats built by aggregateValuesFromLabels() and formats it in a CSV form before exporting it.
## @param stats The output of aggregateValuesFromLabels()
def exportAsCSV(stats):
    pathCSV = os.path.join(globalVars['exportPath'], globalVars['baseName']+"_stats.csv")
    logging("Exporting data to: {0}".format(pathCSV))
    fCSV = open(pathCSV, 'w')

    nextRow = True
    index = -1

    lines = []
    lineIndex = -1

    if len(stats.values()) == 0:
        fCSV.close()
        return

    while lineIndex < len(stats.values()[0]):
        line = []
        for label, frames in stats.items():
            if lineIndex < 0:
                suffix = "_{0}".format(str(label).zfill(3))
                line += [c+suffix for c in frames[0].keys()]
            else:
                line += frames[lineIndex].values()

        lines.append(", ".join([str(s) for s in line])+'\n')
        lineIndex += 1
    
    for line in lines:
        fCSV.write(str(line))
    
    fCSV.close()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                             #
#       GENERAL                                                               #
#                                                                             #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


## @brief Writes the argument in all the selected logging descriptor.
## @param txt A string representing the text to be logged.
def logging(txt):
    if globalVars['logsFile'] is not None:
        globalVars['logsFile'].write(txt)
        globalVars['logsFile'].write('\n')
    if globalVars['showLogs']:
        IJ.log(txt)


## @brief Creates the folder in which all exports will be performed. This folder is necessarily located next the processed image.
## @param imgPath The path of the image being processed.
## @return True
def createExportPath(imgPath):
    global globalVars

    root = ""

    if (imgPath is None) or (not os.path.isfile(imgPath)):
        root = IJ.getDirectory('home')
    else:
        root, imName = os.path.split(imgPath)
    
    ep = os.path.join(root, "statistics")
    if not os.path.isdir(ep):
        os.mkdir(ep)
    globalVars['exportPath'] = ep
    logging("Results will be exported in the folder: {0}".format(ep))

    if globalVars['useLogs']:
        l_path = os.path.join(ep, "logs.txt")
        globalVars['logsFile'] = open(l_path, 'w')

    return True


## @brief Updates the export base path according to the currently processed image.
## @param imgPath The full path of an image. The head will be used to build the name.
def updateBaseName(imgPath):
    root, imName = os.path.split(imgPath)
    globalVars['baseName'] = imName.split('.')[0].replace(' ', '_')


## @brief Opens a GUI dialog asking the user to set his preferences. Can be skipped if a dict was passed to the function.
## @param userVals A dictionary of settings (using defaults if empty). If None, opens the dialog.
## @return False if the dialog was aborted, True otherwise.
def askOptions(userVals):

    if userVals is not None:
        for key, val in userVals:
            globalVars[key] = val

        return True
    
    else:
        gui = GenericDialog("Settings")

        gui.addNumericField("Tolerated size: ", globalVars['toleratedSize'], 0)

        gui.addChoice("Export format", ["JSON", "CSV"], globalVars['format'])
        gui.addCheckbox("Process entire folder", globalVars['processFolder'])
        
        gui.addMessage("-- Logging --")
        gui.addCheckbox("Export logs", globalVars['useLogs'])
        gui.addCheckbox("Show logs", globalVars['showLogs'])

        gui.showDialog()

        if gui.wasOKed():
            globalVars['toleratedSize'] = max(0, int(gui.getNextNumber()))
            globalVars['format'] = gui.getNextChoice()
            globalVars['processFolder'] = gui.getNextBoolean()
            globalVars['useLogs'] = gui.getNextBoolean()
            globalVars['showLogs'] = gui.getNextBoolean()

            return True
    
    logging("Export format: {0}".format(globalVars['format']))
    logging("Process whole folder: {0}".format(str(globalVars['processFolder'])))

    return False


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#    SEQUENCE OF OPERATIONS                                                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


def justPreprocess():
    gui = GenericDialog("Preprocessing")

    gui.addChoice("Target", WindowManager.getImageTitles(), "")

    gui.showDialog()

    if not gui.wasOKed():
        return (None, None)

    title = gui.getNextChoice()
    target = WindowManager.getImage(title)

    width, height, nChannels, nSlices, nFrames = target.getDimensions()

    target.getCalibration().setXUnit("um");
    target.getCalibration().setYUnit("um");
    target.getCalibration().setZUnit("um");
    IJ.run(target, "Properties...", "channels={0} slices={1} frames={2} pixel_width={3} pixel_height={4} voxel_depth={5} frame=[{6} {7}]".format(nChannels, nSlices, nFrames, dimensions['vWidth'], dimensions['vHeight'], dimensions['vDepth'], dimensions['frameInterval'], dimensions['timeUnit']))

    globalVars['baseName'] = title.split('.')[0] # Removing extension

    return preprocessRawImage(target)



def justSegmentAndClean():
    gui = GenericDialog("Segmentation")

    gui.addChoice("Target", WindowManager.getImageTitles(), "")
    gui.addStringField("Classifier", IJ.getDirectory('home'), 30)

    gui.showDialog()

    if not gui.wasOKed():
        return None

    title = gui.getNextChoice()
    target = WindowManager.getImage(title)

    globalVars['classiPath'] = gui.getNextString()
    globalVars['baseName'] = title.split('.')[0] # Removing extension

    return labkitSegmentation(target, globalVars['classiPath'])



def justTrack():
    gui = GenericDialog("Postprocess + Tracking")

    gui.addChoice("Target", WindowManager.getImageTitles(), "")
    gui.addNumericField("Tolerated size: ", globalVars['toleratedSize'], 0)

    gui.showDialog()

    if not gui.wasOKed():
        return None

    title = gui.getNextChoice()
    globalVars['toleratedSize'] = max(0, int(gui.getNextNumber()))
    target = WindowManager.getImage(title)

    globalVars['baseName'] = title.split('.')[0] # Removing extension

    return postProcessSegmentation(target)


def justMakeStats():
    gui = GenericDialog("Make statistics")

    gui.addChoice("Segmentation", WindowManager.getImageTitles(), "")
    gui.addChoice("Data", WindowManager.getImageTitles(), "")
    gui.addChoice("Format", ['JSON', 'CSV'], globalVars['format'])
    gui.addStringField("Export path", "", 30)

    gui.showDialog()

    if not gui.wasOKed():
        return None

    segTitle = gui.getNextChoice()
    dataTitle = gui.getNextChoice()
    globalVars['format'] = gui.getNextChoice()
    globalVars['exportPath'] = gui.getNextString()

    seg = WindowManager.getImage(segTitle)
    data = WindowManager.getImage(dataTitle)

    globalVars['baseName'] = segTitle.split('.')[0]

    return aggregateValuesFromLabels(seg, data)


def launchAnOperation():
    gui = GenericDialog("Launcher")

    gui.addChoice("Operation", ['Everything', 'Preprocess', 'Segmentation', 'Postprocess + Tracking', 'Statistics'], 'Everything')
    gui.addCheckbox("Show logs", globalVars['showLogs'])

    gui.showDialog()

    if not gui.wasOKed():
        return None

    choice = gui.getNextChoice()
    globalVars['showLogs'] = gui.getNextBoolean()
    globalVars['useLogs']  = False
    globalVars['exportPath'] = None

    if choice == 'Everything':
        return segTrackAndStats()

    elif choice == 'Preprocess':
        seg, data = justPreprocess()
        if seg is None:
            return -1
        seg.setTitle("segmentation")
        data.setTitle("data")
        seg.show()
        data.show()

    elif choice == 'Segmentation':
        seg = justSegmentAndClean()
        if seg is None:
            return -2
        seg.setTitle("labkit_out")
        seg.show()

    elif choice == 'Postprocess + Tracking':
        tr = justTrack()
        if tr is None:
            return None
        tr.setTitle("tracked")
        tr.show()

    elif choice == 'Statistics':
        stats = justMakeStats()

        if stats is None:
            return -2

        if globalVars['format'] == 'JSON':
            exportAsJSON(stats)
        else:
            exportAsCSV(stats)
    
    return 0


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#    MAIN                                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


## @brief Function launching the whole procedure. Possibility to specify parameters if GUI must be skiped.
## @param imgPath The path of the image on which we want to apply the process.
## @param classifierPath The path of the classifier to use to segment the desired image.
## @param settings Dictionary of settings to skip the GUI menu asking for them. Available keys: 'processFolder', 'useLogs', 'showLogs', 'format'
## @return 0 on success or a negative number if an error happened and the function was aborted.
def segTrackAndStats(imgPath=None, classifierPath=None, settings=None):

    path = askForPath(imgPath)
    if path is None:
        return -1

    globalVars['classiPath'] = acquireClassifier(classifierPath)
    if globalVars['classiPath'] is None:
        return -2

    if not askOptions(settings):
        return -3
    
    queue = buildQueue(path)
    createExportPath(path)
    logging("Processing queue: {0}".format(str(queue)))

    errorCode = 0

    for filePath in queue:
        logging("========== Processing file: {0} ==========".format(filePath))

        if filePath is None:
            logging("None found in processind queue. Continuing")
            continue

        rawImage = acquireImage(filePath)
        if rawImage is None:
            logging("Working image couldn't be open. Abort.")
            errorCode -= 1
            continue
        
        updateBaseName(filePath)

        segmentation, data = preprocessRawImage(rawImage)
        if (segmentation is None) or (data is None):
            logging("Failed to preprocess the input image. Abort.")
            errorCode -= 2
            continue

        rawSegmentation = labkitSegmentation(segmentation, globalVars['classiPath'])
        if rawSegmentation is None:
            logging("Failed to compute rough segmentation through LabKit")
            errorCode -= 3
            continue
        
        cleanSegmentation = postProcessSegmentation(rawSegmentation)

        if globalVars['exportPath'] is not None:
            IJ.saveAsTiff(cleanSegmentation, os.path.join(globalVars['exportPath'], globalVars['baseName'] + '_rawTracked.tif'))
        
        stats = aggregateValuesFromLabels(cleanSegmentation, data)
        
        logging("Exporting statistics for: {}".format(globalVars['baseName']))
        if globalVars['format'] == 'JSON':
            exportAsJSON(stats)
        else:
            exportAsCSV(stats)

        cleanSegmentation.close()

    if globalVars['useLogs']:
        globalVars['logsFile'].close()
    
    return errorCode



#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#
# | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | | #
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#



if launchAnOperation() < 0:
    IJ.log("Something went wrong. Aborted")
else:
    IJ.log("DONE.")


