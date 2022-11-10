/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".ims") suffix

var SERIES = "series_1";
// See also Process_Folder.py for a version of this code
// in the Python scripting language.

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("ims2tif started " + year + "-" + (month)+1 + "-" + dayOfMonth + " " + hour + ":" + minute + ":" + second); 

setBatchMode(true);
processFolder(input + "/");
setBatchMode(false);

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("ims2tif finished " + year + "-" + (month)+1 + "-" + dayOfMonth + " " + hour + ":" + minute + ":" + second); 
// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, list[i]);
	}
}

function processFile(input, file) {
	// Do the processing here by adding your own code.
	// Leave the print statements until things work, then remove them.
    File.makeDirectory(input + "tiff");
	print("Processing: " + input + file);
    run("Bio-Formats", "open=["+input + file+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT " + SERIES);
	print("Saving to: " + input + "tiff/" + file);
    saveAs("tiff", input + "tiff/" + file);
    close();
}
