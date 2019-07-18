var _WIDTH_OF_ROI = 12.26;
var _HEIGHT_OF_ROI = 6.72;
var _Y_MAX_DIST = _HEIGHT_OF_ROI/2;
var _X_MAX_DIST = _WIDTH_OF_ROI/2;
var _FIRST_TIME_POINT = 13;

placeRegion();

function placeRegion() {
	widthRegion = _WIDTH_OF_ROI;
	heightRegion = _HEIGHT_OF_ROI;
	toUnscaled(widthRegion);
	toUnscaled(heightRegion);
	
	xMaxDist = _X_MAX_DIST;
	yMaxDist = _Y_MAX_DIST;
	toUnscaled(xMaxDist);
	toUnscaled(yMaxDist);
	
	roiManager("select", 0);
	getBoundingRect(x, y, width, height);
	
	xStart = x-widthRegion+width;
	yStart = y-heightRegion+height;
	
	xEnd = x;
	yEnd = y;
	
	
	currentMean = 0;
	posX = 0; 
	posY = 0;
	for(x=xStart; x<=xEnd; x++) {
		for(y=yStart; y<=yEnd; y++) {
			makeRectangle(x, y, widthRegion, heightRegion);
			getStatistics(area, mean);
			if (mean>currentMean) {
				currentMean=mean;
				posX = x;
				posY = y;
			}
		}
	}
	makeRectangle(posX, posY, widthRegion, heightRegion);
}

function measure() {
	
}
