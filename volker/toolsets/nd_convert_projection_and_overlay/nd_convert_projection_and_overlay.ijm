/*
 * INPUT:
 * Channles to use:
 * 	TIRF-561, TIRF-488
 * Each file has 5 z-slices.
 * Different stage positions, each "s" one image
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
var _SUFFIX = ".nd";
var _RADIUS_1 = 50;
var _RADIUS_2 = 50;
var _MIN_1 = 0;
var _MAX_1 = 2000;
var _MIN_2 = 0;
var _MAX_2 = 2000;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/ND_Convert_Projection_And_Overlay";


macro "batch process nd files [f9]" {
	batchProcessImages();
}

macro "batch process nd files (f9) Action Tool - C000T4b12b"{
	batchProcessImages();
}

macro "batch process nd files (f9) Action Tool Options" {
    Dialog.create("nd_convert");
    Dialog.addNumber("channel 1 - radius for background correction: ", _RADIUS_1);
    Dialog.addNumber("channel 1 - min. display value: ", _MIN_1);
    Dialog.addNumber("channel 1 - max. display value: ", _MAX_1);
    Dialog.addNumber("channel 2 - radius for background correction: ", _RADIUS_2);
    Dialog.addNumber("channel 2 - min. display value: ", _MIN_2);
    Dialog.addNumber("channel 2 - max. display value: ", _MAX_2);
    Dialog.addHelp(helpURL);
    Dialog.show();
    _RADIUS_1 = Dialog.getNumber();
    _MIN_1 = Dialog.getNumber();
    _MAX_1 = Dialog.getNumber();
    _RADIUS_2 = Dialog.getNumber();
    _MIN_2 = Dialog.getNumber();
    _MAX_2 = Dialog.getNumber();
}

function batchProcessImages() {
	setBatchMode(true);
	print("\\Clear");
	inDir = getDirectory("Choose a Directory");
	processFolder(inDir, _OUTPUT, _SUFFIX);
	setBatchMode(false);
	print("FINISHED");
}

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
	print("\\Update1:                     ");
	print("\\Update0:Processing: " + input + File.separator + file);
	path = input + File.separator + file;
	nrOfStages = getNumberOfStages(path);
	out = input + File.separator + output;
	if (!File.exists(out)) File.makeDirectory(out);
	counter = 1;
	for(i=1; i<=nrOfStages; i=i+2) {
		series = "series_" + i;
		print("\\Update1:Processing series: " + counter + " of " + (nrOfStages / 2));
		run("Bio-Formats Importer", "open="+path+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT "+series);
		title = getTitle();
		run("Split Channels");
		selectImage("C1-"+title);
		run("Subtract Background...", "rolling="+_RADIUS_1+" stack");
		selectImage("C2-"+title);
		run("Subtract Background...", "rolling="+_RADIUS_2+" stack");
		run("Merge Channels...", "c1=[C1-"+title+"] c2=[C2-"+title+"] create");
		Stack.setDisplayMode("composite");
		Stack.setChannel(1);
		setMinAndMax(_MIN_1, _MAX_1);
		Stack.setChannel(2);
		setMinAndMax(_MIN_2, _MAX_2);
		Stack.setChannel(1);
		run("Z Project...", "projection=[Max Intensity] all");
		names = split(title, "-");
		name = names[0];
		saveAs("Tiff", out + File.separator +name + "_s"+i+".tif");
		close();
		close();
		counter++;
	}
}

function getNumberOfStages(path) {
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
	return stageNames.length;
}

