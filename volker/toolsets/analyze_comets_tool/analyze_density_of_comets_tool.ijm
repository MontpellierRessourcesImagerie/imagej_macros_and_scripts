var _RED_CHANNEL = 1;
var _BLUE_CHANNEL = 3;
var _COMET_CHANNEL = 2;
var _Z_POS = 4;
var _MIN_SIZE = 40;

var _RED_CHANNEL = 1;
var _BLUE_CHANNEL = 3;
var _Z_POS = 3;
var _MIN_SIZE = 40;
var _MIN_INTENSITY_RED = 6000;
var _THRESHOLDING_METHOD_CYTOPLASM = "Huang";

var _MIN_SIZE_COMETS = 0.1;
var _MAX_CIRCULARITY = 0.7;
var _THRESHOLDING_METHOD_COMETS = "Li";
var _UPPER_SCALE_COMETS = 7;
var _LOWER_SCALE_COMETS = 0.7;
var _NR_OF_DILATES = 4;
var _NR_OF_ERODES = 4;

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
	selectImage(inputImageID);
	run("From ROI Manager");
	roiManager("Deselect");
	roiManager("Delete");
	run("Select None");
	selectImage(maskID);
	run("Analyze Particles...", "clear add");
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
