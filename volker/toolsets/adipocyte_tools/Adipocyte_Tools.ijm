/**
  * MRI Adipocyte Tools
  * 
  * The Adipocytes Tools help to analyze fat cells in images from histological sections.
  * 
  * written 2012-2016 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * in collaboration with Matthieu Lacroix and Patricia Cavelier
  */

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Adipocytes-Tools"
var preMinSize = 40;
var preMaxSize = 20000;
var preThresholdMethod = "Percentile";
var preNumberOfDilates = 10;
var preRemoveScale = true;

var simpleMinSize = 40;
var simpleMaxSize = 6000;
var simpleThresholdMethod = "Huang";
var simpleUseBinaryWatershed = true;
var simpleFindEdges = true;
var simpleClearBackground = true;
var simpleRemoveScale = true

var waterMinSize = 50;
var waterMaxSize = 20000;
var waterSigma = 4;
var waterFindEdges = true;
var waterClearBackground = true;
var waterRemoveScale = true;

var largeMinSize = 10000;
var largeMaxSize = "Infinity";
var largeRemoveScale = true;
var largeNumberOfErodes = 3;

var oldForeground;
var oldBackground;

macro "Unused Tool - C037" { }

macro "Adipocytes Tools Help Action Tool - C98aD00D01D02D03D04D05D06D07D08D09D0aD4fDd0De0Df8Df9CfffD1dD29D2eD34D49D51D56D6cD85D8bD9aDa1Dc6DdaDe2CddeD14D15D16D17D18D1cD2aD2dD4aD5dD5eD62D65D66D67D68D72D75D76D77D82D83D84D8aD92D93D94D98D99Da2Da3Da7Da8Da9Db1Db7Db8Db9Dc7Dc8Dc9CfffD0bD0cD0dD0eD0fD10D1eD1fD20D24D25D26D27D28D2fD30D35D36D37D38D39D3fD40D45D46D47D48D50D57D58D5fD60D61D6dD6eD6fD70D71D7cD7dD7eD7fD80D81D8cD8dD8eD8fD90D91D95D96D9bD9cD9dD9eD9fDa0Da5Da6DaaDabDacDadDaeDafDb0Db5Db6DbaDbbDbcDbdDbeDbfDc0DcaDcbDccDcdDceDcfDdbDdcDddDdeDdfDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7DfaDfbDfcDfdDfeDffCccdD13D19D21D22D31D33D3eD42D43D4eD52D5aD5cD63D6bD73D78D7aD87Db3Dc1Dc4Dd1Dd2Dd3Dd5Dd6Dd9De4De5De6CeeeD23D3aD41D44D55D59D7bD86D97Da4Db4Dc5De1De3DeaCcbcD1aD1bD2bD2cD32D3bD4bD4dD53D54D5bD64D69D6aD74D79D88D89Db2Dc2Dc3Dd4Dd7Dd8De7De9CaabD11D12D3cD3dD4cDe8"{
	run('URL...', 'url='+helpURL);
}

