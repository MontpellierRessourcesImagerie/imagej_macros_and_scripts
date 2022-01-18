var SIGMA = 7;
var THRESHOLDING_METHOD = "Intermodes";		
var CHANNELS = newArray("405", "640");
var BATCH_MODE = false;

var CLASSIFIER_FOLDER = getDirectory("macros") + "/toolsets/";
var CLASSIFIER = "neurite_segmentation_3.ilp"
var OUTPUT_TYPE = "Segmentation"; //  or "Probabilities"
var INPUT_DATASET = "/exported_data";
var OUTPUT_DATASET = "/exported_data";
var AXIS_ORDER = "tzyxc";
var COMPRESSION_LEVEL = 0;

var NR_OF_CLOSE_OPERATIONS = 4;
var MIN_NEURITE_AREA = 20000;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Neurite_Analyzer_Tool";
 
segmentNeurites();


macro "Neurite Analyzer Action Tool - C060L0020C050L3050C051D60C041D70C040L8090C030La0b0C020Lc0d0C010Le0f0C050D01C060L1121C050L3151C051D61C040L71a1C030Db1C020Lc1d1C010Le1f1C050D02C060D12C050L2242C040D52C041D62C040L7292C030Da2C020Lb2d2C010Le2f2C050D03C070D13C050L2343C040L5393C030Da3C020Lb3d3C010Le3f3C050D04C060D14C070D24C060L3444C061D54C0afL6474C080D84C070D94C050Da4C030Db4C020Lc4d4C010Le4f4C050L0515C070D25C080D35C0a0D45C0afL5575C0a1D85C080D95C090Da5C080Db5C050Dc5C030Dd5C010Le5f5C050D06C040D16C050L2636C080D46C0b5D56C0afD66C0a4D76C050D86C030D96C040Da6C070Db6C030Lc6d6C020De6C010Df6C040L0737C060D47C0c1D57C0b1D67C060D77C030L8797C020Da7C050Db7C030Dc7C010Ld7f7C040L0838C070D48C0c0D58C080D68C040D78C030L88b8C050Dc8C010Ld8e8C050L0929C070D39C0a0D49C080D59C070D69C040L7989C030L99a9C020Db9C040Dc9C020Dd9C010De9C050D0aC060D1aC080D2aC090D3aC070D4aC050D5aC080D6aC040L7a8aC030L9aaaC020LbadaC010LeafaC050D0bC060L1b2bC050L3b4bC070D5bC080D6bC050D7bC040L8b9bC030LabbbC020LcbdbC010LebfbC050L0c5cC070D6cC050D7cC040D8cC030L9cbcC020LccdcC010LecfcC060D0dC050L1d5dC060D6dC040L7d9dC030LadbdC020LcdddC010LedfdC060L0e1eC050L2e6eC040L7e9eC030LaeceC020LdeeeC010DfeC060L0f1fC050L2f6fC040L7f9fC030LafcfC020LdfefC010Dff" {
	run('URL...', 'url='+helpURL);	
}


macro "segment nuclei (f5) Action Tool - C000T4b12n" {
	segmentNuclei();
}

function batchSegmentNuclei() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	setBatchMode(true);
	BATCH_MODE = true;
	print("\\Clear");
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[0]);
		for (f = 0; f < files.length; f++) {
			file = files[f];
			print("Processing file " + file);
			open(folder + file);
			segmentNuclei();
			save(folder + file);
			close();
		}
	}
	setBatchMode("exit and display");
	BATCH_MODE = false;
}

function filterChannel3Segmentation() {
	toBeDeleted = newArray(0);
	circThreshold = 0.4;
	areaThreshold = 0.001;
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		r = getValue("Circ.");
		a = getValue("Area");
		print(r);
		if (r>=circThreshold || a<areaThreshold) {
			toBeDeleted = Array.concat(toBeDeleted, i);
		}
	}
	roiManager("select", toBeDeleted);
	roiManager("delete");
}


function segmentNeurites() {
	roiManager("reset");
	setAutoThreshold("Huang dark");
	run("Analyze Particles...", "size=1000-Infinity show=Masks exclude");
	run("Create Selection");
	run("Create Mask");
	run("Select None");
	run("Options...", "iterations=4 count=1 do=Dilate");
	run("Options...", "iterations=4 count=1 do=Erode");
}

/**
 * Segment nuclei and add the resulting roi to the overlay
 * of the channel.
 */
function segmentNuclei() {
	Overlay.remove;
	if (!BATCH_MODE) setBatchMode("hide");
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+SIGMA);
	setAutoThreshold(THRESHOLDING_METHOD + " dark");
	run("Analyze Particles...", "  show=Overlay ");
	Overlay.copy;
	close();
	Overlay.paste;
	if (!BATCH_MODE) setBatchMode("show");
}

