#
# Convert images taken with the SPINNING DISC NIKON TI ANDOR CSU-X1 into hyperstacks. 
# When the image is too big the time-points are broken down into multiple chunks. Concatenate
# the z-projections of the different chunks and save one file per date/position/wavelength.
#
# 20180528-_f0000_t0000_w0000.tif
#
# where f is the position, t the time and w the channel
# 
# (c) 2018, INSERM
# written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
# 
 
import os, re
from ij import IJ
from ij.macro import Interpreter as IJ1

ext = ".tif"
timeChunkExp = re.compile(r't(\d+)')
channelExp = re.compile(r'w(\d+)')
imageExp = re.compile(r'(^.+_f\d+)')
outputFolder = "stacks"
zSlices = 31
pixelSize = 0
pixelUnit = "nm"
timeInterval = 0
timeUnit = "sec"

#@ File(label="Select a directory", style="directory") srcDir

def run():
	global ext, timeChunkExp, channelExp, imageExp, outputFolder, zSlices, pixelSize, pixelUnit, timeInterval, timeUnit, srcDir
	
	IJ1.batchMode = True
	if not isinstance(srcDir, str): 
		srcDir = srcDir.toString()
	images, timeChunks, channels = createFileTimeChunksAndChannelsDictionaries(srcDir, imageExp, timeChunkExp, channelExp)
	outDir = os.path.join(srcDir, outputFolder)
	if not os.path.exists(outDir):
		os.makedirs(outDir)
	numberOfImages = len(images)
	counter = 1
	IJ.log("\\Clear")
	IJ.log("Convert images from Nikon-TI-Andor to Hyperstacks...")
	for image, filename in images.iteritems():
		numberOfChannels = channels[image] + 1
		numberOfTimeChunks = timeChunks[image] + 1
		for channel in range(0,numberOfChannels):
			channelString = zeroPad(str(channel), 4)
			for timeChunk in range(0, numberOfTimeChunks):
				IJ.log("\\Update1:Processing image "+ str(counter) +"/"+ str(numberOfImages) + ", channel " + str(channel+1) + "/" + str(numberOfChannels) + ", time-chunk " + str(timeChunk+1) + "/" + str(numberOfTimeChunks))
				timeString = zeroPad(str(timeChunk), 4)
				currentFilename = srcDir + "/" + image + "_t" + timeString + "_w" + channelString + ext
				filename2 = currentFilename.replace("\\","/") 
				IJ.open(filename2)
				stack = IJ.getImage()
				idStack = stack.getID();
				createHyperstack(zSlices)				
				doZProjection(idStack)
				projectionTitle = IJ.getImage().getTitle();
				stack.close()
				if timeChunk>0:
					IJ.run("Concatenate...", "  title="+image+ext+" image1="+image+ext+" image2="+projectionTitle)
				IJ.getImage().setTitle(image + ext)
			dimensions = IJ.getImage().getDimensions()
			nSlices = dimensions[3]
			IJ.run("Properties...", "channels=1 slices=1 frames="+str(nSlices))
			if pixelSize>0:
				IJ.run("Properties...", "unit="+pixelUnit+" pixel_width="+str(pixelSize)+" pixel_height="+str(pixelSize));
			if timeInterval>0:
				IJ.run("Properties...", "frame=["+str(timeInterval)+" "+timeUnit+"]");
			IJ.save(outDir + "/" + image + "_w" + channelString + ext)
			IJ.getImage().close()
		counter = counter + 1
	IJ1.batchMode = False
	IJ.log("Finished!!!")
	
def createFileTimeChunksAndChannelsDictionaries(dir, imageExp, timeChunkExp, channelExp):
	paths = getImageList(dir)
	images = dict()
	timeChunks = dict()
	channels = dict()
	for path in paths:
		list = imageExp.findall(path)
		image =  list[0]
		images[image] = os.path.join(dir, path)
		list = timeChunkExp.findall(path)
		timeChunk = int(list[0])
		if not image in timeChunks or timeChunk>timeChunks[image]:
			timeChunks[image] = timeChunk
		list = channelExp.findall(path)
		channel = int(list[0])
		if not image in channels or channel>channels[image]:
			channels[image] = channel
	return images, timeChunks, channels
		

def getImageList(dir):
	paths = os.listdir(dir)
	imagePaths = []
	for path in paths:
		if path.endswith(ext):
			 imagePaths.append(path)
	return imagePaths

def openAsHyperstack(filename, image, channel):
	filename2 = filename.replace("\\","/")

def zeroPad(string, digits):
	result = string
	for i in range(0, digits-len(string)):
		result = "0" + result
	return result

def createHyperstack(zSlices):
	dimensions = IJ.getImage().getDimensions()
	nSlices = dimensions[3]
	timePoints = nSlices / zSlices
	IJ.run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+str(zSlices)+" frames="+str(timePoints)+" display=Composite");
	
	
def doZProjection(id):
	IJ.selectWindow(id)
	IJ.run("Z Project...", "projection=[Max Intensity] all");

if 'getArgument' in globals():
  parameter = getArgument()
  args = parameter.split(",")
  srcDir =  args[0].split("=")[1]
  outputFolder = args[1].split("=")[1]
  zSlices = int(args[2].split("=")[1])
  pixelSize = float(args[3].split("=")[1])
  pixelUnit = args[4].split("=")[1]
  timeInterval = float(args[5].split("=")[1])
  timeUnit = args[6].split("=")[1]
run()
