var _TRAP_LENGTH = 300;
var _Y_MIN = 20;
var _TOO_LONG_FACTOR = 1.7;
var _MIN_CIRCULARITY=0.14;
var _MIN_AREA=10000;
var _NUMBER_OF_ROWS = 11;
var _NUMBER_OF_COLUMNS =11;
var COLUMN_NAMES = newArray("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K");
var ROW_NAMES = newArray("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K");
var _EVENTS = newArray();	// The indices of the array are the numbers of the traps - 1
							// An event has the form obj-xcenter-y-center-startSlice-EndSlice
var _MIN_INT_DEN = 100000;
var _FILLED_TRAPS;


var _MIN_RADIUS = 20;
var _MAX_RADIUS = 50;
var _RADIUS_STEP = 4;
var _MAX_MEAN_INTENSITY = 65;
var _MIN_QUALITY_CIRCLE = 100;

var _ENLARGE_BY = 10
var _PLOT_MEASUREMENTS = true;
var _AUTO_MAX_MEAN = true

var _MAX_DIST = 30;
var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Turgomap-Tools";

macro "MRI Turgomap Tools Help Action Tool - C000D26D38D3dD44D4bD81D8cDc8Dc9De7De9C777D02D03D0dD0eD11D1aD21D2eD2fD31D41D46D48D4fD56D57D59D5dD62D65D68D6aD75D76D78D80D84D86D8bD8dD90D91D96D99D9bD9fDa0Da6Da7Da8Da9DaaDadDafDb4DbbDbfDcaDcfDd1Dd5DdbDdcDdfDe1De2De4De5DeaDebDedDeeDefDf6DfbDfcDfdDfeDffC555D1bD34D39D3bD4aD51D5bD74D8aD92D93D98D9aDb8C777D06D0aD0bD0cD17D23D47D4eD50D58D5aD5fD60D70Da1DabDacDb1Db6DbaDc1Dd2De3Df5C333D13D19D1cD29D45D54D5cD6cD6dD7eD82D8eDd4De6C666D01D04D0fD10D1dD1eD1fD20D30D3eD3fD40D5eD67D69D6bD6fD79D7aD7bD85D88D89D94D95DaeDb0Db7DbcDbdDbeDc0Dc6DcbDccDcdDceDd0DdaDddDdeDe0DecDf0Df1Df2Df3Df4C888D05D18D24D49D7dDd7DfaC222D14D15D16D25D27D2cD32D37D63Db5Dc7Dd9De8C666D00D12D33D42D55D66D77D7fD8fD97D9cDb9Df9C444D28D2bD53D64D87Da3Da5Dc5C888D3cDb3C111D08D2dD35D61D6eD71D7cDa4Db2Dc3C444D22D36D4dD52D73D9eDa2Df8C333D07D09D3aD43D4cD83D9dDc2Dd3C555D2aDc4Dd6Df7C999D72Dd8" {
	run('URL...', 'url='+helpURL);
}

macro 'Create Grid Action Tool (f1) - C000T4b12g' {
	createGrid();
}

macro 'Detect Circles Action Tool (f2) - C000T4b12c' {
	detectCircles(0, true);
}

macro 'Detect Circles Action Tool (f2) Options' {
	detectCircleOptions();
}

macro 'Next Circle Action Tool (f5) - C000T4b12n' {
	nextCircle();
}

macro 'Detect Circles Tool - C000T4b12d' {
	getCursorLoc(x, y, z, modifiers);
	width = 2*_MAX_RADIUS+1;
	makeOval(x-(width/2), y-(width/2), width, width);
	detectCircles(0, true);
}

macro 'Track Circles Action Tool - C000T4b12t (f3)' {
	trackCircle();
}

macro 'Measure Swelling Action Tool (f9) - C000T4b12m' {
	measureSwelling();	 
}

macro "create-grid [f1]" {
	createGrid();
}

macro "detect-circles [f2]" {
	detectCircles(0, true);
}

macro "detect-circles [f3]" {
	trackCircle();
}

