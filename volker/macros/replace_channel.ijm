/*
 * For each image there are two hyperstacks. Replace the 4th channel of the first stack by the 4th channel of the second Stack.
 * The image from the second stack is scaled to the size of the images in the first stack before they are merged.
 * 
 * (c) 2018, INSERM
 * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 * 
 */

var _CHANNEL_SUPER = "SIR";
var _CHANNEL_WF = "WF_D3D";
var _OUT_DIR = "results";
var _WORK_DIR = "tmp";
var _EXT = ".dv";

batchProcessImages()

function batchProcessImages() {
	dir = getDirectory("Select the input folder");
	files = getFileList(dir);
	
	File.makeDirectory(dir + "/" + _OUT_DIR);

	files = filterImageFilesChannelSuper(dir, files);
	setBatchMode(true);
	print("\\Clear");
	print("replacing channel 4...");
	for (i = 0; i < files.length; i++) {
		print("\\Update1:Processing image " + (i+1) + " of " + files.length);
		file1 = files[i];
		path = dir + "/" + file1;
		run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT");
		close();
		width1 = getWidth();
		height1 = getHeight();
		depth = nSlices;
		file2 = replace(file1, _CHANNEL_SUPER, _CHANNEL_WF);
		path = dir + "/" + file2;
		run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		wfImageID = getImageID();
		run("Duplicate...", "duplicate channels=4-4");
		oneChannelID = getImageID();
		selectImage(wfImageID);
		close();
		width2 = getWidth();
		height2 = getHeight();
		sfx = width1 / width2;
		sfy = height1 / height2;
		run("Scale...", "x="+sfx+" y="+sfy+" z=1.0 width="+width1+" height="+height1+" depth="+depth+" interpolation=Bilinear average process create");
		scaledTitle = getTitle();
		selectImage(oneChannelID);
		close();
		run("Merge Channels...", "c1=["+file1+" - C=0] c2=["+file1+" - C=1] c3=["+file1+" - C=2] c4=["+scaledTitle+"] create");
		outFile = replace(file1,  _CHANNEL_SUPER+"_", "");
		outFile = replace(outFile,  ".dv", ".tif");
		save(dir + "/" + _OUT_DIR + "/" + outFile);
		close();
	}
	setBatchMode(false);
	print("Finished replacing channel 4 !");
}

function filterImageFilesChannelSuper(dir, files) {
	filteredFiles = newArray();
	for(i=0; i<files.length; i++) {
		file = files[i];
		path = dir + "/" + file;
		if (	indexOf(file, _CHANNEL_SUPER)!=-1 &&
				!File.isDirectory(path) && 
				endsWith(file, _EXT)
			)
				filteredFiles = Array.concat(filteredFiles, file);
	}
	return filteredFiles;
}

function cleanFolder(folder) {
	files = getFileList(folder);
	for (i = 0; i < files.length; i++) {	
		if (File.isDirectory())  continue;
		path = folder + "/" + files[i];
		File.delete(path);
	}
}
