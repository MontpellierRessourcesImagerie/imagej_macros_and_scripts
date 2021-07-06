/***
 * 
 * Spot Distances Tool
 * 
 * Detect spots and measure the nearest neighbour distances between them.
 * 
 * (c) 2021, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/

var _SPOTS_CHANNEL = 1;
var _Z_SLICE = 1;
var _SIGMA = 3;
var _PROEMINENCE = 10;
var _CORRECT_MANUALLY = false;
var _FILE_EXTENSION = "tif";
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spot_Distances_Tool";

analyzeImage();
exit();

macro "spot distances tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "spot distances tool help (f4) Action Tool - CfffL00f0L01f1L0222C224L3252CfffL62f2L0313C224L2363CfffL73f3L0414C224L2434C82cD44C224L5464CfffL74f4L0515C224L2535C82cD45C224L5565CfffL75f5L0626C224D36C82cD46C224D56CfffL66f6L0737C82cD47CfffL57f7L0838C82cD48CfffL58b8C224Lc8d8CfffLe8f8L0929C82cD39CfffL49a9C224Db9C82cLc9d9C224De9CfffDf9L0a2aC82cD3aCfffL4a8aC82cL9abaC224LcaeaCfffDfaL0b2bC82cD3bC224D4bCfffD5bC82cL6b8bCfffL9bbbC224LcbdbCfffLebfbL0c1cC224D2cC82cL3c5cCfffL6cfcL0d1dC224L2d5dCfffL6dfdL0e2eC224L3e4eCfffL5efeL0fff"{
	run('URL...', 'url='+helpURL);
}

macro "analyze image (f5) Action Tool - C000T4b12a" {
	analyzeImage();
}

macro "process image [f5]" {
	processImage();
}

macro "run batch analysis (f6) Action Tool - C000T4b12b" {
	batchProcessImages();
}

macro "run batch analysis [f6]" {
	batchProcessImages();
}

function analyzeImage() {
	run("Set Measurements...", "display redirect=None decimal=9");
	inputImageID = getImageID();
	
	if (selectionType>=0) {
		Overlay.remove
		run("Add Selection...");
	}
	if (selectionType==-1 && Overlay.size>0) {
		Overlay.activateSelection(0);
		Overlay.remove
		run("Add Selection...");
	}
	run("Select None");
	run("Duplicate...", "duplicate channels="+_SPOTS_CHANNEL+"-"+_SPOTS_CHANNEL+" slices="+_Z_SLICE+"-"+_Z_SLICE);
	spotsInputImageID = getImageID();
	run("FeatureJ Laplacian", "compute smoothing="+_SIGMA);
	run("Find Maxima...", "prominence="+_PROEMINENCE+" light output=[Point Selection]");
	getSelectionCoordinates(xpoints, ypoints);
	close();
	Overlay.activateSelection(0);
	X = newArray(0);
	Y = newArray(0);
	for (i = 0; i < xpoints.length; i++) {
		cX = xpoints[i];
		cY = ypoints[i];
		if (Roi.contains(cX, cY)) {
			X = Array.concat(X, cX);
			Y = Array.concat(Y, cY);
		}
	}
	close();
	makeSelection("point", X, Y);
	if (_CORRECT_MANUALLY)
		waitForUser("Please, correct the points and press OK!");
	Overlay.addSelection;
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/find_nearest_neighbors.py");
	parameter = "";
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	startIndex = nResults;
	roiManager("measure");
	endIndex = nResults ;
	run("From ROI Manager");
	roiManager("reset");
	
	L = Table.getColumn("Length", "Results");
	lengths = Array.slice(L, startIndex, endIndex);
	Array.getStatistics(lengths, min, max, mean, stdDev);
	image = getResultLabel(startIndex);
	if (!isOpen("spot distances")) {
		Table.create("spot distances");
	}
	row = Table.size("spot distances");
	Table.set("image", row, image, "spot distances");
	Table.set("min. length", row, min, "spot distances");
	Table.set("max. length", row, max, "spot distances");
	Table.set("mean length", row, mean, "spot distances");
	Table.set("stdDev.", row, stdDev, "spot distances");
}

function batchProcessImages() {
	run("Clear Results");
	inputFolder = getDirectory("Choose the input folder!");
	files = getFileList(inputFolder);
	images = filterImages(files, _FILE_EXTENSION);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	ctrlFolder = inputFolder + "distances-"+year+"-"+month+"-"+dayOfMonth+"-"+hour+"_"+minute+"_"+second+"/";
	if (images.length > 0 && !File.exists(ctrlFolder)) {
		File.makeDirectory(ctrlFolder)
	}
	for (i = 0; i < images.length; i++) {
		image = images[i];
		path = inputFolder + image;
		if (_FILE_EXTENSION=="tif") open(path);
		else {
			run("Bio-Formats Importer", "open=["+path+"] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT ");
		}
		imageID = getImageID();
		title = getTitle();
		analyzeImage();
		saveAs("tiff", ctrlFolder + title);
		close();
	}
	selectWindow("Results");
	saveAs("results", ctrlFolder + "results-" + title+".xls");
	selectWindow("spot distances");
	saveAs("results", ctrlFolder + "distances-" + title+".xls");
}

function filterImages(files, ext) {
	images = newArray();
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, "."+ext)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}