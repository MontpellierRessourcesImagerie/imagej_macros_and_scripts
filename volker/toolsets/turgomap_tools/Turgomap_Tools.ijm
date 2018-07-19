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

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Turgomap-Tools";

macro "MRI Turgomap Tools Help Action Tool - C000D26D38D3dD44D4bD81D8cDc8Dc9De7De9C777D02D03D0dD0eD11D1aD21D2eD2fD31D41D46D48D4fD56D57D59D5dD62D65D68D6aD75D76D78D80D84D86D8bD8dD90D91D96D99D9bD9fDa0Da6Da7Da8Da9DaaDadDafDb4DbbDbfDcaDcfDd1Dd5DdbDdcDdfDe1De2De4De5DeaDebDedDeeDefDf6DfbDfcDfdDfeDffC555D1bD34D39D3bD4aD51D5bD74D8aD92D93D98D9aDb8C777D06D0aD0bD0cD17D23D47D4eD50D58D5aD5fD60D70Da1DabDacDb1Db6DbaDc1Dd2De3Df5C333D13D19D1cD29D45D54D5cD6cD6dD7eD82D8eDd4De6C666D01D04D0fD10D1dD1eD1fD20D30D3eD3fD40D5eD67D69D6bD6fD79D7aD7bD85D88D89D94D95DaeDb0Db7DbcDbdDbeDc0Dc6DcbDccDcdDceDd0DdaDddDdeDe0DecDf0Df1Df2Df3Df4C888D05D18D24D49D7dDd7DfaC222D14D15D16D25D27D2cD32D37D63Db5Dc7Dd9De8C666D00D12D33D42D55D66D77D7fD8fD97D9cDb9Df9C444D28D2bD53D64D87Da3Da5Dc5C888D3cDb3C111D08D2dD35D61D6eD71D7cDa4Db2Dc3C444D22D36D4dD52D73D9eDa2Df8C333D07D09D3aD43D4cD83D9dDc2Dd3C555D2aDc4Dd6Df7C999D72Dd8" {
	run('URL...', 'url='+helpURL);
}

macro 'Create Grid Action Tool (f1) - C000T4b12g' {
	createGrid();
}

macro "create-grid [f1]" {
	createGrid();
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