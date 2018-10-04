/**
  * MRI Root Hair Tools
  * 
  * The Root Hair Tools help to analyze the density of root hair
  * 
  * written 2017 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * and Térence Lee-Chao-Shit
  * 
  */


var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Root_Hair_Tools";
  
var _INVERT = true;
var _RADIUS = 250;
var _SUBTRACT_BACKGROUND_RADIUS =500;
var _MIN_AREA = 50000;
var _SUBTRACT_BACKGROUND = true;
var _THRESHOLDING_METHOD = "Li";
var _DEBUG = false;
var _X_INC, _Y_INC;
var _WIDTH_OF_MAIN_ROOT;
var _LENGTH_OF_MAIN_ROOT;
var _UPPER_LENGTH;
var _LOWER_LENGTH;
var _FILENAME;
var _UNIT, _PIXEL_WIDTH;
var _FILL_HOLES = true;

macro "MRI Root Hair Tool Help Action Tool - C000D00D01D02D03D0cD0fD10D11D12D13D15D1bD1cD1dD1eD1fD20D21D22D23D25D2fD30D32D35D40D41D42D43D44D45D4fD50D51D52D5bD5cD5dD5eD5fD61D6fD70D71D72D7aD7bD7cD7dD7eD7fD80D81D83D84D8eD8fD91D92D93D94D9fDa0Da1DaeDafDb0DbaDbbDbcDbdDbeDc0Dc1DcbDceDcfDd0Dd1Dd2Dd3Dd4DdaDdcDddDdeDdfDe0De1De3De9DeaDecDedDeeDefDf0Df1Df3DfcDfdDfeDffC000D6bC000D0eD16D24D46D82D85DcdDf2DfbC000D04D05D14D31D33D60D6eD90DbfDdbDebDfaC000DccC000D0dD6dD95De2C000D2cD34D4cD74Da4DabDf4C000D55D62D8bDc3C000D3fD6cD9eDb1C000D26D36C000D0bDcaC000De4C000D2eD4eD53D8dDa2DadC000C111D06D2dD54D56D73D8cDa3Da5DacDc2C111D4dC111Dd9Df9C111D6aC111D2bC111D4bD75DaaDc4C111D8aC111C222C333C444C555C666C777C888C999CaaaCbbbCcccCdddCeeeD3eD9dDb2CeeeD63CeeeD65Db4CeeeD3cD9bCeeeDc9CeeeD0aD3bD5aD9aDf5CfffDd5CfffD2aD3dD64D86D9cDa9Db3CfffD07D37D69Da6Df8CfffD17D27D47D57D66D79D89D96Db5Dd8De8CfffD09CfffDc7Df6CfffD98Db7CfffD39D4aD67D76Db9Dc5CfffD1aD3aCfffD08D18D19D28D29D38D48D49D58D59D68D77D78D87D88D97D99Da7Da8Db6Db8Dc6Dc8Dd6Dd7De5De6De7Df7" {
	run('URL...', 'url='+helpURL);
}

macro "Select main root Action Tool - C000T4b12s" {
	width = getWidth();
	prepareImage();
	selectMainRoot();
	_WIDTH_OF_MAIN_ROOT = measureWidthAt(width/2);
}

