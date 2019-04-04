/**
  * MRI Area of Axonal Projections Tools
  * 
  * Measure the area of the axonal projections relative to the zone they are in.
  *   
  * (c) 2019, INSERM
  * 
  * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 *
*/

var _METHODS = getList("threshold.methods");
var _STAININGS = newArray("H&E", "H&E 2","H DAB", "Feulgen Light Green", "Giemsa", "FastRed FastBlue DAB", "Methyl Green DAB", "H&E DAB", "H AEC","Azan-Mallory","Alcian blue & H","H PAS","RGB","CMY");
var _BROWN_CHANNEL = "Colour_2";
var _BLUE_CHANNEL = "Colour_1";
var _GREEN_CHANNEL = "Colour_3";
var _THRESHOLDING_METHOD_PROJECTIONS = "Yen";
var _TRESHOLDING_METHOD_ZONE = "MaxEntropy";
var _COLOR_VECTORS = "H DAB";
var _MIN_SIZE_ZONE = 1000000;
var _MIN_SIZE_PROJECTIONS = 500;
var _SIGMA_BLUR = 2;
var _CLOSE_RADIUS = 40;
var _TABLE_TITLE = "area of axonal projections";
var _EXLUCDE_ON_EDGES_ZONE = true;

var _BLOLBS_THRESHOLD_METHOD = "Default";
var _BLOBS_MIN_SIZE = 12160;
var _BLOBS_MIN_CIRCULARITY = 0.3;
var _BLOBS_MIN_DIAMETER = 90;
var _BLOBS_MAX_DIAMETER = 144;
var _FEATURES = "Area";
var _PARTS = split(_FEATURES, ",");
var _MAIN_FEATURE = _PARTS[0];
var _FIT_ELLIPSE = false;

var _SOMA_MIN_INTENSITY_THRESHOLD = 42; 

var _TABLE_TITLE = "somata count";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Area-of-Axonal-Projections-Tool";

macro "area of axonal projections tools help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "area of axonal projections tools help Action Tool (f4) - C655D00C654L1040C665D50C656D60C766D70C655D80C554D90C555Da0C656Lb0c0C767Dd0C877De0C767Df0C654L0141C665L5171C554D81C544D91C655Da1C656Db1C667Dc1C767Dd1C766De1C667Df1C654D02C554D12C544D22C654D32C554D42C655L5262C554D72C544D82C655D92C656La2b2C667Lc2f2C554D03C544L1333C554D43C655L5363C544D73C554D83C656L93b3C667Lc3f3C544L0434C555D44C655L5464C555D74C655D84C656L94b4C667Dc4C766Dd4C767Le4f4C544D05C554D15C654D25C555D35C655L4555C555D65C554D75C665D85C656L95a5C667Db5C766Dc5C767Ld5f5C654D06C554D16C555D26C654D36C655L4656C654L6676C665D86C766D96C667Da6C766Db6C767Dc6C877Dd6C767De6C766Df6C655D07C654D17C655D27C665L3747C766D57C654L6777C665D87C766D97C767Da7C766Db7C877Lc7f7C767D08C766D18C665D28C766L3848C655D58C654D68C543D78C655D88C766L98b8C877Dc8C766Dd8C877Le8f8C766D09C665D19C655D29C766D39C655D49C654D59C543L6989C654L99a9C766Lb9d9C877De9C767Df9C655L0a1aC555D2aC654L3a4aC532L5a8aC543L9aaaC654DbaC655DcaC766DdaC877DeaC767DfaC655D0bC554L1b2bC654D3bC543D4bC532L5b7bC543L8b9bC544LabbbC543DcbC555DdbC767LebfbC555D0cC544D1cC543L2c3cC532L4c7cC544D8cC543D9cC544LacbcC543DccC555DdcC656LecfcC555D0dC554L1d2dC654D3dC543D4dC532L5d9dC543DadC544DbdC555DcdC655LddedC554DfdC766D0eC665L1e2eC655L3e4eC654L5e6eC554D7eC544D8eC554D9eC555DaeC665DbeC656DceC665DdeC655DeeC555DfeC766L0fafC665DbfC766DcfC665DdfC655DefC665Dff" {
	run('URL...', 'url='+helpURL);
}

macro "measure area of projections [f5]" {
	measureAreaOfAxonalProjections();
}

macro "measure area of projections Action Tool (f5) - C000T4b12a" {
	measureAreaOfAxonalProjections();
}

macro "measure area of projections Action Tool (f5) Options" {
	displayOptionsDialog();
}

macro "detect zone [f6]" {
	title = getTitle();
	imageID = getImageID();
	blueTitle = title+"-("+_BLUE_CHANNEL+")";
	doColorDeconvolution(imageID);
	detectZone(imageID, blueTitle);
	run("Create Mask");
}

macro "detect zone Action Tool (f6) - C000T4b12d" {
	title = getTitle();
	imageID = getImageID();
	blueTitle = title+"-("+_BLUE_CHANNEL+")";
	doColorDeconvolution(imageID);
	detectZone(imageID, blueTitle);
	run("Create Mask");
}

