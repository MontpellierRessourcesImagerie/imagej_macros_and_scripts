var SIGMA = 7;
var THRESHOLDING_METHOD = "Intermodes";		
var THRESHOLDING_METHODS = getList("threshold.methods");
var CHANNELS = newArray("405", "640", "488");
var BATCH_MODE = false;

var CLASSIFIER_FOLDER = getDirectory("macros") + "/toolsets/";
var CLASSIFIER = "neurite_segmentation_final.ilp"
var OUTPUT_TYPE = "Segmentation"; //  or "Probabilities"
var INPUT_DATASET = "/exported_data";
var OUTPUT_DATASET = "/exported_data";
var AXIS_ORDER = "tzyxc";
var COMPRESSION_LEVEL = 0;
var DO_HISTO_EQ = true;

var NR_OF_CLOSE_OPERATIONS = 4;
var MIN_NEURITE_AREA = 20000;

var LUT = "Random";
var CONNECTIVITY = 4;

var SCALE = 1.7;
var PROEMINENCE = 200;
var NEURITE_ID_CHANNEL = 3;
var DISTANCE_CHANNEL = 4;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Neurite_Analyzer";
 
measureFISHOnNeurites();
exit

macro "Neurite Analyzer (F1) Action Tool - C060L0020C050L3050C051D60C041D70C040L8090C030La0b0C020Lc0d0C010Le0f0C050D01C060L1121C050L3151C051D61C040L71a1C030Db1C020Lc1d1C010Le1f1C050D02C060D12C050L2242C040D52C041D62C040L7292C030Da2C020Lb2d2C010Le2f2C050D03C070D13C050L2343C040L5393C030Da3C020Lb3d3C010Le3f3C050D04C060D14C070D24C060L3444C061D54C0afL6474C080D84C070D94C050Da4C030Db4C020Lc4d4C010Le4f4C050L0515C070D25C080D35C0a0D45C0afL5575C0a1D85C080D95C090Da5C080Db5C050Dc5C030Dd5C010Le5f5C050D06C040D16C050L2636C080D46C0b5D56C0afD66C0a4D76C050D86C030D96C040Da6C070Db6C030Lc6d6C020De6C010Df6C040L0737C060D47C0c1D57C0b1D67C060D77C030L8797C020Da7C050Db7C030Dc7C010Ld7f7C040L0838C070D48C0c0D58C080D68C040D78C030L88b8C050Dc8C010Ld8e8C050L0929C070D39C0a0D49C080D59C070D69C040L7989C030L99a9C020Db9C040Dc9C020Dd9C010De9C050D0aC060D1aC080D2aC090D3aC070D4aC050D5aC080D6aC040L7a8aC030L9aaaC020LbadaC010LeafaC050D0bC060L1b2bC050L3b4bC070D5bC080D6bC050D7bC040L8b9bC030LabbbC020LcbdbC010LebfbC050L0c5cC070D6cC050D7cC040D8cC030L9cbcC020LccdcC010LecfcC060D0dC050L1d5dC060D6dC040L7d9dC030LadbdC020LcdddC010LedfdC060L0e1eC050L2e6eC040L7e9eC030LaeceC020LdeeeC010DfeC060L0f1fC050L2f6fC040L7f9fC030LafcfC020LdfefC010Dff" {
	run('URL...', 'url='+helpURL);	
}

macro "Neurite Analyzer [f1]" {
	run('URL...', 'url='+helpURL);	
}

macro "segment nuclei (f2) Action Tool - C000T4b12n" {
	segmentNuclei();
}

macro "segment nuclei [f2]" {
	segmentNuclei();
}

macro "segment nuclei (f2) Action Tool Options" {
	Dialog.create("Segment Nuclei Options");
	Dialog.addNumber("sigma of Gaussian blur: ", SIGMA);
	Dialog.addChoice("thresholding method", THRESHOLDING_METHODS, THRESHOLDING_METHOD);
	Dialog.show();
	SIGMA = Dialog.getNumber();
	THRESHOLDING_METHOD = Dialog.getChoice();
}
macro "segment neurites (f3) Action Tool - C000T4b12s" {
	segmentNeurites();	
}

macro "segment neurites [f3]" {
	segmentNeurites();	
}

macro "segment neurites (f3) Action Tool Options" {
	Dialog.create("Segment Neurites Options");
	Dialog.addCheckbox("equalize histogram: ", DO_HISTO_EQ);
	Dialog.addString("input dataset: ", INPUT_DATASET, 40);
	Dialog.addString("axis order: ", AXIS_ORDER);
	Dialog.addString("classifier folder: ", CLASSIFIER_FOLDER, 60);
	Dialog.addString("classifier: ", CLASSIFIER, 40);
	
	Dialog.show();

	DO_HISTO_EQ = Dialog.getCheckbox();
	INPUT_DATASET = Dialog.getString();
	AXIS_ORDER = Dialog.getString();
	CLASSIFIER_FOLDER = Dialog.getString();
	CLASSIFIER = Dialog.getString();
}

