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
 
batchMaskToSelection();

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


function segmentNucleiSimple() {
	run("Duplicate...", " ");
	setAutoThreshold("Li dark");
	run("Analyze Particles...", "size=200-Infinity circularity=0-1.00 show=Masks");
	run("Fill Holes");
	run("Watershed");
	setThreshold(1, 255);
	run("Analyze Particles...", "size=200-Infinity circularity=0.45-1.00 show=Nothing add");
	close();
	close();
	run("From ROI Manager");
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
			open(file);
			nucleiImageID = getImageID();
			nucleiImageID = getTitle();
			file2 = replace(file, CHANNELS[0], CHANNELS[1]);
			open(file2);
			neuriteImageID = getImageID();
			neuriteImageTitle = getTitle();
			file3 = replace(file2, ".tif", "_segmentation.tiff");
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
			outFile = replace(file3, "_segmentation.tiff", "_composite.tif");
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
