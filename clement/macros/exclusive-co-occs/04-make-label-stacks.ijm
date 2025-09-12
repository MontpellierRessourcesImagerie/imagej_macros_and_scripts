// Settings :

images_folder = "/media/clement/5B0AAEC37149070F/debug-celia/CC399-240725-dNC+-PURO/NEW JOINT DECONVOLUTION";
originals_ext = ".czi";
membranes_c   = 4;

// --------------

/**
 * Allows to merge two pieces of a path without worrying about the presence of the separator or not.
 */
function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

/**
 * Turns a single-slice image into a 3D stack by copying the given image N times.
 * 
 * Args:
 *   - target (int): Number of slices that the new stack must have
 *   - flat (image id): ID of the 2D image to be replicated
 */
function make_stack(flat, target) {
	selectImage(flat);
	run("Label Morphological Filters", "operation=Dilation radius=6 from_any_label");
	run("Copy");
	close(flat);
	stk = getImageID();
	
	for (i = 0 ; i < target-1 ; ++i) {
		run("Add Slice");
	}
	
	for (i = 2 ; i <= target ; ++i) {
		setSlice(i);
		run("Paste");
	}
	run("Select None");
	rename("lbls3d");
	return stk
}

function membranes_to_mask(image_id) {
	selectImage(image_id);
	run("Duplicate...", "title=membranes duplicate channels=" + membranes_c + "-" + membranes_c + " frames=1-1");
	close(image_id);
	image_id = getImageID();
	run("Median 3D...", "x=4 y=4 z=4");
	close(image_id);
	run("Log", "stack");
	setAutoThreshold("Otsu dark stack no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask", "method=Otsu background=Dark black");
	rename("mask3d");
	return getImageID();
}

/**
 * Fills the holes in every label in a stack by convexifying it on each slice independently.
 * A good membrane staining is required to do so, but it's the only required thing.
 */
function fix_labels(image_id) {
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	n_labels = max;
	if (n_labels == 0) { return; }
	Stack.getDimensions(width, height, channels, slices, frames);

	for (sl = 1 ; sl <= slices ; ++sl) {
		Stack.setSlice(sl);
		for (lbl = 1 ; lbl <= n_labels ; ++lbl) {
			resetThreshold();
			print(lbl);
			setThreshold(lbl, lbl, "raw");
			run("Create Selection");
			if (Roi.size == 0) { continue; }
			Color.set(lbl);
			run("Convex Hull");
			fill();
			run("Select None");
		}
	}
}

// Check that the folder containing 2D label maps exists
labels_folder = join(images_folder, "labeled-2d");
if (!File.isDirectory(labels_folder)) {
	exit("The labels folder folder doesn't exist.");
}

// The output folder is named "mips" and is located in the inputs folder
output_folder = join(images_folder, "labeled-stacks");
if (!File.isDirectory(output_folder)) {
	File.makeDirectory(output_folder);
}

labels_pool   = getFileList(labels_folder);

run("Close All");
run("Collect Garbage");
setBatchMode(true);

for (i = 0 ; i < lengthOf(labels_pool) ; ++i) {
	labels_name   = labels_pool[i];
	original_name = replace(labels_name, ".tif", originals_ext);
	labels_path   = join(labels_folder, labels_name);
	image_path    = join(images_folder, original_name);
	print(image_path);
	
	IJ.log("[" + (i+1) + "/" + labels_pool.length + "] Processing: " + labels_name);
	
	// Check that labels exist
	if (!File.exists(labels_path)) {
		IJ.log("Couldn't find labels " + labels_name);
		continue;
	}
	// Check that the corresponding image exists
	if (!File.exists(image_path)) {
		IJ.log("Couldn't find image " + original_name);
		continue;
	}
	
	// Extracting a binary mask of cells in 3D
	run("Bio-Formats", "open=[" + image_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	ori_img = getImageID();
	getVoxelSize(pw, ph, pd, unit);
	// cells_mask = membranes_to_mask(ori_img);
	getDimensions(width, height, channels, slices, frames);
	
	// Transforming 2D labels in 3D labels
	run("Bio-Formats", "open=[" + labels_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	lbls2d = getImageID();
	lbls3d = make_stack(lbls2d, slices);
	
	// Merging the mask with the labels
	// imageCalculator("AND create stack", "lbls3d", "mask3d");
	// rename("labels-merged");
	// merged_stack = getImageID();
	setVoxelSize(pw, ph, pd, unit);
	run("Remap Labels");

	// Fix the labels
	// fix_labels(merged_stack);

	// Save the result
	output_path = join(output_folder, labels_name);
	saveAs("TIFF", output_path);

	run("Analyze Regions 3D", "volume surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
	table_name = replace(labels_name, ".tif", ".csv");
	table_path = join(output_folder, table_name);
	saveAs("Results", table_path);
	close(table_name);
	
	run("Close All");
	run("Collect Garbage");
}

IJ.log("DONE.");
setBatchMode(false);

