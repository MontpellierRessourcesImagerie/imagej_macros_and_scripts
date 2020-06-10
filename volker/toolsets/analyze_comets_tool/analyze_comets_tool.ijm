/**
  * MRI Analyze Comets Tools
  *
  * Estimate the number of comets per cell.
  *
  * (c) 2020, INSERM
  * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
  *
*/

var _CHANNEL_RED = 2;
var _CHANNEL_GREEN = 1;
var _SIGMA = 22;
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _THRESHOLDING_METHOD = "Intermodes";
var _MIN_CELL_SIZE = 100;
var _PROEMINENCE = 0.10;

var _DELTA_X = 2;
var _MAX_RADIUS = 100;
var _LINE_WIDTH = 13;
var _MIN_TOLERANCE = 0;

var _MIN_SIZE_COMETS = 0.1;
var _THRESHOLDING_METHOD_COMETS = "Li";

var _TABLE_TITLE = "number of comets per cell";
var _FILE_EXT = "tif";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Analyze_Comets_Tool";

analyzeImage();
exit();

macro "MRI Analyze Comets (f1) Help Action Tool - C800D00C600D10C500D20C400L3090C500La0b0C400Lc0f0Ca00D01C700D11C500L2131C400D41C500L5171C600D81C700D91C900Da1C800Db1C500Dc1C400Ld1f1Ca00D02C700D12C600D22C500L3252C600D62C700L7282Ca00D92Cc00Da2Cb00Db2C700Dc2C500Dd2C400Le2f2C900D03C700D13C600D23C500L3343C600L5363C700D73C900D83Cc00D93Cf00Da3Cc00Db3C800Dc3C600Dd3C500Le3f3C800D04C700D14C600L2444C700L5464C800D74Cb00D84Cf00D94Ce00Da4Cb00Db4C900Dc4C800Dd4C600De4C500Df4C800D05C700D15C600L2535C700D45C800L5565C900D75Cc00D85Ce00D95Cc00La5c5Cb00Dd5C800De5C600Df5C700L0616C600L2636C700D46C800D56C900D66Cb00D76Cc00D86Ce00L96a6Cf00Lb6c6Cc00Dd6C900De6C700Df6L0717C600L2737C700D47C800D57C900D67Cc00D77Cf00L87b7Cc00Dc7Ca00Dd7C800De7C700Df7L0818C600D28C700L3848C800D58Cb00D68Cf00L7898Ce00Da8Cc00Db8Ca00Dc8C800Dd8C700De8C600Df8C700L0939C800D49Cb00D59Cf00L6989Ce00D99Cb00Da9C900Db9C800Dc9C700Ld9e9C600Df9C700L0a2aC800D3aCb00D4aCe00D5aCf00L6a7aCc00D8aCa00D9aC800DaaC700LbafaL0b1bC800D2bC900D3bCc00D4bCf00L5b6bCc00D7bC900D8bC700L9bfbL0c1cC800D2cC900D3cCb00D4cCc00L5c6cC900D7cC700D8cC600L9cbcC700DccC800LdcfcC700L0d1dC800L2d3dC900D4dCa00D5dC900D6dC800D7dC700D8dC600L9dadC700LbdcdC900LddfdC700L0e1eC800L2e3eC900D4eC800L5e6eC700L7e8eC600D9eC700LaebeC800DceCa00DdeCb00LeefeC700L0f1fC800D2fC900L3f4fC800L5f6fC700L7f8fC600D9fC700DafC800DbfC900DcfCa00DdfCb00DefCa00Dff"{
	help();
}

macro "help [f1]" {
	help();
}

macro "analyze image (f5) Action Tool - C000T4b12a" {
	 analyzeImage();
}

macro "analyze image [f5]" {
	 analyzeImage();
}

macro "batch analysis (f6) Action Tool - C000T4b12b" {
	runBatchAnalysis();
}

