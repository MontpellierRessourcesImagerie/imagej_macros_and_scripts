/**
  *  Measure in FLIM-FRET images for each cell the total volume of the cell and the volume occupied by values above 
  *  a fixed threshold.
  *   
  *  written 2019 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *  in cooperation with Claire Dupont
  **
*/

var _SUBTRACT_BACKGROUND_RADIUS = 1;
var _SUBTRACT_BACKGROUND_OFFSET = 1;
var _SUBTRACT_BACKGROUND_ITERATIONS = 2;
var _LOWER_THRESHOLD = 2049;
var _UPPER_THRESHOLD = 4092;
var _TABLE_TITLE = "FLIM FRET Tool volumes";
var _MAX_SIZE = 1000000000000000000000000000000.0000;
var _MIN_SIZE = 10;
var _CREATE_CONTROL_IMAGE = true;
var _CONTROL_FOLDER = "control"
var _EXT = "tif";
var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/FLIM-FRET_Volume_Tool";

macro "HELP for the FLIM/FRET Volume (f1) Action Tool - C506D5dD72D7eD8eDbdDc2Df6Df7C000D16D1aD1bD3cD5eDecDf4C50bD55D56D66D9cDb7DbaDc7Dc8Cb05D35D49D4aD64D6aD6bD74D7aD7bDa3Db4Dc5Dd4Dd5De8C302D18D25D2bD43D62DaeDd2DdcDe3DebDf5Ca09D36D37D54D5bD65D68D76D7dD8aD97Da5Da7Da8Db2Db3Dc4Ca07D27D29D34D38D48D4bD63D6dD84D86D92Db6Dc6Dd3DdaDdbDe5C101D15D17D24D33D4dD81D91Da1Db1DbeDcdC80bD44D45D46D57D5cD87D88D8dD98D9dDa9DadDbbDbcDc9DcaCb07D28D58D59D5aD69D6cD79D7cD93D94D95D96Da4Dd6Dd9Ca03D2aD39D3aD3bD53D75D85Db5De9DeaDf8C90bD47D73D78D83D89D8bD8cD99D9aDa6Dc3DcbDd7Dd8De6De7C705D26D4cD6eD82D9eDa2DccDe4C100D19D52D9fDf9C60cD67D77D9bDaaDabDacDb8Db9" {
	 run('URL...', 'url='+_URL);
}

macro 'help for the FLIM/FRET Volume Tool [f1]' {
	run('URL...', 'url='+_URL);
}

macro "Measure Volumes in Current Image (f2) Action Tool - C037T4d14m" {
	 measureCells();
}

macro "Measure Volumes in Current Image (f2) Action Tool Options" {
	Dialog.create("FLIM/FRET Volume Tool Options");
	Dialog.addNumber("lower threshold: ", _LOWER_THRESHOLD);
	Dialog.addNumber("upper threshold: ", _UPPER_THRESHOLD);
    Dialog.addCheckbox("create control image", _CREATE_CONTROL_IMAGE);
    Dialog.show();
    _LOWER_THRESHOLD = Dialog.getNumber();
    _UPPER_THRESHOLD = Dialog.getNumber();
    _CREATE_CONTROL_IMAGE = Dialog.getCheckbox();
}

macro 'measure volumes in current image [f2]' {
	measureCells();
}

macro "Batch Measure Volumes (f3) Action Tool - C037T4d14b" {
	 measureCellsBatch();
}

macro 'batch measure images [f3]' {
	measureCellsBatch();
}


function measureCellsBatch() {
	dir = getDirectory("Please select the input folder!");
	files = getFileList(dir);
	images = newArray();
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	startTimeStamp = "" + year + "-" + (month + 1)+"-"+dayOfMonth+"--"+hour+"."+minute+"."+second+"."+msec;
	for(i=0; i<files.length; i++) {
		if (endsWith(files[i], ".tif")) images = Array.concat(images, files[i]);
	}
	File.makeDirectory(dir + _CONTROL_FOLDER);
	for (i = 0; i < images.length; i++) {
		image = images[i];
		open(dir + image);
		measureCells();
		saveAs("Tiff", dir + _CONTROL_FOLDER + "/" + image);
		close();
		if (nImages>0) close();
	}
	selectWindow(_TABLE_TITLE);
	saveAs("Text", dir + _TABLE_TITLE + "-" + startTimeStamp + ".xls");
}

