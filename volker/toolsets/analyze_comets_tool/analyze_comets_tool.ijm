/**
  * MRI Analyze Comets Tools
  *
  * Estimate the density of comets in transfected cells.
  *
  * (c) 2020, INSERM
  * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
  *
*/

var _RED_CHANNEL = 1;
var _BLUE_CHANNEL = 3;
var _COMET_CHANNEL = 2;
var _Z_POS = 3;

var _MIN_SIZE = 40;
var _MIN_INTENSITY_RED = 6000;
var _THRESHOLDING_METHOD_CYTOPLASM = "Huang";
var _THRESHOLDING_METHODS = getList("threshold.methods");

var _MIN_SIZE_COMETS = 0.1;
var _MAX_CIRCULARITY = 0.7;
var _THRESHOLDING_METHOD_COMETS = "Li";
var _UPPER_SCALE_COMETS = 7;
var _LOWER_SCALE_COMETS = 0.7;
var _NR_OF_DILATES = 4;
var _NR_OF_ERODES = 4;

var _FILE_EXT = "nd";

var _TABLE_TITLE = "density of comets";

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

macro "analyze image (f5) Action Tool Options" {
	 Dialog.create("analyze comets options");
	 Dialog.addMessage("--Stack layout------------------------------------------");
	 Dialog.addNumber("red channel: ", _RED_CHANNEL);
	 Dialog.addNumber("comet channel: ", _COMET_CHANNEL);
	 Dialog.addNumber("nuclei channel: ", _BLUE_CHANNEL);
	 Dialog.addNumber("z-slice: ", _Z_POS);
	 Dialog.addMessage("--Cell segmentation------------------------------------------");
	 Dialog.addNumber("min size: ", _MIN_SIZE);
	 Dialog.addNumber("min intensity red: ", _MIN_INTENSITY_RED);
	 Dialog.addChoice("thresholding method cytoplasm: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD_CYTOPLASM);
	 Dialog.addMessage("--Comet segmentation------------------------------------------");
	 Dialog.addNumber("min. size comets: ", _MIN_SIZE_COMETS);
	 Dialog.addNumber("max. circularity comets: ", _MAX_CIRCULARITY);
	 Dialog.addChoice("thresholding method comets: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD_COMETS);
	 Dialog.addNumber("number of dilates: ", _NR_OF_DILATES);
	 Dialog.addNumber("number of erodes: ", _NR_OF_ERODES);
	 Dialog.show();
	 
	 _RED_CHANNEL = Dialog.getNumber();
	 _COMET_CHANNEL = Dialog.getNumber();
	 _BLUE_CHANNEL = Dialog.getNumber();
	 _Z_POS = Dialog.getNumber();
	 
	 _MIN_SIZE = Dialog.getNumber();
	 _MIN_INTENSITY_RED = Dialog.getNumber();
	 _THRESHOLDING_METHOD_CYTOPLASM = Dialog.getChoice();

	 _MIN_SIZE_COMETS = Dialog.getNumber();
	 _MAX_CIRCULARITY = Dialog.getNumber();
	 _THRESHOLDING_METHOD_COMETS = Dialog.getChoice();
	 _NR_OF_DILATES = Dialog.getNumber();
	 _NR_OF_ERODES = Dialog.getNumber();
}

function help() {
	run('URL...', 'url='+helpURL);
}

macro "batch analysis (f6) Action Tool - C000T4b12b" {
	runBatchAnalysis();
}

macro "batch analysis [f6]" {
	runBatchAnalysis();
}

macro "batch analysis (f6) Action Tool Options" {
	Dialog.create("Batch analysis options");
	Dialog.addString("file ext.: ", _FILE_EXT);
	Dialog.show();
	_FILE_EXT = Dialog.getString();
}

function runBatchAnalysis() {
	dir = getDirectory("Input Folder");
	files = getFileList(dir);	
	files = filterFiles(files, _FILE_EXT);
	File.makeDirectory(dir+"out");
	for (i = 0; i < files.length; i++) {
		file = files[i];
		run("Bio-Formats", "open="+dir+file+" autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		title = getTitle();
		analyzeImage();
		saveAs("tiff", dir+"out/"+title);
		close();
	}
	Table.save(dir+"out/comets.xls", _TABLE_TITLE);
}

function analyzeImage() {
	inputImageID = getImageID();
	inputImageTitle = getTitle();
	init();
	segmentNuclei();
	count = roiManager("count");
	if (count<1) {
		print("No nuclei found for image "+inputImageTitle);
		return;
	}
	filterTransfectedCells();
	count = roiManager("count");
	if (count<1) {
		print("No transfected cells found for image "+inputImageTitle);
		close();
		return;
	}
	segmentCytoplasm();
	totalArea = measureTotalArea();
	segmentComets();
	run("Skeletonize");
	width = getWidth();
	height = getHeight();
	nrOfComets = findEndPoints(0,0,width, height, "blue circle");
	print(totalArea, nrOfComets, nrOfComets/totalArea);
	run("To ROI Manager");
	close();
	run("From ROI Manager");	
	reportCounts(totalArea, nrOfComets);
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

function DoG(sigma1, sigma2) {
	imageID = getImageID();
	run("Duplicate...", " ");
	rename("blurred1");
	run("Gaussian Blur...", "sigma="+sigma1);
	selectImage(imageID);
	run("Duplicate...", " ");
	rename("blurred2");
	run("Gaussian Blur...", "sigma="+sigma2);
	imageCalculator("Subtract create", "blurred1", "blurred2");
	selectImage("blurred1");
	close();
	selectImage("blurred2");
	close();
}

function init() {
	run("Select None");
	Overlay.remove;
	run("Set Measurements...", "area mean standard min centroid perimeter shape feret's integrated median display redirect=None decimal=3");
	roiManager("reset");
}

function segmentNuclei() {
	run("Duplicate...", "duplicate channels="+_BLUE_CHANNEL+"-"+_BLUE_CHANNEL+" slices="+_Z_POS+"-"+_Z_POS);
	run("Gaussian Blur...", "sigma=2");
	setAutoThreshold("Default dark");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity add");
	close();
}

function filterTransfectedCells() {
	run("Duplicate...", "duplicate channels="+_RED_CHANNEL+"-"+_RED_CHANNEL+" slices="+_Z_POS+"-"+_Z_POS);
	count = roiManager("count");
	toBeDeleted = newArray(0);
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		getStatistics(area, mean, min, max, std, histogram);
		if (mean<_MIN_INTENSITY_RED) {
			toBeDeleted = Array.concat(toBeDeleted, i);
		}
	}
	if (toBeDeleted.length > 0) {
		roiManager("select", toBeDeleted);	
		roiManager("Delete");
	}
	run("Select None");
}

function segmentCytoplasm() {
	setAutoThreshold(_THRESHOLDING_METHOD_CYTOPLASM+" dark");
	run("Clear Results");
	roiManager("measure");
	X = Table.getColumn("X", "Results");
	Y = Table.getColumn("Y", "Results");
	workImageID = getImageID();
	for (i = 0; i < X.length; i++) {
		selectImage(workImageID);
		x = X[i];
		y = Y[i];
		toUnscaled(x, y);
		doWand(x, y);
		run("Create Mask");
		if (i==0) maskID = getImageID();
	}
	selectImage(maskID);
	roiManager("deselect");
	roiManager("combine");
	run("Clear", "slice");
	run("Select None");
	selectImage(inputImageID);
	run("From ROI Manager");
	roiManager("Deselect");
	roiManager("Delete");
	run("Select None");
	selectImage(maskID);
	run("Create Selection");
	roiManager("Add");
	selectImage(maskID);
	close();
	selectImage(workImageID);
	close();
	roiManager("Show None");
	roiManager("Show All");
}

function measureTotalArea() {
	totalArea = 0;
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		getStatistics(area);
		totalArea = totalArea + area;
	}
	run("Select None");
	return totalArea;
}

function segmentComets() {
	run("Duplicate...", "duplicate channels="+_COMET_CHANNEL+"-"+_COMET_CHANNEL+" slices="+_Z_POS+"-"+_Z_POS);
	
	cometsImageID = getImageID();
	
	count = roiManager("count");
	 if (count>1) {
		roiManager("Combine");
	} else {
		roiManager("select", 0);
	}
	
	run("Create Mask");
	maskImageID = getImageID();
	selectImage(cometsImageID);
	run("Select None");
	DoG(_LOWER_SCALE_COMETS, _UPPER_SCALE_COMETS);
	dogImageID =getImageID();
	run("FeatureJ Laplacian", "compute smoothing=1");
	setAutoThreshold("Default ");
	run("Analyze Particles...", "size="+_MIN_SIZE_COMETS+"-Infinity circularity=0-"+_MAX_CIRCULARITY+" show=Masks in_situ");
	title = getTitle();
	imageCalculator("AND create", title, "Mask");
	selectImage(cometsImageID);
	close();
	selectImage(maskImageID);
	close();
	selectImage(title);
	close();
	selectImage(dogImageID);
	close();
	cometsImageID = getImageID();
	selectImage(inputImageID);
	run("From ROI Manager");
	roiManager("Deselect");
	roiManager("Delete");
	selectImage(cometsImageID);
	for (i = 0; i < _NR_OF_DILATES; i++) {
		run("Dilate");
	}
	for (i = 0; i < _NR_OF_ERODES; i++) {
		run("Erode");
	}
}

function reportCounts(area, count) {
	image = getTitle();
	title = _TABLE_TITLE;
	line = 0;
	if (!isOpen(title)) {
		Table.create(title);
	} else {
		line = Table.size(title);
	}
	Stack.getUnits(X, Y, Z, Time, Value);
	Table.set("nr.", line, line+1, title);
	Table.set("image", line, image, title);
	Table.set("area", line, area, title);
	Table.set("nr. of comets", line, count, title);
	Table.set("areal number density [1/"+X+"²]", line, count / area, title);
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
