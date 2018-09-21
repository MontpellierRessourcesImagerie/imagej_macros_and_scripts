/**
  * MRI Analyze Roots Tool
  * Collaborators:
  *        Philippe NACRY
  *
  * The tool allows to  
  *  * measure the length and area of the main root
  *  * the number of secondary roots
  *  * the length and area of the whole root
  *
  * (c) 2017, INSERM
  * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 *
*/

var _MIN_AREA = 10000;
var _MAX_ROOT_WIDTH = 25;
var _MIN_ROOT_LENGTH = 3000;
var _STEP_WIDTH = 3;
var _MEDIAN_FILTER_RADIUS = 5;
var _TIP_DISTANCE = 6;
var _ENLARGE_MAIN_ROOT_SELECTION1 = 10;
var _MAIN_CENTER_COLOR = "blue";
var _SKELETON_COLOR = "red";
var _MAIN_BORDER_COLOR = "magenta";
var _SEC_ROOT_COLOR = "green";
var _MIN_OBJECT_SIZE = 80;
var _REPORT_TITLE = "Roots-measurements";
var _REPORT_HANDLE = "[" + _REPORT_TITLE + "]";
var _CONTROL_FOLDER = "control";
var _ROTATE = true;
var _ROTATE_DIRECTION = "Right";
var _FILE_EXTENSION = ".jpg";
 
var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/MRI_Analyze_Roots_Tool";

macro "MRI Analyze Roots Tool Help Action Tool - - C0f0D53D63Da4DadDb4Cf00D2bD35D37D38D39D3aD3bD44D45D46D54Db5Db6DbdDbeDc7Dc8Dc9DdaDeaDebC00fD71D72D79D7aD7bD7cD83D84D85D86D87D88D8cD8dD8eD93D94D95D96Cff0D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D1fD20D2fD30D3fD40D4fD50D5fD60D6fD70D7fD80D8fD90D9fDa0DafDb0DbfDc0DcfDd0DdfDe0DefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCf0eD61D62D68D69D6aD6bD6cD6dD73D74D75D76D77D78D7dD7eD81D82D89D8aD8bD92D97D98D99D9bD9cD9dD9eDa2Da3Da5Da6"{
	run('URL...', 'url='+helpURL);
}

macro "Analyze Current Image (f5) Action Tool - C000T4b12a" {
	openResultsTable();
	analyzeRootsInCurrentImage();
}

macro 'Analyze Current Image [f5]' {
	openResultsTable();
	analyzeRootsInCurrentImage();
}

macro "Batch Process Images (f6) Action Tool - C000T4b12b" {
	openResultsTable();
	batchProcessImages();
}

macro 'Batch Process Images [f6]' {
	openResultsTable();
	batchProcessImages();
}

macro 'Analyze Current Image (f5) Action Tool Options' {
	 showOptionsDialog();
}


macro 'Batch Process Images (f6) Action Tool Options' {
	showOptionsDialog();
}

function showOptionsDialog() {
	Dialog.create("Analyze Roots Tool Options");
	 Dialog.addNumber("min. area: ", _MIN_AREA);
	 Dialog.addNumber("max. root width: ", _MAX_ROOT_WIDTH);
	 Dialog.addNumber("min. root length: ", _MIN_ROOT_LENGTH);
	 Dialog.addNumber("step width: ", _STEP_WIDTH);
	 Dialog.addNumber("median filter radius: ", _MEDIAN_FILTER_RADIUS);
	 Dialog.addNumber("tip distance: ", _TIP_DISTANCE);
	 Dialog.addNumber("enlarge main root selection: ", _ENLARGE_MAIN_ROOT_SELECTION1);
	 Dialog.addNumber("min. object size: ", _MIN_OBJECT_SIZE);
	 Dialog.addString("center color of main root: ", _MAIN_CENTER_COLOR);
	 Dialog.addString("border color of main root: ", _MAIN_BORDER_COLOR); 
	 Dialog.addString("skeleton color of secondary roots: ", _SKELETON_COLOR);
     Dialog.addString("base color of secondary roots: ", _SEC_ROOT_COLOR);
	 Dialog.addChoice("rotate image into direction: ", newArray("Right", "Left", "None"), _ROTATE_DIRECTION);
	 Dialog.addString("file extension: ",  _FILE_EXTENSION);
	 
	 Dialog.show();
	 
	 _MIN_AREA = Dialog.getNumber();
	 _MAX_ROOT_WIDTH = Dialog.getNumber();
	 _MIN_ROOT_LENGTH = Dialog.getNumber();
	 _STEP_WIDTH = Dialog.getNumber();
	 _MEDIAN_FILTER_RADIUS = Dialog.getNumber();
	 _TIP_DISTANCE = Dialog.getNumber();
	 _ENLARGE_MAIN_ROOT_SELECTION1 = Dialog.getNumber();
	 _MIN_OBJECT_SIZE = Dialog.getNumber();
	 _MAIN_CENTER_COLOR = Dialog.getString();
	 _MAIN_BORDER_COLOR = Dialog.getString();
	 _SKELETON_COLOR = Dialog.getString();
	 _SEC_ROOT_COLOR = Dialog.getString();
	 _ROTATE_DIRECTION = Dialog.getChoice();
	 if (_ROTATE_DIRECTION=="None") 
	 	_ROTATE = false;
	 else 
	 	_ROTATE = true;
	  _FILE_EXTENSION = Dialog.getString();
}

