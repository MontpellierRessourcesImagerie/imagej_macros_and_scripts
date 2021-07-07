var _X_BASE = newArray(0);
var _Y_BASE = newArray(0);
var _V_BASE = newArray(0);

var _X_FILTERED = newArray(0);
var _Y_FILTERED = newArray(0);
var _V_FILTERED = newArray(0);

macro "filter points (f6) Action Tool - C000T4b12f" {
	filterPoints();
}

macro "Change Threshold Tool - C000T4b12t" {
	 getCursorLoc(x, y, z, flags);
	 print(x);
	 print(flags);
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
	Plot.setColor("red");
	Plot.drawNormalizedLine(0.25, 0, 0.25, 1);
	Plot.setColor("black");
	Plot.show();
}
