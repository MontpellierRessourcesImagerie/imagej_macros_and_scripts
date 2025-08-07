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

labels_path = join(images_folder, "labeled-2d");
images_pool = getFileList(images_folder);

run("Close All");
run("Collect Garbage");

for (i = 0 ; i < images_pool.length ; ++i) {
	image_name = images_pool[i];

	// Skip files that don't have the correct extension.
	if (!endsWith(image_name, extension)) { continue; }
	IJ.log("[" + (i+1) + "∕" + images_pool.length + "] Processing: " + image_name);
	raw_name = replace(image_name, extension, "");

	// Open an image
	full_path  = join(images_folder, image_name);
	run("Bio-Formats", "open=[" + full_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	original = getImageID();

	// Open CellPose's labels
	cp_name = raw_name + ".tif";
	cp_path = join(labels_path, cp_name);
	roiManager("reset");
	open(cp_path);
	run("Label Map to ROIs", "connectivity=C4 vertex_location=Corners name_pattern=r%03d");
	close();

	waitForUser("Check masks", "Are labels correct?\n    [OK]: Yes\n    [Alt]+[OK]: No");

	if (!isKeyDown("alt")) { 
		run("Close All");
		continue;
	}

	roiManager("reset");
	waitForUser("Redraw", "Draw a new polygon and press [OK].");

	Roi.copy();
	getDimensions(width, height, channels, slices, frames);
	newImage("fixed", "16-bit black", width, height, 1);
	Roi.paste();
	setColor(1, 1, 1);
	fill();
	run("Select None");

	// Open the segmented nuclei
	nuclei_name = "nuclei-" + raw_name + ".tif";
	nuclei_path = join(labels_path, nuclei_name);
	open(nuclei_path);
	rename("nuclei");

	// Remove nuclei
	imageCalculator("Multiply create", "fixed","nuclei");

	// Save the results
	saveAs("TIFF", cp_path);
	run("Close All");
}