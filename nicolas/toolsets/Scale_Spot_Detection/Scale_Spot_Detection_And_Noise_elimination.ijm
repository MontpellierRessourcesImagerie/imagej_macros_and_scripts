// multi Scale Detection Processing

requires("1.48d");
var _FILE_EXTENSION = "tif";
var _SSF = sqrt(2);
var _SIGMA_START = 1.6;
var _SIGMA_DELTA = 0.4;
var _SCALE_SPACE_PARTS_OF_WIDTH = 75;
// av var _MAXIMA_PROMINENCE = 5;
var _MAXIMA_PROMINENCE = 3;
var _AUTO_MAXIMA_PROMINENCE = false;
var _RADIUS_VARIANCE_FILTER = 2;
var _EXCLUDE_ON_EDGES = true;
var _MERGE_SPOTS = true;
var _MIN_COVERAGE = 25;
var _DISPLAY_SCALE_SPACE = false;
var _CHANNEL = 2; 
var _Sigma_Multiplicative_Factor = 5;
var Stack_Slice_Spots_X_Array = newArray();
var Stack_Slice_Spots_Y_Array = newArray();
		
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Multi_Scale_Spot_Detection_And_Noise_Elimination";

/****************************************************************************************************************************************************/

macro "multiScale Spot Detection (f5) Action Tool-C000T4b12M" {
	Dialog.create("Scale Spot Detection Options");
	Dialog.addNumber("SIGMA_START: ", _SIGMA_START);
	Dialog.addNumber("SIGMA_DELTA: ", _SIGMA_DELTA);
	Dialog.addNumber("SCALE_SPACE_PARTS_OF_WIDTH (from 50 to 150): ", _SCALE_SPACE_PARTS_OF_WIDTH);
	Dialog.addNumber("MAXIMA_PROMINENCE: from 2 (DETECTION LESS SENSITIVE FOR PREPROCESSED IMAGE) to 5 ", _MAXIMA_PROMINENCE);
	Dialog.addNumber("RADIUS_VARIANCE_FILTER : ", _RADIUS_VARIANCE_FILTER);
	Dialog.addNumber("Sigma's Multiplicative Factor", _Sigma_Multiplicative_Factor);
	Dialog.show();
	_SIGMA_START = Dialog.getNumber();
	_SIGMA_DELTA = Dialog.getNumber();
	_SCALE_SPACE_PARTS_OF_WIDTH = Dialog.getNumber();
	_MAXIMA_PROMINENCE = Dialog.getNumber();
	_RADIUS_VARIANCE_FILTER = Dialog.getNumber();
	_Sigma_Multiplicative_Factor = Dialog.getNumber();
	run("Close All");
	dir = getDirectory("Select Image input folder!");
	files = getFileList(dir);
	// get image file name with its tif extension. Or Only One tif Image in a the image_tiff's dircetory is Supported  
	image_name = filterImageFiles(files, dir, _FILE_EXTENSION);
	if ((image_name.length < 1)|(image_name.length > 1 )) {	
		exit("Error Message : No Image tif File Or Only One Image is Supported");
	}
	// images without or with preprocessing 
	waitForUser("before createScaleSpace");
	open(image_name[0]);
	waitForUser("before createScaleSpace");
	createScaleSpace();
	// findAndLinkScaleSpaceSpots();

	Stack_Slice_Spots_X_Array = newArray();
	Stack_Slice_Spots_Y_Array) = newArray();
	waitForUser("findAndLinkScaleSpaceSpots");
	
	findAndLinkScaleSpaceSpots(Stack_Slice_Spots_X_Array,Stack_Slice_Spots_Y_Array);
	waitForUser("av Print Array");
	Array.print(Stack_Slice_Spots_X_Array);
	Array.print(Stack_Slice_Spots_Y_Array);
	print("Done");

}

macro "Visualize Scale Spot Detection Help (f4) Action Tool-C000T4b12?" {
	help();
}

macro "Visualize Scale Spot Detection Help [f4]" {
	help();
}

function help() {
	run('URL...', 'url='+helpURL);
}

function createScaleSpace(){ 
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
		sigma = (_SIGMA_START + _Sigma_Multiplicative_Factor*(i-1) * _SIGMA_DELTA);
		sigmas[i-1] = sigma;
		run("FeatureJ Laplacian", "compute smoothing="+sigma);
		run("Multiply...", "value="+sigma*sigma);
		laplacianID = getImageID();
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

function findAndLinkScaleSpaceSpots(Stack_Slice_Spots_X_Array,Stack_Slice_Spots_Y_Array){
	run("Set Measurements...", "area mean standard modal min centroid center bounding feret's integrated median skewness kurtosis stack display redirect=None decimal=9");
	roiManager("reset");
	run("Clear Results");
	sigmas = newArray(nSlices);
	Stack_Slice_Array = newArray(nSlices);
	
	Stack_Slice_Spots_X_Array = newArray(nSlices);
	Stack_Slice_Spots_Y_Array = newArray(nSlices);
	
	
	for (i = 1; i <= nSlices; i++) {
		sigma = _SIGMA_START + _Sigma_Multiplicative_Factor*(i-1) * _SIGMA_DELTA;
		radius = sigma*_SSF;
		Stack.setSlice(i);
		Stack_Slice_Array[i] = getImageID();
		
		run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
		getSelectionCoordinates(xpoints, ypoints);
		
		Stack_Slice_Spot_Array_X[i]= newArray(xpoints.length);
		Stack_Slice_Spot_Array_Y[i]= newArray(ypoints.length);
		
		roiManager("show all without labels");
		for (j = 0; j < xpoints.length; j++) {
			makePoint(xpoints[j],ypoints[j],"large red cross");
			
			run("Colors...", "foreground=black background=white selection=red");
			roiManager("add");
			
			Stack_Slice_Spot_Array_X[i][j] = xpoints[j];
			Stack_Slice_Spot_Array_Y[i][j] = ypoints[j];
			
		}
		run("Select None");
	}
	roiManager("measure");	
	return Stack_Slice_Spot_Array_X,Stack_Slice_Spot_Array_Y;
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

function detectSpots() {
	run("Set Measurements...", "area mean standard modal min centroid center feret's integrated display redirect=None decimal=9");
	Overlay.remove;
	rgb = (bitDepth()==24);
	if (rgb) {
		run("Duplicate...", " ");
		run("16-bit"); 
	}
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
	if (rgb) {
		run("To ROI Manager");
		close();
		run("From ROI Manager");
	}
	startIndex = nResults;
	Overlay.measure;
	endIndex = nResults;
	reportResults(startIndex, endIndex);
	print("Done!");
}

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

run("Close All");
dir = getDirectory("Select Image input folder!");
files = getFileList(dir);
// get image file with its tif extension 
image_name = filterImageFiles(files, dir, _FILE_EXTENSION);
if (image_name.length < 1) || (image_name.length > 1 ) {
	exit("Error message: only one image is supported in the images_tiff directory");
}

waitForUser("findAndLinkScaleSpaceSpots");
createScaleSpace();
Stack_Slice_Spots_X_Array = newArray();
Stack_Slice_Spots_Y_Array) = newArray();
waitForUser("findAndLinkScaleSpaceSpots");
findAndLinkScaleSpaceSpots(Stack_Slice_Spots_X_Array,Stack_Slice_Spots_Y_Array);
waitForUser("av Print Array");
Array.print(Stack_Slice_Spots_X_Array);
Array.print(Stack_Slice_Spots_Y_Array);
print("Done");

findAndLinkScaleSpaceSpots();
