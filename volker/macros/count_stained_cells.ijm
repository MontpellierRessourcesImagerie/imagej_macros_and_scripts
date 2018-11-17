/**
 * Count the nuclei that have a staining in the correponding gfp channel. 
 * 
 * Open the dapi-image and run the macro. 
 * You might need to adjust the Channel names 
 * and the width and height of the region of 
 * the image that will be used.
 * 
 */
 
var NUCLEI_CHANNEL = "DAPI";
var SIGNAL_CHANNEL = "GFP";
var WIDTH = 552;
var HEIGHT = 405;
var ENLARGE_ROIS_BY = 2;
var methods = getList("threshold.methods");
// Default, Huang, Intermodes, IsoData, IJ_IsoData, Li, MaxEntropy, Mean, MinError, 
// Minimum, Moments, Otsu, Percentile, RenyiEntropy, Shanbhag, Triangle, Yen
var THRESHOLDING_METHOD_DAPI = methods[0]; 
var THRESHOLDING_METHOD_GFP = methods[6]; 
var MIN_SIZE = 100;

roiManager("Reset");
folder = File.directory;
nucleiImageName = File.name;

nucleiImageID = getImageID();
nucleiImageTitle = getTitle();
createMaskDAPI();
nucleiMaskID = getImageID();
nucleiMaskTitle = getTitle();
run("Erode");
run("Watershed");
run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity show=Outlines display summarize");
outlinesImageID = getImageID();
outlinesImageTitle = getTitle();
run("Invert");
selectImage(nucleiMaskID);

signalImageName = replace(nucleiImageName, NUCLEI_CHANNEL, SIGNAL_CHANNEL);
open(folder + "/" + signalImageName);
signalImageID = getImageID();
signalImageTitle = getTitle();
createMaskGFP();
signalMaskID = getImageID();
signalMaskTitle = getTitle();

imageCalculator("AND create", signalMaskTitle,nucleiMaskTitle);
run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity circularity=0.00-1.00 add display summarize in_situ");
close();

selectImage(signalMaskID);
close();
selectImage(nucleiMaskID);
close();
selectImage(nucleiImageID);
cropScaleAndConvert();
newNucleiImageTitle = getTitle();
selectImage(nucleiImageID);
close();
selectImage(signalImageID);
cropScaleAndConvert();
newSignalImageTitle = getTitle();
selectImage(signalImageID);
close();

run("Merge Channels...", "c6=["+outlinesImageTitle+"] c2="+newSignalImageTitle+" c3="+newNucleiImageTitle+" create");
setSlice(1);
run("Green");
run("Enhance Contrast", "saturated=0.35");
setSlice(2);
run("Blue");
run("Enhance Contrast", "saturated=0.35");
setSlice(1);
roiManager("Show None");
roiManager("Show All without labels");

run("Out [-]");
run("Out [-]");

if (ENLARGE_ROIS_BY!=0) enlargeRoisBy(ENLARGE_ROIS_BY);

function enlargeRoisBy(n) {
	count = roiManager("Count");
	for(i=0; i<count; i++) {
		roiManager("Select", i);
		run("Enlarge...", "enlarge="+n);
		roiManager("Update");
	}
	roiManager("Deselect");
}

function createMaskGFP() {
	cropScaleAndConvert();
	setAutoThreshold(THRESHOLDING_METHOD_GFP+" dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
}

function createMaskDAPI() {
	cropScaleAndConvert();
	setAutoThreshold(THRESHOLDING_METHOD_DAPI+" dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
}


function cropScaleAndConvert() {
	makeRectangle(0, 0, WIDTH, HEIGHT);
	run("Crop");
	run("8-bit");
	run("Scale...", "x=4 y=4 interpolation=Bilinear average create");
}