macro "analyze image (f5) Action Tool Options" {
	 Dialog.create("analyze comets options");

	 Dialog.addMessage("--Cell segmentation------------------------------------------");
	 Dialog.addNumber("comets channel: ",  _CHANNEL_RED);
	 Dialog.addNumber("other channel: ",  _CHANNEL_GREEN);
	 Dialog.addNumber("sigma Gaussian blur for cell detection: ", _SIGMA);
	 Dialog.addChoice("thresholding method for cells: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD);
	 Dialog.addNumber("min. cell size", _MIN_CELL_SIZE);
	 Dialog.addNumber("proeminence for maxima detection: ", _PROEMINENCE);

	 Dialog.addMessage("--Border correction------------------------------------------");
	 Dialog.addNumber("delta x for border direction: ", _DELTA_X);
	 Dialog.addNumber("radius for border correction: ", _MAX_RADIUS);
	 Dialog.addNumber("line width for profile: ", _LINE_WIDTH);
	 Dialog.addNumber("min. tolerance minima detection: ", _MIN_TOLERANCE);

	 Dialog.addMessage("--Comets segmentation------------------------------------");
	 Dialog.addNumber("min. size comets: ", _MIN_SIZE_COMETS);
	 Dialog.addChoice("thresholding method for comets: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD_COMETS);

	 Dialog.addHelp(helpURL);
	 
	 Dialog.show();
	 
	 _CHANNEL_RED = Dialog.getNumber();
	 _CHANNEL_GREEN = Dialog.getNumber(); 
	 _SIGMA = Dialog.getNumber();
	 _THRESHOLDING_METHOD = Dialog.getChoice();
	 _MIN_CELL_SIZE = Dialog.getNumber();
	 _PROEMINENCE = Dialog.getNumber();
	 
	 _DELTA_X = Dialog.getNumber();
	 _MAX_RADIUS = Dialog.getNumber();
	 _LINE_WIDTH = Dialog.getNumber();
	 _MIN_TOLERANCE = Dialog.getNumber();

	 _MIN_SIZE_COMETS = Dialog.getNumber();
	 _THRESHOLDING_METHOD_COMETS = Dialog.getChoice();
}

function help() {
	run('URL...', 'url='+helpURL);
}


function runBatchAnalysis() {
	dir = getDirectory("Input Folder");
	files = getFileList(dir);	
	files = filterFiles(files, _FILE_EXT);
	File.makeDirectory(dir+"out");
	for (i = 0; i < files.length; i++) {
		file = files[i];
		open(dir + file);
		title = getTitle();
		analyzeImage();
		saveAs("tiff", dir+"out/"+title);
		close();
	}
	Table.save(dir+"out/comets.xls", _TABLE_TITLE);
}

function analyzeImage() {
	run("Remove Overlay");
	preSegmentCells();
	setBatchMode(true);
	normalizedSumOfRedAndGreenChannels();
	count = roiManager("count");
	
	for (i = 0; i < count; i++) {
		showProgress(i, count-1);
		roiManager("select", i);
		adjustRoiBorders();
		roiManager("update");	
	}
	setBatchMode(false);
	close();
	roiManager("Show None");
	roiManager("Show All");
	
	run("Select None");
	inputImageID = getImageID();
	run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
	segmentComets();
	cometsImageID = getImageID();
	counts = countCometsPerCell();
	selectImage(inputImageID);
	run("From ROI Manager");
	roiManager("reset");
	selectImage(cometsImageID);
	run("To ROI Manager");
	close();
	run("From ROI Manager");
	roiManager("reset");
	drawLabels();
	reportCounts(counts);
}

function reportCounts(counts) {
	image = getTitle();
	title = _TABLE_TITLE;
	line = 0;
	if (!isOpen(title)) {
		Table.create(title);
	} else {
		line = Table.size(title);
	}
	for (i = 0; i < counts.length; i++) {
		Table.set("nr.", line+i, line+i+1, title);
		Table.set("image", line+i, image, title);
		Table.set("cell", line+i, i+1, title);
		Table.set("comets", line+i, counts[i], title);
	}
}

function countCometsPerCell() {
	count = roiManager("count");
	counts = newArray(count);
	for (r = 0; r < count; r++) {	
		snapshot();
		roiManager("select", r);
		getSelectionBounds(x, y, width, height);
		run("Make Inverse");
		run("Fill", "slice");
		run("Select None");
		counts[r] = findEndPoints(floor(x), floor(y) , round(width), round(height), "blue circle");
		reset();
	}
	return counts;
}

function segmentComets() {
	redImageID = getImageID();
	run("FeatureJ Laplacian", "compute smoothing=3");
	run("Invert");
	setAutoThreshold(_THRESHOLDING_METHOD_COMETS+" dark");
	run("Analyze Particles...", "size="+_MIN_SIZE_COMETS+"-Infinity show=Masks exclude in_situ");
	run("Skeletonize");
	selectImage(redImageID);
	close();
}

function preSegmentCells() {
	imageID = getImageID();
	
	run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
	redID = getImageID();
	rename("red");	run("Enhance Contrast...", "saturated=0 equalize");
	run("Gaussian Blur...", "sigma="+_SIGMA);
	selectImage(imageID);
	
	run("Duplicate...", "duplicate channels="+_CHANNEL_GREEN+"-"+_CHANNEL_GREEN);
	rename("green");
	greenID = getImageID();
	run("Enhance Contrast...", "saturated=0 equalize");
	run("Gaussian Blur...", "sigma="+_SIGMA);
	normalizeImage(greenID);
	normalizeImage(redID);
	imageCalculator("Add create 32-bit", "green","red");
	sumID = getImageID();
	rename("sum");
	run("Gaussian Blur...", "sigma="+_SIGMA);
	run("Find Maxima...", "prominence="+_PROEMINENCE+" output=[Segmented Particles]");
	rename("sumSegmented");
	sumSegmentedID = getImageID();
	
	selectImage(sumID);
	setAutoThreshold(_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	imageCalculator("AND create", "sum","sumSegmented");
	
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_CELL_SIZE+"-Infinity exclude add");
	close();
	close();
	close();
	close();
	close();
	roiManager("Show None");
	roiManager("Show All");
}

function normalizedSumOfRedAndGreenChannels() {
	run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
	redID = getImageID();
	rename("red");	
	run("Duplicate...", "duplicate channels="+_CHANNEL_GREEN+"-"+_CHANNEL_GREEN);
	rename("green");
	greenID = getImageID();
	run("Enhance Contrast...", "saturated=0 equalize");
	normalizeImage(greenID);
	normalizeImage(redID);
	imageCalculator("Add create 32-bit", "green","red");
	selectImage(redID);
	close();
	selectImage(greenID);
	close();
}

function adjustRoiBorders() {
	run("Interpolate", "interval=1 smooth adjust");
	getSelectionCoordinates(xpoints, ypoints);
	N = xpoints.length;
	xPointsCorrected = newArray(xpoints.length);
	yPointsCorrected = newArray(xpoints.length);
	for (i = 0; i < xpoints.length; i++) {
		i0 = i-_DELTA_X;
		if (i0<0) i0 = N + i0;
		i1 = (i+_DELTA_X) % N;
		makeLine(xpoints[i0], ypoints[i0], xpoints[i1], ypoints[i1]);
		run("Rotate...", "angle=90");
	 	getSelectionCoordinates(xL, yL);
	    x1 = xL[0];
	    y1 = yL[0];
	    x2 = xL[xL.length-1];	
	    y2 = yL[yL.length-1];
		dx = x2-x1;	
	    dy = y2-y1;
	    n = round(sqrt(dx*dx + dy*dy));
	    xInc = _MAX_RADIUS * (dx / n);
	    yInc = _MAX_RADIUS * (dy / n);
	    makeLine(xpoints[i], ypoints[i], xpoints[i]+xInc, ypoints[i1]+yInc, _LINE_WIDTH);
	    profile1 = getProfile();
	    minima1 = Array.findMinima(profile1, _MIN_TOLERANCE);
	    if(minima1.length==0) min = 0;
	    else min = minima1[0];
	    makeLine(xpoints[i], ypoints[i], xpoints[i]-xInc, ypoints[i1]-yInc, _LINE_WIDTH);
	    profile2 = getProfile();
	    minima2 = Array.findMinima(profile2, _MIN_TOLERANCE);
	    if(minima2.length==0) min2 = 0;
	    else min2 = minima2[0];
	    if (profile1[min]<profile2[min2]) {
	    	xPointsCorrected[i] = xpoints[i]+min*(dx / n);
	    	yPointsCorrected[i] = ypoints[i]+min*(dy / n);
	    } else {
	    	xPointsCorrected[i] = xpoints[i]-min2*(dx / n);
	    	yPointsCorrected[i] = ypoints[i]-min2*(dy / n);    
	    }
	}
	makeSelection("freehand", xPointsCorrected, yPointsCorrected);
	run("Fit Spline");
	run("Interpolate", "interval=1 smooth adjust");
}

function normalizeImage(id) {
	selectImage(id);
	getStatistics(area, mean, min, max, std, histogram);
	run("32-bit");
	run("Divide...", "value="+max);	
	run("Enhance Contrast", "saturated=0.35");
}


function findEndPoints(startX, startY, width, height, color) {
	setBatchMode(true);
	numberOfPoints = 0;
	for(y=startY; y<startY+height-1; y++) {
		for(x=startX; x<startX+width-1; x++) {
			v = getPixel(x, y);
			if (v<255) continue;
			sumOfNeighbors = getPixel(x-1, y-1) + getPixel(x, y-1) + getPixel(x+1, y-1) +
							 getPixel(x-1, y)   +                    getPixel(x+1, y) +
							 getPixel(x-1, y+1) + getPixel(x, y+1) + getPixel(x+1, y+1);
			if (sumOfNeighbors==255) {
				makePoint(x, y, color);
				numberOfPoints++;
				Overlay.addSelection();
			}
		}
	}
	setBatchMode(false);
	return floor(numberOfPoints/2);
}

function drawLabels() {
	setFont("SansSerif" , 48, "antialiased"); 
	for (i = 0; i < Overlay.size; i++) {
		Overlay.activateSelection(i);
		type = selectionType();
		getSelectionBounds(x, y, width, height);
		run("Select None");
		if (type>4) break;
		Overlay.drawString(i+1, x+width/2, y+height/2);
	}
}

function filterFiles(files, ext) {
	newFiles = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, "."+ext)) {
			newFiles = Array.concat(newFiles, file);
		}
	}
	return newFiles;
}
