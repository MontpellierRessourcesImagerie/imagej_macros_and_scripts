import os
import datetime
import traceback
from ij import IJ
from ij import WindowManager
from ij.measure import ResultsTable
from loci.plugins import BF
from fr.cnrs.mri.kinetochores import KinetochoreAnalyzer
from fr.cnrs.mri.kinetochores import CellposeSegmenter
from fr.cnrs.mri.kinetochores import LabKitSpotSegmenter
from fr.cnrs.mri.cialib.options import Options
from fr.cnrs.mri.cialib.dialog import OptionsDialog


tableTitle = "Kinetochore Measurements"


def main():
    options = getOptions()
    dialog = OptionsDialog(options)
    if not dialog.showOptions():
        return
    folder = IJ.getDir("Please select the input folder!")
    IJ.log("Running batch analyze kinetochores")
    IJ.log(str(datetime.datetime.now()))
    IJ.log(options.asString())
    table = WindowManager.getWindow(tableTitle)
    if table:
        table = table.getResultsTable()
    else:
        table = ResultsTable()
    batchAnalyzeImages(folder, options.value("image file extension"), table)


def batchAnalyzeImages(folder, ext, table):
    options = Options("kinetochore analyzer", "Analyze Image")
    options.load()
    IJ.log(options.asString())
    images = getImages(folder, ext)
    if len(images) < 1:
        IJ.log("No images found!")
        return
    IJ.log("Processing folder: " + folder)
    IJ.log(str(datetime.datetime.now()))
    nrOfImages = len(images)
    for counter, image in enumerate(images, start=1):
        IJ.log("Processing image " + image)
        IJ.log("Image number " + str(counter) + " of " + str(nrOfImages)) 
        imps = BF.openImagePlus(image)
        imp = imps[0]
        cellSegmenter = getCellSegmenter(options)
        spotSegmenter = getSpotSegmenter(options)
        analyzer = KinetochoreAnalyzer(cellSegmenter, spotSegmenter, imp, options=options)
        analyzer.table = table
        try:
            analyzer.run()
            analyzer.table.show(tableTitle)
            path = os.path.join(folder, "images")
            if not os.path.exists(path):
                os.makedirs(path)
            table.save(os.path.join(os.path.dirname(folder), "results.xls"))
            basename = os.path.splitext(os.path.basename(image))[0]
            IJ.save(analyzer.controlImage, os.path.join(path, basename + ".tif"))
        except:
            outputTraceStack()
            IJ.log("Skipping image " + image)
        finally:
            imp.close()

    IJ.log(str(datetime.datetime.now()))


def getOptions():
    options = Options("kinetochore analyzer", "Batch Analyze Image")
    options.addStr("image file extension", value="czi")
    options.load()
    return options


def getImages(path, ext):
    files = os.listdir(path)
    images = [os.path.join(path, aFile) for aFile in files if not os.path.isdir(os.path.join(path, aFile)) and aFile.endswith(ext)]
    return images


def getCellSegmenter(options):
    segmenter = CellposeSegmenter(options=options)
    return segmenter


def getSpotSegmenter(options):
    segmenter = LabKitSpotSegmenter(options=options)
    return segmenter

def outputTraceStack():
    traceback.print_exc()
    
    
main()