function openResultsTable() {
	if (!isOpen(_REPORT_TITLE)){
		run("Table...", "name="+_REPORT_HANDLE+" width=800 height=600");
 		print(_REPORT_HANDLE, "\\Headings:nr\tmain root length\tmain root area\tnr. of 2-order roots\ttotal area\ttotal length\timage");
	}
}

function batchProcessImages() {
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	startTimeStamp = "" + year + "-" + (month + 1)+"-"+dayOfMonth+"--"+hour+"."+minute+"."+second+"."+msec;
	dir = getDirectory("Please select the input folder!");
	files = getFileList(dir);
	images = newArray();
	print("\\Clear");
	print(startTimeStamp);
	print("Start analyzing roots");
	for(i=0; i<files.length; i++) {
		if (endsWith(files[i], _FILE_EXTENSION)) images = Array.concat(images, files[i]);
	}
	File.makeDirectory(dir + _CONTROL_FOLDER);
	for (i=0; i<images.length; i++) {
		print("\\Update2:Processing image " + (i+1) + " of " + images.length + "."); 
		open(dir + images[i]);
		if (_ROTATE) run("Rotate 90 Degrees "+ _ROTATE_DIRECTION);
		analyzeRootsInCurrentImage();
		saveAs("Tiff", dir + _CONTROL_FOLDER + "/" + images[i]);
		close();
	}
	selectWindow(_REPORT_TITLE);
	saveAs("Text", dir + _REPORT_TITLE + "-" + startTimeStamp + ".xls");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	endTimeStamp = "" + year + "-" + (month + 1)+"-"+dayOfMonth+"--"+hour+"."+minute+"."+second+"."+msec;
	print("Finished analyzing roots");
	print(endTimeStamp);
}

