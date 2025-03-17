from ij import IJ, ImagePlus
from net.imglib2.img import ImagePlusAdapter
from sc.fiji.labkit.ui.segmentation import SegmentationTool
from net.imglib2.img.display.imagej import ImageJFunctions
from inra.ijpb.label.LabelImages import keepLabels
from ij.measure import Calibration
import os

# Folder containing the `membranes` and `measures` sub-folders.
root_folder = "/home/benedetti/Documents/projects/bacilles/sources"
# Folder containing the membrane images, used for segmentation.
membranes   = "star_488"
# Folder containing the images to be measured.
measures    = "star_orange"
# Path to the LabKit classifier file.
classifier  = "/home/benedetti/Documents/projects/bacilles/sources/v2.classifier"

def read_settings():
	"""
	Tries to read the settings file named 'fr-cnrs-mri-bacilles.txt' from the ImageJ directory.
	If the file is missing or doesn't have the expected shape, the function returns None.
	Otherwise, it sets the global variables root_folder, membranes, measures, and classifier.
	In this file, each line contains an item, without key (so the order is important).
	"""
	global root_folder
	global membranes
	global measures
	global classifier
	ij_path = IJ.getDirectory("imagej")
	s_path = os.path.join(ij_path, "fr-cnrs-mri-bacilles.txt")
	if not os.path.isfile(s_path):
		print("Settings file is missing")
		return None
	with open(s_path, "r") as f:
		items = f.readlines()
	if len(items) != 4:
		print("Settings file is corrupted")
		return None
	root_folder = items[0].strip()
	membranes   = items[1].strip()
	measures    = items[2].strip()
	classifier  = items[3].strip()
	
def get_files():
	"""
	Probes the `membranes` and `measures` folders and returns the set of items that are present in both.
	(The segmentation and the measures channel should be named the same way.)
	"""
	if not os.path.isdir(root_folder):
		print("Root folder doesn't exist")
		return None
	seg_content = set([f for f in os.listdir(os.path.join(root_folder, membranes)) if f.endswith(".tif")])
	mes_content = set([f for f in os.listdir(os.path.join(root_folder, measures)) if f.endswith(".tif")])
	return seg_content.intersection(mes_content)

def open_pair(target):
	"""
	Takes the name of an image in input and opens all its channels from the different folders.
	Returns a tuple of ImagePlus objects, one for the membrane channel and one for the measures channel.
	If one if this items can't be found, the function returns (None, None).
	Images are duplicated because BioFormats insists on opening them as virtual stack, even if we explicitely ask to open them as regular images.
	"""
	mp = os.path.join(root_folder, membranes, target)
	tp = os.path.join(root_folder, measures, target)
	if (not os.path.isfile(mp)) or (not os.path.isfile(tp)):
		print("Image " + target + " is missing")
		return (None, None)
	c = Calibration()
	c.pixelWidth = 1
	c.pixelHeight = 1
	c.pixelDepth = 1
	c.setUnit("pixel")
	m = IJ.openImage(mp)
	m.setCalibration(c)
	m1 = m.duplicate()
	t = IJ.openImage(tp)
	t.setCalibration(c)
	t1 = t.duplicate()
	m.close()
	t.close()
	return (m1, t1)

def segment_membranes(membranes):
	"""
	Use LabKit to segment the membrane channel.
	3 classes are predicted: 
	  - (0) background
	  - (1) object (mask of bacteria)
	  - (2) split
	"""
	imgplus = ImagePlusAdapter.wrapImgPlus(membranes) # wraps the ImgPlus as an ImagePlus
	sc = SegmentationTool()
	sc.openModel(classifier)
	result = sc.segment(imgplus)
	output = ImageJFunctions.wrap(result, "segmented") # Unpack the result in an ImagePlus
	raw_seg = output.duplicate() # Make it a non-virtual stack
	output.close()
	labelsOut = keepLabels(raw_seg, [1]) # We only keep the 'object' class
	raw_seg.close()
	prc = labelsOut.getProcessor()
	prc.setThreshold(1, 255) # Threshold the mask
	mask = ImagePlus("mask", prc)
	labelsOut.close()
	return mask

def save_mask(mask, target):
	"""
	Segmented images (masks) are saved in the 'masks-<membranes>' folder.
	The name of the file is the same as the original image.
	"""
	dir_name = "masks-" + membranes
	out_path = os.path.join(root_folder, dir_name)
	if not os.path.isdir(out_path):
		os.mkdir(out_path)
	out_path = os.path.join(out_path, target)
	IJ.saveAs(mask, "Tiff", out_path)

def main():
	read_settings()
	imgs_pool = get_files()
	for img in imgs_pool:
		IJ.log("Working on: " + img)
		membranes, interest = open_pair(img)
		if (membranes is None) or (interest is None):
			IJ.run("Close All")
			continue
		mask = segment_membranes(membranes)
		membranes.close()
		save_mask(mask, img)
		mask.close()
	IJ.log("DONE.")

main()
