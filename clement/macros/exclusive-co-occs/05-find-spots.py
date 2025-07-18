import os
import shutil
import math
import json
from ij import IJ, ImagePlus, ImageStack
from net.imglib2.img import ImagePlusAdapter
from ij.io import Opener
from sc.fiji.labkit.ui.segmentation import SegmentationTool
from net.imglib2.img.display.imagej import ImageJFunctions
from inra.ijpb.label.LabelImages import (keepLabels, findAllLabels, 
	                                     remapLabels, dilateLabels)
from inra.ijpb.label.conncomp import FloodFillRegionComponentsLabeling3D
from ij.plugin import Duplicator, GaussianBlur3D
from ij.plugin.filter import BackgroundSubtracter
from ij.plugin import ImageCalculator
from ij.measure import ResultsTable
from mcib3d.image3d import (ImageFloat, ImageHandler, ImageInt)
from mcib3d.image3d.distanceMap3d import EDT
from mcib3d.image3d.processing import FastFilters3D
from mcib3d.image3d.regionGrowing import Watershed3D
from inra.ijpb.measure.region3d import Centroid3D
from inra.ijpb.measure import IntensityMeasures
from inra.ijpb.geometry import Point3D

images_folder  = "/home/benedetti/Downloads/2025-04-16-celia_chamontin/transfer_9591250_files_e96af054"
clfs_location  = "/home/benedetti/Downloads/2025-04-16-celia_chamontin/transfer_9591250_files_e96af054"
extension      = ".czi"
spots_channels = {
	"RFP": 4,
	"GFP": 4
}
distance = 0.35 # in physical unit


def run_classification(ch_data, ch_name):
	cf_path = os.path.join(clfs_location, ch_name+"-last.classifier")
	
	if not os.path.isfile(cf_path):
		print("Could not find " + cf_path)
		return None
	
	imgplus = ImagePlusAdapter.wrapImgPlus(ch_data)
	clb	 = ch_data.getCalibration()
	title = ch_name + "-labels"
	result = None

	for useGpu in [True, False]:
		try:
			sc = SegmentationTool()
			sc.openModel(cf_path)
			sc.setUseGpu(useGpu)
			result = sc.segment(imgplus)
		except:
			result = None
		if result is not None:
			break

	if result is None:
		print("Failed to run LabKit")
		return None

	output = ImageJFunctions.wrap(result, "segmented")
	raw_seg = output.duplicate()
	output.close()
	raw_seg.setTitle(title)

	return raw_seg

def make_mask(labels):
	stackOut = ImageStack()
	for s in range(1, labels.getNSlices()+1):
		labels.setSlice(s)
		prc = labels.getProcessor()
		prc.setThreshold(1, 65535)
		stackOut.addSlice(prc.createMask())
	t = labels.getTitle()
	mask = ImagePlus("mask-" + t, stackOut)
	return mask

def split_spots(binaryMask, rad=1.0):
	radXY = rad
	radZ  = rad
	
	cal = binaryMask.getCalibration()
	
	resXY = cal.pixelWidth
	resZ  = cal.pixelDepth
	radZ  = radXY * (resXY / resZ)
	
	imgMask = ImageInt.wrap(binaryMask)
	edt = EDT.run(imgMask, 0, resXY, resZ, False, 0)
	edt16 = edt.convertToShort(True)
	
	edt16Plus = edt16.getImagePlus()
	GaussianBlur3D.blur(edt16Plus, 2.0, 2.0, 2.0)
	edt16 = ImageInt.wrap(edt16Plus)
	edt16.intersectMask(imgMask)
	
	seedsImg = FastFilters3D.filterImage(edt16, FastFilters3D.MAXLOCAL, radXY, radXY, radZ, 0, False)
	
	water = Watershed3D(edt16, seedsImg, 0, 0)
	water.setLabelSeeds(True)
	water.setAnim(False)
	splitted = water.getWatershedImage3D()
	result = splitted.getImagePlus()
	result.setCalibration(cal)
	return result

