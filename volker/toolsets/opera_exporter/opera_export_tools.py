import xml.etree.ElementTree as ET
from ij import IJ
import os
from ij import Prefs
from ij.gui import WaitForUserDialog
from ij.macro import Interpreter
from ij.plugin import ImagesToStack, ZProjector, RGBStackMerge, ImageCalculator
from ij.process import ImageConverter
from datetime import datetime
import shutil
import argparse
import re

_Z_STACK_FOLDER = "/stack/"
_PROJECT_FOLDER = "/projection/"
_Z_STACK_MOSAIC_FOLDER = "/stackMosaic/"
_PROJECT_MOSAIC_FOLDER = "/projectionMosaic/"
_PROJECT_MOSAIC_RGB_FOLDER = "/projectionMosaicRGB/"
_PROJECT_MOSAIC_CHAN_FOLDER = "/projectionMosaicChannel/"
_WORK_FOLDER = "/work/"


def main(args):
	parser = getArgumentParser()
	params = parser.parse_args(args)
	experiment = PhenixHCSExperiment.fromIndexFile(params.index_file);
	
	srcPath = experiment.getPath();
	print(experiment)
	print(srcPath)
	wells = experiment.getPlates()[0].getWells()
	if not params.wells == 'all':
		listOfWellIDS = splitIntoChunksOfSize(params.wells, 4)	
	for well in wells:
		if params.wells=='all' or well.getID() in listOfWellIDS:
			dims = well.getDimensions()
			zSize = dims[2]
			zPos = params.slice
			if zPos==0:
				zPos = max(zSize / 2,1)
			IJ.log("Create Tile Config")
			if params.stitchOnMIP:
				names, newNames = well.createTileConfig(1, 0, params.channel)
			else:
				names, newNames = well.createTileConfig(zPos, 0, params.channel)
			
			
			if params.stitchOnMIP:
				IJ.log("Create MIP to calculate Stitching")
				well.createMIPFromInputImages(dims, params, params.channel)
			else:
				IJ.log("Copy fields to calculate Stitching");
				well.copyImages(srcPath, srcPath+"/work/", names, newNames)

			IJ.log("Calculate Stitching");
			well.calculateStitching(params)
			for newName in newNames:
				os.remove(srcPath+"/work/"+newName)

			#Fields
			if params.zStackFields:
				IJ.log("Create zStacks Fields")
				well.createStack(dims, params, outputFolder=_Z_STACK_FOLDER, exportComposite=params.zStackFieldsComposite) # + rename later

			if params.projectionFields:
				IJ.log("Create projection Fields")
				well.createMIP(dims, params, outputFolder=_PROJECT_FOLDER, exportComposite=params.projectionFieldsComposite) # + rename later
		
			if params.zStackMosaic:
				IJ.log("Applying Stitching on each Z")
				well.applyStitching(params, outputFolder=_Z_STACK_MOSAIC_FOLDER, exportComposite=params.zStackMosaicComposite)
				if params.projectionMosaic:
					IJ.log("Projecting Mosaic")
					well.projectMosaic(params, stackFolder=_Z_STACK_MOSAIC_FOLDER, outputFolder=_PROJECT_MOSAIC_FOLDER, exportComposite=params.projectionMosaicComposite) 
			else:
				if params.projectionMosaic:
					IJ.log("Applying Stitching on projection")
					well.applyStitchingProjection(params, outputFolder=_PROJECT_MOSAIC_FOLDER, exportComposite=params.projectionMosaicComposite)
			
			if params.projectionMosaicRGB:
				if params.projectionMosaic:
					well.convertToRGB(params, inputFolder=_PROJECT_MOSAIC_FOLDER, outputFolder=_PROJECT_MOSAIC_RGB_FOLDER)
				else:
					if not params.zStackMosaic:
						well.applyStitchingProjection(params, outputFolder=_WORK_FOLDER, exportComposite=params.projectionMosaicComposite)
					else:
						well.projectMosaic(params, stackFolder=_Z_STACK_MOSAIC_FOLDER, outputFolder=_WORK_FOLDER, exportComposite=params.projectionMosaicComposite)
					well.convertToRGB(params, inputFolder=_WORK_FOLDER, outputFolder=_PROJECT_MOSAIC_RGB_FOLDER)
				
			channelList = list(params.channelRGB)

			for i in range(len(channelList)):
				if channelList[i] =="1":
					if params.projectionMosaic:
						well.convertToRGB(params, inputFolder=_PROJECT_MOSAIC_FOLDER, outputFolder=_PROJECT_MOSAIC_CHAN_FOLDER,channelExport=str(i))
					else:
						if not params.zStackMosaic:
							well.applyStitchingProjection(params, outputFolder=_WORK_FOLDER, exportComposite=params.projectionMosaicComposite) # ???
						else:
							well.projectMosaic(params, stackFolder=_Z_STACK_MOSAIC_FOLDER, outputFolder=_WORK_FOLDER, exportComposite=params.projectionMosaicComposite,channelExport=str(i))
						well.convertToRGB(params, inputFolder=_WORK_FOLDER, outputFolder=_PROJECT_MOSAIC_CHAN_FOLDER,channelExport=str(i))
			well.renameAllOutputs(params)
			
			
