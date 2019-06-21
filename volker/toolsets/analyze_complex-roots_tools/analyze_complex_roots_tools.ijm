var _DIST_BORDER = 5;
var _CIRCLE_ORIGIN_X = 3226;
var _CIRCLE_ORIGIN_Y = 7;
var _CIRCLE_INITIAL_RADIUS = 50;
var _DELTA_RADIUS = 200;
var _FACTOR = 1.1;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Analyze_Complex_Roots_Tool";
 
// segmentRoot();
// makeCircles(_CIRCLE_ORIGIN_X, _CIRCLE_ORIGIN_Y, _CIRCLE_INITIAL_RADIUS, _DELTA_RADIUS);
// getValuesInCirleNr(7);
/*
maxValues = getMaxPerDistance();
Plot.create("max radius per dist.", "step nr.", "radius", maxValues);
Plot.show();
*/

exit();

macro "analyze complex roots tools help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "analyze complex roots help Action Tool (f1) - C0ffD07D0cD18D1dD20D21D22D23D29D2eD34D3aD3eD45D4aD4eD56D5aD5fD60D61D62D67D6bD6fD73D77D7bD7fD83D87D8bD8fD93D97D9bD9fDa0Da1Da2Da7DabDafDb6DbaDbfDc5DcaDcfDd4DdaDdeDe0De1De2De3De9DeeDf7Df8Dfd"{
	run('URL...', 'url='+helpURL);
}
macro "create mask [f2]" {
	segmentRoot();
}

macro "create mask Action Tool (f2) - C000T4b12m" {
	segmentRoot();
}


macro "make circles [f3]" {
	doMakeCircles(_CIRCLE_ORIGIN_X, _CIRCLE_ORIGIN_Y);
}

macro "make circles Tool (f3) - C000T4b12c" {
	getCursorLoc(x, y, z, modifiers);
	doMakeCircles(x,y);
}

macro "plot max. radius [f4]" {
	plotMaxRadius();
}

macro "plot max. radius Action Tool (f4) - C000T4b12r" {
	plotMaxRadius();
}

function getDistances() {
	count = Overlay.size;
	distances = newArray(count);
	for (i = 0; i < count; i++) {
		Overlay.activateSelection(i);
		getSelectionBounds(x, y, width, height);
		run("Select None");
		distances[i] = width / 2.0;
		toScaled(distances[i]);
	}
	return distances;
}

function plotMaxRadius() {
	maxValues = getMaxPerDistance();
	distances = getDistances();
	Plot.create("max radius per dist.", "distance [cm]", "radius [cm]", distances, maxValues);
	Plot.show();	
}

function doMakeCircles(x,y) {
	_CIRCLE_ORIGIN_X = x;
	_CIRCLE_ORIGIN_Y = y;
	makeCircles(_CIRCLE_ORIGIN_X, _CIRCLE_ORIGIN_Y, _CIRCLE_INITIAL_RADIUS, _DELTA_RADIUS, _FACTOR);
}

function getMaxPerDistance() {
	count = Overlay.size;
	maxValues = newArray(count);
	for (i = 0; i < count; i++) {
		values = getValuesInCircleNr(i);
		Array.getStatistics(values, min, max);
		toScaled(max);
		maxValues[i] = max;
	}
	run("Select None");
	return maxValues;
}

function getValuesInCircleNr(i) {
		Overlay.activateSelection(i);
		run("Area to Line");
		getSelectionCoordinates(xpoints, ypoints);
		values = getValuesInSelection(xpoints, ypoints);
		return values;
}


function makeCircles(centerX, centerY, initialRadius, deltaRadius, factor) {
	Overlay.remove;
	height = getHeight();
	currentRadius = initialRadius;
	while(currentRadius<height) {
		circleWidth = currentRadius*2;
		makeOval(centerX-currentRadius, centerY-currentRadius, circleWidth, circleWidth);
		Overlay.addSelection;
		deltaRadius *= factor;
		currentRadius += deltaRadius;
	}
	Overlay.show;
	run("Select None");
}

function getValuesInSelection(xpoints, ypoints) {
	values = newArray(xpoints.length);
	for(i=0; i<xpoints.length; i++) {
		x = xpoints[i];
		y = ypoints[i];
		values[i] = getPixel(x, y);
	}
	return values;
}

function segmentRoot() {
	run("Options...", "iterations=1 count=1 do=Nothing");
	width = getWidth();
	height = getHeight();
	run("RGB Color");
	run("16-bit");
	setAutoThreshold("MaxEntropy dark");
	run("Convert to Mask");
	border = 2 * _DIST_BORDER;
	run("Canvas Size...", "width="+width+" height="+(height+border)+" position=Center");
	setLineWidth(_DIST_BORDER/2);
	makeLine(0, _DIST_BORDER, width, _DIST_BORDER);
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	run("Select None");
	run("Analyze Particles...", "size=50000-Infinity pixel show=Masks exclude in_situ");
	run("Canvas Size...", "width="+width+" height="+height+" position=Center");
	setLineWidth(1);
}