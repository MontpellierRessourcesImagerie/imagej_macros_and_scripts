from __future__ import with_statement, division, print_function

from ij import IJ, WindowManager, ImagePlus, ImageStack
from ij.gui import GenericDialog
from ij.io import OpenDialog
from ij.plugin import ChannelSplitter, ZProjector, Concatenator, Duplicator
from inra.ijpb.label.edit import ReplaceLabelValues
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
import os
import json
import sys
import logging

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
    'lengthUnit': "µm",
    'frameInterval': 15,
    'timeUnit': "min"
}

globalVars = {
    'classiPath': None,
    'useGpu': False,
    'exportPath': "",
    'baseName': "",
    'processFolder': False,
    'useLogs': True,
    'logsFile': None,
    'generateHTML': True,
    'format': 'JSON'
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

    logging.debug("Focus infos: " + str(acceptedRange))

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
    else:
        dataPath = path

    logging.debug("Path selected by the user: {0}".format(dataPath))

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
        logging.debug("Failed to open image: {0}".format(path))
        return None

    width, height, nChannels, nSlices, nFrames = rawImage.getDimensions()

    rawImage.getCalibration().setXUnit("µm");
    rawImage.getCalibration().setYUnit("µm");
    rawImage.getCalibration().setZUnit("µm");
    
    IJ.run(rawImage, "Properties...", "channels={0} slices={1} frames={2} pixel_width={3} pixel_height={4} voxel_depth={5} frame=[{6} {7}]".format(nChannels, nSlices, nFrames, dimensions['vWidth'], dimensions['vHeight'], dimensions['vDepth'], dimensions['frameInterval'], dimensions['timeUnit']))

    return rawImage


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
        logging.debug("LabKit classifier expected with 'classifier' extension (\"some_name.classifier\")")
        return None
    
    logging.debug("Classifier in use: {0}".format(dataPath))

    return dataPath


## @brief Preprocessing necessary before being able to segment the image.
## @param rawImage: Image as it was opened from the disk.
## @return A tuple containing the preprocessed segmentation channel and the raw data channel.
def preprocessRawImage(rawImage):
    logging.debug("Starting preprocessing")
    # 1. Splitting channels and closing original image
    if rawImage.getNChannels() != 2:
        logging.debug("Only two channeled images are handled (1:segmentation, 2:data)")
        return (None, None)
    
    segmentationChannel, dataChannel = ChannelSplitter.split(rawImage)
    rawImage.close()

    # 2. Applying median blur to each channel
    IJ.run(segmentationChannel, "Median 3D...", "x=5 y=5 z=1.5")
    IJ.run(dataChannel, "Median 3D...", "x=5 y=5 z=1.5")

    # 3. Ditching out-of-focus slices
    inFocusInfos = getFocusInfos(zProfileOverLaplacian(segmentationChannel), 0.3)
    segmentationChannel = keepInFocusSlices(inFocusInfos, segmentationChannel)

    # 4. Z-projection (max intensity)
    segmentationChannel = ZProjector.run(segmentationChannel, "max all")
    dataChannel = ZProjector.run(dataChannel, "max all")

    # 5. Enhance contrast and normalize between 0 and 1 (32-bits)
    IJ.run(segmentationChannel, "Enhance Contrast...", "saturated=0.35 normalize process_all")
    IJ.run(segmentationChannel, "32-bit", "")
    IJ.run(segmentationChannel, "Divide...", "value=65535 stack");

    return (segmentationChannel, dataChannel)



## @brief Launches LabKit and attempts to produce a rough segmentation of the image.
## @param segmentation: The preprocessed channel as produced by preprocessRawImage
## @param classifierPath: The path to the classifier suitable to segment this image.
## @return The segmentation produced by LabKit.
def labkitSegmentation(segmentation, classifierPath):
    logging.debug("Starting LabKit automatic segmentation")
    segmentation.show() # Mandatory to get LabKit working...
    try:
        IJ.run(segmentation, "Segment Image With Labkit", "segmenter_file={0} use_gpu={1}".format(classifierPath, "true" if globalVars['useGpu'] else "false"));
    except:
        logging.debug("Failed to launch LabKit")
        return None
    
    segmentationVirtual = IJ.getImage()
    rawSegmentation = segmentationVirtual.duplicate()
    segmentationVirtual.close()
    segmentation.close()

    return rawSegmentation


## @brief Filters all the labels contained on a frame by applying multiple transformations.
## @param frame A frame (1 image of 1 channel, 1 slice, 1 frame) containing labels
## @return A new image representing the input frame but with labels filtered and fixed.
def filterLabels(frame):
    IJ.run(frame, "Connected Components Labeling", "connectivity=4 type=[16 bits]")
    compos = IJ.getImage()
    
    labels = []

    stats = compos.getStatistics()

    for i in range(int(stats.histMin), int(stats.histMax)):
        
        if stats.histogram16[i] < 6500:
            continue # If the component is less than 7000 pixels of area, we consider that it's not a nuclei
        
        IJ.run(compos, "Select Label(s)", "label(s)={0}".format(i))
        isolatedLabel = IJ.getImage()

        IJ.run(isolatedLabel, "Morphological Filters", "operation=Closing element=Disk radius=20")
        fixedLabel = IJ.getImage()
        isolatedLabel.close()
        labels.append(fixedLabel)

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


def labelsTracking(labeledFrames):
    reload(sys)
    sys.setdefaultencoding('utf-8')

    model = Model()
    model.setLogger(Logger.VOID_LOGGER) # Rediriger vers un fichier ou None

    #------------------------
    #  SETTINGS
    #------------------------

    settings = Settings(labeledFrames)

    # Configure detector - We use the Strings for the keys
    settings.detectorFactory = LabeImageDetectorFactory()
    settings.detectorSettings = {
        'TARGET_CHANNEL' : 1,
        'SIMPLIFY_CONTOURS': False
    }  

    # Configure spot filters - Classical filter on quality
    # filter1 = FeatureFilter('QUALITY', 30, True)
    # settings.addSpotFilter(filter1)

    # Configure tracker - We want to allow merges and fusions
    settings.trackerFactory = OverlapTrackerFactory()
    settings.trackerSettings['SCALE_FACTOR'] = 1.0
    settings.trackerSettings['MIN_IOU'] = 0.3
    settings.trackerSettings['IOU_CALCULATION'] = 'PRECISE'


    # Add ALL the feature analyzers known to TrackMate. They will 
    # yield numerical features for the results, such as speed, mean intensity etc.
    settings.addAllAnalyzers()


    #-------------------
    # Instantiate plugin
    #-------------------

    trackmate = TrackMate(model, settings)

    #--------
    # Process
    #--------

    ok = trackmate.checkInput()
    if not ok:
        sys.exit(str(trackmate.getErrorMessage()))

    ok = trackmate.process()
    if not ok:
        sys.exit(str(trackmate.getErrorMessage()))


    #----------------
    # Display results
    #----------------


    exportSpotsAsDots = False
    exportTracksOnly = True
    beUseless = False
    
    # This function doesn't match its documentation in any version, the last boolean is unknown...
    return LabelImgExporter.createLabelImagePlus(trackmate, exportSpotsAsDots, exportTracksOnly, beUseless)



## @brief Launches all the procedures required to post-process the animation coming from LabKit.
## @return The cleaned, labelled and segmented animation.
def postProcessSegmentation(rawSeg):
    logging.debug("Starting postprocessing")
    ReplaceLabelValues().process(rawSeg, [2], 0)
    filteredLabels = launchFilteringLabels(rawSeg)
    tracked = labelsTracking(filteredLabels).duplicate()
    filteredLabels.close()
    rawSeg.close()
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

## @brief Creates statistics over the fluorescence of nuclei in the data's channel.
## @param segmentation: An animation representing tracked labels.
## @param data: The animation of the data channel.
## @return A dictionary, exportable as a JSON, representing the evolution of fluorescence over time.
def aggregateValuesFromLabels(segmentation, data):
    
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

                if lbl == 0: # Skip BG
                    continue
                
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
                'median': data[int(len(data)/2)],
                'average': sum(data) / len(data)
            })
        
    toBeDeleted = []
    if len(toBeDeleted) > 0:
        logging.debug("Labels discarded: {0}".format(str(toBeDeleted)))

    for lbl, data in stats.items():
        if len(data) != nFms:
            toBeDeleted.append(lbl)
    
    for lbl in toBeDeleted:
        del stats[lbl]

    return stats


