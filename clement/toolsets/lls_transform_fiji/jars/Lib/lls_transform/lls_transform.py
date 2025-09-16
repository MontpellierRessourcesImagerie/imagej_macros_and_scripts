#@ String (label="Please enter your name", description="Name field") name

import os
import math

from ij import IJ
from imagescience.image import Image, Axes
from imagescience.transform import Transform, Affine

# https://github.com/ImageScience/ImageScience/blob/master/source/java/imagescience/transform/Transform.java

def lls_transform(image, angle_deskew, angle_cgt, what):
	calib = image.getCalibration()
	csave = calib.copy()
	s_z   = calib.pixelDepth
	s_xy  = calib.pixelWidth
	ratio = s_z / s_xy

	calib.pixelDepth = calib.pixelWidth = calib.pixelHeight = 1
	calib.setUnit("pixel")
	image.setCalibration(calib)

	name, _ = os.path.splitext(image.getTitle())
	title = name + "-" + what

	M = Transform()

	M.shear(
		math.cos(math.radians(angle_deskew)) * ratio,
		Axes.Y,
		Axes.Z
	)

	if (what == "CGT"):
		M.scale(ratio * 0.5, Axes.Z)
		M.rotate(angle_cgt, Axes.X)
		M.rotate(90, Axes.Z)
		M.scale(-1, Axes.X)
		M.scale(-1, Axes.Z)

	wrapped = Image.wrap(image)
	affine = Affine()

	result = affine.run(
		wrapped,       # data
		M,             # transform
		Affine.LINEAR, # interpolation
		True,          # adjust canvas size
		False,         # resample
		False          # anti-alias
	)

	calib.pixelDepth = calib.pixelWidth = calib.pixelHeight = s_xy
	calib.setUnit("um")
	image.setCalibration(csave)

	imp_result = result.imageplus()
	imp_result.setTitle(title)
	imp_result.setCalibration(calib)

	return imp_result

def get_transforms():
	return set([
		"Deskew",
		"CGT"
	])

def get_zeiss_config():
	# 31.8 ?
	return {
		"angle_deskew" : 30.0,
		"angle_cgt"    : -180.0-30.0
	}
