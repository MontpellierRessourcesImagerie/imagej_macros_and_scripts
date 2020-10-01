var _MEAN1 = 10;
var _MEAN2 = 30;
var _STD_DEV1 = 2;
var _STD_DEV2 = 5;
var _NUMBER_SPOTS1 = 100;
var _NUMBER_SPOTS2 = 300;
var _WIDTH = 1980;
var _HEIGHT = 1830;
var _BACKGROUND_LEVEL = 70;
var _FOREGROUND_LEVEL = 120;
var _BACKGROUND_NOISE = 3.34;
var _FOREGROUND_NOISE = 5.25;
var _GAUSSIAN_BLUR = 4;
var _DO_NOT_TOUCH_EDGES = true;
var _CREATE_GT_IMAGE = true;
var _CREATE_GT_TABLE = true;
var _ADD_GRADIENT = true;
var _GRADIENT = 1/200;
var _IMAGE_TYPES = newArray("8-bit", "16-bit", "32-bit");
var _IMAGE_TYPE = "16-bit";
var _COUNT = 0;
var _CURRENT_PARAMETER_SET = "default";
var _PARAMETER_FILE_EXTENSION = ".ini";

var _FALSE_NEGATIVE_COLOR = "yellow";
var _FALSE_POSITIVE_COLOR = "red";
var _TRUE_POSITIVE_COLOR = "green";

var _MEASURE_POPULATION = "false positive";
var _MEASURE_POPULATIONS = newArray("false positive", "true positive", "false negative");

var _CURRENT_BATCH_GT_PARAMETER_SET = "default";
var _BATCH_GT_NUMBER_OF_IMAGES = 30;

var _CURRENT_BATCH_IMAGE_PARAMETER_SET = "default";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Create_Synthetic_Spots_Tool";

macro "Create Synthetic Spots Action Tool (f1) - C000D01D10D14D20D30C111D16D4dD7dD9bDaaDb9De3De8C111D06D07D08D09D0aD0fD15D1cD24D2cD2dD32D3dD43D53D61D63D6dD6eD71D73D7eD80D82D83D8dD92D93D9cD9dD9fDa0Da2DbaDc1Dc2Dc9DccDd1Dd2Dd9DdaDe0De1DeaDeeDf0Df4Df5Df6Df7Df9DfaDfcDfeC555D27D3bD45D86D98Da5Da6Db4Db7Dc4C000D00D02D03D04D05D0bD0cD0dD0eD11D12D13D1dD1eD1fD21D22D23D2eD2fD31D33D3eD3fD40D41D42D4eD4fD50D51D52D5eD5fD60D62D6fD70D72D7fD81D8eD8fD90D91D9eDa1DabDacDadDaeDafDb0Db1Db2DbbDbcDbdDbeDbfDc0DcaDcbDcdDceDcfDd0DdbDdcDddDdeDdfDe2De9DebDecDedDefDf1Df2Df3Df8DfbDfdDffC333D2bD85D95Dc3De5De6C999D37D46D5bD88D89Dc6C222D17D19D3cD44D54D64Da9Db8Dc8Dd3De7C888D28D36D7bD87D8aDb5Dc5C444D2aD4cD5cD6cD75D8bD96D97D99Da4Da7Dd4Dd7CeeeD47D48D49D57D58D59D5aD67D68D69D6aD78D79C222D1aD1bD25D34D5dD74D84D8cD94Da3Db3Dd8De4C666D29D55D65Dc7Dd5Dd6C333D18D26D35D7cD9aDa8CbbbD38D39D4aD56D66D77D7aC999D3aD4bD6bD76Db6" {
	createSpotsImage();
}

macro 'create synthetic spots [f1]' {
	createSpotsImage();
}

