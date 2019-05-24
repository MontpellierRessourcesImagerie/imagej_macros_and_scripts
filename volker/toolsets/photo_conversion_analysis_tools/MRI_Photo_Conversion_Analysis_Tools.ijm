var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Photo_Conversion_Analysis_Tool";
var _CHANNEL = 2;
var _CELL_MASK_CHANNEL = 1;
var _T0 = 0;
var _USE_ROLLING_BALL=true;
var _ROLLING_BALL_RADIUS = 40;
// var _USE_ROLLING_BALL_SEG = true;
var _ROLLING_BALL_RADIUS_SEG = 40;
var _FILTER = "Gaussian Blur...";
var _FILTER_PARAM = 1.2;
var _MIN_SIZE = 20;
var _MEASURE_REGION_OPTIONS = newArray("whole cell", "above threshold", "around max");
var _MEASURE_REGION_OPTION = _MEASURE_REGION_OPTIONS[2];
var _PROJECTION_IMAGE_ID = 0;
var _PROJECTION_METHOD = "Average Intensity"; //"Sum Slices";
var _RADIUS_AROUND_MAX = 6;
var _FIND_MAXIMA_NOISE = 10000;
var _DO_NOT_CORRECT_BACKGROUND = false;
var _OUTPUT_FOLDER = "cells";
var _TABLE_TITLE = "plot_data";
var _DoG_SIGMA_SMALL = 0.5;
var _DoG_SIGMA_BIG = 4;

macro "MRI Photo Conversion Analysis Help Action Tool - C000D21D22D23D24D25D26D27D28D29D2aD2bD2cD2dD2eD3eD4eD5eD6eD7eD8eD9eDaeDbeDceDdeDeeCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D2fD30D31D32D33D34D35D36D37D38D39D3aD3bD3cD3dD3fD40D43D44D45D46D47D48D49D4aD4bD4cD4dD4fD50D51D57D58D59D5aD5bD5cD5dD5fD60D61D62D63D64D65D68D69D6aD6bD6cD6dD6fD70D71D72D73D74D75D76D7bD7cD7dD7fD80D81D82D83D84D85D86D87D88D89D8cD8dD8fD90D91D92D93D94D95D96D97D98D99D9aD9dD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDadDafDb0Db1Db2Db3Db4Db5Db6Db7Db8Db9DbaDbbDbdDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDcdDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDddDdfDe0De1De2De3De4De5De6De7De8De9DeaDecDedDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfcDfdDfeDffCf00D41D42D52D53D54D55D56D66D67D77D78D79D7aD8aD8bD9bD9cDacDbcDccDdbDdcDebDfb" {
	run('URL...', 'url='+helpURL);
}

macro "help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "prepare image Action Tool (f2) - C000T4b12p" {
	prepareImage();	
}

macro "pepare image [f2]" {
	prepareImage();	
}

macro "prepare image Action Tool (f2) Options" {
	Dialog.create("Photo Conversion Analysis Options");
	Dialog.addCheckbox("do not correct background", _DO_NOT_CORRECT_BACKGROUND);
	Dialog.addCheckbox("use rolling-ball", _USE_ROLLING_BALL);
    Dialog.addNumber("rolling ball radius: ", _ROLLING_BALL_RADIUS);
    Dialog.show();
    _DO_NOT_CORRECT_BACKGROUND = Dialog.getCheckbox();
    _USE_ROLLING_BALL = Dialog.getCheckbox();
    _ROLLING_BALL_RADIUS = Dialog.getNumber();
}

macro "select cells Action Tool (f3) - C000T4b12c" {
	selectCells();	
	selectImage(_PROJECTION_IMAGE_ID);
	Overlay.remove;
	roiManagerRoisToOverlay();
}

