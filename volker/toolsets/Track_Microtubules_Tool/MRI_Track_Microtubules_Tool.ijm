var _EXT = ".nd";
var _CURRENT_IMAGE_ID = -1;
var _CURRENT_SKELETON_ID = -1;
var	_RECTANGLE_WIDTH = 10;
var _PRECISION_RADIUS = 1;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Track_Microtubules_Tool";

macro "track microtubules tools help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "track microtubules tools help Action Tool (f4) - C111D01D02D05D06D07D08D0cD0dD0eD0fD1cD1dD1fD28D29D2aD2bD2cD2dD2fD35D38D39D3aD3bD3cD3dD41D46D47D48D49D4aD4bD4cD4dD4eD4fD51D5cD5dD5eD5fD60D70D9fDa0Da1Da2Db0Db1Db2Db4Db9DbaDbeDc0Dc1Dc2Dc4Dc5Dc9DcbDccDceDcfDd0Dd1Dd2Dd3Dd4Dd5DddDdeDdfDe0De1De2De3De4DeeDefDf0Df1Df2Df3Df4C222D0aD0bD10D1aD20D27D32D33D52D53D54D58D6cD92D94D97D98D99D9aD9bD9cD9eDd7Dd8Dd9De6De8De9Df6Df7DfeDffC111D00D03D04D09D11D12D13D14D15D16D17D18D19D1bD1eD21D22D23D24D25D26D2eD30D31D34D36D37D3eD3fD40D42D43D44D45D50D55D56D57D59D5aD5bD80D90D91Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb3Db5Db6Db7Db8DbbDbcDbdDbfDc3Dc6Dc7Dc8DcaDcdDd6DdaDdbDdcDe5DeaDebDecDedDf5Df8Df9DfaDfbDfcDfdC333D66D69D86D87C222D6bD93D95D96De7C737D61D62D63D71D72D73D81D82D83C277D6dD6eD6fD7dD7eD7fD8dD8eD8fC333D6aD84D85C555D8cC444D64C888D74D75D76D77D78D79D7aD7bD7cC444D65D67D68D88D9dC555D89D8aD8b" {
	run('URL...', 'url='+helpURL);
}

macro 'stack registration [f1]' {
	registerStacks();
}

macro "stack registration Action Tool (f1) - C000T4b12s" {
	registerStacks();	
}

macro 'find end points [f2]' {
	skeletonizeMicrotubules();
	findEndPoints();
}


macro "find end points Action Tool (f2) - C000T4b12f" {
	skeletonizeMicrotubules();
	findEndPoints();
}

macro 'track ends [f3]' {
	trackEnds();
}

macro "track ends Action Tool (f3) - C000T4b12t" {
	trackEnds();
}


function registerStacks() {
	inDir = getDirectory("Please select the input directory!");
	files = getFileList(inDir);
	ndFiles = filterFiles(files);
	regDir = inDir+"reg"+File.separator;
	File.makeDirectory(regDir);
	print("\\Clear");
	print("\\Update0:Stackreg started...")
	for (i = 0; i < ndFiles.length; i++) {
		print("\\Update1:Processing image "+(i+1)+ " of "+ ndFiles.length);
		file = ndFiles[i];
		path = inDir + file;
		run("Bio-Formats", "open="+path+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("StackReg ", "transformation=[Rigid Body]");
		saveAs("tiff", regDir+file);
		close();
	}
	print("\\Update2:Stackreg finished...")
}

function skeletonizeMicrotubules() {
	_CURRENT_IMAGE_ID = getImageID();
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	roiManager("reset");
	run("Remove Overlay");
	run("Remove Overlay");
	run("FeatureJ Laplacian", "compute smoothing=2");
	run("Convert to Mask", "method=Default background=Light calculate");
	run("Analyze Particles...", "size=1.5-Infinity add slice exclude");
	roiManager("Combine");
	run("Clear Outside", "stack");
	run("Select None");
	run("Skeletonize", "stack");
	_CURRENT_SKELETON_ID = getImageID();
}

function filterFiles(files) {
	newFiles = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, _EXT)!=-1) {
			newFiles = Array.concat(newFiles, file);
		}
	}
	return newFiles;
}