macro "Create Synthetic Spots Action Tool (f1) Options" {
	
	 Dialog.createNonBlocking("Create Synthetic Spots Options");

	 Dialog.addMessage("Parameter set: " + _CURRENT_PARAMETER_SET);
	 Dialog.addMessage("Image"); 
	 Dialog.addChoice("type: ", _IMAGE_TYPES, _IMAGE_TYPE);
	 Dialog.addNumber("image size: ", _WIDTH);
	 Dialog.addToSameRow();
	 Dialog.addNumber("x ", _HEIGHT);
	 Dialog.addNumber("background_level: ", _BACKGROUND_LEVEL);
	 Dialog.addNumber("background_noise: ", _BACKGROUND_NOISE);
	 Dialog.addCheckbox("add gradient", _ADD_GRADIENT);
	 Dialog.addNumber("gradient: ", _GRADIENT);
	 
	 Dialog.addMessage("Spots") 
	 Dialog.addNumber("number population 1: ", _NUMBER_SPOTS1);
	 Dialog.addToSameRow();
	 Dialog.addNumber("2: ", _NUMBER_SPOTS2);
	 Dialog.addNumber("mean diameter 1: ", _MEAN1);
	 Dialog.addToSameRow();
	 Dialog.addNumber("2: ", _MEAN2);
	 Dialog.addNumber("stdDev diameter 1: ", _STD_DEV1);
	 Dialog.addToSameRow();
	 Dialog.addNumber("2: ", _STD_DEV2);
	 Dialog.addNumber("intensity: ", _FOREGROUND_LEVEL);
	 Dialog.addNumber("sigma convolution: ", _GAUSSIAN_BLUR);
	 Dialog.addNumber("foreground noise: ", _FOREGROUND_NOISE);
	 Dialog.addCheckbox("do not touch edges", _DO_NOT_TOUCH_EDGES);

	 Dialog.addMessage("Ground Truth");
	 Dialog.addCheckbox("create image", _CREATE_GT_IMAGE);

 	 Dialog.addMessage("Press the help button below to open the online help!");
	 Dialog.addHelp(helpURL);
 	 Dialog.show();

	 _IMAGE_TYPE = Dialog.getChoice();
 	 _WIDTH = Dialog.getNumber();
 	 _HEIGHT = Dialog.getNumber();
 	 _BACKGROUND_LEVEL = Dialog.getNumber();
 	 _BACKGROUND_NOISE = Dialog.getNumber();
	 _ADD_GRADIENT = Dialog.getCheckbox();
	 _GRADIENT = Dialog.getNumber();
 	 
 	 _NUMBER_SPOTS1 = Dialog.getNumber();
 	 _NUMBER_SPOTS2 = Dialog.getNumber();
 	 _MEAN1 = Dialog.getNumber();
 	 _MEAN2 = Dialog.getNumber();
 	 _STD_DEV1 = Dialog.getNumber();
 	 _STD_DEV2 = Dialog.getNumber();
 	 _FOREGROUND_LEVEL = Dialog.getNumber();
 	 _GAUSSIAN_BLUR = Dialog.getNumber();
 	 _FOREGROUND_NOISE = Dialog.getNumber();
 	 _DO_NOT_TOUCH_EDGES = Dialog.getCheckbox();

 	 _CREATE_GT_IMAGE = Dialog.getCheckbox();
}

macro "create new parameter set [f2]" {
	createNewParameterSet();
}

macro "create new parameter set Action Tool (f2) - C000T4b12n" {
	createNewParameterSet();
}

macro "open parameter set [f3]" {
	openParameterSet();
}

macro "open parameter set Action Tool (f3) - C000T4b12o" {
	openParameterSet();
}

macro "mark false positive and true positive detections [f4]" {
	markFalseDetections();
}

macro "mark false and true detections Action Tool (f4) - C000T4b12d" {
	markFalseDetections();
}

macro "marc false negatives [f5]" {
	markFalseNegatives();
}

macro "marc false negatives Action Tool (f5) - C000T4b12f" {
	markFalseNegatives();
}

