var _MIN_SIZE = 30;
var _THRESHOLDING_METHOD = "Huang";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _THRESHOLD = -1;

var _FIRST_ROI_INDEX = -1;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Transfection_Efficiency_Tool";

macro "Transfection Efficiency Action Tool (f4) - C220L0050C232D60C253D70C254L80b0C232Dc0C220Ld0f0L0111C221D21C232L3141C221L5161C232L71b1C220Lc1f1C232D02C224L1252C232D62C221D72C220L82a2C221Lb2c2C220Ld2f2C224L0323C254L3343C224L5363C232D73C231D83C232D93C253Da3C254Lb3c3C253Dd3C231De3C220Df3C232D04C224L1454C232D64C221D74C232D84C254D94C286La4d4C242De4C220Df4C221L0555C220D65C231D75C253D85C286L95d5C242De5C220Df5C221D06C220L1636C231D46C220L5666C231D76C253D86C286L96c6C273Dd6C232De6C220Df6C253D07C221D17C231D27C232D37C273D47C242D57C231L6777C232D87C254D97C286La7b7C273Dc7C232Dd7C220Le7f7C254D08C242L1828C2f4L3868C242D78C231D88C232L98c8C231Ld8f8C253D09C242D19C2f4D29C2f6L3959C2f4L6979C232D89C231D99C230La9b9C232Dc9C253Ld9f9C242L0a1aC2f4D2aC2f6L3a5aC2f4L6a7aC273D8aC231D9aC230DaaC231DbaC253DcaC273LdafaC221D0bC242D1bC2f4D2bC2f6L3b5bC2f4L6b7bC273D8bC230L9babC231DbbC253DcbC254DdbC273DebC254DfbC231D0cC232D1cC2f4D2cC2f6L3c6cC2f4D7cC242D8cC220D9cC230LacbcC232DccC253LdcecC254DfcC231L0d1dC273D2dC2f4L3d4dC2f6D5dC2f4D6dC273D7dC230L8dbdC220DcdC231LddedC232DfdC231L0e1eC232D2eC242D3eC273L4e5eC242L6e8eC232D9eC230LaebeC220LcefeC231L0f3fC242D4fC253D5fC273D6fC286D7fC273D8fC253D9fC231DafC230DbfC220Lcfff" {
	run('URL...', 'url='+helpURL);	
}

macro "transfection efficiency tool [f4]" {
	run('URL...', 'url='+helpURL);	
}
macro "Detect Nuclei Action Tool (f5) -  C000T4b12d" {
	segmentNuclei();
}

macro "Detect Nuclei Action Tool (f5) Options" {
	Dialog.create("Detect nuclei options");	
	Dialog.addChoice("auto-thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD);
	Dialog.show();
	_THRESHOLDING_METHOD = Dialog.getChoice();
}

macro "detect nuclei [f5]" {
	segmentNuclei();
}

macro "Merge Tool (f6) - C000T4b12m" {
	merge();
}

macro "merge [f6]" {
	merge();
}

macro "Split Action Tool (f7) - C000T4b12s" {
	split();
}

macro "split [f7]" {
	split();
}

macro "Analyze Action Tool (f8) - C000T4b12a" {
	analyze();	
}

macro "analyze [f8]" {
	analyze();
}

macro "Show below and above Action Tool (f09) - C000T4b12b" {
	belowAndAbove();
}

macro "show below and above [f09]" {
	belowAndAbove();
}

macro "Count transfected cells Action Tool (f11) -  C000T4b12c" {
	countTransfectedCells();
}

macro "count transfected cells [f11]" {
	countTransfectedCells();
}

macro "Count transfected cells Action Tool (f11) Options" {
	Dialog.create("count transfected cells options");		
	Dialog.addNumber("threshold: ", _THRESHOLD);
	Dialog.addToSameRow();
	Dialog.addMessage("Enter the threshold value. If the value is -1,\nthe color of the rois is used to count the transfected cells.");
	Dialog.show();
	_THRESHOLD = Dialog.getNumber();
}

function countTransfectedCells() {
	title = getTitle();
	totalNumberOfCells = roiManager("count");
	nonTransfected = 0;
	setBatchMode(true);
	if (_THRESHOLD==-1) {
		belowAndAbove();
		row = Table.getSelectionStart("Results");
		threshold = getResult("Mean", row, "Results");
		for (i = 0; i < totalNumberOfCells; i++) {
			roiManager("select", i);
			if (Roi.getStrokeColor!=Roi.getDefaultColor) {
					nonTransfected++;	
			}
		}
		run("Select None");
		Table.setSelection(row, row, "Results");
	} else {
		threshold = _THRESHOLD;
		color = Roi.getDefaultColor;
		indexesNonTransfected = newArray(0);
		indexesTransfected = newArray(0);
		for (i = 0; i < nResults; i++) {
			v = getResult("Mean", i);
			if (v<=_THRESHOLD) {
				nonTransfected++;
				indexesNonTransfected = Array.concat(indexesNonTransfected, i);
			} else {
				indexesTransfected = Array.concat(indexesTransfected, i);
			}
		}
		roiManager("select", indexesNonTransfected);
		roiManager("Set Color", "red");
		roiManager("deselect");
		run("Select None");
		roiManager("select", indexesTransfected);
		roiManager("Set Color", color);
		roiManager("deselect");
		run("Select None");
		Table.setSelection(-1, -1, "Results");
	}
	setBatchMode(false);
	reportCount(title, totalNumberOfCells, nonTransfected, threshold);
}

function reportCount(title, totalNumberOfCells, nonTransfected, threshold) {
	if (!isOpen("transfected cells count")) {
		Table.create("transfected cells count");
	}
	size = Table.size("transfected cells count");
	transfected =  totalNumberOfCells-nonTransfected;
	percent = (transfected * 100) / totalNumberOfCells;
	Table.set("image", size, title, "transfected cells count");
	Table.set("total nr. of cells", size, totalNumberOfCells, "transfected cells count");
	Table.set("nr. of transfected cells", size, transfected, "transfected cells count");
	Table.set("% of transfected cells", size, percent, "transfected cells count");
	Table.set("threshold", size, threshold, "transfected cells count");
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
	roiManager("reset");
	Stack.getPosition(channel, slice, frame);
	run("Duplicate...", "duplicate channels=&channel-&channel");
	run("8-bit");
	setAutoThreshold("&_THRESHOLDING_METHOD dark");
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
