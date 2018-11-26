var _MACRO_DIR = getDirectory("macros");
var _BACKGROUND_CORRECTION_RADIUS = 200;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Osteoclasts_Tool";
var _PATH_ILASTIK_SH = "/media/baecker/DONNEES/programs/ilastik/ilastik-1.3.2rc2-Linux/run_ilastik.sh";
var _ILASTIK_PROJECT = _MACRO_DIR + "/toolsets/osteoclasts.ilp";
var _THRESHOLDING_METHOD_OSTEOCLASTS = "Huang";
var _THRESHOLDING_METHOD_BORDERS = "Default";

// batchClassifyImages(); 
// createRoisFromPredictions();

macro "MRI Osteoclasts Tools Help Action Tool - C034D14D15D16D22D23D26D27D28D29D2aD2bD2cD32D3cD42D4cD4dD51D5dD5eD61D6eD71D7eD81D8eD91D92D9eDa2DaeDb2DbdDbeDc2DccDcdDd3Dd4Dd5Dd6Dd7Dd9DdaDdbDdcC041D24D25D33D34D35D36D37D38D39D3aD3bD43D44D45D46D47D48D49D4aD4bD52D53D54D55D56D57D58D59D5aD5cD62D63D64D65D66D67D68D69D6dD72D73D76D77D78D79D7dD82D86D87D88D89D8aD8bD8cD8dD96D97D9aD9bD9cD9dDa3Da4Da5Da6Da7DabDacDadDb3Db4Db5Db6Db7DbbDbcDc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDd8Ce20D5bD6aD6bD6cD74D75D7aD7bD7cD83D84D85D93D94D95D98D99Da8Da9DaaDb8Db9Dba" {
	run('URL...', 'url='+helpURL);
}

macro "Train classifier Action Tool (f11) - C000T4b12t" {
	retrainClassifier();
}

macro 'retrain classifier [f11]' {
	retrainClassifier();
}

macro 'Correct Background Action Tool (f1) - C000T4b12b' {
	correctBackground();
}

macro 'correct background [f1]' {
	correctBackground();
}

macro 'segment cells Action Tool (f2) - C000T4b12c' { 
	createRoisFromPredictions();
}

macro 'segment cells [f2]' {
	createRoisFromPredictions();
}

macro 'Detect Nuclei Action Tool (f3) - C000T4b12n' {
	detectNuclei();
}

macro 'Detect Nuclei [f3]' {
	detectNuclei();
}

macro 'Filter by number of Nuclei Action Tool (f4) - C000T4b12f' {
	filterRoisByNumberOfNuclei();
}

macro 'filter by number of nuclei [f4]' {
	filterRoisByNumberOfNuclei();
}

macro 'Run Batch Classify Action Tool (f5) - C444D22D2cD52D5cD68D85D9dDe8Df6C000D29D41D67D8fDd4DebCcccD32D33D39D3cD57D65D69D6bD8aDa9Db8Dc7Dd7De7CbbbD26D7cD80D8bD8cD8eD92D95D99D9bD9cDa8DaaDabDb9DbaDbbDc4Dc9DcaDccDd6C222D31D3dD90D9eDc1Dd9DdaCeeeD17D36D37D38D45D46D48D49D4aD55D56D58D59D63D64D73D82D83Da4Da5Db3Db4Dc2Dc3C888D16D28D34D3aD42D4cD62D6cD70D79D7dDa7Db2Dd2Dd8DdbDdcDe6C111D06D98Df8CeeeD44D4bD53D54D5aD72D81Db5Db6CcccD35D71D7bD8dD9aDa6Dc8DcbC333D07D23D2bD66D91DbcDd5CfffD27D47D74D84D93D94Da3C555D18D75D7eD89Da2DacDd3Df7C111D08D25D61D96DcdCdddD3bD43D5bD6aD7aDb7Dc5Dc6' {
	batchClassifyImages();
}

macro 'run batch classify [f5]' {
	batchClassifyImages();
}

function correctBackground() {
	width = getWidth();
	run("Subtract Background...", "rolling="+_BACKGROUND_CORRECTION_RADIUS);
}

