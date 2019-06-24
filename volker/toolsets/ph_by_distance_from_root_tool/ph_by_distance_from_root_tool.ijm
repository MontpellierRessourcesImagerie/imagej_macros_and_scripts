//                       1   2  3  4  5  6  7  8  9 1011 1213 14 15 16
var _CENTER_X = newArray(9 ,10, 8, 8, 7, 9, 8,10,10,6,10, 7,8, 6, 7, 9);
var _CENTER_Y = newArray(16,19,14,11,19,13,15,16,15,9,20,13,9,19,15,10);
var _DIRECTIONS_X = newArray(1, 0, -1, -1, 0, 1, 1, 0, -1);
var _DIRECTIONS_Y = newArray(-1, -1, -1, 0, 0, 0, 1, 1, 1);
var _OPTODE_DIAMETER = 1;
var _OPTODE_DISTANCE_X = 3;
var _OPTODE_DISTANCE_Y = 7;
var _NR_Of_OPEN = 20;
var _NR_OF_CLOSE = 20;
var _MIN_BOX_AREA = 2000000;
var _PROBE_LENGTH_FACTOR = 1/4.5;
var _PROBE_POS_PERCENTAGE = 80;
var _FLIP_IMAGE_TO_RIGHT = true;

var _BOX_NR = 14;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/ph_by_distance_from_root_tool";

exit();


macro "ph by distance from root tool help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "ph by distance from root tool help Action Tool (f1) - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D15D1aD1fD20D22D23D25D27D28D2aD2cD2dD2fD30D32D33D35D37D38D3aD3cD3dD3fD40D45D4aD4fD50D51D52D53D54D55D56D57D58D59D5aD5bD5cD5dD5eD5fD60D65D6aD6fD70D72D73D75D77D78D7aD7cD7dD7fD80D82D83D85D87D88D8aD8cD8dD8fD90D95D9aD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb0Db5DbaDbfDc0Dc2Dc3Dc5Dc7Dc8DcaDccDcdDcfDd0Dd2Dd3Dd5Dd7Dd8DdaDdcDddDdfDe0De5DeaDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC0bbD11D12D13D14D16D17D18D19D1bD1cD1dD1eD21D24D26D29D2bD2eD31D34D36D39D3bD3eD41D42D43D44D46D47D48D49D4bD4cD4dD4eD61D62D63D64D66D67D68D69D6bD6cD6dD6eD71D74D76D79D7bD7eD81D84D86D89D8bD8eD91D92D93D94D96D97D98D99D9bD9cD9dD9eDb1Db2Db3Db4Db6Db7Db8Db9DbbDbcDbdDbeDc1Dc4Dc6Dc9DcbDceDd1Dd4Dd6Dd9DdbDdeDe1De2De3De4De6De7De8De9DebDecDedDee"{
	run('URL...', 'url='+helpURL);
}

macro "find positions of optodes [f2]" {
	findPositionsOfOptodes();
}

macro "find positions of optodes (f2) Action Tool - C000T4b12o" {
	findPositionsOfOptodes();
}

function findPositionsOfOptodes() {
	boxNr = _BOX_NR;

	run("Remove Overlay");

	origin = findOrigin();
	center = findCenter(boxNr, origin);
	makePoint(origin[0], origin[1], "large green hybrid");
	Overlay.addSelection;
	makePoint(center[0], center[1], "large yellow hybrid");
	Overlay.addSelection;
	width = _OPTODE_DIAMETER;
	toUnscaled(width);
	for (i = 1; i <= 9; i++) {
		coords = findCoordinates(i, center);
		makeRectangle(coords[0], coords[1], width, width);
		Overlay.addSelection;
	}
	Overlay.show;
	run("Select None");
}

function findCoordinates(optodeNr, center) {
	dirX = _DIRECTIONS_X[optodeNr-1];
	dirY = _DIRECTIONS_Y[optodeNr-1];
	xp = center[0];
	yp = center[1];
	toScaled(xp, yp);
	x = (_OPTODE_DISTANCE_X * dirX) + xp;
	y = (_OPTODE_DISTANCE_Y * dirY) + yp;
	x = x -(_OPTODE_DIAMETER / 2);
	y = y -(_OPTODE_DIAMETER / 2);
	toUnscaled(x, y);
	result = newArray(x,y);
	return result;
}

