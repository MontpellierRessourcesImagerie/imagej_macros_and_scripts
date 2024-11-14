
# Contains "c1.classifier", "c2.classifier", ...
_CLASSIFIERS_PATH = "/home/benedetti/Documents/projects/2068-coralie-co-occurance/classifiers-v2/"
# Contains the input image
_SOURCES_FOLDER   = "/home/benedetti/Documents/projects/2068-coralie-co-occurance/transfer_8066882_files_8c192037/new_version/inputs/"
# Will contain the produced masks (to be created before launching the macro)
_OUTPUT_FOLDER    = "/home/benedetti/Documents/projects/2068-coralie-co-occurance/transfer_8066882_files_8c192037/new_version/outputs/"
# Only images with this extension will be processed
_EXTENSION        = ".tif"

import os

from ij import IJ, ImagePlus, ImageStack
from ij.plugin import Duplicator
from net.imglib2.img import ImagePlusAdapter
from sc.fiji.labkit.ui.segmentation import SegmentationTool
from net.imglib2.img.display.imagej import ImageJFunctions
from inra.ijpb.label.LabelImages import keepLabels


def make_mask(img, channel_idx):
    classifier_path = os.path.join(_CLASSIFIERS_PATH, "c"+str(channel_idx)+".classifier")
    if not os.path.isfile(classifier_path):
        IJ.log("Can't find: " + classifier_path)
        return None
    imgplus = ImagePlusAdapter.wrapImgPlus(img)
    sc = SegmentationTool()
    sc.openModel(classifier_path)
    sc.setUseGpu(False)
    result = sc.segment(imgplus)
    output = ImageJFunctions.wrap(result, "segmented")
    raw_seg = output.duplicate()
    output.close()
    img.close()
    return raw_seg
    
    
def clean_mask(raw):
    title = raw.getTitle()
    labelsOut = keepLabels(raw, [1])
    stackOut = ImageStack()
    for s in range(1, labelsOut.getNSlices()+1):
        labelsOut.setSlice(s)
        prc = labelsOut.getProcessor()
        prc.setThreshold(1, 1)
        stackOut.addSlice(prc.createMask())
    raw.close()
    mask = ImagePlus("mask-"+title, stackOut)
    return mask


def classify_pixels(im_path, out_path):
    img = IJ.openImage(im_path)
    nC = img.getNChannels()
    nS = img.getNSlices()
    nF = img.getNFrames()
    d = Duplicator()
    for c in range(1, nC+1):
        c_img = d.run(img, c, c, 1, nS, 1, nF)
        raw = make_mask(c_img, c)
        if raw is None:
        	continue
        binary = clean_mask(raw)
        export_path = os.path.join(out_path, "c"+str(c)+".tif")
        IJ.save(binary, export_path)
        binary.close()


def make_output_directory(img_name):
    no_ext = os.path.splitext(img_name)[0]
    no_ext += "-masks"
    full_path = os.path.join(_OUTPUT_FOLDER, no_ext)
    if not os.path.isdir(full_path):
        os.mkdir(full_path)
    return full_path


def main():
    all_images = sorted([img for img in os.listdir(_SOURCES_FOLDER) if img.endswith(_EXTENSION)])
    for img in all_images:
        output_dir = make_output_directory(img)
        classify_pixels(os.path.join(_SOURCES_FOLDER, img), output_dir)


main()
IJ.log("DONE.");