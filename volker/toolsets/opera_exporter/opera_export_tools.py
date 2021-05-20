import xml.etree.ElementTree as ET
from ij import IJ
import os
from ij.gui import WaitForUserDialog
from ij.macro import Interpreter
from ij.plugin import ImagesToStack, ZProjector
from ij.process import ImageConverter
from datetime import datetime
import shutil
import argparse
import re

def main(args):
	parser = getArgumentParser()
 	params = parser.parse_args(args)
 	experiment = PhenixHCSExperiment.fromIndexFile(params.index_file);
	print(experiment)
	wells = experiment.getPlates()[0].getWells()
	if not params.wells == 'all':
		listOfWellIDS = splitIntoChunksOfSize(params.wells, 4)	
	for well in wells:
		dims = well.getDimensions()
		zSize = dims[2]
		zPos = params.slice
		if zPos==0:
			zPos = zSize / 2
		if params.wells=='all' or well.getID() in listOfWellIDS:
			well.calculateStitching(zPos, 0, params)
			well.applyStitching(params)	
			if params.stack:
				well.createStack(dims, params)
			if params.merge:
				well.mergeChannels(dims, params)
 			if params.mip:
 				well.mip(dims, params)
 						
def getArgumentParser():
	parser = argparse.ArgumentParser(description='Create a mosaic from the opera images using the index file and fiji-stitching.')
	parser.add_argument("--wells", "-w", default='all', help='either "all" or a string of the form "01010102" defining the wells to be exported')
	parser.add_argument("--slice", "-s", default=0, type=int, help='the slice used to calculate the stitching, 0 for the middle slice')
	parser.add_argument("--channel", "-c", default=1, type=int, help='the channel used to calculate the stitching')
	parser.add_argument("--stack", default=False, action='store_true', help='create z-stacks of the mosaics')
	parser.add_argument("--merge", default=False, action='store_true', help='merge the channels into a hyperstack')
	parser.add_argument("--mip", default=False, action='store_true', help='apply a maximum intensity projection per channel')
	parser.add_argument("--normalize", default=False, action='store_true', help='normalize the intensities of the images in a mosaic')
	parser.add_argument("--fusion-method", default="Linear_Blending", help='the fusion method, "Linear_Blending", "Average", "Median" ,"Max_Intensity", "Min_Intensity" or "random"')
	parser.add_argument("--regression-threshold", "-r", default=0.3, type=float, help='if the regression threshold between two images after the individual stitching are below that number they are assumed to be non-overlapping')
	parser.add_argument("--displacement-threshold", "-d", default=2.5, type=float, help='max/avg displacement threshold')
	parser.add_argument("--abs-displacement-threshold", "-a", default=3.5, type=float, help='removes links between images if the absolute displacement is higher than this value')
	parser.add_argument("--pseudoflatfield", "-p", default=0, type=float, help='blurring radius for the pseudo flatfield correction (no correction if 0)')
	parser.add_argument("--rollingball", "-b", default=0, type=float, help='rolling ball radius for the background correction (no correction if 0)')
	parser.add_argument("--subtract-background-radius", "-g", default=3, type=int, help='radius for the find and subtract background operation')
	parser.add_argument("--subtract-background-offset", "-o", default=3, type=int, help='offset for the find and subtract background operation')
	parser.add_argument("--subtract-background-iterations", "-i", default=1, type=int, help='nr of iterations for the find and subtract background operation')
	parser.add_argument("--subtract-background-skip", "-k", default=0.3, type=float, help='skip limit for the find and subtract background operation')
	parser.add_argument('--colours', "-C", type=lambda s: re.split(' |,', s), default=["Blue", "Green", "Red"], help='colors of the channels')
	parser.add_argument("index_file", help='path to the Index.idx.xml file')
	return parser

def splitIntoChunksOfSize(some_string, x):
	res=[some_string[y-x:y] for y in range(x, len(some_string)+x,x)]
	return res
	
