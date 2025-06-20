/**
  * MRI Lipid Droplets Tool
  * 
  * The Lipid Droplets Tool helps to analyze lipid droplets marked with BODIPY.
  * 
  * written 2017 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * in collaboration with Monica Colitti
  */

var SCALE_BACK = true;
var BAND_PASS_PYRAMID = true;
var FILTER = "Gaussian Blur";
var FILTER_RADIUS = 7;
var INTERPOLATION = "Bilinear";
var AVERAGE = true;
var UP_INTERPOLATION = "Bilinear";
var UP_AVERAGE = true;
var MIN_SIZE = 300;
var THRESHOLDING_METHOD_DROPLETS = "Percentile";
var THRESHOLDING_METHOD_SIGNAL = "Triangle";

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Lipid_Droplets_Tool";

segmentLipidDroplets();

macro "Lipid Droplets Tool Help Action Tool - C072D00D01D10D11D20D30D40DafDbeDbfDc0Dc1DceDcfDdfC0a3D14D2aD36D3cD3dD46D54D55D69D88D97Da2Da7Da9Db3Db6DdaDdcDe8C093D65Dd4Dd5C0b4D0aD1eD2bD2cD2dD34D35D7aD7cD89D8cD96D9aD9cDa3De9Df8C093D04D08D12D18D27D3fD4bD4cD4dD4fD52D57D59D61D63D6eD74D8fDb0Dc7DcaDccDd3Dd6Dd7Dd8De4De7DffC0b4D0fD1aD1fD23D24D25D2eD33D43D44D45D6aD6bD79D80D84D85D8dD90D99D9dDa6DaaDabDacDb4Db5DdbDedDf0Df1Df2DfeC0a3D09D13D15D19D22D26D2fD32D3bD3eD42D53D56D5bD60D6dD71D78D81D83D86D91D98Da0Da8DadDb7DbbDc4Dc5Dc6Dd9De1Df4Df7C0c4D0bD1dD8bDa4Da5DebDfdC083D03D05D17D21D28D31D39D41D4aD4eD50D51D58D5dD62D66D67D72D75D77DaeDb1DbdDc2Dc8Dc9Dd2De5De6Df5Df6C0a3D6cD70D7dD92Df3C093D29D37D3aD47D5aD5cD5fD64D68D6fD7eD7fD82D87D8eD9eDa1Db2Db8Db9DbaDbcDc3DcbDddDe0De2De3DeeC0c4D0eD1bD7bD8aD93D9bDeaDecC0d4DfaDfbDfcC082D02D06D07D38D48D49D5eD73D76D9fDcdDd0Dd1DdeDefC093D16C0c4D0cD0dD1cD94D95Df9"{
	run('URL...', 'url='+helpURL);
}

macro "select lipid droplets [f1]" {
    segmentLipidDroplets();
}

macro  "Select Lipid Droplets (f1) Action Tool - C000T4b12s" {
    segmentLipidDroplets();
}

macro  "Select Lipid Droplets (f1) Action Tool Options" {
    showLipidDropletsOptions();
}

macro "Lipid Droplets Tool Help Action Tool Options"{
    showLipidDropletsOptions();
}

function showLipidDropletsOptions() {
    Dialog.create("Lipid Droplets Options");
    Dialog.addNumber("min. size", MIN_SIZE);
    Dialog.show();
    MIN_SIZE = Dialog.getNumber();
}

