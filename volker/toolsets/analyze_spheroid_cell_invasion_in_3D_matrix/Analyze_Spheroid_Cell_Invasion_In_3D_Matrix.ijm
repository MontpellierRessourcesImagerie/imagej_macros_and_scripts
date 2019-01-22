/**
  *  Measure the area of the invading spheroïd in a 3D cell invasion assay.
  *   
  *  written 2016-2019 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *  in cooperation with Mailys LE BORGNE
  **
*/

var _RADIUS_BACKGROUND = 40;
var _FILE_EXTENSIONS = newArray("tif", "TIF");
var _REMOVE_SMALL_OBJECTS = true;
var _MIN_SIZE = 50;
var _INVERT_CONTRAST = false;
var _COLORS = newArray("red","green","blue","magenta","cyan","yellow","orange","black","white");
var _SPHEROID_ROI_COLOR = "magenta";
var _NUCLEI_ROI_COLOR = "cyan";
var _SPHEROID_STROKE_WIDTH = 4;
var _NUCLEI_STROKE_WIDTH = 4;

var _MIN_SIZE_NUCLEI=180;
var _ROLLING_BALL_RADIUS = 50;
var _UNSHARP_MASK_RADIUS = 10;
var _UNSHARP_MASK_WEIGHT = 0.9;
var _MEDIAN_FILTER_RADIUS = 2;
var _REMOVE_SMALL_OBJECTS_SIZE = 50;

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze-Spheroid-Cell-Invasion-In-3D-Matrix";


macro "HELP for the Analyze Spheroid Cell Invasion In 3D Matrix Action Tool - C777D75D76D77D78D88D95D98Da4CfffD17D81D91DaeDdbDe5CbbbD29D2aD34D36D3bD3cD3dD43D45D52D72D82D9bDb3Db5Dc3Dc5Dc6Dc8CaaaD39D3aD47D57D63D6aD79D7aD83D84Da9Dc7CcccD5eD6dDb2DbbDc9Dd5Dd6Dd8C999D27D28D48D49D4aD59D5aD64D65D89D97D99Db7Db8CcccD37D5dD92Da2DcaDe7CbbbD38D44D46D4cD53D54D5cD62D6cD73D7bD7cD8bDa3Db4DbaDc4Dd7CeeeD6eD8dD9dDacC999D4bD55D56D58D66D67D69D74D8aD94D9aDa6Da7DaaDb6CaaaD26D4dD5bD6bD8cD93Da5DabDb9CdddD2bD35Dd4CeeeD71Dd9DdaDe6De9C888D68D85D86D87D96Da8CdddD25D7dD9cDe8" {
	 run('URL...', 'url='+_URL);
}

macro "Measure Area Current Image Action Tool - C037T4d14m" {
	 measureArea();
}

macro "Measure Area Current Stack Action Tool - C037T4d14s" {
	measureStack();
}

macro "Measure Area Batch Action Tool - C037T4d14b" {
	folder = getDirectory("Select a directory");
	files = getFileList(folder);
	files = filterFiles(files, _FILE_EXTENSIONS);
	measureSeries(folder, files);
}

macro "Measure Area Current Image Action Tool Options" {
	Dialog.create("Measure Area Options");
	Dialog.addNumber("radius background subtraction", _RADIUS_BACKGROUND);
	Dialog.addCheckbox("remove small objects", _REMOVE_SMALL_OBJECTS);
	Dialog.addNumber("min object size", _MIN_SIZE);
	Dialog.addCheckbox("invert contrast", _INVERT_CONTRAST);
	Dialog.show();
	_RADIUS_BACKGROUND = Dialog.getNumber();
	_REMOVE_SMALL_OBJECTS = Dialog.getCheckbox();
	_MIN_SIZE = Dialog.getNumber();
	_INVERT_CONTRAST = Dialog.getCheckbox();
}

