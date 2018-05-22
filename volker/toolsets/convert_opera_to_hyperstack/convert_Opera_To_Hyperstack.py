# Convert images taken with the opera into hyperstacks
# The image names are in the form
#
# r02c04f01p01-ch1sk1fk1fl1.tiff
#
# where r is the row, c the column, f the field, p the 
# z position and ch the channel.
#
# (c) 2017, INSERM
# written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)

import os, re
from ij import IJ
from ij.macro import Interpreter as IJ1

ext = ".tiff"
exp = re.compile(r'ch(\d)')
saturated = "0.35"
outputFolder = "stacks"
#@ File(label="Select a directory", style="directory") srcFile

def run():
	global ext, exp, saturated, outputFolder, srcFile
	
	IJ1.batchMode = True

	srcDir = srcFile
	images, channels = createFileAndChannelsDictionaries(srcDir, exp)
	outDir = os.path.join(srcDir, outputFolder)
	if not os.path.exists(outDir):
		os.makedirs(outDir)
	
	numberOfImages = len(images)
	counter = 1
	IJ.log("\\Clear")
	IJ.log("Convert images from Opera to Hyperstacks...")
	for image, filename in images.iteritems():
		IJ.log("\\Update1:Processing image "+ str(counter) +"/"+ str(numberOfImages))
		nrOfChannels = channels[image]
		openAsHyperstack(filename, image, nrOfChannels)
		adjustDisplay(nrOfChannels, saturated)
		IJ.saveAsTiff(IJ.getImage(), os.path.join(outDir, image + ".tiff"))
		IJ.getImage().close()
		counter = counter + 1
	IJ.log("Finished !")
	IJ1.batchMode = False

def getImageList(dir):
	paths = os.listdir(dir)
	imagePaths = []
	for path in paths:
		if path.endswith(ext):
			 imagePaths.append(path)
	return imagePaths

def adjustDisplay(nrOfChannels, saturated):
	IJ.getImage().setZ(IJ.getImage().getNSlices() // 2)
	for i in range(1, nrOfChannels+1):
		IJ.getImage().setC(i)
		IJ.getImage().getProcessor().resetMinAndMax()
		IJ.run("Enhance Contrast", "saturated="+saturated)
	IJ.getImage().setC(1)
	IJ.getImage().setZ(1)

def openAsHyperstack(filename, image, nrOfChannels):
	filename2 = filename.replace("\\","/")
	parameters = "open=[" + filename2 + "] file="+image+" sort"
	IJ.run("Image Sequence...", parameters)
	nrOfSlices = IJ.getImage().getImageStackSize()
	nrOfZSlices = nrOfSlices / nrOfChannels
	IJ.run("Stack to Hyperstack...", "order=xyczt(default) channels="+str(nrOfChannels)+" slices="+str(nrOfZSlices)+" frames=1 display=Composite")

def createFileAndChannelsDictionaries(dir, exp):
	paths = getImageList(dir)
	images = dict()
	channels = dict()
	for path in paths:
		image = path.split("p")[0]
		images[image] = os.path.join(dir, path)
		list = exp.findall(path)
		channel = int(list[0])
		if not image in channels or channel>channels[image]:
			channels[image] = channel
	return images, channels

if 'srcFile' in globals():
	srcFile = srcFile.getAbsolutePath()
if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  arg1 = args[0]
  arg2 = args[1]
  arg3 = args[2]
  val1 = arg1.split("=")
  val2 = arg2.split("=")
  val3 = arg3.split("=")
  srcFile = val1[1]
  saturated = val2[1]
  outputFolder = val3[1] 
run()