macro "measure [f6]" {
	measure();	
}

macro "measure Action Tool (f6) - C000T4b12m" {
	measure();
}

macro "measure Action Tool (f6) Options" {
	 Dialog.create("Measure Options");

	 Dialog.addChoice("population: ", _MEASURE_POPULATIONS, _MEASURE_POPULATION);

	 Dialog.show();

	 _MEASURE_POPULATION = Dialog.getChoice();
}

macro "batch create ground truth Action Tool (f7) - C000T4b12g" {
	batchCreateGroundTruth();
}

macro "batch create ground truth [f7]" {
	batchCreateGroundTruth();
}

macro "batch create ground truth Action Tool (f7) Options" {
	parameterSets = getParameterSets();
	Dialog.create("Batch create gt options");
	Dialog.addChoice("parameter set: ", parameterSets, _CURRENT_BATCH_GT_PARAMETER_SET);
	Dialog.addNumber("number of images: ", _BATCH_GT_NUMBER_OF_IMAGES);
	Dialog.show();
	_CURRENT_BATCH_GT_PARAMETER_SET = Dialog.getChoice();
	_BATCH_GT_NUMBER_OF_IMAGES = Dialog.getNumber();
}

macro "batch create images Action Tool (f8) - C000T4b12b" {
	batchCreateImages();	
}

macro "batch create images [f8]" {
	batchCreateImages();
}

macro "batch create images Action Tool (f8) Options" {
	parameterSets = getParameterSets();
	Dialog.create("Batch create omages options");
	Dialog.addChoice("parameter set: ", parameterSets, _CURRENT_BATCH_IMAGE_PARAMETER_SET);
	Dialog.show();
	_CURRENT_BATCH_IMAGE_PARAMETER_SET = Dialog.getChoice();
}

macro "flatten gt image Action Tool (f9) - C000D58D59D5aD67D68D69D6aD6bD77D78D79D7aD7bD87D88D89D8aD8bD98D99D9aDc8Dc9DcaDcbDccDd7Dd8Dd9DdaDdbDdcDddDe6De7De8De9DeaDebDecDedDeeDf5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D25D26D27D28D29D2aD2bD2cD2dD2eD2fD30D31D32D33D34D35D36D37D38D39D3aD3bD3cD3dD3eD3fD40D41D42D43D44D45D46D47D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D57D5bD5cD5dD5eD5fD60D61D62D63D64D65D66D6cD6dD6eD6fD70D71D72D73D74D75D76D7cD7dD7eD7fD80D81D82D83D84D85D86D8cD8dD8eD8fD90D91D92D93D94D95D96D97D9bD9cD9dD9eD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb0Db1Db2Db3Db4Db5Db6Db7Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7DcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6DdeDdfDe0De1De2De3De4De5DefDf0Df1Df2Df3Df4"{
	flattenGTImage();
}

macro "flatten gt image [f9]" {
	flattenGTImage();
}

macro "batch flatten gt images Action Tool (f11) - C000D00D01D02D03D04D05D06D10D12D13D16D20D22D23D26D30D31D32D33D34D35D36D44D45D46D58D59D5aD67D68D69D6aD6bD77D78D79D7aD7bD87D88D89D8aD8bD98D99D9aDc8Dc9DcaDcbDccDd7Dd8Dd9DdaDdbDdcDddDe6De7De8De9DeaDebDecDedDeeDf5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCfffD07D08D09D0aD0bD0cD0dD0eD0fD11D14D15D17D18D19D1aD1bD1cD1dD1eD1fD21D24D25D27D28D29D2aD2bD2cD2dD2eD2fD37D38D39D3aD3bD3cD3dD3eD3fD40D41D42D43D47D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D57D5bD5cD5dD5eD5fD60D61D62D63D64D65D66D6cD6dD6eD6fD70D71D72D73D74D75D76D7cD7dD7eD7fD80D81D82D83D84D85D86D8cD8dD8eD8fD90D91D92D93D94D95D96D97D9bD9cD9dD9eD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb0Db1Db2Db3Db4Db5Db6Db7Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7DcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6DdeDdfDe0De1De2De3De4De5DefDf0Df1Df2Df3Df4" {
	batchFlattenGTImages();
}

