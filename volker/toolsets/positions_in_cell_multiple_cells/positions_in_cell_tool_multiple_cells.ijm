var _MEASURE_DIST_NUCLEI = false;
var _NUCLEI_CHANNEL = 2;
var _SIGNAL_CHANNEL = 1;
var _MIN_NUCLEUS_SIZE =0.002;
var _MIN_CELL_SIZE = 0.0015;
var _USE_WATERSHED_ON_SIGNAL = false;
var _MIN_SIGNAL_SIZE = 0.000035
var _TITLE_OF_TABLE = "Distances to the center of the nuclei and the cell";
var _FILE_EXTENSION="tif";
var _OUT_FOLDER = "control_images";
var _MAX_AREA = 0.0020;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Positions_In_Cell_Tool_Multiple_Cells";

// runTests();
measureAllPositionsInImage();
exit();

macro "Positions In Cell Action Tool (f1) - C100L00f0L0191C110La1b1C200Dc1C110Ld1e1C100Df1L0242C200L5262C410D72C914L82c2C410Dd2C200De2C110Df2C200D03C410L1333C710L4363Ce27D73Cf68D83Ce94L93b3Cf68Dc3Ce27Dd3C710De3C200Df3C410D04C710L1434C831L4454Ce27D64Cf68D74C980D84Cdf0D94C9f0Da4Cdf0Db4C980Dc4Cf68Dd4Ce27De4C410Df4D05C831D15Ce27D25Cf68L3555Ce27D65Ce94D75Cdf0L85c5C831Dd5Cf68De5C710Df5C410D06C914D16Ce94D26C980D36C7e0L4656C980D66C7e0D76Cdf0L86b6C9f0Dc6C980Dd6Cf68De6C980Df6C410D07C914D17Ce94D27C7e0D37C9f0L4767Ce94L7787Cdf0L97b7C9f0Dc7C980Dd7Cf68De7C831Df7C710D08C914D18C831D28C7e0D38C9f0L4868Ce94L7888Cf68D98Cdf0Da8C9f0Db8C7e0Dc8C980Dd8Ce27De8C980Df8C710D09C914D19C831D29C7e0L3949C9f0L5969Ce94D79Cf68L8999Ce94Da9C7e0Db9C980Dc9Ce94Dd9Ce27De9C980Df9C710D0aC914D1aCe94D2aC7e0L3a5aC9f0L6a7aC7e0D8aCf68D9aCe94LaabaCf68DcaCe27DdaC831DeaC980DfaC410D0bC831D1bCe27D2bC831D3bC7e0L4b6bC9f0D7bC980D8bCf68D9bCe27LabbbC831DcbC710LdbebC410DfbC200L0c1cC914D2cCe27D3cC831D4cC980D5cC7e0D6cC980L7c8cCe27D9cC831DacC710LbcccC410LdcfcC100D0dC200L1d2dC914L3d4dCe27D5dC914L6d7dCe27D8dC914D9dC710DadC410DbdC200LcdddC100DedC110DfdC100L0e3eC200D4eC831L5e8eC200L9ebeC100LcefeL0fff" {
	run('URL...', 'url='+helpURL);
}

macro 'Positions In Cell [f1]' {
	run('URL...', 'url='+helpURL);
}

macro "Measure current image Action Tool (f2) - C000T4b12m" {
	measureAllPositionsInImage();
}

macro 'measure current image [f2]' {
	measureAllPositionsInImage();
}