macro 'Select main root Action Tool Options' {
	 Dialog.create("Select Root Options");
	 Dialog.addNumber("create background radius: ", _RADIUS);
	 Dialog.addNumber("subtract background radius: ", _SUBTRACT_BACKGROUND_RADIUS);
	 Dialog.addNumber("min. area: ", _MIN_AREA);
	 Dialog.addCheckbox("invert", _INVERT);
	 Dialog.addCheckbox("subtract background", _SUBTRACT_BACKGROUND);
	 Dialog.addChoice("thresholding method", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError",  "Minimum", "Moments",  "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"),  _THRESHOLDING_METHOD);
	 Dialog.addCheckbox("Fill holes when segmenting root hair", _FILL_HOLES);
	Dialog.show();
	 _RADIUS = Dialog.getNumber();
	 _SUBTRACT_BACKGROUND_RADIUS = Dialog.getNumber();
	 _MIN_AREA = Dialog.getNumber();
	 _INVERT = Dialog.getCheckbox();
	 _SUBTRACT_BACKGROUND = Dialog.getCheckbox();
	 _THRESHOLDING_METHOD = Dialog.getChoice();
      _FILL_HOLES = Dialog.getCheckbox();
}

macro "Create density plot Action Tool - C000T4b12c" {
	createRootHairDensityPlots();
}

function prepareImage() {
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	run("8-bit");
	run("Remove Overlay");
	if (_INVERT) run("Invert");
}

function selectMainRoot() {
	roiManager("Reset");
	type = selectionType(); 
	if (selectionType > -1) {
		transformSelection();
		roiManager("add");
		roiManager("Show None");
		roiManager("Show All");
		return;
	}
	sourceImageID = getImageID();
	run("Duplicate...", " ");
	tmpImageID = getImageID();
	if (_SUBTRACT_BACKGROUND) run("Subtract Background...", "rolling="+_SUBTRACT_BACKGROUND_RADIUS);
	run("Subtract Background...", "rolling="+_RADIUS+" create");
	setAutoThreshold(_THRESHOLDING_METHOD + " dark");
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity add");
	close();
	roiManager("Show None");
	roiManager("Show All");
	roiManager("select", 0);
	run("Enlarge...", "enlarge=5");
	run("Enlarge...", "enlarge=-5");
	roiManager("Update");
}	

function transformSelection() {
	id = getImageID();	
	run("Create Mask");
	maskID = getImageID();
	run("Create Selection");
	close();
	selectImage(id);
	run("Restore Selection");
}

function measureWidthAt(x) {
	roiManager("select", 0);
    run("Create Mask");
	height = getHeight();
	yLower = getLowerY(x, height);
	upperPoint = getUpperPoint(x,yLower);
	result = upperPoint[2];
	toScaled(result);
	close();
	makeLine(x,yLower,upperPoint[0],upperPoint[1]); 
	dx = upperPoint[0] - x;
	dy = upperPoint[1] - yLower;
	n = round(sqrt(dx*dx + dy*dy));
    _X_INC = dx / n;
    _Y_INC = dy / n;

	return result;
}

function getLowerY(x, yStart) {
	found = false;
	yResult = yStart;
	for(y=yStart; y>=0 && !found; y--) {
		p = getPixel(x,y);
		if (p>0) {
			found = true;
			yResult = y;
		}
	}
	return yResult;
}

function getUpperPoint(x, yStart) {
	width = getWidth();
	found = false;
	yResult = yStart;
	for(y=yStart; y>=0 && !found; y--) {
		p = getPixel(x,y);
		if (p==0) {
			found = true;
			yResult = y+1;
		}
	}
	lowerX = x;
	lowerY = yStart;
	upperX = x;
	upperY = yResult;
	bestX = x;
	bestY = yResult;
	minSqDist = ((lowerY-upperY)*(lowerY-upperY))+((lowerX-upperX)*(lowerX-upperX));
	y = upperY;
	for(i=x-1; i>=(x-(lowerY-upperY)); i--) {
		y = findUpperBorderFrom(i, y);
		sqDist =  ((lowerY-y)*(lowerY-y))+((lowerX-i)*(lowerX-i));
		if (_DEBUG) print(i,y,sqDist);
		if (sqDist<minSqDist) {
			minSqDist = sqDist;
			bestX = i;
			bestY = y;
			if (_DEBUG) print(minSqDist);
		}
	}	
	for(i=x+1; i<=(x+(lowerY-upperY)); i++) {
		y = findUpperBorderFrom(i, y);
		sqDist =  ((lowerY-y)*(lowerY-y))+((lowerX-i)*(lowerX-i));
		if (_DEBUG) print(i,y,sqDist);
		if (sqDist<minSqDist) {
			minSqDist = sqDist;
			bestX = i;
			bestY = y;
			if (_DEBUG) print(minSqDist);
		}
	}	
	result = newArray(3);
	result[0] = bestX;
	result[1] = bestY;
	result[2] = sqrt(minSqDist);
	return result;
}

function findUpperBorderFrom(xStart, yStart) {
	height= getHeight();
	p = getPixel(xStart, yStart);
	found = false;
	yResult = yStart;
	if (p==0) {
		for(y=yStart; y<height && !found; y++) {
			p = getPixel(xStart,y);
			if (p>0) {
				found = true;
				yResult = y;
			}
		}
	} else {
		
		for(y=yStart; y>=0&& !found; y--) {
			p = getPixel(xStart,y);
			if (p==0) {
				found = true;
				yResult = y-1;
			}
		}
	}
	return yResult;
}

function binarizeRootWithHairs() {
	run("Select None");
	run("Remove Overlay");
	setAutoThreshold("Triangle");
	convertToMask();
	run("Analyze Particles...", "size=200-Infinity show=Masks in_situ");
	if (_FILL_HOLES) run("Fill Holes");
}

function convertToMask() {
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0 ,0);
	run("Create Selection");
	run("Create Mask");
	run("Invert");
}
function createRootHairDensityPlots() {
	_FILENAME = File.name;
	getPixelSize(_UNIT, _PIXEL_WIDTH, pixelHeight);
	binarizeRootWithHairs();
	imageID = getImageID();
	roiManager("select", 0);
	getSelectionBounds(x, y, width, height);
	run("Area to Line");
	cutSelection(x, x+width);
	roiManager("select", 1);
	moveSelectionOutOfObject(-1);
	roiManager("select", 2);
 	moveSelectionOutOfObject(1);
    roiManager("select", 1);
	createDensityPlot(-1);
	selectImage(imageID);
	roiManager("select", 2);
	createDensityPlot(1);
}
	
