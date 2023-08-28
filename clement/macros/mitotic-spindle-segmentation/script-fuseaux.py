import os
from ij import IJ
from ij import ImagePlus
from ij.plugin import Duplicator
from ij.plugin.filter import BackgroundSubtracter
from ij.plugin import ImageCalculator
from ij.plugin.filter import ThresholdToSelection
from ij.gui import PolygonRoi
from ij.gui import Roi
from ij.plugin.filter import Analyzer
from ij.measure import Measurements

from inra.ijpb.label import LabelImages
from inra.ijpb.label.conncomp import FloodFillRegionComponentsLabeling

from java.awt import Color

###################  SETTINGS  ###################

_stained_channel     = 2
_rolling_ball_radius = 50
_min_size            = 90

##################################################

imIn    = IJ.getImage() # Active image.
nPlanes = imIn.getNFrames()
dup     = Duplicator()
bg_subt = BackgroundSubtracter()
ffrcl   = FloodFillRegionComponentsLabeling(8, 8)
control = IJ.createImage("control", '16-bit', imIn.getWidth(), imIn.getHeight(), 1, 1, nPlanes)
output  = IJ.getDirectory("")

print("Saving results to: " + output)

# Configure measures for analyser
Analyzer.setMeasurement(Measurements.ADD_TO_OVERLAY, False)
Analyzer.setMeasurement(Measurements.ALL_STATS, False)
Analyzer.setMeasurement(Measurements.AREA, True)
Analyzer.setMeasurement(Measurements.AREA_FRACTION, False)
Analyzer.setMeasurement(Measurements.CENTER_OF_MASS, False)
Analyzer.setMeasurement(Measurements.CENTROID, False)
Analyzer.setMeasurement(Measurements.CIRCULARITY, False)
Analyzer.setMeasurement(Measurements.ELLIPSE, True)
Analyzer.setMeasurement(Measurements.FERET, False)
Analyzer.setMeasurement(Measurements.INTEGRATED_DENSITY, True)
Analyzer.setMeasurement(Measurements.INVERT_Y, False)
Analyzer.setMeasurement(Measurements.KURTOSIS, False)
Analyzer.setMeasurement(Measurements.LABELS, False)
Analyzer.setMeasurement(Measurements.LIMIT, False)
Analyzer.setMeasurement(Measurements.MAX_STANDARDS, False)
Analyzer.setMeasurement(Measurements.MEAN, True)
Analyzer.setMeasurement(Measurements.MEDIAN, False)
Analyzer.setMeasurement(Measurements.MIN_MAX, False)
Analyzer.setMeasurement(Measurements.MODE, False)
Analyzer.setMeasurement(Measurements.NaN_EMPTY_CELLS, False)
Analyzer.setMeasurement(Measurements.PERIMETER, True)
Analyzer.setMeasurement(Measurements.RECT, False)
Analyzer.setMeasurement(Measurements.SCIENTIFIC_NOTATION, False)
Analyzer.setMeasurement(Measurements.SHAPE_DESCRIPTORS, False)
Analyzer.setMeasurement(Measurements.SKEWNESS, False)
Analyzer.setMeasurement(Measurements.SLICE, False)
Analyzer.setMeasurement(Measurements.STACK_POSITION, False)
Analyzer.setMeasurement(Measurements.STD_DEV, True)

for planeIdx in range(1, nPlanes+1):
    print("========= Processing plane: " + str(planeIdx) + "/" + str(nPlanes) + "=========")

    # 1. Isolating the working plane:
    plane = dup.run(imIn, _stained_channel, _stained_channel, 1, 1, planeIdx, planeIdx)
    control.setT(planeIdx)

    # 2. Subtracting background:
    bg_correct = plane.duplicate()
    bg_subt.rollingBallBackground(
        bg_correct.getProcessor(),
        _rolling_ball_radius,
        False,
        False,
        False,
        False,
        False
    )
    plane.close()

    # 3. Creating a thresholded image (we keep `bg_correct` clean to make our measurements later):
    proc = bg_correct.getProcessor()
    proc.setAutoThreshold('Otsu dark')
    mask = ImagePlus("mask-fuseau-"+str(planeIdx), proc.createMask())
    proc.resetThreshold()
    bg_correct.setTitle(str(planeIdx).zfill(3) + "-bg-correct")

    # 4. Create definitive mask:
    labels = ImagePlus("labeled", ffrcl.computeLabels(mask.getProcessor(), 255))
    mask.close()
    big_labels = ImagePlus("filtered", LabelImages.areaOpening(labels.getProcessor(), _min_size))
    labels.close()
    big_labels.getProcessor().setThreshold(1, 255)
    polygon = ThresholdToSelection.run(big_labels).getConvexHull()
    big_labels.close()

    roi = PolygonRoi(polygon, Roi.POLYGON)
    bg_correct.setRoi(roi)

    # 5. Measuring
    IJ.run(bg_correct, "Measure", "")
    Analyzer.getResultsTable().addValue("T", planeIdx)

    # 6. Adding the segmented outline to the control image.
    c_proc = control.getProcessor()
    c_proc.setLineWidth(2)
    c_proc.setColor(Color(0.5, 0.5, 0.5))
    c_proc.draw(roi)
    
    # 7. Save image with ROI
    IJ.saveAsTiff(bg_correct, os.path.join(output, bg_correct.getTitle()+".tif"))
    bg_correct.close()
    
control.show()
Analyzer.getResultsTable().show("Results")

""" TODO

- [X] Check if the results are better (less segmentation errors) by changing the thresholding algorithm.
- [X] Check the effect of a bigger rolling ball.
- [X] Add an output folder for control images.
- [ ] Make sure there is no memory leak left.
- [X] Create a quick control image in addition of individual ROIs.

"""
