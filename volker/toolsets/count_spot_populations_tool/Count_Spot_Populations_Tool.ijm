/*
 * Count Spot Populations Tool
 * 
 * Detect Spots and count spot-populations of different sizes.
 * 
 * (c) 2019 INSERM
 * written by Volker Baecker (volker.baecker at mri.cnrs.fr)
 * for Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 */

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Count_Spot_Populations_Tool";

// Petri-dish segmentation parameters
var _REDUCTION_FACTOR = 7;

// DoG parameters
var _CONTRAST_CHOICES = newArray("Normal", "Invert", "Auto");
var _CONTRAST_CHOICE = "Auto";
var _INVERT = true;
var _AUTO_FIND_CONTRAST = true;
var _MIN_DIAMETER = 2;
var _MAX_DIAMETER = 25;

// Spot Segmentation parameters
var _THRESHOLD_METHODS = newArray("Default", "Intermodes");
var _THRESHOLD_METHOD = _THRESHOLD_METHODS[0];
var _MIN_SIZE = PI*(_MIN_DIAMETER/2)*(_MIN_DIAMETER/2);
var _MIN_CIRCULARITY = 0.3;
var _FIT_ELLIPSE = true;

// Clustering parameters 
var _NUMBER_OF_CLUSTERS = 2;	// Do not change the number of clusters in this context.
var _FEATURES = "Area";
var _PARTS = split(_FEATURES, ",");
var _MAIN_FEATURE = _PARTS[0];

// Visualization parameters
var _COLORS = newArray("black", "blue", "cyan", "darkGray", "gray", "green", "lightGray", "magenta", "orange", "pink", "red", "white", "yellow");
var _COLOR_CLUSTER_ONE = "cyan";
var _COLOR_CLUSTER_TWO = "magenta"
var _COLOR_HISTOGRAM = "blue";
var _HIST_BINS = 10;
var _DIST_LINE_WIDTH = 3;

// uncomment for debugging

// var _MIN_DIAMETER = 15;
// var _MAX_DIAMETER = 60;

// detectSpotsDoG(_MIN_DIAMETER, _MAX_DIAMETER);
// sortByFeature(_MAIN_FEATURE, false);
// visualizeResults();
// detectSpotsBasic();
// dogFilterAction();
// exit();

// debugging end

macro "MRI Count Spot Populations Help Action Tool (f1) - CcccL00f0L0141CbbbD51CcccL6181CdddD91CcccLa1f1L0232C0ffL4262CcccL7282CdddD92CcccLa2f2L0333C0ffD43CaaaD53C0ffD63CcccL7383CdddD93CcccLa3f3L0434C0ffL4464CcccD74CdddL84a4CcccLb4f4CdddD05CcccL1535CbbbL4555CcccL6575CdddL85a5CcccLb5f5L0616CbbbL2636CcccL46a6CbbbLb6d6CcccLe6f6D07CbbbD17C0ffL2747CbbbL5767CcccL7787CbbbD97CaaaLa7b7C999Dc7CaaaDd7CbbbDe7CcccDf7D08C0ffL1828C888D38C0ffL4858CbbbL6878CaaaD88Cf0fL98d8C999De8CbbbDf8CcccD09C0ffD19C888D29C666L3949C0ffD59CbbbL6979Cf0fL8999C555Da9C444Lb9c9C666Dd9Cf0fDe9CaaaDf9CcccD0aC0ffL1a2aC666D3aC0ffL4a5aCbbbL6a7aCf0fD8aC555D9aC444LaadaCf0fDeaC888DfaCcccD0bCbbbD1bC0ffL2b4bCaaaD5bCcccD6bCbbbD7bCf0fD8bC555D9bC333LabbbC444LcbdbCf0fDebC888DfbCbbbL0c2cCaaaD3cCbbbL4c5cCcccD6cCbbbD7cCf0fD8cC555D9cC444LacccC555DdcCf0fDecC999DfcCbbbL0d3dCcccL4d6dCbbbD7dC999D8dCf0fD9dC555LadcdCf0fLddedCaaaDfdCcccL0e7eCbbbD8eC888D9eCf0fLaedeCaaaDeeCbbbDfeCcccL0f8fCbbbD9fCaaaLafcfCbbbLdfefCcccDff" {
	run('URL...', 'url='+helpURL);
}