function getFilesForChannel(files, channel) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, channel)>-1) {
			res = Array.concat(res, file);			
		}
	}
	return res;
}

function getH5FilesForChannel(files, channel) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, channel)>-1 && endsWith(file, ".h5")) {
			res = Array.concat(res, file);			
		}
	}
	return res;
}	

function equalize() {
	run("Enhance Contrast...", "saturated=0.3 equalize");
	run("Gaussian Blur...", "sigma=1");
}

function batchEqualize() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	setBatchMode(true);
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		showProgress(i+1, subfolders.length);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[1]);
		for (f = 0; f < files.length; f++) {
			file = files[f];
			open(folder + file);
			equalize();
			save(folder + file);
			close();
		}
	}
	setBatchMode("exit and display");
}

function batchConvertToH5() {
	t1 = getTime();
	outputDataset = "exported_data";
	compressionLevel = 0;

	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	print("\\Clear");
	setBatchMode(true);
	for (i = 0; i < subfolders.length; i++) {
		showProgress(i+1, subfolders.length);
		print("Entering folder " + subfolders[i]);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[1]);
		for (f = 0; f < files.length; f++) {
			file = files[f];
			filesString = String.join(files, ",");
			if (endsWith(file, ".h5")) continue;
			out = replace(file, "tif", "h5");
			if (indexOf(filesString, out)>-1) continue;
			print("Processing file " + file);
			open(folder + file);
			outputPath = folder + File.nameWithoutExtension + ".h5";			
			exportArgs = "select=" + outputPath + " datasetname=" + outputDataset + " compressionlevel=" + compressionLevel;
			run("Export HDF5", exportArgs);
			close("*");
			if (f%10==0) run("Collect Garbage");
		}
	}
	setBatchMode(false);
	t2 = getTime();
	print("batch convert to h5 took: " + (t2-t1)/1000 + "s");
}

// Use ilastik from command line instead
function batchSegmentNeurites() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	setBatchMode(true);
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		showProgress(i+1, subfolders.length);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getH5FilesForChannel(files, CHANNELS[1]);
		for (f = 0; f < files.length; f++) {
			print("Processing file " + files[f]);
			file = folder + files[f];
			inputImage = file + INPUT_DATASET;
			importArgs = "select=" + file + " datasetname=" + INPUT_DATASET + " axisorder=" + AXIS_ORDER; 	
			run("Import HDF5", importArgs);
			pixelClassificationArgs = "projectfilename=" + CLASSIFIER_FOLDER + CLASSIFIER + " saveonly=false inputimage=" + inputImage + " pixelclassificationtype=" + OUTPUT_TYPE;
			run("Run Pixel Classification Prediction", pixelClassificationArgs);
			parts = split(file, '.');
			outputFile = parts[0] + "-" + OUTPUT_TYPE + ".h5";
			exportArgs = "select=" + outputFile + " datasetname=" + OUTPUT_DATASET + " compressionlevel=" + COMPRESSION_LEVEL;	
			run("Export HDF5", exportArgs);
			close("*");
		}
	}
	setBatchMode("exit and display");
}

function batchMaskToSelection() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	setBatchMode(true);
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		showProgress(i+1, subfolders.length);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[0]);
		for (f = 0; f < files.length; f++) {
			print("Processing file " + files[f]);
			file = folder + files[f];
			file2 = replace(file, CHANNELS[0], CHANNELS[1]);
			file3 = replace(file2, ".tif", "_segmentation.tiff");
			outFile = replace(file3, "_segmentation.tiff", "_composite.tif");
			if (File.exists(outFile)) continue;
			open(file);
			nucleiImageID = getImageID();
			nucleiImageID = getTitle();
			open(file2);
			neuriteImageID = getImageID();
			neuriteImageTitle = getTitle();
			open(file3);
			neuriteMaskToSelection();
			close();
			selectImage(nucleiImageID);
			Overlay.copy
			run("Merge Channels...", "c2="+neuriteImageTitle+" c3="+nucleiImageID+" create");
			run("Enhance Contrast", "saturated=0.35");
			Overlay.paste
			Stack.setChannel(2);
			run("From ROI Manager");
			saveAs("tiff", outFile);
			close("*");
		}
	}
	setBatchMode("exit and display");
}

function neuriteMaskToSelection() {
	roiManager("reset");
	imageID = getImageID();
	run("Invert");
	run("Invert LUT");
	run("Options...", "iterations="+NR_OF_CLOSE_OPERATIONS+" count=1 do=Close");
	run("Analyze Particles...", "size="+MIN_NEURITE_AREA+"-Infinity show=Masks");
	run("Create Selection");
	roiManager("Add");
	run("Select None");
	selectImage(imageID);
	close();
}
