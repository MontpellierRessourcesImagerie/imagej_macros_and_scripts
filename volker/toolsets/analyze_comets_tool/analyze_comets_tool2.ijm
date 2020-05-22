var _CHANNEL_RED = 1;
var _CHANNEL_GREEN = 2;
var _SIGMA = 33;
var _THRESHOLDING_METHOD = "Intermodes";
var _PROEMINENCE = 0.10;

var _DELTA_X = 2;
var _MAX_RADIUS = 100;
var _LINE_WIDTH = 13;
var _MIN_TOLERANCE = 0;

preSegmentCells();
setBatchMode(true);
normalizedSumOfRedAndGreenChannels();
count = roiManager("count");

for (i = 0; i < count; i++) {
	showProgress(i, count-1);
	roiManager("select", i);
	adjustRoiBorders();
	roiManager("update");	
}
setBatchMode(false);
close();
roiManager("Show None");
roiManager("Show All");

function preSegmentCells() {
	imageID = getImageID();
	
	run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
	redID = getImageID();
	rename("red");
	run("Gaussian Blur...", "sigma="+_SIGMA);
	selectImage(imageID);
	
	run("Duplicate...", "duplicate channels="+_CHANNEL_GREEN+"-"+_CHANNEL_GREEN);
	rename("green");
	greenID = getImageID();
	run("Enhance Contrast...", "saturated=0 equalize");
	run("Gaussian Blur...", "sigma="+_SIGMA);
	normalizeImage(greenID);
	normalizeImage(redID);
	imageCalculator("Add create 32-bit", "green","red");
	sumID = getImageID();
	rename("sum");
	run("Gaussian Blur...", "sigma="+_SIGMA);
	run("Find Maxima...", "prominence="+_PROEMINENCE+" output=[Segmented Particles]");
	rename("sumSegmented");
	sumSegmentedID = getImageID();
	
	selectImage(sumID);
	setAutoThreshold(_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	imageCalculator("AND create", "sum","sumSegmented");
	
	roiManager("reset");
	run("Analyze Particles...", "size=1000-Infinity exclude add");
	close();
	close();
	close();
	close();
	close();
	roiManager("Show None");
	roiManager("Show All");
}

function normalizedSumOfRedAndGreenChannels() {
	run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
	redID = getImageID();
	rename("red");	
	run("Duplicate...", "duplicate channels="+_CHANNEL_GREEN+"-"+_CHANNEL_GREEN);
	rename("green");
	greenID = getImageID();
	run("Enhance Contrast...", "saturated=0 equalize");
	normalizeImage(greenID);
	normalizeImage(redID);
	imageCalculator("Add create 32-bit", "green","red");
	selectImage(redID);
	close();
	selectImage(greenID);
	close();
}

function adjustRoiBorders() {
	run("Interpolate", "interval=1 smooth adjust");
	getSelectionCoordinates(xpoints, ypoints);
	N = xpoints.length;
	xPointsCorrected = newArray(xpoints.length);
	yPointsCorrected = newArray(xpoints.length);
	for (i = 0; i < xpoints.length; i++) {
		i0 = i-_DELTA_X;
		if (i0<0) i0 = N + i0;
		i1 = (i+_DELTA_X) % N;
		makeLine(xpoints[i0], ypoints[i0], xpoints[i1], ypoints[i1]);
		run("Rotate...", "angle=90");
	 	getSelectionCoordinates(xL, yL);
	    x1 = xL[0];
	    y1 = yL[0];
	    x2 = xL[xL.length-1];	
	    y2 = yL[yL.length-1];
		dx = x2-x1;	
	    dy = y2-y1;
	    n = round(sqrt(dx*dx + dy*dy));
	    xInc = _MAX_RADIUS * (dx / n);
	    yInc = _MAX_RADIUS * (dy / n);
	    makeLine(xpoints[i], ypoints[i], xpoints[i]+xInc, ypoints[i1]+yInc, _LINE_WIDTH);
	    profile1 = getProfile();
	    minima1 = Array.findMinima(profile1, _MIN_TOLERANCE);
	    if(minima1.length==0) min = 0;
	    else min = minima1[0];
	    makeLine(xpoints[i], ypoints[i], xpoints[i]-xInc, ypoints[i1]-yInc, _LINE_WIDTH);
	    profile2 = getProfile();
	    minima2 = Array.findMinima(profile2, _MIN_TOLERANCE);
	    if(minima2.length==0) min2 = 0;
	    else min2 = minima2[0];
	    if (profile1[min]<profile2[min2]) {
	    	xPointsCorrected[i] = xpoints[i]+min*(dx / n);
	    	yPointsCorrected[i] = ypoints[i]+min*(dy / n);
	    } else {
	    	xPointsCorrected[i] = xpoints[i]-min2*(dx / n);
	    	yPointsCorrected[i] = ypoints[i]-min2*(dy / n);    
	    }
	}
	makeSelection("freehand", xPointsCorrected, yPointsCorrected);
	run("Fit Spline");
	run("Interpolate", "interval=1 smooth adjust");
}

function normalizeImage(id) {
	selectImage(id);
	getStatistics(area, mean, min, max, std, histogram);
	run("32-bit");
	run("Divide...", "value="+max);	
	run("Enhance Contrast", "saturated=0.35");
}

