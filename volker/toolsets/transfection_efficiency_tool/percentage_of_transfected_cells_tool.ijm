var _MIN_SIZE = 30;
var _THRESHOLD = -1;

var _FIRST_ROI_INDEX = -1;

macro "Detect Nuclei Action Tool (f2) -  C000T4b12d" {
	segmentNuclei();
}

macro "detect nuclei [f2]" {
	segmentNuclei();
}

macro "Merge Tool (f3) - C000T4b12m" {
	merge();
}

macro "merge [f3]" {
	merge();
}

macro "Split Action Tool (f4) - C000T4b12s" {
	split();
}

macro "split [f4]" {
	split();
}

macro "Analyze Action Tool (f5) - C000T4b12a" {
	analyze();	
}

macro "analyze [f5]" {
	analyze();
}

macro "Show below and above Action Tool (f6) - C000T4b12b" {
	belowAndAbove();
}

macro "show below and above [f6]" {
	belowAndAbove();
}

macro "Count transfected cells Action Tool (f7) -  C000T4b12c" {
	countTransfectedCells();
}

macro "count transfected cells [f7]" {
	countTransfectedCells();
}

function countTransfectedCells() {
	title = getTitle();
	totalNumberOfCells = roiManager("count");
	if (_THRESHOLD==-1) {
		nonTransfected = 0;
		for (i = 0; i < totalNumberOfCells; i++) {
			roiManager("select", i);
			if (Roi.getStrokeColor!=Roi.getDefaultColor) {
					nonTransfected++;	
			}
		}
	}
	reportCount(title, totalNumberOfCells, nonTransfected);
}

function reportCount(title, totalNumberOfCells, nonTransfected) {
	if (!isOpen("transfected cells count")) {
		Table.create("transfected cells count");
	}
	size = Table.size;
	transfected =  totalNumberOfCells-nonTransfected;
	percent = (transfected * 100) / totalNumberOfCells;
	Table.set("image", size, title);
	Table.set("total nr. of cells", size, totalNumberOfCells);
	Table.set("nr. of transfected cells", size, transfected);
	Table.set("% of transfected cells", size, percent);
}

function belowAndAbove() {
	count = roiManager("count");
	row = Table.getSelectionStart("Results");
	color = Roi.getDefaultColor;
	if (row==-1) {
		indexes = Array.getSequence(count);
		roiManager("select", indexes);
		roiManager("Set Color", color);
		roiManager("deselect");
		run("Select None");
		return;
	}
	indexes = newArray(0);
	for(i = 0; i<row; i++) {
		indexes = Array.concat(indexes, i);
	}
	roiManager("select", indexes);
	roiManager("Set Color", color);
	roiManager("deselect");
	run("Select None");
	indexes = newArray(0);
	for(i = row; i<count; i++) {
		indexes = Array.concat(indexes, i);
	}
	roiManager("select", indexes);
	roiManager("Set Color", "red");
	roiManager("deselect");
	run("Select None");
	Table.setSelection(row, row);
}

function analyze() {
	run("Set Measurements...", "area mean standard modal min centroid center shape feret's integrated median display redirect=None decimal=9");
	run("Clear Results");
	roiManager("measure");
	sortByColumn("Mean", true);	
}

function split() {
	type = selectionType();
	getSelectionCoordinates(xpoints, ypoints);
	getBoundingRect(x, y, width, height);
	x = x + width/2;
	y = y + height/2;
	roiIndex = getRoiAtCoords(x,y);
	roiManager("select", roiIndex);
	run("Create Mask");
	makeSelection(type, xpoints, ypoints);
	Roi.setStrokeColor(0);
	Roi.setStrokeWidth(3);
	run("Clear", "slice");
	run("Select None");
	run("Analyze Particles...", "size=30-Infinity show=Nothing add");
	close();
	roiManager("select", roiIndex);
	roiManager("delete");
	roiManager("Show None");
	roiManager("Show All")
}
function segmentNuclei() {
	Stack.getPosition(channel, slice, frame);
	run("Duplicate...", "duplicate channels=&channel-&channel");
	run("8-bit");
	setAutoThreshold("Huang dark");
	run("Threshold...");
	waitForUser;
	run("Convert to Mask");
	run("Fill Holes");
	run("Watershed");
	run("Analyze Particles...", "size=&_MIN_SIZE-Infinity show=Masks exclude in_situ");
	run("Analyze Particles...", "size=&_MIN_SIZE-Infinity show=Masks in_situ add");
	close();
	roiManager("Show None");
	roiManager("Show All")
}

function merge() {
	print("Start merge");
	getCursorLoc(x, y, z, modifiers);
	if (_FIRST_ROI_INDEX<0) {
		_FIRST_ROI_INDEX = getRoiAtCoords(x,y);
		if (_FIRST_ROI_INDEX=="" || _FIRST_ROI_INDEX==-1) {
			_FIRST_ROI_INDEX = -1;
			print("no roi at the given coordinates, starting over");
			return;
		}
		roiManager("select", _FIRST_ROI_INDEX);
		roiManager("Set Fill Color", "green");
		roiManager("deselect");
		return;
	} 
	secondRoiIndex = getRoiAtCoords(x,y);
	if (secondRoiIndex=="" || secondRoiIndex==-1) {
		roiManager("select", _FIRST_ROI_INDEX);
		RoiManager.setPosition(0);
		roiManager("Set Color", "yellow");
		roiManager("Set Line Width", 0);
		roiManager("deselect");
		_FIRST_ROI_INDEX = -1;
		print("no roi at the given coordinates, starting over");
		return;
	}
	indexes = newArray(_FIRST_ROI_INDEX, secondRoiIndex);
	roiManager("select", indexes);
	roiManager("Combine");
	setBatchMode(true);
	run("Create Mask");
	roiManager("delete");
	run("Select None");
	run("Options...", "iterations=1 count=1 black do=Dilate");
	run("Options...", "iterations=1 count=1 black do=Erode");
	run("Create Selection");
	type = Roi.getType;
	getSelectionCoordinates(xpoints, ypoints);
	close();
	setBatchMode(false);
	makeSelection(type, xpoints, ypoints);
	roiManager("add");
	run("Select None");
	roiManager("Show None");
	roiManager("Show All");
	updateDisplay();
	_FIRST_ROI_INDEX = -1;
}

function getRoiAtCoords(x,y) {
	Overlay.remove;
	run("From ROI Manager");
	index = Overlay.indexAt(x,y);
	print(index, x, y);
	Overlay.remove;
	roiManager("Show None");
	roiManager("Show All");
	return index;
}

function sortByColumn(column, doReverse) {
	FEATURE = column;
	REVERSE = doReverse;
	column = newArray(nResults);
	for (i=0; i<nResults; i++) {
		column[i] = getResult(FEATURE, i);
	}
	positions = Array.rankPositions(column);
	if (REVERSE) Array.reverse(positions);
	ranks = Array.rankPositions(positions);
	for (i=0; i<roiManager("count"); i++) {
		roiManager("select", i);
		roiManager("Rename", IJ.pad(ranks[i]+1, 4)); 
	}
	roiManager("Deselect");
	roiManager("Sort");
	run("Clear Results");
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Measure");
}
