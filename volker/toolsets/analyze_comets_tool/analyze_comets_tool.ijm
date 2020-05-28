var _CHANNEL_RED = 1;
var _CHANNEL_GREEN = 2;
var _SIGMA = 22;
var _THRESHOLDING_METHOD = "Intermodes";
var _PROEMINENCE = 0.10;

var _DELTA_X = 2;
var _MAX_RADIUS = 100;
var _LINE_WIDTH = 13;
var _MIN_TOLERANCE = 0;

var _MIN_SIZE_COMETS = 25;

run("Remove Overlay");
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

run("Select None");
inputImageID = getImageID();
run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
segmentComets();
cometsImageID = getImageID();
counts = countCometsPerCell();
selectImage(inputImageID);
run("From ROI Manager");
roiManager("reset");
selectImage(cometsImageID);
run("To ROI Manager");
close();
run("From ROI Manager");
roiManager("reset");
drawLabels();
reportCounts(counts);

function reportCounts(counts) {
	image = getTitle();
	title = "number of comets per cell";
	line = 0;
	if (!isOpen(title)) {
		Table.create(title);
	} else {
		line = Table.size(title);
	}
	for (i = 0; i < counts.length; i++) {
		Table.set("nr.", line+i, line+i+1, title);
		Table.set("image", line+i, image, title);
		Table.set("cell", line+i, i+1, title);
		Table.set("comets", line+i, counts[i], title);
	}
}

function countCometsPerCell() {
	count = roiManager("count");
	counts = newArray(count);
	for (r = 0; r < count; r++) {	
		snapshot();
		roiManager("select", r);
		getSelectionBounds(x, y, width, height);
		run("Make Inverse");
		run("Fill", "slice");
		run("Select None");
		counts[r] = findEndPoints(floor(x), floor(y) , round(width), round(height), "blue circle");
		reset();
	}
	return counts;
}

function segmentComets() {
	redImageID = getImageID();
	run("FeatureJ Laplacian", "compute smoothing=3");
	run("Invert");
	setAutoThreshold("Li dark");
	run("Analyze Particles...", "size=25-Infinity show=Masks exclude in_situ");
	run("Skeletonize");
	selectImage(redImageID);
	close();
}

function preSegmentCells() {
	imageID = getImageID();
	
	run("Duplicate...", "duplicate channels="+_CHANNEL_RED+"-"+_CHANNEL_RED);
	redID = getImageID();
	rename("red");	run("Enhance Contrast...", "saturated=0 equalize");
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

function drawLabels() {
	setFont("SansSerif" , 48, "antialiased"); 
	for (i = 0; i < Overlay.size; i++) {
		Overlay.activateSelection(i);
		type = selectionType();
		getSelectionBounds(x, y, width, height);
		run("Select None");
		if (type>4) break;
		Overlay.drawString(i+1, x+width/2, y+height/2);
	}
}
