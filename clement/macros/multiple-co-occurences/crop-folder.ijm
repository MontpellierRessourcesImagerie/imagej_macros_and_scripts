var input_path    = "/home/clement/Downloads/2025-09-18-help-nelly/images-pour-classifiers/F2-GFP_VLP_Mxra8-halo";
var clear_outside = true;
var extension     = ".tiff";
var output_folder = "";

// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function join(a, b) {
	if (endsWith(a, File.separator)) { return a + b; }
	return a + File.separator + b;
}

function ask_crop() {
	t = getTitle();
	waitForUser("Navigate to the first slice to keep");
	Stack.getPosition(channel, first, frame);
	waitForUser("Navigate to the last slice to keep");
	Stack.getPosition(channel, last, frame);
	run("Duplicate...", "duplicate slices="+first+"-"+last);
	if (clear_outside) {
		run("Clear Outside", "stack");
	}
	output_path = join(output_folder, t);
	run("Select None");
	saveAs("TIFF", output_path);
}

// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

output_folder = join(input_path, "crops");
if (!File.isDirectory(output_folder)) {
	File.makeDirectory(output_folder);
}

images_pool = getFileList(input_path);
for (i = 0 ; i < images_pool.length ; ++i) {
	image_name = images_pool[i];
	if (!endsWith(image_name, extension)) { continue; }
	image_path = join(input_path, image_name);
	open(image_path);
	ask_crop();
	run("Close All");
}