function analyzeRootsInCurrentImage() {
	setBackgroundColor(255,255,255);
	run("Set Measurements...", "area bounding area_fraction stack display redirect=None decimal=3");
	roiManager("Reset");
	run("Select None");
	
	inputImageID = getImageID();
	inputTitle = getTitle();

	for(i=150; selectionType()<0 && i<5600; i=i+150) {
		doWand(3456+i, 3564, 45.0, "Legacy");
	}
	run("Enlarge...", "enlarge=20");
	run("Enlarge...", "enlarge=-30");
	getStatistics(area, mean);
	
	run("Create Mask");
	firstMaskID = getImageID();
	run("Fill Holes");
	run("Create Selection");
	selectImage(inputImageID);
	run("Restore Selection");
	selectImage(firstMaskID);
	close();
	selectImage(inputImageID);
	
	run("Make Inverse");
	setForegroundColor(mean, mean, mean);
	run("Fill", "slice");
	run("Select None");
	
	run("Duplicate...", " ");
	maskImage = getImageID();
	setAutoThreshold("Intermodes dark");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Invert");
	cleanUpSmallObjects();
	
	run("Create Selection");
	run("To Bounding Box");
	getSelectionBounds(x, y, width, height);
	height = height + 50;
	x = x -50;
	width = width +100;
	makeRectangle(x, y, width, height);
	run("Crop");

	findTips();
	
	selectImage(inputImageID);
	
	makeRectangle(x,y,width,height);
	run("Crop");
	
	traceMainRoots();
	
	smoothTracings();
	
	selectImage(maskImage);
	boxStartIndex = roiManager("count");
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity add");
	boxEndIndex = roiManager("count");

	nrOfRoots = boxEndIndex-boxStartIndex;
	xCoordinates = newArray(nrOfRoots);

	counter = 0;
	for(i=boxStartIndex; i<boxEndIndex; i++) {
		roiManager("select", i);
		setKeyDown("shift");
		run("To Bounding Box");
		getSelectionBounds(x,y,w,h);
		xCoordinates[counter] = x;
		counter++;
		setKeyDown("none");
		roiManager("Update");
	}

	rranks = Array.rankPositions(xCoordinates);	
	ranks = Array.rankPositions(rranks);	
	totalArea = 0;
	measurements = newArray(nrOfRoots);
	boundsX = newArray(nrOfRoots);
	boundsY = newArray(nrOfRoots);
	for (i=0; i<nrOfRoots; i++) {
		rootNR = IJ.pad((ranks[i]+1), 2);
		measurements[rootNR-1] = "";
		leftIndex = (3 * i) + 1;
		rightIndex = (3 * i) + 2;
		boxIndex = boxStartIndex + i;
		// measure total area 
		roiManager("select", boxIndex);
		roiManager("Rename", rootNR + "-bounds");
		getSelectionBounds(x, y, width, height);
		boundsX[rootNR-1] = x;
		boundsY[rootNR-1] = y;
		run("Duplicate...", " ");
		run("Create Selection");
		run("Measure");
		close();
		totalArea = getResult("Area", nResults-1);
		// measure main root area and length and number of 2. order roots
		roiManager("select", leftIndex);
		getSelectionCoordinates(xpoints1, ypoints1);
		roiManager("select", rightIndex);
		getSelectionCoordinates(xpoints2, ypoints2);
		roiManager("select", 3* i);
		run("Measure");
		length = getResult("Length", nResults-1);
		makeAreaSelection(xpoints1, ypoints1, xpoints2, ypoints2);
		roiManager("add");
		count = roiManager("Count");
		roiManager("Select", count-1);
		roiManager("Rename", rootNR + "-main-border");
		roiManager("Set Color", _MAIN_BORDER_COLOR);
		run("Measure");
		area = getResult("Area", nResults - 1); 
		run("Enlarge...", "enlarge="+_ENLARGE_MAIN_ROOT_SELECTION1);
		run("Clear", "slice");
		run("Enlarge...", "enlarge=20");
		countBefore = roiManager("count");
		run("Analyze Particles...", "size="+_MIN_OBJECT_SIZE+"-Infinity show=Overlay add");
		countAfter = roiManager("count");
		nrOfSecondOrderRoots = countAfter-countBefore;
		for (c = countBefore; c<countAfter; c++) {
			secRootNR = IJ.pad((c+1-countBefore), 2);
			roiManager("select", c);
			roiManager("Rename", rootNR + "-sec-root-" + secRootNR);
			roiManager("Set Color", _SEC_ROOT_COLOR);
		}
		run("Select None");
		roiManager("select", boxIndex);
		run("Duplicate...", " "); 
		run("Skeletonize");
		totalLength = measureSkeletonLength() + _ENLARGE_MAIN_ROOT_SELECTION1 + length;
		run("Create Selection");
		close();
		run("Restore Selection");
		getSelectionBounds(xt, yt, wt, ht);
		setSelectionLocation(x+xt, y+yt);
		roiManager("add");
		last = roiManager("count") - 1;
		roiManager("Select", last);
		roiManager("Rename", rootNR + "-skeletons");
		roiManager("Set Color", _SKELETON_COLOR);
		run("Select None");
		measurements[rootNR-1] = "" + length + "\t" + area +"\t" + nrOfSecondOrderRoots + "\t" + totalArea + "\t" + totalLength + "\t" + inputTitle; 
	}
	close();
	
	// remove left and right border selections
	for(i=0; i<nrOfRoots; i++) {
		roiManager("Select", i+1);
		roiManager("Delete");
		roiManager("Select", i+1);
		roiManager("Delete");
	}
	
	for(i=0; i<nrOfRoots; i++) {
		rootNR = IJ.pad((ranks[i]+1), 2);
		roiManager("Select", i);
		roiManager("Rename", rootNR + "-main-center");
		roiManager("Set Color", _MAIN_CENTER_COLOR);
	}
	run("Select None");
	
	roiManager("Sort");
	
	// Reorder rois and measurements from left to right instead top/left to bottom/right

	reportResults(measurements);
	
	roiManager("Show All without labels");
	run("From ROI Manager");
	roiManager("Delete");
	
	setFont("SansSerif" ,72 , "bold");
	for (i=0; i<nrOfRoots; i++) {
		Overlay.drawString(""+(i+1), boundsX[i]+5, boundsY[i]+72);
	}
}

