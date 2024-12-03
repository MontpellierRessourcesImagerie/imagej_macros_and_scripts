from ij import IJ, ImagePlus
from ij.plugin.frame import RoiManager
from inra.ijpb.binary import BinaryImages
from inra.ijpb.morphology import Strel
from ij.plugin.filter import ThresholdToSelection
from ij.measure import ResultsTable
import os

root_folder = "/home/benedetti/Documents/projects/bacilles/sources"
membranes   = "star_488"
measures    = "star_orange"
classifier  = "/home/benedetti/Documents/projects/bacilles/sources/v2.classifier"

masks_path  = None
n_iters     = 4

def read_settings():
	"""
	Check the documentation of this function in the `bacilli_segment.py` file.
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
	Returns the list of membrane masks (names only) that are present in the `masks-<membranes>` folder.
	The assumption is that the masks are named the same way as the images in the `measures` folder.
	An other assumption is that images were left untouched since the segmentation, and no file was removed.
	(No safety check performed)
	At the same time, the path to the masks folder is stored in the global variable `masks_path`.
	"""
	global masks_path
	if not os.path.isdir(root_folder):
		print("Root folder doesn't exist")
		return None
	m_path = os.path.join(root_folder, "masks-"+membranes)
	if not os.path.isdir(m_path):
		print("Masks folder doesn't exist")
		return None
	masks_path = m_path
	masks_ctt = set([f for f in os.listdir(masks_path) if f.endswith(".tif")])
	return masks_ctt

def get_triplet(target):
	"""
	Builds triplets of inputs for the measures:
	  - The mask produced at the segmentation step (whole image).
	  - The RoiManager containing the individual cells.
	  - The image to be measured (whole image).
	If the RoiManager is missing (it can happen if an image didn't have any good cell), it is set to None.
	"""
	mp = os.path.join(masks_path, target)
	tt = os.path.join(root_folder, measures, target)
	rp = os.path.join(masks_path, target.replace(".tif", ".zip"))
	mp1 = IJ.openImage(mp)
	tt1 = IJ.openImage(tt)
	rp1 = None
	if os.path.isfile(rp):
		rp1 = RoiManager.getRoiManager()
		rp1.reset()
		rp1.open(rp)
	# Mask, RoiManager, Measure image
	return (mp1, rp1, tt1)

def postprocess_mask(mask):
	"""
	The membrane staining has the shape of a peanut, but the bacteria have a shape of capsules.
	This function performs a closing with a wide radius to get a more "capsular" shape from the mask.
	The original image is closed and new one is created.
	"""
	strel = Strel.Shape.DISK.fromRadius(12)
	closed = strel.closing(mask.getProcessor())
	imOut = ImagePlus("Main cell", closed)
	mask.close()
	return imOut

def erode_mask(mask, kern_rad=1):
	"""
	Creates a new image in every situation, the original is not modified.
	Performs an erosion with a disk-shaped structuring element of radius `kern_rad`.
	If the radius is less than 1, the original mask is duplicated and returned.
	"""
	if kern_rad < 1:
		return mask.duplicate()
	strel = Strel.Shape.DISK.fromRadius(kern_rad)
	eroded = strel.erosion(mask.getProcessor())
	imOut = ImagePlus("Main cell", eroded)
	return imOut

def append_result(table, measures, img_name):
	"""
	This function expects a ResultsTable object, a dictionary of measures and the name of the image.
	The dictionary contains the measures for a single cell at different erosion levels.
	  ex: {'min-0': 0.0, 'min-1': 1.0, 'min-2': 2.0, 'min-3': 3.0}
	      This example only contains the 'min' values, but the dictionary should contain more (min, max, mean, std, median).
	All the measures are added on a same line for a same bacteria.
	The first column is the name of the image.
	"""
	table.addRow()
	size = table.size() - 1
	table.setValue("Source", size, img_name)
	if measures is None:
		table.updateResults()
		return
	keys = sorted(list(measures.keys()))
	for k in keys:
		table.setValue(k, size, measures[k])
	table.updateResults()

def measure_in_mask(mask, img, idx):
	"""
	Expects a mask and an image, and the index of the erosion level.
	Turns the mask into a ROI and use it to measure stats on the image.
	The index is only used to name the columns in the ResultsTable.
	"""
	prc = mask.getProcessor()
	prc.setThreshold(1, 255)
	roi = ThresholdToSelection.run(mask)
	prc = img.getProcessor()
	prc.setRoi(roi)
	stats = prc.getStatistics()
	return {
		'min-'    + str(idx): stats.histMin,
		'max-'    + str(idx): stats.histMax,
		'mean-'   + str(idx): stats.mean,
		'std-'    + str(idx): stats.stdDev,
		'median-' + str(idx): stats.median,
	}

def main():
	read_settings()
	files = get_files()
	rt = ResultsTable()
	for img_name in files:
		IJ.log("Working on: " + img_name)
		flag = True # We want the image's name only once in the ResultsTable, not for every cell
		mask, roi, img = get_triplet(img_name)
		if (mask is None) or (roi is None) or (img is None): # No cell on this image (no RoiManager)
			append_result(rt, None, img_name)
			continue
		for r in roi.getRoisAsArray():
			mask.setRoi(r)
			img.setRoi(r)
			sub_mask = mask.crop()
			sub_img = img.crop()
			sub_mask = postprocess_mask(sub_mask)
			measures = {}
			for i in range(n_iters):
				eroded = erode_mask(sub_mask, i)
				vals = measure_in_mask(eroded, sub_img, i)
				measures.update(vals)
				eroded.close()
			sub_mask.close()
			sub_img.close()
			append_result(rt, measures, img_name if flag else "")
			flag = False
	rt.show("Results")
	IJ.log("DONE.")

main()