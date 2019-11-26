/**
  * MRI width measurement tool
  * 
  * Rotate the image so that the major axis of the object in the image is parallel to the horizontal axis.
  * Measure the width of a gap between cells where the gap is dark and the membranes of 
  * the cells or bright.
  *   
  * (c) 2019, INSERM
  * 
  * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 *
*/
var _TOLERANCE=8000;
var _DISPLAY_PLOT=true;
var _DO_Z_STACK = true;

var _NUMBER_OF_LINES = 11;
var _LINE_WIDTH = 27;


var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Width_Measurement_Tool";

exit();

macro "width measurement tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "width measurement tool help (f4) Action Tool - C070D29D3dD5eD68D76D7fD84D8cD99Da2Da3Da4Da5DbbDdaDdbC040D1cD1dD1eD1fD28D2eD2fD37D42D45D55D56D57D6bD6cD6fD79D7cD88D89DcfDe9Df3Df4C1a0D73D82D8eD9bD9cD9dDa7Da8Da9DaaDadDb7DbdDcdC010D0bD0cD18D19D1aD25D26D27D32D33DdeDeaDebDf6Df7C190D2bD39D4eD50D5cDa6Dc4Dc9DceDe5De6C050D2dD38D3eD3fD43D58D66D6aD78D7dD85D86D8bD92D98Dc5Dd6De8Df2C1c0D3aD3bD3cD4bD61D70D71D72D80Dc8Dd8De1De2C180D2aD54D59D8dD90DacDb5Dd7C050D48D6dD6eD87D8aD93D94D95D96D97Da0Dc6Dd5DdcC1b0D4aD60D62D63D81D8fD9eDb1Db4Db8Dc1Dd0Dd1De3De4C020D0dD0eD0fD1bD34D35D36D40D41D46D47D7aD7bDddDf5C190D4dD4fD51D53D5aD5bD64D74D9aDabDb9Dc0Dd9Df1C060D44D5fD65D67D69D77D7eD91Da1DbcC1f0D4cD9fDaeDafDb2Db3DbeDbfDc2Dc3Dd2Dd3De0Df0C180D2cD49D52D5dD75D83Db0Db6DbaDc7DcaDcbDccDd4De7"{
	run('URL...', 'url='+helpURL);
}

macro "rotate image (f5) Action Tool - C000T4b12r" {
	rotateImage();
}

macro "rotate image [f5]" {
	rotateImage();
}

macro "measure average width (f6) Action Tool - C000T4b12w" {
	width = getWidth();
	measureWidth(1, width, _TOLERANCE);
}

macro "measure average width [f6]" {
	width = getWidth();
	measureWidth(1, width, _TOLERANCE);
}

macro "measure average width (f6) Action Tool Options" {
	Dialog.create("measure average width options");
	Dialog.addNumber("tolerance for the maxima detection: ", _TOLERANCE);
	Dialog.addCheckbox("display plot", _DISPLAY_PLOT);
	Dialog.addCheckbox("measure stack", _DO_Z_STACK);
	Dialog.show();
	_TOLERANCE = Dialog.getNumber();
	_DISPLAY_PLOT = Dialog.getCheckbox();
	_DO_Z_STACK = Dialog.getCheckbox();
}

macro "measure width (f7) Action Tool - C000T4b12m" {
	measureWidth(_NUMBER_OF_LINES, _LINE_WIDTH, _TOLERANCE);
}

macro "measure width [f7]" {
	measureWidth(_NUMBER_OF_LINES, _LINE_WIDTH, _TOLERANCE);
}

macro "measure width (f7) Action Tool Options" {
	Dialog.create("measure average width options");
	Dialog.addNumber("nr. of lines: ", _NUMBER_OF_LINES);
	Dialog.addNumber("line width: ", _LINE_WIDTH);
	Dialog.show();
	_NUMBER_OF_LINES = Dialog.getNumber();
	_LINE_WIDTH = Dialog.getNumber();
}

function rotateImage() {	
	width = getWidth();
	height = getHeight();
	maxDimension = maxOf(width, height);
	
	run("Set Measurements...", "area standard centroid center fit shape display redirect=None decimal=9");
	setAutoThreshold("Default dark");
	run("Create Selection");
	run("Measure");
	row = nResults-1;
	angle = getResult("Angle", row);
	run("Select None");
	run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear enlarge stack");
}

