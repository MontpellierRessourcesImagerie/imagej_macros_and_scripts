/***
 * 
 * MRI Foci per nucleus tool
 * 
 * Detect and measure the foci per nucleus
 * 
 * (c) 2019, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 * 
**/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Foci-Per-Nucleus-Tool";
var	_SCALE_FACTOR = 5.0;
var	_MIN_SIZE = 1000;
var _THRESHOLDING_METHOD = "Huang";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _SIGMA_BLUR_FILTER = 12;
var _FOCI_THRESHOLDING_METHOD = "Otsu";
var _PROEMINENCE_OF_MAXIMA = 250;
var _THRESHOLD_1 = 10;
var _THRESHOLD_2 = 50;

var _FILE_EXTENSION = "tif";

measureFociPerNucleus();

exit();

macro "foci per nucleus tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "foci per nucleus tool help (f4) Action Tool - C11dD5fD6fD7fD8fD9fC555D39D3aD3bD47D56D5eD66D6eD75D7eD8eD9eDf9C00fD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D25D26D27D28D2dD2eD2fD30D31D32D33D34D35D3eD3fD40D41D42D43D44D45D50D51D52D53D54D60D61D62D63D64D70D71D72D73D80D81D82D83D90D91D92Da0Da1Da2Db0Db1Db2Db3DbfDc0Dc1Dc2Dc3DceDcfDd0Dd1Dd2Dd3DdeDdfDe0De1De2De3De4DedDeeDefDf0Df1Df2Df3Df4Df5DfcDfdDfeDffC777D4bD5cD68D6cD78D7cD8bD8cD9cDacDb5DbcDc6Dc7Dd7DeaC00fDafDbeDddDecDfbC337D2aD2bD37D38D46D4eD65Dc4CaaaD49D6bD79D7aD85D97Da6DabDbbDd9C00dD2cD4fDa3Df6C666D48D58D67D76D77D7dD8dD94D9dDadDc5Dd6De7De8De9C999D87D89D98D99Da5Da7DcbDd8C22bD29D36D3dD55D74D93DaeDbdDcdDd4DdcDe5DebDfaCeeeD5aD5bD6aD96DaaDb9DbaDc9DcaDdaC556D3cD4cD57D5dD6dDccDe6Df7Df8C888D7bD88D8aD9aD9bDa8Db6Db7Db8DdbC448D4dD84Da4Db4Dd5CdddD4aD59D69D86D95Da9Dc8"{
	run('URL...', 'url='+helpURL);
}

macro "measure foci per nucleus [f5]" {
	measureFociPerNucleus();
}

macro "measure foci per nucleus (f5) Action Tool - C000T4b12m" {
	measureFociPerNucleus();
}

