var _WIDTH_OF_ROI = 12.26;
var _HEIGHT_OF_ROI = 6.72;
var _Y_MAX_DIST = _HEIGHT_OF_ROI/2;
var _X_MAX_DIST = _WIDTH_OF_ROI/2;
var _FIRST_TIME_POINT = 25;
var _CHANNEL = 1;
var _SIGMA = 1.4;
var _THRESHOLDING_METHOD = "Minimum";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _MIN_SPOT_SIZE = 5;
var _MEASURE_REGION = true;
var _MEASURE_SPOTS = true;
var _DISPLAY_PLOTS = false;
var _TABLE_TITLE = "Calcium Signal Measurements";
var _FILE_EXTENSION = "czi";
var _OUT_FOLDER = "control-images";
var _REGIONS_FOLDER = "regions";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Calcium_Signals_In_Spines";

exit();

macro "Analyze Calcium Signals in Spines Action Tool (f1) - C000D0fD4fDccDdeDedDefDf9DfaDfeDffC050D04D0aD21D23D32D43D52D60D70D88D8eD91Da4Db2DbdDc0Dc5C020D06D09D33D45D58D63D94D95Dc6Dc7De2De3Df2Df7DfcC0f0D01D0bD0cD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD28D29D2aD2bD3bD3cD4bD4cD5bD6aD6bD6eD6fD7aD7bD7eD7fD8aD8bD99D9aD9bD9cD9dD9eDa5Da6Da7Da8Da9DaaDabDacDadDaeDafDb4Db5Db6Dc1Dc2Dc3Dd0Dd1Dd2De0Df0C010D0eD34D37D44D49D55D57D59D64D66D67D68D6cD93Db8Dc8DcdDd4Dd8DddDe5Df3Df6C090D03D20D5aD72D75D86D8fDb7Dc4De1C030D39D51D7dD92Da0Db1DecC010D1fD2dD35D47D48D4eD54D69Da3DbaDbfDc9DcbDceDd5Dd6Dd7Dd9DdaDe4De7De8De9DeaDf8DfbC070D0dD25D71D73D74D76D77D78D79D83D84D85D89D90Dd3C030D05D07D22D50D53D61D62DbcDbeDebDf1C0d0D00D02D24D26D2cD4dD5dD80D81D8cDb3C040D08D30D31D38D3aD6dD96D97Db0C000D1dD1eD2eD2fD36D3dD3eD3fD46D56D5fD65Db9DbbDcaDcfDdbDdcDdfDe6DeeDf5DfdC060D27D41D5eD87C020D40D4aD7cDa1Da2Df4C0a0D42D5cD82D8dD98D9f" {
	run('URL...', 'url='+helpURL);
}

macro "help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "Find Region Action Tool (f2) - C000T4b12f" {
	placeRegion();
}

macro "Find Region Action Tool (f2) Options" {
	Dialog.create("Find Region Options");
	
	Dialog.addNumber("width of region: ", _WIDTH_OF_ROI);
	Dialog.addNumber("height of region: ", _HEIGHT_OF_ROI);
	
	Dialog.show();
	
	_WIDTH_OF_ROI = Dialog.getNumber();
	_HEIGHT_OF_ROI = Dialog.getNumber();
}

macro 'find region [f2]' {
	placeRegion();
}

macro 'analyze calcium spots [f3]' {
	runAnalysis();
}


macro "Analyze Calcium Spots Action Tool (f3) - C000T4b12a" {
	runAnalysis();
}