def zero_center_coordinates(x_pos, y_pos):
    leftmost = min(x_pos)
    top = max(y_pos)

    if leftmost < 0:
        leftmost = abs(leftmost)
        if top < 0:
            top = abs(top)
            x_pos = [i + leftmost for i in x_pos]
            y_pos = [abs(i) - top for i in y_pos]
        else:
            x_pos = [i + leftmost for i in x_pos]
            y_pos = [top - i for i in y_pos]
    else:
        if top < 0:
            top = abs(top)
            x_pos = [i - leftmost for i in x_pos]
            y_pos = [abs(i) - top for i in y_pos]
        else:
            x_pos = [i - leftmost for i in x_pos]
            y_pos = [top - i for i in y_pos]
    return x_pos, y_pos

class Plate(object):
	def __init__(self, plateData, experiment):
		self.data = plateData
		self.experiment = experiment

	def __str__(self):
		plateType = self.data[4].text
		rows = self.data[5].text
		columns = self.data[6].text
		return "Plate (" + name + ", "+ plateType + ", " + rows + "x" + columns + ")"

	def getWells(self):
		wells = []
		for wellID in self.data[7:]:
			wells.append(self.experiment.getWell(wellID.attrib['id'], self))
		return wells

	def getName(self):
		return self.data[3].text
		
