images_folder = "/home/clement/Downloads/2025-04-16-celia_chamontin/transfer_9591250_files_e96af054";
extension = ".czi";

// --------------------------

/**
 * Allows to merge two pieces of a path without worrying about the presence of the separator or not.
 */
function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

function should_redraw(labels_path, inv, whatisit) {
	open(labels_path);
	if (inv) { run("Invert"); }
	roiManager("reset");
	run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=r%03d");
	close();

	waitForUser(
		"Check " + whatisit, 
		"Are " + whatisit + " correct?\n    [OK]: Yes\n    [Shift]+[OK]: No"
	);

	if (!isKeyDown("shift")) { 
		return false;
	}

	roiManager("reset");
	waitForUser("Redraw", "Add new " + whatisit + " to the RoiManager and press [OK]");

	getDimensions(width, height, channels, slices, frames);
	newImage("fixed", "16-bit black", width, height, 1);

	for (j = 0 ; j < roiManager("count") ; ++j) {
		roiManager("select", j);
		setColor(j+1, j+1, j+1);
		fill();
	}
	run("Remap Labels");
	saveAs("TIFF", labels_path);
	close();
	return true;
}

function update_nuclei(nuclei_path) {
	open(nuclei_path);
	setThreshold(1, 65535, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Invert");
	run("Divide...", "value=255");
	saveAs("TIFF", nuclei_path);
	run("Close All");
}

function update_cells(nuclei_path, cells_path) {
	open(nuclei_path);
	rename("nuclei");

	open(cells_path);
	rename("cells");

	imageCalculator("Multiply create", "cells","nuclei");
	saveAs("TIFF", cells_path);
	run("Close All");
}

labels_path = join(images_folder, "labeled-2d");
images_pool = getFileList(images_folder);

run("Close All");
run("Collect Garbage");

for (i = 0 ; i < images_pool.length ; ++i) {
	image_name = images_pool[i];

	// Skip files that don't have the correct extension.
	if (!endsWith(image_name, extension)) { continue; }
	IJ.log("[" + (i+1) + "∕" + images_pool.length + "] Checking: " + image_name);
	raw_name = replace(image_name, extension, "");
	setTool("polygon");

	// Open an image
	full_path  = join(images_folder, image_name);
	run("Bio-Formats", "open=[" + full_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	original = getImageID();

	// Open the nuclei
	nuclei_name = "nuclei-" + raw_name + ".tif";
	nuclei_path = join(labels_path, nuclei_name);
	if (should_redraw(nuclei_path, true, "nuclei")) {
		update_nuclei(nuclei_path);
	}

	// Open CellPose's labels
	cells_name = raw_name + ".tif";
	cells_path = join(labels_path, cells_name);
	if (should_redraw(cells_path, false, "cells")) {
		update_cells(nuclei_path, cells_path);
	}
}