macro "help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "Count Spot Populations Action Tool (f2) - C000T4b12c" {
	detectSpotsDoG(_MIN_DIAMETER, _MAX_DIAMETER);
	runEMClusterAnalysis();
	countAndColorClusters();
}

macro 'Count Spot Populations Action Tool (f2) Options' {
	Dialog.create("Count Spot Populations Options");
	Dialog.addMessage("You might also need to set the options of the DoG-Filter (right-click the d-button)");
	Dialog.addNumber("petri-dish margin in %: ", _REDUCTION_FACTOR)
	Dialog.addChoice("threshold method: ", _THRESHOLD_METHODS, _THRESHOLD_METHOD);
	Dialog.addNumber("min. circularity: ", _MIN_CIRCULARITY);
	Dialog.addCheckbox("fit ellipse", _FIT_ELLIPSE)
    Dialog.show();
    _REDUCTION_FACTOR = Dialog.getNumber();
    _THRESHOLD_METHOD = Dialog.getChoice();
    _MIN_CIRCULARITY = Dialog.getNumber();
    _FIT_ELLIPSE = Dialog.getCheckbox();
}

macro 'Count Spot Populations [f2]' {
	detectSpotsDoG(_MIN_DIAMETER, _MAX_DIAMETER);
	runEMClusterAnalysis();
	countAndColorClusters();
}

macro "DoG Filter Action Tool (f3) - C000T4b12d" {
	dogFilterAction();
}

macro 'Run DoG Filter [f3]' {
	dogFilterAction();
}

macro 'DoG Filter Action Tool (f3) Options' {
	Dialog.create("DoG Filter Options");
	Dialog.addChoice("contrast: ", _CONTRAST_CHOICES, _CONTRAST_CHOICE);
	Dialog.addNumber("min. diameter of spots", _MIN_DIAMETER);
	Dialog.addNumber("max. diameter of spots", _MAX_DIAMETER);
	Dialog.show();
	_CONTRAST_CHOICE = Dialog.getChoice();
	_MIN_DIAMETER = Dialog.getNumber();
	_MAX_DIAMETER = Dialog.getNumber();
	
	_AUTO_FIND_CONTRAST = false;
	_INVERT = false;
	if (_CONTRAST_CHOICE=="Auto") _AUTO_FIND_CONTRAST = true;
	if (_CONTRAST_CHOICE=="Invert") _INVERT = true;
}

macro "Run Cluster Analysis of Areas Action Tool (f4) - C000T4b12r" {
	runEMClusterAnalysis();
	countAndColorClusters();
}

macro 'Run Cluster Analysis of Areas [f4]' {
	runEMClusterAnalysis();
	countAndColorClusters();
}

macro "Plot Histogram and Distributions Action Tool (f5) - C000T4b12p" {
    plotHistogramAndGaussians();
}

macro 'Plot Histogram and Distributions [f5]' {
	 plotHistogramAndGaussians();
}

macro 'Plot Histogram and Distributions Action Tool (f5) Options' {
	Dialog.create("Plot Options");
	Dialog.addChoice("color cluster one: ", _COLORS, _COLOR_CLUSTER_ONE);
	Dialog.addChoice("color cluster two: ", _COLORS, _COLOR_CLUSTER_TWO);
	Dialog.addChoice("color histogram", _COLORS, _COLOR_HISTOGRAM);
	Dialog.addNumber("histogram bin width: ", _HIST_BINS);
	Dialog.addNumber("distribution line width: ", _DIST_LINE_WIDTH);
	Dialog.show();
	_COLOR_CLUSTER_ONE = Dialog.getChoice();
	_COLOR_CLUSTER_TWO = Dialog.getChoice();
	_COLOR_HISTOGRAM = Dialog.getChoice();
	_HIST_BINS = Dialog.getNumber();
	_DIST_LINE_WIDTH = Dialog.getNumber();
}

function dogFilterAction() {
	init();
	if (_AUTO_FIND_CONTRAST) autoSetContrast();
	sigmaMin = 	(_MIN_DIAMETER/2)/2.5;
	sigmaMax =  (_MAX_DIAMETER/2)/2.5;
	run("16-bit");
	if (_INVERT) run("Invert");
	DoGFilter(sigmaMin, sigmaMax);
}