class Well(object):
	def __init__(self, anID, row, col, imageData, experiment, plate):
		self.id = anID
		self.row = row
		self.column = col
		self.imageData= imageData
		self.images = None
		self.experiment = experiment
		self.plate = plate

	def getID(self):
		return self.id

	def getRow(self):
		return self.row

	def getColumn(self):
		return self.column

	def getImageData(self):
		return self.imageData;

	def getImages(self):
		if not self.images:
			self.images = []
			for data in self.imageData:
				self.images.append(self.experiment.getImage(data.attrib['id']))
		return self.images;
    
	def getFields(self):
		images = self.getImages()
		fieldSet = set()
		for image in images:
			fieldSet.add(image.getField())
		fields = sorted(fieldSet)
		return fields

	def getPixelWidth(self):
		return self.getImages()[0].getPixelWidth()
		
	def getDimensions(self):
		images = self.getImages()
		xPositions = set()
		yPositions = set()
		slices = set()
		frames = set()
		channels = set()
		width = 0
		height = 0
		pixelWidth = self.getPixelWidth()
		xCoords = [int(round(image.getX()/pixelWidth)) for image in images]
		yCoords = [int(round(image.getY()/pixelWidth)) for image in images]
		xCoords, yCoords = zero_center_coordinates(xCoords, yCoords)
		for image in images:
			slices.add(image.getPlane())
			frames.add(image.getTime())
			channels.add(image.getChannel())
			if image.getWidth()>width:
				width = image.getWidth()# Define the image coordinates
			if image.getHeight()>height: 
				height = image.getHeight()
		res = (max(xCoords)+width, max(yCoords)+height, len(slices), len(frames), len(channels))
		return res

	def createTileConfig(self, zPosition, timePoint, channel):
		srcPath = self.experiment.getPath();
		path = srcPath + "/work";
		if not os.path.exists(path):
			os.mkdir(path)
		tileConfPath = path + "/TileConfiguration.txt"
		allImages = self.getImages()
		images = [image for image in allImages if image.getPlane()==zPosition and image.getChannel()==channel and image.getTime()==timePoint]
		xCoords = [int(round(image.getX()/float(image.getPixelWidth()))) for image in images]
		yCoords = [int(round(image.getY()/float(image.getPixelHeight()))) for image in images]
		names = [image.getURL() for image in images]
		newNames = [str(names.index(name)).zfill(2)+".tif" for name in names]
		for name, newName in zip(names, newNames):
			shutil.copy(srcPath+"/"+name, path+"/"+newName)
		xCoords, yCoords = zero_center_coordinates(xCoords, yCoords)
		with open(tileConfPath, 'w') as f:
			f.write("# Define the number of dimensions we are working on\n")
			f.write("dim = 2\n")
			f.write("\n")
			f.write("# Define the image coordinates\n")
			for name, x, y in zip(newNames, xCoords, yCoords):
				f.write(name+";"+" ; (" + str(x) + "," + str(y)+")"+"\n")
		return names, newNames;

	
	def calculateStitching(self, zPosition, timePoint, params):
		'''
		Create an initial TileConfiguration from the meta-data in the work-folder 
		and use it for the stitching. Replace the TileConfiguration by the one
		created by the stitching.
		'''   
		path = self.experiment.getPath();
		names, newNames = self.createTileConfig(zPosition, timePoint, params.channel)
		if not os.path.exists(path+"/out"):
			os.mkdir(path+"/out")
		fusionMethod = params.fusion_method
		if "Max_" in fusionMethod:
			fusionMethod = fusionMethod.replace("Max_", "Max. ")
		if "Min_" in fusionMethod:
			fusionMethod = fusionMethod.replace("Min_", "Min. ")
		if "Linear_" in fusionMethod:
			fusionMethod = fusionMethod.replace("_", " ");	
		if "random" in fusionMethod:
			fusionMethod = "Intensity of random input tile"
		parameters = "type=[Positions from file] " + \
					 "order=[Defined by TileConfiguration] " + \
					 "directory=["+path+"/work/] " + \
					 "layout_file=TileConfiguration.txt " + \
					 "fusion_method=["+fusionMethod+"] " + \
					 "regression_threshold=" + str(params.regression_threshold) + " " +\
					 "max/avg_displacement_threshold=" + str(params.displacement_threshold) + " "+\
					 "absolute_displacement_threshold=" + str(params.abs_displacement_threshold) + " "+\
					 "compute_overlap " + \
					 "subpixel_accuracy " + \
					 "computation_parameters=[Save computation time (but use more RAM)] " + \
					 "image_output=[Write to disk] " \
					 "output_directory=["+path+"/out/] "
		now = datetime.now().time()
		print(now)
		IJ.run("Grid/Collection stitching", parameters)
		now = datetime.now().time()
		print(now)
		os.remove(path+"/work/TileConfiguration.txt")
		os.rename(path+"/work/TileConfiguration.registered.txt", path+"/work/TileConfiguration.txt")
		os.remove(path+"/out/img_t1_z1_c1")
		for newName in newNames:
			os.remove(path+"/work/"+newName)

	def applyStitching(self, params):
		path = self.experiment.getPath();
		dims = self.getDimensions()
		slices = dims[2]
		channels = dims[4]
		timePoints = dims[3]
		for c in range(1, channels+1):
			for t in range(0, timePoints):
				for z in range(1, slices+1):
					images = self.getImagesForZPosTimeAndChannel(z, t, c)
					names, newNames = self.copyImagesToWorkFolder(images)
					if params.pseudoflatfield>0:
						self.doPseudoFlatFieldCorrection(params.pseudoflatfield, path, newNames)
					if params.normalize:
						self.doNormalize(path, newNames)
					if params.rollingball>0:
						self.doBackgroundCorrection(params.rollingball, path, newNames)
					if params.subtract_background_radius>0:
						self.doSubtractBackground(params, path, newNames)
						
					self.runGridCollectionStitching()

					title = images[0].getURLWithoutField()
					os.rename(os.path.normpath(path+"/out/img_t1_z1_c1"), os.path.normpath(path+"/out/"+title))
					for name in newNames:
						os.remove(path+"/work/"+name)

	def doSubtractBackground(self, params, path, names):
		for name in names:
			IJ.open(path+"/work/"+name)
			imp = IJ.getImage()
			self.findAndSubtractBackground(params.subtract_background_radius, params.subtract_background_offset, params.subtract_background_iterations, params.subtract_background_skip)
			IJ.save(imp, path+"/work/"+name)
			imp.close()

	def findAndSubtractBackground(self, radius, offset, iterations, skipLimit):
		'''
		Find the background intensity value and subtract it from the current image.
		 
		Search for the maximum intensity value around pixels that are below or equal
		to the minimum intensity plus an offset in the image.
		 
		@param radius The radius in which the maximum around the small values is searched
		@param offset The intensity offset above the minimum intensity of the image
		@param iterations The number of times the procedure is repeated
		@param skipLimit The ratio of pixels with value zero above which the procedure is skipped
		@return Nothing
		'''
		imp = IJ.getImage()
		ip = imp.getProcessor();
		width = imp.getWidth()
		height = imp.getHeight()
		stats = imp.getStatistics()
		histogram = stats.histogram()
		ratio = histogram[0] / ((width * height) * 1.0)
		if ratio>skipLimit:
			IJ.run("HiLo");
			IJ.run("Enhance Contrast", "saturated=0.35")
			print('find and subtract background - skipped, ratio of 0-pixel is: ' + str(ratio))
			return
		for i in range(0, iterations):
			stats = imp.getStatistics()
			minPlusOffset = stats.min + offset
			currentMax = 0
			for x in range(0, width):
				for y in range(0, height):
					intensity = imp.getProcessor().getPixel(x,y)
					if intensity<=minPlusOffset: 
						value = self.getMaxIntensityAround(ip, x, y, stats.mean, radius, width, height)
						if value>currentMax:
							currentMax = value
			result = currentMax / ((i+1)*1.0);
			print('find and subtract background - iteration ' + str(i+1) + ', value = ' + str(result));
			IJ.run("Subtract...", "value=" + str(result))
		IJ.run("HiLo")
		IJ.run("Enhance Contrast", "saturated=0.35");

	def getMaxIntensityAround(self, ip, x, y, mean, radius, width, height):
		'''
		Find the maximal intensity value below mean in the radius around x,y
		 
		@param x (x,y) are the coordinates around which the maximum is searched
		@param y (x,y) are the coordinates around which the maximum is searched
		@param mean The mean value of the image, only values below mean are considered
		@radius The radius around (x,y) in which the maximum is searched
		@width The width of the image 
		@height The height of the image
		@return The maximum value below mean around (x,y) or zero
		'''
		max = 0;
		for i in range(x-radius, x+radius+1):
			if i>=0 and i<width:
				for j in range(y-radius, y+radius+1):
					if j>=0 and j<height:
						value = ip.getPixel(i,j);
						if value<mean and value>max:
							max = value
		return max

	def doBackgroundCorrection(self, radius, path, names):
		for name in names:
			IJ.open(path+"/work/"+name)
			imp = IJ.getImage()
			IJ.run(imp, "Subtract Background...", "rolling="+str(radius))
			IJ.save(imp, path+"/work/"+name)
			imp.close()
			
	def doNormalize(self, path, names):
		mins = []
		maxs = []
		means = []
		for name in names:
			IJ.open(path+"/work/"+name)
			imp = IJ.getImage()
			mins.append(imp.getStatistics().min)
			maxs.append(imp.getStatistics().max)
			means.append(imp.getStatistics().mean)
			imp.close()
		globalMean = max(means)
		i = 0
		for name in names:
			IJ.open(path+"/work/"+name)
			imp = IJ.getImage()
			IJ.run(imp, "Subtract...", "value=" + str(mins[i]));
			IJ.run(imp, "32-bit", "");
			IJ.run(imp, "Divide...", "value=" + str(maxs[i]-mins[i]));
			IJ.run(imp, "Multiply...", "value="+str(globalMean));
			ImageConverter.setDoScaling(False);
			IJ.run(imp, "16-bit", "");
			ImageConverter.setDoScaling(True);
			IJ.save(imp, path+"/work/"+name)
			imp.close()
			i = i + 1
			
	def doPseudoFlatFieldCorrection(self, radius, path, names):
		for name in names:
			IJ.open(path+"/work/"+name)
			imp = IJ.getImage()
			IJ.run("Pseudo flat field correction", "blurring="+str(radius)+" hide")
			IJ.save(imp, path+"/work/"+name)
			imp.close()

	def createStack(self, dims, params):
		slices = dims[2]
		channels = dims[4]
		timePoints = dims[3]
		path = self.experiment.getPath()
		for c in range(1, channels+1):
			for t in range(0, timePoints):
				imps = []	
				title = ""
				toBeDeleted = []
				for z in range(1, slices+1):
					images = self.getImagesForZPosTimeAndChannel(z, t, c)
					newImages = set()
					for image in images:
						newImages.add(image.getURLWithoutField())					
					for image in newImages:
						IJ.open(path + "/out/" + image)
						IJ.run(params.colours[c-1])
						toBeDeleted.append(path + "/out/" + image)
						imp = IJ.getImage()
						imps.append(imp)
						title = image
				if title:
					imp = ImagesToStack.run(imps)
					name = title[:6] + title[9:]
					IJ.save(imp, path + "/out/" + name)
					imp.close()
					for aPath in toBeDeleted:
						os.remove(aPath)
	
	def mergeChannels(self, dims, params):			
		slices = dims[2]
		channels = dims[4]
		if channels==1:
			return
		timePoints = dims[3]
		path = self.experiment.getPath()
		images = self.getImages()
		urlsChannel1 = [image.getURLWithoutField() for image in images if image.getChannel()==1] 
		if params.stack:
			urlsChannel1 = [url[:6] + url[9:] for url in urlsChannel1]
			urlsChannel1 = set(urlsChannel1)			
		toBeDeleted = []
		for url in urlsChannel1:
			images = []
			IJ.open(path + "/out/" + url)
			imp = IJ.getImage()
			toBeDeleted.append(path + "/out/" + url)
			images.append(url)
			for c in range(2, channels+1):
				newURL = url.replace("ch1", "ch"+str(c))
				IJ.open(path + "/out/" + newURL)
				toBeDeleted.append(path + "/out/" + newURL)
				images.append(newURL)
			options = ""
			for c in range(1, channels+1):
				options = options + "c"+str(c)+"="+images[c-1]+" "
			options = options + "create"
			IJ.run(imp, "Merge Channels...", options);
			imp = IJ.getImage()
			aFile = path + "/out/" + url.replace("ch1", "")
			IJ.save(imp, aFile)
			imp.close()
		for aPath in toBeDeleted:
			os.remove(aPath)

	def mip(self, dims, params):
		if not params.stack: 
			return
		path = self.experiment.getPath()
		url = self.getMergedImageName()
		images = []
		if params.merge:
			images.append(path + "/out/" + url)
		else:
			channels = dims[4]
			for c in range(1, channels+1):
				channelURL = url[:6] + "-ch" + str(c) + url[7:]
				images.append(path + "/out/" + channelURL)
		for url in images:
			IJ.open(url)
			imp = IJ.getImage()
			projImp = ZProjector.run(imp,"max")
			IJ.save(projImp, url)
			imp.close()
			projImp.close()
		
	def getImagesPerChannel(self, channels):
		allImages = self.getImages()
		res = []
		for c in range (1, channels + 1):
			filtered = [image for image in allImages if image.getChannel()==c]
			res.append(filtered);
		return res

	def getMergedImageName(self):
		allImages = self.getImages()
		image1 = allImages[0]
		url = image1.getURL()
		strippedURL = url[:6] + url[9:]
		strippedURL = strippedURL[:6] + strippedURL[9:]
		strippedURL = strippedURL[:7] + strippedURL[10:]
		return strippedURL
		
		
	def getImagesForZPosTimeAndChannel(self, zPosition, timePoint, channel):
		allImages = self.getImages()
		images = [image for image in allImages if image.getPlane()==zPosition and image.getChannel()==channel and image.getTime()==timePoint]
		return images

	def copyImagesToWorkFolder(self, images):
		srcPath = self.experiment.getPath()
		path = srcPath + "/work"
		names = [image.getURL() for image in images]
		newNames = [str(names.index(name)).zfill(2)+".tif" for name in names]
		for name, newName in zip(names, newNames):
			shutil.copy(srcPath+"/"+name, path+"/"+newName)
		return names, newNames

	def runGridCollectionStitching(self, computeOverlap=False):
		path = self.experiment.getPath();
		parameters = "type=[Positions from file] " + \
					 "order=[Defined by TileConfiguration] " + \
					 "directory=["+path+"/work/] " + \
					 "layout_file=TileConfiguration.txt " + \
					 "fusion_method=[Linear Blending] " + \
					 "regression_threshold=0.30 " + \
					 "max/avg_displacement_threshold=2.50 " + \
					 "absolute_displacement_threshold=3.50 "
		if computeOverlap: 
			parameters = parameters + "compute_overlap "
		parameters = parameters + \
					 "subpixel_accuracy " + \
					 "computation_parameters=[Save computation time (but use more RAM)] " + \
					 "image_output=[Write to disk] " \
					 "output_directory=["+path+"/out/] "
		IJ.run("Grid/Collection stitching", parameters)
		
	def createHyperstack(self):
		Interpreter.batchMode=True
		name = self.plate.getName()+"_"+self.getID()
		dims = self.getDimensions()
		print(dims)
		mosaic = IJ.createImage(name, "16-bit composite-mode", dims[0], dims[1], dims[4], dims[2], dims[3])
		if not mosaic: 
			 raise Exception('Image too big!')
		mosaic.show()
		pixelWidth = self.getPixelWidth()
		IJ.run(mosaic, "Set Scale...", "distance=1 known="+str(pixelWidth)+" unit=m");
		mosaic.show()
		images = self.getImages()
		xCoords = [int(round(image.getX()/float(pixelWidth))) for image in images]
		yCoords = [int(round(image.getY()/float(pixelWidth))) for image in images]
		xCoords, yCoords = zero_center_coordinates(xCoords, yCoords)		
		for image, x, y in zip(images, xCoords, yCoords):
			IJ.open(image.getFolder() + os.path.sep + image.getURL())
			imp = IJ.getImage()
			IJ.run(imp, "Copy", "")
			mosaic.setPosition(image.getChannel(), image.getPlane(), image.getTime())
			mosaic.paste(x, y, "Copy")
			imp.close()
		Interpreter.batchMode=False
		mosaic.show()	
		for c in range(1,dims[4]):
			mosaic.setPosition(c, 1, 1)
			IJ.run("Enhance Contrast", "saturated=0.35")
		mosaic.repaintWindow()
			
	def __str__(self):
		anID = self.getID();
		row = self.getRow();
		column = self.getColumn();
		nrOfImages = len(self.getImages())
		imagesString = "images";
		if (nrOfImages==1):
			 imagesString = "image";
		res = "Well ("+anID+", r=" + str(row) + ", c=" + str(column) + ", " + str(nrOfImages) + " " + imagesString +")"
		return res

