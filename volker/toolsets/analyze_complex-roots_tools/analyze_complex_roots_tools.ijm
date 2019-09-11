var _HEIGHT_IN_CM = 29.7;

var _ENHANCE_CONTRAST = true;
var _DIST_BORDER = 5;
var _THRESHOLDING_METHOD = "MaxEntropy";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _MIN_AREA = "50000";

var _CIRCLE_ORIGIN_X = 3226;
var _CIRCLE_ORIGIN_Y = 7;
var _CIRCLE_INITIAL_RADIUS = 50;
var _DELTA_RADIUS = 200;
var _FACTOR = 1.1;
var _CREATE_DISTANCE_MAP = true;

var _LINE_ORIGIN_X = 3226;
var _LINE_ORIGIN_Y = 7;
var _LINE_DELTA_DISTANCE = 200;
var _LINE_DISTANCE_FACTOR = 1;

var _MAXIMA_TOLERANCE = 2;
var _EDGE_MODE = 2;
var _PLOT_AREA_PER_DISTANCE = true;
var _PLOT_BORDER_PIXEL_PER_DISTANCE = false;
var _PLOT_MAX_RADIUS = false;
var _PLOT_MAXIMA_PER_DISTANCE = false;
var _PLOT_HORIZONTAL_DISTANCES = false;

var _FILE_EXTENSION = "tif";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Complex_Roots_Tool";
 
exit();

macro "analyze complex roots tools help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "analyze complex roots help Action Tool (f1) - C0ffD07D0cD18D1dD20D21D22D23D29D2eD34D3aD3eD45D4aD4eD56D5aD5fD60D61D62D67D6bD6fD73D77D7bD7fD83D87D8bD8fD93D97D9bD9fDa0Da1Da2Da7DabDafDb6DbaDbfDc5DcaDcfDd4DdaDdeDe0De1De2De3De9DeeDf7Df8Dfd"{
	run('URL...', 'url='+helpURL);
}
macro "create mask [f2]" {
	segmentRoot();
}

macro "create mask Action Tool (f2) - C000T4b12m" {
	segmentRoot();
}

