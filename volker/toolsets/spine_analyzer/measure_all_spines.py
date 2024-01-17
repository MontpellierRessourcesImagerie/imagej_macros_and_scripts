from ij import IJ
from ij.measure import ResultsTable
from fr.cnrs.mri.cialib.neurons import Dendrites
from fr.cnrs.mri.cialib.neurons import Spine
from fr.cnrs.mri.cialib.neurons import IntensityMeasurements
from fr.cnrs.mri.cialib.segmentation import InstanceSegmentation


image = IJ.getImage()
segmentation = InstanceSegmentation(image)
dendrites = Dendrites(segmentation)
measurements = dendrites.getMeasurements()

table = ResultsTable()
spines = {}
for channel, frameMeasurements in measurements.items():
    row = 0
    for frame, labelMeasurements in frameMeasurements.items():
        for label, values in labelMeasurements.items():
            if channel == 1:
                spine = Spine(label, image)
                spine.nrOfVoxels = values[0]
                spine.volume = values[1]
                spine.frame = frame
                spine.resetIntensityMeasurements()
                spines[(label, frame)] = spine
            else:
                spine = spines[(label, frame)]
            intensityMeasurements = IntensityMeasurements(channel)
            intensityMeasurements.intDen =  values[2]
            intensityMeasurements.meanInt =  values[3]
            intensityMeasurements.min =  values[4]
            intensityMeasurements.max =  values[5]
            intensityMeasurements.stdDev =  values[6]
            intensityMeasurements.mode =  values[7]
            intensityMeasurements.kurtosis =  values[8]
            intensityMeasurements.skewness =  values[9]
            spine.addIntensityMeasurements(intensityMeasurements)
for (label, frame), spine in spines.items():
   table.addRow()
   table.addValue("Frame", spine.frame)
   spine.addToReport(table)
if "Spine" in table.getHeadings():
    table.sort("Frame")
    table.sort("Spine")
table.show("Spines")