def exportAsJSON(stats):
    pathJSON = os.path.join(globalVars['exportPath'], globalVars['baseName']+"_stats.json")
    logging.debug("Exporting data to: {0}".format(pathJSON))
    data = json.dumps(stats, indent=4)

    fJSON = open(pathJSON, 'w')
    fJSON.write(data)
    fJSON.close()


def exportAsCSV(stats):
    pathCSV = os.path.join(globalVars['exportPath'], globalVars['baseName']+"_stats.csv")
    logging.debug("Exporting data to: {0}".format(pathCSV))
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
    logging.debug("Results will be exported in the folder: {0}".format(ep))

    if globalVars['useLogs']:
        logging.basicConfig(filename=os.path.join(ep, "logs.txt"), level=logging.DEBUG)

    return True


def updateBaseName(imgPath):
    root, imName = os.path.split(imgPath)
    globalVars['baseName'] = imName.split('.')[0].replace(' ', '_')


def askOptions():
    gui = GenericDialog("Settings")

    gui.addChoice("Export format", ["JSON", "CSV"], globalVars['format'])
    gui.addCheckbox("Process entire folder", globalVars['processFolder'])
    gui.addCheckbox("Export logs", globalVars['useLogs'])
    #gui.addCheckbox("Generate HTML", globalVars['generateHTML'])

    gui.showDialog()

    if gui.wasOKed():
        globalVars['format'] = gui.getNextChoice()
        globalVars['processFolder'] = gui.getNextBoolean()
        globalVars['useLogs'] = gui.getNextBoolean()

        logging.debug("Export format: {0}".format(globalVars['format']))
        logging.debug("Process whole folder: {0}".format(str(globalVars['processFolder'])))
        #globalVars['generateHTML'] = gui.getNextBoolean()


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#    MAIN                                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #



def main():

    path = askForPath()
    globalVars['classiPath'] = acquireClassifier(globalVars['classiPath'])
    askOptions()
    queue = buildQueue(path)
    createExportPath(path)
    logging.debug("Processing queue: {0}".format(str(queue)))

    for filePath in queue:
        logging.debug("======== Processing file: {0} ========".format(filePath))
        rawImage = acquireImage(filePath)
        updateBaseName(filePath)

        segmentation, data = preprocessRawImage(rawImage)
        rawSegmentation = labkitSegmentation(segmentation, globalVars['classiPath'])
        cleanSegmentation = postProcessSegmentation(rawSegmentation)
        IJ.saveAsTiff(cleanSegmentation, os.join(globalVars['exportPath'], globalVars['baseName'] + '_tracked.tif'))
        stats = aggregateValuesFromLabels(cleanSegmentation, data)
        
        logging.debug("Exporting statistics for: {}".format(globalVars['baseName']))
        if globalVars['format'] == 'JSON':
            exportAsJSON(stats)
        else:
            exportAsCSV(stats)

        cleanSegmentation.close()

    return 0



#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#


main()



#
#   ==================================================  NOTES  ==================================================
#
# - Channels have to be splitted before the projection, otherwise channels influence each other for some reason.
# - Using a Laplacian with a Min projection and averaging it with the Max projection of the original channel gives something unstable.
#	
#	==================================================  TO DO  ==================================================
#
# - [X] Mettre à jour le temps d'interframe dans les images.
# - [X] Scripting Trackmate: https://imagej.net/plugins/trackmate/scripting
# - [X] Voir s'il n'y a pas quelque chose à faire avec le Laplacien de la couche de segmentation...
# - [X] Retrain un classifier avec ces données précises, en faire d'autres avec d'autres segmentation maps.
# - [ ] Faire un script qui inspecte la rondeur des formes extraites, pour retirer les pointes de pixels qui apparaissent.
#       On peut chercher à faire une enveloppe autour de chaque label en un nombre limité de points, et ne garder que ce qui est dedans.
#       Ca nécessite de construire un dictionnaire des labels, ou de maintenir un state pour chaque état.
#       Mesurer les variations de distance entre le centroid et les points et retirer les points avec une trop forte variation.
# - [X] Entrainer un autre classifier sur une image générée avec le script qui détecte l'arrivée au focus.
# - [X] Passer le chemin à ouvrir comme string parameter plutôt qu'en ouverture GUI pour pouvoir batcher.
#       Faire de même avec le chemin du classifier qui ne doit être demandé qu'une fois.
# - [X] Tester si la combinaison avec un Laplacian ne donne pas quelque chose de plus facile à train pour le classifier.
# - [X] La projection peut avoir lieu avant qu'on split les channels.
# - [X] On peut jouer avec la std dev du Gaussian au début avant de train le classifier.
# - [X] Doit proposer un batch mode qui permet de sélectionner un fichier et de traiter tout ce qui se trouve dans le même dossier que ce fichier.
# - [ ] Sortir de meilleurs codes d'erreur quand le script doit abort.
# - [ ] Vérifier que ce script marche aussi pour les images ayant une seule frame.
# - [X] On ne va kill les borders qu'après la phase de tracking pour éviter de perturber l'opération.
# - [X] Essayer une méthode où on prend des carrés avec des thresholds locaux pour l'aasemblage.
# - [?] Générer un HTML pour la visualisation des données.
# - [X] Retirer les labels qui ne sont pas sur toutes les frames.
# - [ ] Filtrer par taille maximale les noyaux pour éviter les aggrégats.
# - [ ] Tester sur des fichiers Auxin.
# - [ ] Soustraire la valeur moyenne du BG à toutes les valeurs obtenues.
# - [X] Faire un système de logging dans un fichier.
# - [ ] Séparer le code en modules pour la propreté.
# - [ ] Aménager le script pour qu'il puisse être utilisé sans GUI, utilisé lui-même comme un module.
# - [ ] Faire plusieurs macros qui séparent le process en étapes (pour pouvoir corriger les erreurs à la main).
# - [ ] Remplacer les run() par des calls API quand c'est possible.
# - [ ] Check que les indices commencent bien à 1 et pas 0.
# - [X] Système d'export en JSON ou en CSV
# - [ ] Handle les erreurs dans le main (en cas de retour de None)
#
#	============================================  QUESTIONS THOMAS  =============================================
#
# - [ ] Est-ce que je dois soustraire la valeur moyenne du background à toutes les mesures ?
# - [ ] Y a-t-il d'autres données à exporter ? Ou sous une autre format ?
#