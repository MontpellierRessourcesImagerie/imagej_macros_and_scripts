var plotX;
var plotY;
var width;
var height;
var channels; 
var slices; 
var frames;
var imageID;

macro "get profile (f2) Action Tool - C000T4b12p" {
	getZProfile();
}

macro "get profile [f2]" {
	getZProfile();
}

macro "subtract profile (f3) Action Tool - C000T4b12s" {
	subtractProfile();
}

macro "subtract profile [f3]" {
	subtractProfile();
}


macro "multiply profile (f4) Action Tool - C000T4b12m" {
	multiplyProfile();
}

macro "multiply profile [f4]" {
	multiplyProfile();
}

function getZProfile() {
	imageID = getImageID();
	getDimensions(width, height, channels, slices, frames);
	run("Plot Z-axis Profile");
	Plot.getValues(plotX, plotY);
	close();
	roiManager("add");
	run("Select None");
}

function subtractProfile() {
	Fit.doFit("Rodbard", plotX, plotY);
	rodbardValues = newArray(slices);
	for (i = 0; i < slices; i++) {
		rodbardValues[i] = Fit.f(i);
	}
	for (i = 0; i < slices; i++) {
		Stack.setSlice(i+1);
		run("Subtract...", "value="+rodbardValues[i]+" slice");
	}
	Stack.setSlice(1);
}

function multiplyProfile() {
	Fit.doFit("Rodbard", plotX, plotY);
	rodbardValues = newArray(slices);
	max = Fit.f(0);
	for (i = 0; i < slices; i++) {
		rodbardValues[i] = max / Fit.f(i);
	}
	for (i = 0; i < slices; i++) {
		Stack.setSlice(i+1);
		run("Multiply...", "value="+rodbardValues[i]+" slice");
	}
	Stack.setSlice(1);
}

