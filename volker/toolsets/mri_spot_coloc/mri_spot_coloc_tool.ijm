var _SIGMA = 3;
var _MIN_PROMINENCE = newArray(30, 30);
var _COLORS=newArray("red", "green");
var _STYLE=newArray("dot", "cross");
var _SIZE=newArray("medium", "medium");
var _MAX_RADIUS = 2;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Spot_Coloc_Tool"

macro "detect spots help (f1) Action Tool - C020D00C310D10C240D30C120D40C040D50C050D60C120D70C170D90C120Da0C010Db0C020Dc0C120Dd0C020De0C040Df0C240D01C020D11C030D21C040D31C030D41C010D51C040D61C010L7181C020D91C050Da1C310Db1C010Dc1C050Dd1C030Le1f1C040L0212C020D22C240D32C540D42C070D52C010D62C310D72C120D82C020D92C120Da2C140Db2C050Lc2d2C120De2C240Df2C020D03C120L1323C020D33C030D43C040D53C030D63C010D73C120D83C030D93C040La3b3C010Dc3C170Dd3C310De3C030Df3C540D04C310D24C540D34C240D44C040D54C240D64C040D74C120D84C240D94C050Da4C540Db4C040Dc4C310Dd4C170De4C120Df4C240D05C170D15C030D25C540D35C310D45C030D55C040D65C120L8595C050Da5C040Db5C8c0Lc5d5C170De5C030Df5C120D06C020D16C170D26C540L3656C070D66C540D76C030D86C120D96C050Da6C170Db6C8c0Lc6e6C170Df6C070D07C240D17C540L2757C010D67C050D77C240D87C170D97C020Da7C170Db7C8c0Lc7d7C170De7C240Df7C120L0818C540D28C8c0L3858C240D68C310D78C140D88C310Da8C020Db8C170Lc8d8C070De8C030Df8C040D09C070D19C8c0L2949C170D59C540D69C030D89C040L99a9C030Lb9c9C040Dd9C050De9C030Df9C240D0aC070D1aC8c0L2a4aC070L5a6aC240L7a8aC120D9aC030DaaC040DbaC010DcaC030DdaC050DeaC030DfaD0bC240D1bC070L2b3bC050D4bC240D5bC050D6bC240D7bC030D8bC050DabC040DbbC120LcbebC010D0cC120D1cC070D2cC050D3cC070D4cC050D5cC040D6cC050D7cC120D8cC040D9cC010DacC030DbcC050DccC020DdcC010DfcC120D0dC020D1dC030D2dC040L3d4dC030D5dC310D6dC040D7dC010D8dC020D9dC030DbdC020LcdddC040DedC030D0eC020D1eC030D2eC120D3eC310D4eC050D5eC010D6eC120D7eC020D8eC030D9eC040DaeC050DbeC120DceC030DdeC020DeeC310DfeC540D0fC020L1f2fC040L3f4fC120L5f6fC040D7fC020L8f9fC030DafC310LbfcfC020DdfC120Lefff" {
	 run('URL...', 'url='+helpURL);
}

macro "detect spots help [f1]" {
	 run('URL...', 'url='+helpURL);
}	

macro "detect spots (f2) Action Tool - C000T4b12d" {
	detectSpots(_MIN_PROMINENCE, _COLORS, _STYLE, _SIZE);
}

macro "detectSpots" [f2]" {
	detectSpots(_MIN_PROMINENCE, _COLORS, _STYLE, _SIZE);
}

function detectSpots(minProminence, colors, style, size) {
	Overlay.remove;
	inputImageID = getImageID();
	run("FeatureJ Laplacian", "compute smoothing="+_SIGMA);
	pointsImageID = getImageID();
	Stack.getDimensions(width, height, channels, slices, frames);
	for (t = 1; t <= frames; t++) {
		for (c = 1; c <= channels; c++) {
			selectImage(pointsImageID);
			Stack.setChannel(c);
			Stack.setFrame(t);
			run("Find Maxima...", "prominence="+minProminence[c-1] +" strict exclude light output=[Point Selection]");
			getSelectionCoordinates(xpoints, ypoints);
			selectImage(inputImageID);
			type = "point " + size[c-1] + " " + colors[c-1] + " " + style[c-1];
			makeSelection(type, xpoints, ypoints);
			Overlay.addSelection
			Overlay.setPosition(0, 0, t);
		}
	}	
	selectImage(pointsImageID);	
	close();
	run("Select None");
	linkSpots();
}

