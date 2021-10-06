
//************************************************ *****************var global vraibles initilization  ******************************/
var COLUMNS = 3;
var ROWS = 2;
var BORDER_WIDTH = 75;
var IMAGE_SIZE = 512;
var STROKE_WIDTH = 2;
var TMP_IMAGE_PREFIX = "xxxTMP";
var TMP_IMAGE_SIZE = 5000;

var GAMMA = 0.9;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Growth_Cone_Visualizer";

normalizeROI();
exit();

//*******************************************************  Program end ******************************************************// 
//***************************************************************************************************************************//
macro "Visualize Growth Cones Help (f4) Action Tool-C000T4b12?" {
	help();
}

macro "Visualize Growth Cones Help [f4]" {
	help();
}

function help() {
	run('URL...', 'url='+helpURL);
}

macro "draw growth cones (f5) Action Tool-C000T4b12d" {
	drawRois("Growth Cones");
}


macro "draw growth cones (f5) Action Tool Options" {
	Dialog.create("Growth Cones Visualizer Options");
	Dialog.addNumber("columns: ", COLUMNS);
	Dialog.addNumber("rows: ", ROWS);
	Dialog.addNumber("border width: ", BORDER_WIDTH);
	Dialog.addNumber("image size: ", IMAGE_SIZE);
	Dialog.addNumber("stroke width: ", STROKE_WIDTH);
	
	Dialog.show();

	COLUMNS = Dialog.getNumber();
	ROWS = Dialog.getNumber();
	BORDER_WIDTH = Dialog.getNumber();
	IMAGE_SIZE = Dialog.getNumber();
 	STROKE_WIDTH = Dialog.getNumber();
}

macro "draw growth cones [f5]" {
	drawRois("Growth Cones");
}

macro "batch draw growth cones [f6]" {
	batchDrawGrowthCones();
}


macro "batch draw growth cones (f6) Action Tool-C000T4b12b" {
	batchDrawGrowthCones();
}


function batchDrawGrowthCones() { 
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	suffix =".zip";
	Array.print(files);
	imageIDs = newArray();
	zipFiles = filterZIPFiles(files);
	print("\\Clear");
	Array.print(zipFiles);
	print("file = "+dir);

	setBatchMode(true);
	/* zip files exist or no **/
	for (i = 0; i<zipFiles.length; i++){
		if(endsWith(zipFiles[i], suffix)){
			roiPath = dir + zipFiles[i];
			roiManager("reset");
			roiManager("Open", roiPath);
			roiFileName = File.getName(roiPath);
			experimentName = cleanRoiName(roiFileName);
			title = TMP_IMAGE_PREFIX + "_" + experimentName;
			imageIDs[i]= drawRois(title);
			selectImage(imageIDs[i]); 
			run("RGB Color", "");
		}
		else {
			exit("Error Message : No File Zip");
		}
	}
	numberOfImages = imageIDs.length;
	
	/********************   run("Images RGB To Stack" and Flatten) and make a montage **********/
	print("images_ID");
	run("Images to Stack", "name=Stack title=["+TMP_IMAGE_PREFIX+"] use");
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
	    label = Property.getSliceLabel();
	    label = replace(label, TMP_IMAGE_PREFIX +"_", "");
	    Property.setSliceLabel(label);
	}
	stackID = getImageID();
	run("Flatten", "stack");
	run("Gamma...", "value="+GAMMA+" stack");
	
	montageParameters = "columns=" + COLUMNS + " rows=" + ROWS + " scale=1 label";
	run("Make Montage...", montageParameters);
	run("Invert");
	selectImage(stackID);
	close();
	setBatchMode("exit and display");
}

//************************  Look for zip files **********************/
function filterZIPFiles(files){
	// suffix =".zip";
	zipFiles = newArray();
	for (i = 0; i < files.length; i++){
		if(endsWith(files[i], suffix)){
			zipFiles[i] = files[i];
		}
	}
	return zipFiles;
}

function normalizeROI() {
		width = getWidth();
		height = getHeight();
		baseY = height-BORDER_WIDTH;
		centerX = width/2;
		centerY = height/2;

		getSelectionCoordinates(xpoints, ypoints);
		makeLine(xpoints[0], ypoints[0], xpoints[1], ypoints[1]);
		angle = getValue("Angle");
		run("Select None");

		makeSelection("polygon", xpoints, ypoints);

		x = getValue("X");
		y = getValue("Y");
		bx = getValue("BX");
		by = getValue("BY");
		bHeight = getValue("Height");
		deltaX = x - bx;
		deltaY = y - by;
		
		Roi.move(centerX-deltaX, centerY-deltaY);	

		run("Rotate...", "angle="+angle);
		
		getSelectionCoordinates(xpoints, ypoints);
		y = getValue("Y");
		
		/******* ROI PI Rotation      *******************************/
		if(ypoints[0]<y){
			run("Rotate...", " angle=180");	
		}
		  
		/******* Fix and Compute Translation Coord. ******************/
		getSelectionCoordinates(xpoints, ypoints);
		x = getValue("X");
		y = getValue("Y");
		bx = getValue("BX");
		by = getValue("BY");
		bHeight = getValue("Height");
		x1 = minOf(xpoints[0],  xpoints[1]);
		x2 = maxOf(xpoints[0],  xpoints[1]);
		
		y1 = minOf(ypoints[0],  ypoints[1]);
		y2 = maxOf(ypoints[0],  ypoints[1]);
		
		deltaX = x1+(x2-x1)/2-bx;
		deltaY = abs(y2 - by);
		// deltaY = y1+(y2-y1)/2-by;
				
		// ******* Move the Selected ROI ********************************/
		Roi.move(centerX-deltaX, baseY-deltaY);	
		drawLine(0, baseY, width, baseY);
}

/************************  drawRois() **********************/
function drawRois(title) {
	newImage(title, "8-bit black", TMP_IMAGE_SIZE, TMP_IMAGE_SIZE, 1);
	count = roiManager("count");

	Overlay.remove;
	
	run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
	
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		color = getColor(i, count);
		normalizeROI();
		/******* Display The Indicated ROI_Lines   ******************/
		Roi.setStrokeColor(color,color,color);
		Roi.setStrokeWidth(STROKE_WIDTH);
		Overlay.addSelection;
	}
	run("Select None");
	imageID = getImageID();
	x = TMP_IMAGE_SIZE / 2 -IMAGE_SIZE / 2;
	y = TMP_IMAGE_SIZE - IMAGE_SIZE;
	width = IMAGE_SIZE;
	height = IMAGE_SIZE;
	makeRectangle(x, y, width, height);
	run("Crop");
	run("Select None");
	return imageID;
}

function cleanRoiName(roiName) { 
	name = replace(roiName, "ROI", "");
	name = replace(name, ".zip", "");
	name = String.trim(name);
	return name;
}


function getColor(index, count) {
	if (count<256){
			Color_Pas_Ech = 256/(count);
		}
		else {
			print("Error" + count);
			exit("Error roi number is not inf to count");
		} 
		color = (index*Color_Pas_Ech) +  Color_Pas_Ech;
		return color;
}

