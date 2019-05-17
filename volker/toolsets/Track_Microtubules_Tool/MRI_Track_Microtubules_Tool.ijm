var _EXT = "nd";

var	_RECTANGLE_WIDTH = 10;

var _LINE_WIDTH_KYMOGRAPH = 7;
var _COLUMNS = 5
var _CREATE_PLOTS = true;
var _CREATE_KYMOGRAPHS = true;
var _KEEP_PLOT = false;
var _ADDITIONAL_KYMOGRAPH_LENGTH = 20;
var _CURRENT_IMAGE_ID = -1;
var _CURRENT_SKELETON_ID = -1;
var _SMOOTHING_SCALE = 2;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Track_Microtubules_Tool";

macro "track microtubules tools help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "track microtubules tools help Action Tool (f1) - C111D01D02D05D06D07D08D0cD0dD0eD0fD1cD1dD1fD28D29D2aD2bD2cD2dD2fD35D38D39D3aD3bD3cD3dD41D46D47D48D49D4aD4bD4cD4dD4eD4fD51D5cD5dD5eD5fD60D70D9fDa0Da1Da2Db0Db1Db2Db4Db9DbaDbeDc0Dc1Dc2Dc4Dc5Dc9DcbDccDceDcfDd0Dd1Dd2Dd3Dd4Dd5DddDdeDdfDe0De1De2De3De4DeeDefDf0Df1Df2Df3Df4C222D0aD0bD10D1aD20D27D32D33D52D53D54D58D6cD92D94D97D98D99D9aD9bD9cD9eDd7Dd8Dd9De6De8De9Df6Df7DfeDffC111D00D03D04D09D11D12D13D14D15D16D17D18D19D1bD1eD21D22D23D24D25D26D2eD30D31D34D36D37D3eD3fD40D42D43D44D45D50D55D56D57D59D5aD5bD80D90D91Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb3Db5Db6Db7Db8DbbDbcDbdDbfDc3Dc6Dc7Dc8DcaDcdDd6DdaDdbDdcDe5DeaDebDecDedDf5Df8Df9DfaDfbDfcDfdC333D66D69D86D87C222D6bD93D95D96De7C737D61D62D63D71D72D73D81D82D83C277D6dD6eD6fD7dD7eD7fD8dD8eD8fC333D6aD84D85C555D8cC444D64C888D74D75D76D77D78D79D7aD7bD7cC444D65D67D68D88D9dC555D89D8aD8b" {
	run('URL...', 'url='+helpURL);
}

macro 'stack registration [f2]' {
	registerStacks();
}

macro "stack registration Action Tool (f2) - C000T4b12s" {
	registerStacks();	
}

macro "stack registration Action Tool (f2) - C000T4b12s" {
	registerStacks();	
}

macro "stack registration Action Tool (f2) Options" {
	Dialog.create("Stack Registration Options");
	Dialog.addString("image file extension: ", _EXT);
	Dialog.show();
	_EXT = Dialog.getString();
}

macro 'track microtubules [f3]' {
	skeletonizeMicrotubules();
	findEndPoints(_CURRENT_IMAGE_ID);
	trackEnds();
}


macro "track microtubules Action Tool (f3) - C000T4b12t" {
	skeletonizeMicrotubules();
	findEndPoints(_CURRENT_IMAGE_ID);
	trackEnds();
}

macro "track microtubules Action Tool (f3) Options" {
	Dialog.create("Track Microtubules Options");
	Dialog.addNumber("smoothing scale: ", _SMOOTHING_SCALE);
	Dialog.addNumber("width of rectangle: ", _RECTANGLE_WIDTH);
	Dialog.show();
	_SMOOTHING_SCALE = Dialog.getNumber();
	_RECTANGLE_WIDTH = Dialog.getNumber();
}

macro "add to selection Action Tool (f4) - C000T4b12a" {
	addToSelection();
}

macro 'add to selection [f4]' {
	addToSelection();
}

macro "remove from selection Action Tool (f5) - C000T4b12r" {
	removeFromSelection();
}

macro 'remove from selection [f5]' {
	removeFromSelection();
}

macro "measure selected microtubules Action Tool (f6) - C000T4b12m" {
	measureSelectedMicrotubules();
}