def getArgumentParser():
	parser = argparse.ArgumentParser(description='Create a mosaic from the opera images using the index file and fiji-stitching.')
	parser.add_argument("--wells", "-w", default='all', help='either "all" or a string of the form "01010102" defining the wells to be exported')
	parser.add_argument("--slice", "-s", default=0, type=int, help='the slice used to calculate the stitching, 0 for the middle slice')
	parser.add_argument("--channel", "-c", default=1, type=int, help='the channel used to calculate the stitching')

	parser.add_argument("--stitchOnMIP", default=False, action='store_true', help='use the z-projection to calculate the stitching')

	parser.add_argument("--zStackFields",default=False,action='store_true',help='export the z-stacks of fields')
	parser.add_argument("--zStackFieldsComposite",default=False,action='store_true',help='export the z-stacks of fields composite')
	parser.add_argument("--projectionFields",default=False,action='store_true',help='export the projection of fields')
	parser.add_argument("--projectionFieldsComposite",default=False,action='store_true',help='export the projection of fields composite')
	parser.add_argument("--zStackMosaic",default=False,action='store_true',help='export the z-stacks of mosaics')
	parser.add_argument("--zStackMosaicComposite",default=False,action='store_true',help='export the z-stacks of mosaics composite')
	parser.add_argument("--projectionMosaic",default=False,action='store_true',help='export the projection of mosaics')
	parser.add_argument("--projectionMosaicComposite",default=False,action='store_true',help='export the projection of mosaics composite')
	parser.add_argument("--projectionMosaicRGB",default=False,action='store_true',help='export the projection of mosaics RGB')
	parser.add_argument("--channelRGB",default="0000",help='Each character is a flag to export a channel, from left to right (1,2,3,4)')

	parser.add_argument("--computeOverlap", default=False, action='store_true',help='Compute the overlap or use approximate grid coordinates')
	parser.add_argument("--normalize", default=False, action='store_true', help='normalize the intensities of the images in a mosaic')
	parser.add_argument("--fusion-method", default="Linear_Blending", help='the fusion method, "Linear_Blending", "Average", "Median" ,"Max_Intensity", "Min_Intensity" or "random"')
	parser.add_argument("--regression-threshold", "-r", default=0.3, type=float, help='if the regression threshold between two images after the individual stitching are below that number they are assumed to be non-overlapping')
	parser.add_argument("--displacement-threshold", "-d", default=2.5, type=float, help='max/avg displacement threshold')
	parser.add_argument("--abs-displacement-threshold", "-a", default=3.5, type=float, help='removes links between images if the absolute displacement is higher than this value')
	
	parser.add_argument("--index-flatfield", default=False, action='store_true', help='background removal using the flatfield profile found in the index file')
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

		print(len(allImages))
		print(str(zPosition)+"/"+str(channel)+"/"+str(timePoint));
		for image in allImages:
			print(str(image.getPlane())+"/"+str(image.getChannel())+"/"+str(image.getTime()));
		
		images = [image for image in allImages if image.getPlane()==zPosition and image.getChannel()==channel and image.getTime()==timePoint]
		print(len(images))
		xCoords = [int(round(image.getX()/float(image.getPixelWidth()))) for image in images]
		print(len(xCoords))
		yCoords = [int(round(image.getY()/float(image.getPixelHeight()))) for image in images]
		print(len(yCoords))
		names = [image.getURL() for image in images]
		newNames = [str(names.index(name)).zfill(2)+".tif" for name in names]
		xCoords, yCoords = zero_center_coordinates(xCoords, yCoords)
		with open(tileConfPath, 'w') as f:
			f.write("# Define the number of dimensions we are working on\n")
			f.write("dim = 2\n")
			f.write("\n")
			f.write("# Define the image coordinates\n")
			for name, x, y in zip(newNames, xCoords, yCoords):
				f.write(name+";"+" ; (" + str(x) + "," + str(y)+")"+"\n")
		return names, newNames;


	def copyImages(self,srcPath, path, names, newNames):
		for name, newName in zip(names, newNames):
			shutil.copy(srcPath+"/"+name, path+"/"+newName)
		
	def calculateStitching(self, params):
		'''
		Create an initial TileConfiguration from the meta-data in the work-folder 
		and use it for the stitching. Replace the TileConfiguration by the one
		created by the stitching.
		'''   	
		srcPath = self.experiment.getPath();
		if not os.path.exists(srcPath+"/out"):
			os.mkdir(srcPath+"/out")
		computeOverlap = params.computeOverlap
		#computeOverlap = False
		computeString = ""
		if computeOverlap:
			computeString = "compute_overlap "
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
					 "directory=["+srcPath+"/work/] " + \
					 "layout_file=TileConfiguration.txt " + \
					 "fusion_method=["+fusionMethod+"] " + \
					 "regression_threshold=" + str(params.regression_threshold) + " " +\
					 "max/avg_displacement_threshold=" + str(params.displacement_threshold) + " "+\
					 "absolute_displacement_threshold=" + str(params.abs_displacement_threshold) + " "+\
					 computeString + \
					 "subpixel_accuracy " + \
					 "computation_parameters=[Save computation time (but use more RAM)] " + \
					 "image_output=[Write to disk] " \
					 "output_directory=["+srcPath+"/out/] "

		now = datetime.now().time()
		print(now)
		IJ.run("Grid/Collection stitching", parameters)
		now = datetime.now().time()
		print(now)
		if computeOverlap:
			print("Writing new Tile Configuration")
			os.remove(srcPath+"/work/TileConfiguration.txt")
			os.rename(srcPath+"/work/TileConfiguration.registered.txt", srcPath+"/work/TileConfiguration.txt")
		os.remove(srcPath+"/out/img_t1_z1_c1")
		
	def executeStitching(self, params, path, channel=1, newNames=None, outputFolder='out'):
		if newNames==None:
			srcPath = self.experiment.getPath()
			path = srcPath + "/work/"
			nbFiles = len(os.listdir(path))
			newNames = [str(i).zfill(2)+".tif" for i in range(nbFiles-1)]
			
		if params.index_flatfield:
			self.doIndexFlatFieldCorrection(path,newNames,channel)

		if params.pseudoflatfield>0:
			self.doPseudoFlatFieldCorrection(params.pseudoflatfield, path, newNames)
		if params.normalize:
			self.doNormalize(path, newNames)
		if params.rollingball>0:
			self.doBackgroundCorrection(params.rollingball, path, newNames)
		if params.subtract_background_radius>0:
			self.doSubtractBackground(params, path, newNames)
			
		self.runGridCollectionStitching(outputFolder=outputFolder)
	
	def applyStitching(self, params, outputFolder ='/out/', exportComposite=False):
		dims = self.getDimensions()
		slices = dims[2]
		timePoints = dims[3]
		channels = dims[4]

		path = self.experiment.getPath()
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)
			
		rgbStackMerge = RGBStackMerge()
		
		for t in range(0, timePoints):
			channelImps = []
			for c in range(1, channels+1):
				imps = []
				for z in range(1, slices+1):
					images = self.getImagesForZPosTimeAndChannel(z, t, c)
					names, newNames = self.copyImagesToWorkFolder(images)

					self.executeStitching(params, path, c, newNames, outputFolder=outputFolder)
					
					imps.append(IJ.getImage())
					
					title = images[0].getURLWithoutField()
					#print(os.path.normpath(outputPath+"img_t1_z1_c1"))
					#os.rename(os.path.normpath(outputPath+"img_t1_z1_c1"), os.path.normpath(outputPath+title))
					#
					for name in newNames:
						os.remove(path+"/work/"+name)
				imp = ImagesToStack.run(imps)
				name = title[:6] + title[9:]
				IJ.log("Creating Z-Stack of mosaic : "+name)
				channelImps.append(imp)
				IJ.save(imp, outputPath + name)
			if exportComposite:
				composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
				name = title[:6] +"-"+title[13:]
				IJ.log("+ Composite: "+name);
				IJ.save(composite, outputPath + name)


	def applyStitchingProjection(self, params, outputFolder ='/out/',exportComposite=False):
		#if outputFolder == _WORK_FOLDER:
		#	self.emptyWorkFolder()
				
		dims = self.getDimensions()
		slices = dims[2]
		timePoints = dims[3]
		channels = dims[4]

		path = self.experiment.getPath()
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)

		rgbStackMerge = RGBStackMerge()
		
		for t in range(0, timePoints):
			channelImps = []
			for c in range(1, channels+1):	
				title = self.createMIPFromInputImages(dims, params, c)
				self.executeStitching(params, path, channel=c, outputFolder=outputFolder)
				imp = IJ.getImage()

				name = title[:6] +"-"+ title[13:]
				channelImps.append(imp)
				IJ.save(imp, outputPath + name)

			if exportComposite:
				composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
				name = title[:6] +"-"+title[16:]
				IJ.log("+ Composite: "+name);
				IJ.save(composite, outputPath + name)
			else:
				for im in channelImps:
					im.close();		

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

	def doIndexFlatFieldCorrection(self, path, names, chan):
		for name in names:
			IJ.open(path+"/work/"+name)
			imp1 = IJ.getImage()
			IJ.open(path+"/flatfield/"+str(chan)+".tiff")
			imp2 = IJ.getImage()
			imp3 = ImageCalculator.run(imp1, imp2, "Subtract create");                                                                                                   
			IJ.save(imp3, path+"/work/"+name)
			imp1.close()
			imp2.close()
			imp3.close()

	def doPseudoFlatFieldCorrection(self, radius, path, names):
		for name in names:
			IJ.open(path+"/work/"+name)
			imp = IJ.getImage()
			IJ.run("Pseudo flat field correction", "blurring="+str(radius)+" hide")
			IJ.save(imp, path+"/work/"+name)
			imp.close()

	def createStack(self, dims, params, outputFolder='/out/', exportComposite=False):
		slices = dims[2]
		timePoints = dims[3]
		channels = dims[4]

		path = self.experiment.getPath()
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)

		rgbStackMerge = RGBStackMerge()
		
		fields = self.getFields()
		for t in range(0, timePoints):
			for f in range(len(fields)):
				channelImps = []
				for c in range(1, channels+1):
					imps = []
					for z in range(1, slices+1):
						images = self.getImagesForZPosTimeAndChannel(z, t, c)
						image = images[f].getURL()
						IJ.open(path + "/" + image)
						IJ.run(params.colours[c-1])
						#toBeDeleted.append(path + "/" + image)
						imp = IJ.getImage()
						imps.append(imp)
					imp = ImagesToStack.run(imps)
					name = image[:9] + image[12:]
					IJ.log("Creating Z-Stack of image : "+name)
					channelImps.append(imp)
					IJ.save(imp, outputPath + name)
					#if exportComposite:
					#imp.close()
					#for aPath in toBeDeleted:
					#os.remove(aPath)
				if exportComposite:
					composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
					name = name[:10] + name[13:]
					IJ.log("+ Composite: "+name);
					IJ.save(composite, outputPath + name)
	
	def createMIP(self, dims, params, outputFolder='/work/', exportComposite=False):
		slices = dims[2]
		timePoints = dims[3]
		channels = dims[4]

		path = self.experiment.getPath()
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)

		rgbStackMerge = RGBStackMerge()

		fields = self.getFields()
		for t in range(0, timePoints):
			index = 0
			for f in fields:
				channelImps = []
				for c in range(1, channels+1):
					images = self.getImagesForTimeFieldAndChannel(t, f, c)
					imps = []	
					title = ""
					for image in images:
						IJ.open(path + "/" + image.getURL())
						IJ.run(params.colours[c-1])
						title = image.getURL()
						imp = IJ.getImage()
						imps.append(imp)
					if title:	
						imp = ImagesToStack.run(imps)
						name = title[:9] + title[12:]
						IJ.log("Creating Projection of image : "+name)
						projImp = ZProjector.run(imp,"max")
						url = outputPath + name
						channelImps.append(projImp)
						IJ.save(projImp, url)
						imp.close()
						projImp.close()

				if exportComposite:
					composite = rgbStackMerge.mergeHyperstacks(channelImps,False)
					name = title[:9] + title[12:13] + title[16:]
					IJ.log("+ Composite: "+name);
					IJ.save(composite, outputPath + name)
				index = index + 1

	def createMIPFromInputImages(self, dims, params, channel, outputFolder='/work/'):
		slices = dims[2]
		timePoints = dims[3]
		path = self.experiment.getPath()
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)
			
		fields = self.getFields()
		for t in range(0, timePoints):
			index = 0
			for f in fields:
				images = self.getImagesForTimeFieldAndChannel(t, f, channel)
				imps = []	
				title = ""
				for image in images:
					IJ.open(path + "/" + image.getURL())
					IJ.run(params.colours[channel-1])
					title = image.getURL()
					imp = IJ.getImage()
					imps.append(imp)
				if title:	
					imp = ImagesToStack.run(imps)
					name = title[:9] + title[12:]
					projImp = ZProjector.run(imp,"max")
					url = outputPath + str(index).zfill(2)+".tif"
					IJ.save(projImp, url)
					imp.close()
					projImp.close()
				index = index + 1
		return title

	def getImagesInFolder(self,inputPath,getFullPath=False,contains=""):

		coordName = "r"+str(self.getRow()).zfill(2)+"c"+str(self.getColumn()).zfill(2)
		if getFullPath:
			imagesURL = [os.path.join(inputPath, f) for f in os.listdir(inputPath) if (os.path.isfile(os.path.join(inputPath, f)) and coordName in f and contains in f)]
		else:
			imagesURL = [f for f in os.listdir(inputPath) if (os.path.isfile(os.path.join(inputPath, f)) and coordName in f and contains in f)]
		return imagesURL

	def projectMosaic(self, params, stackFolder=_Z_STACK_MOSAIC_FOLDER, outputFolder=_PROJECT_MOSAIC_FOLDER, exportComposite=False,channelExport="All"):
		#if outputFolder == _WORK_FOLDER:
		#	self.emptyWorkFolder()
				
		path = self.experiment.getPath()
		stackPath = path + stackFolder
		containsString = "ch"
		if channelExport != "All":
			channelNumber = str(int(channelExport) + 1)
			containsString = containsString + channelNumber
		imagesURL = self.getImagesInFolder(stackPath,getFullPath=True,contains="ch")
		self.mipImages(imagesURL, outputFolder=outputFolder)
			
	def convertToRGB(self, params, inputFolder=_PROJECT_MOSAIC_FOLDER, outputFolder=_PROJECT_MOSAIC_RGB_FOLDER, channelExport="All",invert=False):
		path = self.experiment.getPath()
		inputPath = path + inputFolder
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)
		containsString = "ch"
		if channelExport != "All":
			channelNumber = str(int(channelExport) + 1)
			containsString = containsString + channelNumber
		imagesURL = self.getImagesInFolder(inputPath,getFullPath=False,contains=containsString)
		options = ""
		itt = 1
		for url in imagesURL:
			if channelExport != "All":
				channelMin = Prefs.get("operaExportTools.channel"+str(channelNumber)+"Min",0)
				channelMax = Prefs.get("operaExportTools.channel"+str(channelNumber)+"Max",255)
			else:
				channelMin = Prefs.get("operaExportTools.channel"+str(itt)+"Min",0)
				channelMax = Prefs.get("operaExportTools.channel"+str(itt)+"Max",255)
			IJ.log("Min="+str(channelMin)+"Max="+str(channelMax))
			IJ.open(inputPath+url)
			IJ.setMinAndMax(channelMin,channelMax)
			options= options +"c"+str(itt)+"="+url+" "
			itt=itt+1
			
		if channelExport == "All":
			IJ.run("Merge Channels...", options)
			imp = IJ.getImage()
			aFile = outputPath + imagesURL[0][:7] + imagesURL[0][10:]
		else:
			imp = IJ.getImage()
			IJ.run(imp, "8-bit", "stack");
			aFile = outputPath + imagesURL[0]
		
		if invert:
			IJ.run(imp, "Invert", "stack");
		IJ.save(imp, aFile)
		imp.close()

			
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

	def mipImages(self, images, outputFolder="/out/"):
		path = self.experiment.getPath()
		outputPath = path + outputFolder
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)
			
		for url in images:
			print("mipImages : Opening "+url)
			IJ.open(url)
			title = url.split("/")
			imp = IJ.getImage()
			projImp = ZProjector.run(imp,"max")
			IJ.save(projImp, outputPath + title[-1])
			imp.close()
			projImp.close()
	
	def getImagesPerChannel(self, channels):
		allImages = self.getImages()
		res = []
		for c in range (1, channels + 1):
			filtered = [image for image in allImages if image.getChannel()==c]
			res.append(filtered);
		return res

	def getImagesForTimeFieldAndChannel(self, timePoint, field, channel):
		allImages = self.getImages()
		images = [image for image in allImages if image.getTime()==timePoint and image.getChannel()==channel and image.getField()==field]
		return images

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
		path = srcPath + _WORK_FOLDER
		names = [image.getURL() for image in images]
		newNames = [str(names.index(name)).zfill(2)+".tif" for name in names]
		for name, newName in zip(names, newNames):
			shutil.copy(srcPath+"/"+name, path+"/"+newName)
		return names, newNames

	def emptyWorkFolder(self):
		srcPath = self.experiment.getPath()
		path = srcPath + _WORK_FOLDER
		shutil.rmtree(path)
		

	def runGridCollectionStitching(self, computeOverlap=False , outputFolder = "/out/"):
		path = self.experiment.getPath();
		outputPath = path+outputFolder;
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)
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
					 "image_output=[Fuse and display] "
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

	
	def renameAllOutputs(self,params):
		wellName = self.getName()
		if params.zStackFields:
			self.renameImagesInFolder(_Z_STACK_FOLDER,_Z_STACK_FOLDER + "/" + wellName + "/")
		if params.projectionFields:
			self.renameImagesInFolder(_PROJECT_FOLDER,_PROJECT_FOLDER + "/" + wellName + "/")
		if params.zStackMosaic:
			self.renameImagesInFolder(_Z_STACK_MOSAIC_FOLDER,_Z_STACK_MOSAIC_FOLDER)
			
		if params.projectionMosaic:
			self.renameImagesInFolder(_PROJECT_MOSAIC_FOLDER,_PROJECT_MOSAIC_FOLDER)
			
		if params.projectionMosaicRGB:
			self.renameImagesInFolder(_PROJECT_MOSAIC_RGB_FOLDER,_PROJECT_MOSAIC_RGB_FOLDER)

		channelList = list(params.channelRGB)

		for i in range(len(channelList)):
			if channelList[i] == "1":
				self.renameImagesInFolder(_PROJECT_MOSAIC_CHAN_FOLDER,_PROJECT_MOSAIC_CHAN_FOLDER)
				break
		

	def renameImagesInFolder(self,inputFolder,outputFolder):
		path = self.experiment.getPath()
		inputPath  = path + inputFolder
		outputPath = path + outputFolder
		
		imagesURL = self.getImagesInFolder(inputPath,getFullPath=False,contains="")

		wellName = self.getName()
		
		IJ.log("Renaming images of well "+wellName+": From ["+inputPath+"] To ["+outputPath+"]"); 
		if not os.path.isdir(outputPath):
			os.mkdir(outputPath)

		for image in imagesURL:
			os.rename(inputPath+image,outputPath+wellName+image[6:])
			
	def getName(self):
		path = self.experiment.getPath()
		namesFile = "/wellNames.txt"
		
		row = self.getRow();
		column = self.getColumn();
		
		checkString = str(row).zfill(2) + str(column).zfill(2) + ":"
		
		resultName ="r" +  str(row).zfill(2) + "c" + str(column).zfill(2)
		
		if os.path.isfile(os.path.join(path+namesFile)):
			file = open(os.path.join(path+namesFile))
			wellLine =  [line for line in file if line.startswith(checkString)]
			resultName = resultName+""+wellLine[0].split(":")[-1]
		return resultName[:-1]
	
			
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