macro "batch flatten gt images [f11]" {
	batchFlattenGTImages();
}

function batchFlattenGTImages() {
	dir = getDirectory("Choose the input folder!");
	outDir = dir + "gt-masks/";
	File.makeDirectory(outDir);
	files = getFileList(dir);
	numberOfImages = 0;
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, ".tif")) numberOfImages++;
	}
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (!endsWith(file, ".tif")) continue;
		open(dir+file);
		flattenGTImage();
		save(outDir+file);
		close();
		close();
	}
}

function flattenGTImage() {
	run("Stack to RGB");
	run("8-bit");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
}

function batchCreateImages() {
	_COUNT=0;
	loadParameters(_CURRENT_BATCH_IMAGE_PARAMETER_SET);
	dir = getDirectory("Choose the input folder!");
	outDir = dir + _CURRENT_BATCH_IMAGE_PARAMETER_SET;
	File.makeDirectory(outDir);
	files = getFileList(dir);
	numberOfImages = 0;
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, ".xls")) numberOfImages++;
	}
	digits = Math.log10(numberOfImages) + 1;
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (!endsWith(file, ".xls")) continue;
		_COUNT++;
		Table.open(dir+file);
		xCoordinates = Table.getColumn("XC", file);
		yCoordinates = Table.getColumn("YC", file);
		diameters = Table.getColumn("Diameter", file);
		newImage("spots-"+IJ.pad(_COUNT, digits), _IMAGE_TYPE + " black", _WIDTH, _HEIGHT, 1);
		createBackground(_BACKGROUND_LEVEL);
		setColor(_FOREGROUND_LEVEL);
		drawSpots(xCoordinates, yCoordinates, diameters, _BACKGROUND_LEVEL, _WIDTH, _HEIGHT);
		convolveAndAddNoise(_GAUSSIAN_BLUR, _BACKGROUND_LEVEL, _BACKGROUND_NOISE, _FOREGROUND_NOISE);
		if (_ADD_GRADIENT) {
			run("Macro...", "code=v=v+((x+y)*"+_GRADIENT+")");
		}	
		close(file);
		saveAs("tiff", outDir+"/spots-"+IJ.pad(_COUNT, digits));
		close();
	}
	loadParameters(_CURRENT_PARAMETER_SET);
}

function batchCreateGroundTruth() {
	 _COUNT=0;
	 loadParameters(_CURRENT_BATCH_GT_PARAMETER_SET);
	 outDir = getDirectory("Choose an output folder");
	 for (i = 1; i <= _BATCH_GT_NUMBER_OF_IMAGES; i++) {
	 	_COUNT++;
		xCoordinatesSmall = newArray(_NUMBER_SPOTS1);
		yCoordinatesSmall = newArray(_NUMBER_SPOTS1);
		diametersSmall = newArray(_NUMBER_SPOTS1);
		
		xCoordinatesBig = newArray(_NUMBER_SPOTS2);
		yCoordinatesBig = newArray(_NUMBER_SPOTS2);
		diametersBig = newArray(_NUMBER_SPOTS2);
		createSpots(_NUMBER_SPOTS1, _STD_DEV1, _MEAN1, _WIDTH, _HEIGHT, _DO_NOT_TOUCH_EDGES, xCoordinatesSmall, yCoordinatesSmall, diametersSmall);
		createSpots(_NUMBER_SPOTS2, _STD_DEV2, _MEAN2, _WIDTH, _HEIGHT, _DO_NOT_TOUCH_EDGES, xCoordinatesBig, yCoordinatesBig, diametersBig);
		createGroundTruth(xCoordinatesSmall, yCoordinatesSmall, diametersSmall, xCoordinatesBig, yCoordinatesBig, diametersBig);
		title = getTitle();
		saveAs("tiff", outDir + title);
		close();
		Table.save(outDir + title+".xls", "spots ground-truth table");
		close("spots ground-truth table");
	 }
	 loadParameters(_CURRENT_PARAMETER_SET);
}
function openParameterSet() {
	 parameterSets = getParameterSets();
	
	 Dialog.createNonBlocking("Open parameter set");

	 Dialog.addMessage("Open parameter Set"); 
	 Dialog.addChoice("parameter set: ", parameterSets, _CURRENT_PARAMETER_SET);

	 Dialog.show();

	 _CURRENT_PARAMETER_SET = Dialog.getChoice();
	 loadParameters(_CURRENT_PARAMETER_SET);
}