function findCenter(boxNr, origin) {
	xp = origin[0];
	yp = origin[1];
	toScaled(xp, yp);
	centerX = xp + _CENTER_X[boxNr-1];
	centerY = yp + _CENTER_Y[boxNr-1];
	toUnscaled(centerX, centerY);
	result = newArray(centerX, centerY);
	return result;
}

function findOrigin() {
	inputImageID = getImageID();
	detectBox();
	maskID = getImageID();
	setAutoThreshold("Default");
	run("Create Selection");
	getBoundingRect(x, y, width, height);
	xL = findStartX(x, y, width, height);
	xR = findEndX(x, y, width, height);
	
	yL = findYStartAt(xL, y);
	yR = findYStartAt(xR, y);
	
	yMid = min(yL, yR) + (abs(yR-yL) / 2);
	makeLine(xL, yMid, xR, yMid);
	selectImage(maskID);
	close();
	selectImage(inputImageID);
	result = newArray(xL, yMid);
	return result;
}

function detectBox() {
	inputImageID = getImageID();
	run("Duplicate...", " ");
	maskID = getImageID();
	run("16-bit");
	setAutoThreshold("Default");
	run("Convert to Mask");
	run("Analyze Particles...", "size="+_MIN_BOX_AREA+"-Infinity pixel show=Masks in_situ");
	run("Fill Holes");
	run("Options...", "iterations="+_NR_Of_OPEN+" count=1 do=Open");
	run("Options...", "iterations="+_NR_OF_CLOSE+" count=1 do=Close");
	run("Analyze Particles...", "size="+_MIN_BOX_AREA+"-Infinity pixel show=Masks in_situ");
	setAutoThreshold("Default");
	run("Set Measurements...", "area mean modal min centroid bounding fit integrated limit display redirect=None decimal=5");
	run("Measure");
	width = getWidth();
	height = getHeight();
	if (width > height) {
		angle = getResult("Angle", nResults-1);
		if (angle>90) {
			angle = -1* (180-angle);
		}
		rotateBy(angle);
		if (_FLIP_IMAGE_TO_RIGHT) run("Rotate 90 Degrees Right");
	}
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	selectImage(inputImageID);
	if (width > height) {
		rotateBy(angle);
		if (_FLIP_IMAGE_TO_RIGHT) run("Rotate 90 Degrees Right");
	}
	selectImage(maskID);
}

function rotateBy(angle) {
	run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear");
}

function moveLineToObjectBorder(x, y, deltaX, probeLength, minLength) {
	makeLine(x, y, x, y+probeLength);
 	getStatistics(area, mean);
	nrOfPixels = (mean * probeLength) / 255; 
	while(nrOfPixels<minLength) {
		x = x + deltaX;
		makeLine(x, y, x, y+probeLength);
		getStatistics(area, mean);
		nrOfPixels = (mean * probeLength) / 255; 
	}
	return x;
}

function findStartX(x, y, width, height) {
	probeLength = height * _PROBE_LENGTH_FACTOR;
	minLength = (probeLength * _PROBE_POS_PERCENTAGE) / 100;
	
	xL = moveLineToObjectBorder(x, y, 1, probeLength, minLength);
	return xL;
}

function findEndX(x, y, width, height) {
	probeLength = height * _PROBE_LENGTH_FACTOR;
	minLength = (probeLength * _PROBE_POS_PERCENTAGE) / 100;
	
	xR = moveLineToObjectBorder(x+width, y, -1, probeLength, minLength);
	return xR;
}

function findYStartAt(x, yInitial) {
	y = yInitial;
	p = getPixel(x, y);
	while(p<255 && y<3000) {
		y++;
		p = getPixel(x, y);
		print(x,y,p);
	}
	return y;
}

function min(a,b) {
	if (a<b) return a;
	else return b;
}

function readCoordinates(folder, file, imageNr) {
	lines = File.openAsString(folder + "/" + file);
	
	lines = split(lines, "\n");
	
	for (i = 1; i < lines.length; i++) {
		line = lines[i];
		print(line);
		columns = split(line, "\t");
		if (columns.length==0) continue;
		if (columns[0]==imageNr) {
			boxNumber = columns[1];
			X = columns[2];
			Y = columns[3];
		}
	}
	
	result = newArray(boxNumber, X, Y);
	return result;
}