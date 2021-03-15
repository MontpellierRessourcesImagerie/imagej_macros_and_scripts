var _COCHLEA_CHANNEL = 2;
var _COCHLEA_THRESHOLDING_METHOD = "Li";

run("Set Measurements...", "area stack display redirect=None decimal=3");
resetMinAndMax();
run("Duplicate...", "duplicate channels="+_COCHLEA_CHANNEL+"-"+_COCHLEA_CHANNEL);
resetMinAndMax();

setAutoThreshold(_COCHLEA_THRESHOLDING_METHOD + " dark");
// getThreshold(lower, upper);
//run("Macro...", "code=v=255*(v>"+lower+") stack");
run("Convert to Mask", "method=Li background=Dark calculate");
//resetMinAndMax();

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