macro "measure selected microtubules Action Tool (f6) Options" {
	Dialog.create("Measure Selected Microtubules Options");
	Dialog.addNumber("additional line length for kymographs: ", _ADDITIONAL_KYMOGRAPH_LENGTH);
	Dialog.addNumber("line width kymograph: ", _LINE_WIDTH_KYMOGRAPH);
	Dialog.addNumber("columns montage: ", _COLUMNS);
	Dialog.addCheckbox("create plots", _CREATE_PLOTS);
	Dialog.addCheckbox("create kymographs", _CREATE_KYMOGRAPHS);
	Dialog.addCheckbox("keep plots", _KEEP_PLOT);
	Dialog.show();
	_ADDITIONAL_KYMOGRAPH_LENGTH = Dialog.getNumber();
	_LINE_WIDTH_KYMOGRAPH = Dialog.getNumber();
	_COLUMNS = Dialog.getNumber();
	_CREATE_PLOTS = Dialog.getCheckbox();
	_CREATE_KYMOGRAPHS = Dialog.getCheckbox();
	_KEEP_PLOT = Dialog.getCheckbox();
}

macro 'measure selected microtubules [f6]' {
	measureSelectedMicrotubules();
}

function registerStacks() {
	inDir = getDirectory("Please select the input directory!");
	files = getFileList(inDir);
	ndFiles = filterFiles(files);
	regDir = inDir+"reg"+File.separator;
	File.makeDirectory(regDir);
	print("\\Clear");
	print("\\Update0:Stackreg started...")
	for (i = 0; i < ndFiles.length; i++) {
		print("\\Update1:Processing image "+(i+1)+ " of "+ ndFiles.length);
		file = ndFiles[i];
		path = inDir + file;
		run("Bio-Formats", "open="+path+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("StackReg ", "transformation=[Rigid Body]");
		saveAs("tiff", regDir+file);
		close();
	}
	print("\\Update2:Stackreg finished...")
}

function skeletonizeMicrotubules() {
	_CURRENT_IMAGE_ID = getImageID();
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	roiManager("reset");
	run("Remove Overlay");
	run("Remove Overlay");
	run("FeatureJ Laplacian", "compute smoothing="+_SMOOTHING_SCALE);
	run("Convert to Mask", "method=Default background=Light calculate");
	run("Analyze Particles...", "size=1.0-Infinity add slice exclude");
	count = roiManager("count");
	if (count>1) roiManager("Combine");
	else roiManager("select", 0);
	run("Clear Outside", "stack");
	roiManager("deselect");
	run("Select None");
	run("Skeletonize", "stack");
	_CURRENT_SKELETON_ID = getImageID();
}

function filterFiles(files) {
	newFiles = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, "."+_EXT)!=-1) {
			newFiles = Array.concat(newFiles, file);
		}
	}
	return newFiles;
}

function findEndPoints(imageID) {
	runPythonScript("microtubule-tracking.py", "exec=findEndPoints,imageID="+imageID+",maskID="+_CURRENT_SKELETON_ID);

	selectImage(imageID);
	Overlay.activateSelection(0);
	getSelectionCoordinates(START_X1, START_Y1);
	Overlay.activateSelection(1);
	getSelectionCoordinates(START_X2, START_Y2);
	run("Select None");
	
	roiManager("Deselect");
	roiManager("reset");
	for (i = 0; i < START_X1.length; i++) {
		makeRotatedRectangle(START_X1[i], START_Y1[i], START_X2[i], START_Y2[i], _RECTANGLE_WIDTH);
		roiManager("add");
	}
	run("Select None");
	roiManager("Set Color", "yellow");
	roiManager("Show None");
	roiManager("Show All");
}

function trackEnds() {
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("Select", i);
	    runPythonScript("microtubule-tracking.py", "exec=trackEnds,imageID="+_CURRENT_IMAGE_ID+",maskID="+_CURRENT_SKELETON_ID);
	}
	roiManager("Deselect");
	run("Select None");
}

function addToSelection() {
	roiManager("Set Color", "green");
	run("Select None");
}

function removeFromSelection() {
	roiManager("Set Color", "yellow");
	run("Select None");
}

