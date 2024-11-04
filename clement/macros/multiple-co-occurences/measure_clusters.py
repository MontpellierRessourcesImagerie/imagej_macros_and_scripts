import os
from ij import IJ
from ij.measure import ResultsTable
from inra.ijpb.binary import BinaryImages
from inra.ijpb.measure import IntrinsicVolumes3D
from inra.ijpb.label import LabelImages


_INPUT_FOLDER    = "/home/baecker/Documents/mri/in/2064 - multiple cooccurence/t5-out/"
CONNECTIVITY = 26
BIT_DEPTH = 16
PIXEL_WIDTH = 0.179
VOXEL_DEPTH = 0.5
UNIT = "micron"
N_DIRS = 13
_TABLE_NAME = "cluster size"


def main():
    all_dirs = os.listdir(_INPUT_FOLDER)    
    print(all_dirs)
    rt = ResultsTable.getResultsTable(_TABLE_NAME) or ResultsTable()
    rt.showRowNumbers (True)
    names = []
    volumeMeasurements = []
    areaMeasurements = []
    channels = []
    for folder in all_dirs:
        path = os.path.join(_INPUT_FOLDER, folder)
        masks = os.listdir(path)
        for channelIndex, mask in enumerate(masks):
            maskPath = os.path.join(path, mask)
            image = IJ.openImage(maskPath)
            calibration = image.getCalibration()
            calibration.pixelWidth = PIXEL_WIDTH
            calibration.pixelHeight = PIXEL_WIDTH
            calibration.pixelDepth = VOXEL_DEPTH         
            calibration.setUnit(UNIT)         
            labels = BinaryImages.componentsLabeling(image, CONNECTIVITY, BIT_DEPTH)        
            numbers = LabelImages.findAllLabels(labels)
            volumes = IntrinsicVolumes3D.volumes(labels.getStack(), numbers, labels.getCalibration())
            areas = IntrinsicVolumes3D.surfaceAreas(labels.getStack(), numbers, labels.getCalibration(), N_DIRS)
            for area, volume in zip(areas, volumes):
                names.append(folder)
                channels.append(channelIndex + 1)
                volumeMeasurements.append(volume)
                areaMeasurements.append(area)
    for name, channel, volume, area in zip(names, channels, volumeMeasurements, areaMeasurements):
        rt.addRow()
        line = rt.size() - 1
        rt.setValue("name", line, name)
        rt.setValue("channel", line, channel)
        rt.setValue("volume", line, volume)
        rt.setValue("surface area", line, area)
    rt.show(_TABLE_NAME)
     
     
main()