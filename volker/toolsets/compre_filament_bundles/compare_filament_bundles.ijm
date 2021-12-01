/***
 * 
 * Compare filament bundles
 * 
 * Segment filaments and measure intensities
 * 
 * (c) 2021, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/

var CHANNEL = 1;
var MIN_AREA = 0.2; 	// in square-µm
//var FILE_EXT = "tif";
var FILE_EXT = "czi";
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Compare_Filament_Bundles_Tool";

folder = getDir("Select the input folder!");
batchProcess(folder);

// segmentNormalized(MIN_AREA);

exit();

macro "compare filament bundles tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "compare filament bundles tool help (f4) Action Tool - C010D00C020D10C040L2030C020D40C010L5060C020D70C030D80C040D90C010Da0Lc0f0C030D01C080D11C090D21C060D31C030D41C020D51C010L6171C040D81C050D91C010La1d1C020De1C010Df1C080L0232C040D42C010L5272C030D82C070D92C010Da2Lc2f2C040D03C020D33C040D43C010L5383C060D93C070Da3C020Db3C010Ld3e3C030D04C040D14C020D24C030D34C040L4454C030D64C040L7484C070L94a4C080Db4C040Dc4C010Ld4f4D05C020D15C060L2535C030D45C020D55C040D65C060D75C090D85C080D95C030La5b5C060Dc5C070Dd5C020De5C010Df5D16C050L2636C060D46C030D56C010D66C020D76C060D86C030D96C010La6c6C050Dd6C090De6C030Df6C010D07C020D17C030D27C010D47C050D57C0d0L6777C080D87C040D97C010Da7C020Db7C010Dc7C040De7C0a0Df7C060D08C030D18C020D28C010D38C050D48C090D58C080D68C0a0L7888C0d0D98C040Da8C010Lb8d8C040Le8f8D09C060D19C080D29C0d0L3949C080D59C040D69C060D79C0d0L89a9C050Db9C040Dc9C050Dd9C030De9C010Df9C080D0aC0a0D1aC090D2aC080D3aC040D4aC030D5aC040D6aC050D7aC0a0D8aC0d0L9acaC0a0DdaC090LeafaC060D0bC030D1bC010L2b8bC060D9bC0d0DabC040DbbC020DcbC040DdbC050DebC040DfbC020L0c1cC010L2c5cC020D6cC010L7c8cC030D9cC0d0DacC080DbcC010DdcDfcL0d7dC020D8dC030D9dC040DadC0d0DbdC010LcdedC020DfdD0eC010D1eL3e5eL7eaeC090DbeC040DceC010DeeC020DfeC010L0f3fC020D4fC010L5f9fDbfC040DcfC010DdfC020DefC010Dff"{
	run('URL...', 'url='+helpURL);
}

macro "process image (f5) Action Tool - C000T4b12p" {
	segmentNormalized(MIN_AREA);
}

macro "process image [f5]" {
	segmentNormalized(MIN_AREA);
}


macro "process image (f5) Action Tool Options" {
	Dialog.create("compare filament bundles options");
	Dialog.addNumber("channel: ", CHANNEL);	
	Dialog.addNumber("min. area: ", MIN_AREA);	
	Dialog.show();
	CHANNEL = Dialog.getNumber();
	MIN_AREA = Dialog.getNumber();
}

macro "run batch analysis (f6) Action Tool - C000T4b12b" {
	folder = getDir("Select the input folder!");
	batchProcess(folder);
}

macro "run batch analysis [f6]" {
	folder = getDir("Select the input folder!");
	batchProcess(folder);
}

macro "run batch analysis (f6) Action Tool Options" {
	Dialog.create("batch process filament bundles options");
	Dialog.addString("image file ext.: ", FILE_EXT);	
	Dialog.show();
	FILE_EXT = Dialog.getString();
}

function batchProcess(folder) {
	run("Clear Results");
	files = getFileList(folder);
	File.makeDirectory(folder + "/" + "out");
	images = filterFilesEndingWith(files, "."+FILE_EXT);
	for (i = 0; i < images.length; i++) {
		path = folder + files[i];
		run("Bio-Formats Importer", "open=["+path+"] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=Default");
		segmentNormalized(0.2);
		run("Enhance Contrast", "saturated=0.35");
		saveAs("tiff", folder + "/" + "out/"+ files[i]);	
		close();
	}
	saveAs("results", folder + "/" + "out/results.csv");
}

function segmentNormalized(minSize) {
	run("Duplicate...", "duplicate channels="+CHANNEL+"-"+CHANNEL);
	roiManager("reset");
	Overlay.remove;
	run("Select None");
	run("Enhance Contrast...", "saturated=0.3 normalize");
	setAutoThreshold("Default dark");
	run("Analyze Particles...", "size=0.2-Infinity add composite");
	close();
	roiManager("measure");
 	run("From ROI Manager");
}

function filterFilesEndingWith(files, text) {
	result = newArray(0);
	for (i = 0; i < files.length; i++) {
		if (endsWith(files[i], text)) {
			result = Array.concat(result, files[i]);
		}
	}
	return result;
}
