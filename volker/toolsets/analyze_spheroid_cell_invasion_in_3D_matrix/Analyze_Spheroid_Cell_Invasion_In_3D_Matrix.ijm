/**
  *  Measure the area of the invading spheroïd in a 3D cell invasion assay.
  *   
  *  written 2016 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *  in cooperation with Mailys LE BORGNE
  **
*/

var _RADIUS_BACKGROUND = 40;
var _FILE_EXTENSIONS = newArray("tif", "TIF");
var _REMOVE_SMALL_OBJECTS = true;
var _MIN_SIZE = 50;
var _INVERT_CONTRAST = false;

var _URL = "http://dev.mri.cnrs.fr/projects/imagej-macros/wiki/Analyze_Spheroid_Cell_Invasion_In_3D_Matrix";


macro "HELP for the Analyze Spheroid Cell Invasion In 3D Matrix Action Tool - C777D75D76D77D78D88D95D98Da4CfffD17D81D91DaeDdbDe5CbbbD29D2aD34D36D3bD3cD3dD43D45D52D72D82D9bDb3Db5Dc3Dc5Dc6Dc8CaaaD39D3aD47D57D63D6aD79D7aD83D84Da9Dc7CcccD5eD6dDb2DbbDc9Dd5Dd6Dd8C999D27D28D48D49D4aD59D5aD64D65D89D97D99Db7Db8CcccD37D5dD92Da2DcaDe7CbbbD38D44D46D4cD53D54D5cD62D6cD73D7bD7cD8bDa3Db4DbaDc4Dd7CeeeD6eD8dD9dDacC999D4bD55D56D58D66D67D69D74D8aD94D9aDa6Da7DaaDb6CaaaD26D4dD5bD6bD8cD93Da5DabDb9CdddD2bD35Dd4CeeeD71Dd9DdaDe6De9C888D68D85D86D87D96Da8CdddD25D7dD9cDe8" {
	 run('URL...', 'url='+_URL);
}

macro "Measure Area Current Image Action Tool - C037T4d14m" {
	 measureArea();
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

