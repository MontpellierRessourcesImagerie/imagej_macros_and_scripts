/**********************************************************************************
*
* Molecules and amassements tool
*
* Segment molecules as spots in scale-space and amassements by merging overlapping spots.
*
* (c) 2019, INSERM
* written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr), Biocampus Montpellier
*
**********************************************************************************/
var _SSF = sqrt(2);
var _SIGMA_START = 2.4;
var _SIGMA_DELTA = 0.4;
var _SCALE_SPACE_PARTS_OF_WIDTH = 30;
var _MAXIMA_PROMINENCE = 100;
var _AUTO_MAXIMA_PROMINENCE = false;
var _RADIUS_VARIANCE_FILTER = 2;
var _EXCLUDE_ON_EDGES = true;

var _MERGE_SPOTS = true;
var _MIN_COVERAGE = 20;
var _DISPLAY_SCALE_SPACE = false;

var _FILE_EXTENSION = "nd";
var _CHANNEL = 2;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Automatic_Scale_Spot_Detection_Tool";

findAndLinkScaleSpaceSpots();
exit();

macro " Molecules and amassements Action Tool (f1) - C444D10D19D2cD69D72D82D97Db0Db3Db8Dc1C666D07D09D1eD1fD22D2bD2dD2fD31D32D42D4aD4cD60D6fD77D81D86D8dD90D9aD9bDa2Da6Da7DaeDb5Db6Db9Dc5DcdDceDd0Dd5Dd6Dd7DeaDeeDf2Df5Df6Df9DffC3bbD13D17D24D27D53D54C777D05D18D2eD39D3cD3dD76D8bD99Dd9DddDf4C466D63C777D08D12D1bD29D41D4eD52D5aD6bD75D87D88D89D91D92D93D94Da0Da1Da4Db2Db4DbeDc0Dc8Dc9DcfDd8De0De6Df0Df1DfcDfdC0ffD15D16D33D38D43D65DabDbaDbcDc3DcbDd2Dd4De3C8aaD34D46D47D56D58D67Dd3DdaDdcDfaC555D01D0eD0fD11D21D2aD3bD3fD40D51D5cD5fD62D71D7aD7bD7eD7fD80D8fD95D9fDadDc6Dd1DedDefDf3Df8DfbC1eeD14D23D28D64D66C888D06D68D6aD74D84DbdDdeDdfDebDecDfeC666D02D03D04D0aD0bD0cD1dD20D3aD3eD49D4bD4dD4fD5bD5dD5eD61D6eD70D79D7dD83D85D8cD8eD96D9dD9eDa3Da5Da8DafDb1DbfDe8De9C1eeD48D57DcaDccCbbbD25D26D35D36D37D44D45D55DbbDdbC555D00D0dD1aD1cD30D50D59D6cD6dD73D78D7cD8aD98D9cDa9Db7Dc7De1De5De7Df7C1eeDaaDacDc2Dc4De2De4"{
	run('URL...', 'url='+helpURL);
}

macro "Molecules and amassements detection tool help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "Detect Spots Action Tool (f2) - C000T4b12s" {
	detectSpots();
}

macro "detect spots [f2]" {
	detectSpots();
}

macro "Detect Spots Action Tool (f2) Options" {
	Dialog.create("Detect Spots Options");
	
	Dialog.addMessage("Scale Space Options");
	Dialog.addNumber("sigma min.: ", _SIGMA_START);
	Dialog.addNumber("delta sigma: ", _SIGMA_DELTA);
	Dialog.addNumber("fraction of width: ", _SCALE_SPACE_PARTS_OF_WIDTH);
	Dialog.addCheckbox("exclude on edges", _EXCLUDE_ON_EDGES);
	Dialog.addCheckbox("display scale-space", _DISPLAY_SCALE_SPACE);
	Dialog.addMessage("Initial Spot Detection Options");
	Dialog.addCheckbox("auto detect noise tolerance", _AUTO_MAXIMA_PROMINENCE);
	Dialog.addNumber("radius of variance filter:", _RADIUS_VARIANCE_FILTER);
	Dialog.addNumber("noise tolerance: ", _MAXIMA_PROMINENCE);

	Dialog.addMessage("Post processing");
	Dialog.addCheckbox("Merge spots", _MERGE_SPOTS);
	Dialog.addNumber("min. % of coverage", _MIN_COVERAGE);

	Dialog.show();
	
	_SIGMA_START = Dialog.getNumber();
	_SIGMA_DELTA = Dialog.getNumber();
	_SCALE_SPACE_PARTS_OF_WIDTH = Dialog.getNumber();
	_EXCLUDE_ON_EDGES = Dialog.getCheckbox();
	_DISPLAY_SCALE_SPACE = Dialog.getCheckbox();

	_AUTO_MAXIMA_PROMINENCE = Dialog.getCheckbox();
	_RADIUS_VARIANCE_FILTER = Dialog.getNumber();
	_MAXIMA_PROMINENCE = Dialog.getNumber();

	_MERGE_SPOTS = Dialog.getCheckbox();
	_MIN_COVERAGE = Dialog.getNumber();
}

