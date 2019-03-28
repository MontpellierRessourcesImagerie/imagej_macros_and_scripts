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