macro "select cells Action Tool (f3) Options" {
	Dialog.create("Photo Conversion Segmentation Options");
	Dialog.addCheckbox("use rolling-ball", _USE_ROLLING_BALL_SEG);
    Dialog.addNumber("rolling ball radius: ", _ROLLING_BALL_RADIUS_SEG);
    Dialog.addNumber("Sigma of Gaussian blur filter: ", _FILTER_PARAM);
    Dialog.addNumber("min. size: ", _MIN_SIZE);
    Dialog.show();
    _USE_ROLLING_BALL_SEG = Dialog.getCheckbox();
    _ROLLING_BALL_RADIUS_SEG = Dialog.getNumber();
    _FILTER_PARAM = Dialog.getNumber();
    _MIN_SIZE = Dialog.getNumber();
}

macro "select cells [f3]" {
	selectCells();	
	selectImage(_PROJECTION_IMAGE_ID);
	Overlay.remove;
	roiManagerRoisToOverlay();
}

macro "plot intensity curve Action Tool (f4) - C000T4b12i" {
	plotCurve();
}

macro "plot intensity curve Action Tool (f4) Options" {
	Dialog.create("Photo Conversion Analysis Options");
	Dialog.addChoice("region to measure: ", _MEASURE_REGION_OPTIONS, _MEASURE_REGION_OPTION);
	Dialog.addNumber("radius around max.", _RADIUS_AROUND_MAX);
    Dialog.show();
    _MEASURE_REGION_OPTION = Dialog.getChoice();
    _RADIUS_AROUND_MAX = Dialog.getNumber();
}

macro "plot intensity curve [f4]" {
	plotCurve();
}

macro "batch select cells Action Tool (f5) - C037T1d13bT9d13cC555" {
	batchSelectCells();	
}

macro "batch select cells [f5]" {
	batchSelectCells();
}

macro "batch create intensity curve Action Tool (f6) - C037T1d13bT9d13iC555" {
	batchIntensityCurve();
}

macro "batch create intensity curve [f6]" {
	batchIntensityCurve();
}

function batchSelectCells() {
	dir = getDirectory("Please select the input folder!");
	File.makeDirectory(dir + _OUTPUT_FOLDER);
	files = getFileList(dir);
	images = filterImages(files);
//	setBatchMode(true);
	print("\\Clear");
	print("Selecting cells...");
	for (i = 0; i < images.length ; i++) {
		print("\\Update1: Processing image " + (i+1) + " of " + images.length);
		image = images[i];
		open(dir + image);
		selectCells();
		roiManagerRoisToOverlay();
		save(dir + _OUTPUT_FOLDER + "/" + image);
		close();
	}
//	setBatchMode(false);
	print("FINISHED - Selecting cells.");
}

function batchIntensityCurve() {
	dir = getDirectory("Please select the input folder!");
	File.makeDirectory(dir + _OUTPUT_FOLDER);
	files = getFileList(dir);
	images = filterImages(files);
	counter = 0;
	createTable(_TABLE_TITLE);
	print("\\Clear");
	print("Calculation intensity curves...");
	for (i = 0; i < images.length ; i++) {
		print("\\Update1: Processing image " + (i+1) + " of " + images.length);
		image = images[i];
		open(dir + image);
		prepareImage();
		selectImage(_PROJECTION_IMAGE_ID);
		if (i==0) {
			Stack.getDimensions(width, height, channels, slices, frames);
			meanIntensities = newArray(frames);
		}
		count = Overlay.size;
		for (j=0; j<count; j++) {
	 		Overlay.activateSelection(j);
	 		counter++;
	 		intensities = getCurve();
	 		for(k=0; k<frames-1; k++) {
	 			meanIntensities[k] += intensities[k];
	 		}
	 		report(_TABLE_TITLE, image, (j+1), intensities);
		}
		close();
		close();
	}
	for (k=0; k<frames-1; k++) {
		meanIntensities[k] /= counter;
	}
	print("FINISHED - Calculation intensity curves.");
}