function cleanUpSmallObjects() {
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity show=Masks in_situ");
}

function findTips() {
	tipsX = newArray();
	tipsY = newArray();
	roiManager("Reset");
	run("Analyze Particles...", "size=6000-Infinity add");
	count = roiManager("count");
	for(i=0; i<count; i++) {
		roiManager("select", i);
		getSelectionBounds(x, y, width, height);
		lowestY = y + (height-1);
		xStart = -1;
		xEnd = -1;
		lastValue=0;
		for (j=x; j<x+width; j++) {
			currentValue = getPixel(j, lowestY);
			if (lastValue==0 && currentValue==255) xStart = j;
			if (lastValue==255 && currentValue==0) xEnd = (j-1);
			tmpValue = currentValue;
			currentValue = lastValue;
			lastValue = tmpValue;
		}
		if (xEnd==-1 && lastValue==255) xEnd = x+width-1; 
		tipX = round(xStart + ((xEnd - xStart) / 2));
		tipY = lowestY;
		tipsX = Array.concat(tipsX, tipX);
		tipsY = Array.concat(tipsY, tipY);
	}
	roiManager("Reset");
	for(i=0; i<tipsX.length; i++) {
		tipX = tipsX[i];
		tipY = tipsY[i];
		makePoint(tipX, tipY);
		roiManager("add");
	}
	run("Select None");
}

function traceMainRoots() {
	run("Invert");
	run("Median...", "radius=" + _MEDIAN_FILTER_RADIUS);
	count = roiManager("count");
	for(i=0; i<count; i++) {
		roiManager("select", i);
		type = selectionType();
		if (type==10) {
			getSelectionCoordinates(xpoints, ypoints);
			tipX = xpoints[0];
			tipY = ypoints[0];
			call("tracing.FilamentTracer.traceFrom", toString(tipX), toString(tipY-_TIP_DISTANCE),  toString(_MAX_ROOT_WIDTH), toString(_MIN_ROOT_LENGTH), toString(_STEP_WIDTH));
		}
	}
	run("Select None");
	for (i=0; i<count; i++) {
		roiManager("select", 0);
		roiManager("Delete");
	}
}

function smoothTracings() {
	count = roiManager("count");
	for(i=0; i<count; i++) {
		roiManager("select", i);
		run("Interpolate", "interval=1 smooth adjust");
		roiManager("Update");
		roiManager("Deselect");
	}
}

function makeAreaSelection(x1, y1, x2, y2) {
	  Array.reverse(x2);
	  Array.reverse(y2);
	  xPoints = Array.concat(x1, x2);
	  yPoints = Array.concat(y1, y2);
	  makeSelection("Freehand", xPoints, yPoints);
}

function reportResults(measurements) {
     for(i=0; i<measurements.length; i++) {
			print(_REPORT_HANDLE, (i+1) + "\t" + measurements[i]);
	 }
}

function measureSkeletonLength() {
    var sqrtOfTwo = sqrt(2);
    var x,y, result;
    result = 0;
    var value,ul,um,ur,l,r,ll,lm,lr;
    var straightCounter, diagonalCounter;
    straightCounter = 0;
    diagonalCounter = 0;

    for (x=0; x<getWidth(); x++) {
    	for (y=0; y<getHeight(); y++) {
        	value = getPixel(x,y);
		if (value>0) {
			ul = getPixel(x-1, y-1);
			um = getPixel(x, y-1);
			ur = getPixel(x+1, y-1);
			l = getPixel(x-1, y);
			r = getPixel(x+1, y);
			ll = getPixel(x-1, y+1);
			lm = getPixel(x, y+1);
			lr = getPixel(x+1, y+1);
		        if (um>0) straightCounter++; 
		        if (l>0) straightCounter++;
		        if (r>0) straightCounter++;
			if (lm>0) straightCounter++;
			if (ul>0 && l==0 && um==0) diagonalCounter++;
			if (ur>0 && r==0 && um==0) diagonalCounter++;
			if (ll>0 && l==0 && lm==0) diagonalCounter++;
			if (lr>0 && r==0 && lm==0) diagonalCounter++;
            	}
       }
    }
    straightCounter = straightCounter / 2.0;
    diagonalCounter = diagonalCounter / 2.0;
    result = straightCounter + (diagonalCounter * sqrtOfTwo);
    getPixelSize(unit, pw, ph, pd);
    result = result * pw;
    return result;
}