function batchClassifyImages() {
	outDir = batchPrepareImages();
	files = getFileList(outDir);
	for(i=0; i<files.length; i++) {
		file = files[i];
		if (endsWith(file, ".tif")) {
			print("Processing file: " + file);
			exec("" + _PATH_ILASTIK_SH + " --headless --project="+_ILASTIK_PROJECT+" --output_format=tiff "+outDir+"/"+file);
		} else {
			print("Skipping file: " + file);
		}
	}
	print("FINISHED!");
}

function batchPrepareImages() {
	dir = getDirectory("Choose a Directory");
	files = getFileList(dir);
	files = getImages(files);
	files = getFileListWithoutChannels(files);
	outDir = dir + "/results";
	File.makeDirectory(outDir);
	for(i=0; i<files.length; i++) {
		file = files[i];
		for(d=0; d<3; d++) {
			open(dir + file + "_d"+d+".tif");
		}
		run("Merge Channels...", "c1="+file+"_d2.tif c2="+file+"_d0.tif c3="+file+"_d1.tif create");
		cropToBiggestInscribedRectangle();
		correctBackground();
		save(outDir + "/" + file + ".tif");
		close();
		wait(500);
	}
	return outDir;
}

function cropToBiggestInscribedRectangle() {
	makeBiggestRectangleInCircle();
	run("Crop");
}

function getImages(files) {
	list = newArray();
	for(i=0; i<files.length; i++) {
		if (endsWith(files[i], ".tif")) {
			list = Array.concat(list, files[i]);
		}
	}
	return list;
}

function getFileListWithoutChannels(files) {
	list = newArray();
	Array.sort(list);
	for(i=0; i<files.length; i=i+3) {
		filename = replace(files[i], "_d0.tif", "");
		list = Array.concat(list, filename);
	}
	return list;
}

function createRoisFromPredictions() {
	title = getTitle();
	run("Split Channels");	//C1 - border, C2-background, C3-osteo, C4-cells
	selectImage("C4-"+title);
	convertToMask(_THRESHOLDING_METHOD_OSTEOCLASTS);
	selectImage("C3-"+title);
	convertToMask(_THRESHOLDING_METHOD_OSTEOCLASTS);
	selectImage("C1-"+title);
	convertToMask(_THRESHOLDING_METHOD_BORDERS);
	selectImage("C2-"+title);
	convertToMask(_THRESHOLDING_METHOD_BORDERS);
	selectImage("C3-"+title);
	imageCalculator("OR ", "C3-"+title, "C4-"+title);
	objects = getTitle();
	selectImage("C4-"+title);
	wait(500);
	close();
	selectImage("C1-"+title);
	imageCalculator("OR ", "C1-"+title, "C2-"+title);
	background = getTitle();
	selectImage("C2-"+title);
	wait(500);
	close();
	selectImage(objects);
	imageCalculator("Subtract ", objects, background);
	selectImage(background);
	wait(500);
	close();
	roiManager("reset");
	run("Analyze Particles...", "size=20-Infinity exclude add");
}

function makeBiggestRectangleInCircle() {
	imageWidth = getWidth();
	radius = imageWidth / 2;

	height = sqrt(2*radius*radius);
	makeRectangle(radius-height/2, radius-height/2, height, height);
}

function detectNuclei() {
	title = getTitle();
	Stack.setChannel(1);
	run("Duplicate...", " ");
	setAutoThreshold("Default dark no-reset");
	run("Convert to Mask");
	run("Watershed");
	rename(title+"-"+"nuclei-mask");
	run("Ultimate Points");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	id = getImageID();
	return id;
}

function retrainClassifier() {
	exec("" + _PATH_ILASTIK_SH + " " + _ILASTIK_PROJECT);
}

function convertToMask(thresholdingMethod) {
	resetThreshold();
	setAutoThreshold(thresholdingMethod+" dark");
	run("Convert to Mask");
}

function filterRoisByNumberOfNuclei() {
	count = roiManager("count");
	run("Set Measurements...", "shape integrated display redirect=None decimal=3");
	indicesOfRoisToBeDeleted = newArray();
	for(i=0; i<count; i++) {
		roiManager("select", i);
		run("Measure");
		value = getResult("IntDen", nResults-1);
		circ = getResult("Circ.", nResults-1);
		if (value<511 || circ<0.25) indicesOfRoisToBeDeleted = Array.concat(indicesOfRoisToBeDeleted,i);
	}
	roiManager("select", indicesOfRoisToBeDeleted);
	roiManager("delete");
}