function init() {
	run("Select None");
	roiManager("reset");
	run("Clear Results");
}
function detectSpotsDoG(minDiameter, maxDiameter) {
	init();
	if (_REDUCTION_FACTOR>0) selectInnerZone(_REDUCTION_FACTOR);
	run("Duplicate...", " ");
	if (_AUTO_FIND_CONTRAST) autoSetContrast();
	sigmaMin = 	floor((minDiameter)/2.5);
	sigmaMax =  ceil((maxDiameter)/2.5);
	run("16-bit");
	if (_INVERT) run("Invert");
	DoGFilter(sigmaMin, sigmaMax);
	resetThreshold();
	setAutoThreshold(_THRESHOLD_METHOD + " dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Close-");
	run("Fill Holes");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Masks in_situ");
	run("Watershed");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity circularity="+_MIN_CIRCULARITY+"-1.00 show=Nothing exclude add");
	if (_FIT_ELLIPSE) fitEllipses();
	roiManager("Show All");
	roiManager("measure");
	sortByFeature(_MAIN_FEATURE, false);
	close();
	roiManager("Show All without labels")
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
function autoSetContrast() {
	getStatistics(area, mean);
	mode = getMode();
	if (mean<=mode) {
		// dark Spots
		_INVERT = false;
	} else {
	    // bright spots
		_INVERT = true;
	}
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

function sortByFeature(FEATURE, REVERSE) {
	column = newArray(nResults);
	for (i=0; i<nResults; i++) {
		column[i] = getResult(FEATURE, i);
	}
	positions = Array.rankPositions(column);
	if (REVERSE) Array.reverse(positions);
	ranks = Array.rankPositions(positions);
	// Your code starts after this line
	for (i=0; i<roiManager("count"); i++) {
		/* select the element number i in the roi manager*/
		roiManager("select", i);
		/* Rename the selected roi in the roi manager to its position in the sorted list, that is rename it to IJ.pad(ranks[i], 4) */
		roiManager("Rename", IJ.pad(ranks[i], 4)); 
	}
	/* Deselect all rois in the roi-manager */
	roiManager("Deselect");
	/* Sort the rois in the roi-manager according to their names */
	roiManager("Sort");
	selectWindow("Results");
	run("Close");
	roiManager("Show None");
	roiManager("Show All");
	/* Measure the rois in the roi manager*/
	roiManager("Measure");
}

function visualizeResults() {
	String.copyResults();				// Copies the result table into the clipboard
	selection = String.paste;			// String.paste answers the content of the clipboard
	// Your code starts after this line
	lines = split(selection, "\n");
	indices = newArray(0);				// This array is initially empty. It will contain the indices of the rois that
										// correspond to the selected measurements.
	for(i=0; i<lines.length; i++) {		// For each line in the results table...
		line = lines[i];				// Get the ith line
		columns = split(line, "\t");	
		index = parseInt(columns[0]) - 1;	// Get the value of column 0 which contains the line-number of the measurement
											// Indices in the roi-manager start with 0, those written in the result table with 1
		indices = Array.concat(indices, index);	// Append the new index to the array indices.
	}
	roiManager("select", indices);
	if (indices.length>1) roiManager("Combine");
}

function ceil(number) {
	result =  floor(number)+1;
	if ((result - (number) == 1)) result = result - 1;
	return result
}

function getMode() {
	getHistogram(values, counts, 255);
	maxIndex = -1;
	max = -1;
	for(i=0; i<values.length; i++) {
		value = counts[i];
		if (value>max) {
			max = value;
			maxIndex = i;
		}
	}
	mode = values[maxIndex];
	return mode;
}

function selectInnerZone(reductionFactor) {
	w = getWidth();
	h = getHeight();
	minArea = (w*h)/4;
	roiManager("reset");
	run("Duplicate...", " ");
	run("16-bit");
	setAutoThreshold("Default dark");

	run("Analyze Particles...", "size="+minArea+"-Infinity add");
	roiManager("select", 0)
	getBoundingRect(x, y, width, height);
	
	borderSize = (reductionFactor*width) / 100;
	
	run("Fit Circle");
	incribedRectangle();
	run("Enlarge...", "enlarge=-"+borderSize);
	roiManager("reset");
	roiManager("Add");
	close();
	roiManager("select", 0);
	roiManager("reset");
}

function incribedRectangle() {
	getBoundingRect(x, y, width, height);
	rWidth = (width) / sqrt(2);
	x = x + (width / 2);
	y = y + (width / 2);
	x = x - (rWidth / 2);
	y = y - (rWidth / 2);
	makeRectangle(x, y, rWidth, rWidth);
}

function runEMClusterAnalysis() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/results_table-clusterer.py");
	parameter = "numberOfClusters="+_NUMBER_OF_CLUSTERS+", features="+_FEATURES;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}

function countAndColorClusters() {
	selectWindow("clusters");
	threshold = Table.get("intersection", 0);
	classOneCounter = 0;
	classTwoCounter = 0;
	for (i = 0; i < nResults; i++) {
		area = getResult(_MAIN_FEATURE, i);
		if (area<threshold) classOneCounter++;
		else classTwoCounter++;
	}
	Table.set("count", 0, classOneCounter);
	Table.set("count", 1, classTwoCounter);
	Table.update();
	indices = newArray(classOneCounter);
	for (i = 0; i < classOneCounter; i++) {
		indices[i]=i; 
	}
	roiManager("Select", indices);
	roiManager("Set Color", _COLOR_CLUSTER_ONE);
    roiManager("Set Line Width", 0);
    indices = newArray(classTwoCounter);
	for (i = 0; i < classTwoCounter; i++) {
		indices[i]=classOneCounter + i; 
	}
	roiManager("Select", indices);
	roiManager("Set Color", _COLOR_CLUSTER_TWO);
    roiManager("Set Line Width", 0);
    run("Select None");
}

function gauss(x, mu, sigma) {
	res = (1/(sigma*sqrt(2*PI)))*exp(-0.5*pow(((x-mu)/sigma),2));
	return res;
}

function plotHistogramAndGaussians() {
	selectWindow("Results");
	areas = Table.getColumn(_MAIN_FEATURE);
	Array.getStatistics(areas, minArea, maxArea, meanArea, stdDevArea);

	selectWindow("clusters");
	mu1 = Table.get("mean", 0);
	sigma1 = Table.get("stddev", 0);
	mu2 = Table.get("mean", 1);
	sigma2 = Table.get("stddev", 1);
	intersection = Table.get("intersection",0);
	
	xValues = Array.getSequence(maxArea+1);
	yValues1 = newArray(maxArea+1);
	yValues2 = newArray(maxArea+1);
	
	for (i = 0; i <xValues.length; i++) {
		yValues1[i] = gauss(i, mu1, sigma1); 
		yValues2[i] = gauss(i, mu2, sigma2); 
	}
	numberOfBins = floor((maxArea - minArea) / _HIST_BINS)+1;
	binCenters = newArray(numberOfBins);
	counts = newArray(numberOfBins);
	getHistogramCounts(areas, minArea, _HIST_BINS, counts, true);
	getHistogramCenters(minArea, maxArea, _HIST_BINS, binCenters);
	
	Plot.create(_MAIN_FEATURE+" Histogram / "+_MAIN_FEATURE+" Distributions", _MAIN_FEATURE, "frequency/probability density");
	Plot.setColor("blue");
	Plot.add("Separated Bars", binCenters, counts);
	Plot.setStyle(0, _COLOR_HISTOGRAM+",none,1.0,Separated Bars");
	Plot.add("line", xValues, yValues1);
	Plot.setStyle(1, _COLOR_CLUSTER_ONE+",none,"+_DIST_LINE_WIDTH+",Line");
	Plot.add("line", xValues, yValues2);
	Plot.setStyle(2, _COLOR_CLUSTER_TWO+",none,"+_DIST_LINE_WIDTH+",Line");
	Plot.setJustification("right");
	Plot.addText("intersection = "+intersection, 0.9, 0.10);
	Plot.show();
	Plot.setLimitsToFit();
}

function getHistogramCounts(areas, start, binSize, counts, normalize) {
	for(i=0; i<areas.length; i++) {
		index = floor((areas[i]-start) / binSize);
		counts[index]++; 	
	}
	if (!normalize) return;
	sum = 0;	
	for (i = 0; i < counts.length; i++) {
		sum = sum + counts[i];
	}
	totalArea = sum * binSize;
	for (i = 0; i < counts.length; i++) {
		counts[i] = counts[i] / totalArea;
	}
}

function getHistogramCenters(start, end, binSize, binCenters) {
	for(i=start; i<end+1; i=i+binSize) {
		index = floor((i-start) / binSize);
		binCenters[index] = (index * binSize) + floor(binSize/2);
	}
}
 
