/***
 * 
 * MRI Filament tools
 * 
 * Detect nuclei in 3D images and run a cluster analysis on them
 * 
 * (c) 2020, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/
var FILAMENT_CHANNEL = 1;
var MIN_SIZE = 0.5; 	
var MAX_CIRCULARITY = 1;
var EXCLUDE_ON_EDGES = false;
var OBJECT_TABLE = "filaments";
var SUMMARY_TABLE = "summary filaments";
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Filament_Tools";
var SUFFIX = "Out.czi";

analyzeImage();
exit();

macro "filament tools (f1) Action Tool - C010L0020C030D30C060D40C080L5070C060D80C030D90C020Da0C010Db0C000Lc0f0C010L0121C030D31C070D41C080D51C090L6171C080D81C050D91C020Da1C010Db1C000Lc1f1C010L0222C030D32C070D42C090D52C0b0L6272C080D82C060D92C030Da2C010Db2C000Lc2f2C020D03C010D13C020D23C030D33C070D43C0b0D53C0c0L6373C0b0D83C070D93C030Da3C010Db3C000Lc3f3C050D04C030L1424C050D34C070D44C0b0D54C0f0L6474C0b0D84C080D94C050Da4C020Db4C000Lc4f4C080D05C070D15C060L2535C080D45C0c0D55C0f0L6575C0c0D85C080D95C050Da5C020Db5C000Lc5f5C0b0L0616C090D26C080D36C0b0D46C0d0D56C0f0L6676C0c0D86C080D96C060Da6C030Db6C010Dc6C000Ld6e6C010Df6C0d0L0717C0c0D27C0b0D37C0c0D47C0f0L5777C0c0D87C090D97C070Da7C050Db7C030Dc7C020Ld7f7C0d0D08C0f0L1828C0d0D38C0f0L4878C0d0D88C0b0D98C090Da8C070Db8C060Lc8d8C050Le8f8C0b0D09C0c0D19C0d0L2939C0f0L4989C0d0D99C0b0La9b9C090Dc9C080Ld9f9D0aC090D1aC0b0L2a3aC0c0D4aC0d0D5aC0f0L6a9aC0d0DaaC0c0LbadaC0b0LeafaC050D0bC070D1bC080L2b3bC090D4bC0b0L5b6bC0d0D7bC0f0L8bbbC0d0LcbebC0c0DfbC020D0cC030D1cC050D2cC060L3c4cC070D5cC080D6cC090D7cC0b0D8cC0c0L9cfcC010L0d1dC020L2d3dC030L4d5dC050D6dC070D7dC080D8dC090L9dedC0b0DfdC000L0e1eC010L2e4eC020L5e6eC030D7eC060D8eC070L9ebeC060LceeeC070DfeC000L0f3fC010L4f6fC020D7fC030D8fC050L9fafC030Lbfff" {
	help();
}

macro "filament tools help [f1]" {
	help();
}

macro "analyze image (f2) Action Tool - C000T4b12a" {
	analyzeImage();
}

macro "analyze image (f2) Action Tool Options" {
	Dialog.create("Filament tools options");
	Dialog.addNumber("filament channel: ", FILAMENT_CHANNEL);
	Dialog.addNumber("min. area: ", MIN_SIZE);
	Dialog.addNumber("max. circularity: ", MAX_CIRCULARITY);
	Dialog.addCheckbox("exclude on edges", EXCLUDE_ON_EDGES);
	Dialog.show();
	FILAMENT_CHANNEL = Dialog.getNumber();
	MIN_SIZE = Dialog.getNumber();
	MAX_CIRCULARITY = Dialog.getNumber();
	EXCLUDE_ON_EDGES = Dialog.getCheckbox();
}

macro "analyze image [f2]" {
	analyzeImage();
}

macro "batch analyze images (f3) Action Tool - 000T4b12b" {
	batchProcessImages();
}

macro "batch analyze images (f3) Action Tool Options" {
	Dialog.create("Batch processing options");
	Dialog.addString("image suffix: ", SUFFIX);
	Dialog.show();
	SUFFIX = Dialog.getString();
}

macro "batch analyze images [f3]" {
	batchProcessImages();
}

function help() {
	run('URL...', 'url='+helpURL);
}


function analyzeImage() {
	setBatchMode(true);
	getPixelSize(unit, pixelWidth, pixelHeight);
	title = getTitle();
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels>1) {
		Stack.setChannel(FILAMENT_CHANNEL);
	}
	run("Select None");
	getStatistics(area);
	run("Duplicate...", " ");
	setAutoThreshold("Huang dark");
	
	option = "";
	if (EXCLUDE_ON_EDGES) option = " exclude";
	run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity circularity=0.00-"+MAX_CIRCULARITY+" show=Masks"+option+" in_situ");
	run("Find Connected Regions", "allow_diagonal display_one_image display_results regions_for_values_over=100 minimum_number_of_points=1 stop_after=-1");
	getHistogram(values, counts, 65536);
	counts = Array.deleteIndex(counts, 0);
	counts = Array.deleteValue(counts, 0);
	if (!isOpen(OBJECT_TABLE)) {
		Table.create(OBJECT_TABLE);
	}
	totalArea = 0; 
	for (i = 0; i < counts.length; i++) {
		counts[i] = counts[i] * pixelWidth * pixelWidth;
		index =  Table.size(OBJECT_TABLE);
		Table.set("image", index, title, OBJECT_TABLE);
		Table.set("filament", index, i+1, OBJECT_TABLE);
		Table.set("area", index, counts[i], OBJECT_TABLE);
		totalArea = totalArea + counts[i];
	}
	Table.update(OBJECT_TABLE);
	
	Array.getStatistics(counts, min, max, mean, stdDev);
	
	if (!isOpen(SUMMARY_TABLE)) {
		Table.create(SUMMARY_TABLE);
	}
	index =  Table.size(SUMMARY_TABLE);
	Table.set("image", index, title, SUMMARY_TABLE);
	Table.set("image area", index, area,SUMMARY_TABLE);
	Table.set("filaments", index, counts.length, SUMMARY_TABLE);
	Table.set("total filament area", index, totalArea, SUMMARY_TABLE);
	Table.set("rel. filament area", index, totalArea/area, SUMMARY_TABLE);
	Table.set("mean", index, mean, SUMMARY_TABLE);
	Table.set("stdDev", index, stdDev, SUMMARY_TABLE);
	Table.set("min.", index, min, SUMMARY_TABLE);
	Table.set("max.", index, max, SUMMARY_TABLE);
	Table.update(SUMMARY_TABLE);
	setThreshold(1, 65535);
	run("Create Selection");
	close();
	close();
	run("Restore Selection");
	setBatchMode(false); 
}

function batchProcessImages() {
	dir = getDir("Select the input folder please!");
	files = getFileList(dir);
	images = filterImages(dir, files);
	if (!File.exists(dir+"control")) File.makeDirectory(dir+"control");
	for (i = 0; i < images.length; i++) {
		image = images[i];
		path = dir + image;
		run("Bio-Formats", "open=["+path+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		analyzeImage();
		saveAs("tiff", dir+"control/"+image);
		close();
	}
	selectWindow(OBJECT_TABLE);
	saveAs("results", dir+"filaments.xls");
	selectWindow(SUMMARY_TABLE);
	saveAs("results", dir+"summary-filaments.xls");
}

function filterImages(dir, files) {
	result = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		path = dir + file;
		if (File.isDirectory(path)) continue;
		if (endsWith(file, SUFFIX)) result = Array.concat(result, file);
	}
	return result;
}