function createNewParameterSet() {
	baseFolder = getDirectory("imagej");
	paramFolder = baseFolder + "/csst";
	parameterSets = getParameterSets();
	newName = "new-parameter-set";
	Dialog.createNonBlocking("Create new parameter set");
	Dialog.addString("name: ", newName);
	Dialog.show();	
	newName = Dialog.getString();
	if (File.exists(paramFolder+"/"+newName+_PARAMETER_FILE_EXTENSION)) {
		showMessageWithCancel("continue?", "Do you really want to overwrite the existing parameter set?");
	}
	_CURRENT_PARAMETER_SET = newName;
	saveParameters(false);
}

function getParameterSets() {
	baseFolder = getDirectory("imagej");
	paramFolder = baseFolder + "/csst";
	if (!File.exists(paramFolder+"/default"+_PARAMETER_FILE_EXTENSION)) saveParameters(false);
	
	paramSets = getFileList(paramFolder);

	for (i = 0; i < paramSets.length; i++) {
		parts = split(paramSets[i], ".");
		paramSets[i] = parts[0];
	}
	return paramSets;
}

function saveParameters(askFileName) {
	baseFolder = getDirectory("imagej");
	paramFolder = baseFolder + "/csst";
	if (!File.exists(paramFolder)) File.makeDirectory(paramFolder);
	iniContent = "[Parameter Set]"+"\n";
	iniContent += "CURRENT_PARAMETER_SET="+_CURRENT_PARAMETER_SET+"\n";

	iniContent += "[Image]"+"\n";
	iniContent += "IMAGE_TYPE="+_IMAGE_TYPE+"\n"; 
	iniContent += "WIDTH="+_WIDTH+"\n"; 
	iniContent += "HEIGHT="+_HEIGHT+"\n"; 
	iniContent += "BACKGROUND_LEVEL="+_BACKGROUND_LEVEL+"\n"; 
	iniContent += "BACKGROUND_NOISE="+_BACKGROUND_NOISE+"\n"; 
	iniContent += "ADD_GRADIENT="+_ADD_GRADIENT+"\n"; 
	iniContent += "GRADIENT="+_GRADIENT+"\n"; 

	iniContent += "[Spots]"+"\n";
	iniContent += "NUMBER_SPOTS1="+_NUMBER_SPOTS1+"\n"; 
	iniContent += "NUMBER_SPOTS2="+_NUMBER_SPOTS2+"\n"; 
	iniContent += "MEAN1="+_MEAN1+"\n"; 
	iniContent += "MEAN2="+_MEAN2+"\n"; 
	iniContent += "STD_DEV1="+_STD_DEV1+"\n"; 
	iniContent += "STD_DEV2="+_STD_DEV2+"\n"; 
	iniContent += "FOREGROUND_LEVEL="+ _FOREGROUND_LEVEL+"\n"; 
	iniContent += "GAUSSIAN_BLUR="+_GAUSSIAN_BLUR+"\n"; 
	iniContent += "FOREGROUND_NOISE="+_FOREGROUND_NOISE+"\n"; 
	iniContent += "DO_NOT_TOUCH_EDGES="+_DO_NOT_TOUCH_EDGES+"\n"; 

	iniContent += "[Ground Truth]"+"\n";
	iniContent += "CREATE_GT_IMAGE="+ _CREATE_GT_IMAGE+"\n"; 

	if (askFileName) _CURRENT_PARAMETER_SET = getString("name of the new parameter set: ", _CURRENT_PARAMETER_SET);
	
	File.saveString(iniContent, paramFolder + "/" + _CURRENT_PARAMETER_SET + _PARAMETER_FILE_EXTENSION);
}

