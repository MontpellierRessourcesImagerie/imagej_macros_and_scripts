var _SPOTS_CHANNEL = "SC35TR";
var _NUCLEUS_CHANNEL = "Hoechst";
var _BORDER_CHANNEL = "LaminB1V";
var _BORDER_RADIUS = 3;
var _TABLE_NAME = "border and spots measurements";
var _MIN_NUCLEUS_AREA = 5000;
var _MIN_FOCI_AREA = 10;

var _SIGMA_BLUR_FILTER = 15;
var _USE_ROLLING_BALL = false;
var _ROLLING_BALL_RADIUS = 20;
var _FOCI_THRESHOLDING_METHOD = "Yen";
var _PROMINENCE_OF_MAXIMA = 350;
var _THRESHOLD_1 = 10;
var _THRESHOLD_2 = 50;
var _DO_WATERSHED = false;

run("Set Measurements...", "area mean standard min perimeter centroid fit shape feret's integrated median stack display redirect=None decimal=9");
setOption("BlackBackground", false);
if(!isOpen(_TABLE_NAME)) {
	Table.create(_TABLE_NAME);
}
line = Table.size(_TABLE_NAME);
dir = File.directory;
title = getTitle();
areas = selectNuclei();
nucleiImageTitle = getTitle();
count = roiManager("count");
std = newArray(count);
means = measureBorder(dir, title, std);
borderImageTitle = getTitle();
close("Results");
for (i = 0; i < means.length; i++) {
	Table.set("image", line + i, title, _TABLE_NAME);
	Table.set("nucleus", line + i, i+1, _TABLE_NAME);
	Table.set("mean int. border", line + i, means[i], _TABLE_NAME);
	Table.set("stdDev int. border", line + i, std[i], _TABLE_NAME);
	Table.set("area nucleus", line + i, areas[i], _TABLE_NAME);
}
measureAndReportSpots(dir, nucleiImageTitle, borderImageTitle);



function measureAndReportSpots(dir, nucleiImageTitle, borderImageTitle) {
	titleWithoutChannel = replace(nucleiImageTitle, _NUCLEUS_CHANNEL, "");
	spotsImageTitle = replace(nucleiImageTitle, _NUCLEUS_CHANNEL, _SPOTS_CHANNEL);
	open(dir + spotsImageTitle);
	spotsImageTitle = getTitle();
	selectImage(nucleiImageTitle);
	roiManager("reset");
	run("To ROI Manager");
	run("From ROI Manager");
	run("Duplicate...", "title=nuclei");
	selectImage(borderImageTitle);
	run("Duplicate...", "title=borders");
	run("Merge Channels...", "c1=borders c2="+spotsImageTitle+" c3=nuclei create");	
	rename(titleWithoutChannel);
	targetImageID = getImageID();
	selectImage(nucleiImageTitle);
	size = Overlay.size;
	for(i = 0; i < size; i++) {
		selectImage(nucleiImageTitle);
		Overlay.activateSelection(i);
		selectImage(targetImageID);
		run("Restore Selection");
		Overlay.addSelection;
		Overlay.setPosition(3, 0, 0);
	}
	Stack.setChannel(1);
	selectImage(borderImageTitle);
	size = Overlay.size;
	for (i = 0; i < size; i++) {
		selectImage(borderImageTitle);
		Overlay.activateSelection(i);
		selectImage(targetImageID);
		run("Restore Selection");
		Overlay.addSelection;
		Overlay.setPosition(1, 0, 0);
	}
	run("Select None");
	close("\\Others");
	measureFociPerNucleus(3, 2);
}

function measureBorder(dir, title, std) {
	borderImageTitle = replace(title, _NUCLEUS_CHANNEL, _BORDER_CHANNEL);
	open(dir + borderImageTitle);
	count = roiManager("count");
	means = newArray(count);
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		run("Enlarge...", "enlarge=-" + (2 * _BORDER_RADIUS + 1));
		run("Make Band...", "band=" + (2 * _BORDER_RADIUS + 1));
		getStatistics(area, mean, min, max, stdDev);
		std[i] = stdDev;
		means[i] = mean;
		Overlay.addSelection;
	}
	run("Select None");
	return means;
}

