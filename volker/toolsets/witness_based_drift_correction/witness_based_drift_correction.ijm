/***
 * 
 * Witness Based Drift Correction
 * 
 * Correct the constant drift in one channel by using the first and last frame 
 * of another channel (the witness) to calculate the overall translation T. 
 * Divide T the number of timepoints-1 and apply it to each frame.
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/
var _CONTENT_CHANNEL = 2;
var _WITNESS_CHANNEL = 1;
var _IMAGE_FILE_EXTENSION = "nd";
var _REMOVE_WITNESS = true;
var _OUTPUT_IN_BASEFOLDER = true;
var _OUTPUT_FOLDER_NAME = "/drift_corrected_images/";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Witness_based_drift_correction_Tool";

correctConstantDrift(false);
exit(0);

macro "witness based drift correction help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "witness based drift correction help (f4) Action Tool - C8aaL00f0L01f1L02c2C8abDd2CbbdDe2C8aaDf2L03b3C8abDc3CbbdDd3CbcdDe3C8aaDf3L04a4C8abDb4CbbdDc4CbcdLd4e4C8aaDf4D05C99aL1535C8aaL4575C8abL8595CbbdDa5CbcdLb5e5C8aaDf5D06C99aL1646C8aaL5666C9abD76CeffL8696CddeDa6CbcdLb6e6C8aaDf6L0717C99aL2757C8abD67CddeD77CfffL8797CeffDa7CbcdLb7e7C8aaDf7L0828C99aL3878CeefD88CfffD98CeffDa8CbcdLb8d8CbbdDe8C8aaDf8C677L0939C99aL4989CeefD99CeffDa9CbcdDb9CbbdLc9d9C677Le9f9C556L0a2aC677L3a4aC99aL5abaC677LcadaC556LeafaL0b3bC677D4bC99aD5bC677L6bbbC556LcbfbL0c3cC677L4c8cC444L9cdcC556LecfcL0d4dC444L5dddC556LedfdL0e4eC444L5eceC556LdefeL0f4fC444L5fafC556Lbfff"{
	run('URL...', 'url='+helpURL);
}

macro "correct drift (f5) Action Tool - C000T4b12c" {
	correctConstantDrift(false);
}

macro "correct drift [f5]" {
	correctConstantDrift(false);
}

macro "batch correct drift (f6) Action Tool - C000T4b12b" {
	batchCorrectConstantDrift();
}

macro "batch correct drift [f6]" {
	batchCorrectConstantDrift();
}

macro "correct drift (f5) Action Tool Options" {
	Dialog.create("Witness based drift correction options");
	Dialog.addNumber("content channel: ", _CONTENT_CHANNEL);
	Dialog.addNumber("witness channel: ", _WITNESS_CHANNEL);
	Dialog.addCheckbox("remove witness in result", _REMOVE_WITNESS);
	Dialog.show();
	_CONTENT_CHANNEL = Dialog.getNumber();
	_WITNESS_CHANNEL = Dialog.getNumber();
	_REMOVE_WITNESS = Dialog.getCheckbox();
}

macro "batch correct drift (f6) Action Tool Options" {
	Dialog.create("batch drift correction options");
	Dialog.addString("image file-extension: ", _IMAGE_FILE_EXTENSION);
	Dialog.addCheckbox("output in base-folder", _OUTPUT_IN_BASEFOLDER);
	Dialog.show();
	_IMAGE_FILE_EXTENSION = Dialog.getString();
	_OUTPUT_IN_BASEFOLDER = Dialog.getCheckbox();
}
/**
 * Run the drift correction recursively on all images in a folder and its subfolders.
 */

function batchCorrectConstantDrift() {
	dir = getDir("Please select the input folder!");
	print("Batch Drift Corrections started!");
	printTimestamp();
	if (_OUTPUT_IN_BASEFOLDER) output = dir;
	else output = dir + _OUTPUT_FOLDER_NAME;
	processFolder(dir, output, '.'+_IMAGE_FILE_EXTENSION);
	print("Batch Drift Corrections finished!");
	printTimestamp();
	beep();
}
/**
 * Correct the constant drift in one channel by using the first and last frame 
 * of another channel (the witness) to calculate the overall translation. 
 * divide it by the number of timepoints-1 and apply it to each frame
 */