macro "make band [f7]" {
	makeBand();
}

macro "make band Action Tool (f7) - C000T4b12m" {
	makeBand();
}

macro "count somata [f8]" {
	countSomata();
}

macro "count somata Action Tool (f8) - C000T4b12b" {
	countSomata();
}


function countSomata() {
	title = getTitle();
	imageID = getImageID();
	brownTitle = title+"-("+_BROWN_CHANNEL+")";
	selectImage(brownTitle);
	detectSpotsDoG(_BLOBS_MIN_DIAMETER, _BLOBS_MAX_DIAMETER);
	filterRoisNotInBand();
	filterRoisNotTouchingZone(imageID);
	createTable(_TABLE_TITLE);
	nrOfSomata = roiManager("count");
	report(_TABLE_TITLE, title, nrOfSomata);
}

function displayOptionsDialog() {
	Dialog.create("Measure area of projections Options");
	parts = split(_BLUE_CHANNEL,"_");
	blueChannelID = parts[1];
	parts = split(_BROWN_CHANNEL,"_");
	brownChannelID = parts[1];
	
	Dialog.addChoice("stainings", _STAININGS, _COLOR_VECTORS);
	
	Dialog.addNumber("detect zone in channel:", blueChannelID);
	Dialog.addChoice("thresholding method zone", _METHODS, _TRESHOLDING_METHOD_ZONE);
	Dialog.addNumber("min. size zone:", _MIN_SIZE_ZONE);
	Dialog.addNumber("sigma of Gaussian Blur filter:", _SIGMA_BLUR);
	Dialog.addNumber("radius of close:", _CLOSE_RADIUS);
	
	Dialog.addNumber("detect axonal projections in channel:", brownChannelID);
	Dialog.addChoice("thresholding method projections", _METHODS, _THRESHOLDING_METHOD_PROJECTIONS);
	Dialog.addNumber("min. size zone:", _MIN_SIZE_PROJECTIONS);
	
    Dialog.show();

	_COLOR_VECTORS = Dialog.getChoice();
	blueChannelID = Dialog.getNumber();
	_BLUE_CHANNEL = "Colour_" + blueChannelID;
	_TRESHOLDING_METHOD_ZONE = Dialog.getChoice();
	_MIN_SIZE_ZONE = Dialog.getNumber();
	_SIGMA_BLUR = Dialog.getNumber();
	_CLOSE_RADIUS = Dialog.getNumber();

	brownChannelID = Dialog.getNumber();
	_BROWN_CHANNEL = "Colour_" + brownChannelID;
	_THRESHOLDING_METHOD_PROJECTIONS = Dialog.getChoice();
	_MIN_SIZE_PROJECTIONS = Dialog.getNumber();

	greenChannelID = 6 - (blueChannelID + brownChannelID);
	_GREEN_CHANNEL = "Colour_" + greenChannelID;
}

function doColorDeconvolution(imageID) {
	selectImage(imageID)
	greenTitle = title+"-("+_GREEN_CHANNEL+")";
	run("Colour Deconvolution", "vectors=["+_COLOR_VECTORS+"] hide");
	selectImage(greenTitle);
	close();
	selectImage(imageID);
}

function measureAreaOfAxonalProjections() {
	createTable(_TABLE_TITLE);
	run("Set Measurements...", "area limit display redirect=None decimal=3");
	title = getTitle();
	imageID = getImageID();
	brownTitle = title+"-("+_BROWN_CHANNEL+")";
	blueTitle = title+"-("+_BLUE_CHANNEL+")";
	doColorDeconvolution(imageID);
	
	zoneArea = detectZone(imageID, blueTitle);
	selectImage(blueTitle);
	close();
	projectionsArea = detectProjections(imageID, brownTitle);

	report(_TABLE_TITLE, title, zoneArea, projectionsArea);
	run("Select None");
}

function detectZone(imageID, channelTitle) {
	run("Remove Overlay");
	run("Select None");
	selectImage(channelTitle);
	run("Duplicate...", " ");
	maskID = getImageID();
	run("Invert");
	run("Gaussian Blur...", "sigma="+_SIGMA_BLUR);
	setAutoThreshold(_TRESHOLDING_METHOD_ZONE + " dark");
	run("Convert to Mask");
	setAutoThreshold("Default");
	excludeText = "";
	if (_EXLUCDE_ON_EDGES_ZONE) excludeText = "exclude";
	run("Analyze Particles...", "size="+_MIN_SIZE_ZONE+"-Infinity show=Masks "+excludeText+" in_situ");
	run("Fill Holes");
	run("Options...", "iterations="+_CLOSE_RADIUS+" count=1 do=Close");
	run("Create Selection");
	getStatistics(area);
	selectImage(imageID);
	run("Restore Selection");
	Overlay.addSelection;
	Overlay.show;
	selectImage(maskID);
	close();
	return area;
}

