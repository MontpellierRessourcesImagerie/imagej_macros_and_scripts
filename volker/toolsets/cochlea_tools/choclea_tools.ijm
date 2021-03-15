var _DEAD_CELLS_CHANNEL = 1;
var _DEAD_CELLS_THRESHOLDING_METHOD = "Triangle";
var _COCHLEA_CHANNEL = 2;
var _COCHLEA_THRESHOLDING_METHOD = "Li";

measureAreaOfChochlea();

function measureAreaOfChochlea() {
	getStatistics(totalArea);
	extractCochlea();
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
