from ij import IJ
from ij import WindowManager
from ij.measure import ResultsTable
from fr.cnrs.mri.cialib.kinetochores import CellposeSegmenter
from fr.cnrs.mri.cialib.kinetochores import LabKitSpotSegmenter
from fr.cnrs.mri.cialib.kinetochores import KinetochoreAnalyzer
from fr.cnrs.mri.cialib.options import Options
from fr.cnrs.mri.cialib.dialog import OptionsDialog


SIGNAL_CHANNEL = 1
KINETOCHORES_CHANNEL = 2
CELL_CHANNEL = 1
DIAMETER = 50
CONDA_ENV_PATH = "/home/baecker/miniforge3/envs/cellpose3-napari"
MODEL_PATH = "/home/baecker/.cellpose/models/size_cyto3.npy"
CLASSIFIER_PATH = "/home/baecker/Documents/mri/in/2026/open-desk/2026-09-24/kinetochore.classifier"
SPOT_LABEL = 2
USE_GPU = True



def main():
    options = getOptions()
    dialog = OptionsDialog(options)
    if not dialog.showOptions():
        return

    image = IJ.getImage()
    IJ.log("Running analyze kinetochores on " + image.getTitle() + "...")
    IJ.log(options.asString())

    tableTitle = "Kinetochore Measurements"
    table = WindowManager.getWindow(tableTitle)
    if table:
        table = table.getResultsTable()
    else:
        table = ResultsTable()

    cellSegmenter = getCellSegmenter(options)
    spotSegmenter = getSpotSegmenter(options)
    analyzer = KinetochoreAnalyzer(cellSegmenter, spotSegmenter, image, options=options)
    analyzer.table = table
    analyzer.run()
    analyzer.controlImage.show()
    analyzer.table.show(tableTitle)
    IJ.log("Kinetochore analysis finished.")


def getCellSegmenter(options):
    segmenter = CellposeSegmenter(options=options)
    return segmenter


def getSpotSegmenter(options):
    segmenter = LabKitSpotSegmenter(options=options)
    return segmenter


def getOptions():
    options = Options("kinetochore analyzer", "Analyze Image")
    options.addInt("signal channel", value=SIGNAL_CHANNEL)
    options.addInt("kinetochore channel", value=KINETOCHORES_CHANNEL)
    options.addInt("cell channel", value=CELL_CHANNEL)
    options.addInt("cell diameter", value=DIAMETER)
    options.addFile("conda env path", value=CONDA_ENV_PATH, transient=False)
    options.addFile("model path", value=MODEL_PATH, transient=False)
    options.addFile("labkit classifier path", value=CLASSIFIER_PATH, transient=False)
    options.addInt("spot label", value=SPOT_LABEL)
    options.addChoice("background subtraction value", value="mean", choices=["mean", "max", "mode", "median"])
    options.addBool("use gpu", value=USE_GPU)
    options.load()
    return options


main()