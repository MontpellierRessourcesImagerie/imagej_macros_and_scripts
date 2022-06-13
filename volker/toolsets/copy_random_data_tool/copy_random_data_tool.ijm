/***
 * 
 * MRI Copy Random Data Tool
 * 
 * Randomly copy files from a number of input folders to create a test dataset
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/
var NAME_FILTER = "Coleno";
var NR_OF_FILES_PER_FOLDER = 10;
var SUBFOLDER = "/Mosaic_16bits/";
var CHANNELS = newArray("405", "640", "488");

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Copy_Random_Data_Tool";

macro "copy random data (f3) Action Tool - C037T1d13cT9d13rC555" {
	copyRandomData();
}

macro "copy random data (f3) Action Tool Options" {
	channelText = String.join(CHANNELS);
	Dialog.create("Copy Random Data Options");
	Dialog.addString("copy data from folders containing: ", NAME_FILTER, 20);
	Dialog.addNumber("number of images to be copied from each folder: ", NR_OF_FILES_PER_FOLDER);
	Dialog.addString("subfolder containing the data: ", SUBFOLDER, 40);
	Dialog.addString("channels: ", channelText, 40);
	Dialog.addHelp(helpURL);
	Dialog.show();
	NAME_FILTER = Dialog.getString();
	NR_OF_FILES_PER_FOLDER = Dialog.getNumber();
	SUBFOLDER = Dialog.getString();
	channelText = Dialog.getString();
	channelText = String.trim(channelText);
	CHANNELS = split(channelText, ",");
	for (i = 0; i < CHANNELS.length; i++) {
		CHANNELS[i] = String.trim(CHANNELS[i]);
	}
}

function copyRandomData() {
	dir = getDir("Select the input folder!");
	destDir = getDir("Select the target folder!");
	files = getFileList(dir);
	folders = filterFolders(files);
	Array.print(folders);
	for (i = 0; i < folders.length; i++) {
		showProgress(i+1, folders.length);
		folder = dir + folders[i] + SUBFOLDER;
		File.makeDirectory(destDir + "/" + folders[i]);
		files = getFileList(folder);
		partFiles = getPartFiles(files, CHANNELS[0]);
		Array.sort(partFiles);
		indices = Array.getSequence(partFiles.length);
		shuffle(indices);
		for (p = 0; p < CHANNELS.length; p++) {
			part = CHANNELS[p];
			if (p>0) replaceFile(partFiles, CHANNELS[p-1], CHANNELS[p]);
			for (f = 0; f < NR_OF_FILES_PER_FOLDER; f++) {
				File.copy(folder + "/" + partFiles[indices[f]], destDir + "/" + folders[i] + partFiles[indices[f]]);
			}
		}
	}
}

function filterFolders(files) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		if (indexOf(files[i], NAME_FILTER)>-1) {
			res = Array.concat(res, files[i]);
		}
	}
	return res;
}

function replaceFile(files, part1, part2) {
	for (i = 0; i < files.length; i++) {
		files[i] = replace(files[i], part1, part2);
	}
}

function getPartFiles(files, part) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, part)>-1) {
			res = Array.concat(res, file);			
		}
	}
	return res;
}


function shuffle(array) {
	for (i = 0; i < array.length; i++) {
		randomIndexToSwap = randomInt(array.length);
		temp = array[randomIndexToSwap];
		array[randomIndexToSwap] = array[i];
		array[i] = temp;
	}
}

function randomInt(n) {
	rand = random;
	res = floor(n * rand);
	return res;
}