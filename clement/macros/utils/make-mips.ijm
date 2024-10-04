// Folder in which original images are located
_INPUT_DIRECTORY = "/home/benedetti/Documents/projects/coralie-co-occurance/transfer_8066882_files_8c192037/inputs/";
// Folder in which MIP will be exported.
_MIP_DIRECTORY = "/home/benedetti/Documents/projects/coralie-co-occurance/transfer_8066882_files_8c192037/mip/";
// Index of the nuclei channel in the original image.
_NUCLEI_CHANNEL = 3;
// Extension of input images
_EXTENSION = ".czi";

function make_mip(full_path, export_path) {
	run("Bio-Formats", "open=" + full_path + " autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	run("Duplicate...", "duplicate channels=" + _NUCLEI_CHANNEL + "-" + _NUCLEI_CHANNEL);
	run("Z Project...", "projection=[Max Intensity]");
	saveAs("Tiff", export_path);
	close();
	close();
}

function main() {
	run("Close All");
	setBatchMode("hide");
	content = getFileList(_INPUT_DIRECTORY);
	for (i = 0 ; i < lengthOf(content) ; i++) {
		current = content[i];
		if (!endsWith(current, _EXTENSION)) { continue; }
		full_path = _INPUT_DIRECTORY + current;
		new_name = replace(current, _EXTENSION, ".tif");
		export_path = _MIP_DIRECTORY + new_name;
		print("Working on: " + current);
		make_mip(full_path, export_path);
		close();
	}
	setBatchMode("exit and display");
	print("DONE.");
}


main();