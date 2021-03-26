var _SPOTS_CHANNEL = "SC35TR";
var _NUCLEUS_CHANNEL = "Hoechst";
var _BORDER_CHANNEL = "LaminB1V";
var _BORDER_RADIUS = 3;
var _TABLE_NAME = "border and spots measurements";
var _MIN_NUCLEUS_AREA = 5000;

run("Set Measurements...", "area mean standard centroid fit shape feret's integrated stack display redirect=None decimal=9");

if(!isOpen(_TABLE_NAME)) {
	Table.create(_TABLE_NAME);
}
line = Table.size(_TABLE_NAME);
dir = File.directory;
title = getTitle();
areas = selectNuclei();
means = measureBorder(dir, title);
close("Results");

for (i = 0; i < means.length; i++) {
	Table.set("image", line + i, title, _TABLE_NAME);
	Table.set("nucleus", line + i, i+1, _TABLE_NAME);
	Table.set("mean int. border", line + i, means[i], _TABLE_NAME);
	Table.set("area nucleus", line + i, areas[i], _TABLE_NAME);
}

function measureAndReportSpots() {
	
}

function measureBorder(dir, title) {
	borderImageTitle = replace(title, _NUCLEUS_CHANNEL, _BORDER_CHANNEL);
	open(dir + borderImageTitle);
	count = roiManager("count");
	means = newArray(count);
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		run("Enlarge...", "enlarge=-" + (2 * _BORDER_RADIUS + 1));
		run("Make Band...", "band=" + (2 * _BORDER_RADIUS + 1));
		getStatistics(area, mean, min, max, std);
		means[i] = mean;
		Overlay.addSelection;
	}
	return means;
}

function selectNuclei() {
	run("Select None");
	nucleusImageID = getImageID();
	setBatchMode(true);
	applyDoGAndAdjustDisplay(1,200);
	inputImageID = getImageID();
	setAutoThreshold("Li dark");
	run("Convert to Mask");
	run("Options...", "iterations=1 count=1 do=Close");
	run("Fill Holes");
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_NUCLEUS_AREA+"-Infinity show=Masks display exclude clear include add in_situ");
	areas = Table.getColumn("Area");
	close();
	run("From ROI Manager");
//	roiManager("reset");
	setBatchMode(false);
	return areas;
}

function applyDoGAndAdjustDisplay(sigmaSmall, sigmaLarge) {
	DoG(sigmaSmall, sigmaLarge);
	adjustDisplay();
}

function adjustDisplay() {
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels>1) {
		for (i = 0; i < channels; i++) {
			Stack.setChannel(i+1);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
		}
	} else {
		run("Enhance Contrast", "saturated=0.35");
	}
}

function DoG(sigmaSmall, sigmaBig) {
	run("Duplicate...", "title=A duplicate");
	run("Duplicate...", "title=B duplicate");
	run("Gaussian Blur...", "sigma="+sigmaBig+" stack");
	selectWindow("A");
	run("Gaussian Blur...", "sigma="+sigmaSmall+" stack");
	imageCalculator("Subtract create stack", "A","B");
	selectWindow("Result of A");
	selectWindow("A");
	close();
	selectWindow("B");
	close();
}