macro "Measure Area Current Stack Action Tool Options" {
	Dialog.create("Measure Area on Stack Options");
	Dialog.addNumber("min. nucleus size", _MIN_SIZE_NUCLEI);
	Dialog.addNumber("subtract background radius", _ROLLING_BALL_RADIUS );
	Dialog.addNumber("unsharp mask radius", _UNSHARP_MASK_RADIUS);
	Dialog.addNumber("unsharp mask weight", _UNSHARP_MASK_WEIGHT);
	Dialog.addNumber("median filter radius", _MEDIAN_FILTER_RADIUS);
	Dialog.addNumber("remove small objects size", _REMOVE_SMALL_OBJECTS_SIZE);
	Dialog.addChoice("color of the spheroid roi", _COLORS, _SPHEROID_ROI_COLOR);
	Dialog.addNumber("stroke-width of the sheroid roi", _SPHEROID_STROKE_WIDTH);
	Dialog.addChoice("color of the nuclei roi", _COLORS, _NUCLEI_ROI_COLOR);
	Dialog.addNumber("stroke-width of the nuclei roi", _NUCLEI_STROKE_WIDTH);
	Dialog.show();
	_MIN_SIZE_NUCLEI = Dialog.getNumber();
	_ROLLING_BALL_RADIUS = Dialog.getNumber();
	_UNSHARP_MASK_RADIUS = Dialog.getNumber();
	_UNSHARP_MASK_WEIGHT = Dialog.getNumber();
	_MEDIAN_FILTER_RADIUS = Dialog.getNumber();
	_REMOVE_SMALL_OBJECTS_SIZE = Dialog.getNumber();
	_SPHEROID_ROI_COLOR = Dialog.getChoice();
	_SPHEROID_STROKE_WIDTH = Dialog.getNumber();
	_NUCLEI_ROI_COLOR = Dialog.getChoice();
	_NUCLEI_STROKE_WIDTH = Dialog.getNumber();
}

function measureSeries(folder, files) {
	run("Clear Results");
	File.makeDirectory(folder + "/out");
	setBatchMode(true);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("\\Clear");
	print("Measure area started at "+hour+":"+minute+":"+second+"."+msec);
	for(i=0; i<files.length; i++) {
		print("\\Update1: Processing image " + (i+1) + " of " + files.length);
		aFile = files[i];
		open(folder + "/" + aFile);
		measureArea();
		save(folder + "/out/" + aFile);
		close();
	}
	setBatchMode("exit and display");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("Measure area finished at "+hour+":"+minute+":"+second+"."+msec);
}

/*
 * Channel one is supposed to contain the nuclei and channel two the cells.
 */
function measureStack() {
	inputTitle = getTitle();
	outDir = getDirectory("Please select the output folder!");
	run("Set Measurements...", "area centroid stack display redirect=None decimal=3");
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Clear Results");
	inputImage = getImageID();
	getDimensions(width, height, channels, slices, frames);
	if (slices>1 && frames == 1) run("Properties...", "channels="+channels+" slices=1 frames="+slices);
	getDimensions(width, height, channels, slices, frames);
	run("Remove Overlay");
	setBatchMode(true);
	if (channels>1) Stack.setChannel(2);
	for (i = 1; i <= frames; i++) {
		Stack.setFrame(i);
		measureArea();
		Overlay.addSelection(_SPHEROID_ROI_COLOR, _SPHEROID_STROKE_WIDTH);
		if (channels>1) Overlay.setPosition(0,0,i);
		else Overlay.setPosition(i);
	}
	area = newArray(frames);
	for (i = 0; i < frames; i++) {
		area[i] = getResult("Area", i);
	}
	setBatchMode(false);
	run("Select None");
	roiManager("reset");
	Stack.setFrame(1);
	setBatchMode(true);
	if (channels>1) {
		run("To ROI Manager");
		run("Duplicate...", "duplicate channels=1-1");
		nucleiImage = getImageID();
		countNuclei();
		selectImage(inputImage);
		count = roiManager("count");
		for (i = 0; i < count; i++) {
			Stack.setFrame(i+1);
			roiManager("select", i);
			Overlay.addSelection(_SPHEROID_ROI_COLOR, _SPHEROID_STROKE_WIDTH);
			Overlay.setPosition(0,0,i+1);
		}
		setAutoThreshold("Default");
		selectImage(nucleiImage);
		title = getTitle();
		run("Analyze Particles...", "size="+_MIN_SIZE_NUCLEI+"-Infinity show=Nothing display clear summarize add stack");
		close();
		Table.rename("Summary of "+title, "Results");
		combineRoisByFrame();
		for(i=0; i<frames; i++) {
			setResult("spheroid area", i, area[i]);
		}
	}
	setBatchMode(false);
	Stack.setFrame(1);
	saveAs("results", outDir+"/"+"results.xls");
	saveAs("tiff", outDir+"/"+inputTitle);
	beep();
}