macro "Measure current image Action Tool (f2) Options" {

	Dialog.create("Measure current image options");

	Dialog.addCheckbox("measure dist. to nuclei", _MEASURE_DIST_NUCLEI);
	Dialog.addNumber("nuclei channel: ", _NUCLEI_CHANNEL);
	Dialog.addNumber("signal channel: ", _SIGNAL_CHANNEL);
	Dialog.addNumber("min. area cell: " , _MIN_CELL_SIZE,  6, 8, "");
	Dialog.addNumber("min. area nuclei: ", _MIN_NUCLEUS_SIZE,  6, 8, "");
	Dialog.addCheckbox("use watershed on signal", _USE_WATERSHED_ON_SIGNAL);
	Dialog.addNumber("min. area signal: ", _MIN_SIGNAL_SIZE, 6, 8, "");
	Dialog.addString("title of table: ", _TITLE_OF_TABLE);
	
	Dialog.show();

	_MEASURE_DIST_NUCLEI = Dialog.getCheckbox();
	_NUCLEI_CHANNEL = Dialog.getNumber();
	_SIGNAL_CHANNEL = Dialog.getNumber();
	_MIN_CELL_SIZE = Dialog.getNumber();
	_MIN_NUCLEUS_SIZE = Dialog.getNumber();
	_USE_WATERSHED_ON_SIGNAL = Dialog.getCheckbox();
	_MIN_SIGNAL_SIZE = Dialog.getNumber();
	_TITLE_OF_TABLE = Dialog.getString();
}

macro "Batch measure images Action Tool (f3) - C000T4b12b" {
	batchMeasurePositions();	
}

macro "Batch measure images Action Tool (f3) Options" {
	Dialog.create("Batch measure images options");

	Dialog.addString("file extension: ", _FILE_EXTENSION);
	Dialog.addString("output folder: ", _OUT_FOLDER);
	
	Dialog.show();

	_FILE_EXTENSION = Dialog.getString();
	_OUT_FOLDER = Dialog.getString();
}

macro 'batch measure positions [f3]' {
	batchMeasurePositions();	
}

function batchMeasurePositions() {
	dir = getDirectory("Select the input folder!");
	File.makeDirectory(dir+"/"+_OUT_FOLDER);
	files = getFileList(dir);
	files = filterFiles(dir, files);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);

	print("\\Clear"); 
	print("Analyze Positions In Cell started at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	for (i = 0; i < files.length; i++) {
		print("\\Update1: Processing image " + (i+1) + "/" + files.length);
		file = files[i];
		if (endsWith(file, _FILE_EXTENSION)) {
			open(dir+"/"+file);
			if (i==0) {
				Table.create(_TITLE_OF_TABLE);
			}
			measureAllPositionsInImage();
			outFile = replace(file, "."+_FILE_EXTENSION, ".tif");
			saveAs("tif", dir+"/"+_OUT_FOLDER+"/"+outFile);
			close();
		}
	}
	selectWindow(_TITLE_OF_TABLE);
	Table.save(dir+"/"+_TITLE_OF_TABLE+".xls");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("Analyze Positions In Cell finished at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
}

function report(nucleiData, cellData, signalData) {
	title = getTitle();
	if (!isOpen(_TITLE_OF_TABLE)) {
		Table.create(_TITLE_OF_TABLE);
	}
	selectWindow(_TITLE_OF_TABLE);
	lastRowIndex = Table.size;
	
	Table.set("image", lastRowIndex, title);
	positive = ((cellData[0]==1) && (signalData[0]==1));
	if (_MEASURE_DIST_NUCLEI) {
		positive = (positive && (nucleiData[0]==2));
	}
	if (!positive) {
		Table.set("positive", lastRowIndex, 0);
		Table.update;
		return;
	}
	Table.set("positive", lastRowIndex, 1);

	distanceToCell = sqrt(pow(signalData[1] - cellData[1], 2) + pow(signalData[2] - cellData[2], 2));
	toScaled(distanceToCell);
	
	if (_MEASURE_DIST_NUCLEI) {
		distanceToNucleus1 = sqrt(pow(signalData[1] - nucleiData[1], 2) + pow(signalData[2] - nucleiData[2], 2));
		distanceToNucleus2 = sqrt(pow(signalData[1] - nucleiData[3], 2) + pow(signalData[2] - nucleiData[4], 2));
		toScaled(distanceToNucleus1);
		toScaled(distanceToNucleus2);
	}

	Table.set("distance to cell", lastRowIndex, distanceToCell);
	if (_MEASURE_DIST_NUCLEI) {
		Table.set("distance to nucleus 1", lastRowIndex, distanceToNucleus1);
		Table.set("distance to nucleus 2", lastRowIndex, distanceToNucleus2);
	}
	Table.set("area cell", lastRowIndex, cellData[3]);
	if (_MEASURE_DIST_NUCLEI) {
		Table.set("area nucleus1", lastRowIndex, nucleiData[5]);
		Table.set("area nucleus2", lastRowIndex, nucleiData[6]);
	}
	Table.set("area signal", lastRowIndex, signalData[3]);
	Table.update;
}

