// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
// #                             MACRO SETTINGS                                          #
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
// 
// Macro aiming to count cells stained in GFP from a Boyden chamber in which pores are stained as well.
// Clément Benedetti, MRI-CIA, CNRS
// #2056


var _MODE = 1; // 0: Works on the currently opened image.
               // 1: Works on the content of the folder provided below.

// Path of the folder containing images.
// Make sure that it ends with a separator.
// On Windows, replace the '\' by '/'.
var _IMAGES_PATH = "/home/benedetti/Desktop/boyden-images/transfer_7975367_files_9d18123a/"; 

// Extension must include the dot (".tif" and not "tif")
var _EXTENSION   = ".tiff"; 

// Gamma coef: Gamma applied to make intensities more uniform
var _GAMMA = 0.10;

// Determines the frequencies conserved within the image. Higher it is, bigger the conserved objects are.
var _GAUSSIAN_RADIUS = 3.0;

// Lower bound: minimal intensity to reach before we consider that we have a peak.
var _MIN_VALUE = 210;

// How big the bump of intensity must be compared to its local environment. 
var _PROMINENCE = 0.05;

var _TABLE_NAME = "Cells count";

// --------------------------------------

if (_MODE == 0) {
	content = newArray(toString(getImageID()));
}
else {
	content = getFileList(_IMAGES_PATH);
}

roiManager("reset");
Table.create(_TABLE_NAME);
index = 0;

for (i = 0 ; i < lengthOf(content) ; i++) {
	current = content[i];
	if (_MODE == 0) {
		img = parseInt(current);
		selectImage(img);
	}
	else {
		if (!endsWith(current, _EXTENSION)) { continue; }
		full_path = _IMAGES_PATH + current;
		if (File.isDirectory(full_path)) { continue; }
		open(full_path);
	}
	print("Working on: " + getTitle());
	
	run("Gamma...", "value=" + _GAMMA);
	run("Gaussian Blur...", "sigma=" + _GAUSSIAN_RADIUS);
	run("Min...", "value=" + _MIN_VALUE);
	run("Find Maxima...", "prominence=" + _PROMINENCE + " output=[Point Selection]");
	roiManager("add");
	
	Table.set("source", index, getTitle(), _TABLE_NAME);
	Table.set("# cells", index, Roi.size, _TABLE_NAME);
	Table.update(_TABLE_NAME);
	index += 1;
	
	if (_MODE == 1) {
		output_path = full_path.replace(_EXTENSION, ".zip");
		roiManager("deselect");
		roiManager("save", output_path);
		run("Close All");
	}
	
	roiManager("reset");
}