function segmentLipidDroplets() {
    run("Options...", "iterations=1 count=1");
    run("Select None");
    inputImageID = getImageID();
    width = getWidth();
    height = getHeight();

    wasRGB = false;

    // For rgb images use only the green channel
    if (bitDepth==24) {
	wasRGB = true;	
	run("Duplicate...", " ");
	rgbStackID = getImageID();
	run("RGB Stack");
	setSlice(2);
	run("Duplicate...", " ");
	eightBitID =  getImageID();
	selectImage(rgbStackID);
	close();
	selectImage(eightBitID);
	originalImageID = inputImageID;
	inputImageID = eightBitID;
    }
    // Calculate the bandpass pyramid (only the first two images) and create
    // an image of the same size as the input image as result 
    calculatePyramid();
    run("Enhance Contrast", "saturated=0.35");
    pyramidID = getImageID();
    widthP = getWidth();
    heightP = getHeight();
    midxp = widthP/2;
    midyp = heightP/2;
    xp = midxp - (width / 2);
    yp = midyp - (height / 2);
    makeRectangle(xp, yp, width, height);
    run("Duplicate...", " ");
    maskID = getImageID();
    maskTitle = getTitle();
    selectImage(pyramidID);
    close();
    // Create a mask and remove background by using a mask containing non empty regions created by thresholding the 
    // input image
    selectImage(maskID);
    setAutoThreshold(THRESHOLDING_METHOD_DROPLETS + " dark");
    run("Convert to Mask");
    run("Fill Holes");
    stop = false;
    while (!stop) {
    	getHistogram(values, counts, 256);
	if (counts[0]>0) {
		stop = true;
		print(">0");
	}
	else {
                            run("Undo");
	    run("Erode");
	    run("Fill Holes");
	    run("Dilate");
	}
    }

    selectImage(inputImageID);
    run("Duplicate...", " ");
    setAutoThreshold(THRESHOLDING_METHOD_SIGNAL + " dark");
    run("Convert to Mask");
    mask2ID = getImageID();
    mask2Title = getTitle();
    imageCalculator("AND", maskTitle, mask2Title);
    selectImage(mask2ID);
    close();
    // Remove small objects
    selectImage(maskID);
    run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity show=Masks exclude in_situ");
    selectImage(maskID);
    setAutoThreshold("Default");
    run("Convert to Mask");
   // Separate touching objects and create rois for the objects
    run("Watershed");
    roiManager("Reset");
    run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity show=Nothing add");
    close();

    // For rgb input images close green channel image to display the result on the rgb version 
    if (wasRGB) {
	if (isOpen(inputImageID)) {
		selectImage(inputImageID);
		close();
	}
	inputImageID = originalImageID;
    }
   // display the result on the input image
    selectImage(inputImageID);
    roiManager("Show None");
    roiManager("Show All");
}

function calculatePyramid() {
	width = getWidth();
	height = getHeight();
	title = getTitle();

	exponent_width =  floor(log(width) / log(2))+1;
	exponent_height =  floor(log(height) / log(2))+1;

	slices = 1;
	width_target = pow(2, exponent_width);
	height_target = pow(2, exponent_height);

	setBatchMode(true);

	run("Duplicate...", "title=pyramid");
	run("Canvas Size...", "width="+width_target+" height="+height_target+" position=Center zero");

	for (i=0; i<slices; i++) {
		setSlice(i+1);
		run("Duplicate...", "title=pyramid-p");
		filter();
		downSample();	
		addToStack();
	}

	if (SCALE_BACK || BAND_PASS_PYRAMID) {
		for (i=1; i<=slices; i++) {
			setSlice(i+1);
			upSample(i); 
		}
	}

	if (BAND_PASS_PYRAMID) {
		setSlice(slices+1);
		run("Duplicate...", "title=base");
		for(i=slices; i>=1; i--) {
			selectWindow("pyramid");
			setSlice(i);
			run("Duplicate...", "title=next");
			imageCalculator("Subtract create", "next","base");
			selectWindow("Result of next");
			run("Select All");
			run("Copy");
			selectWindow("pyramid");
			run("Paste");
			selectWindow("Result of next");
			run("Close");
			selectWindow("base");
			run("Close");
			selectWindow("next");
			run("Select None");
			rename("base");
		} 
		selectWindow("base");
		run("Close");	
		selectWindow("pyramid");
		rename("bandpass-pyramid");
		run("Select None");
	} else {
		selectWindow("pyramid");
		rename("lowpass-pyramid");
	}

	setBatchMode("exit and display");
}

function filter() {
	if (FILTER=="None") return;
	if (FILTER=="Gaussian Blur") run("Gaussian Blur...", "sigma=" + FILTER_RADIUS);
	else 
	   run(FILTER+"...", "radius="+FILTER_RADIUS);
}

function downSample() {
	options = "x=0.5 y=0.5 interpolation="+INTERPOLATION;
	if (AVERAGE) options += " average";
	run("Scale...", options);
}

function upSample(i) {
	scale = pow(2,i);
	options = "x="+scale+" y="+scale+" interpolation="+UP_INTERPOLATION;
	if (AVERAGE) options += " average";
	run("Scale...", options);
}

function addToStack() {
	run("Concatenate...", "  title=[pyramid] image1=[pyramid] image2=[pyramid-p] image3=[-- None --]");
}
