var _DEAD_CELLS_CHANNEL = 1;
var _DEAD_CELLS_THRESHOLDING_METHOD = "Triangle";
var _COCHLEA_CHANNEL = 2;
var _COCHLEA_THRESHOLDING_METHOD = "Li";
var _INTERPOLATION_LENGTH = 20;

getSelectionBounds(xOffset, yOffset, width, height);
run("Set Measurements...", "area stack display redirect=None decimal=9");
getStatistics(totalArea);
inputImageID = getImageID();
areasDeadCells = measureAreasOfDeadCells(xOffset, yOffset);
selectImage(inputImageID);
areasOfCochlea = measureAreaOfChochlea();
lengthsOfChochlea = measureLengthOfCochlea();
areasOfDeadCellsInCochlea = measureDeasCellsAreaInCochlea();

tableTitle = "cochlea results";
Table.create(tableTitle);
Table.showRowIndexes(true, tableTitle);
Table.set("total area", 0, totalArea, tableTitle);
Table.setColumn("rel. area dead cells", areasDeadCells, tableTitle);
Table.setColumn("rel. area cochlea", areasOfCochlea, tableTitle);
Table.setColumn("rel. area dead cells in cochlea", areasOfDeadCellsInCochlea, tableTitle);
Table.setColumn("length of cochlea", lengthsOfChochlea, tableTitle);

function measureDeasCellsAreaInCochlea() {
	getStatistics(totalArea);
	imageID = getImageID();
	imageCalculator("AND create stack", "dead_cells","cochlea");
	areas = newArray(nSlices);
	for (i = 1; i <= nSlices; i++) {
		Stack.setFrame(i);
		setThreshold(1, 255);
		run("Create Selection");
		getStatistics(area);
		run("Select None");
		areas[i-1] = area / totalArea;
	}
	selectImage(imageID);
	return areas;
}

function measureLengthOfCochlea() {	
	imageID = getImageID();
	run("Duplicate...", "duplicate");
	title = getTitle();
	roiManager("reset");
	run("Clear Results");
	run("Skeletonize", "stack");
	for (i = 1; i <= nSlices; i++) {
		Stack.setFrame(i);
		run("Geodesic Diameter", "label="+title+" distances=[Chessknight (5,7,11)] export");
		roiManager("Select", i-1);
		run("Interpolate", "interval="+_INTERPOLATION_LENGTH+" smooth ");
		run("Interpolate", "interval=1 smooth adjust");
		roiManager("Update");
		run("Select None");
	}
	Stack.setFrame(1);
	roiManager("measure");
	lengths = Table.getColumn("Length", "Results");
	close();
	selectImage(imageID);
	return lengths;
}

function measureAreaOfChochlea() {
	getStatistics(totalArea);
	extractCochlea();
	imageID = getImageID();
	areas = newArray(nSlices);
	for (i = 1; i <= nSlices; i++) {
		Stack.setFrame(i);
		setThreshold(1, 255);
		run("Create Selection");
		getStatistics(area);
		run("Select None");
		areas[i-1] = area / totalArea;
	}
	selectImage(imageID);
	return areas;
}


function extractCochlea() {
	resetMinAndMax();
	run("Duplicate...", "duplicate channels="+_COCHLEA_CHANNEL+"-"+_COCHLEA_CHANNEL);
	resetMinAndMax();
	setAutoThreshold(_COCHLEA_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask", "method=Li background=Dark calculate");
	run("Fill Holes", "stack");
	for (i = 1; i <= nSlices; i++) {
		Stack.setFrame(i);
		run("Analyze Particles...", "size=0-Infinity display clear add slice");
		areas = Table.getColumn("Area", "Results");
		ranks = Array.rankPositions(areas);
		indexOfBiggest = ranks[ranks.length - 1];
		roiManager("select", indexOfBiggest);
		run("Clear Outside", "slice");
		roiManager("reset");
		run("Select None");
	}
	Stack.setFrame(1);
	rename("cochlea");
}

function measureAreasOfDeadCells(xOffset, yOffset) {
	getStatistics(totalArea);
	inputImageID = getImageID();
	setBatchMode(true);
	run("Duplicate...", "duplicate channels="+_DEAD_CELLS_CHANNEL+"-"+_DEAD_CELLS_CHANNEL);
	run("Convert to Mask", "method="+_DEAD_CELLS_THRESHOLDING_METHOD+" background=Dark calculate");
	areas = newArray(nSlices);
	for (i = 1; i <= nSlices; i++) {
		Stack.setFrame(i);
		setThreshold(1, 255);
		run("Create Selection");
		getStatistics(area);
		run("Select None");
		areas[i-1] = area / totalArea;
	}
	rename("dead_cells");
	setBatchMode(false);
	return areas;
}