function reportNegative() {
	signalData = newArray(4);
	cellData = newArray(5);
	nucleiData = newArray(7);
	signalData[0] = -1;
	cellData[0] = 0;
	nucleiData[0] = 0;
	report(nucleiData, cellData, signalData);
}

function measureAllPositionsInImage() {
	Overlay.remove;
	roiManager("reset");
	run("Clear Results");
	inputImageID = getImageID();
	detectCellsInImage();
	startIndex = Overlay.size; 
	run("From ROI Manager");
	size = Overlay.size; 
	for (i = startIndex; i < size; i++) {
		Overlay.activateSelection(i)
		run("To Bounding Box");
		run("Enlarge...", "enlarge=0.03");
		getBoundingRect(x, y, width, height);
		run("Duplicate...", "duplicate");
		run("Select None");
		run("Options...", "iterations=1 count=1 black do=Nothing");
		result = cropCenterCell();
		if (!result) {
			close();
			reportNegative();
			return;
		}
		getBoundingRect(x1, y1, width1, height1);
		run("Crop");
		run("Select None");
		xShift = x+x1;
		yShift = y+y1;
		measurePositions(inputImageID, xShift, yShift);
		close();
	}
}
function measurePositions(inputImageID, xShift, yShift) {
	// There are sometimes multiple cells in the image, crop a region around the central cell
	copyCenterOfCellSlice();
	workImageID = getImageID();
	nucleiData = newArray(7);
	if (_MEASURE_DIST_NUCLEI) nucleiData = findNuclei();
	if (nucleiData[0]==2) {
		markCenterPointsOfNuclei(nucleiData);
	}
	cellData = findCell();
	if (cellData[0] == 1) {
		selectImage(inputImageID);
		shiftedCellData = newArray(cellData.length);
		shiftedCellData[0] = cellData[0];
		shiftedCellData[1] = cellData[1] + xShift;
		shiftedCellData[2] = cellData[2] + yShift;
		shiftedCellData[3] = cellData[3];
		markCenterOfCell(shiftedCellData);
		selectImage(workImageID);
	}
	signalData = findSignal(cellData);
	if (signalData[0]) {

		selectImage(inputImageID);
		shiftedSignalData = newArray(signalData.length);
		shiftedSignalData[0] = signalData[0];
		shiftedSignalData[1] = signalData[1] + xShift;
		shiftedSignalData[2] = signalData[2] + yShift;
		shiftedSignalData[3] = signalData[3];
		markSignal(shiftedSignalData);
		selectImage(workImageID);
	}
	if (_MEASURE_DIST_NUCLEI) {
		distNucleus1 = sqrt(pow(nucleiData[3]-cellData[1],2) + pow(nucleiData[4]-cellData[2],2));
		distNucleus2 = sqrt(pow(nucleiData[3]-cellData[1],2) + pow(nucleiData[4]-cellData[2],2));
		distSignal = sqrt(pow(signalData[1]-cellData[1],2) + pow(signalData[2]-cellData[2],2));
		if (((distNucleus1 < distSignal) || (distNucleus2 < distSignal))) {
			reportNegative();
			return;
		}
	}
	report(nucleiData, cellData, signalData);
}