def postprocess_labels(labels):
	# Keep only the label of interest
	interest_labels = [1]
	labelsOut = keepLabels(labels, interest_labels)
	# Transform the image in a mask
	mask = make_mask(labelsOut)
	labelsOut.close()
	# Split the mask using a watershed
	labeled = split_spots(mask)
	mask.close()
	# Make sure IDs are continuous
	remapLabels(labeled.getStack())
	return labeled

def segment_channel(ch_data, ch_name):
	labels = run_classification(ch_data, ch_name)
	clean = postprocess_labels(labels)
	labels.close()
	return clean

def check_content():
	original_content = sorted([f for f in os.listdir(images_folder) if f.endswith(extension)])
	required_masks   = [f.replace(extension, ".tif") for f in original_content]
	masks_path       = os.path.join(images_folder, "labeled-stacks")
	
	if not os.path.isdir(masks_path):
		return (None, None)
	
	found = []
	for o, m in zip(original_content, required_masks):
		mask_path = os.path.join(masks_path, m)
		if os.path.isfile(mask_path):
			found.append((o, m))

	if len(found) != len(original_content):
		print("Warning: Some images are not segmented in 'labeled-stacks'.")

	return (masks_path, found)

def reset_output():
	target_directory = os.path.join(images_folder, "spots")
	if os.path.isdir(target_directory):
		shutil.rmtree(target_directory)
	os.mkdir(target_directory)
	return target_directory

def create_spots_folder(output_dir, image_name):
	n = image_name.replace(extension, "")
	target = os.path.join(output_dir, n)
	os.mkdir(target)
	return target

def extract_spots(segmented_cells, labeled_spots, clb):
	all_lbls = findAllLabels(labeled_spots.getStack())
	all_cell = findAllLabels(segmented_cells.getStack())
	all_lbls = sorted([i for i in all_lbls if i != 0])
	all_cell = sorted([i for i in all_cell if i != 0])
	centers  = Centroid3D.centroids(
		labeled_spots.getStack(), 
		all_lbls, 
		clb
	)
	im = IntensityMeasures(segmented_cells, labeled_spots)
	rt = im.getMedian()
	spots = {c: [] for c in all_cell}
	cl = rt.getColumnIndex("Median")
	
	for row_idx in range(rt.size()):
		lbl = int(rt.getLabel(row_idx)) # spot id
		cell = int(rt.getValueAsDouble(cl, row_idx))
		if cell == 0:
			continue
		spots[cell].append(centers[lbl-1])

	return spots

def get_distance(p1, p2):
    return math.sqrt((p2.getX() - p1.getX())**2 + (p2.getY() - p1.getY())**2 + (p2.getZ() - p1.getZ())**2)

def midpoint(p1, p2):
    return Point3D(
        (p1.getX() + p2.getX()) / 2.0,
        (p1.getY() + p2.getY()) / 2.0,
        (p1.getZ() + p2.getZ()) / 2.0
    )

def get_distance(p1, p2):
    return math.sqrt(
        (p1.getX() - p2.getX())**2 +
        (p1.getY() - p2.getY())**2 +
        (p1.getZ() - p2.getZ())**2
    )

def build_graph(A, B, threshold):
    graph = [[] for _ in range(len(A))]
    for i, a in enumerate(A):
        for j, b in enumerate(B):
            if get_distance(a, b) <= threshold:
                graph[i].append(j)
    return graph

def bpm(u, graph, seen, match_to):
    for v in graph[u]:
        if not seen[v]:
            seen[v] = True
            if match_to[v] == -1 or bpm(match_to[v], graph, seen, match_to):
                match_to[v] = u
                return True
    return False

def max_matching(A, B, threshold):
    graph = build_graph(A, B, threshold)
    match_to = [-1] * len(B)
    result = []

    for u in range(len(A)):
        seen = [False] * len(B)
        if bpm(u, graph, seen, match_to):
            pass

    for v in range(len(B)):
        if match_to[v] != -1:
            result.append( (match_to[v], v) )

    return result