function detectProjections(imageID, channelTitle) {
	selectImage(channelTitle);
	run("8-bit");
	channelID = getImageID();
	run("Restore Selection");
	getStatistics(area, mean);
	selectImage(channelTitle);
	run("Make Inverse");
	fillValue = round(mean);
	setColor(fillValue, fillValue, fillValue);
	selectImage(channelID);
	fill();
	run("Select None");
	setAutoThreshold(_THRESHOLDING_METHOD_PROJECTIONS);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size="+_MIN_SIZE_PROJECTIONS+"-Infinity show=Masks in_situ");
	setAutoThreshold("Default");
	run("Measure");
	areaProjections = getResult("Area", nResults-1);
	run("Create Selection");
	selectImage(imageID);
	run("Restore Selection");
	Overlay.addSelection("cyan");
	selectImage(channelTitle);
	close();
	return areaProjections;
}

function createTable(title) {
	if (!isOpen(title)) {
		Table.create(title);
	}
}

function report(tableTitle, inputImageTitle, areaZone, areaProjections) {
	ratio = areaProjections / areaZone;
	selectWindow(tableTitle);
	counter = Table.size;
	if (counter<0) counter=0;
	Table.update;	
	Table.set("image", counter, inputImageTitle);
	Table.set("area of the zone", counter, areaZone);
	Table.set("area of projections", counter, areaProjections);
	Table.set("ratio of areas", counter, ratio);
	Table.update;
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

function init() {
	run("Select None");
	roiManager("reset");
	run("Clear Results");
}
function detectSpotsDoG(minDiameter, maxDiameter) {
	init();
	run("Duplicate...", " ");
	sigmaMin = 	floor((minDiameter)/2.5);
	sigmaMax =  ceil((maxDiameter)/2.5);
	run("16-bit");
	DoGFilter(sigmaMin, sigmaMax);
	resetThreshold();
	setAutoThreshold(_BLOLBS_THRESHOLD_METHOD + " dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Close-");
	run("Fill Holes");
	run("Analyze Particles...", "size="+_BLOBS_MIN_SIZE+"-Infinity show=Masks in_situ");
	run("Watershed");
	run("Analyze Particles...", "size="+_BLOBS_MIN_SIZE+"-Infinity circularity="+_BLOBS_MIN_CIRCULARITY+"-1.00 show=Nothing exclude add");
	if (_FIT_ELLIPSE) fitEllipses();
	roiManager("Show All");
	roiManager("measure");
	close();
	roiManager("Show All without labels")
}

function ceil(number) {
	result =  floor(number)+1;
	if ((result - (number) == 1)) result = result - 1;
	return result
}

function DoGFilter(sigmaMin, sigmaMax) {
	imageID = getImageID();
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+sigmaMin);
	rename("DoGImageSmallSigma");
	selectImage(imageID);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+sigmaMax);
	rename("DoGImageBigSigma");
	imageCalculator("Subtract create", "DoGImageBigSigma","DoGImageSmallSigma");
	selectImage("DoGImageSmallSigma");
	close();
	selectImage("DoGImageBigSigma");
	close();
}

function fitEllipses() {
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		run("Fit Ellipse");
		roiManager("select", i);
		run("Restore Selection");
		roiManager("Update");
	}
}

function makeBand() {
	selectImage("Mask");
	run("Enlarge...", "enlarge=-40");
	run("Make Band...", "band=80");
}

function filterRoisNotInBand() {
	run("MRI Roi Util");
	selectImage("Mask");
	getSelectionCoordinates(bandPointsX, bandPointsY);
	count = roiManager("count");
	indicesToBeRemoved = newArray(0);
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		getSelectionCoordinates(blopPointsX, blobPointsY);
		if (Ext.doRoisHaveNoOverlap(bandPointsX, bandPointsY, blopPointsX, blobPointsY)=="true") indicesToBeRemoved = Array.concat(indicesToBeRemoved, i);
	}
	roiManager("select", indicesToBeRemoved);
	roiManager("delete");
	run("Select None");
}

function filterRoisNotTouchingZone(imageID) {
	run("MRI Roi Util");
	selectImage(imageID);
	Overlay.activateSelection(0);
	run("Enlarge...", "enlarge=20");
	getSelectionCoordinates(zonePointsX, zonePointsY);
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		getStatistics(area, mean, min, max, std, histogram);
		getSelectionCoordinates(blopPointsX, blobPointsY);
		if (Ext.doRoisHaveNoOverlap(zonePointsX, zonePointsY, blopPointsX, blobPointsY)=="true") indicesToBeRemoved = Array.concat(indicesToBeRemoved, i);
		else {
			if (min>_SOMA_MIN_INTENSITY_THRESHOLD) indicesToBeRemoved = Array.concat(indicesToBeRemoved, i);
		}
	}
	roiManager("select", indicesToBeRemoved);
	roiManager("delete");
	run("Select None");
}

function createTable(title) {
	if (!isOpen(title)) {
		Table.create(title);
	}
}

function report(tableTitle, image, nrOfSomata) {
	selectWindow(tableTitle);
	counter = Table.size;
	if (counter<0) counter=0;
	Table.update;	
	Table.set("image", counter, image);
	Table.set("nr. of somas", counter, nrOfSomata);
	Table.update;
}