macro "measure foci per nucleus (f5) Action Tool Options" {
	Dialog.create("Measure Foci Options");
	Dialog.addMessage("Foci area thresholds:");
	Dialog.addNumber("threshold one: ", _THRESHOLD_1);
	Dialog.addNumber("threshold two: ", _THRESHOLD_2);
	Dialog.addMessage("Nuclei Segmentation:");
	Dialog.addNumber("scale factor: ", _SCALE_FACTOR);
	Dialog.addNumber("min. area: ", _MIN_SIZE);
	Dialog.addChoice("nuclei thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD);
	Dialog.addMessage("Foci Segmentation:");
	Dialog.addNumber("sigma of Gaussian blur filter: ", _SIGMA_BLUR_FILTER);
	Dialog.addNumber("min. proeminence of maxima: ", _PROEMINENCE_OF_MAXIMA);
	Dialog.addChoice("foci thresholding method: ", _THRESHOLDING_METHODS, _FOCI_THRESHOLDING_METHOD);
	
	Dialog.show();
	
	_THRESHOLD_1 = Dialog.getNumber();
	_THRESHOLD_2 = Dialog.getNumber();

	_SCALE_FACTOR = Dialog.getNumber();
	_MIN_SIZE = Dialog.getNumber();
	_THRESHOLDING_METHOD = Dialog.getChoice();

	_SIGMA_BLUR_FILTER = Dialog.getNumber();
	_PROEMINENCE_OF_MAXIMA = Dialog.getNumber();
	_FOCI_THRESHOLDING_METHOD = Dialog.getChoice();
}

macro "batch measure foci per nucleus [f6]" {
	batchMeasureFociPerNucleus();
}

macro "batch measure foci per nucleus (f6) Action Tool - C000T4b12b" {
	batchMeasureFociPerNucleus();
}

macro "batch measure foci per nucleus (f6) Action Tool Options" {
	Dialog.create("Batch Measure Foci Options")
	Dialog.addString("file extension: ", _FILE_EXTENSION);
	Dialog.show();
	_FILE_EXTENSION = Dialog.getString();
}

function batchMeasureFociPerNucleus() {
	dir = getDirectory("Choose the input folder !");
	File.makeDirectory(dir+File.separator+"out");
	files = getFileList(dir);
	images = filterImages(files);
	Table.reset("Nuclei");
	Table.reset("Foci");
	for (i = 0; i < images.length; i++) {
		image = images[i];
		print("\\Update1: processing file " + (i+1) + " of " + images.length);
		open(dir + File.separator + image);
		measureFociPerNucleus();
		save(dir + File.separator+"out" + File.separator + image);
		close();
	}
	Table.save(dir + File.separator + "Nuclei.xls", "Nuclei");
	Table.save(dir + File.separator + "Foci.xls", "Foci");
}


function filterImages(files) {
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		fileLowerCase = toLowerCase(file);
		ext = toLowerCase(_FILE_EXTENSION);
		if (endsWith(fileLowerCase, "."+ext)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}

function reportResults() {
	run("Set Measurements...", "area mean standard min perimeter shape feret's integrated median display redirect=None decimal=3");
	Overlay.measure;
	if (!isOpen("Nuclei")) {
		Table.create("Nuclei");
	}
	startIndexNuclei = Table.size("Nuclei");
	if (!isOpen("Foci")) {
		Table.create("Foci");
	}
	startIndexFoci = Table.size("Foci");
	nrNuclei = 0;
	counter = 0;
	setBatchMode(true);
	for (i = 0; i < nResults; i++) {
		print("\\Update0: processing line " + (i+1) + " of " + nResults);
		label = Table.getString("Label", i, "Results");
		parts = split(label, ":");
		imageName = parts[0];
		object = parts[1];
		if (!startsWith(object, "N")) {
			area = getResult("Area", i);
			mean = getResult("Mean", i);
			stdDev = getResult("StdDev", i);
			intDen = getResult("IntDen", i);
			Table.set("Nr.", startIndexNuclei+i, nrNuclei+1, "Nuclei");
			Table.set("Image", startIndexNuclei+i, imageName, "Nuclei");
			Table.set("Area", startIndexNuclei+i, area, "Nuclei");
			Table.set("Mean", startIndexNuclei+i, mean, "Nuclei");
			Table.set("StdDev", startIndexNuclei+i, stdDev, "Nuclei");
			Table.set("IntDen", startIndexNuclei+i, intDen, "Nuclei");
			Table.update("Nuclei");
			nrNuclei++;
		} else {
			if (counter==0) {
				fociBelow = newArray(nrNuclei);
				fociBetween = newArray(nrNuclei);
				fociAbove = newArray(nrNuclei);
			}
			parts = split(object, "N");
			tmp = parts[0];
			parts = split(tmp, "F");			
			nucleus = parseInt(parts[0]);
			foci = parseInt(parts[1]);
			area = getResult("Area", i);
			mean = getResult("Mean", i);
			stdDev = getResult("StdDev", i);
			intDen = getResult("IntDen", i);
			row = Table.size("Foci");
			Table.set("Nr.", row, counter+1, "Foci");
			Table.set("Image", row, imageName, "Foci");
			Table.set("Nucleus", row, nucleus+1, "Foci");
			Table.set("Foci", row, foci+1, "Foci");
			Table.set("Area", row, area, "Foci");
			Table.set("Mean", row, mean, "Foci");
			Table.set("StdDev", row, stdDev, "Foci");
			Table.set("IntDen", row, intDen, "Foci");
			Table.update("Foci");
			if (area < _THRESHOLD_1) {
				fociBelow[nucleus] = fociBelow[nucleus] + 1;
			}
			if (area >= _THRESHOLD_1 && area < _THRESHOLD_2) {
				fociBetween[nucleus] = fociBetween[nucleus] + 1;
			} 
			if (area >= _THRESHOLD_2) {
				fociAbove[nucleus] = fociAbove[nucleus] + 1;
			}
			counter++;
		}
		if (i%1000==0) run("Collect Garbage");
	}
	for (i = 0; i < nrNuclei; i++) {
		Table.set("foci with area <"+ _THRESHOLD_1, startIndexNuclei+i, fociBelow[i], "Nuclei");
		Table.set("foci with "+ _THRESHOLD_1 +"<=area<"+  _THRESHOLD_2, startIndexNuclei+i, fociBetween[i], "Nuclei");
		Table.set("foci with area >="+ _THRESHOLD_2, startIndexNuclei+i, fociAbove[i], "Nuclei");
		Table.update("Nuclei");
	}
	setBatchMode(false);
}

function measureFociPerNucleus() {
	setForegroundColor(255,255,255);
	setBackgroundColor(0,0,0);
	roiManager("reset");
	inputImageID = getImageID();
	run("Remove Overlay");
	roiManager("reset");
	selectNuclei();
	run("From ROI Manager");
	roiManager("reset");
	subtractBlurredImage(_SIGMA_BLUR_FILTER);
	damsID = getImageID();
	run("Duplicate...", " ");
	maskID =getImageID();
	maskTitle = getTitle();
	setAutoThreshold(_FOCI_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	selectImage(damsID);
	run("Find Maxima...", "prominence="+_PROEMINENCE_OF_MAXIMA+" output=[Segmented Particles]");
	selectImage(damsID);
	close();
	damsID = getImageID();
	damsTitle = getTitle();
	imageCalculator("AND", maskTitle, damsTitle);
	selectImage(damsID);
	close();
	selectImage(inputImageID);
	size = Overlay.size;
	roiManager("reset");
	for (i = 0; i < size; i++) {
		selectImage(inputImageID);
		Overlay.activateSelection(i);
		selectImage(maskID);
		run("Select None");
		run("Duplicate...", " ");
		run("Restore Selection");
		setBackgroundColor(255,255,255);
		run("Clear Outside");
		setBackgroundColor(0,0,0);
		run("Analyze Particles...", "size=0-Infinity add");
		close();
		count = roiManager("count");
		for (r = 0; r < count; r++) {
			roiManager("select", r);
			roiManager("rename", "N"+IJ.pad(i, 3)+"F"+IJ.pad(r,3));
		}
		run("Select None");
		selectImage(inputImageID);
		roiManager("Show All without labels");
		run("From ROI Manager");
		roiManager("reset");
	}
	selectImage(maskID);
	close();
	reportResults();
}

function selectNuclei() {
	imageID = getImageID();
	run("Scale...", "x="+(1.0/_SCALE_FACTOR)+" y="+(1.0/_SCALE_FACTOR)+" interpolation=Bilinear create title=small_tmp");
	setAutoThreshold(_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Watershed");
	run("Scale...", "x="+_SCALE_FACTOR+" y="+_SCALE_FACTOR+" interpolation=Bilinear create title=big_tmp");
	setAutoThreshold(_THRESHOLDING_METHOD);
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity circularity=0.00-1.00 show=Nothing add exclude");
	selectWindow("small_tmp");
	close();
	selectWindow("big_tmp");
	close();
	selectImage(imageID);
	roiManager("Show All");
}

function subtractBlurredImage(sigma) {
	imageID = getImageID();
	imageTitle = getTitle();
	run("Duplicate...", " ");
	blurredID = getImageID();
	blurredTitle = getTitle();
	run("Gaussian Blur...", "sigma="+sigma);
	imageCalculator("Subtract create", imageTitle, blurredTitle);
	subtractedID = getImageID();
	selectImage(blurredID);
	close();
}