function measureCells() {
	run("Options...", "iterations=1 count=1 black");
	createTable(_TABLE_TITLE);
	
	inputImageID = getImageID();
	setBatchMode(true);
	numberOfCells = createCellsIndexdMask(inputImageID);
	setBatchMode(false);
	
	cellsIndexMaskID = getImageID();
	setBatchMode(true);
	for (i = 1; i <= numberOfCells; i++) {
		measureCell(cellsIndexMaskID, inputImageID, i, _LOWER_THRESHOLD, _UPPER_THRESHOLD, _TABLE_TITLE);
	}
	setBatchMode(false);
	if (_CREATE_CONTROL_IMAGE) createControlImage(inputImageID, cellsIndexMaskID, numberOfCells, _TABLE_TITLE, _LOWER_THRESHOLD, _UPPER_THRESHOLD);
}

// needs the table with the measurements of the cells, the objects map and the input image to be open.
function createControlImage(inputImageID, cellsIndexMaskID, numberOfCells, tableTitle, lowerThreshold, upperThreshold) {
	selectImage(inputImageID);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
	getMinAndMax(min, max);
	title = getTitle();
	channelOneID = createOutputImage(title, 1, inputImageID);
	channelOneTitle = getTitleOfImage(channelOneID);
	channelTwoID = createOutputImage(title, 2, inputImageID);
	channelTwoTitle = getTitleOfImage(channelTwoID);
	for (i = 1; i <= numberOfCells; i++) {
		maskOfCellID = createMaskOfCell(cellsIndexMaskID, i);
		
		inputImageTitle = getTitleOfImage(inputImageID);
		currentObjectImageTitle = getTitleOfImage(maskOfCellID);
		imageCalculator("Multiply create 32-bit stack", inputImageTitle, currentObjectImageTitle);
		multipliedID = getImageID();
		multipliedTitle = getTitle();
		run("Macro...", "code=[v=(v>="+lowerThreshold*255+" && v<"+upperThreshold*255+")*(v/255)] stack");
		imageCalculator("OR stack", channelOneTitle, multipliedTitle);

		selectImage(maskOfCellID);
		maskOfCellTitle = getTitle();
		
		outline3D();
		run("Macro...", "code=v=(v/255)*"+i+" stack");	// create indexed-mask
		run("32-bit");
		imageCalculator("OR stack", channelTwoTitle, maskOfCellTitle);
		closeImage(maskOfCellID);
		closeImage(multipliedID);
	}
	selectImage(channelTwoID);
	run("glasbey on dark");
	selectImage(channelOneID);
	run("Fire");
	run("Merge Channels...", "c1=["+channelOneTitle+"] c2=["+channelTwoTitle+"] create");
	Stack.setChannel(2);
	fontHeight = getValue("font.height");
	fontSize = getValue("font.size");
	xCoordsColumn = "X";
	yCoordsColumn = "Y";
	zCoordsColumn = "Z";
	selectWindow(tableTitle);
	lines = Table.size;
	for (i = 0; i < numberOfCells; i++) {
		xCoord = Table.get(xCoordsColumn, lines-i-1);
		yCoord = Table.get(yCoordsColumn, lines-i-1);
		zCoord = Table.get(zCoordsColumn, lines-i-1);
		setColor("white");
		Overlay.drawString(""+(i+1), xCoord-fontSize/2, yCoord+fontHeight/2);
		Overlay.setPosition(2, round(zCoord), 0);
		Overlay.show;
	}
	resetMinAndMax();
	Stack.setChannel(1);
	setMinAndMax(min, max);
	setVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
	closeImage(cellsIndexMaskID);
}

function createOutputImage("title", channel, inputImageID) {
	selectImage(inputImageID);
	title = getTitle();
	title = "C"+channel+"-" + title + "-control.tif";
	width = getWidth();
	height = getHeight();
	depth = nSlices;
	newImage(title, "32-bit black", width, height, depth);
	id = getImageID();
	return id;
}

