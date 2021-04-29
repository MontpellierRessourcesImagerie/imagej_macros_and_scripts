/***
 * 
 * MRI Filament Morphology Tool
 * 
 * Count filaments and measure their areas and forms.
 * 
 * (c) 2021 INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
  */
  
var _MIN_SIZE = 0.01;
var _FILAMENT_CHANNEL = 1;
var _FILAMENT_THRESHOLDING_METHOD = "Default";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _INTERPOLATION_LENGTH = 3;
var _EXT = ".czi";
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Filament_Morphology_Tool";

analyzeImage();
exit;

macro "filament morphology tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "filament morphology tool help (f4) Action Tool - C020D00C010L1060C020L7080C030L90a0C020Db0C010Dc0C000Ld0f0C010L0131C020L4151C010L61a1C000Lb1f1C010L0212C020D22C030L3252C020D62C010L7282C000L92f2C010D03C020D13C030D23Cff0L3363C010D73C000L83d3C010Le3f3D04C020D14Cff0L2434C160D44C050D54Cff0D64C020D74C010L84c4C020Ld4f4C010D05C020D15Cff0D25Cf00D35Ca30D45C050D55Cff0L6575C030D85C020L95b5C030Lc5f5C010D06C020D16Cff0D26C160D36Ca30D46Cf00D56Ca20D66Cff0L76f6C010D07C020D17Cff0D27C160L3757Ca20D67Cf00D77Ca20D87C140L97a7C050Lb7c7C140Dd7C030De7Cff0Df7C010D08C020D18Cff0L2838C050L4868C140D78Ca20D88Cf00L98d8Cff0Le8f8C000D09C010D19C020D29Cff0L3949C140L5969C030D79Cff0L89e9C020Df9C000L0a1aC010D2aC020D3aCff0L4a8aC020L9aaaC010LbadaC020DeaC010DfaC000L0b2bC010L3bfbL0c5cC000L6c9cC010LacecC020DfcC010L0d3dC000L4d9dC010DadC020LbdfdL0e2eC010D3eC000L4e7eC010L8e9eC030LaedeC020LeefeCff0L0f1fC020D2fC010L3f4fC000L5f7fC010D8fC030D9fCff0LafdfC020Lefff"{
	run('URL...', 'url='+helpURL);
}

macro "analyze image [f2]" {
	analyzeImage();
}

macro "analyze image (f2) Action Tool - C000T4b12a" {
	analyzeImage();
}

macro "analyze image (f2) Action Tool Options" {
	Dialog.create("filament morphology tool options");	
	Dialog.addNumber("filament channel: ", _FILAMENT_CHANNEL);
	Dialog.addChoice("filament auto-thresholding method: ", _THRESHOLDING_METHODS, _FILAMENT_THRESHOLDING_METHOD);
	Dialog.addNumber("filament min. area: ", _MIN_SIZE);
	Dialog.addNumber("interpolation length: ", _INTERPOLATION_LENGTH);
	Dialog.show();
	_FILAMENT_CHANNEL = Dialog.getNumber();
	_FILAMENT_THRESHOLDING_METHOD = Dialog.getChoice();
	_MIN_SIZE = Dialog.getNumber();
	_INTERPOLATION_LENGTH = Dialog.getNumber();
}

macro "run batch analysis [f3]" {
	runBatchAnalysis();
}

macro "run batch analysis (f3) Action Tool - C000T4b12b" {
	runBatchAnalysis();
}

macro "run batch analysis (f3) Action Tool Options" {
	Dialog.create("batch options");
	Dialog.addString("image file-extension", _EXT);
	Dialog.show();
	Dialog.getString(_EXT);
}
	