function selectNuclei() {
	run("Select None");
	nucleusImageID = getImageID();
//	setBatchMode(true);
	applyDoGAndAdjustDisplay(1,200);
	inputImageID = getImageID();
	setAutoThreshold("Li dark");
	run("Convert to Mask");
	run("Options...", "iterations=1 count=1 do=Close");
	run("Fill Holes");
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_NUCLEUS_AREA+"-Infinity show=Masks display exclude clear include add in_situ");
	areas = Table.getColumn("Area", "Results");
	close();
	run("From ROI Manager");
//	roiManager("reset");
//	setBatchMode(false);
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


function measureFociPerNucleus(nucleiChannel, fociChannel) {
	setForegroundColor(255,255,255);
	setBackgroundColor(0,0,0);
	blackBackground = eval("js","Prefs.blackBackground");
	setOption("BlackBackground", true);
	Stack.getDimensions(width, height, channels, slices, frames);
	count=roiManager("count");
	if (count<1) {
		title = getTitle();
		print("No nuclei found on image " + title + " with min. size = " + _MIN_NUCLEUS_AREA);
		return;
	}
	if (channels>1 && nucleiChannel!=fociChannel) {
		Stack.setChannel(fociChannel);
		run("Duplicate...", " ");
	}
	inputImageID = getImageID();
	run("From ROI Manager");
	roiManager("reset");
	if (!_USE_ROLLING_BALL) subtractBlurredImage(_SIGMA_BLUR_FILTER);
	else subtractBackground(_ROLLING_BALL_RADIUS);
	damsID = getImageID();
	run("Duplicate...", " ");
	maskID =getImageID();
	maskTitle = getTitle();
	setAutoThreshold(_FOCI_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	run("Analyze Particles...", "size="+_MIN_FOCI_AREA+"-Infinity show=Masks in_situ");
	selectImage(damsID);
	if (_DO_WATERSHED) run("Find Maxima...", "prominence="+_PROMINENCE_OF_MAXIMA+" output=[Segmented Particles]");
	selectImage(damsID);
	close();
	if (_DO_WATERSHED) {
		damsID = getImageID();
		damsTitle = getTitle();
		imageCalculator("AND", maskTitle, damsTitle);
		selectImage(damsID);
		close();
	}
	selectImage(inputImageID);
	size = Overlay.size;
	roiManager("reset");
	for (i = 0; i < size; i++) {
		selectImage(inputImageID);
		Overlay.activateSelection(i);
		selectImage(maskID);
		run("Select None");
		run("Duplicate...", " ");
		run("Restore Selection");
		setBackgroundColor(255,255,255);
		run("Clear Outside");
		setBackgroundColor(0,0,0);
		run("Analyze Particles...", "size=0-Infinity add");
		close();
		count = roiManager("count");
		for (r = 0; r < count; r++) {
			roiManager("select", r);
			roiManager("rename", "N"+IJ.pad(i, 3)+"F"+IJ.pad(r,3));
		}
		run("Select None");
		selectImage(inputImageID);
		roiManager("Show All without labels");
		count = roiManager("count");
		if (count>0) run("From ROI Manager");
		roiManager("reset");
	}
	selectImage(maskID);
	close();
	reportResults();
	if (channels>1) {
		for (i = 0; i < size; i++) {
			Overlay.removeSelection(0);	
		}
		run("To ROI Manager");
		close();
		run("From ROI Manager");
	}	
	setOption("BlackBackground", blackBackground);
}

function reportResults() {
	Overlay.measure;
	if (!isOpen("Nuclei")) {
		Table.create("Nuclei");
	}
	startIndexNuclei = Table.size("Nuclei");
	if (!isOpen("Foci")) {
		Table.create("Foci");
	}
	
	size = Overlay.size;
	inputID = getImageID();
	for (i = 0; i < size; i++) {
		selectImage(inputID);
		Overlay.activateSelection(i);	
		name = Roi.getName;
		if (!startsWith(name, "N")) {
			run("Create Mask");
		}
	}
	selectImage("Mask");
	run("Exact Euclidean Distance Transform (3D)");

	startIndexFoci = Table.size("Foci");
	nrNuclei = 0;
	counter = 0;
//	setBatchMode(true);
	for (i = 0; i < nResults; i++) {
		print("\\Update0: processing line " + (i+1) + " of " + nResults);
		label = Table.getString("Label", i, "Results");
		parts = split(label, ":");
		imageName = parts[0];
		object = parts[1];
		xN = 0;
		yN = 0;
		if (!startsWith(object, "N")) {
			area = getResult("Area", i);
			mean = getResult("Mean", i);
			stdDev = getResult("StdDev", i);
			intDen = getResult("IntDen", i);
			xN = getResult("X", i);
			yN = getResult("Y", i);
			Table.set("Nr.", startIndexNuclei+i, nrNuclei+1, "Nuclei");
			Table.set("Image", startIndexNuclei+i, imageName, "Nuclei");
			Table.set("Area", startIndexNuclei+i, area, "Nuclei");
			Table.set("Mean", startIndexNuclei+i, mean, "Nuclei");
			Table.set("StdDev", startIndexNuclei+i, stdDev, "Nuclei");
			Table.set("IntDen", startIndexNuclei+i, intDen, "Nuclei");
			Table.set("X", startIndexNuclei+i, xN, "Nuclei");
			Table.set("Y", startIndexNuclei+i, yN, "Nuclei");
			Table.update("Nuclei");
			nrNuclei++;
		} else {
			if (counter==0) {
				fociBelow = newArray(nrNuclei);
				fociBetween = newArray(nrNuclei);
				fociAbove = newArray(nrNuclei);
				title = newArray(nrNuclei);
			}
			parts = split(object, "N");
			tmp = parts[0];
			parts = split(tmp, "F");			
			nucleus = parseInt(parts[0]);
			foci = parseInt(parts[1]);
			area = getResult("Area", i);
			mean = getResult("Mean", i);
			stdDev = getResult("StdDev", i);
			intDen = getResult("IntDen", i);
			circ = getResult("Circ.", i);
			ar = getResult("AR", i);
			solidity = getResult("Solidity", i);
			x = getResult("X", i);
			y = getResult("Y", i);		
			xN = Table.get("X", startIndexNuclei + nucleus, "Nuclei");
			yN = Table.get("Y", startIndexNuclei + nucleus, "Nuclei");
			xN = parseFloat(xN);
			yN = parseFloat(yN);
			deltaX = xN-x;
			deltaY = yN-y;
			dist = sqrt(deltaX * deltaX + deltaY * deltaY); 
			distBorder = getPixel(x, y);
			row = Table.size("Foci");
			Table.set("Nr.", row, counter+1, "Foci");
			Table.set("Image", row, imageName, "Foci");
			Table.set("Nucleus", row, nucleus+1, "Foci");
			Table.set("Foci", row, foci+1, "Foci");
			Table.set("Area", row, area, "Foci");
			Table.set("Mean", row, mean, "Foci");
			Table.set("StdDev", row, stdDev, "Foci");
			Table.set("IntDen", row, intDen, "Foci");
			Table.set("Circ.", row, circ, "Foci");
			Table.set("AR", row, ar, "Foci");
			Table.set("Solidity", row, solidity, "Foci");
			Table.set("X", row, x, "Foci");
			Table.set("Y", row, y, "Foci");
			Table.set("Dist. center", row, dist, "Foci");
			Table.set("Dist. border", row, distBorder, "Foci");
			Table.update("Foci");
			if (area < _THRESHOLD_1) {
				fociBelow[nucleus] = fociBelow[nucleus] + 1;
			}
			if (area >= _THRESHOLD_1 && area < _THRESHOLD_2) {
				fociBetween[nucleus] = fociBetween[nucleus] + 1;
			} 
			if (area >= _THRESHOLD_2) {
				fociAbove[nucleus] = fociAbove[nucleus] + 1;
			}
			title[nucleus] = imageName;
			counter++;
		}
		if (i%1000==0) run("Collect Garbage");
	}
	for (i = 0; i < nrNuclei; i++) {
		Table.set("foci with area <"+ _THRESHOLD_1, startIndexNuclei+i, fociBelow[i], "Nuclei");
		Table.set("foci with "+ _THRESHOLD_1 +"<=area<"+  _THRESHOLD_2, startIndexNuclei+i, fociBetween[i], "Nuclei");
		Table.set("foci with area >="+ _THRESHOLD_2, startIndexNuclei+i, fociAbove[i], "Nuclei");
		Table.update("Nuclei");
		nrOfFoci = fociBelow[i]+fociBetween[i]+fociAbove[i];
		Table.set("nr. of foci", startIndexNuclei+i, nrOfFoci, _TABLE_NAME);
		areas = getValuesWhere("Area", "Image", "Nucleus", title[i], i+1, "Foci");
		Array.getStatistics(areas, min, max, areaMean, areaStdDev);
		Table.set("mean area of foci", startIndexNuclei+i, areaMean, _TABLE_NAME);
		Table.set("stdDev. area of foci", startIndexNuclei+i, areaStdDev, _TABLE_NAME);
		Table.set("total area of foci", startIndexNuclei+i, areaMean * nrOfFoci, _TABLE_NAME);
		circs = getValuesWhere("Circ.", "Image", "Nucleus", title[i], i+1, "Foci");
		Array.getStatistics(circs, min, max, circsMean, circsStdDev);
		ars = getValuesWhere("AR", "Image", "Nucleus", title[i], i+1, "Foci");
		Array.getStatistics(ars, min, max, arsMean, arsStdDev);
		solidities = getValuesWhere("Solidity", "Image", "Nucleus", title[i], i+1, "Foci");
		Array.getStatistics(solidities, min, max, soliditiesMean, soliditiesStdDev);		
		Table.set("mean circ. of foci", startIndexNuclei+i, circsMean, _TABLE_NAME);
		Table.set("stdDev. circ. of foci", startIndexNuclei+i, circsStdDev, _TABLE_NAME);
		Table.set("mean ar. of foci", startIndexNuclei+i, arsMean, _TABLE_NAME);
		Table.set("stdDev. ar. of foci", startIndexNuclei+i, arsStdDev, _TABLE_NAME);
		Table.set("mean solidity of foci", startIndexNuclei+i, soliditiesMean, _TABLE_NAME);
		Table.set("stdDev. solidity of foci", startIndexNuclei+i, soliditiesStdDev, _TABLE_NAME);
		xNucleus = Table.get("X", startIndexNuclei+i);
		yNucleus = Table.get("Y", startIndexNuclei+i);
		xSpots = getValuesWhere("X", "Image", "Nucleus", title[i], i+1, "Foci");
		ySpots = getValuesWhere("Y", "Image", "Nucleus", title[i], i+1, "Foci");
		dists = getValuesWhere("Dist. center", "Image", "Nucleus", title[i], i+1, "Foci");
		Array.getStatistics(dists, min, max, distsMean, distsStdDev);
		Table.set("mean dist. center", startIndexNuclei+i, distsMean, _TABLE_NAME);
		Table.set("stdDev. dist. center", startIndexNuclei+i, distsStdDev, _TABLE_NAME);
		borderDists = getValuesWhere("Dist. border", "Image", "Nucleus", title[i], i+1, "Foci");
		Array.getStatistics(borderDists, min, max, distsBorderMean, distsBorderStdDev);
		Table.set("mean dist. border", startIndexNuclei+i, distsBorderMean, _TABLE_NAME);
		Table.set("stdDev. dist. border", startIndexNuclei+i, distsBorderStdDev, _TABLE_NAME);
	}
//	setBatchMode(false);
	close("EDT");
	close("Mask");
}

function getValuesWhere(value, column1, column2, value1, value2, table) {
	col1 = Table.getColumn(column1, table);	
	col2 = Table.getColumn(column2, table);	
	colVal = Table.getColumn(value, table);	
	res = newArray(0);

	for (i = 0; i < col1.length; i++) {
		if (col1[i]==value1 && col2[i]==value2) res = Array.concat(res, colVal[i]);
	}
	return res;
}
function subtractBlurredImage(sigma) {
	imageID = getImageID();
	imageTitle = getTitle();
	run("Duplicate...", " ");
	blurredID = getImageID();
	blurredTitle = getTitle();
	run("Gaussian Blur...", "sigma="+sigma);
	imageCalculator("Subtract create", imageTitle, blurredTitle);
	subtractedID = getImageID();
	selectImage(blurredID);
	close();
}

function subtractBackground(radius) {
	run("Duplicate...", " ");
	run("Subtract Background...", "rolling="+_ROLLING_BALL_RADIUS+" stack");
}