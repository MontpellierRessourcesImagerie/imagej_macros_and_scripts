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
var _ADD_GRADIANT = true;
var _GRADIANT = 1/200;

var _COUNT = 0;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Create_Synthetic_Spots_Tool";

macro "Create Synthetic Spots Action Tool (f11) - C000D01D10D14D20D30C111D16D4dD7dD9bDaaDb9De3De8C111D06D07D08D09D0aD0fD15D1cD24D2cD2dD32D3dD43D53D61D63D6dD6eD71D73D7eD80D82D83D8dD92D93D9cD9dD9fDa0Da2DbaDc1Dc2Dc9DccDd1Dd2Dd9DdaDe0De1DeaDeeDf0Df4Df5Df6Df7Df9DfaDfcDfeC555D27D3bD45D86D98Da5Da6Db4Db7Dc4C000D00D02D03D04D05D0bD0cD0dD0eD11D12D13D1dD1eD1fD21D22D23D2eD2fD31D33D3eD3fD40D41D42D4eD4fD50D51D52D5eD5fD60D62D6fD70D72D7fD81D8eD8fD90D91D9eDa1DabDacDadDaeDafDb0Db1Db2DbbDbcDbdDbeDbfDc0DcaDcbDcdDceDcfDd0DdbDdcDddDdeDdfDe2De9DebDecDedDefDf1Df2Df3Df8DfbDfdDffC333D2bD85D95Dc3De5De6C999D37D46D5bD88D89Dc6C222D17D19D3cD44D54D64Da9Db8Dc8Dd3De7C888D28D36D7bD87D8aDb5Dc5C444D2aD4cD5cD6cD75D8bD96D97D99Da4Da7Dd4Dd7CeeeD47D48D49D57D58D59D5aD67D68D69D6aD78D79C222D1aD1bD25D34D5dD74D84D8cD94Da3Db3Dd8De4C666D29D55D65Dc7Dd5Dd6C333D18D26D35D7cD9aDa8CbbbD38D39D4aD56D66D77D7aC999D3aD4bD6bD76Db6" {
	createSpotsImage();
}

macro 'create synthetic spots [f11]' {
	createSpotsImage();
}

macro "Create Synthetic Spots Action Tool (f11) Options" {
	 Dialog.create("Create Synthetic Spots Options");
	 
	 Dialog.addMessage("Image"); 
	 Dialog.addNumber("image size: ", _WIDTH);
	 Dialog.addToSameRow();
	 Dialog.addNumber("x ", _HEIGHT);
	 Dialog.addNumber("background level: ", _BACKGROUND_LEVEL);
	 Dialog.addNumber("background noise: ", _BACKGROUND_NOISE);
	 Dialog.addCheckbox("add gradient", _ADD_GRADIANT);
	 Dialog.addNumber("gradiant: ", _GRADIANT);
	 
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
 	 
 	 _WIDTH = Dialog.getNumber();
 	 _HEIGHT = Dialog.getNumber();
 	 _BACKGROUND_LEVEL = Dialog.getNumber();
 	 _BACKGROUND_NOISE = Dialog.getNumber();
	 _ADD_GRADIANT = Dialog.getCheckbox();
	 _GRADIANT = Dialog.getNumber();
 	 
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

function createSpotsImage(){
	_COUNT++;
	xCoordinatesSmall = newArray(_NUMBER_SPOTS1);
	yCoordinatesSmall = newArray(_NUMBER_SPOTS1);
	diametersSmall = newArray(_NUMBER_SPOTS1);
	
	xCoordinatesBig = newArray(_NUMBER_SPOTS2);
	yCoordinatesBig = newArray(_NUMBER_SPOTS2);
	diametersBig = newArray(_NUMBER_SPOTS2);

	newImage("spots-"+_COUNT, "8-bit black", _WIDTH, _HEIGHT, 1);
	createBackground(_BACKGROUND_LEVEL);
	setColor(_FOREGROUND_LEVEL);
	createSpots(_NUMBER_SPOTS1, _STD_DEV1, _MEAN1, _WIDTH, _HEIGHT, _DO_NOT_TOUCH_EDGES, xCoordinatesSmall, yCoordinatesSmall, diametersSmall);
	createSpots(_NUMBER_SPOTS2, _STD_DEV2, _MEAN2, _WIDTH, _HEIGHT, _DO_NOT_TOUCH_EDGES, xCoordinatesBig, yCoordinatesBig, diametersBig);
	drawSpots(xCoordinatesBig, yCoordinatesBig, diametersBig, _BACKGROUND_LEVEL, _WIDTH, _HEIGHT);
	drawSpots(xCoordinatesSmall, yCoordinatesSmall, diametersSmall, _BACKGROUND_LEVEL, _WIDTH, _HEIGHT);
	convolveAndAddNoise(_GAUSSIAN_BLUR, _BACKGROUND_LEVEL, _BACKGROUND_NOISE, _FOREGROUND_NOISE);
	
	if (_ADD_GRADIANT) {
		run("Macro...", "code=v=v+((x+y)*"+_GRADIANT+")");
	}
	if (_CREATE_GT_IMAGE) {
		newImage("spots ground-truth "+_COUNT, "16-bit composite-mode", _WIDTH, _HEIGHT, 2, 1, 1);
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
			Table.set("XC", i, xCoordinatesSmall[i]+(diametersSmall[i]/2));
			Table.set("YC", i, yCoordinatesSmall[i]+(diametersSmall[i]/2));
			Table.set("Diameter", i, diametersSmall[i]);
			Table.set("Radius", i, diametersSmall[i]/2);
			Table.set("Area", i, PI*pow(diametersSmall[i]/2,2));
		}
		for (j = 0; j < xCoordinatesBig.length; j++) {		
			Table.set("Class", j+i, 1);
			Table.set("XC", j+i, xCoordinatesBig[j]+(diametersBig[j]/2));
			Table.set("YC", j+i, yCoordinatesBig[j]+(diametersBig[j]/2));
			Table.set("Diameter", j+i, diametersBig[j]);
			Table.set("Radius", j+i, diametersBig[j]/2);
			Table.set("Area", j+i, PI*pow(diametersBig[j]/2,2));
		}
		Table.update;
	}
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

function createBackground(backgroudLevel) {
	run("Select All");
	setForegroundColor(backgroudLevel,backgroudLevel,backgroudLevel);
	run("Fill", "slice");
	run("Select None");	
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
		v = getPixel(xCoords[i]+(diameter/2), yCoords[i]+(diameter/2));
		while (v>backgroudLevel) { 
			xCoords[i] = diameter + random*(width-3*diameter);
			yCoords[i] = diameter + random*(height-3*diameter);
			v = getPixel(xCoords[i], yCoords[i]);
		}
		fillOval(xCoords[i], yCoords[i], diameter, diameter);
		updateDisplay();
	}
}

function createSpots(number, stdDev, mean, width, height, doNotTouchEdges, xList, yList, dList) {
	for (i = 0; i < number; i++) {
		dList[i] = stdDev*random("gaussian")+mean;	
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
		xList[i] = x;
		yList[i] = y;
	}
}