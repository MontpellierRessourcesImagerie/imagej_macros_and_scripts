var _SUBTRACT_BACKGROUND_RADIUS = 1;
var _SUBTRACT_BACKGROUND_OFFSET = 1;
var _SUBTRACT_BACKGROUND_ITERATIONS = 2;
var _THRESHOLD = 2049;
var _TABLE_TITLE = "FLIM FRET Tool volumes";
var _MAX_SIZE = 1000000000000000000000000000000.0000;
var _MIN_SIZE = 10;
var _CREATE_CONTROL_IMAGE = true;

measureCells();

function measureCells() {
	createTable(_TABLE_TITLE);
	
	inputImageID = getImageID();
	setBatchMode(true);
	numberOfCells = createCellsIndexdMask(inputImageID);
	setBatchMode(false);
	
	cellsIndexMaskID = getImageID();
	setBatchMode(true);
	for (i = 1; i <= numberOfCells; i++) {
		measureCell(cellsIndexMaskID, inputImageID, i, _THRESHOLD, _TABLE_TITLE);
	}
	setBatchMode(false);
	if (_CREATE_CONTROL_IMAGE) createControlImage(inputImageID, cellsIndexMaskID, numberOfCells, _TABLE_TITLE, _THRESHOLD);
}

// needs the table with the measurements of the cells, the objects map and the input image to be open.
function createControlImage(inputImageID, cellsIndexMaskID, numberOfCells, tableTitle, threshold) {
	selectImage(inputImageID);
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
		run("Macro...", "code=v=(v>"+threshold*255+")*(v/255) stack");
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
	for (i = 0; i < numberOfCells; i++) {
		xCoord = Table.get(xCoordsColumn, i);
		yCoord = Table.get(yCoordsColumn, i);
		zCoord = Table.get(zCoordsColumn, i);
		setColor("white");
		Overlay.drawString(""+i, xCoord-fontSize/2, yCoord+fontHeight/2);
		Overlay.setPosition(2, round(zCoord), 1);
	}
	Overlay.show;
	resetMinAndMax();
	Stack.setChannel(1);
	setMinAndMax(min, max);
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

function measureCell(indexedMaskID, inputImageID, cellNr, threshold, tableTitle) {
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
	run("Macro...", "code=v=(v>"+threshold*255+") stack");
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
	Table.set("volume above "+_THRESHOLD, counter, volumeAboveThreshold);
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