function runBatchAnalysis() {
	dir = getDir("Select the input folder");
	files = getFileList(dir);
	images = filterImages(files, _EXT);
	if (!File.exists(dir + "out")) File.makeDirectory(dir + "out");
	for (i = 0; i < images.length; i++) {
		image = images[i];
		run("Bio-Formats", "open=["+dir+image+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		title = getTitle();
		analyzeImage();
		parts = split(title, ".");
		name = parts[0];
		saveAs("tiff", dir + "out/" + name + ".tif");
		Table.save(dir + "out/" + name + "_branches.csv" , "Global Branch Information");
		close("Global Branch Information");
		close("*");
	}
	Table.save(dir+"out/"+"results.xls", "Results");
}

function analyzeImage() {
	run("Set Measurements...", "area centroid perimeter bounding fit shape feret's display redirect=None decimal=9");
	setBatchMode(true);
	roiManager("reset");
	run("Select None");
	Overlay.remove;
	roiManager("reset");
	inputImageID = getImageID();
	inputImageTitle = getTitle();
	getDimensions(width, height, channels, slices, frames);
	if (channels>1) {
		run("Duplicate...", "duplicate channels="+_FILAMENT_CHANNEL+"-"+_FILAMENT_CHANNEL);
	} else {
		run("Duplicate...", " ");
	}
	setAutoThreshold("Default dark");
	startLine = nResults;
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity display exclude add");
	close();
	resetMinAndMax();
	run("Enhance Contrast", "saturated=0.35");
	run("From ROI Manager");
	roiManager("Combine");
	run("Create Mask");
	maskID = getImageID();
	run("Connected Components Labeling", "connectivity=8 type=[16 bits]");
	lblID = getImageID();
	run("Geodesic Diameter", "label=Mask-lbl distances=[Chessknight (5,7,11)] show image=["+inputImageTitle+"]");
	selectImage(inputImageID);	
	selectImage(lblID);
	close();
	selectImage(inputImageID);
	run("From ROI Manager");
	title1 = "Results";
	title2 = "Mask-lbl-GeodDiameters";
	appendTableColumns(title1, title2, startLine);
	close(title2);
	Table.rename("Results", "Filament morphology summary");
	selectImage(maskID);
	run("Skeletonize (2D/3D)");
	count = roiManager("count");
	Table.create("Global Branch Information");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		run("Duplicate...", " ");;
		run("Clear Outside");
		run("Analyze Skeleton (2D/3D)", "prune=none calculate show");
		appendTableColumns("Filament morphology summary", "Results", i);
		close("Results");	
		close();
		close();
		close();
		countBranches = Table.size("Branch information");
		for (j = 0; j < countBranches; j++) {
			Table.set("Skeleton_ID", j, i+1);
		}
		appendTableRows("Global Branch Information", "Branch information");
		close("Branch information");
	}
	run("Analyze Skeleton (2D/3D)", "prune=none calculate show");
	selectWindow("Longest shortest paths");
	close();
	selectImage("Tagged skeleton");
	run("glasbey on dark");
	selectImage(inputImageID);
	run("Add Image...", "image=[Tagged skeleton] x=0 y=0 opacity=100 zero");
	close("Tagged skeleton");
	close(maskID); 
	close("Branch information");
	close("Results");
	close("Mask");
	setBatchMode("exit and display"); 
}

function appendTableColumns(table1, table2, startLine) {
	headings = Table.headings(table2);
	columns = split(headings, "\t");
	nrOfColumns = columns.length;
	size = Table.size(table2);
	for (i = 0; i < size; i++) {
		for(c=1; c<nrOfColumns; c++) {
			value = Table.get(columns[c], i, table2);
			Table.set(columns[c], startLine+i, value, table1);
		}
	}
	Table.update(table1);
}

function appendTableRows(table1, table2) {
	count = Table.size(table2);	
	startLine = Table.size(table1);
	headings = Table.headings(table2);
	columns = split(headings, "\t");
	nrOfColumns = columns.length;
	for (i = 0; i < count; i++) {
		for(c=1; c<nrOfColumns; c++) {
			value = Table.get(columns[c], i, table2);
			Table.set(columns[c], startLine+i, value, table1);
		}
	}
}

function filterImages(files, ext) {
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, ext)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}