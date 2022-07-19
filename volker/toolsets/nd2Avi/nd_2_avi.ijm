/***
 * 
 * ND2AVI
 * 
 * Convert multi-position ND-time-series to avi movies
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/

var OUT_FOLDER = "converted/";
var EXTENSION = "TIF";
var INTERVAL = 600;			// in seconds
var FRAME_RATE = 2;

// Timebar options
var OFFSET = 0;				// start counting at offset
var THICKNESS = 4;
var FONTSIZE = 28;
var COLORS = newArray("Black", "Blue", "(Light) Gray", "Gray", "(Dark) Gray", "Green", "Red", "White", "Yellow");
var COLOR = COLORS[0];
var BACKGROUND_COLORS = Array.concat(COLORS, "None");
var BACKGROUND_COLOR = BACKGROUND_COLORS[7];
var LOCATIONS = newArray("Upper Right", "Lower Right", "Lower Left", "Upper Left", "At Selection");
var LOCATION = LOCATIONS[0];
var TIME_FORMATS = newArray("D-HH:mm:ss.SSS", "D-HH:mm:ss", "D-HH:mm", "HH:mm:ss.SSS", "HH:mm:ss", "HH:mm", "mm:ss.SSS", "mm:ss", "ss.SSS");
var TIME_FORMAT = TIME_FORMATS[2];
var BOLD = true;
var HIDE_BAR = true;
var SERIF_FONT = false;
var SHOW_UNITS = false;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/ND_2_AVI";

macro "ND2AVI tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "ND2AVI tool help (f4) Action Tool - C000T4b12?"{
	run('URL...', 'url='+helpURL);
}

macro "convert ND2AVI (f5) Action Tool - C000T4b12c" {
	convert();
}

macro "convert ND2AVI [f5]" {
	convert();
}

macro "convert ND2AVI (f5) Action Tool Options" {
	Dialog.create("ND2AVI Options");
	Dialog.addMessage("Time-series/movie options");
	Dialog.addNumber("time intervall in seconds: ", INTERVAL);
	Dialog.addNumber("AVI frame rate: ", FRAME_RATE);
	Dialog.addMessage("Timestamp (Timebar) options");
	Dialog.addNumber("offset: ", OFFSET);
	Dialog.addNumber("thickness: ", THICKNESS);
	Dialog.addNumber("font size: ", FONTSIZE);
	Dialog.addChoice("color: ", COLORS, COLOR);
	Dialog.addChoice("background color: ", BACKGROUND_COLORS, BACKGROUND_COLOR);
	Dialog.addChoice("location: ", LOCATIONS, LOCATION);
	Dialog.addChoice("time format: ", TIME_FORMATS, TIME_FORMAT);
	Dialog.addCheckbox("bold", BOLD);
	Dialog.addCheckbox("hide bar", HIDE_BAR);
	Dialog.addCheckbox("serif font", SERIF_FONT);
	Dialog.addCheckbox("show units", SHOW_UNITS);
	Dialog.show();
	INTERVAL = Dialog.getNumber();
	FRAME_RATE = Dialog.getNumber();
	
	OFFSET = Dialog.getNumber();
	THICKNESS = Dialog.getNumber();
	FONTSIZE = Dialog.getNumber();
	
	COLOR = Dialog.getChoice();
	BACKGROUND_COLOR = Dialog.getChoice();
	LOCATION = Dialog.getChoice();
	TIME_FORMAT = Dialog.getChoice();
	
	BOLD = Dialog.getCheckbox();
	HIDE_BAR = Dialog.getCheckbox();
	SERIF_FONT = Dialog.getCheckbox();
	SHOW_UNITS = Dialog.getCheckbox();
}

function convert() {
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	ndFiles = getNDFilesInList(dir, files);
	numberOfTimepoints = 0;
	paths = newArray(0);
	numberOfPositions = 0;
	if (!File.exists(dir+OUT_FOLDER)) {
		File.makeDirectory(dir+OUT_FOLDER);
	}
	for (i = 0; i < ndFiles.length; i++) {
		ndFile = ndFiles[i];
		ndContent = File.openAsString(ndFile);
		lines = split(ndContent, "\n");
		numberOfTimepoints = getNumberOfTimepoints(lines);
		numberOfPositions = getNumberOfPositions(lines);
		paths = getPaths(lines, dir, OUT_FOLDER);
		for (pos = 0; pos < numberOfPositions; pos++) {
			options = "filter=."+EXTENSION+" start="+((pos*numberOfTimepoints)+1)+" count="+numberOfTimepoints+" sort";
			print(options);
			File.openSequence(ndFile, options);
			Stack.setDimensions(1, 1, numberOfTimepoints) 
			Stack.setFrameInterval(INTERVAL);
			Stack.setTUnit("sec") 
			options = "offset="+OFFSET+" thickness="+THICKNESS+" font="+FONTSIZE+" color="+COLOR+" background="+BACKGROUND_COLOR+" location=["+LOCATION+"] time="+TIME_FORMAT;
			if (BOLD) options = options + " bold";
			if (HIDE_BAR) options = options + " hide";
			if (SERIF_FONT) options = options + " serif";
			if (SHOW_UNITS) options = options + " show";
			run("Time Bar...", options + " overlay");
			saveAs("tiff", paths[pos]);
			run("Remove Overlay");
			run("Time Bar...", options);
			outPath = replace(paths[pos], ".tif", ".avi");
			run("AVI... ", "compression=JPEG frame="+FRAME_RATE+" save=["+outPath+"]");
			close();
		}
	}
}

function getPaths(lines, dir, out) {
	paths = newArray(0);
	for (i = 0; i < lines.length; i++) {
		line = lines[i];
		parts = split(line, ", ");
		name = replace(parts[0], '"', '');
		if (startsWith(name, 'Stage')) {
			value = replace(parts[1], '"', '');
			paths = Array.concat(paths, dir+out+value+'.tif');
		}
	}
	return paths;
}

function getNumberOfTimepoints(lines) {
	number = getValueAt('NTimePoints', lines);
	return number;
}

function getNumberOfPositions(lines) {
	number = getValueAt('NStagePositions', lines);
	return number;	
}

function getValueAt(key, lines) {
	for (i = 0; i < lines.length; i++) {
		line = lines[i];
		parts = split(line, ",");
		name = replace(parts[0], '"', '');
		if (name==key) {
			return parseInt(parts[1]);
		}
	}
	return 0;
}
	
function getNDFilesInList(dir, aList) {
	ndFiles = newArray(0);
	for (i = 0; i < aList.length; i++) {
		file = aList[i];
		if (endsWith(file, ".nd")) {
			ndFiles = Array.concat(ndFiles, dir + file);
		}
	}
	return ndFiles;
}