function findEndPoints() {
	START_X1=newArray(0);
	START_Y1=newArray(0);
	START_X2=newArray(0);
	START_Y2=newArray(0);
	
	setSlice(1);
	count = roiManager("count");
	for (r = 0; r < count; r++) {
		roiManager("select", r);
		getBoundingRect(bx, by, bwidth, bheight);
		run("Duplicate...", " ");
		run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
		run("Select None");
		width = getWidth();
		height = getHeight();
		run("Canvas Size...", "width="+(width+2)+" height="+(height+2)+" position=Center zero");
		run("Points from Mask");
		getSelectionCoordinates(xpoints, ypoints);
		run("Select None");
		nr = 0;
		X1=-1;
		Y1=-1;
		X2=-1;
		Y2=-1; 
		for(i=0; i<xpoints.length; i++) {
			x = xpoints[i];
			y = ypoints[i];
		
			makeRectangle(x-1, y-1, 3, 3);
			getStatistics(area, mean);
			if(mean>56 && mean<57) {
				if (nr==0) {
					X1 = x;
					Y1 = y;
				} else {
					X2 = x;
					Y2 = y;
				}
				nr++;
			}
		}
		if (nr==2) {
				START_X1 = Array.concat(START_X1, bx+X1-1);
				START_Y1 = Array.concat(START_Y1, by+Y1-1);
				START_X2 = Array.concat(START_X2, bx+X2-1);
				START_Y2 = Array.concat(START_Y2, by+Y2-1);
		}
		close();
	}
	selectImage(_CURRENT_IMAGE_ID);
	run("Point Tool...", "type=Circle color=Magenta size=Medium label");
	makeSelection("point", START_X1, START_Y1);
	Overlay.addSelection("magenta");
	makeSelection("point", START_X2, START_Y2);
	Overlay.addSelection("cyan");
	Overlay.show;
	roiManager("Deselect");
	roiManager("reset");
	for (i = 0; i < START_X1.length; i++) {
		makeRotatedRectangle(START_X1[i], START_Y1[i], START_X2[i], START_Y2[i], _RECTANGLE_WIDTH);
		roiManager("add");
	}
	run("Select None");
	roiManager("Set Color", "green");
	roiManager("Show None");
	roiManager("Show All");
}

