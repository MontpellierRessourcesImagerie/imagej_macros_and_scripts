var _SIGMA = 3;
var _MIN_PROMINENCE = newArray(30, 30);
var _COLORS=newArray("red", "green");
var _STYLE=newArray("dot", "cross");
var _SIZE=newArray("medium", "medium");

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
			print(type);
			makeSelection(type, xpoints, ypoints);
			Overlay.addSelection
			Overlay.setPosition(0, 0, t);
		}
	}	
	selectImage(pointsImageID);	
	close();
	run("Select None");
}
