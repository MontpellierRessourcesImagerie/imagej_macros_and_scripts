var _X_BASE = newArray(0);
var _Y_BASE = newArray(0);
var _V_BASE = newArray(0);

var _X_FILTERED = newArray(0);
var _Y_FILTERED = newArray(0);
var _V_FILTERED = newArray(0);

var _INITIAL_DELAY = 50;

macro "filter points (f6) Action Tool - C000T4b12f" {
	filterPoints();
}

macro "Change Threshold Tool - C000T4b12t" {
	 getCursorLoc(x, y, z, flags);
//	 print(x);
//	 print(flags); 
	 h = getHeight();
	 Overlay.activateSelection(0);
	 delay = _INITIAL_DELAY;
	 while (isKeyDown("shift")) {
	 	Roi.getCoordinates(xpoints, ypoints);
	 	Roi.move(xpoints[0]-1, 0);
	 	wait(delay);
	 	delay = maxOf(20, delay-0.25);
	 }
	  while (isKeyDown("control")) {
	 	Roi.getCoordinates(xpoints, ypoints);
	 	Roi.move(xpoints[0]+1, 0);
	 	wait(delay);
	 	delay = maxOf(20, delay-0.25);
	 }
	 if (isKeyDown("alt")) {
	 	Roi.move(x, 0);
	 }
	 run("Select None");
}

macro "treshold down [8]" {
	
}


function filterPoints() {
	_X_BASE = Table.getColumn("X");
	_Y_BASE = Table.getColumn("Y");
	_V_BASE = Table.getColumn("Mean");
	Array.getStatistics(_V_BASE, min, max, mean, stdDev);
	_THRESHOLD = min + ((max - min) / 4)
	Plot.create("Point confidence", "confidence", "count");
	Plot.addHistogram(_V_BASE, 0);
	Plot.setStyle(0, "black,blue,1.0,Bar");
	Plot.show();
	x1 = _THRESHOLD
	x2 = x1;
	y1 = 0;
	y2 = getHeight()-1;
	xs1 = x1;
	zero = 0;
	toUnscaled(x1, zero);
	makeLine(x1, y1, x1, y2);
	Overlay.addSelection
	run("Select None");
}
