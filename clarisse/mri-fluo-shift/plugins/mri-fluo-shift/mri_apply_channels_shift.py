import math
import json
import os
from ij.gui import GenericDialog
from ij import IJ
from ij.plugin import (
	ZProjector,
	Duplicator
)
from ij.plugin.filter import (
	MaximumFinder,
	GaussianBlur,
	BackgroundSubtracter
)
from ij.io import Opener
from ij.process import ImageProcessor


def ask_microscope():
	gd = GenericDialog("Channels shifting")
	gd.addFileField("Microscope shifts (JSON file)", "")
	gd.showDialog()
	
	path = gd.getNextString()
	if not os.path.isfile(path):
		return None
	else:
		return path
		
		
def ask_settings(shifts):
	gd = GenericDialog("Shifting: " + shifts['microscope'])
	
	gd.addDirectoryField("Input folder", "")
	gd.addStringField("Extension", ".czi")
	gd.addDirectoryField("Output folder", "")
	
	channels_pool = ["---", "Brightfield"] + list([k for k in shifts['shifts'].keys()])
	nCh = len(channels_pool) - 1
	for i in range(nCh):
		gd.addChoice("C"+str(i+1), channels_pool, "---")
		
	gd.showDialog()
	
	input_folder = gd.getNextString()
	extension = gd.getNextString()
	output_folder = gd.getNextString()
	
	channels = []
	for i in range(nCh):
		ch_name = gd.getNextChoice()
		if ch_name == "---":
			break
		channels.append(ch_name)
	
	return {
		'input'    : input_folder,
		'output'   : output_folder,
		'extension': extension,
		'channels' : channels
	}
	
	
def apply_transform(img, properties, shifts):
	nZ = img.getNSlices()
	for ch_index, ch_name in enumerate(properties['channels']):
		img.setC(ch_index+1)
		transform = shifts['shifts'].get(ch_name, None)
		if transform is None:
			continue
		for z in range(1, nZ+1):
			img.setZ(z)
			prc = img.getProcessor()
			prc.setInterpolationMethod(ImageProcessor.BILINEAR)
			prc.translate(transform[0], transform[1])

		
def main():
	IJ.run("Close All")
	
	microscope_path = ask_microscope()
	if microscope_path is None:
		print("Couldn't find the file")
		return
		
	with open(microscope_path, 'r') as fp:
		shifts = json.load(fp)
	
	properties = ask_settings(shifts)
	
	for img_name in os.listdir(properties['input']):
		if not img_name.endswith(properties['extension']):
			continue
		full_path = os.path.join(properties['input'], img_name)
		output_name = img_name.replace(properties['extension'], ".tif")
		output_path = os.path.join(properties['output'], output_name)
		
		# IJ.run(
		# 	"Bio-Formats", 
		# 	"open=["+full_path+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT"
		# )
		
		img = Opener.openUsingBioFormats(full_path)
		apply_transform(img, properties, shifts)
		
		IJ.saveAs(img, "TIFF", output_path)
		img.close()
		
	print("DONE.")
		


main()
		
		
		
		
		
		
		
		
		
		
		
		
		
		