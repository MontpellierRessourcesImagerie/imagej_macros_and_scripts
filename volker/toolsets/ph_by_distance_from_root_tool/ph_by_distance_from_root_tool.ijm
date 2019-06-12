_NR_Of_OPEN = 20;
_NR_OF_CLOSE = 20;
_MIN_BOX_AREA = 2000000;
_PROBE_LENGTH_FACTOR = 1/4.5;
_PROBE_POS_PERCENTAGE = 80;
_FLIP_IMAGE_TO_RIGHT = true;

findOrigin();

function findOrigin() {
	inputImageID = getImageID();
	detectBox();
	maskID = getImageID();
	setAutoThreshold("Default");
	run("Create Selection");
	getBoundingRect(x, y, width, height);
	xL = findStartX(x, y, width, height);
	xR = findEndX(x, y, width, height);
	
	yL = findYStartAt(xL, y);
	yR = findYStartAt(xR, y);
	
	yMid = min(yL, yR) + (abs(yR-yL) / 2);
	makeLine(xL, yMid, xR, yMid);
	selectImage(maskID);
	close();
	selectImage(inputImageID);
	makePoint(xL, yMid, "large yellow hybrid");
}

function detectBox() {
	inputImageID = getImageID();
	run("Duplicate...", " ");
	maskID = getImageID();
	run("16-bit");
	setAutoThreshold("Default");
	run("Convert to Mask");
	run("Analyze Particles...", "size=2000000-Infinity show=Masks in_situ");
	run("Fill Holes");
	run("Options...", "iterations="+_NR_Of_OPEN+" count=1 do=Open");
	run("Options...", "iterations="+_NR_OF_CLOSE+" count=1 do=Close");
	run("Analyze Particles...", "size="+_MIN_BOX_AREA+"-Infinity show=Masks in_situ");
	setAutoThreshold("Default");
	run("Set Measurements...", "area mean modal min centroid bounding fit integrated limit display redirect=None decimal=5");
	run("Measure");
	angle = getResult("Angle", nResults-1);
	if (angle>90) {
		angle = -1* (180-angle);
	}
	rotateBy(angle);
	if (_FLIP_IMAGE_TO_RIGHT) run("Rotate 90 Degrees Right");
	setThreshold(1, 255);
	setOption("BlackBackground", false);
	run("Convert to Mask");
	selectImage(inputImageID);
	rotateBy(angle);
	if (_FLIP_IMAGE_TO_RIGHT) run("Rotate 90 Degrees Right");
	selectImage(maskID);
}

function rotateBy(angle) {
	run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear");
}

function moveLineToObjectBorder(x, y, deltaX, probeLength, minLength) {
	makeLine(x, y, x, y+probeLength);
 	getStatistics(area, mean);
	nrOfPixels = (mean * probeLength) / 255; 
	while(nrOfPixels<minLength) {
		x = x + deltaX;
		makeLine(x, y, x, y+probeLength);
		getStatistics(area, mean);
		nrOfPixels = (mean * probeLength) / 255; 
	}
	return x;
}

function findStartX(x, y, width, height) {
	probeLength = height * _PROBE_LENGTH_FACTOR;
	minLength = (probeLength * _PROBE_POS_PERCENTAGE) / 100;
	
	xL = moveLineToObjectBorder(x, y, 1, probeLength, minLength);
	return xL;
}

function findEndX(x, y, width, height) {
	probeLength = height * _PROBE_LENGTH_FACTOR;
	minLength = (probeLength * _PROBE_POS_PERCENTAGE) / 100;
	
	xR = moveLineToObjectBorder(x+width, y, -1, probeLength, minLength);
	return xR;
}

function findYStartAt(x, yInitial) {
	y = yInitial;
	p = getPixel(x, y);
	while(p<255 && y<3000) {
		y++;
		p = getPixel(x, y);
		print(x,y,p);
	}
	return y;
}

function min(a,b) {
	if (a<b) return a;
	else return b;
}