macro "next-circle [f5]" {
	nextCircle();
}

macro "measure-swelling [f9]" {
	measureSwelling();
}

function createGrid() {
	count = selectTraps();
	if (count!=_NUMBER_OF_ROWS*_NUMBER_OF_COLUMNS) {
		showMessage("Could not create the grid !!!");
		exit;
	}
	makeCircles();
	run("From ROI Manager");
	roiManager("Delete");
	run("Labels...", "color=white font=12 show draw");
	markEmptyTraps();
}

function selectTraps() {
	imageID = getImageID();
	roiManager("Reset");
	run("Options...", "iterations=10 count=1 do=Nothing");
	run("Duplicate...", "use");
	run("Subtract Background...", "rolling=30");
	setAutoThreshold("Li dark");
	run("Convert to Mask");
	run("Dilate");
	run("Analyze Particles...", "size="+2*_MIN_AREA+"-Infinity show=Masks in_situ");
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity circularity=0.15-1.00 exclude add");
	roiManager("Select", 0);
	getSelectionBounds(x, y, width, height)
	if (y<_Y_MIN) roiManager("delete");
	roiManager("deselect");
	count = roiManager("Count");
	averageLength = _TRAP_LENGTH;
	roisToBeSplitted = newArray();
	for(i=0; i<count; i++) {
		roiManager("Select", i);
		getSelectionBounds(x, y, width, height);
		length = max(width, height);
		if (length>_TOO_LONG_FACTOR*averageLength) {
			roisToBeSplitted = Array.concat(roisToBeSplitted, i); 	
		}
	}
	
	setForegroundColor(255, 255, 255);
	for (i=0; i<roisToBeSplitted.length; i++) {
		index = roisToBeSplitted[i];
		roiManager("Select", index);
		getSelectionBounds(x, y, width, height);
		if (width>height) {
			drawLine(x+width/2, y-5, x+width/2, y+height+5);
		} else {
			drawLine(x-5, y+height/2, x+width+5, y+height/2);
		}
	}
	
	roiManager("Reset");
	run("Select None");
	run("Analyze Particles...", "size=10000-Infinity circularity="+_MIN_CIRCULARITY+"-1.00 exclude add");
	roiManager("Select", 0);
	getSelectionBounds(x, y, width, height);
	if (y<_Y_MIN) roiManager("delete");
	result = roiManager("Count");
	close();
	selectImage(imageID);
	return result;
}

function makeCircles() {
	count = roiManager("Count");
	run("Options...", "iterations=10 count=1 do=Nothing");
	for(i=0; i<count; i++) {
		originalImage = getImageID();
		roiManager("Select", i);
		getSelectionBounds(x, y, width, height);
		run("Duplicate...", "use");
		trapImage = getImageID();
		selectImage(originalImage);
		run("Select None");
		selectImage(trapImage);
		run("Select None");
		setAutoThreshold("Huang");
		run("Convert to Mask");
		run("Analyze Particles...", "size=2000-Infinity show=Masks include in_situ");
		run("Erode");
		run("Fit Circle to Image", "threshold=254");
		getSelectionBounds(xCircle, yCircle, widthCircle, heightCircle);
		selectImage(originalImage);
		run("Restore Selection");
		setSelectionLocation(x+xCircle, y+yCircle);
		roiManager("add");
		selectImage(trapImage);
		close();
	}
	indices = newArray();
	for(i=0; i<count; i++) {
		indices = Array.concat(indices, i);
	}
	roiManager("select", indices);
	roiManager("delete");
	run("Select None");
	for(row=0; row<_NUMBER_OF_ROWS; row++) {
		xCoords = newArray();
		for(column=0; column<_NUMBER_OF_COLUMNS; column++) {
			roiManager("select", _NUMBER_OF_ROWS * row + column);
			getSelectionBounds(x, y, width, height);
			xCoords = Array.concat(xCoords, x);
		}	
		rankPositions = Array.rankPositions(Array.rankPositions(xCoords));
		Array.print(xCoords);
		Array.print(rankPositions);
		for(column=0; column<_NUMBER_OF_ROWS; column++) {
			roiManager("select", _NUMBER_OF_ROWS * row + column);
			roiManager("rename", ROW_NAMES[row] + "-" + COLUMN_NAMES[rankPositions[column]]);
		}
	}
	roiManager("sort");
	roiManager("Remove Channel Info");
	roiManager("Remove Slice Info");
	roiManager("Remove Frame Info");
	roiManager("Show None");
	roiManager("Show All");
}