function report(tableTitle, image, cellNr, intensities) {
	selectWindow(tableTitle);
	counter = Table.size;
	if (counter<0) counter=0;
	Table.update;	
	Table.set("image", counter, image);
	Table.set("cell", counter, cellNr);
	for(i=0; i<intensities.length; i++) {
		Table.set("t"+(i+1), counter, intensities[i]); 
	}
	Table.update;
}

function plotCurve() {
	intensities = getCurve();
	displayPlot(intensities);	
}

function getCurve() {
	run("Duplicate...", "duplicate");
	run("32-bit");
	Table.create("Results");
	roiManager("reset");
	roiManager("add");
	intensities = newArray(0);
	if (_MEASURE_REGION_OPTION==_MEASURE_REGION_OPTIONS[0]) intensities = getCurveWholeCell();
	if (_MEASURE_REGION_OPTION==_MEASURE_REGION_OPTIONS[1]) intensities = getCurveAboveThreshold();
	if (_MEASURE_REGION_OPTION==_MEASURE_REGION_OPTIONS[2]) intensities = getCurveAroundMax();
	return intensities;
}

function getCurveWholeCell() {
	roiManager("select", 0)
	roiManager("Multi Measure");
	close();
	intensities = getPlot();
	return intensities;
}

function getCurveAroundMax() {
	run("Clear Results");
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setFrame(1);
	roiManager("select", 0)
	getStatistics(area, int);
	setResult("Mean1", 0, int);
	for (i=2; i<=frames; i++) {
		Stack.setFrame(i);
		run("Find Maxima...", "noise="+_FIND_MAXIMA_NOISE+" output=[Point Selection]");
		if (_RADIUS_AROUND_MAX>0) {
			run("To Bounding Box");
			run("Enlarge...", "enlarge="+_RADIUS_AROUND_MAX +" pixel");
		}
		getStatistics(area, int);
		setResult("Mean1", i-1, int);
		run("Select None");
	}
	close();
	intensities = getPlot();
	return intensities;
}

function getCurveAboveThreshold() {
	setAutoThreshold("Triangle dark stack");
	run("Set Measurements...", "area mean modal min centroid integrated median kurtosis stack limit display redirect=None decimal=3");
	roiManager("select", 0)
	roiManager("Multi Measure");
	run("Set Measurements...", "area mean modal min centroid integrated median kurtosis stack display redirect=None decimal=3");
	close();
	intensities = getPlot();
	return intensities;
}

function displayPlot(intensities) {
	Plot.create("Intensity Plot", "t", "Intensity");
	Plot.setColor("blue");
	Plot.add("circle", intensities);
}

function getPlot() {
	/*I_min = getResult("Mean1", 0);
	I_max = getResult("Mean1", 1);
	intensities = newArray(nResults-1);
	for(i=1; i<nResults; i++) {
		I = getResult("Mean1", i);
		I_norm = (I - I_min) / (I_max - I_min);
		intensities[i-1] = I_norm;
	}
	return intensities; */
	intensities = newArray(nResults-1);
	selectWindow("Results");
	values = Table.getColumn("Mean1");
	Array.getStatistics(values, min, max, mean, stdDev);
	I_min = values[0];
	I_max = max;
	for(i=1; i<values.length; i++) {
		I = values[i];
		I_norm = (I - I_min) / (I_max - I_min);
		intensities[i-1] = I_norm;
	}
	return intensities;
}

function prepareImage() {
	inputImage = getImageID();
	run("Select None");
	run("Duplicate...", "duplicate channels="+_CHANNEL+"-"+_CHANNEL);
	if (!_DO_NOT_CORRECT_BACKGROUND) correctBackground(_USE_ROLLING_BALL, _ROLLING_BALL_RADIUS);
	channelImageID = getImageID();
	run("Z Project...", "projection=["+_PROJECTION_METHOD+"] all");
	_PROJECTION_IMAGE_ID = getImageID();
	selectImage(channelImageID);
	close();
	setSlice(1);
	selectImage(inputImage);
}