function measureSelectedMicrotubules() {
	title = getTitle();
	if (indexOf(title, "Laplacian")>=0) {
		parts = split(title, " ");
		title = parts[0];
		selectImage(title);
	}
	count = roiManager("count");
	counter = 1;
	for (i = 0; i < count; i++) {
		roiManager("Select", i);
		color = Roi.getStrokeColor;
		if (color=="green") {
			index = roiManager("index");
			measureMicrotubule(index, counter);
			counter++;
		}
	}
	if (counter<2) return;
    if (_CREATE_PLOTS) makeMontageOfPlots();
    if (_CREATE_KYMOGRAPHS) makeMontageOfKymographs();
}

function makeMontageOfKymographs() {
    titles = getList("image.titles");
	maxWidth = -1;
	nrOfMTs = 0;
	for (i = 0; i < titles.length; i++) {
		title = titles[i];
		if (indexOf(title, "Kymograph") >= 0) {
			nrOfMTs++;
			selectImage(title);
			width = getWidth();
			if (width>maxWidth) maxWidth = width;
		}
	}
	for (i = 0; i < titles.length; i++) {
		if (indexOf(title, "Kymograph") >= 0) {
			height = getHeight();
			run("Canvas Size...", "width="+maxWidth+" height="+height+" position=Center zero");
		}
	}
	if (nrOfMTs>1) {
  	    run("Images to Stack", "name=kymos title=Kymograph");
	    stackID = getImageID();
	    rows = floor(nSlices / _COLUMNS);
	    if ((nSlices % _COLUMNS)>0) rows++;
	    run("Make Montage...", "columns="+_COLUMNS+" rows="+rows+" scale=1 border=2 label");
		selectImage(stackID);
		close();	
	}
}

function makeMontageOfPlots() {
	titles = getList("image.titles");
	yMaxGlobal = 0;
	xMaxGlobal = 0;
	for (i = 0; i < titles.length; i++) {
		title = titles[i];	
		if (indexOf(title, "Plot of MT") >= 0) {
			selectImage(title);
			Plot.getValues(xpoints, ypoints);
			Array.getStatistics(ypoints, ymin, ymax);
			if (ymax>yMaxGlobal) {
				yMaxGlobal = ymax;
			}
			Array.getStatistics(xpoints, xmin, xmax);
			if (xmax>xMaxGlobal) {
				xMaxGlobal = xmax;
			}
		}
	}
	for (i = 0; i < titles.length; i++) {
		title = titles[i];	
		selectImage(title);
		if (indexOf(title, "Plot of MT") >= 0) {
			Plot.setLimits(0, xMaxGlobal, 0, yMaxGlobal);
		}
	}
	keepOption = "";
	if (_KEEP_PLOT) keepOption = "keep";
	run("Images to Stack", "name=plots title=Plot of MT "+keepOption);
	stackID = getImageID();
	rows = floor(nSlices / _COLUMNS);
	if ((nSlices % _COLUMNS)>0) rows++;
	run("Make Montage...", "columns="+_COLUMNS+" rows="+rows+" scale=1 border=2 label");
	selectImage(stackID);
	close();
}
function measureMicrotubule(index, number) {
	imageID = getImageID();
	title = getTitle();
	Overlay.activateSelection(0);
	getSelectionCoordinates(xpoints1, ypoints1);
	Overlay.activateSelection(1);
	getSelectionCoordinates(xpoints2, ypoints2);
	x1 = xpoints1[index];
	y1 = ypoints1[index];
	x2 = xpoints2[index];
	y2 = ypoints2[index];
	makeLine(x1, y1, x2, y2);
	length = sqrt(pow(x2-x1, 2) + pow(y2-y1, 2));
	if (_CREATE_KYMOGRAPHS) {
		newLength = length + _ADDITIONAL_KYMOGRAPH_LENGTH;
		scaleFactor = newLength / length;
	    run("Scale... ", "x="+scaleFactor+" y="+scaleFactor+ " centered");
	    run("Multi Kymograph", "linewidth="+_LINE_WIDTH_KYMOGRAPH);
	}
	selectImage(imageID);
	setSlice(1);
	trackIndex1 = (2*index) + 2;
	trackIndex2 = trackIndex1 + 1;
	Overlay.activateSelection(trackIndex1);
	speedStats1 = newArray(6);	// avg., stdDev., min. and max. speed, length, distance
    type = selectionType();
    if (type==-1) {
		xpointsLeft=newArray(0,0);
		ypoints=newArray(0,0);
    } else {
    	getSelectionCoordinates(xpointsLeft, ypoints);
    }
	measureSpeed(xpointsLeft, ypoints, speedStats1, index+1, "end 1");
	Overlay.activateSelection(trackIndex2);
	speedStats2 = newArray(6);	// avg., stdDev., min. and max. speed, length, distance
	type = selectionType();
    if (type==-1) {
		xpointsRight=newArray(0,0);
		ypoints=newArray(0,0);
    } else {
    	 getSelectionCoordinates(xpointsRight, ypoints);	
    }
	measureSpeed(xpointsRight, ypoints, speedStats2, index+1, "end 2");
	selectImage(imageID);
	deltaT = Stack.getFrameInterval();
	reportStats(title, index+1, speedStats1, speedStats2, length, xpointsLeft.length * deltaT, number); 
}