function max(a,b) {
	result = a;
	if (b>a) result = b;
	return result;
}

function markEmptyTraps() {
	file = getInfo("image.directory") + "/" + getInfo("image.filename");
	imageID = getImageID();
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	run("Reduce...", "reduction=10");
	run("Stack Difference", "gap=1");
	run("Z Project...", "projection=[Max Intensity]");
	setAutoThreshold("RenyiEntropy dark");
	run("Convert to Mask", "method=RenyiEntropy background=Dark");
	maskID = getImageID();
	selectImage(imageID);	
	run("To ROI Manager");
	run("Remove Overlay");
	count = roiManager("count");
	_FILLED_TRAPS = newArray(count);
	for(i=0; i<count; i++) {
		roiManager("select", i);
		selectImage(maskID);	
		run("Restore Selection");
		getStatistics(area, mean);
		intDen = area * mean;
		selectImage(imageID);	
		if (intDen > _MIN_INT_DEN) {
			_FILLED_TRAPS[i] = true;
			Overlay.addSelection("green", 2);
		} else {
			_FILLED_TRAPS[i] = false;
			Overlay.addSelection("red", 2);
		}
	}
	roiManager("reset");
	run("Labels...", "color=white font=12 show");
	selectImage(maskID);	
	close();
	selectImage(imageID);	
}


function nextCircle() {
	run("Measure");
	x1=getResult("X", nResults-1);
	y1=getResult("Y", nResults-1);
	run("Add Selection...");
	Overlay.activateSelection(0);
	sliceNr = getSliceNumber();
	if (sliceNr==nSlices) return 999999;
	setSlice(sliceNr+1);
	detectCircles(0, false);
	run("Clear Results");
	roiManager("Deselect");
	roiManager("Measure");
	minDist = 999999;
	minIndex = -1;
	for (i = 0; i < nResults; i++) {
		x2 = getResult("X", i);
		y2 = getResult("Y", i);
		dy = y2-y1;
		dx = x2-x1;
		dist = dx*dx + dy*dy;
		if (dist<minDist) {
			minDist = dist;
			minIndex = i;
		}
	}
	roiManager("select", minIndex);
	return minDist;
}

function detectCircles(backgroundColor, duplicate) {
	if (selectionType()==-1) return;
	run("MRI Roi Util");
	setupMeasurements();
	roiManager("reset")
	roiManager("add");
	if (_AUTO_MAX_MEAN) {
		roiManager("Select", 0);
		getStatistics(area, mean);
		_MAX_MEAN_INTENSITY = mean + 3;
	}
	setBatchMode(true);
	runFindCircles(_MIN_RADIUS, _MAX_RADIUS, _RADIUS_STEP, backgroundColor, duplicate);
	setBatchMode("exit and display");
	drawCirclesAbove(_MIN_QUALITY_CIRCLE);
	removeIntersectingRois();
	nrOfCircles = roiManager("count")-1;
	if (nrOfCircles>3) removeBrightCircles();
	sortCirclesByIntensity();
	run("Select None");
	roiManager("Deselect");
	roiManager("Show None");
	roiManager("select", 0);
}

function setupMeasurements() {
	run("Set Measurements...", "area mean modal min centroid stack display redirect=None decimal=3");
}

