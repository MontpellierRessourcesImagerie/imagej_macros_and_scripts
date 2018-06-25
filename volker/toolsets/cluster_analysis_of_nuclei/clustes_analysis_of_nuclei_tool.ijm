var _CORRECT_BACKGROUND = true;
var _SMOOTH_IMAGE = true;
var ROLLING_BALL_RADIUS = 20;
var _SMOOTHING_RADIUS = 3;
var _NOISE = 12;

inputImageID = getImageID();
run("Duplicate...", " ");
watershedInputImageID = getImageID();

preProcessing();

createSeedsImage(_NOISE);
seedImageID = getImageID();
seedsImageTitle = getTitle();
selectImage(watershedInputImageID);
watershedInputImageTitle = getTitle();
applyMarkerBasedWatershed(seedImageID, watershedInputImageID);
selectImage(inputImageID);
roiManager("Show None");
roiManager("Show All");

function preProcessing() {
	if (_CORRECT_BACKGROUND) run("Subtract Background...", "rolling=" + ROLLING_BALL_RADIUS);
	if (_SMOOTH_IMAGE) run("Gaussian Blur...", "sigma=" + _SMOOTHING_RADIUS);
}



function createSeedsImage(noise) {
	run("Duplicate...", " ");
	inputImage = getImageID();
	run("8-bit");
	run("Find Maxima...", "noise="+noise+" output=[Point Selection] exclude");
	getSelectionCoordinates(xpoints, ypoints);
	run("Select All");
	setBackgroundColor(0, 0, 0);
	run("Clear", "slice");
	run("Select None");
	makeSelection("point", xpoints, ypoints);
	setForegroundColor(255, 255, 255);
	run("Draw", "slice");
	run("Select None");
}

function applyMarkerBasedWatershed(seedImageID, watershedImageID) {
	run("Set Measurements...", "modal display redirect=None decimal=3");
	selectImage(watershedImageID);
	run("Find Edges");
	edgesTitle = getTitle();
	parts = split(edgesTitle, ".");
	edgesTitle = parts[0];
	selectImage(seedImageID);
	seedTitle = getTitle();
	parts = split(seedTitle, ".");
	seedTitle = parts[0];
	run("Marker-controlled Watershed", "input="+edgesTitle+" marker="+seedTitle+" mask=None binary calculate use");
	getStatistics(area, mean, min, max);
	setThreshold(1, max);
	run("Find Maxima...", "noise=1 output=[Point Selection] exclude");
	roiManager("Add");
}

