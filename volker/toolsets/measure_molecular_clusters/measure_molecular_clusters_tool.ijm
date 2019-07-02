_CHANNELS = newArray(1);
_CHANNELS[0] = 3;
_MIN_DIAMETER = 3;
_MAX_DIAMETER = 10;
_INVERT = true;
_MIN_AREA = 5;
_AUTO_FIND_CONTRAST = true;

for(c=0; c<_CHANNELS.length; c++) {
	Stack.setChannel(_CHANNELS[c]+1);
	run("Duplicate...", " ");
	dogFilterAction();
	setAutoThreshold("Default dark");
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity pixel exclude add");
	close();
	close();
}

function dogFilterAction() {
	init();
	if (_AUTO_FIND_CONTRAST) autoSetContrast();
	sigmaMin = 	(_MIN_DIAMETER/2)/2.5;
	sigmaMax =  (_MAX_DIAMETER/2)/2.5;
	run("16-bit");
	if (_INVERT) run("Invert");
	DoGFilter(sigmaMin, sigmaMax);
}

function init() {
	run("Select None");
	roiManager("reset");
	run("Clear Results");
}

function DoGFilter(sigmaMin, sigmaMax) {
	imageID = getImageID();
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+sigmaMin);
	rename("DoGImageSmallSigma");
	selectImage(imageID);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+sigmaMax);
	rename("DoGImageBigSigma");
	imageCalculator("Subtract create", "DoGImageBigSigma","DoGImageSmallSigma");
	selectImage("DoGImageSmallSigma");
	close();
	selectImage("DoGImageBigSigma");
	close();
}

function autoSetContrast() {
	getStatistics(area, mean);
	mode = getMode();
	if (mean<=mode) {
		// dark Spots
		_INVERT = false;
	} else {
	    // bright spots
		_INVERT = true;
	}
}

function getMode() {
	getHistogram(values, counts, 255);
	maxIndex = -1;
	max = -1;
	for(i=0; i<values.length; i++) {
		value = counts[i];
		if (value>max) {
			max = value;
			maxIndex = i;
		}
	}
	mode = values[maxIndex];
	return mode;
}