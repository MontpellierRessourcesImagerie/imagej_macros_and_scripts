/** 
 * Batch convert images in the .nd format to ImageJ hyperstacks
 * 
 * The user selects an .nd file. An image can consist of multiple
 * positions, frames, z-slices and channels.
 * Each position is converted into an ImageJ hyperstack and writen into
 * a subfolder of the folder containing the input image.
 * 
 * (c) 2018, INSERM
 * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 * 
 */

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_ND_To_Hyperstack";
var _OUT_DIR = "stacks";
var _SATURATED = 0.25;

macro "convert nd images [f8]" {
  convertNDImages();
}

macro "convert nd images (f8) Action Tool - C037T1d13nT9d13dC555"{
  convertNDImages();
}

macro "convert nd images (f8) Action Tool Options" {
	 Dialog.create("Convert ND-Images Options");
	 Dialog.addNumber("saturated", _SATURATED);
	 Dialog.addString("output folder", _OUT_DIR);
	 Dialog.addMessage("Press the help button below to open the online help!");
	 Dialog.addHelp(helpURL);
 	 Dialog.show();
 	 _SATURATED = Dialog.getNumber();
 	 _OUT_DIR = Dialog.getString();
}

function convertNDImages() {
	path = File.openDialog("Please select a .nd file");
	parentPath =File.getParent(path);
	stageNames = getStageNamesFromNDFile(path);
	outPath = parentPath + "/" + _OUT_DIR;
	if (!File.exists(outPath)) File.makeDirectory(outPath);
	setBatchMode(true);
	print("\\Clear");
	print("Converting nd-images to hyperstack...");
	for(i=0; i<stageNames.length; i++) {
		print("\\Update1:Converting position " + (i+1) + " of " + stageNames.length);
		run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+(i+1));
		title = getTitle();
		parts = split(title, "_");
		nameP1 = parts[0];
		nameP2 = parts[1];
		run("Enhance Contrast...", "saturated="+_SATURATED);
		saveAs("Tiff", outPath + "/" + nameP1 + "_"+nameP2+"_s"+(i+1)+"-"+stageNames[i]+".tif");
		close();
	}
	print("Finished converting !");
	setBatchMode(false);
}

function getStageNamesFromNDFile(path) {
	text = File.openAsString(path);
	lines = split(text, "\n");
	stageNames = newArray();
	for(i=0; i<lines.length; i++) {
		line = lines[i];
		parts = split(line, ",");
		if (parts.length<2) continue
		property = replace(parts[0], '"', '');
		value = replace(parts[1], '"', '');
		if (startsWith(property, "Stage")) stageNames = Array.concat(stageNames, value);
	}
	return stageNames;
}