function loadParameters(name) {
	baseFolder = getDirectory("imagej");
	paramFolder = baseFolder + "/csst";
	iniFile = File.openAsString(paramFolder + "/" + name + _PARAMETER_FILE_EXTENSION);
	ini = split(iniFile, "\n");
	for(i=0; i<ini.length; i++) {
		line = ini[i];
		line = replace(line, " ", "");
		line = replace(line, "\t", "");
		if (startsWith(line, "[") || startsWith(line, ";") || startsWith(line, "#")) continue;
		parts = split(line, "=");
		variable = parts[0];
		value = parts[1];
		variable = toUpperCase(variable);
		if (variable == "CURRENT_PARAMETER_SET") _CURRENT_PARAMETER_SET=value;
		if (variable == "IMAGE_TYPE") _IMAGE_TYPE=value;		
		if (variable == "WIDTH") _WIDTH=parseInt(value);
		if (variable == "HEIGHT") _HEIGHT=parseInt(value);
		if (variable == "BACKGROUND_LEVEL") _BACKGROUND_LEVEL=parseFloat(value);
		if (variable == "BACKGROUND_NOISE") _BACKGROUND_NOISE=parseFloat(value);
		if (variable == "ADD_GRADIENT") _ADD_GRADIENT=value;
		if (variable == "GRADIENT") _GRADIENT=parseFloat(value);
		if (variable == "NUMBER_SPOTS1") _NUMBER_SPOTS1=parseInt(value);
		if (variable == "NUMBER_SPOTS2") _NUMBER_SPOTS2=parseInt(value);
		if (variable == "MEAN1") _MEAN1=parseFloat(value);
		if (variable == "MEAN2") _MEAN2=parseFloat(value);
		if (variable == "STD_DEV1") _STD_DEV1=parseFloat(value);
		if (variable == "STD_DEV2") _STD_DEV2=parseFloat(value);
		if (variable == "FOREGROUND_LEVEL") _FOREGROUND_LEVEL = parseFloat(value);
		if (variable == "GAUSSIAN_BLUR") _GAUSSIAN_BLUR=parseFloat(value);
		if (variable == "FOREGROUND_NOISE") _FOREGROUND_NOISE=parseFloat(value);
		if (variable == "DO_NOT_TOUCH_EDGES") _DO_NOT_TOUCH_EDGES=value;
		if (variable == "CREATE_GT_IMAGE") _CREATE_GT_IMAGE=value;
	}
}

