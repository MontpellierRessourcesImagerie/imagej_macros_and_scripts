/**
  * MRI Fibrosis quantification tool
  *
  * Measure the relative area of sirius red stained fibrosis.
  *
  * written 2015 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
*/

var r1 = 0.148;
var g1 = 0.772;
var b1 = 0.618;
var r2 = 0.462;
var g2 = 0.602;
var b2 = 0.651;
var r3 = 0.187;
var g3 = 0.523;
var b3 = 0.831;
var _EXT = ".ndpi";
var _CONTROL_FOLDER = "control-images";
var _RESULTS_TABLE = "Fibrosis area";
var _REMOVE_SCALE = false;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Fibrosis_Tool";

macro "MRI Fibrosis Tool Help [f1]" {
  showHelp();
}

macro "MRI Fibrosis Tool Help (f1) Action Tool - Cb87D01D1bD44D4cD63D73D9bDa0Da4Db0Db4DbaDc0Dd1Dd8De1Df3CdaaD09D0aD0bD13D23D30D42D4aD61D71D7aD7bD81D82Dd9Df9Cda8D0fD10D17D1fD20D2dD2eD34D35D38D8bDafDbfDc5DceDcfDd4Df2DffCeccD03D04D05D06D08D12D55D69D70D89D96D98D99DbdDeaDfaDfdCd88D1aD1cD25D26D28D29D2aD2bD2cD5cD6cDa2Dc1Dc2Dd2Dd7CdcaD0eD11D33D37D43D45D62D6dD72D7eD9eDa6Db7DcdDddDe4Cdb8D2fD3eD3fD4eD4fD53D5fD6fD7fD8fD94D9fDdeDdfDefCeddD0cD46D57D66D68D77D79D85D86D88D9dDa8DacDadDbbDbcDfcCc98D14D15D18D24D32D3bD54D7cDa1DabDb2Db9Dc9DcaDe0De2De9CebaD22D39D52D6aD6bD90Da9Dc3Dc6De3De5De7Df1Df5Df6Cda9D3aD3dD4bD4dD5bD83D92D95D9aDa3Dc4Dc8Dd5Df7CedcD21D36D40D48D58D60D67D87D8dDcbDdbDebDecDf0DfbCd99D16D19D27D3cD8cD91DaaDb1Db3Db5Dc7Dd0Dd6De6De8Df8CecbD02D1dD31D41D49D51D5aD64D74D7dD80D84DccDd3DdcDedCdb9D00D1eD5dD5eD6eD8aD8eD93Da5DaeDb6DbeDeeDf4DfeCeddD07D0dD47D50D56D59D65D75D76D78D97D9cDa7Db8Dda"{
  showHelp();
}

macro "measure image [f2]" {
   measureCurrentImage();
}


macro "Measure Image (f2) Action Tool - C037T4d14m"{
  measureCurrentImage();
}

macro "Measure Image (f2) Action Tool Options" {
	Dialog.create("Options of MRI Fibrosis Tool");
	Dialog.addNumber("red 1:", r1);
	Dialog.addNumber("green 1:", g1);
	Dialog.addNumber("blue 1:", b1);
	Dialog.addNumber("red 2:", r2);
	Dialog.addNumber("green 2:", g2);
	Dialog.addNumber("blue 2:", b2);
	Dialog.addNumber("red 3:", r3);
	Dialog.addNumber("green 3:", g3);
	Dialog.addNumber("blue 3:", b3);
	Dialog.addString("file ext.:", _EXT);
	Dialog.addCheckbox("remove scale", _REMOVE_SCALE);
	Dialog.show();
	r1 = Dialog.getNumber();
	g1 = Dialog.getNumber();
	b1 = Dialog.getNumber();
	r2 = Dialog.getNumber();
	g2 = Dialog.getNumber();
	b2 = Dialog.getNumber();
	r3 = Dialog.getNumber();
	g3 = Dialog.getNumber();
	b3 = Dialog.getNumber();
	_EXT = Dialog.getString();
	_REMOVE_SCALE = Dialog.getCheckbox();
}

macro "run batch [f3]" {
   measureCurrentImage();
}

macro "Run Batch (f3) Action Tool - C037T4d14b"{
  batchMeasureImages();
}

macro "Run Batch (f3) Action Tool Options" {
	Dialog.create("Options of MRI Fibrosis Batch Tool");
	Dialog.addString("control folder", _CONTROL_FOLDER);
	Dialog.addString("results table", _RESULTS_TABLE);
	Dialog.show();
	_CONTROL_FOLDER = Dialog.getString();
	_RESULTS_TABLE = Dialog.getString();
}

function measureCurrentImage() {
	if (_REMOVE_SCALE) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	run("Set Measurements...", "area mean standard modal min display redirect=None decimal=3");
	getPixelSize(unit, pixelWidth, pixelHeight);
	run("RGB Color");
	run("Restore Selection");
	run("Clear Outside");
	run("Measure");
	run("Colour Deconvolution", "vectors=[User values] [r1]="+r1+" [g1]="+g1+" [b1]="+b1+" [r2]="+r2+" [g2]="+g2+" [b2]="+b2+" [r3]="+r3+" [g3]="+g3+" [b3]="+b3);
	close();
	close();
	setAutoThreshold("Default");
	run("Create Selection");
	run("Set Scale...", "distance=1 known="+pixelWidth+" pixel=1 unit="+unit);
	run("Measure");
	close();
	close();
	run("Restore Selection");
	imageTitle = getTitle();
	parts = split(imageTitle, _EXT);
	imageTitle = parts[0];
	title = _RESULTS_TABLE;
  	handle = "["+_RESULTS_TABLE+"]";
	if (!isOpen(_RESULTS_TABLE)) {
 	    Table.create(title);
		Table.setLocationAndSize(100, 100 ,600, 400);
	    print(handle, "\\Headings:title\ttotal area\tfibrosis area\trelative fibrosis area");
	}
	totalArea = getResult("Area",  nResults-2);
	fibrosisArea = getResult("Area",  nResults-1);
	relativeFibrosisArea = fibrosisArea / totalArea;
	print(handle, imageTitle + "\t" + totalArea + "\t" + fibrosisArea + "\t" + relativeFibrosisArea);
}

function batchMeasureImages() {
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	startTimeStamp = "" + year + "-" + (month + 1)+"-"+dayOfMonth+"--"+hour+"."+minute+"."+second+"."+msec;
	handle = "["+_RESULTS_TABLE+"]";
	if (isOpen(_RESULTS_TABLE)) print(handle, "\\Clear");
	dir = getDirectory("Please select the input folder!");
	files = getFileList(dir);
	images = newArray();
	for(i=0; i<files.length; i++) {
		if (endsWith(files[i], ".tif")) images = Array.concat(images, files[i]);
	}
	File.makeDirectory(dir + _CONTROL_FOLDER);
	for (i=0; i<images.length; i++) {
		open(dir + images[i]);
		measureCurrentImage();
		saveAs("Tiff", dir + _CONTROL_FOLDER + "/" + images[i]);
		close();
		if (nImages>0) close();
	}
	selectWindow(_RESULTS_TABLE);
	saveAs("Text", dir + _RESULTS_TABLE + "-" + startTimeStamp + ".xls");
}

function showHelp() {
     run('URL...', 'url='+helpURL);
}