function linkSpots() {
	currentID = 1;
	Stack.getDimensions(width, height, channels, slices, frames);
	inputImageID = getImageID();
	newImage("map", "16-bit", width, height, channels, slices, frames);
	setBatchMode(true);	// move up again for efficiency
	map = getImageID();
	selectImage(inputImageID);
	numberOfSelections = Overlay.size;
	Table.create("intensity per time");
	timePoints = Array.getSequence(frames);
	Table.setColumn("frame", timePoints, "intensity per time");
	for (i = 0; i < numberOfSelections; i++) {
		selectImage(inputImageID);
		Overlay.activateSelection(i);
		Roi.getPosition(currentChannel, currentSlice, currentFrame);
		color = Roi.getStrokeColor;
		getSelectionCoordinates(xpoints1, ypoints1);
		run("Select None");
		for (j = 0; j < xpoints1.length; j++) {
			selectImageChannelAndFrame(map, color, currentFrame);
			makeRectangle(xpoints1[j]-_MAX_RADIUS, ypoints1[j]-_MAX_RADIUS, 2*_MAX_RADIUS+1, 2*_MAX_RADIUS+1);
			id = getIDFor(xpoints1[j], ypoints1[j], currentChannel, currentFrame);
			if (id==-1) id = currentID++;
			setColor(id);
			run("Fill", "slice");	
			selectImageChannelAndFrame(inputImageID, color, currentFrame);
			makeRectangle(xpoints1[j]-_MAX_RADIUS, ypoints1[j]-_MAX_RADIUS, 2*_MAX_RADIUS+1, 2*_MAX_RADIUS+1);
			getStatistics(area, mean, min, max, std, histogram);
			Table.set(id, currentFrame-1, mean, "intensity per time");
		}
	}
	Table.create("coloc per frame");
	Table.setColumn("frame", timePoints, "coloc per frame");
	for (i = 0; i < numberOfSelections; i++) {
		selectImage(inputImageID);
		Overlay.activateSelection(i);
		Roi.getPosition(currentChannel, currentSlice, currentFrame);
		color = Roi.getStrokeColor;
		getSelectionCoordinates(xpoints1, ypoints1);
		run("Select None");
		redSpots = 0;
		greenSpots = 0;
		coveredByOther = 0;
		if (color=='red') 
			redSpots = xpoints1.length;
		else 
			greenSpots = xpoints1.length;
		for (j = 0; j < xpoints1.length; j++) {
			otherColor = 'red';
			if (color=='red') otherColor = 'green';
			selectImageChannelAndFrame(map, otherColor, currentFrame);
			makeRectangle(xpoints1[j]-_MAX_RADIUS, ypoints1[j]-_MAX_RADIUS, 2*_MAX_RADIUS+1, 2*_MAX_RADIUS+1);
			getStatistics(area, mean);
			if(mean>0) coveredByOther++;
		}
		if (color=='red') {
			Table.set("red spots", currentFrame-1, redSpots, "coloc per frame");
		} else {
			Table.set("green spots", currentFrame-1, greenSpots, "coloc per frame");
			Table.set("colocalized", currentFrame-1, coveredByOther, "coloc per frame");
		}
	}
	run("Select None");
	Stack.setChannel(2);
	resetMinAndMax();
	Stack.setChannel(1);
	resetMinAndMax();
	Stack.setDisplayMode("composite");
	setBatchMode(false);
}

function selectImageChannelAndFrame(imageID, color, frame) {
		selectImage(imageID);
		if (color=='red') {
			Stack.setChannel(1);
		} else {	
			Stack.setChannel(2);
		}
		Stack.setFrame(frame);
}

function getIDFor(x, y, currentChannel, currentFrame) {
	if (currentFrame==1) return -1;
	for(f=currentFrame-1; f>0; f--) {
		Stack.setFrame(f);
		Stack.setChannel(currentChannel);
		val = getPixel(x, y);
		if (val>0) {
			Stack.setFrame(currentFrame);
			return val;
		}
	}
	Stack.setFrame(currentFrame);
	return -1;	 
}