macro "calculate distances (f4) Action Tool - C000T4b12d" {
	mergeAndFilter();
}

macro  "calculate distances [f4]" {
	mergeAndFilter();
}

macro "calculate distances (f4) Action Tool Options" {
	Dialog.create("calculate distances options")
	Dialog.addString("nuclei channel: ", CHANNELS[0]);
	Dialog.addString("neurite channel: ", CHANNELS[1]);
	Dialog.addString("FISH channel: ", CHANNELS[2]);
	Dialog.show();
	CHANNELS[0] = Dialog.getString();
	CHANNELS[1] = Dialog.getString();
	CHANNELS[2] = Dialog.getString();
}

macro "label neurites (f5) Action Tool - C000T4b12l" {
   labelNeurites();  
}

macro "label neurites [f5]" {
    labelNeurites();
}

macro "label neurites (f5) Action Tool Options" {
	Dialog.create("Label Neurites Options");	
	Dialog.addNumber("connectivity: ", CONNECTIVITY);
	Dialog.show();
	CONNECTIVITY = Dialog.getNumber();
}

macro "batch segment nuclei (f6) Action Tool - C037T1d13bT9d13nC555" {
	batchSegmentNuclei();
}

macro "batch segment nuclei [f6]" {
	batchSegmentNuclei();
}

macro "batch export as h5 (f7) Action Tool - C037T1d13hT9d135C555" {
	batchConvertToH5();
}

macro "batch export as h5 [f7]" {
	batchConvertToH5();
}

macro "use ilastik (f8) Action Tool - C000T4b12i" {
	useIlastikDialog();
}

macro "use ilastik [f8]" {
	useIlastikDialog();	
}

macro "batch mask to selection (f9) Action Tool - C037T1d13bT9d13sC555" {
	batchMaskToSelection();
}


macro "batch mask to selection [f9]" {
	batchMaskToSelection();
}

macro "batch calculate distances (f10) Action Tool - C037T1d13bT9d13dC555" {
	batchMergeAndFilter();
}

macro "batch calculateDistances [f10]" {
	batchMergeAndFilter();
}

function useIlastikDialog() {
	Dialog.create("Use ilastik");
	Dialog.addMessage("Use ilastik to create a classifier and segment the neurite channel!\nSave each segmentation-mask in the folder of its input image.");
	Dialog.show();
}


function selectNucleiImage() {
	selectImageWithTextInTitle(CHANNELS[0]);
}

function selectNeuriteImage() {
	selectImageWithTextInTitle(CHANNELS[1]);
}


function selectFISHImage() {
	selectImageWithTextInTitle(CHANNELS[2]);
}

function selectCompositeImage() {
	selectImageWithTextInTitle("composite");
}


function selectImageWithTextInTitle(text) {
	titles = getList("image.titles");
	for (i = 0; i < titles.length; i++) {
		title = titles[i];
		selectImage(title);
		type = getInfo("window.type");
		if ((type!="Image")) continue;	
		if (indexOf(title, text)>-1) return;
	}
}

function removeRoisWithoutSupport(image, otherImage) {
	selectImage(otherImage);
	run("To ROI Manager");
	run("Select None");
	roiManager("combine");
	if (!BATCH_MODE) setBatchMode(true);
	run("Create Mask");
	rename("neurite-mask");
	otherImageMaskID = getImageID();
	selectImage(otherImage);
	run("From ROI Manager");
	roiManager("reset");
	selectImage(image);
	Overlay.copy
	selectImage(otherImageMaskID);	
	Overlay.paste
	toBeRemoved = newArray(0);
	for (i = 0; i < Overlay.size; i++) {
		showProgress(i+1, Overlay.size);
		Overlay.activateSelection(i);
		v = getValue("Mean");
		if (v==0) {
			toBeRemoved = Array.concat(toBeRemoved, i);
		}
	}
	selectImage(image);	
	run("To ROI Manager");
	if (toBeRemoved.length>0) {
		roiManager("select", toBeRemoved);
		roiManager("delete");
		run("Select None");
	}
	print("Removed :"+toBeRemoved.length+" rois");
	run("From ROI Manager");
	roiManager("reset");
	selectImage(otherImageMaskID);
	close();
	if (!BATCH_MODE) setBatchMode("exit and display");
}