function createGroundTruth(xCoordinatesSmall, yCoordinatesSmall, diametersSmall, xCoordinatesBig, yCoordinatesBig, diametersBig) {
	digits = Math.log10(_BATCH_GT_NUMBER_OF_IMAGES) + 1;
	if (_CREATE_GT_IMAGE) {
		newImage("spots-ground-truth-"+IJ.pad(_COUNT, digits), "16-bit composite-mode", _WIDTH, _HEIGHT, 2, 1, 1);
		drawGroundTruth(xCoordinatesSmall, yCoordinatesSmall, diametersSmall, 1);
		run("Magenta Hot");
		drawGroundTruth(xCoordinatesBig, yCoordinatesBig, diametersBig, 2);
		run("Orange Hot");
		resetMinAndMax();
		Stack.setChannel(1);
		resetMinAndMax();
	}
	if (_CREATE_GT_TABLE) {
		Table.create("spots ground-truth table");
		Table.showRowNumbers(true);
		for (i = 0; i < xCoordinatesSmall.length; i++) {		
			Table.set("Class", i, 0);
			Table.set("XC", i, xCoordinatesSmall[i]);
			Table.set("YC", i, yCoordinatesSmall[i]);
			Table.set("Diameter", i, diametersSmall[i]);
			Table.set("Radius", i, diametersSmall[i]/2);
			Table.set("Area", i, PI*pow(diametersSmall[i]/2,2));
		}
		for (j = 0; j < xCoordinatesBig.length; j++) {		
			Table.set("Class", j+i, 1);
			Table.set("XC", j+i, xCoordinatesBig[j]);
			Table.set("YC", j+i, yCoordinatesBig[j]);
			Table.set("Diameter", j+i, diametersBig[j]);
			Table.set("Radius", j+i, diametersBig[j]/2);
			Table.set("Area", j+i, PI*pow(diametersBig[j]/2,2));
		}
		Table.update;
	}
}
function createSpotsImage(){
	_COUNT++;
	xCoordinatesSmall = newArray(_NUMBER_SPOTS1);
	yCoordinatesSmall = newArray(_NUMBER_SPOTS1);
	diametersSmall = newArray(_NUMBER_SPOTS1);
	
	xCoordinatesBig = newArray(_NUMBER_SPOTS2);
	yCoordinatesBig = newArray(_NUMBER_SPOTS2);
	diametersBig = newArray(_NUMBER_SPOTS2);

	newImage("spots-"+_COUNT, _IMAGE_TYPE + " black", _WIDTH, _HEIGHT, 1);
	createBackground(_BACKGROUND_LEVEL);
	setColor(_FOREGROUND_LEVEL);
	createSpots(_NUMBER_SPOTS1, _STD_DEV1, _MEAN1, _WIDTH, _HEIGHT, _DO_NOT_TOUCH_EDGES, xCoordinatesSmall, yCoordinatesSmall, diametersSmall);
	createSpots(_NUMBER_SPOTS2, _STD_DEV2, _MEAN2, _WIDTH, _HEIGHT, _DO_NOT_TOUCH_EDGES, xCoordinatesBig, yCoordinatesBig, diametersBig);
	drawSpots(xCoordinatesBig, yCoordinatesBig, diametersBig, _BACKGROUND_LEVEL, _WIDTH, _HEIGHT);
	drawSpots(xCoordinatesSmall, yCoordinatesSmall, diametersSmall, _BACKGROUND_LEVEL, _WIDTH, _HEIGHT);
	convolveAndAddNoise(_GAUSSIAN_BLUR, _BACKGROUND_LEVEL, _BACKGROUND_NOISE, _FOREGROUND_NOISE);
	
	if (_ADD_GRADIENT) {
		run("Macro...", "code=v=v+((x+y)*"+_GRADIENT+")");
	}
	createGroundTruth(xCoordinatesSmall, yCoordinatesSmall, diametersSmall, xCoordinatesBig, yCoordinatesBig, diametersBig);
}

function drawGroundTruth(xCoords, yCoords, diameters, channel) {
	Stack.setChannel(channel);
	showStatus("Creating GT-Image Channel " + channel);
	for (i = xCoords.length-1; i >= 0; i--) {
		showProgress((xCoords.length-1-i) / xCoords.length);
		setColor(i+1);
		fillOval(xCoords[i], yCoords[i], diameters[i], diameters[i]);
	}
}

function createBackground(backgroundLevel) {
	run("Macro...", "code=v="+backgroundLevel);
}

