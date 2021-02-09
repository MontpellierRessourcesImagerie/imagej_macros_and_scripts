/**
  * Wound Healing Tool
  * Collaborators: 
  *     Nathalie Cahuzac, CNRS, IGMM, SPLICOS THERAPEUTICS; 
  *     Virginie Georget, MRI-CRBM
  *
  * Measure the area of a wound in a cellular tissue on a stack 
  * of images representing a time-series
  *
  * (c) 2010-2017, INSERM
  * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *
*/


var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Wound-Healing-Tool"
var varianceFilterRadius = 10;
var threshold = 50;
var radiusOpen = 4;
var minSize = 10000;
var methods = newArray("variance", "find edges");
var method = "variance";
var measureInPixelUnits = false;

macro "Unused Tool - C037" { }

macro "MRI Wound Healing Tool Help Action Tool - C000C111C222D07D08D09D0aD0bD0cD0dD0eD0fD18D19D1aD1bD1cD1dD1eD1fD28D29D2cD2dD2eD2fD38D39D3aD3bD3cD3eD3fD40D49D4aD4bD4cD4dD4eD4fD50D51D52D5aD5bD5cD5dD5eD5fD60D61D62D6aD6bD6cD6dD6eD6fD70D71D72D73D7bD7cD7eD7fD80D81D82D83D8cD8dD8eD8fD90D91D93D94D9cD9dD9eD9fDa0Da1Da2Da3Da4DadDaeDafDb0Db1Db2Db3Db4Db5DbeDbfDc0Dc1Dc2Dc4Dc5DcfDd0Dd2Dd4Dd5DdfDe0De2De3De4De5DefDf0Df1Df2Df3Df4Df5Df6C222C333C444C555C666C777C888C999D2aD2bD3dD7dD92Dc3Dd1Dd3De1C999CaaaCbbbCcccCdddCeeeD00D01D02D03D04D05D06D10D11D12D13D14D15D16D17D20D21D22D23D24D25D26D27D30D31D32D33D34D35D36D37D41D42D43D44D45D46D47D48D53D54D55D56D57D58D59D63D64D65D66D67D68D69D74D75D76D77D78D79D7aD84D85D86D87D88D89D8aD8bD95D96D97D98D99D9aD9bDa5Da6Da7Da8Da9DaaDabDacDb6Db7Db8Db9DbaDbbDbcDbdDc6Dc7Dc8Dc9DcaDcbDccDcdDceDd6Dd7Dd8Dd9DdaDdbDdcDddDdeDe6De7De8De9DeaDebDecDedDeeDf7Df8Df9DfaDfbDfcDfdDfeDff"{
    run('URL...', 'url='+helpURL);
}

macro 'Measure Wound Healing Action Tool - C000T4b12m' {
	measureActiveImage();
}

macro 'Batch Measure Wound Healing Action Tool - C000T4b12b' {
	batchMeasureImages();
}

macro 'Measure Wound Healing Action Tool Options' {
     Dialog.create("Wound Healing Tool Options");
     Dialog.addChoice("method", methods, method);
     Dialog.addNumber("variance filter radius", varianceFilterRadius);
     Dialog.addNumber("threshold", threshold);
     Dialog.addNumber("radius open", radiusOpen);
     Dialog.addNumber("min. size", minSize);
     Dialog.addCheckbox("ignore spatial calibration", measureInPixelUnits);
     Dialog.show();
     
     method = Dialog.getChoice();
     varianceFilterRadius= Dialog.getNumber();
     threshold= Dialog.getNumber();
     radiusOpen = Dialog.getNumber();
     minSize = Dialog.getNumber();
     measureInPixelUnits = Dialog.getCheckbox();
}

function batchMeasureImages() {
	print("\\Clear");
	setBatchMode(true);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(dayOfMonth + "-" + (month+1) + "-" + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	dir = getDirectory("Select the folder containing the images");
	files = getFileList(dir);
	numberOfImages = 0;
	for (i=0; i<files.length; i++) {
		file = files[i];
		if (isInputImage(file)) {
			numberOfImages++;
		}
	}
	counter = 1;
	for (i=0; i<files.length; i++) {
		file = files[i];
		if (isInputImage(file)) {
			print("\\Update1:Processing file " + (counter) + " of " + numberOfImages);
			open(dir+"/"+file);
			title = getTitle();
			measureActiveImage();
			outDir = dir + "/" + "control-images";
			if (!File.exists(outDir)) {
				File.makeDirectory(outDir);
			}
			save(outDir + "/" + title);
			close();
			selectWindow("Results");
			saveAs("Text", dir + "/scratch_areas_" + title + ".xls");
			counter++;
		}
	}
	print("FINISHED");
    	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);	
	print(dayOfMonth + "-" + (month+1) + "-" + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	setBatchMode("exit and display");	
}


function measureActiveImage() {
	run("Select None");
	getPixelSize(unit, pixelWidth, pixelHeight);
	run("Duplicate...", "duplicate");
    setForegroundColor(0, 0, 0);
    setBackgroundColor(255, 255, 255);
    roiManager("reset")
    roiManager("Associate", "true");
    if (method=="variance") 
        thresholdVariance();
    else 
        thresholdFindEdges();
    run("Convert to Mask", " black");
    resetThreshold();
    run("Invert", "stack");
    for (i=0; i<radiusOpen; i++) {
        run("Dilate", "stack");
    }
    for (i=0; i<radiusOpen; i++) {
        run("Erode", "stack");
    }
    run("Select All");
    run("Enlarge...", "enlarge=-" + radiusOpen + " pixel");
    run("Invert", "stack");
    run("Analyze Particles...", "size="+minSize+"-Infinity circularity=0.00-1.00 show=Nothing add stack");
    close();
    run("Clear Results");
    if (measureInPixelUnits)
    		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    roiManager("Measure"); 
    roiManager("Show None");
	roiManager("Show All");
}

function isInputImage(name) {
	if (!endsWith(name, ".tif") && !endsWith(name, ".TIF")) return false;
	return true;
}

function thresholdVariance() {
    run("Variance...", "radius=" + varianceFilterRadius + " stack");
    run("8-bit");
    setThreshold(0,threshold);
}

function thresholdFindEdges() {
    run("Find Edges", "stack");
    run("Invert", "stack");
    setAutoThreshold("Percentile dark");
}