function combineRoisByFrame() {
	for (i = 0; i < nResults; i++) {
		frame = getResult("Slice", i);
		count = getResult("Count", i);
		indices = newArray(count);
		for (index = 0; index < count; index++) {
			indices[index] = index;
		}
		roiManager("select", indices);
		roiManager("combine");
		Overlay.addSelection(_NUCLEI_ROI_COLOR, _NUCLEI_STROKE_WIDTH);
		Overlay.setPosition(0,0,frame);
		run("Select None");
		roiManager("delete");
	}
}

function measureArea() {
	if (bitDepth()==24) run("8-bit");
	run("Select None");
	run("Options...", "iterations=1 count=1 black");
	id = getImageID();
	run("Enhance Contrast", "saturated=0.35");
	run("Duplicate...", "copy");
	if (_INVERT_CONTRAST) run("Invert");
	run("Subtract Background...", "rolling=" + _RADIUS_BACKGROUND + " stack");
	setAutoThreshold("Triangle dark");
	run("Create Mask");
	run("Fill Holes (Binary/Gray)");
	run("Invert LUT");
	if (_REMOVE_SMALL_OBJECTS) {
		run("Invert");
		run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Masks in_situ");
		run("Invert");
	}
	run("Create Selection");
	close();
	close();
	close();
	run("Restore Selection");
	resetMinAndMax();
	run("Measure");
}

function filterFiles(files, extensions) {
	resultFiles = newArray();
	for(i=0; i<files.length; i++) {
		aFile = files[i];
		parts = split(aFile, ".");
		ext = "noextension";
		if (parts.length>1) ext = parts[1];
		hasRightExtension = false;
		for(j=0; j<extensions.length; j++) {
			theExtension = extensions[j];	
			if (theExtension == ext) hasRightExtension = true;
		}
		if (hasRightExtension) resultFiles = Array.concat(resultFiles, aFile);
	}
	return resultFiles;
}

/*
 * Count the nuclei in the image. If a selection is given, only the nuclei in the selection 
 * are counted.
 * 
 * (c) 2019 INSERM
 * 
 * Written by Volker Baecker, based on a version written by Sylvain DeRossi.
 */

function countNuclei() {
	run("Options...", "iterations=1 count=1 do=Nothing");
	run("Subtract Background...", "rolling="+_ROLLING_BALL_RADIUS+" stack");
	run("Unsharp Mask...", "radius="+_UNSHARP_MASK_RADIUS+" mask="+_UNSHARP_MASK_WEIGHT+" stack");
	run("Median...", "radius="+_MEDIAN_FILTER_RADIUS+" stack");
	run("8-bit");
	setAutoThreshold("Mean dark");
	run("Convert to Mask", "method=Mean background=Dark calculate");
	run("Fill Holes", "stack");
	run("Analyze Particles...", "size="+_REMOVE_SMALL_OBJECTS_SIZE+"-Infinity show=Nothing stack");
	run("Erode", "stack");
	run("Dilate", "stack");
	run("Fill Holes", "stack");
	run("Dilate", "stack");
	run("Watershed", "stack");
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		Stack.setFrame(i+1);
		run("Make Inverse");
		run("Fill", "slice");
		run("Make Inverse");
		roiManager("update");
	}
	run("Select None");
}