function runFindCircles(minRadius, maxRadius, step, backgroundColor, duplicate) {
	roiManager("Select", 0);
	getSelectionBounds(xBox, yBox, widthBox, heightBox);
	if (duplicate) {
		sliceNr = getSliceNumber();
		run("Duplicate...", "duplicate");
		setSlice(sliceNr);
		setBackgroundColor(backgroundColor, backgroundColor, backgroundColor);
		run("Clear Outside", "stack");
	}
	imageID = getImageID();
	
	title = "Circles";
	handle = "[" + title + "]";
	counter = 0;
	if (isOpen(title)) {
	     print(handle, "\\Clear");
	}
	else
	     run("Table...", "name="+handle+" width=400 height=600");
	 
	print(handle, "\\Headings:n\tradius\tx\ty\tscore");
	
	for (radius=minRadius; radius<=maxRadius; radius=radius+step) {
		run("Duplicate...", " ");
		workingImageID = getImageID();
		findCircles();
		run("Find Maxima...", "noise=20 output=[Point Selection]");
		run("Clear Results");
		run("Measure");
		for (i=0; i<nResults; i++) {
			x = getResult("X", i);
			y = getResult("Y", i);
			score = getResult("Mode", i);
			print(handle, "" + (++counter) + "\t" + radius + "\t" + x + "\t" + y + "\t" + score);
		}
		close();
		selectImage(imageID);
	}
	//close();
}

function trackCircle() {
	setupMeasurements();
	slice = getSliceNumber();
	counter = 0;
	getBoundingRect(x, y, width, height);
	for(i=slice; i<=nSlices; i++) {
		distance = nextCircle();
		if (distance>_MAX_DIST) break;
	}
	measureSwelling();
}

function removeBrightCircles() {
	count = roiManager("count");
	indices = newArray();
	for(i=1; i<count; i++) {
		roiManager("Select", i);
		run("Area to Line");
		getStatistics(area, mean);
		if (mean>_MAX_MEAN_INTENSITY) indices = Array.concat(indices, i);
	}
	if (indices.length==0) return;
	roiManager("Select", indices);
	roiManager("Delete");
}

function sortCirclesByIntensity() {
	count = roiManager("count");
	means = newArray(count);
	means[0] = -1;
	for(i=1; i<count; i++) {
		roiManager("Select", i);
		run("Area to Line");
		getStatistics(area, mean);
		means[i]=mean;
	}
	sortRoisBy(means);
}

function removeIntersectingRois() {
	indices = newArray();
	roiManager("Select", 0);
	getSelectionCoordinates(X1, Y1);
	count = roiManager("count");
	for(i=1; i<count; i++) {
		roiManager("Select", i);
		getSelectionCoordinates(X2, Y2);
		result = Ext.doRoisOverlap(X1,Y1,X2,Y2);
		if (result=="true") indices = Array.concat(indices, i);
	}
	if (indices.length == 0) return; 
	roiManager("Select", indices);
	roiManager("Delete");
}

function detectCircleOptions() {
  //Create and show the user input dialog
    Dialog.create("Find Circles");
    Dialog.addNumber("Min. radius: ",  _MIN_RADIUS);
    Dialog.addNumber("Max. radius: ",  _MAX_RADIUS);
	Dialog.addNumber("Delta radius: ", _RADIUS_STEP);
	Dialog.addCheckbox("Auto. find max. mean intensity ", _AUTO_MAX_MEAN)
	Dialog.addNumber("Max. mean intensity: ", _MAX_MEAN_INTENSITY);
	Dialog.addNumber("Min. quality of circle: ", _MIN_QUALITY_CIRCLE);
    Dialog.show();
    _MIN_RADIUS = Dialog.getNumber();
    _MAX_RADIUS = Dialog.getNumber();
    _RADIUS_STEP = Dialog.getNumber();
    _AUTO_MAX_MEAN = Dialog.getCheckbox();
    _MAX_MEAN_INTENSITY = Dialog.getNumber();
    _MIN_QUALITY_CIRCLE = Dialog.getNumber();
}

