import xml.etree.ElementTree as ET
from ij import IJ
import os
from ij.gui import WaitForUserDialog
from ij.macro import Interpreter
from datetime import datetime
import shutil

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
				self.images.append(experiment.getImage(data.attrib['id']))
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

	
	def calculateStitching(self, zPosition, timePoint, channel):
		'''
		Create an initial TileConfiguration from the meta-data in the work-folder 
		and use it for the stitching. Replace the TileConfiguration by the one
		created by the stitching.
		'''   
		path = self.experiment.getPath();
		names, newNames = self.createTileConfig(zPosition, timePoint, channel)
		if not os.path.exists(path+"/out"):
			os.mkdir(path+"/out")
		parameters = "type=[Positions from file] " + \
					 "order=[Defined by TileConfiguration] " + \
					 "directory=["+path+"/work/] " + \
					 "layout_file=TileConfiguration.txt " + \
					 "fusion_method=[Linear Blending] " + \
					 "regression_threshold=0.30 " + \
					 "max/avg_displacement_threshold=2.50 " + \
					 "absolute_displacement_threshold=3.50 " + \
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

	def applyStitching(self):
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
					self.runGridCollectionStitching()
					title = images[0].getURLWithoutField()
					os.rename(path+"/out/img_t1_z1_c1", path+"/out/"+title)
					for name in newNames:
						os.remove(path+"/work/"+name)
					
	def getImagesForZPosTimeAndChannel(self, zPosition, timePoint, channel):
		allImages = self.getImages()
		images = [image for image in allImages if image.getPlane()==zPosition and image.getChannel()==channel and image.getTime()==timePoint]
		return images

	def copyImagesToWorkFolder(self, images):
		srcPath = self.experiment.getPath();
		path = srcPath + "/work";
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

	
experiment = PhenixHCSExperiment.fromIndexFile("D:/MRI/Volker/Sensorion Opera/Sensorion_20x_PreciScanXYZ_20210219__2021-02-19T14_40_00-Measurement 1b/Images/Index.idx.xml")
print(experiment)

wells = experiment.getPlates()[0].getWells()

for well in wells:
	well.calculateStitching(17, 0, 1)
	well.applyStitching()	

"""
for well in wells:
	print("Processing well " + well.getID() + " - " + str(counter) + "/" + str(size))
	try:  
		well.createHyperstack()
		imp =IJ.getImage()
		IJ.saveAs(imp, "Tiff", "D:/MRI/Volker/Sensorion Opera/Sensorion_5Xto20x_Av1_part2_20210401__2021-04-01T19_12_49-Measurement 1b/out/"+well.getID()+".tif")
		imp.close()
	except Exception as e:
		print str(e)
	counter = counter + 1
""" 
print("DONE!");

# print(experiment)
# firstPlate = experiment.getPlates()[0]
# print(firstPlate)
# wells = firstPlate.getWells();