function trackEnds() {
	index = roiManager("index");
	if (index<0) {
		print("You need to select a roi in the roi-manager for the tracking.");
		return;
	}
	selectImage(_CURRENT_IMAGE_ID);
	Overlay.activateSelection(0);
	getSelectionCoordinates(xpoints1, ypoints1);
	Overlay.activateSelection(1);
	getSelectionCoordinates(xpoints2, ypoints2);
	selectImage(_CURRENT_SKELETON_ID);
	x1 = minOf(xpoints1[index], xpoints2[index]);
	x2 = maxOf(xpoints1[index], xpoints2[index]);
	y1 = minOf(ypoints1[index], ypoints2[index]);
	y2 = maxOf(ypoints1[index], ypoints2[index]);
	makeLine(x1-1, y1-1, x2+2, y2+2);
	run("To Bounding Box");
	getBoundingRect(bx, by, bwidth, bheight);
	run("Duplicate...", "duplicate");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	width = getWidth();
	height = getHeight();
	run("Canvas Size...", "width="+(width+2)+" height="+(height+2)+" position=Center zero");
	// get the middle
	setSlice(1);
	run("Set Measurements...", "centroid redirect=None decimal=3");
	run("Create Selection");
	run("Measure");
	run("Select None");
	mX = getResult("X", nResults-1);
	mY = getResult("Y", nResults-1);
	START_X1=newArray(0);
	START_Y1=newArray(0);
	START_X2=newArray(0);
	START_Y2=newArray(0);
	// FIND end points again START

	run("Points from Mask");
	getSelectionCoordinates(xpoints, ypoints);
	run("Select None");
	nr = 0;
	X1=-1;
	Y1=-1;
	X2=-1;
	Y2=-1; 
	for(i=0; i<xpoints.length; i++) {
		x = xpoints[i];
		y = ypoints[i];
	
		makeRectangle(x-1, y-1, 3, 3);
		getStatistics(area, mean);
		if(mean>56 && mean<57) {
			if (nr==0) {
				X1 = x;
				Y1 = y;
			} else {
				X2 = x;
				Y2 = y;
			}
			nr++;
		}
	}
	if (nr==2) {
			START_X1 = Array.concat(START_X1, X1);
			START_Y1 = Array.concat(START_Y1, Y1);
			START_X2 = Array.concat(START_X2, X2);
			START_Y2 = Array.concat(START_Y2, Y2);
	}
		
	// FIND end points again END
	trackX1 = newArray(nSlices);
	trackY1 = newArray(nSlices);
	trackX1[0] = START_X1[0];
	trackY1[0] = START_Y1[0];
	trackX2 = newArray(nSlices);
	trackY2 = newArray(nSlices);
	trackX2[0] = START_X2[0];
	trackY2[0] = START_Y2[0];
	x1 = trackX1[0];
	y1 = trackY1[0];
	x2 = trackX2[0];
	y2 = trackY2[0];
	for (i = 2; i <= nSlices; i++) {
		setSlice(i);
		
		// get all end-points on the new slice
		
		endX = newArray(0);
		endY = newArray(0);
		run("Points from Mask");
		getSelectionCoordinates(xpoints, ypoints);
		run("Select None");
		for(p=0; p<xpoints.length; p++) {
			x = xpoints[p];
			y = ypoints[p];	
			makeRectangle(x-1, y-1, 3, 3);
			getStatistics(area, mean);
			if(mean>56 && mean<57) {
				endX = Array.concat(endX, x);
				endY = Array.concat(endY, y);
			}
		}
		// filter out points further away from the middle than the last point that are on this side of the middle.
		setNextPoint(x1, y1, mX, mY, endX, endY, trackX1, trackY1, i-1);
		setNextPoint(x2, y2, mX, mY, endX, endY, trackX2, trackY2, i-1);
		x1 = trackX1[i-1];
		y1 = trackY1[i-1];
		x2 = trackX2[i-1];
		y2 = trackY2[i-1];
	}
	close();
	for (i = 0; i < trackX1.length; i++) {
		trackX1[i] = trackX1[i] + bx;
		trackY1[i] = trackY1[i] + by;
	}
	
	for (i = 0; i < trackX2.length; i++) {
		trackX2[i] = trackX2[i] + bx;
		trackY2[i] = trackY2[i] + by;
	}
	
	selectImage(_CURRENT_IMAGE_ID);
	makeSelection("polyline", trackX1, trackY1);
	Overlay.addSelection;
	makeSelection("polyline", trackX2, trackY2);
	Overlay.addSelection;
	Overlay.show;
}

function setNextPoint(x, y, xM, yM, endX, endY, trackX, trackY, pos) {
	// filter out points further away from the middle than the last point that are on this side of the middle.
		endX1 = newArray(0);
		endY1 = newArray(0);
		distLastToMiddle = sqrt(((xM-x1)*(xM-x1))+((yM-y1)*(yM-y1)));
		for (p = 0; p < endX.length; p++) {
			xC = endX[p];
			yC = endY[p];
			distCurrentToMiddle = sqrt(((xM-xC)*(xM-xC))+((yM-yC)*(yM-yC)));
			distCurrentToLast = sqrt(((x1-xC)*(x1-xC))+((y1-yC)*(y1-yC)));
			if (distCurrentToMiddle<distLastToMiddle && distCurrentToLast<=distCurrentToMiddle) {
				endX1 = Array.concat(endX1, xC);
				endY1 = Array.concat(endY1, yC);
			}
		}
		// No nearer point found, keep the last one
		if(endX1.length==0) {
			print("mark1");
			trackX[pos] = x1;
			trackY[pos] = y1;
			return;
		}
		// If only one found, take that one
		if(endX1.length==1) {
			print("mark2");
			trackX[pos] = endX1[0];
			trackY[pos] = endY1[0];
			return;
		}
		// otherwise find the nearest endPoint to the last endPoint
		print("mark3");
		distances = newArray(endX1.length);
		for (p = 0; p < endX1.length; p++) {
			distances[p] = sqrt(((x1-endX1[p])*(x1-endX1[p]))+((y1-endY1[p])*(y1-endY1[p])));
		}
		ranks = Array.rankPositions(distances);
		indexSmallest = ranks[0];
		trackX[pos] = endX1[indexSmallest];
		trackY[pos] = enyY1[indexSmallest];
}