def count_co_occurrences(spots):
	if len(spots) != 2:
		print("Received more than 2 dyes. Abort.")
		return False
	
	dye1, dye2 = tuple(spots.keys())
	cells = set(spots[dye1].keys()).union(spots[dye2].keys())
	spots['# co-occ'] = {c: [] for c in cells}

	for cell in cells:
		co_occs = max_matching(spots[dye1][cell], spots[dye2][cell], distance)
		points = [midpoint(spots[dye1][cell][i], spots[dye2][cell][j]) for i, j in co_occs]
		spots['# co-occ'][cell] = points

	return True

def create_control(im_like, spots, path):
	h = im_like.getHeight()
	w = im_like.getWidth()
	d = im_like.getNSlices()
	c = len(spots)
	clb = im_like.getCalibration()
	control = IJ.createImage("control", "8-bit black", w, h, c, d, 1)
	for idx, ch in enumerate(sorted(list(spots.keys())), start=1):
		control.setC(idx)
		for cell_idx, positions in spots[ch].items():
			for p in positions:
				x = int(clb.getRawX(p.getX()))
				y = int(clb.getRawY(p.getY()))
				z = int(clb.getRawZ(p.getZ()))
				control.setSlice(z+1)
				prc = control.getProcessor()
				prc.set(x, y, cell_idx)

	IJ.saveAs(control, "TIFF", path)
	control.close()

def add_to_summary(source, lbld_spots, summary):
	summary[source] = {}
	for ch_name, cells_data in lbld_spots.items():
		summary[source][ch_name] = {}
		for cell_id, positions in cells_data.items():
			summary[source][ch_name][cell_id] = len(positions)

def export_summary(output_dir, summary):
	full_path = os.path.join(output_dir, "results.json")
	f = open(full_path, 'w')
	json.dump(summary, f)
	f.close()

def main():
	# Check that only 2 channels are present
	if len(spots_channels) != 2:
		print("This script was built to handle only 2 channels of spots")
		return

	# Verify that every input image is associated with a mask
	masks_path, content = check_content()
	if masks_path is None:
		print("Error: Couldn't find masks directory (labeled-stacks)")
		return

	# Create (or reset) the folder that will containg control images and results.
	output_folder = reset_output()

	dp = Duplicator()
	rt = ResultsTable()
	summary = {}
	for idx, (image_name, mask_name) in enumerate(content):
		print("[" + str(idx+1).zfill(2) + "/" + str(len(content)).zfill(2) + "] - Processing: '" + image_name + "'...")
		image_path = os.path.join(images_folder, image_name)
		mask_path  = os.path.join(masks_path, mask_name)
		image_data = Opener.openUsingBioFormats(image_path)
		calib      = image_data.getCalibration()
		segmented  = IJ.openImage(mask_path)
		n_slices   = image_data.getNSlices()
		spots_dir  = create_spots_folder(output_folder, image_name)
		lbld_spots = {} # {dye1: {1: [(x1, y1), (x2, y2), (x3, y3)]}, dye2: {...}}
		for ch_name, ch_index in spots_channels.items():
			ch_data = dp.run(image_data, ch_index, ch_index, 1, n_slices, 1, 1)
			labeled = segment_channel(ch_data, ch_name)
			IJ.saveAs(labeled, "TIFF", os.path.join(spots_dir, ch_name+".tif"))
			lbld_spots[ch_name] = extract_spots(segmented, labeled, calib)
			ch_data.close()
			labeled.close()
		count_co_occurrences(lbld_spots)
		create_control(segmented, lbld_spots, os.path.join(spots_dir, "co-occs.tif"))
		print("-------")
		for dye, spots in lbld_spots.items():
			print(dye + ": " + str(len(spots)) + " cells")
			for cell_id, positions in spots.items():
				print("   cell-" + str(cell_id) + ": " + str(len(positions)) + " spots")
		print("-------")
		add_to_summary(image_name, lbld_spots, summary)
		print(summary)
		image_data.close()
		segmented.close()
	export_summary(output_folder, summary)
	print("DONE.")


main()