function measureCell(indexedMaskID, inputImageID, cellNr, lowerThreshold, upperThreshold, tableTitle) {
	maskOfCellID = createMaskOfCell(indexedMaskID, cellNr);
	run("3D Objects Counter", "threshold=128 slice=10 min.="+_MIN_SIZE+" max.="+_MAX_SIZE+" statistics");
	Stack.getUnits(XU, YU, ZU, TimeU, ValueU);
	volumeColumn = "Volume ("+XU+"^3)";
	surfaceColumn = "Surface ("+XU+"^2)";
	xCoordsColumn = "X";
	yCoordsColumn = "Y";
	zCoordsColumn = "Z";
	volume = Table.get(volumeColumn, 0);
	surface = Table.get(surfaceColumn, 0);
	x = Table.get(xCoordsColumn, 0);
	y = Table.get(yCoordsColumn, 0);
	z = Table.get(zCoordsColumn, 0);
	inputImageTitle = getTitleOfImage(inputImageID);
	currentObjectImageTitle = getTitleOfImage(maskOfCellID);
	imageCalculator("Multiply create 32-bit stack", inputImageTitle, currentObjectImageTitle);
	multipliedID = getImageID();
	run("Macro...", "code=[v=(v>="+lowerThreshold*255+" && v<"+upperThreshold*255+")] stack");						// creates image with values 0 and 1.
	run("Z Project...", "projection=[Sum Slices]");
	projectionID = getImageID();
	run("Measure");
	numberOfVoxelsAboveThreshold = getResult("IntDen", nResults-1);
	selectImage(inputImageID);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
	volumeAboveThreshold = numberOfVoxelsAboveThreshold * voxelWidth * voxelHeight * voxelDepth;
	report(tableTitle, inputImageTitle, cellNr, volume, volumeAboveThreshold, surface, x, y, z);
	closeImage(projectionID);
	closeImage(maskOfCellID);
	closeImage(multipliedID);
}

function createMaskOfCell(indexedMaskID, cellNr) {
	selectImage(indexedMaskID);
	run("Duplicate...", "duplicate");
	id = getImageID();
	run("Macro...", "code=v=(v=="+i+")*255 stack");	// Threshold object i (mask with 0 and 255).
	run("Dilate", "stack");
	run("Dilate", "stack");
	run("Close-", "stack");
	return id;
}

function createCellsIndexdMask(imageID) {
	selectImage(imageID);
	backgroundLevel = findBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS);
	run("Duplicate...", "duplicate");
	tmpImageID = getImageID();
	run("Macro...", "code=v=(v>"+backgroundLevel+1+")*255 stack");
	run("Enhance Contrast", "saturated=0.35");
	run("8-bit");
	run("Watershed", "stack");
	run("Erode", "stack");
	run("Erode", "stack");
	run("3D Objects Counter", "threshold=1 slice=10 min.=10 max.=1376256 objects");
	getStatistics(area, mean, min, numberOfCells);
	selectImage(tmpImageID);
	close();
	return numberOfCells;
}

function report(tableTitle, inputImageTitle, cellNr, volume, volumeAboveThreshold, surface, x, y, z) {
	selectWindow(tableTitle);
	counter = Table.size;
	if (counter<0) counter=0;
	Table.update;	
	Table.set("image", counter, inputImageTitle);
	Table.set("cell nr.", counter, cellNr);
	Table.set("total volume", counter, volume);
	Table.set("volume between "+_LOWER_THRESHOLD + " and " +_UPPER_THRESHOLD, counter, volumeAboveThreshold);
	Table.set("total surface", counter, surface);
	Table.set("X", counter, x);
	Table.set("Y", counter, y);
	Table.set("Z", counter, z);
	Table.update;
}

function closeImage(id) {
	selectImage(id);
	close();
}

function createTable(title) {
	if (!isOpen(title)) {
		Table.create(title);
	}
}

function getTitleOfImage(id) {
	tmpImageID = getImageID();
	selectImage(id);
	title = getTitle();
	selectImage(tmpImageID);
	return title;
}


function findBackground(radius, offset, iterations) {
	width = getWidth();
	height = getHeight();
	for(i=0; i<iterations; i++) {
    	getStatistics(area, mean, min, max, std, histogram); 
        minPlusOffset =  min + offset;
        currentMax = 0;
        for(x=0; x<width; x++) {
			for(y=0; y<height; y++) {
				intensity = getPixel(x,y);
				if (intensity<=minPlusOffset) {
				     value = getMaxIntensityAround(x, y, mean, radius, width, height);
				     if (value>currentMax) currentMax = value;	
				}
			}
        }
        result = currentMax / (i+1);
	}
	return result;
}

function getMaxIntensityAround(x, y, mean, radius, width, height) {
    max = 0;
    for(i=x-radius; i<=x+radius; i++) {
        if (i>=0 && i<width) {
               for(j=y-radius; j<=y+radius; j++) {
                      if (j>=0 && j<height) {
	    					value = getPixel(i,j);
                            if (value<mean && value>max)  max = value;
                      }
               }
        }
    }
    return max;
}

function outline3D() {
	run("Find Edges", "stack");
	for(i=1; i<=nSlices; i++) {
		setSlice(i);
		getStatistics(area, mean, min, max);
		if (max>0) {
			run("Fill Holes", "slice");
			break;
		}
	}
	for(i=nSlices; i>0; i--) {
		setSlice(i);
		getStatistics(area, mean, min, max);
		if (max>0) {
			run("Fill Holes", "slice");
			break;
		}
	}
}