macro "Analyze Calcium Spots Action Tool (f3) Options" {
	Dialog.create("Analyze Calcium Spots Options");
	
	Dialog.addNumber("first timepoint: ", _FIRST_TIME_POINT);
	Dialog.addNumber("channel: ", _CHANNEL);
	Dialog.addNumber("sigma Gaussian blur: ", _SIGMA);
	Dialog.addChoice("thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD);
	Dialog.addNumber("min. spot size: ", _MIN_SPOT_SIZE);
	Dialog.addCheckbox("measure whole region", _MEASURE_REGION);
	Dialog.addCheckbox("measure spots", _MEASURE_SPOTS);
	Dialog.addCheckbox("display plots", _DISPLAY_PLOTS);
	Dialog.addString("file extension: ", _FILE_EXTENSION);
	
	Dialog.show();
	
	_FIRST_TIME_POINT = Dialog.getNumber();
	_CHANNEL = Dialog.getNumber();
	_SIGMA = Dialog.getNumber();
	_THRESHOLDING_METHOD = Dialog.getChoice();
	_MIN_SPOT_SIZE = Dialog.getNumber();
	_MEASURE_REGION = Dialog.getCheckbox();
	_MEASURE_SPOTS = Dialog.getCheckbox();
	_DISPLAY_PLOTS = Dialog.getCheckbox();
	_FILE_EXTENSION = Dialog.getString();
}

macro 'batch process images [f4]' {
	batchProcessImages();	
}

macro "Batch Process Images Action Tool (f4) - C000T4b12b" {
	batchProcessImages();
}

macro 'batch find regions [f5]' {
	batchFindRegions();	
}

macro "Batch Find Regions Action Tool (f5) - C000T4b12r" {
	batchFindRegions();
}

function runAnalysis() {
	if (selectionType() == -1) 
		rect = placeRegion();
	else {
		getBoundingRect(posX, posY, widthRegion, heightRegion);
		rect = newArray(posX, posY, widthRegion, heightRegion);
		Overlay.addSelection;
		Overlay.show;
	}
	imageID = getImageID();
	title = getTitle();
	if (_MEASURE_REGION) {
		values = measure();
		reportData(values, "ROI-"+title);
		if (_DISPLAY_PLOTS) plot("mean int. complete zone", values);
	}
	selectImage(imageID);
	if (_MEASURE_SPOTS) {
		detectSpots();
		roiImageID = getImageID();
		values = measureSpots();
		reportData(values, "spots-"+title);
		if (_DISPLAY_PLOTS) plot("mean int. spots", values);
		selectImage(imageID);
		run("Restore Selection");
		getBoundingRect(x, y, width, height);
		Roi.move(rect[0]+x, rect[1]+y);
		Overlay.addSelection;
		selectImage(roiImageID);
		close();
	}
}

function placeRegion() {
	Stack.getDimensions(width, height, channels, slices, frames);
	widthRegion = _WIDTH_OF_ROI;
	heightRegion = _HEIGHT_OF_ROI;
	toUnscaled(widthRegion);
	toUnscaled(heightRegion);
	
	xMaxDist = _X_MAX_DIST;
	yMaxDist = _Y_MAX_DIST;
	toUnscaled(xMaxDist);
	toUnscaled(yMaxDist);
	
	roiManager("select", 0);
	getBoundingRect(x, y, width, height);

	run("From ROI Manager");
	
	xStart = x-widthRegion+width;
	yStart = y-heightRegion+height;
	
	xEnd = x;
	yEnd = y;
	
	
	currentMean = 0;
	posX = 0; 
	posY = 0;

	Stack.setFrame(frames);
	
	for(x=xStart; x<=xEnd; x++) {
		for(y=yStart; y<=yEnd; y++) {
			makeRectangle(x, y, widthRegion, heightRegion);
			getStatistics(area, mean);
			if (mean>currentMean) {
				currentMean=mean;
				posX = x;
				posY = y;
			}
		}
	}
	makeRectangle(posX, posY, widthRegion, heightRegion);
	Overlay.addSelection;
	Overlay.show;
	rect = newArray(posX, posY, widthRegion, heightRegion);
	return rect;
}

function measure() {
	Stack.getDimensions(width, height, channels, slices, frames);
	values = newArray(frames);
	Stack.setFrame(_FIRST_TIME_POINT-1);
	getStatistics(area, meanT0);
	for(t=1; t<=frames; t++) {
		Stack.setFrame(t);
		getStatistics(area, mean);
		values[t-1] = mean / meanT0;
	}
	Stack.setFrame(1);
	return values;
}

function plot(title, values) {
	timePoints = getTimePoints();
	Stack.getUnits(X, Y, Z, Time, Value);
	
	Plot.create(title, "t ["+Time+"]", "int.", timePoints, values);
	Plot.show();
}

function detectSpots() {
	roiManager("Reset");
	inputImageID = getImageID();
	run("Duplicate...", "duplicate channels="+_CHANNEL+"-"+_CHANNEL);
	roiImageID = getImageID();
	run("Duplicate...", "duplicate channels="+_CHANNEL+"-"+_CHANNEL);
	maskID = getImageID();
	run("32-bit");
	max = 0;
	for(t=1; t<_FIRST_TIME_POINT; t++) {
		Stack.setFrame(t);
		getStatistics(area, mean);
		if (mean>max) max = mean;
	}
	run("Divide...", "value="+max+" stack");
	run("Enhance Contrast", "saturated=0.35");
	run("Gaussian Blur...", "sigma="+_SIGMA+" stack");
	setAutoThreshold(_THRESHOLDING_METHOD +" dark");
	run("Analyze Particles...", "size="+_MIN_SPOT_SIZE+"-Infinity pixel add stack");
	run("8-bit");
	roiManager("Fill");
	run("Macro...", "code=v=(v==255)*255 stack");
	count = roiManager("count");
	toBeRemoved = newArray();
	Stack.getDimensions(width, height, channels, slices, frames);
	for(i=0; i<count; i++) {
		roiHasPredecessor = false;
		roiHasSuccessor = false;
		roiManager("select", i);
		Stack.getPosition(channel, slice, frame);
		if (frame<_FIRST_TIME_POINT) {
			toBeRemoved = Array.concat(toBeRemoved, i);
			continue;
		}
		if (frame<frames) {
			Stack.setFrame(frame+1);
			getStatistics(area, mean);
			if (mean>0) roiHasSuccessor=true;
		}
		if (frame>1) {
			Stack.setFrame(frame+1);
			getStatistics(area, mean);
			if (mean>0) roiHasPredecessor=true;
		}
		if (!(roiHasSuccessor || roiHasPredecessor)) toBeRemoved = Array.concat(toBeRemoved, i);
	}
	roiManager("select", toBeRemoved);
	roiManager("Delete");
	Stack.setFrame(1);
	run("Select None");
	selectImage(maskID);
	close();
	selectImage(roiImageID);
}

function measureSpots() {
	roiImageID = getImageID();
	roiManager("combine");
	values = measure();
	return values;
}

function getTimePoints() {
	frameInterval = Stack.getFrameInterval();
	Stack.getDimensions(width, height, channels, slices, frames);
	timePoints = newArray(frames);
	for(i=0; i<timePoints.length; i++) {
		timePoints[i] = i * frameInterval;
	}
	return timePoints;
}

function createTable() {
	if (isOpen(_TABLE_TITLE)) return;
	resetTable();
}

function resetTable() {
	Table.create(_TABLE_TITLE);
	timePoints = getTimePoints();
	Stack.getUnits(X, Y, Z, Time, Value);
	Table.setColumn("t ["+Time+"]", timePoints);
}

function reportData(values, title) {
	createTable();
	selectWindow(_TABLE_TITLE);
	Table.setColumn(title, values);
}

function batchProcessImages() {
	displayPlots = _DISPLAY_PLOTS;
	_DISPLAY_PLOTS = false;
	dir = getDirectory("Select the input folder!");
	File.makeDirectory(dir+"/"+_OUT_FOLDER);
	files = getFileList(dir);
	files = filterFiles(dir, files);
	setBatchMode(true);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	print("\\Clear"); 
	print("Analyze Calcium Signal started at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	for (i = 0; i < files.length; i++) {
		print("\\Update1: Processing image " + (i+1) + "/" + files.length);
		file = files[i];
		roiManager("reset");
		if (endsWith(file, _FILE_EXTENSION)) {
			run("Bio-Formats", "open=["+dir+"/"+file+"] autoscale color_mode=Default display_rois rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT");
			if (nImages>1) close();
			Stack.getDimensions(width, height, channels, slices, frames);
			count = roiManager("count");
			if (frames<2 || count<1) {
				print("skipped image " + file);
				if (nImages>0) close();
				continue;
			}
		} else {
			open(dir+"/"+file);
		}
		if (i==0) resetTable();
		runAnalysis();
		selectWindow("Log");
		outFile = replace(file, "."+_FILE_EXTENSION, ".tif");
		saveAs("tif", dir+"/"+_OUT_FOLDER+"/"+outFile);
		close();
	}
	_DISPLAY_PLOTS = displayPlots;
	selectWindow(_TABLE_TITLE);
	Table.save(dir+"/"+_TABLE_TITLE+".xls");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("Analyze Calcium Signal finished at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	setBatchMode(false);
}

function filterFiles(dir, files) {
	filteredFiles = newArray(0);
	for(i=0; i<files.length; i++) {
		file = files[i];
		if (File.isDirectory(dir + "/" + file)) continue;
		if (!endsWith(file, "."+_FILE_EXTENSION) && !endsWith(file, ".tif")) continue;
		filteredFiles = Array.concat(filteredFiles, file);
	}
	return filteredFiles;
}

function batchFindRegions() {
	dir = getDirectory("Select the input folder!");
	File.makeDirectory(dir+"/"+_REGIONS_FOLDER);
	files = getFileList(dir);
	files = filterFiles(dir, files);
	setBatchMode(true);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	print("\\Clear"); 
	print("Batch Find Regions started at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	for (i = 0; i < files.length; i++) {
		print("\\Update1: Processing image " + (i+1) + "/" + files.length);
		file = files[i];
		roiManager("reset");
		run("Bio-Formats", "open=["+dir+"/"+file+"] autoscale color_mode=Default display_rois rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT");
		if (nImages>1) close();
		Stack.getDimensions(width, height, channels, slices, frames);
		count = roiManager("count");
		if (frames<2 || count<1) {
			print("skipped image " + file);
			if (nImages>0) close();
			continue;
		}
		rect = placeRegion();
		makeRectangle(rect[0], rect[1], rect[2], rect[3]);
		selectWindow("Log");
		
		outFile = replace(file, "."+_FILE_EXTENSION, ".tif");
		saveAs("tif", dir+"/"+_REGIONS_FOLDER+"/"+outFile);
		close();
	}
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("Analyze Calcium Signal finished at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	setBatchMode(false);
}