macro "Batch Detect Spots Action Tool (f3) - C000T4b12b" {
	batchDetectSpots();
}

macro "batch detect spots [f3]" {
	batchDetectSpots();
}

macro "Batch Detect Spots Action Tool (f3) Options" {
	Dialog.create("Batch Spots Detection Options");
	Dialog.addString("file extension: ", _FILE_EXTENSION);
	Dialog.addNumber("channel: ", _CHANNEL);
	Dialog.show();
	_FILE_EXTENSION = Dialog.getString();
	_CHANNEL = Dialog.getNumber();
}

function detectSpots() {
	run("ROI Manager...");
	setBatchMode(true);
	Overlay.remove;
	run("Select None");
	imageID = getImageID();
	sigmas = createScaleSpace();
	scaleSpaceID = getImageID();
	findMinima(sigmas, imageID, scaleSpaceID);
	selectImage(imageID);
	if (_MERGE_SPOTS) {
		mergeSpots();
	}
	if (_EXCLUDE_ON_EDGES) {
		removeEdgeSpots();
	}
	if (!_DISPLAY_SCALE_SPACE) {
		selectImage(scaleSpaceID);
		close();
	}
	setBatchMode("exit and display");
	run("Clear Results");
	roiManager("reset");
	selectImage(imageID);
	Overlay.measure;
	print("Done!");
}