function markSignal(data) {
	makePoint(data[1], data[2], "hybrid blue large");
	Overlay.addSelection;
	Overlay.show;
	run("Select None");
}

function findSignal(cellData) {
	result = newArray(4);
	roiManager("reset");
	run("Clear Results");
	run("Set Measurements...", "area centroid shape display redirect=None decimal=9");
	Stack.setChannel(_SIGNAL_CHANNEL);
//	setBatchMode(true);
	run("Duplicate...", " ");
	setAutoThreshold("Yen dark");
	run("Convert to Mask");
	run("Fill Holes");
	if (_USE_WATERSHED_ON_SIGNAL) run("Watershed");
	run("Analyze Particles...", "size="+_MIN_SIGNAL_SIZE+"-Infinity show=Masks in_situ add");
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		run("Interpolate", "interval=1 smooth adjust");
		roiManager("update");
	}
	roiManager("Measure");
	xC = cellData[1];
	yC = cellData[2];
	minDist = getWidth();
	bestX = 0;
	bestY = 0;
	bestRoundness = 0;
	area = 0;
	for (i = 0; i < nResults; i++) {
		x = getResult("X", i);
		y = getResult("Y", i);
		roundness = getResult("Round", i);
		area = getResult("Area", i);
		dist = sqrt(pow(x-xC,2) + pow(y-yC,2));
		if (dist<minDist) {
			minDist = dist;
			bestX = x;
			bestY = y;
			bestRoundness = roundness;
		}
	}
	close();
	result[0] = 0;
	if (nResults<1) return result;
	if (bestRoundness<0.1) return result;
	result[0] = 1;
	result[1] = bestX;
	result[2] = bestY;
	result[3] = area;
	toUnscaled(result[1], result[2]);
//	setBatchMode(false);
	return result;
}

function markCenterOfCell(data) {
	makePoint(data[1], data[2], "hybrid red large");
	Overlay.addSelection;
	Overlay.show;
	run("Select None");
}

// returns an array of the form:
// 0 - number of cells detected
// 1 - x of the center of cell
// 2 - y of the center of cell
// 3 - area of the cell
function findCell() {
	roiManager("reset");
	run("Clear Results");
	run("Set Measurements...", "area centroid display redirect=None decimal=9");
	result = newArray(4);
	Stack.setChannel(_SIGNAL_CHANNEL);
//	setBatchMode(true);
	run("Duplicate...", " ");
	setAutoThreshold("Minimum dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Analyze Particles...", "size="+_MIN_CELL_SIZE+"-Infinity add");
	close();
	roiManager("Measure");
	selectWindow("Results");
	result[0] = nResults;
	if (result[0]!=1) return result;
	result[1] = Table.get("X", 0);
	result[2] = Table.get("Y", 0);
	result[3] = Table.get("Area", 0);
	toUnscaled(result[1], result[2]);
//	setBatchMode(false);
	return result;
}

function markCenterPointsOfNuclei(data) {
	makePoint(data[1], data[2], "hybrid green large");
	Overlay.addSelection;
	makePoint(data[3], data[4], "hybrid green large");
	Overlay.addSelection;
	Overlay.show;
	run("Select None");
}

// returns an array of the form:
// 0 - number of nuclei detected
// 1 - x of the center of nucleus 1
// 2 - y of the center of nucleus 1
// 3 - x of the center of nucleus 2
// 4 - y of the center of nucleus 3
// 5 - area of nucleus 1
// 6 - area of nucleus 2