function convolveAndAddNoise(gaussianBlur, backgroudLevel, backgroundNoise, foregroundNoise) {
	run("Gaussian Blur...", "sigma="+gaussianBlur);
	setThreshold(0, backgroudLevel+1);
	run("Create Selection");
	run("Add Specified Noise...", "standard="+backgroundNoise);
	run("Make Inverse");
	run("Add Specified Noise...", "standard="+foregroundNoise);
	
	resetThreshold();
	run("Select None");
}
function drawSpots(xCoords, yCoords, diameters, backgroudLevel, width, height) {
	for (i = xCoords.length-1; i >= 0; i--) {
		diameter = diameters[i];
//		v = getPixel(xCoords[i]+(diameter/2), yCoords[i]+(diameter/2));
//		while (v>backgroudLevel) { 
//			xCoords[i] = diameter + random*(width-3*diameter);
//			yCoords[i] = diameter + random*(height-3*diameter);
//			v = getPixel(xCoords[i], yCoords[i]);
//		}	
		fillOval(xCoords[i], yCoords[i], diameter, diameter);
		updateDisplay();
	}
}

function createSpots(number, stdDev, mean, width, height, doNotTouchEdges, xList, yList, dList) {
	for (i = 0; i < number; i++) {			
	 	do {
			dList[i] = stdDev*random("gaussian")+mean;			
	 	} while (dList[i]<=0);
	}
	dList=Array.sort(dList);
	for (i = 0; i < number; i++) {
		diameter = dList[i];
		if (doNotTouchEdges) {
			x = diameter + random*(width-3*diameter);
			y = diameter + random*(height-3*diameter);
		} else {
			x = random*width;
			y = random*height;
		}
		xList[i] = x+(diameter/2);
		yList[i] = y+(diameter/2);
	}
}

function markFalseDetections() {
	count = Overlay.size;
	for (i = 0; i < count; i++) {
		setSlice(1);
		Overlay.activateSelection(i);
		getStatistics(area, mean1, min);
		setSlice(2);
		getStatistics(area, mean2, min);
		if ((mean1+mean2)==0) Roi.setStrokeColor(_FALSE_POSITIVE_COLOR);
		else Roi.setStrokeColor(_TRUE_POSITIVE_COLOR);
	}
	setSlice(1);
}

function markFalseNegatives() {
	
	gtImageID = getImageID();
	
	roiManager("Reset");
	run("To ROI Manager");
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Show All without labels");
	roiManager("Combine");
	run("Create Mask");
	maskID = getImageID();
	
	selectImage(gtImageID);
	run("Select None");
	selectImage(maskID);
	
	selectWindow("spots ground-truth table");
	XC = Table.getColumn("XC");
	YC = Table.getColumn("YC");
	R = Table.getColumn("Radius");
	selectImage(maskID);
	indices = newArray(0);
	for (i = 0; i < XC.length; i++) {
		makeOval(XC[i]-1.5, YC[i]-1.5, 3,3);
		getStatistics(area, mean);
		if (mean==0) {
			indices = Array.concat(indices, i);
		}
	}
	
	selectImage(gtImageID);
	for (i = 0; i < indices.length; i++) {
		makeOval(XC[indices[i]]-1.5, YC[indices[i]]-1.5, 3, 3);
		Overlay.addSelection(_FALSE_NEGATIVE_COLOR);
	}
	run("Select None");
}

function measure() {
	if (_MEASURE_POPULATION=="false positive") measureFalsePositives();
	if (_MEASURE_POPULATION=="true positive") measureTruePositives();
	if (_MEASURE_POPULATION=="false negative") measureFalseNegatives();
}

function measureFalseNegatives() {
	measureRoisWithColor(_FALSE_NEGATIVE_COLOR);
}

function measureFalsePositives() {
	measureRoisWithColor(_FALSE_POSITIVE_COLOR);
}

function measureTruePositives() {
	measureRoisWithColor(_TRUE_POSITIVE_COLOR);
}

function measureRoisWithColor(color) {
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		currentColor = Roi.getStrokeColor;
		if (currentColor==color) {
			run("Measure");
		}
	}
}