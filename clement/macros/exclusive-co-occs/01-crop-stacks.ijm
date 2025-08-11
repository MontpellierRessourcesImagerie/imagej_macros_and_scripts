input_folder = "/home/clement/Downloads/2025-04-16-celia_chamontin/transfer_9591250_files_e96af054";
extension    = ".czi"

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

output_folder = input_folder; // join(input_folder, "cropped");
if (!File.isDirectory(output_folder)) {
	File.makeDirectory(output_folder);
}

run("Close All");
run("Collect Garbage");

images_pool   = getFileList(input_folder);

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

	Stack.getDimensions(width, height, channels, slices, frames);
	first = 1;
	last = slices;

	waitForUser("First slice", "Navigate to the first slice to keep.");
	first = getSliceNumber();

	waitForUser("Last slice", "Navigate to the last slice to keep.");
	last = getSliceNumber();

	run("Duplicate...", "duplicate slices="+first+"-"+last);
	output_path = join(output_folder, raw_name+".tif");
	saveAs("TIFF", output_path);

	run("Close All");
}

print("DONE. No more image to crop.")