macro "Preprocessing Clear Background Action Tool - C000T4b12p" {
    setBatchMode(true);
    roiManager("reset");
    storeColors();
    setWhiteOnBlack();
    if (preRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    clearBackground(preMinSize, preMaxSize, preThresholdMethod, preNumberOfDilates, false);
    resetColors();
    setBatchMode("exit and display");
    if (isOpen("Results")) {
	selectWindow("Results");
	run("Close");
    }
}

macro "Simple Adipocytes Segmentation Action Tool- C000T4b12s" {
    run("ROI Manager...");
    roiManager("Show All with labels");
    setBatchMode(true);
    roiManager("reset");
    storeColors();
   setWhiteOnBlack();
    if (simpleRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    if (simpleUseBinaryWatershed && simpleClearBackground) clearBackground(preMinSize, preMaxSize, preThresholdMethod, preNumberOfDilates, true);
    if (simpleRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    if (simpleFindEdges) run("Find Edges");
    run("8-bit");
    if (simpleFindEdges) {
        run("Smooth");
        run("Invert");
    }
    setAutoThreshold(simpleThresholdMethod+ " dark");
    run("Convert to Mask");
    if (simpleUseBinaryWatershed) run("Watershed");
    run("Clear Results");
    run("Analyze Particles...", "size="+simpleMinSize+"-"+simpleMaxSize+" circularity=0.00-1.00 show=Nothing add exclude");
    run("Revert");
     if (simpleRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    resetColors();
    setBatchMode("exit and display");
    if (isOpen("Results")) {
	    selectWindow("Results");
	    run("Close");
   }
    roiManager("Show All with labels");
}

macro "Watershed Adipocytes Segmentation Action Tool- C000T4b12w" {
   run("ROI Manager...");
   roiManager("Show All with labels");
   setBatchMode(true);
   roiManager("reset");
   storeColors();
   setWhiteOnBlack();
   if (waterRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
   if (waterClearBackground) clearBackground(preMinSize, preMaxSize, preThresholdMethod, preNumberOfDilates, false);
   title = getTitle();
   if (waterRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
   if (waterFindEdges) run("Find Edges");
   else  run("Invert");
   run("8-bit");
   run("Gaussian Blur...", "sigma=" + waterSigma);
   run("Watershed Algorithm");
   run("Invert");
   imageCalculator("AND create", title,"Watershed");
   titleResult = getTitle();
   selectImage("Watershed");
   close();
   selectImage(titleResult);
   setThreshold(1, 255);
   run("Convert to Mask");
   run("Clear Results");
    run("Analyze Particles...", "size="+waterMinSize+"-"+waterMaxSize+" circularity=0.00-1.00 show=Nothing add exclude");
   selectImage(titleResult); 
   close();
   run("Revert");
   if (waterRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
   resetColors();
   setBatchMode("exit and display");
   if (isOpen("Results")) {
        selectWindow("Results");
        run("Close");
   }
   roiManager("Show All with labels");
}

macro "Large Magnification Adipocytes Segmentation Action Tool- C000T4b12l" {
   run("ROI Manager...");
   roiManager("Show All with labels");
   setBatchMode(true);
   roiManager("reset");
   storeColors();
   setWhiteOnBlack();
   if (largeRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
   title = getTitle();
   
    run("Fit Polynomial", "x=2 y=2 mixed=1");
    run("8-bit");
    setAutoThreshold("Huang dark");
    setOption("BlackBackground", false);
    run("Convert to Mask");
    for (i=0; i<largeNumberOfErodes; i++) {
	    run("Erode");
    }
    run("Fill Holes");
    run("Create Selection");
    run("Crop");
    run("Select None");
    run("Analyze Particles...", "size="+largeMinSize+"-"+largeMaxSize+" exclude add");

   run("Revert");
   if (largeRemoveScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
   resetColors();
   setBatchMode("exit and display");
   if (isOpen("Results")) {
        selectWindow("Results");
        run("Close");
   }
   roiManager("Show All with labels");
}

macro "Preprocessing Clear Background Action Tool Options" {
        Dialog.create("Preprocessing Adipocytes Segmentation Options");
        Dialog.addNumber("min. size", preMinSize);	
        Dialog.addNumber("max. size", preMaxSize);
        Dialog.addNumber("nr. of dilates", preNumberOfDilates);
        Dialog.addChoice("thresholding method", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError",  "Minimum", "Moments",  "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"),  preThresholdMethod);
        Dialog.addCheckbox("remove scale", preRemoveScale);
        Dialog.show();
        preMinSize = Dialog.getNumber();
        preMaxSize = Dialog.getNumber();
        preNumberOfDilates = Dialog.getNumber();
        preThresholdMethod = Dialog.getChoice();
        preRemoveScale = Dialog.getCheckbox();
}

macro "Simple Adipocytes Segmentation Action Tool Options" {
       Dialog.create("Simple Adipocytes Segmentation Options");
       Dialog.addNumber("min. size", simpleMinSize);	
       Dialog.addNumber("max. size", simpleMaxSize);
       Dialog.addChoice("thresholding method", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError",  "Minimum", "Moments",  "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"),  simpleThresholdMethod);
       Dialog.addCheckbox("clear background", simpleClearBackground);
       Dialog.addCheckbox("find edges", simpleFindEdges);
       Dialog.addCheckbox("use binary watershed", simpleUseBinaryWatershed);
       Dialog.addCheckbox("remove scale", simpleRemoveScale);
       Dialog.show();
       simpleMinSize = Dialog.getNumber();
       simpleMaxSize = Dialog.getNumber();
       simpleThresholdMethod = Dialog.getChoice();
       simpleClearBackground = Dialog.getCheckbox();
       simpleFindEdges = Dialog.getCheckbox();
       simpleUseBinaryWatershed = Dialog.getCheckbox();
       simpleRemoveScale = Dialog.getCheckbox();
}

macro "Watershed Adipocytes Segmentation Action Tool Options" {
        Dialog.create("Watershed Adipocytes Segmentation Options");
        Dialog.addNumber("min. size", waterMinSize);	
        Dialog.addNumber("max. size", waterMaxSize);
        Dialog.addNumber("sigma", waterSigma);
        Dialog.addCheckbox("clear background", waterClearBackground);
        Dialog.addCheckbox("find edges", waterFindEdges);
        Dialog.addCheckbox("remove scale", waterRemoveScale);
        Dialog.show();
        waterMinSize = Dialog.getNumber();
        waterMaxSize = Dialog.getNumber();
        waterSigma = Dialog.getNumber();
        waterClearBackground = Dialog.getCheckbox();
        waterFindEdges = Dialog.getCheckbox();
        waterRemoveScale = Dialog.getCheckbox();
}

macro "Large Magnification Adipocytes Segmentation Action Tool Options" {
        Dialog.create("Large Magnification Adipocytes Segmentation Options");
        Dialog.addNumber("min. size", largeMinSize);	
        Dialog.addNumber("max. size", largeMaxSize);
        Dialog.addNumber("nr. of erodes", largeNumberOfErodes);
        Dialog.addCheckbox("remove scale", largeRemoveScale);
        Dialog.show();
        largeMinSize = Dialog.getNumber();
        largeMaxSize = Dialog.getNumber();
        largeNumberOfErodes = Dialog.getNumber();
        largeRemoveScale = Dialog.getCheckbox();
}

function clearBackground(minSize, maxSize, thresholdMethod,  numberOfDilates, keepSelection) {
    saveSettings();
    setOption("black background", false);
    title = getTitle();
    run("Find Edges");
    run("8-bit");
    run("Smooth");
    run("Invert");
    setAutoThreshold(thresholdMethod + " dark");
    run("Analyze Particles...", "size="+minSize+"-"+maxSize+" circularity=0.00-1.00 show=Masks exclude in_situ");
    run("Create Selection");
    run("Enlarge...", "enlarge=" + numberOfDilates);
    run("Revert");
    run("Clear Outside");
    roiManager("reset");
    if (!keepSelection) run("Select None");
    restoreSettings();
}

function storeColors() {
       oldForeground = getValue("color.foreground");
       oldBackground = getValue("color.background");
}

function setWhiteOnBlack() {
    setForegroundColor(255,255,255);
    setBackgroundColor(0,0,0);
}


function setBlackOnWhite() {
    setForegroundColor(0,0,0);
    setBackgroundColor(255,255,255);
}

function resetColors() {
    setForegroundColor((oldForeground>>16)&0xff, (oldForeground>>8)&0xff, oldForeground&0xff);
    setBackgroundColor((oldBackground>>16)&0xff, (oldBackground>>8)&0xff, oldBackground&0xff);
}

function emptyRoiManager() {
    roiManager("Deselect");
    if (roiManager("count")>0) roiManager("Delete");
}