function measureWidth(numberOfLines, widthOfLine, tolerance) {
	width = getWidth();
	height = getHeight();
	title = getTitle();
	imageID = getImageID();
	deltaLines = width / numberOfLines;
	print("Image " + title);
	print("parameters:");
	print("tolerance: ", tolerance);
	print("number of lines: ", numberOfLines);
	print("line width", widthOfLine);
	print("\n");

	Overlay.remove;
	Stack.getPosition(channel, slice, frame);
	startSlice = slice;
	nrOfSlices = 1;
	displayPlot = _DISPLAY_PLOT;
	Stack.getDimensions(width, height, channels, slices, frames);
	if (_DO_Z_STACK && slices>1) {
		nrOfSlices = slices;
		startSlice = 1;
		_DISPLAY_PLOT = false;
	}
	for (s = 0; s < nrOfSlices; s++) {
		selectImage(imageID);
		if (slices>1) Stack.setSlice(startSlice+s);
		averageDistances = newArray(0);
		leftCrossings = newArray(0);
		rightCrossings = newArray(0);
		xPositions = newArray(0);
		for (i = 0; i < numberOfLines; i++) {
			x = (deltaLines / 2.0) + (i*deltaLines);
			xPositions = Array.concat(xPositions, x);
			print("" + i + ". Position: " + x);
			makeProfilePlotAtPosition(x, 0, x, height, widthOfLine);
			Plot.getValues(xpoints, profile);
			if (!_DISPLAY_PLOT) run("Close");
			else selectImage(imageID);
			maximaPositions = findMiddleMaxima(xpoints, profile, tolerance);
			if (maximaPositions[0]<0) {
				crossings = newArray(2);
				crossings[0] = 0;
				crossings[1] = 0;
			} else {
				Array.sort(maximaPositions);
				print("Maxima: ");
				Array.print(maximaPositions);
				delta=xpoints[1] - xpoints[0];
				first = firstDerivative(delta, profile);
				second = firstDerivative(delta, first);
				crossings = zeroCrossings(xpoints, second);	
				crossings = valuesBetween(crossings, maximaPositions[0], maximaPositions[1]);
				print("Inflection points: ");
				Array.print(crossings);
			}
			averageDistance = abs(crossings[crossings.length-1]-crossings[0]);
			averageDistances = Array.concat(averageDistances, averageDistance);
			leftCrossings = Array.concat(leftCrossings, crossings[0]);
			rightCrossings = Array.concat(rightCrossings, crossings[crossings.length-1]);
			print("\n");
			selectImage(imageID);
		}
		reportDistances(averageDistances, startSlice + s);
		reportSummaryOfDistances(averageDistances);
		displayMeasurementPoints(xPositions, leftCrossings, rightCrossings);
	}
	if (_DO_Z_STACK) {
		_DISPLAY_PLOT = displayPlot;
	}
}

function reportDistances(averageDistances, slice) {
	if (!isOpen("width_measurements")) {
		Table.create("width_measurements");
		getLocationAndSize(x, y, width, height);
		Table.setLocationAndSize(x, y, 600, 400);
	}
	title = getTitle();
	selectWindow("width_measurements");
	Table.showRowNumbers(true);
	for (i = 0; i < averageDistances.length; i++) {
		row = Table.size;
		Table.set("image", row, title);
		Table.set("width", row, averageDistances[i]);
		Table.set("slice", row, slice);
	}	
	Table.update;
}

function displayMeasurementPoints(xPositions, leftCrossings, rightCrossings) {
	width = getWidth();
	unscaledLeftCrossings = Array.copy(leftCrossings);
	unscaledRightCrossings = Array.copy(rightCrossings);
	a = 0;
	Stack.getPosition(channel, slice, frame);
	for (i = 0; i < leftCrossings.length; i++) {
		toUnscaled(a, unscaledLeftCrossings[i]);
		toUnscaled(a, unscaledRightCrossings[i]);
	}
	if (xPositions.length==1) {
		makeLine(xPositions[0], unscaledLeftCrossings[0], xPositions[0], unscaledRightCrossings[0], width);
		Overlay.addSelection;
		Overlay.setPosition(slice);
	} else {
		makeSelection("polyline", xPositions, unscaledLeftCrossings);
		Overlay.addSelection;
		Overlay.setPosition(slice);
		makeSelection("polyline", xPositions, unscaledRightCrossings);
		Overlay.addSelection;		
		Overlay.setPosition(slice);
	}
	run("Select None");
	Overlay.show;
}

