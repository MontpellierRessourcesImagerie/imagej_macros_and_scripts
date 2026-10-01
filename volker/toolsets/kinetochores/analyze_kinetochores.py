from ij import IJ
from fr.cnrs.mri.kinetochores import CellposeSegmenter
from fr.cnrs.mri.kinetochores import LabKitSpotSegmenter
from fr.cnrs.mri.kinetochores import KinetochoreAnalyzer


SIGNAL_CHANNEL = 1
KINETOCHORES_CHANNEL = 2
DIAMETER = 50
CONDA_ENV_PATH = "/home/baecker/miniforge3/envs/cellpose3-napari"
MODEL_PATH = "/home/baecker/.cellpose/models/size_cyto3.npy"
CLASSIFIER_PATH = "/home/baecker/Documents/mri/in/2026/open-desk/2026-09-24/kinetochore.classifier"
SPOT_LABEL = 2
USE_GPU = True


def main():
    image = IJ.getImage()
    cellSegmenter = getCellSegmenter()
    spotSegmenter = getSpotSegmenter()
    analyzer = KinetochoreAnalyzer(cellSegmenter, spotSegmenter, image)
    analyzer.cellChannelNr = SIGNAL_CHANNEL
    analyzer.signalChannelNr = SIGNAL_CHANNEL
    analyzer.kinetochoreChannelNr = KINETOCHORES_CHANNEL
    analyzer.spotLabel = SPOT_LABEL
    analyzer.run()
    analyzer.cellLabels.show()
    analyzer.kinetochoreMask.show()
    analyzer.signalMask.show()
    

def getCellSegmenter():
    segmenter = CellposeSegmenter()
    segmenter.env_path = CONDA_ENV_PATH
    segmenter.env_type = "conda"
    segmenter.model = "cyto"
    segmenter.model_path = MODEL_PATH
    segmenter.diameter = DIAMETER
    segmenter.useGPU = USE_GPU
    segmenter.ch1 = 0
    segmenter.ch2 = 0
    return segmenter


def getSpotSegmenter():
    segmenter = LabKitSpotSegmenter(CLASSIFIER_PATH)
    segmenter.useGPU = USE_GPU
    return segmenter



main()