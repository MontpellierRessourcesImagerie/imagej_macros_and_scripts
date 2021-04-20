import xml.etree.ElementTree as ET
from ij import IJ
import os
from ij.gui import WaitForUserDialog

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
				width = image.getWidth()
			if image.getHeight()>height: 
				height = image.getHeight()
		res = (max(xCoords)+width, max(yCoords)+height, len(slices), len(frames), len(channels))
		return res

	def createHyperstack(self):
		name = self.plate.getName()+"_"+self.getID()
		dims = self.getDimensions()
		print(dims)
		mosaic = IJ.createImage(name, "16-bit composite-mode", dims[0], dims[1], dims[4], dims[2], dims[3])
		mosaic.show()
		pixelWidth = self.getPixelWidth()
		print("pixelWidth: "+str(pixelWidth))
		IJ.run(mosaic, "Set Scale...", "distance=1 known="+str(pixelWidth)+" unit=m");
		mosaic.show()
		images = self.getImages()
		xCoords = [int(round(image.getX()/pixelWidth)) for image in images]
		yCoords = [int(round(image.getY()/pixelWidth)) for image in images]
		xCoords, yCoords = zero_center_coordinates(xCoords, yCoords)		
		for image, x, y in zip(images, xCoords, yCoords):
			IJ.open(image.getFolder() + os.path.sep + image.getURL())
			imp = IJ.getImage()
			IJ.run(imp, "Copy", "")
			mosaic.setPosition(image.getChannel(), image.getPlane(), image.getTime())
			mosaic.paste(x, y, "Copy")
			imp.close()
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

	
experiment = PhenixHCSExperiment.fromIndexFile("/media/baecker/DONNEES1/mri/in/2020/benoit/Index.idx.xml")
print(experiment)
wells = experiment.getPlates()[0].getWells()
well = wells[0]
print(well)
well.createHyperstack()

# print(experiment)
# firstPlate = experiment.getPlates()[0]
# print(firstPlate)
# wells = firstPlate.getWells();