macro "create mask Action Tool (f2) Options" {
	Dialog.create("create mask options");
	Dialog.addCheckbox("enhance contrast", _ENHANCE_CONTRAST);
	Dialog.addNumber("distance to border: ", _DIST_BORDER);
	Dialog.addChoice("thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD);
	Dialog.addNumber("min area: ", _MIN_AREA);
	Dialog.show();
	_ENHANCE_CONTRAST = Dialog.getCheckbox();
	_DIST_BORDER = Dialog.getNumber();
	_THRESHOLDING_METHOD = Dialog.getChoice();
	_MIN_AREA = Dialog.getNumber();
}

macro "make circles [f3]" {
	doMakeCircles(_CIRCLE_ORIGIN_X, _CIRCLE_ORIGIN_Y);
}

macro "make circles Tool (f3) - C000T4b12c" {
	getCursorLoc(x, y, z, modifiers);
	doMakeCircles(x,y);
}

macro "make circles Tool (f3) Options" {
	Dialog.create("make circles options");
	Dialog.addNumber("initial radius: ", _CIRCLE_INITIAL_RADIUS);
	Dialog.addNumber("initial delta: ", _DELTA_RADIUS);
	Dialog.addNumber("factor: ", _FACTOR);
	Dialog.show();
	_CIRCLE_INITIAL_RADIUS = Dialog.getNumber();
	_DELTA_RADIUS = Dialog.getNumber();
	_FACTOR = Dialog.getNumber();
}

macro "make lines [f4]" {
	doMakeLines(_LINE_ORIGIN_X, _LINE_ORIGIN_Y);
}

macro "make lines Tool (f4) - C000T4b12l" {
	getCursorLoc(x, y, z, modifiers);
	doMakeLines(x,y);
}

macro "make lines Tool (f4) Options" {
	Dialog.create("make lines options");
	Dialog.addNumber("initial y: ", _LINE_ORIGIN_Y);
	Dialog.addNumber("initial distance: ", _LINE_DELTA_DISTANCE);
	Dialog.addNumber("factor: ", _LINE_DISTANCE_FACTOR);
	Dialog.show();
	_LINE_ORIGIN_Y = Dialog.getNumber();
	_LINE_DELTA_DISTANCE = Dialog.getNumber();
	_LINE_DISTANCE_FACTOR = Dialog.getNumber();
}

macro "plot features [f5]" {
	doPlotFeatures();
}

macro "plot features Action Tool (f5) - C000T4b12p" {
	doPlotFeatures();
}

macro "plot features Action Tool (f5) Options" {
	Dialog.create("plot features options");
	Dialog.addCheckbox("plot area per distance", _PLOT_AREA_PER_DISTANCE);
	Dialog.addCheckbox("plot nr. of border-pixel per distance", _PLOT_BORDER_PIXEL_PER_DISTANCE);
	Dialog.addCheckbox("plot max. radius per distance", _PLOT_MAX_RADIUS);
	Dialog.addCheckbox("plot nr. of max. per distance", _PLOT_MAXIMA_PER_DISTANCE);
	Dialog.addCheckbox("plot horizontal distances", _PLOT_HORIZONTAL_DISTANCES);
	
	Dialog.addNumber("tolerance: ", _MAXIMA_TOLERANCE);
	Dialog.show();
	_PLOT_AREA_PER_DISTANCE = Dialog.getCheckbox();
	_PLOT_BORDER_PIXEL_PER_DISTANCE = Dialog.getCheckbox();
	_PLOT_MAX_RADIUS = Dialog.getCheckbox();
	_PLOT_MAXIMA_PER_DISTANCE = Dialog.getCheckbox();
	_PLOT_HORIZONTAL_DISTANCES = Dialog.getCheckbox();
	_MAXIMA_TOLERANCE = Dialog.getNumber();
}

macro "batch measure roots Action Tool (f6) - C000T4b12b" {
	batchMeasureRoots();
}


macro "batch measure roots [f6]" {
	batchMeasureRoots();
}


function batchMeasureRoots() {

	createDistanceMapOption = _CREATE_DISTANCE_MAP;

	_CREATE_DISTANCE_MAP = false;
	
	inputDir = getDirectory("Choose the directory containing the input images!");
	fileList = getFileList(inputDir);
	fileList = filterImages(fileList);

	xAxis = "distance";
	for (i = 0; i < fileList.length; i++) {
		file = fileList[i];
		open(inputDir+"/"+file);
		print(inputDir+"/"+file);
		retrieveMetadata();
		doCirclesOrLines();
		inputImageID = getImageID();
		segmentRoot();
		maskID = getImageID();
		run("Create Selection");
		createDistanceMap();
		edtID = getImageID();
		selectImage(maskID);
		run("Select None");	

		if (i==0) {
			Overlay.activateSelection(0);
			
			if (selectionType()==5) xAxis = "depth";
			run("Select None");
			distances = getDistances();
			if (_PLOT_AREA_PER_DISTANCE) {
				Table.create("root area per "+xAxis);
				Table.setColumn(xAxis, distances);
				Table.create("root rel. area per "+xAxis);
				Table.setColumn(xAxis, distances);
			}
			if (_PLOT_BORDER_PIXEL_PER_DISTANCE) {
				Table.create("nr. pixel in touch with earth "+xAxis);
				Table.setColumn(xAxis, distances);
				Table.create("rel. number of pixel in touch with earth "+xAxis);
				Table.setColumn(xAxis, distances);
			}
			if (_PLOT_MAX_RADIUS) {
				Table.create("max. radius per "+xAxis);
				Table.setColumn(xAxis, distances);
			}
			if (_PLOT_MAXIMA_PER_DISTANCE) {
				Table.create("nr. of maxima per "+xAxis);
				Table.setColumn(xAxis, distances);
			}
		}
		
		if (_PLOT_AREA_PER_DISTANCE) {
			
			sumOfAreas = getSumOfAreas();
			areaPerDistance = getAreaPerDistance(sumOfAreas);
			relativeAreaPerDistance = getRelativeAreas(areaPerDistance, sumOfAreas[sumOfAreas.length-1]);
			selectWindow("root area per "+xAxis);
			Table.setColumn(file, areaPerDistance);

			selectWindow("root rel. area per "+xAxis);
			Table.setColumn(file, relativeAreaPerDistance);
		}

		if (_PLOT_BORDER_PIXEL_PER_DISTANCE) {
			run("Points from Mask");
			getSelectionCoordinates(x, y);
			run("Select None");
			totalNrOfPixel = x.length;
		
			nrOfBorderPixel = getNrOfBorderPixelPerDistance();
			relNrOfBorderPixel = newArray(nrOfBorderPixel.length);
			for (j = 0; j < relNrOfBorderPixel.length; j++) {
				relNrOfBorderPixel[j] = nrOfBorderPixel[j] / totalNrOfPixel;
			}
			selectWindow("nr. pixel in touch with earth "+xAxis);
			Table.setColumn(file, nrOfBorderPixel);

			selectWindow("rel. number of pixel in touch with earth "+xAxis);
			Table.setColumn(file, relNrOfBorderPixel);
		}

		if (_PLOT_MAX_RADIUS) {
			selectImage(maskID);
			run("To ROI Manager");
			run("From ROI Manager");
			selectImage(edtID);
			run("From ROI Manager");
			roiManager("Delete");
			selectImage(edtID);
			
			maxValues = getMaxPerDistance();
			selectWindow("max. radius per "+xAxis);
			Table.setColumn(file, maxValues);
			
			selectImage(maskID);
		}

		close();
		close();
		close();
	}

	_CREATE_DISTANCE_MAP = createDistanceMapOption;
}

function doCirclesOrLines() {
	Overlay.activateSelection(0);
	if (selectionType()==5) {
		 doMakeLines(_LINE_ORIGIN_X, _LINE_ORIGIN_Y);
	} else {
		doMakeCircles(_CIRCLE_ORIGIN_X, _CIRCLE_ORIGIN_Y);
	}
	run("Select None");
}

function retrieveMetadata() {
	metadataString = getMetadata("Info");
	metadata = split(metadataString, ";");
	data = split(metadata[0], "=");
	if (data[0]=="origin_x") {
		_CIRCLE_ORIGIN_X=parseFloat(data[1]);
		data=split(metadata[1], "=");
		_CIRCLE_ORIGIN_Y=parseFloat(data[1]);
		data=split(metadata[2], "=");
		_CIRCLE_INITIAL_RADIUS=parseFloat(data[1]);
		data=split(metadata[3], "=");
		_DELTA_RADIUS=parseFloat(data[1]);
		data=split(metadata[4], "=");
		_FACTOR=parseFloat(data[1]);
	} else {
		data=split(metadata[0], "=");
		_LINE_ORIGIN_Y = parseFloat(data[1]);
		data=split(metadata[1], "=");
		_LINE_DELTA_DISTANCE = parseFloat(data[1]);
		data=split(metadata[2], "=");
		_LINE_DISTANCE_FACTOR = parseFloat(data[1]);
	}
}

function doPlotFeatures() {
	imageID = getImageID();
	if (_PLOT_AREA_PER_DISTANCE) plotAreaPerDistance();
	selectImage(imageID);
	if (_PLOT_BORDER_PIXEL_PER_DISTANCE) plotNrOfBorderPixel();
	selectImage(imageID);
	if (_PLOT_MAX_RADIUS) plotMaxRadius();
	selectImage(imageID);
	if (_PLOT_MAXIMA_PER_DISTANCE) plotMaximaPerDistance();
	selectImage(imageID);
	if (_PLOT_HORIZONTAL_DISTANCES) plotHorizontalDistances();
	selectImage(imageID);
	roiManager("Show None");
	roiManager("Show All");
}

function plotNrOfBorderPixel() {
	
	run("Points from Mask");
	getSelectionCoordinates(x, y);
	run("Select None");
	totalNrOfPixel = x.length;

	nrOfBorderPixel = getNrOfBorderPixelPerDistance();
	relNrOfBorderPixel = newArray(nrOfBorderPixel.length);
	for (i = 0; i < relNrOfBorderPixel.length; i++) {
		relNrOfBorderPixel[i] = nrOfBorderPixel[i] / totalNrOfPixel;
	}
	distances = getDistances();
	
	Overlay.activateSelection(0);
	xAxis = "distance";
	if (selectionType()==5) xAxis = "depth";
	run("Select None");
	Plot.create("nr. of pixels in touch with earth per"+xAxis, ""+xAxis+" [cm]", "numer of pixel [1]", distances, nrOfBorderPixel);
	Plot.show();	
	Plot.create("relative nr. of pixels in touch with earth per "+xAxis, ""+xAxis+" [cm]", "relative numer of pixel [1]", distances, relNrOfBorderPixel);
	Plot.show();	
}

function plotMaximaPerDistance() {
	maximaCount = getMaximaPerDistance();
	distances = getDistances();
	Plot.create("nr. of maxima per dist.", "distance [cm]", "nr.[1]", distances, maximaCount);
	Plot.show();	
}

function getMaximaPerDistance() {
	roiManager("Reset");
	count = Overlay.size;
	maximaCount = newArray(count);
	origonX = 0;
	origonY = 0;
	toUnscaled(origonX, origonY);
	makePoint(origonX, origonY);
	roiManager("Add");
	run("Select None");
	for (i = 0; i < count; i++) {
		Overlay.activateSelection(i);
		getSelectionCoordinates(xpoints, ypoints);
		if (selectionType() == 5) {
			xpoints = Array.getSequence(xpoints[1]);
			y = ypoints[0];
			ypoints = newArray(xpoints.length);
			Array.fill(ypoints, y);
		}
		values = getValuesInSelection(xpoints, ypoints);
		maxima = Array.findMaxima(values, _MAXIMA_TOLERANCE, _EDGE_MODE);
		maximaCount[i] = maxima.length;
		for (j = 0; j < maxima.length; j++) {
			x = xpoints[maxima[j]];
			y = ypoints[maxima[j]];
			toScaled(x, y);
			if (y>=0) { 
				makePoint(xpoints[maxima[j]], ypoints[maxima[j]]);
				roiManager("Add");
				run("Select None");
			}
		}	
	}
	return maximaCount;
}

function getDistances() {
	count = Overlay.size;
	distances = newArray(count);
	for (i = 0; i < count; i++) {
		Overlay.activateSelection(i);
		getSelectionBounds(x, y, width, height);
		if (selectionType() == 5) {
			distances[i] = y;
		} else {
			distances[i] = width / 2.0;
		}
		run("Select None");
		toScaled(distances[i]);
	}
	return distances;
}

function plotMaxRadius() {
	maxValues = getMaxPerDistance();
	distances = getDistances();
	Plot.create("max radius per dist.", "distance [cm]", "radius [cm]", distances, maxValues);
	Plot.show();	
}

function doMakeCircles(x,y) {
	_CIRCLE_ORIGIN_X = x;
	_CIRCLE_ORIGIN_Y = y;
	makeCircles(_CIRCLE_ORIGIN_X, _CIRCLE_ORIGIN_Y, _CIRCLE_INITIAL_RADIUS, _DELTA_RADIUS, _FACTOR);
	metadata = "origin_x="+_CIRCLE_ORIGIN_X + ";" +
			   "origin_y="+_CIRCLE_ORIGIN_Y + ";" +
			   "initial_radius=" + _CIRCLE_INITIAL_RADIUS + ";" +
			   "delta_radius="+_DELTA_RADIUS + ";" +
			   "factor="+ _FACTOR;
	 setMetadata("Info", metadata);
	 run("Properties...", "origin="+_CIRCLE_ORIGIN_X+","+_CIRCLE_ORIGIN_Y);
}

function doMakeLines(x,y) {
	_LINE_ORIGIN_X = x;
	_LINE_ORIGIN_Y = y;
	makeLines(_LINE_ORIGIN_Y, _LINE_DELTA_DISTANCE, _LINE_DISTANCE_FACTOR);
	metadata = "line_origin_y="+_LINE_ORIGIN_Y + ";" +
			   "delta_line="+_LINE_DELTA_DISTANCE + ";" +
			   "line_factor="+ _LINE_DISTANCE_FACTOR;
	setMetadata("Info", metadata);
	run("Properties...", "origin="+_LINE_ORIGIN_X+","+_LINE_ORIGIN_Y);
}

function getMaxPerDistance() {
	count = Overlay.size;
	maxValues = newArray(count);
	for (i = 0; i < count; i++) {
		values = getValuesInCircleNr(i);
		Array.getStatistics(values, min, max);
		toScaled(max);
		maxValues[i] = max;
	}
	run("Select None");
	return maxValues;
}

function getValuesInCircleNr(i) {
		Overlay.activateSelection(i);
		run("Area to Line");
		getSelectionCoordinates(xpoints, ypoints);
		if (selectionType() == 5) {
			xpoints = Array.getSequence(xpoints[1]);
			y = ypoints[0];
			ypoints = newArray(xpoints.length);
			Array.fill(ypoints, y);
		}
		values = getValuesInSelection(xpoints, ypoints);
		return values;
}


function makeCircles(centerX, centerY, initialRadius, deltaRadius, factor) {
	Overlay.remove;
	height = getHeight();
	currentRadius = initialRadius;
	while(currentRadius<height) {
		circleWidth = currentRadius*2;
		makeOval(centerX-currentRadius, centerY-currentRadius, circleWidth, circleWidth);
		Overlay.addSelection;
		deltaRadius *= factor;
		currentRadius += deltaRadius;
	}
	Overlay.show;
	run("Select None");
}

function getValuesInSelection(xpoints, ypoints) {
	values = newArray(xpoints.length);
	for(i=0; i<xpoints.length; i++) {
		x = xpoints[i];
		y = ypoints[i];
		x = round(x);
		y = round(y);
		values[i] = getPixel(x, y);
	}
	return values;
}

function segmentRoot() {
	width = getWidth();
	height = getHeight();
	run("Set Scale...", "distance="+height+" known="+_HEIGHT_IN_CM+" pixel=1 unit=cm");
	run("Options...", "iterations=1 count=1 do=Nothing");
	if (_ENHANCE_CONTRAST) enhanceContrast();
	run("RGB Color");
	run("16-bit");
	setAutoThreshold(_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	border = 2 * _DIST_BORDER;
	run("Canvas Size...", "width="+width+" height="+(height+border)+" position=Center");
	setLineWidth(_DIST_BORDER/2);
	makeLine(0, _DIST_BORDER, width, _DIST_BORDER);
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	run("Select None");
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity pixel show=Masks exclude in_situ");
	run("Canvas Size...", "width="+width+" height="+height+" position=Center");
	maskID = getImageID();
	run("Create Selection");
	if (_CREATE_DISTANCE_MAP) createDistanceMap();
	selectImage(maskID);
	run("Select None");
}

function createDistanceMap() {
	getVoxelSize(width, height, depth, unit);
	run("Exact Euclidean Distance Transform (3D)");
	setVoxelSize(width, height, depth, unit);
	run("16 colors");
	run("Restore Selection");
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	run("Select None");
}

function enhanceContrast() {
	setSlice(1);
	run("Enhance Contrast...", "saturated=0.3 equalize");
	setSlice(2);
	run("Enhance Contrast...", "saturated=0.3 equalize");
	setSlice(3);
	run("Enhance Contrast...", "saturated=0.3 equalize");
	setSlice(1);
}

function makeLines(initialY, deltaDistance, factor) {
	Overlay.remove;
	height = getHeight();
	width = getWidth();
	currentY = initialY;
	while(currentY<height) {
		makeLine(0, currentY, width, currentY);
		Overlay.addSelection;
		deltaDistance *= factor;
		currentY += deltaDistance;
	}
	Overlay.show;
	run("Select None");
}

function plotAreaPerDistance() {
	sumOfAreas = getSumOfAreas();
	areaPerDistance = getAreaPerDistance(sumOfAreas);
	relativeAreaPerDistance = getRelativeAreas(areaPerDistance, sumOfAreas[sumOfAreas.length-1]);
	distances = getDistances();
	yAxis = "distance";
	Overlay.activateSelection(0);
	if (selectionType()==5) yAxis = "depth";
	run("Select None");
	Plot.create("area per "+yAxis, ""+yAxis+" [cm]", "area [cm^2]", distances, areaPerDistance);
	Plot.show();	
	Plot.create("relative area per "+yAxis, ""+yAxis+" [cm]", "relative area [1]", distances, relativeAreaPerDistance);
	Plot.show();	
}

function plotHorizontalDistances() {
	hDist = getHorizontalDistances();
	length = hDist.length;
	leftDist = Array.slice(hDist, 0, (length/2)-1);
	rightDist =  Array.slice(hDist, length/2, (length-1));
	distances = getDistances();
	
	Plot.create("left horiz. dist.", "dist. [cm]", "max. horiz. dist. [cm]", distances, leftDist);
	Plot.show();	
	Plot.create("right horiz. dist.", "dist. [cm]", "max. horiz. dist. [cm]", distances, rightDist);
	Plot.show();	
}

function getSumOfAreas() {
	run("Set Measurements...", "area limit redirect=None decimal=9");
	run("Clear Results");
	setAutoThreshold("Triangle");
	Overlay.activateSelection(0);
	if (selectionType() == 5) {
		Overlay.activateSelection(0);
		getSelectionBounds(x0, y0, width0, height0);
		for (i = 1; i < Overlay.size; i++) {
			Overlay.activateSelection(i);
			getSelectionBounds(x, y, width, height);
			makeRectangle(x0, y0, width0, y);
			run("Measure");
		}
		run("Select None");
	} else {
		Overlay.measure;	
	}
	selectWindow("Results");
	sumOfAreas = Table.getColumn("Area");
	return sumOfAreas;
}

function getNrOfBorderPixelPerDistance() {
	Overlay.activateSelection(0);
	selType = selectionType();
	run("Select None");
	if (selType == 5) pixelPerDist = getNrOfBorderPixelPerDepth();
	else pixelPerDist = getNrOfBorderPixelCircles();
	return pixelPerDist;
}

function getNrOfBorderPixelPerDepth() {
	
}

function getNrOfBorderPixelCircles() {
	roiManager("reset");
	setBackgroundColor(255,255,255);
	createOutlineImage();
	size = Overlay.size;
	nrOfBorderPixel = newArray(size);
	for (i = 0; i < size; i++) {
		run("Duplicate...", " ");
		Overlay.activateSelection(i);
		if (i>0) {
			Overlay.activateSelection(i-1);
			run("Clear", "slice");
		}
		Overlay.activateSelection(i);
		getSelectionBounds(x0, y0, width0, height0);
		radius = width0/2.0;
		
		run("Clear Outside");

		nrOfPixels = countBorderPixels();
		nrOfBorderPixel[i] = nrOfPixels;
		close();
	}
	close();
	return nrOfBorderPixel;
}

function getAreaPerDistance(sumOfAreas) {
	areaPerDistance = newArray(sumOfAreas.length);
	areaPerDistance[0] = sumOfAreas[0];
	for (i = 1; i < sumOfAreas.length; i++) {
		areaPerDistance[i] = sumOfAreas[i]-sumOfAreas[i-1];
	}	
	return areaPerDistance;
}

function getRelativeAreas(areas, total) {
	relativeAreaPerDistance = newArray(areas.length);
	relativeAreaPerDistance[0] = areas[0]/total;
	for (i = 1; i < sumOfAreas.length; i++) {
		relativeAreaPerDistance[i] = areaPerDistance[i]/total;
	}	
	return relativeAreaPerDistance;
}


function getHorizontalDistances() {
	Overlay.activateSelection(0);
	selType = selectionType();
	if (selType == 5) hDist = getHorizontalDistacesLines();
	else hDist = getHorizontalDistancesCircles();
	return hDist;
}

function getHorizontalDistacesLines() {
	imageWidth = getWidth();
	imageHeight = getHeight();
	roiManager("reset");
	setBackgroundColor(255,255,255);
	size = Overlay.size;
	leftDistance = newArray(size);
	rightDistance = newArray(size);
	leftDistance[0] = 0;
	rightDistance[0] = 0;
	for (i = 0; i < size-1; i++) {
		run("Duplicate...", " ");
		Overlay.activateSelection(i);
		getSelectionBounds(x1, y1, width1, height1);
		makeRectangle(0, 0, imageWidth, y1);
		run("Clear", "slice");
		if (i<size-1) {
			Overlay.activateSelection(i+1);
			getSelectionBounds(x1, y1, width1, height1);
			makeRectangle(x1, y1, imageWidth, imageHeight-y1);
			run("Clear", "slice");
		}
		run("Create Selection");
		getSelectionBounds(x, y, width, height);
		x1 = x+width;
		Overlay.activateSelection(i+1);
		getSelectionBounds(x2, y, width, height);
		y1 = y;
		
		toScaled(x,y);
		toScaled(x1,y1);

		leftDistance[i+1] = x;
		rightDistance[i+1] = x1;
		
		toUnscaled(x,y);
		toUnscaled(x1,y1);		
		
		makePoint(x, y, "hybrid magenta");
		roiManager("add");
		makePoint(x1, y1, "hybrid red");
		roiManager("add");

		close();
	}
	hDist = Array.concat(leftDistance, rightDistance);
	return hDist;
}

function getHorizontalDistancesCircles() {
	roiManager("reset");
	setBackgroundColor(255,255,255);
	size = Overlay.size;
	leftDistance = newArray(size);
	rightDistance = newArray(size);
	for (i = 0; i < size; i++) {
		run("Duplicate...", " ");
		Overlay.activateSelection(i);
		if (i>0) {
			Overlay.activateSelection(i-1);
			run("Clear", "slice");
		}
		Overlay.activateSelection(i);
		getSelectionBounds(x0, y0, width0, height0);
		radius = width0/2.0;
		
		run("Clear Outside");
		run("Create Selection");
		getSelectionBounds(x, y, width, height);
		x1 = x+width;
	
		toScaled(x,y);
		toScaled(x1,y1);
		toScaled(radius);
	
		leftDistance[i] = x;
		rightDistance[i] = x1;
		
		y = sqrt(pow(radius,2)-pow(x,2));
		y1 = sqrt(pow(radius,2)-pow(x1,2));
		toUnscaled(x, y);
		toUnscaled(x1, y1);		
	
		makePoint(x, y, "hybrid magenta");
		roiManager("add");
		makePoint(x1, y1, "hybrid red");
		roiManager("add");
	
		close();
	}
	hDist = Array.concat(leftDistance, rightDistance);
	return hDist;
}

function countBorderPixels() {
	roiManager("reset");
	run("Points from Mask");
	roiManager("add");
	getSelectionCoordinates(x, y);
	run("Select None");
	counter = x.length;
	return counter;
}

function createOutlineImage() {
	run("Duplicate...", " ");
	run("Points from Mask");
	getSelectionCoordinates(x, y);
	run("Select None");
	for(i=0; i<x.length; i++) {
		xp = x[i];
		yp = y[i];
		v = getPixel(xp, yp);
		if (v==0) continue;
		sum = (getPixel(xp, yp-1)>0) + (getPixel(xp-1, yp)>0) + (getPixel(xp+1, yp)>0) + (getPixel(xp, yp+1)>0);
		if (sum<4) {
			setPixel(xp, yp, 128);
		}
	}
	setThreshold(10, 254);
	setOption("BlackBackground", false);
	run("Convert to Mask");
}

function filterImages(files) {
	images = newArray();
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, "."+_FILE_EXTENSION)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}
