
// Macro settings:

var _IMAGES_PATH = "/home/benedetti/Desktop/test-pores/"; // Make sure that it ends with a separator
var _EXTENSION   = ".tif";

// Determines the frequencies conserved within the image. Higher it is, bigger the conserved objects are.
var _LOG_RADIUS = 3.5;

// How big a bump from the LoG filter must be to be conserved (height of the peak)
// To be adjusted depending on the amount of noise.
var _PROMINENCE = 2.0;

var _TABLE_NAME = "Cells count";

// --------------------------------------

content = getFileList(_IMAGES_PATH);
Table.create(_TABLE_NAME);
index = 0;

for (i = 0 ; i < lengthOf(content) ; i++) {
	current = content[i];
	if (!endsWith(current, _EXTENSION)) { continue; }
	full_path = _IMAGES_PATH + current;
	if (File.isDirectory(full_path)) { continue; }
	print("Working on: " + current);
	open(full_path);
	
	run("FeatureJ Laplacian", "compute smoothing=" + _LOG_RADIUS);
	run("Multiply...", "value=-1.0000");
	run("Find Maxima...", "prominence=" + _PROMINENCE + " output=[Point Selection]");
	run("Measure");
	
	Table.set("source", index, current, _TABLE_NAME);
	Table.set("# cells", index, nResults, _TABLE_NAME);
	Table.update(_TABLE_NAME);
	index += 1;
	
	close("Results");
	run("Close All");
}