function cutSelection(xMin,xMax) {
	Roi.getCoordinates(xpoints, ypoints);
	positions = Array.rankPositions(xpoints);
	index = positions[1];
	xpoints = moveIndexToZero(index, xpoints);
	ypoints = moveIndexToZero(index, ypoints);
	borderHits = 0;
	lastX = -1;
	xUpper = newArray(0);
	yUpper = newArray(0);
	xLower = newArray(0);
	yLower = newArray(0);
	for(i=0; i<xpoints.length; i++) {
		x = xpoints[i];
		y = ypoints[i];
		if ((x==xMax) && (x==lastX)) {
			while(x==lastX) {
				i++;
				lastX = x;
				x = xpoints[i];
				y = ypoints[i];
			}
			borderHits++;
		}
		if (borderHits==0) {
			xLower = Array.concat(x, xLower);
			yLower = Array.concat(y, yLower);
		}
		
		if (borderHits==1) {
			xUpper = Array.concat(xUpper, x);
			yUpper = Array.concat(yUpper, y);
		}
		lastX = x;	
	}
	if (yLower[0]<yUpper[0]) {
			xTemp = xUpper;
			yTemp = yUpper;
			xUpper = xLower;
			yUpper = yLower;
			xLower = xTemp;
			yLower = yTemp;
	}
	makeSelection("freeline", xUpper, yUpper);
	roiManager("add");
	run("Measure");
	_UPPER_LENGTH = getResult("Length", nResults-1);
	makeSelection("freeline", xLower, yLower);
	roiManager("add");
	run("Measure");
	_LOWER_LENGTH = getResult("Length", nResults-1);
}


function moveSelectionOutOfObject(step) {
	profile = getProfile();
	Array.getStatistics(profile, min, max, mean, stdDev);
	threshold = mean;
	maxima = Array.findMaxima(profile, 1);
	
	lastNrOfHairs = maxima.length;
	nrOfHairs = maxima.length;
	i=0;
	while (mean>=threshold || nrOfHairs<1 || nrOfHairs>=lastNrOfHairs) {
		moveSelection(step);
		profile = getProfile();
		Array.getStatistics(profile, min, max, mean, stdDev);
		maxima = Array.findMaxima(profile, 1);
		lastNrOfHairs = nrOfHairs;
		nrOfHairs = maxima.length;
	}
	run("Add Selection...");
}