function mergeAndFilter() {
	imageInfo = getImageInfo();
	nucleiImageTitle = imageInfo[0];
	nucleiImageID = imageInfo[1];
	neuriteImageTitle = imageInfo[2];
	neuriteImageID = imageInfo[3];
	showStatus("Merge and filter: STARTED...");
	removeRoisWithoutSupport(nucleiImageID, neuriteImageID);
	showStatus("Merge and filter: STAND BY...");
	removeRoisWithoutSupport(neuriteImageID, nucleiImageID);
	selectImage(nucleiImageID);
	run("To ROI Manager");
	roiManager("Combine");
	run("Create Mask");
	rename("nuclei-mask");
	nucleiMaskID = getImageID();
	run("Options...", "iterations=50 count=1 do=Dilate");
	selectImage(nucleiImageID);
	run("From ROI Manager");
	roiManager("reset");
	selectImage(neuriteImageID);
	run("To ROI Manager");
	roiManager("Combine");
	run("Create Mask");
	rename("neurite-mask");
	neuriteMaskID = getImageID();
	run("Geodesic Distance Map", "marker=nuclei-mask mask=neurite-mask distances=[Chessknight (5,7,11)] output=[16 bits] normalize");
	max = getValue("Max");
	run("Macro...", "code=v=(v!="+max+")*v");
	selectImage(neuriteImageID);
	run("From ROI Manager");
	roiManager("reset");
	showStatus("Merging and filter: DONE.");
}

function labelNeurites() {
    selectImage("nuclei-mask");
    run("16-bit");
    run("Connected Components Labeling",  "connectivity="+CONNECTIVITY+" type=[16 bits]");
    getHistogram(values, counts, 255);
    max = Math.ceil(values[values.length -1]);
    nucleiLabels = getImageID();
    run("Copy");
    selectImage("neurite-mask");
    run("16-bit");
    run("Macro...", "code=[v = (v==255) * 65535]");
    setPasteMode("Transparent-zero");
    run("Paste");
    run("Neurite Labelling PlugIn");
    run(LUT);
    setMinAndMax(0, max);
    run("Select None");
    selectNucleiImage();
    nucleiTitle = getTitle();
    selectNeuriteImage();
    neuritesTitle = getTitle();
    run("Merge Channels...", "c3="+nucleiTitle+" c4="+neuritesTitle+" c5=neurite-mask c6=neurite-mask-geoddist create");
}

function getImageInfo() {
	title = getTitle();    
	imageID = getImageID();
	if (indexOf(title, CHANNELS[0])>-1) {
		nucleiImageTitle = title;
		nucleiImageID = imageID;
		neuriteImageTitle = replace(nucleiImageTitle, CHANNELS[0], CHANNELS[1]);
		selectImage(neuriteImageTitle);
		neuriteImageID = getImageID();
	} 
	if (indexOf(title, CHANNELS[1])>-1) {
		neuriteImageTitle = title;
		neuriteImageID = imageID;
		nucleiImageTitle = replace(neuriteImageTitle, CHANNELS[1], CHANNELS[0]);
		selectImage(nucleiImageTitle);
		nucleiImageID = getImageID();
	}
	return newArray(nucleiImageTitle, nucleiImageID, neuriteImageTitle, neuriteImageID);
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
		files = getFilesForChannel(files, CHANNELS[0], "tif");
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


/**
 * Run the ilastik-classifier on the active image and transform the resulting segmentation mask
 * to a roi on the input image.
 */
function segmentNeurites() {
	Overlay.remove;
	outputDataset = "exported_data";
	compressionLevel = 0;
	imageID = getImageID();
	dir = getInfo("image.directory");
	file = getInfo("image.filename");
	parts = split(file, ".");
	file = replace(file, "\."+parts[1], ".h5");
	outputPath = dir + file;
	run("Duplicate...", " ");
	if (DO_HISTO_EQ) equalize();
	exportArgs = "select=" + outputPath + " datasetname=" + outputDataset + " compressionlevel=" + compressionLevel;
	run("Export HDF5", exportArgs);
	close();
	inputImage = outputPath + INPUT_DATASET;
	importArgs = "select=" + outputPath + " datasetname=" + INPUT_DATASET + " axisorder=" + AXIS_ORDER; 	
	run("Import HDF5", importArgs);
	h5Image = getImageID();
	pixelClassificationArgs = "projectfilename=" + CLASSIFIER_FOLDER + CLASSIFIER + " saveonly=false inputimage=" + inputImage + " pixelclassificationtype=" + OUTPUT_TYPE;
	run("Run Pixel Classification Prediction", pixelClassificationArgs);
	neuriteMaskToSelection();
	segmentationImage = getImageID();
	selectImage(h5Image);
	close();
	selectImage(imageID);
	count = roiManager("count");
	if (count>0) run("From ROI Manager");
 	roiManager("reset");
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

function getFilesForChannel(files, channel, ext) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, channel)>-1 && endsWith(file, "."+ext)) {
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
		files = getFilesForChannel(files, CHANNELS[1], "tif");
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
		files = getFilesForChannel(files, CHANNELS[1], "tif");
		for (f = 0; f < files.length; f++) {
			file = files[f];
			filesString = String.join(files, ",");
			if (endsWith(file, ".h5")) continue;
			out = replace(file, "tif", "h5");
			if (indexOf(filesString, out)>-1) continue;
			print("Processing file " + file);
			open(folder + file);
			if (DO_HISTO_EQ) equalize();
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
	BATCH_MODE = true;
	print("\\Clear");
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[1], "tif");
		for (f = 0; f < files.length; f++) {
			file = files[f];
			print("Processing file " + file);
			open(folder + file);
			segmentNeurites();
			save(folder + file);
			close();
		}
	}
	setBatchMode("exit and display");
	BATCH_MODE = false;
}