function correctConstantDrift(batchIsRunning) {
	if (!batchIsRunning) setBatchMode("hide");
	title = getTitle();
	getDimensions(width, height, channels, slices, frames);
	tmpDir = getDir('imagej') + "/tmp";
	transformationsFilePath = tmpDir + "/trans.txt";
	File.makeDirectory(tmpDir);
	run("Split Channels");
	print("calculating drift from witness...");
	localDelta = getOneStepDriftVector(title, frames, transformationsFilePath);
	writeTransformationFileForAllFrames(localDelta, frames, transformationsFilePath);
	print("applying drift correction...");
	run("MultiStackReg", "stack_1=[C"+_CONTENT_CHANNEL+"-"+title+"] action_1=[Load Transformation File] file_1="+transformationsFilePath+" stack_2=None action_2=Ignore file_2=[] transformation=[Translation]");
	if (_REMOVE_WITNESS) {
		selectImage("C"+_WITNESS_CHANNEL+"-"+title);
		close();
	} else { 
		run("MultiStackReg", "stack_1=[C"+_WITNESS_CHANNEL+"-"+title+"] action_1=[Load Transformation File] file_1="+transformationsFilePath+" stack_2=None action_2=Ignore file_2=[] transformation=[Translation]");
	}
	mergeChannels(title, channels);	
	if (!batchIsRunning) {
		setBatchMode("show");
		beep();
	}
}

/**
 * Calculate the translation-vector between two frames, from the translation vector
 * between the first and the last frame frame in the witness-channel.
 * 
 * Answers an array with the x-component and the y-component of the vector 
 * at the positions 0 and 1.
 */
function getOneStepDriftVector(title, frames, transformationsFilePath) {
	selectImage('C'+_WITNESS_CHANNEL+'-'+title);
	run("Make Substack...", "  slices=1,"+frames);
	substackID = getImageID();
	run("MultiStackReg", "stack_1=[Substack (1,"+frames+")] action_1=Align file_1=["+transformationsFilePath+"] stack_2=None action_2=Ignore file_2=[] transformation=Translation save");
	selectImage(substackID);
	close();
	transformationsText = File.openAsString(transformationsFilePath);
	transformationsLines = split(transformationsText, "\n");
	srcLine = transformationsLines[5];
	targetLine = transformationsLines[9];
	parts = split(srcLine, "\t");
	xSrc = parseFloat(parts[0]);
	ySrc = parseFloat(parts[1]);
	parts = split(targetLine, "\t");
	xTarget = parseFloat(parts[0]);
	yTarget = parseFloat(parts[1]);
	globalDeltaX = xSrc - xTarget;
	globalDeltaY = ySrc - yTarget;
	print("global delta x:", globalDeltaX);
	print("global delta y:", globalDeltaY);
	localDeltaX = globalDeltaX / (frames - 1);
	localDeltaY = globalDeltaY / (frames - 1);
	print("local delta x:", localDeltaX);
	print("local delta y:", localDeltaY);
	return newArray(localDeltaX, localDeltaY);
}

/**
 * Fake a transformations-file for MultiStackReg, using a constant vector 
 * localDelta for each steps.
 */
function writeTransformationFileForAllFrames(localDelta, frames, transformationsFilePath) {
	output = "";
	output = output + "MultiStackReg Transformation File\n"
					+ "File Version 1.0\n"
					+ "0\n";
	for (i = 2; i <= frames; i++) {
		output = output + "TRANSLATION\n"
						+ "Source img: "+ i + " Target img: 1\n" 
						+ "" + 300+((1)*localDelta[0]) + "\t" + 300+((1)*localDelta[1]) + "\n"
						+ "0.0\t0.0\n"
						+ "0.0\t0.0\n"
						+ "\n"
						+ "300.0\t300.0\n"
						+ "0.0\t0.0\n"
						+ "0.0\t0.0\n"
						+ "\n";
	}
	File.saveString(output, transformationsFilePath);	
}

/**
 * Re-merge the channels of an image that have been
 * split with ImageJ's split channels command.
 */
function mergeChannels(title, channels) {
	mergeOptions = "";
	for (c = 1; c <= channels; c++) {
		if (_REMOVE_WITNESS && c==_WITNESS_CHANNEL) continue;
		mergeOptions = mergeOptions + "c"+c+"=[C"+c+"-"+title+"] ";
	}
	mergeOptions = mergeOptions + "create";
	run("Merge Channels...", mergeOptions);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (c = 1; c <= channels; c++) {
		Stack.setChannel(c);
		run("Grays");
	}
	Stack.setChannel(1);
	if (channels > 1) Stack.setDisplayMode("color");
}

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, output, suffix) {
	list = getFileList(input);
	list = Array.sort(list);
	setBatchMode(true);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i])) {
			if (!_OUTPUT_IN_BASEFOLDER) output = input + File.separator + list[i] + _OUTPUT_FOLDER_NAME;
			processFolder(input + File.separator + list[i], output, suffix);
		}
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
	setBatchMode("exit and display");
}

function processFile(input, output, file) {
	print("Processing: " + input + File.separator + file);
	run("Bio-Formats", "open=["+input + File.separator + file+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	correctConstantDrift(true);
	File.makeDirectory(output);
	print("Saving to: " + output);
	saveAs("tiff", output + File.separator + file); 
	close();
}

function printTimestamp() {
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(year + "-" + (month + 1) + "-" + dayOfMonth + " " + hour + ":" + minute + ":" + second + "." + msec);
}
