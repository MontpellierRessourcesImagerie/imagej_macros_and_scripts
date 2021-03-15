var _DEAD_CELLS_CHANNEL = 1;
var _DEAD_CELLS_THRESHOLDING_METHOD = "Triangle";
var _COCHLEA_CHANNEL = 2;
var _COCHLEA_THRESHOLDING_METHOD = "Li";
var _INTERPOLATION_LENGTH = 20;

measureAreaOfChochlea();
measureLengthOfCochlea();
close();
function measureLengthOfCochlea() {	
	title = getTitle();
	imageID = getImageID();
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
	Plot.create("Length cochlea", "X-axis Label", "Y-axis Label", lengths);
	Plot.show();
	selectImage(imageID);
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
	Plot.create("Area cochlea", "X-axis Label", "Y-axis Label", areas);
	Plot.show();	
	selectImage(imageID);
}


function extractCochlea() {
	run("Set Measurements...", "area stack display redirect=None decimal=3");
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
}

function measureAreasOfDeadCells() {
	getStatistics(totalArea);
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
	Plot.create("Dead cells", "X-axis Label", "Y-axis Label", areas);
	Plot.show();
}
