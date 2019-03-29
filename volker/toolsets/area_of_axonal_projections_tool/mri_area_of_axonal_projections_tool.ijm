/**
  * MRI Area of Axonal Projections Tools
  * 
  * Measure the area of the axonal projections relative to the zone they are in.
  *   
  * (c) 2019, INSERM
  * 
  * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 *
*/
var BROWN_CHANNEL = "Colour_2";
var BLUE_CHANNEL = "Colour_1";
var GREEN_CHANNEL = "Colour_3";
var _THRESHOLDING_METHOD_PROJECTIONS = "Yen";
var _TRESHOLDING_METHOD_ZONE = "MaxEntropy";
var _COLOR_VECTORS = "[H DAB]";
var _MIN_SIZE_ZONE = 1000000;
var _MIN_SIZE_PROJECTIONS = 500;
var _SIGMA_BLUR = 2;
var _CLOSE_RADIUS = 4/*0*/;
var _TABLE_TITLE = "area of axonal projections";
var _EXLUCDE_ON_EDGES_ZONE = true;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Area-of-Axonal-Projections-Tool";

macro "area of axonal projections tools help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "area of axonal projections tools help (f4) Action Tool - C655D00C654L1040C665D50C656D60C766D70C655D80C554D90C555Da0C656Lb0c0C767Dd0C877De0C767Df0C654L0141C665L5171C554D81C544D91C655Da1C656Db1C667Dc1C767Dd1C766De1C667Df1C654D02C554D12C544D22C654D32C554D42C655L5262C554D72C544D82C655D92C656La2b2C667Lc2f2C554D03C544L1333C554D43C655L5363C544D73C554D83C656L93b3C667Lc3f3C544L0434C555D44C655L5464C555D74C655D84C656L94b4C667Dc4C766Dd4C767Le4f4C544D05C554D15C654D25C555D35C655L4555C555D65C554D75C665D85C656L95a5C667Db5C766Dc5C767Ld5f5C654D06C554D16C555D26C654D36C655L4656C654L6676C665D86C766D96C667Da6C766Db6C767Dc6C877Dd6C767De6C766Df6C655D07C654D17C655D27C665L3747C766D57C654L6777C665D87C766D97C767Da7C766Db7C877Lc7f7C767D08C766D18C665D28C766L3848C655D58C654D68C543D78C655D88C766L98b8C877Dc8C766Dd8C877Le8f8C766D09C665D19C655D29C766D39C655D49C654D59C543L6989C654L99a9C766Lb9d9C877De9C767Df9C655L0a1aC555D2aC654L3a4aC532L5a8aC543L9aaaC654DbaC655DcaC766DdaC877DeaC767DfaC655D0bC554L1b2bC654D3bC543D4bC532L5b7bC543L8b9bC544LabbbC543DcbC555DdbC767LebfbC555D0cC544D1cC543L2c3cC532L4c7cC544D8cC543D9cC544LacbcC543DccC555DdcC656LecfcC555D0dC554L1d2dC654D3dC543D4dC532L5d9dC543DadC544DbdC555DcdC655LddedC554DfdC766D0eC665L1e2eC655L3e4eC654L5e6eC554D7eC544D8eC554D9eC555DaeC665DbeC656DceC665DdeC655DeeC555DfeC766L0fafC665DbfC766DcfC665DdfC655DefC665Dff" {
	run('URL...', 'url='+helpURL);
}

macro "select zone [f1]" {
	
}

measureAreaOfAxonalProjections();

function measureAreaOfAxonalProjections() {
	createTable(_TABLE_TITLE);
	run("Set Measurements...", "area limit display redirect=None decimal=3");
	title = getTitle();
	imageID = getImageID();
	brownTitle = title+"-("+BROWN_CHANNEL+")";
	blueTitle = title+"-("+BLUE_CHANNEL+")";
	greenTitle = title+"-("+GREEN_CHANNEL+")";
	run("Colour Deconvolution", "vectors="+_COLOR_VECTORS+" hide");
	selectImage(greenTitle);
	close();
	selectImage(imageID);
	
	zoneArea = detectZone(imageID, blueTitle);
	selectImage(blueTitle);
	close();
	projectionsArea = detectProjections(imageID, brownTitle);

	report(_TABLE_TITLE, title, zoneArea, projectionsArea);
	run("Select None");
}

function detectZone(imageID, channelTitle) {
	run("Remove Overlay");
	run("Select None");
	selectImage(channelTitle);
	run("Duplicate...", " ");
	maskID = getImageID();
	run("Invert");
	run("Gaussian Blur...", "sigma="+_SIGMA_BLUR);
	setAutoThreshold(_TRESHOLDING_METHOD_ZONE + " dark");
	run("Convert to Mask");
	setAutoThreshold("Default");
	excludeText = "";
	if (_EXLUCDE_ON_EDGES_ZONE) excludeText = "exclude";
	run("Analyze Particles...", "size="+_MIN_SIZE_ZONE+"-Infinity show=Masks "+excludeText+" in_situ");
	run("Fill Holes");
	run("Options...", "iterations="+_CLOSE_RADIUS+" count=1 do=Close");
	run("Create Selection");
	getStatistics(area);
	selectImage(imageID);
	run("Restore Selection");
	Overlay.addSelection;
	Overlay.show;
	selectImage(maskID);
	close();
	return area;
}

function detectProjections(imageID, channelTitle) {
	selectImage(channelTitle);
	run("8-bit");
	channelID = getImageID();
	run("Restore Selection");
	getStatistics(area, mean);
	selectImage(channelTitle);
	run("Make Inverse");
	fillValue = round(mean);
	setColor(fillValue, fillValue, fillValue);
	selectImage(channelID);
	fill();
	run("Select None");
	setAutoThreshold(_THRESHOLDING_METHOD_PROJECTIONS);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Analyze Particles...", "size="+_MIN_SIZE_PROJECTIONS+"-Infinity show=Masks in_situ");
	setAutoThreshold("Default");
	run("Measure");
	areaProjections = getResult("Area", nResults-1);
	run("Create Selection");
	selectImage(imageID);
	run("Restore Selection");
	Overlay.addSelection("cyan");
	selectImage(channelTitle);
	close();
	return areaProjections;
}

function createTable(title) {
	if (!isOpen(title)) {
		Table.create(title);
	}
}

function report(tableTitle, inputImageTitle, areaZone, areaProjections) {
	ratio = areaProjections / areaZone;
	selectWindow(tableTitle);
	counter = Table.size;
	if (counter<0) counter=0;
	Table.update;	
	Table.set("image", counter, inputImageTitle);
	Table.set("area of the zone", counter, areaZone);
	Table.set("area of projections", counter, areaProjections);
	Table.set("ratio of areas", counter, ratio);
	Table.update;
}