function createDensityPlot(step) {
		resultData = newArray();
		nrOfHairsData = newArray();
		ratioPixelHairs = newArray();
		nrOfPixels = -1;
		dist = 0;
		while(nrOfPixels!=0) {
			profile = getProfile();
			sum = 0;
			for(i=0;i<profile.length;i++) {
				sum = sum + profile[i];
			}
			nrOfPixels = sum / 255;
			
			resultData = Array.concat(resultData, nrOfPixels);

			maxima = Array.findMaxima(profile, 1);
			nrOfHairs = maxima.length;
			nrOfHairsData = Array.concat(nrOfHairsData, nrOfHairs);

			ratioPixelHairs = Array.concat(ratioPixelHairs, nrOfPixels / nrOfHairs);
			moveSelection(step);
			dist++;
		}
		distance = (dist - 1) * _PIXEL_WIDTH;
		title = "density by distance " + "(top)";
		if (step == 1) title = "density by distance " + "(bottom)";
		Plot.create(title, "distance [pixel]", "number of pixels", resultData);
		Plot.show();

		title = "nr. of hairs by distance " + "(top)";
		if (step == 1) title = "nr. of hairs by distance " + "(bottom)";
		Plot.create(title, "distance [pixel]", "nr. of Hairs", nrOfHairsData);
		Plot.show();

		title = "(nr. of pixel / nr. of hairs) by distance " + "(top)";
		if (step == 1) title = "(pixel / hairs) by distance " + "(bottom)";
		Plot.create(title, "distance [pixel]", "nr. of pixels / nr. of hairs", ratioPixelHairs);
		Plot.show();

		title = "root hair measurements";
		handle = "[" + title + "]";
		 if (!isOpen(title)) {
		 	 run("Table...", "name="+handle+" width=400 height=600");
		 	 print(handle, "\\Headings:n\timage\tside\tlength\twidth\tnr. hairs\tmax Length\taverage length\tnr. of Pixel\tarea\tdensity");
		 }
		 selectWindow(title);
		 content = getInfo("window.contents");
		 lines = split(content, "\n");
		 nr = lines.length;
		 side = "top";
		 length = _UPPER_LENGTH;
		 if (step>0) {
		 	side = "bottom";
		 	length = _LOWER_LENGTH;
		 }
		 Array.getStatistics(nrOfHairsData, min, max, mean, stdDev);
		 averageLength = calculateAverageLength(nrOfHairsData);
		 totalNumberOfPixels = calculateTotalNumberOfPixels(resultData);
		 pixelDensity = totalNumberOfPixels / (profile.length * resultData.length);
		 totalArea = _PIXEL_WIDTH * _PIXEL_WIDTH * totalNumberOfPixels;
		 print(handle, nr +"\t"+ _FILENAME +"\t"+ side +"\t"+ length +"\t"+ _WIDTH_OF_MAIN_ROOT +"\t"+ max +"\t"+ distance + "\t" + averageLength + "\t" + totalNumberOfPixels + "\t" + totalArea + "\t" + pixelDensity); 
}

function calculateTotalNumberOfPixels(data) {
	sum = 0;
	for (i=0; i<data.length; i++) {
		sum = sum + data[i];	
	}
	return sum;
}

function calculateAverageLength(nrPerDistance) {
	average = 0;
	currentNumber = 0;
	lastNumber = 0;
	counter = 0;
	for (i=0; i<nrPerDistance.length; i++) {
		currentNumber = nrPerDistance[i];
		if (currentNumber<lastNumber) { 
			diff = lastNumber - currentNumber;
			counter = counter + diff;
			average = average + ((i-1) * diff);
		}
		lastNumber = currentNumber;
	}
	average = average / counter;
	average = average * _PIXEL_WIDTH;
	return average;
}

function moveIndexToZero(index, values) {
	result = Array.concat(Array.slice(values, index, values.length), Array.slice(values, 0, index));
	return result;
}

function moveSelection(step) {
	Roi.getCoordinates(xpoints, ypoints);
	for(i=0; i<ypoints.length; i++) {
		ypoints[i] = ypoints[i] + ((-1 * step) * _Y_INC);	
	}
	
	for(i=0; i<xpoints.length; i++) {
		xpoints[i] = xpoints[i] + ((-1 * step) * _X_INC);	
	}
	makeSelection("freeline", xpoints, ypoints);
	roiManager("update");
}