function batchMaskToSelection() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	setBatchMode(true);
	BATCH_MODE = true;
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		showProgress(i+1, subfolders.length);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[0], "tif");
		for (f = 0; f < files.length; f++) {
			print("Processing file " + files[f]);
			roiManager("reset");
			file = folder + files[f];
			file2 = replace(file, CHANNELS[0], CHANNELS[1]);
			file3 = replace(file2, ".tif", "_Simple Segmentation.tif");
			open(file2);
			neuriteImageID = getImageID();
			neuriteImageTitle = getTitle();
			open(file3);
			neuriteMaskToSelection();
			run("From ROI Manager");
			run("Enhance Contrast", "saturated=0.35");
			save(file2);
			close("*");
		}
	}
	setBatchMode("exit and display");
	BATCH_MODE = false;
}

function batchMergeAndFilter() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	setBatchMode(true);
	BATCH_MODE = true;
	for (i = 0; i < subfolders.length; i++) {
		print("Entering folder " + subfolders[i]);
		showProgress(i+1, subfolders.length);
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[0], "tif");
		for (f = 0; f < files.length; f++) {
			print("Processing file " + files[f]);
			roiManager("reset");
			outFile = replace(files[f], CHANNELS[0]+".tif", "composite.tif");
			outFile = folder + outFile;
			file = folder + files[f];			
			open(file);
			nucleiTitle = getTitle();
			file2 = replace(file, CHANNELS[0], CHANNELS[1]);
			open(file2);
			neuritesTitle = getTitle();
			mergeAndFilter();
			labelNeurites();
			save(outFile);
			close("*");
		}
	}
	setBatchMode("exit and display");
	BATCH_MODE = false;
}

function neuriteMaskToSelection() {
	roiManager("reset");
	imageID = getImageID();
	run("Invert");
	run("Invert LUT");
	run("Options...", "iterations="+NR_OF_CLOSE_OPERATIONS+" count=1 do=Close");
	run("Analyze Particles...", "size="+MIN_NEURITE_AREA+"-Infinity composite add");
	run("Select None");
	selectImage(imageID);
	close();
}

function measureFISHOnNeurites() {
	selectFISHImage();
	run("FeatureJ Laplacian", "compute smoothing="+SCALE);
	run("Find Maxima...", "prominence="+PROEMINENCE+" light output=[Point Selection]");
	roiManager("reset");
	roiManager("Add");
	close();
	selectCompositeImage();
	roiManager("Show None");
	roiManager("Show All");
	run("Set Measurements...", "mean redirect=None decimal=3");
	roiManager("select", 0);
	run("Clear Results");
	Stack.setChannel(NEURITE_ID_CHANNEL);	
	roiManager("measure");
	X = Table.getColumn("X");
	Y = Table.getColumn("Y");
	neuronID = Table.getColumn("Mean");
	run("Clear Results");
	Stack.setChannel(DISTANCE_CHANNEL);	
	roiManager("measure");
	somaDistance = Table.getColumn("Mean");
	xPoints = newArray(0);
	yPoints = newArray(0);
	for (i = 0; i < neuronID.length; i++) {
		if (neuronID[i] == 0 || somaDistance[i]==0) continue;
		xPoints = Array.concat(xPoints, X[i]);
		yPoints = Array.concat(yPoints, Y[i]);
	}
	roiManager("reset");
	run("Clear Results");
	makeSelection("point", xPoints, yPoints);
	roiManager("add");
	roiManager("Remove Channel Info");
	roiManager("Remove Slice Info");
	roiManager("Remove Frame Info");
	Stack.setChannel(NEURITE_ID_CHANNEL);	
	roiManager("measure");
	X = Table.getColumn("X");
	Y = Table.getColumn("Y");
	neuronID = Table.getColumn("Mean");
	run("Clear Results");
	Stack.setChannel(DISTANCE_CHANNEL);	
	roiManager("measure");
	somaDistance = Table.getColumn("Mean");
	run("Clear Results");
	Table.setColumn("X", X);
	Table.setColumn("Y", Y);
	Table.setColumn("Neuron-ID", neuronID);
	Table.setColumn("Dist. to Soma", somaDistance);
}