function reportSummaryOfDistances(averageDistances) {
	if (averageDistances.length<2) return;
	if (!isOpen("summary_of_width_measurements")) {
		Table.create("summary_of_width_measurements");
		getLocationAndSize(x, y, width, height);
		Table.setLocationAndSize(x, y, 600, 400);
	}
	title = getTitle();
	selectWindow("summary_of_width_measurements");
	Array.getStatistics(averageDistances, min, max, mean, stdDev);
	Table.showRowNumbers(true);
	row = Table.size;
	Table.set("image", row, title);
	Table.set("mean width", row, mean);
	Table.set("stdDev of width", row, stdDev);
	Table.set("min. width", row, min);
	Table.set("max. width", row, max);
	Table.update;
}

function makeProfilePlotAtPosition(x1, y1, x2, y2, lineWidth) {
	imageID = getImageID();
	makeLine(x1, y1, x2, y2, lineWidth);
	run("Plot Profile");
}

function findMiddleMaxima(xpoints, profile, tolerance) {
	result = newArray(2);
	maxima = Array.findMaxima(profile, tolerance);
	middleIndex = findLowestMinimumBetweenHighestMaxima(xpoints, profile, tolerance);
	if (middleIndex<0) {
		result[0] = -1;
		return result;
	}
	maximaIndicesByMiddle = Array.copy(maxima);
	for (i = 0; i < maximaIndicesByMiddle.length; i++) {
		maximaIndicesByMiddle[i] = abs(maximaIndicesByMiddle[i] - middleIndex);
	}
	Array.print(maximaIndicesByMiddle);
	rankPositions = Array.rankPositions(maximaIndicesByMiddle);
	if (maximaIndicesByMiddle.length>=2) {
		result[0] = xpoints[maxima[rankPositions[0]]];
		result[1] = xpoints[maxima[rankPositions[1]]];
	}	
	return result;
}

function firstDerivative(delta, discreteCurve) {
	length = discreteCurve.length;
	derivative = newArray(length);
	if (discreteCurve.length<2) return derivative;
	derivative[0] = (discreteCurve[1]-discreteCurve[0]) / delta;
	derivative[length-1] = (discreteCurve[length-1]-discreteCurve[length-2]) / delta;
	for (i = 1; i < discreteCurve.length-1; i++) {
		derivative[i] = (discreteCurve[i+1]-discreteCurve[i-1]) / (2*delta);
	}
	return derivative;
}

function zeroCrossings(xpoints, discreteCurve) {
	crossings = newArray(0);
	deltaX = xpoints[1] - xpoints[0];
	for (i = 0; i < discreteCurve.length-1; i++) {
		if (discreteCurve[i] == 0) {
			crossings = Array.concat(crossings, xpoints[i]);
			continue;
		}
		if (discreteCurve[i]*discreteCurve[i+1]<0) {
			m = (discreteCurve[i+1] - discreteCurve[i]) / deltaX;
			b = discreteCurve[i] - (m * xpoints[i]);
			xIntercept = -b/m;
			crossings = Array.concat(crossings, xIntercept);
		}
	}
	return crossings;
}

function valuesBetween(values, min, max) {
	valuesInInterval = newArray(0);
	if (min>max) {
		tmp = min;
		min = max;
		max = tmp;
	}
	for (i = 0; i < values.length; i++) {
		if (values[i]>min && values[i]<max) {
			valuesInInterval = Array.concat(valuesInInterval, values[i]);
		}
	}
	return valuesInInterval;
}

function findLowestMinimumBetweenHighestMaxima(xpoints, profile, tolerance) {
	result = -1;
	maxima = Array.findMaxima(profile, tolerance);
	minima = Array.findMinima(profile, tolerance);
	if (maxima.length<2 || minima.length<1) return -1;
	minima = valuesBetween(minima, maxima[0], maxima[1]);
	result = minima[0];
	return result;
}