function findCircles() {
	inverted=true;
	filled=false;
	slices=true;
    snapshot();
    //If RGB then convert to 8-bit for analysis
    if (bitDepth()==24) {
        run("8-bit");
    }
    //Pick a good value for maximum image value for image inversion
    if (bitDepth()==32) {
        amax=0;
    } else {
        amax=pow(2, bitDepth())-1;
    }

    //Derive the slice range to analyse
    if (nSlices==1) {
        startSlice=1;
        endSlice=1;
    } else {
        if (slices==true) {
            startSlice=1;
            endSlice=nSlices();
        } else {
            startSlice=getSliceNumber();
            endSlice=getSliceNumber();
        }
    }

    for (i=startSlice; i<=endSlice; i++) {
        setSlice(i);
        //Invert (if selected)
        if (inverted==true) {
            run("Macro...", "code=[v="+amax+"-v] slice");
        }
        //Find edges in the image prior to analysis (if optimised to also find filled circles)
        if (filled==true) {
            run("Find Edges", "slice");
        }
        //Find circles in the image
        diameter=2*round(radius)+1;
        circleKernel(diameter);            
    }
}

function measureSwelling() {
	run("Clear Results");
	Overlay.activateSelection(0);
	Overlay.removeSelection(0);
	Overlay.measure;
	Overlay.add;	
	area = newArray(nResults);
	if(_PLOT_MEASUREMENTS) {
		time = newArray(nResults);
		for(i=0; i<nResults; i++) {
			area[i] = getResult("Area", i);
			time[i] = i+1;
		}
		
		Plot.create("Area/time", "time", "area", time, area);
	}
}

//Function to generate and apply a circle shaped kernel
//The diameter must be odd and greater than zero, very large diameters are slow
function circleKernel(diameter) {
    //Make an image to generate the kernel pattern in
    newImage("Kernel", "8-bit Black", diameter, diameter, 1);
    //And make a hollow circle 1px in thickness with a value of one
    makeOval(0, 0, diameter, diameter);
    setColor(1);
    fill();
    makeOval(1, 1, diameter-2, diameter-2);
    setColor(0);
    fill();
    run("Select None");
    setMinAndMax(0, 1);

    //Record the kernel by reading the image values to a 2D array
    kernel=newArray(diameter*diameter);
    kernelstring="";
    for (x=0; x<diameter; x++) {
        for (y=0; y<diameter; y++) {
            kernel[x+y*diameter]=getPixel(x, y);
            kernelstring+=""+getPixel(x, y)+" ";
        }
        kernelstring+="\n";
    }
    //And close the kernel image
    close();

    //Apply the kernel to the image
    run("Convolve...", "text1=["+kernelstring+"] normalize slice");
} 


function drawCirclesAbove(scoreMin) {
	selectWindow("Circles");
	text = getInfo("window.contents");
	lines = split(text, "\n");
	for(i=1; i<lines.length; i++) {
		line = split(lines[i], "\t");
		radius = parseFloat(line[1]);
		x = parseFloat(line[2]);
		y = parseFloat(line[3]);
		score = parseFloat(line[4]);
		if (score>scoreMin) {
			makeOval(x-radius,y-radius,(2*radius)+1, (2*radius)+1);
			roiManager("add");
		}
	}
}

function sortRoisBy(aList) {
	REVERSE = true;
	Array.sort(aList);
	positions = Array.rankPositions(aList);
	if (REVERSE) Array.reverse(positions);
	ranks = Array.rankPositions(positions);
	// Your code starts after this line
	for (i=0; i<roiManager("count"); i++) {
		/* select the element number i in the roi manager*/
		roiManager("select", i);
		/* Rename the selected roi in the roi manager to its position in the sorted list, that is rename it to IJ.pad(ranks[i], 4) */
		roiManager("Rename", IJ.pad(ranks[i]+1, 4)); 
		print(aList[i]);
	}
	/* Deselect all rois in the roi-manager */
	roiManager("Deselect");
	/* Sort the rois in the roi-manager according to their names */
	roiManager("Sort");
	roiManager("Show None");
	roiManager("Show All");
}