function findNuclei() {
	roiManager("reset");
	run("Clear Results");
	run("Set Measurements...", "area centroid display redirect=None decimal=9");
	result = newArray(7);
	Stack.setChannel(_NUCLEI_CHANNEL);
//	setBatchMode(true);
	run("Duplicate...", " ");
	setAutoThreshold("Huang dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Analyze Particles...", "size="+_MIN_NUCLEUS_SIZE+"-Infinity exclude add");
	close();
	roiManager("Measure");
	selectWindow("Results");
	result[0] = nResults;
	if (result[0]!=2) return result;
	result[1] = Table.get("X", 0);
	result[2] = Table.get("Y", 0);
	result[3] = Table.get("X", 1);
	result[4] = Table.get("Y", 1);
	result[5] = Table.get("Area", 0);
	result[6] = Table.get("Area", 1);
	toUnscaled(result[1], result[2]);
	toUnscaled(result[3], result[4]);
//	setBatchMode(false);
	return result;
}

function cropCenterCell() {
	inputImageID = getImageID();
	centerX = getWidth() / 2;
	centerY = getHeight() / 2;
	
	run("Set Measurements...", "area display redirect=None decimal=9");
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+_SIGNAL_CHANNEL+"-"+_SIGNAL_CHANNEL);
	stackID = getImageID();
	run("Z Project...", "projection=[Max Intensity]");
	selectImage(stackID);
	close();
	setAutoThreshold("Li dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Analyze Particles...", "size="+_MIN_CELL_SIZE+"-Infinity add");
	count = roiManager("count");
	if (count==0) return false;
	minDist = getWidth()+getHeight();
	index = 0;
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		getSelectionBounds(x, y, width, height);
		centerOfRoiX = x + (width/2);
		centerOfRoiY = y + (height/2);
		dist = sqrt(pow(centerX - centerOfRoiX, 2) + pow(centerY - centerOfRoiY, 2));
		if (dist<minDist) {
			minDist = dist;
			index = i;
		}
	}
	close();
	selectImage(inputImageID);
	roiManager("select", index);
	return true;
}

function copyCenterOfCellSlice() {
	inputImageID = getImageID();
	index = findCenterOfCellSlice();
	run("Duplicate...", "duplicate slices="+index+"-"+index);
	selectImage(inputImageID);
	close();
}

function findCenterOfCellSlice() {
	if (_MEASURE_DIST_NUCLEI) {
		index = findCenterOfCellSliceUsingNuclei();
	} else {
		index = findCenterOfCellSliceUsingSignal();
	}
	return index;
}

function detectCellsInImage() {
	if (Overlay.size>0) Overlay.remove;
	roiManager("reset");
	run("Duplicate...", "duplicate channels=2-2");
	run("Z Project...", "projection=[Max Intensity]");
	setAutoThreshold("Intermodes");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Invert");
	run("Options...", "iterations=5 count=1 black do=Dilate");
	run("Analyze Particles...", "size=0.0001-Infinity show=Masks exclude add in_situ");
	run("From ROI Manager");
	toBeRemoved = newArray(0);
	size = Overlay.size;
	for (i = 0; i < size; i++) {
		roiManager("reset");
		Overlay.activateSelection(i);
		getStatistics(area);
		if (area>_MAX_AREA) {
			toBeRemoved = Array.concat(toBeRemoved, i);
			continue;
		}
		run("Duplicate...", " ");
		run("Watershed");
		run("Analyze Particles...", "size=0.0001-Infinity show=Nothing add");
		count = roiManager("count");
		if (count!=2) toBeRemoved = Array.concat(toBeRemoved, i);
		close();
	}
	roiManager("reset");
	run("To ROI Manager");
	roiManager("select", toBeRemoved);
	roiManager("delete");
	close();
	close();
	roiManager("Show None");
	roiManager("Show All");
}

function findCenterOfCellSliceUsingNuclei() {
	run("Clear Results");
	measureNucleiAreas();
	selectWindow("Results");
	areas = Table.getColumn("Area1");
	startIndex = findLeftMin(areas);
	endIndex = findRightMin(areas);
	centerIndex = findMax(areas, startIndex, endIndex);
	return centerIndex+1;
}

