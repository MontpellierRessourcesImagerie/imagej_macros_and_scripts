/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

// See also Process_Folder.py for a version of this code
// in the Python scripting language.

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
	print("Processing: " + input + File.separator + file);
	run("Bio-Formats", "open="+input + File.separator + file+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	newName = File.getNameWithoutExtension(file);
	newName = newName + "-RGB.tif";
	run("Duplicate...", "duplicate");
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	run("RGB Color");
	saveAs("tiff",  output + File.separator + newName);
	close();
	run("Split Channels");
	channelNames = newArray("Red", "Green", "Blue");
	for (i = 0; i < 3; i++) {
		newNameChannel = File.getNameWithoutExtension(file);
		newNameChannel = newNameChannel + "-" + channelNames[i] +".tif";
		saveAs("tiff",  output + File.separator + newNameChannel);
		close();
	}	
	close();
}
