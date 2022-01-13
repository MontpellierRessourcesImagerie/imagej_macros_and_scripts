var SIGMA = 7;
var THRESHOLDING_METHOD = "Intermodes";		
var CHANNELS = newArray("405", "640");
var BATCH_MODE = false;

// set global variables
CLASSIFIER = "neurite_segmentation_3.ilp"
OUTPUT_TYPE = "Segmentation"; //  or "Probabilities"
inputDataset = "data";
outputDataset = "exported_data";
axisOrder = "tzyxc";
compressionLevel = 0;

 
batchConvertToH5();

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


function batchSegmentNeurites() {
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
			importArgs = "select=" + fileName + " datasetname=" + inputDataset + " axisorder=" + axisOrder;

			save(folder + file);
			close();
		}
	}
	setBatchMode("exit and display");
	
	// process all H5 files in a given directory
	dataDir = "<DATASET_DIR>";
	fileList = getFileList(dataDir);
	for (i = 0; i < fileList.length; i++) {
		// import image from the H5
		fileName = dataDir + fileList[i];	
		pixelClassificationArgs = "projectfilename=" + CLASSIFIER + " saveonly=false inputimage=" + inputImage + " pixelclassificationtype=" + outputType;
		run("Import HDF5", importArgs);
	
		// run pixel classification
		inputImage = fileName + "/" + inputDataset;
		pixelClassificationArgs = "projectfilename=" + pixelClassificationProject + " saveonly=false inputimage=" + inputImage + " pixelclassificationtype=" + outputType;
		run("Run Pixel Classification Prediction", pixelClassificationArgs);
	
		// export probability maps to H5
		outputFile = dataDir + "output" + i + ".h5";
		exportArgs = "select=" + outputFile + " datasetname=" + outputDataset + " compressionlevel=" + compressionLevel;
		run("Export HDF5", exportArgs);
	}
}