class Image(object):

	def __init__(self, anID):
		self.id = anID

	def getID(self):
		return self.id

	def setState(self, state):
		self.state = state

	def getState(self):
		return self.state
		
	def setURL(self, url):
		self.url = url

	def getURL(self):
		return self.url
	
	def setRow(self, row):
		self.row = row

	def getRow(self):
		return self.row
		
	def setColumn(self, column):
		self.column = column

	def getColumn(self):
		return self.column

	def getField(self):
		return self.field

	def setField(self, field):
		self.field = field

	def getPlane(self):
		return self.plane

	def setPlane(self, plane):
		self.plane = plane
		
	def getTime(self):
		return self.time

	def setTime(self, time):
		self.time = time
		
	def getChannel(self):
		return self.channel

	def setChannel(self, channel):
		self.channel = channel

	def getWidth(self):
		return self.width

	def setWidth(self, width):
		self.width = width

	def getHeight(self):
		return self.height

	def setHeight(self, height):
		self.height = height

	def getX(self):
		return self.x

	def getY(self):
		return self.y

	def getZ(self):
		return self.z

	def setX(self, x):
		self.x = x

	def setY(self, y):
		self.y = y
	
	def setZ(self, z):
		self.z = z

	def setPixelWidth(self, pixelWidth):
		self.pixelWidth = pixelWidth

	def getPixelWidth(self):
		return self.pixelWidth

	def setPixelHeight(self, pixelHeight):
		self.pixelHeight = pixelHeight

	def getPixelHeight(self):
		return self.pixelHeight

	def setFolder(self, folder):
		self.folder = folder

	def getFolder(self):
		return self.folder

	def getURLWithoutField(self):
		url = self.getURL()
		res = url[:6] + url[9:]
		return res
		
	def __str__(self):
		res = "Image ("+self.getID()+", state="+self.getState()+", " + self.getURL() + ", r" + self.getRow() + ", c="+self.getColumn()+ ", f="+self.getField()+")"
		return res
	