function correctBackground(rollingBall, radius) {
	run("Set Measurements...", "area mean modal min centroid integrated median kurtosis stack display redirect=None decimal=3");
	if (rollingBall) correctBackGroundRollingBall(radius);
	else correctBackgroundSubtractMean();
}

function correctBackGroundRollingBall(radius) {
	run("Subtract Background...", "rolling="+radius+" stack");
}

function correctBackgroundSubtractMean() {
	run("Restore Selection");
	if (selectionType()<0 || selectionType()>4) {
		exit("No selection. Select a background region before running the macro!") 
	}
	roiManager("reset");
	roiManager("add");
	run("Select None");
	run("Clear Results");
	roiManager("Multi Measure");
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	for (i = 0; i < nResults; i++) {
		mean = floor(getResult("Mean1", i)) + 1;
		channel = getResult("Ch1", i);
		frame = getResult("Frame1", i);
		Stack.setPosition(channel, (i%slices)+1, frame)
		run("Subtract...", "value="+mean+" slice");
	}
}

function selectCells() {
	Stack.setPosition(_CELL_MASK_CHANNEL, 1, 1);
	frame = findLastImageNotEmpty();
	Stack.setPosition(_CELL_MASK_CHANNEL, 1, frame);
	run("Select None");
	run("Duplicate...", " ");
	Overlay.remove;
	DoG(_DoG_SIGMA_SMALL, _DoG_SIGMA_BIG);
	run("Find Edges");
	setAutoThreshold("Default dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity exclude show=Masks in_situ");
	run("Dilate");
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Nothing add");
	close();
	close();
}

function selectCellsByThresholding() {
	Stack.setPosition(_CELL_MASK_CHANNEL, 1, 1);
	frame = findLastImageNotEmpty();
	Stack.setPosition(_CELL_MASK_CHANNEL, 1, frame);
	run("Select None");
	run("Duplicate...", " ");
	correctBackground(_USE_ROLLING_BALL_SEG, _ROLLING_BALL_RADIUS_SEG);
	run("Select None");
	run(_FILTER, "sigma="+_FILTER_PARAM);
	resetThreshold();
	setAutoThreshold("Default dark");
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity exclude show=Masks in_situ");
	run("Fill Holes");
	run("Close-");
	run("Open");
	run("Dilate");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Nothing add");
	close();
}
function roiManagerRoisToOverlay() {
	run("Select None");
	roiManager("Show None");
	roiManager("Show All");
	run("From ROI Manager");
	roiManager("reset");
}

function findLastImageNotEmpty() {
	Stack.getDimensions(width, height, channels, slices, frames);
	lastFrameNotEmpty = 0;
	for (i = 1; i <= frames; i++) {
		Stack.setFrame(i);
		getStatistics(area, mean, min, max, std, histogram);
		if(max>0) lastFrameNotEmpty=i;
	}
	return lastFrameNotEmpty;
}

function filterImages(files) {
	filtered = newArray(0);
	for(i=0; i<files.length; i++) {
		file = files[i];
		if (endsWith(file, ".tif")) filtered = Array.concat(filtered, file);
	}
	return filtered;
}

function createTable(title) {
	if (!isOpen(title)) {
		Table.create(title);
	}
}

function DoG(smallSigma, bigSigma) {
	inputImageID = getImageID();
	run("Duplicate...", " ");
	run("32-bit");
	rename("small_sigma");
	run("Gaussian Blur...", "sigma="+smallSigma+" scaled");
	selectImage(inputImageID);
	run("Duplicate...", " ");
	run("32-bit");
	rename("big_sigma");
	run("Gaussian Blur...", "sigma="+bigSigma+" scaled");
	imageCalculator("Subtract create 32-bit", "small_sigma","big_sigma");
	selectImage("small_sigma");
	close();
	selectImage("big_sigma");
	close();
}