function reportStats(title, index, speedStats1, speedStats2, mtLength, lastFrame, number) {
	tableTitle = "speed of microtubule ends";
	toScaled(mtLength);
	if (!isOpen(tableTitle)) {
		Table.create(tableTitle);
	}
	selectWindow(tableTitle);
	row = Table.size;
	Table.set("image", row, title);
	Table.set("microtubule nr.", row, index);
	Table.set("kymograph nr.", row, number);
	
	Table.set("avg. speed side 1", row, speedStats1[0]);
	Table.set("stdDev side 1", row, speedStats1[1]);
	Table.set("min. speed side 1", row, speedStats1[2]);
	Table.set("max. speed side 1", row, speedStats1[3]);
	Table.set("track length side 1", row, speedStats1[4]);
	Table.set("distance side 1", row, speedStats1[5]);

	Table.set("avg. speed side 2", row, speedStats2[0]);
	Table.set("stdDev side 2", row, speedStats2[1]);
	Table.set("min. speed side 2", row, speedStats2[2]);
	Table.set("max. speed side 2", row, speedStats2[3]);
	Table.set("track length side 2", row, speedStats2[4]);
	Table.set("distance side 2", row, speedStats2[5]);

	Table.set("length of MT", row, mtLength);
	Table.set("last timepoint", row, lastFrame);
	
	Table.update;
}

function measureSpeed(xpoints, ypoints, speedStats, index, side) {
	run("Set Measurements...", "area bounding limit display redirect=None decimal=6");
	speeds = newArray(xpoints.length-1);
	distances = newArray(xpoints.length);
	deltaT = Stack.getFrameInterval();
	time = newArray(xpoints.length);
	for (i = 0; i < time.length; i++) {
		time[i] = i * deltaT;
	}
	length = 0;
	distances[0] = 0;
	for (i = 1; i < xpoints.length; i++) {
		x1 = xpoints[i-1];
		y1 = ypoints[i-1];
		x2 = xpoints[i];
		y2 = ypoints[i];
		toScaled(x1,y1);
		toScaled(x2,y2);
		dist = sqrt(pow(x2-x1,2)+pow(y2-y1,2));
		speeds[i-1] = dist / deltaT;
		distances[i] = dist +  distances[i-1];
		length = length + dist;
	}
	Array.getStatistics(speeds, min, max, mean, stdDev);
	x1 = xpoints[0];
	y1 = ypoints[0];
	x2 = xpoints[xpoints.length-1];
	y2 = ypoints[ypoints.length-1];
	toScaled(x1,y1);
    toScaled(x2,y2);
	distance = sqrt(pow(x2-x1,2)+pow(y2-y1,2));
	speedStats[0] = mean;
	speedStats[1] = stdDev;
	speedStats[2] = min;
	speedStats[3] = max;
	speedStats[4] = length;
	speedStats[5] = distance;
	imageID = getImageID();
	if (_CREATE_PLOTS) {
		Plot.create("Plot of MT "+ index + " - " + side, "time", "distance", time, distances);
		Plot.show();
	}
	selectImage(imageID);
}

function runPythonScript(name, parameters) {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/"+name);
    call("ij.plugin.Macro_Runner.runPython", script, parameters); 
}

