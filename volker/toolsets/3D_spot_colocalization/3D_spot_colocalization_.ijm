var _NUCLEUS_CHANNEL = 1;
var _SPOTS1_CHANNEL = 2;
var _SPOTS2_CHANNEL = 3;
var _SIGMA = 1;
var _MAX_FINDER_THRESHOLD = 35;
var _RADIUS_XY = 3;
var _RADIUS_Z = 5;
var _NOISE = 25;

inputImageID = getImageID();
detectSpots(_SPOTS1_CHANNEL, _SIGMA);
spots1 = getImageID();
selectImage(inputImageID);
segmentNucleus(_NUCLEUS_CHANNEL)
nucleusMask = getImageID();
run("Invert", "stack");
imageCalculator("AND create stack", spots1, nucleusMask);
maskedSpots1 = getImageID();
selectImage(spots1);
close();
filterSpots(maskedSpots1);


function segmentNucleus(channel) {
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	maskID = getImageID();
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
}

function filterSpots(imageID) {
	Table.create("spots");
	selectImage(imageID);
	for (i = 0; i < nResults(); i++) {
		x = getResult("X", i);	
		y = getResult("Y", i);	
		z = getResult("Z", i);	
		q = getResult("V", i);
		Stack.setSlice(z);
		v = getPixel(x, y);
		if (v>0) {
			row = Table.size("spots");
			Table.set("X", row, x, "spots");
			Table.set("Y", row, y, "spots");
			Table.set("Z", row, z, "spots");
			Table.set("V", row, q, "spots");
		}
	}
	close("Results");
	Table.rename("spots", "Results");
}

function detectSpots(channel, sigma) {
	inputImageID = getImageID();
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	channelImage = getImageID();
	run("FeatureJ Laplacian", "compute smoothing=" + sigma);	
	laplaceImage = getImageID();
	run("8-bit");
	run("Invert", "stack");
	run("3D Maxima Finder", "minimmum="+_MAX_FINDER_THRESHOLD+" radiusxy="+_RADIUS_XY+" radiusz="+_RADIUS_Z+" noise="+_NOISE);
	setThreshold(1, 65535);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Grays");
	for (i = 0; i < 3; i++) {
		run("Dilate (3D)", "iso=255");
	}
	selectImage(channelImage);
	close();
	selectImage(laplaceImage);
	close();
}