class PhenixHCSExperiment(object):		
	@classmethod
	def fromIndexFile(cls, path):
		root = ET.parse(path).getroot()
		children = root.getchildren()
		experiment = PhenixHCSExperiment()
		experiment.setUser(children[0].text)
		experiment.setInstrumentType(children[1].text)
		experiment.setPlates(children[2])
		experiment.setWells(children[3])
		experiment.setMaps(children[4])
		experiment.setImages(children[5])
		experiment.setPath(os.path.dirname(path))
		return experiment

	def setPath(self, path):
		self.path = path

	def getPath(self):
		return self.path
	
	def setUser(self, user):
		self.user = user

	def getUser(self):
		return self.user

	def setInstrumentType(self, instrumentType):
		self.instrumentTYpe = instrumentType

	def getInstrumentType(self):
		return self.instrumentTYpe

	def getNrOfPlates(self):
		return len(self.getPlates());

	def getNrOfColumns(self):
		return 0;

	def getNrOfRows(self):
		return 0;

	def getNrOfWells(self):
		return len(self.getWells());

	def getPlates(self):
		return self.plates

	def setPlates(self, plates):
		self.plates = []
		plates = plates.getchildren()
		for plate in plates:
			self.plates.append(Plate(plate, self))

	def getWells(self):
		return self.wells

	def setWells(self, wells):
		self.wells = wells

	def getMaps(self):
		return self.maps

	def setMaps(self, maps):
		self.maps = maps

	def getImages(self):
		return self.images

	def setImages(self, images):
		self.images = images

	def getNrOfImages(self):
		return len(self.getImages())

	def getWell(self, anID, aPlate):
		for well in self.wells:
			if well[0].text==anID:
				imageData = []
				for i in range(3, len(well)):
					imageData.append(well[i])
				wellObject = Well(anID, well[1].text, well[2].text, imageData, self, aPlate)
				return wellObject
		return None 

	def getImage(self, anID):
		for image in self.images:
			if image[0].text==anID:
				result = Image(anID)
				result.setFolder(self.getPath())
				result.setState(image[1].text)
				result.setURL(image[2].text)
				result.setRow(image[3].text)
				result.setColumn(image[4].text)
				result.setField(image[5].text)
				result.setPlane(int(image[6].text))
				result.setTime(int(image[7].text))
				result.setChannel(int(image[8].text))
				result.setPixelWidth(float(image[15].text))
				result.setPixelHeight(float(image[16].text))
				result.setWidth(int(image[17].text))
				result.setHeight(int(image[18].text))
				result.setX(float(image[23].text))
				result.setY(float(image[24].text))
				result.setZ(float(image[25].text))
				return result
		return None
	
	def __str__(self):
		nrOfPlates = self.getNrOfPlates();
		nrOfWells = self.getNrOfWells();
		nrOfImages = self.getNrOfImages();
		platesString = "plates";
		if (nrOfPlates==1):
			 platesString = "plate";
		wellsString = "wells";
		if (nrOfWells==1):
			 wellsString = "well";
		imagesString = "images";
		if (nrOfImages==1):
			 imagesString = "image";
		res = "PhenixHCSExperiment ("+self.getUser()+", "+ self.getInstrumentType()+", "+str(self.getNrOfPlates()) + " " + platesString + ", "+str(self.getNrOfWells()) + " " + wellsString + ", " + str(self.getNrOfImages()) + " " + imagesString + ")"
		return res

if 'getArgument' in globals():
	if not hasattr(zip, '__call__'):
		del zip 					# the python function zip got overriden by java.util.zip, so it must be deleted to get the zip-function to work.
	args = getArgument()
	args = " ".join(args.split())
	print(args.split())
	main(args.split())
