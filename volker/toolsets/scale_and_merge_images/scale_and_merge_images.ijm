var _CHANNEL_SUPER = "SIR";
var _CHANNEL_WF = "WF_D3D";
var _OUT_DIR = "results";
var _WORK_DIR = "tmp";
var _EXT = ".dv";

function batchProcessImages() {
	dir = getDirectory("Select the input folder");
	files = getFileList(dir);

	File.makeDirectory(dir + "/" + _WORK_DIR);
	File.makeDirectory(dir + "/" + _OUT_DIR);

	files = filterImageFilesChannelSuper(dir, files);

	for (i = 0; i < files.length; i++) {
		file = files[i];
		path = dir + "/" + file;
		run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		originalID = getImageID();
		run("Duplicate...", "duplicate channels=1-3");
		threeChannelID = getImageID();
		selectImage(originalID);
		close();
		file = replace(file, _CHANNEL_SUPER, _CHANNEL_WF);
		path = dir + "/" + file;
		run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		wfImageID = getImageID();
		run("Duplicate...", "duplicate channels=4-4");
	}
}

function loadAndConvertHyperstackToStack(path) {
	run("Bio-Formats Importer", "open=[path] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	title = getTitle();
	run("Image Sequence... ", "format=TIFF name=tmp save=["+path+"/tmp_z001_c001.tif]");	
	close();
	run("Image Sequence...", "open=["+path+"/tmp_z001_c001.tif]"] sort");
	superImageID = getImageID();
	cleanFolder(dir + "/" + _WORK_DIR);
	rename(title);
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