function findCenterOfCellSliceUsingSignal() {
	run("Clear Results");
	measureSignalAreas();
	selectWindow("Results");
	areas = Table.getColumn("Area1");
	centerIndex = findMiddleMaximum(areas);
	return centerIndex+1;
}

function measureSignalAreas() {
	run("Set Measurements...", "area limit display redirect=None decimal=9");
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+_SIGNAL_CHANNEL+"-"+_SIGNAL_CHANNEL);
	setAutoThreshold("Default");
	getThreshold(lower, upper);
	run("Macro...", "code=[v=(v>"+lower+") * 65535] stack");
	run("8-bit");
	run("Fill Holes", "stack");
	run("Select All");
	roiManager("Add");
	setThreshold(1, 255);
	roiManager("Multi Measure");
	close();
}

function measureNucleiAreas() {
	run("Set Measurements...", "area limit display redirect=None decimal=9");
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+_NUCLEI_CHANNEL+"-"+_NUCLEI_CHANNEL);
	run("Convert to Mask", "method=Default background=Dark calculate");
	run("Fill Holes", "stack");
	run("Select All");
	roiManager("Add");
	setThreshold(1, 255);
	roiManager("Multi Measure");
	close();
}

function findMax(values, start, end) {
	index = start;
	max = values[start];
	for(i=start+1; i<=end; i++) {
		if (values[i]>max) {
			max = values[i];
			index = i;
		}
	}
	return index;
}

function findLeftMin(values) {
	lastSlice = (values.length / 2) - 1;
	min = values[0];
	index = 0;
	for (i = 1; i < lastSlice+1; i++) {
		if (values[i]<min) {
			min = values[i];
			index = i;
		}
	}	
	return index;
}

function findRightMin(values) {
	Array.reverse(values);
	index = findLeftMin(values);
	index = values.length-1-index;
	Array.reverse(values);
	return index;
}

function findMiddleMaximum(list) {
	maxima = Array.findMaxima(list, 0);
	Array.sort(maxima);
	return floor(maxima[maxima.length/2]);
}

/* 
 * Tests  
 *
 */

var _TEST_COUNTER = 0;
runTests();

function runTests() {
	_TEST_COUNTER = 0;
	print("Test suite started");
	testFindLeftMin();
	testFindRightMin();
	testFindMax();
	testFindMiddleMaximum();
	print("Test suite finished");
}

function testFindMax() {
	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
	start = findLeftMin(values);
	end = findRightMin(values);
 	index = findMax(values, start, end);
 	assertEquals(index, 5, "testFindMax (even length)");

 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
	start = findLeftMin(values);
	end = findRightMin(values);
 	index = findMax(values, start, end);
 	assertEquals(index, 5, "testFindMax (odd length)");
}

function testFindLeftMin() {
 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
 	index = findLeftMin(values);
 	assertEquals(index, 1, "testFindLeftMin (even length)");

 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12, 15);
 	index = findLeftMin(values);
 	assertEquals(index, 1, "testFindLeftMin (odd length)");
}

function testFindRightMin() {
 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
 	index = findRightMin(values);
 	assertEquals(index, 9, "testFindRightMin (even length)");

 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12, 15);
 	index = findRightMin(values);
 	assertEquals(index, 9, "testFindRightMin (odd length)");
}

function testFindMiddleMaximum() {
	list = newArray(1,3,9,7,6,5,6,7,10,9,8,7,9,11,10);

	index = findMiddleMaximum(list);
	assertEquals(index, 8, "testFindMiddleMaximum (odd number of maxima)");
}


function assertEquals(isValue, shouldValue, nameOfTest) {
	_TEST_COUNTER++;
	result = false;
	if (isValue==shouldValue) {
		print (_TEST_COUNTER + "-" + nameOfTest + " - ok");
	} else {
		print (_TEST_COUNTER + "-" + nameOfTest + " - FAILED!");
		print ("expected value is "+shouldValue+", but the result is "+isValue);
	}
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



