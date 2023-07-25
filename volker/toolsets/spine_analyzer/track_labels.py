from ij import IJ
from ij.plugin import Duplicator
from ij.measure import Calibration
from fr.cnrs.mri.cialib.unittests.testdata import DendriteGenerator
from inra.ijpb.measure.region3d import Centroid3D
from inra.ijpb.label import LabelImages
from fr.cnrs.mri.cialib.stackutil import HyperstackUtils

MAX_DIST = 15

segmentation = DendriteGenerator().next()
segmentation.show()
width, height, nChannels, nSlices, nFrames = segmentation.image.getDimensions()
segmentation.image.setT(nFrames)
cal = segmentation.image.getCalibration()
tmpCal = Calibration()
segmentation.image.setCalibration(tmpCal)
analyzer = Centroid3D()

for frame in range(2, nFrames):
    imp = Duplicator().run(segmentation.image, nChannels, nChannels, 1, nSlices, frame, frame);            
    measurementsCurrent = analyzer.analyzeRegions(imp)
    if len(measurementsCurrent.values()) < 1:
        continue
    imp2 = Duplicator().run(segmentation.image, nChannels, nChannels, 1, nSlices, frame-1, frame-1);            
    measurementsPrevious = analyzer.analyzeRegions(imp2)
    closestLabels = {}
    for label in measurementsCurrent.keySet():
        point = measurementsCurrent.get(label)
        minDist = 9999999999999
        closestLabel = -1
        for otherLabel in measurementsPrevious.keySet():
            otherPoint = measurementsPrevious.get(otherLabel)
            dist = point.distance(otherPoint)
            if dist < MAX_DIST and dist < minDist:
                minDist = dist
                closestLabel = otherLabel
        if closestLabel > -1:
            closestLabels[label] = closestLabel
    print(closestLabels)
    for oldLabel, newLabel in closestLabels.items():
        LabelImages.replaceLabels(imp, [oldLabel], newLabel)
    HyperstackUtils.copyStackTo(segmentation.image, imp, nChannels, frame)
    
segmentation.image.setCalibration(cal)