function batchDetectSpots() {
	dir = getDirectory("Select the input folder!");
	files = getFileList(dir);
	images = filterImageFiles(files, dir, _FILE_EXTENSION);
	out = "";
	summary = "";
	outPath = dir + File.separator + "out";
	if (!File.exists(outPath)) File.makeDirectory(outPath);
	for (i = 0; i < images.length; i++) {
		image = images[i];
		path = dir + File.separator + images[i];
		run("Bio-Formats", "open=["+path+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");
		Stack.setChannel(_CHANNEL);
		run("Duplicate...", " ");
		detectSpots();
		selectWindow("Results");
		if (i==0) {
			out = out + Table.headings;
			summary = "image\tnr. of spots" + Table.headings + "\n";
		}
		results = getInfo("window.contents");
		index = indexOf(results, "\n");
		results = substring(results, index+1, lengthOf(results));
		out = out + "\n" + results;
		
		nrOfSpots = nResults;
		run("Summarize");
		results = getInfo("window.contents");
		results = split(results, "\n");
		lines = Array.slice(results, results.length-4 , results.length-1);
		summary = summary + image + "\t" + nrOfSpots + "\n";
		for (j = 0; j < lines.length; j++) {
			line = lines[j];
			index = indexOf(line, "\t");
			line = substring(line, index+1, lengthOf(line));
			summary = summary + "\t\t" + line + "\n";
		}
		saveAs("Tiff", outPath + File.separator + image);
		close();
		close();
	}
	run("Clear Results");
	String.show("spots", out);
	path = dir + File.separator + "spots.csv";
	saveAs("Text", path);
	selectWindow("spots.csv");
	run("Close");
	run("Table... ", "open=["+path+"]");
	String.show("spots summary", summary);
	path = dir + File.separator + "spots-summary.csv";
	saveAs("Text", path);
	selectWindow("spots-summary.csv");
	run("Close");
	run("Table... ", "open=["+path+"]");
}

function filterImageFiles(list, dir, extension) {
	images = newArray(0);
	for (i = 0; i < list.length; i++) {
		file = list[i];
		path = dir + File.separator + file;
		if (File.isDirectory(path)) continue;
		if (endsWith(file, "."+_FILE_EXTENSION)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}

function createScaleSpace() {
	width = getWidth();
	height = getHeight();
	max = round(width/_SCALE_SPACE_PARTS_OF_WIDTH);
	title = getTitle();
	run("Duplicate...", " ");
	rename("tmp");
	run("Duplicate...", " ");
	run("Images to Stack", "name=Scale-Space title=[tmp] use");
	run("Size...", "width="+width+" height="+height+" depth="+max+" constrain average interpolation=Bilinear");
	sigmas = newArray(nSlices);
	stackID = getImageID();
	run("32-bit");
	for(i=1; i<=nSlices; i++) {
		setSlice(i);
		run("Duplicate...", " ");
		sliceID = getImageID();
		sigma = _SIGMA_START + (i-1) * _SIGMA_DELTA;
		sigmas[i-1] = sigma;
		run("FeatureJ Laplacian", "compute smoothing="+sigma);
		laplacianID = getImageID();
		run("Multiply...", "value="+(sigma*sigma));
		run("Select All");
		run("Copy");
		selectImage(stackID);
		run("Paste");
		selectImage(sliceID);
		close();
		selectImage(laplacianID);
		close();
	}
	run("Select None");
	resetMinAndMax();
	return sigmas;
}

/*
 * Find the minima in scale-space.
 */
function findMinima(sigmas, imageID, scaleSpaceID) {
	if (_AUTO_MAXIMA_PROMINENCE) {
		selectImage(imageID);
		_MAXIMA_PROMINENCE = estimateSTD(_RADIUS_VARIANCE_FILTER);
	}
	selectImage(scaleSpaceID);
	Stack.setSlice(1);
	run("Z Project...", "projection=[Min Intensity]");
	run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
	getSelectionCoordinates(xpoints, ypoints);
	close();
	run("Select None");
	selectImage(scaleSpaceID);
	Stack.setSlice(1);
	run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
	getSelectionCoordinates(xpoints2, ypoints2);
	xpoints = Array.concat(xpoints, xpoints2);
	ypoints = Array.concat(ypoints, ypoints2);
	run("Select None");
	
	for (i = 0; i < xpoints.length; i++) {
		
		oldMin = 99999999;
		currentMin = 1111111;
		
		while(oldMin!=currentMin) {
	
			selectImage(scaleSpaceID);
			x = xpoints[i];
			y = ypoints[i];
			setSlice(1);
			makePoint(x, y);
			run("Plot Z-axis Profile");
			Plot.getValues(pxpoints, pypoints);
			close();
			ranks = Array.rankPositions(pypoints);
			minIndex = ranks[0]+1;
			currentMin = pypoints[minIndex-1];
			
			sigma = sigmas[minIndex-1];
			radius = sigma*_SSF;

			setSlice(minIndex);
			makeRectangle(x-radius, y-radius, 2*radius+1, 2*radius+1);
			Roi.getContainedPoints(rxpoints, rypoints);
			oldMin = currentMin;
			for(j=0; j<rxpoints.length; j++) {
				for(k=0; k<rypoints.length; k++) {
					v = getPixel(rxpoints[j], rypoints[k]);
					if (v<currentMin) {
						currentMin = v;
						xpoints[i] = rxpoints[j];
						ypoints[i] = rypoints[k];
					}			
				}
			}
			
		}
		run("Select None");
		selectImage(imageID);
		makeOval(x+0.5-radius, y+0.5-radius, (2*radius), (2*radius));
		Overlay.addSelection;
		run("Select None");
	}
	Overlay.show;
}

function findAndLinkScaleSpaceSpots() {
	roiManager("reset");
	run("Clear Results");
	sigmas = newArray(nSlices);
	for (i = 1; i <= nSlices; i++) {
		sigma = _SIGMA_START + (i-1) * _SIGMA_DELTA;
		radius = sigma*_SSF;
		Stack.setSlice(i);
		run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
		getSelectionCoordinates(xpoints, ypoints);
		for (j = 0; j < xpoints.length; j++) {
			makeOval(xpoints[j]+0.5-radius, ypoints[j]+0.5-radius, (2*radius), (2*radius));
			roiManager("add");
		}
		run("Select None");
	}
	roiManager("measure");
	
}

/*
 * Currently unused
 */
function filterMaxima(imageID, scaleSpaceID) {
	selectImage(imageID);
	Overlay.copy;
	selectImage(scaleSpaceID);
	setSlice(1);
	Overlay.paste;
	nrOfBlobs = Overlay.size;
	toBeRemoved = newArray(0);
	for (i = 0; i < nrOfBlobs; i++) {
		Overlay.activateSelection(i);
		getStatistics(area, mean, min, max, std);
		if (mean>-20) {
			toBeRemoved = Array.concat(toBeRemoved, i);
		}
	}
	roiManager("reset");
	run("To ROI Manager");
	roiManager("select", toBeRemoved);
	roiManager("Delete");

	run("From ROI Manager");
	
	Overlay.copy;
	selectImage(imageID);
	Overlay.remove;
	Overlay.paste;
	roiManager("reset");
}

function estimateSTD(radius) {
	run("Duplicate...", " ");
	run("Variance...", "radius="+radius);
	setAutoThreshold("Triangle");
	run("Create Selection");
	getStatistics(area, mean);
	close();
	stDev = sqrt(mean);
	return stDev;
}

function removeEdgeSpots() {
	toBeDeleted = newArray(0);
	size = Overlay.size;
	imageWidth = getWidth();
	imageHeight = getHeight();
	for (i = 0; i < size; i++) {
		Overlay.activateSelection(i);
		getSelectionBounds(x, y, width, height);
		x2 = x+width;
		y2 = y+height;
		if (x<=0 || y<=0 || x2>=imageWidth || y2>=imageHeight) {
			toBeDeleted = Array.concat(toBeDeleted, i);
		}
	}
	run("To ROI Manager");
	if (toBeDeleted.length<1) {
		run("From ROI Manager");
		return;
	}
	roiManager("select", toBeDeleted);
	roiManager("delete");
	run("From ROI Manager");
}

function mergeSpots() {
	print("Merging overlapping spots...");
	run("Set Measurements...", "area mean standard modal min centroid center shape feret's integrated display redirect=None decimal=9");
	run("Clear Results");
	Overlay.measure;
	run("To ROI Manager");
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/merge_overlapping_spots.py");
	parameter = "minOverlap="+_MIN_COVERAGE;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	run("From ROI Manager");
	roiManager("Delete");
	print("Done merging overlapping spots...");
}
