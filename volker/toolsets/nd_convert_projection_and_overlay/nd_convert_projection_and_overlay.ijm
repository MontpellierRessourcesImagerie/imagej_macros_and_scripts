/*
 * INPUT:
 * Channles to use:
 * 	TIRF-561, TIRF-488
 * Each file has 5 z-slices.
 * Different stage positions, each s one image
 * 21 time frames
 * 
 * OUTPUT save:
 * Parameter: rolling ball radius per channel, min/max display values per channel
 * For each stage in the folder:
 * 	mip projection of z 
 * 	Concatenate all time points
 * 	Subtract background for each channel independantly
 * 	and overlay of channels
 */
/*
 * Macro template to process multiple images in a folder
 */

var _OUTPUT = "movies";
var _ SUFFIX = ".nd";

inDir = getDirectory("Choose a Directory");
processFolder(inDir, _OUTPUT, _SUFFIX);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, output, suffix) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output, suffix);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	out = input + File.separator + output;
	print("Saving to: " + out);
}

// run("Bio-Formats Importer", "open=/media/baecker/UNTITLED/638_Cin8_tdEos/slx_cin8_td.nd autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_3");
