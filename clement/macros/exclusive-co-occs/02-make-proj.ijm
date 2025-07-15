// Settings :
input_folder = "/home/benedetti/Downloads/2025-04-16-celia_chamontin/transfer_9591250_files_e96af054";
extension    = ".czi"
membranes_c  = 4;
nuclei_c     = 2;

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

// Checking that the extension starts with a '.'
if (!startsWith(extension, ".")) {
	extension = "." + extension;
}

// The output folder is named "mips" and is located in the inputs folder
output_folder = join(input_folder, "mips");
if (!File.isDirectory(output_folder)) {
	File.makeDirectory(output_folder);
}

images_pool   = getFileList(input_folder);

run("Close All");
run("Collect Garbage");
setBatchMode(true);

for (i = 0 ; i < lengthOf(images_pool) ; i++) {
	image_name = images_pool[i];

	// Skip files that don't have the correct extension.
	if (!endsWith(image_name, extension)) { continue; }
	IJ.log("[" + (i+1) + "∕" + images_pool.length + "] Processing: " + image_name);
	raw_name = replace(image_name, extension, "");

	// Open an image
	full_path  = join(input_folder, image_name);
	run("Bio-Formats", "open=[" + full_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	original = getImageID();
	
	// Extracting membranes channel
	selectImage(original);
	run("Duplicate...", "title=membranes duplicate channels=" + membranes_c + "-" + membranes_c + " frames=1-1");
	run("Z Project...", "projection=[Max Intensity]");
	rename("membranes-max");
	
	// Extracting nuclei channel
	selectImage(original);
	run("Duplicate...", "title=nuclei duplicate channels=" + nuclei_c + "-" + nuclei_c + " frames=1-1");
	run("Z Project...", "projection=[Max Intensity]");
	rename("nuclei-max");
	
	// Make a composite out this two channels
	run("Merge Channels...", "c1=membranes-max c2=nuclei-max create");

	// Write the result to the disk
	output_name = raw_name + ".tif";
	output_path = join(output_folder, output_name);
	saveAs("TIFF", output_path);
	
	run("Close All");
	run("Collect Garbage");
}

setBatchMode(false);
IJ.log("DONE.");