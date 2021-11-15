/***
 * 
 * MRI Growth Cone Visualization
 * 
 * Make a montage in which each image contains the overlay of all rois in a zip-file. 
 * The orientation is normalized according to the line formed by the first two points of 
 * the selection.
 * 
 * (c) 2021, INSERM
 * 
 * written by Nicolas Nafati and Volker Baecker 
 * at Montpellier Ressources Imagerie, 
 * Biocampus Montpellier, INSERM, CNRS, 
 * University of Montpellier (www.mri.cnrs.fr)
 * 
**/

//************************************************ *****************global variables initilization  ******************************/
var COLUMNS = 2;
var ROWS = 3;
var BORDER_WIDTH = 30;
var IMAGE_WIDTH = 300;
var IMAGE_HEIGHT = 290;
var STROKE_WIDTH = 1;
var MONTAGE_BORDER = 0;
var TMP_IMAGE_PREFIX = "xxxTMP";
var TMP_IMAGE_SIZE = 5000;
var DRAW_LINE = true;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Growth_Cone_Visualizer";
var COLOR_SCHEMES = newArray("default", "linear-distributed", "12 colors","RGB colors");
var COLOR_SCHEME = "RGB colors";
var TWELVE_COLORS = newArray("black", "blue", "cyan", "darkGray", "gray", "green", "lightGray", "magenta", "orange", "pink", "red", "yellow");
var LOOKUPTABLE_LIST_PARAM = getList("LUTs");
// var LOOKUPTABLE="glasbey";
// var LOOKUPTABLE="glasbey";
var LOOKUPTABLE="glasbey inverted";
var STRETCH_LUT = false;
var STRETCH_LUT_Linear = false;


batchDrawGrowthCones();
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

function Choice= init_LookUpTable() {
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
	Dialog.addNumber("image width: ", IMAGE_WIDTH);
	Dialog.addNumber("image height: ", IMAGE_HEIGHT);
	Dialog.addNumber("stroke width: ", STROKE_WIDTH);
	Dialog.addNumber("montage border width: ", MONTAGE_BORDER);
	Dialog.addCheckbox("draw base-line", DRAW_LINE);
	Dialog.addChoice("color scheme: ", COLOR_SCHEMES, COLOR_SCHEME);
	Dialog.addChoice("LookUpTable: ", LOOKUPTABLE_LIST_PARAM, LOOKUPTABLE);
	Dialog.addCheckbox("stretch colors", STRETCH_LUT);
	Dialog.addCheckbox("stretch in unLinear Mode",STRETCH_LUT_Linear);
	
	Dialog.show();

	COLUMNS = Dialog.getNumber();
	ROWS = Dialog.getNumber();
	BORDER_WIDTH = Dialog.getNumber();
	IMAGE_WIDTH = Dialog.getNumber();
	IMAGE_HEIGHT = Dialog.getNumber();
 	STROKE_WIDTH = Dialog.getNumber();
 	MONTAGE_BORDER = Dialog.getNumber();
 	DRAW_LINE = Dialog.getCheckbox();
 	COLOR_SCHEME = Dialog.getChoice();
 	LOOKUPTABLE = Dialog.getChoice(); 
 	STRETCH_LUT = Dialog.getCheckbox();
 	STRETCH_LUT_Linear = Dialog.getCheckbox();
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
	setBatchMode(true);
	createImagesFromRoiZipFiles(dir);
	run("Images to Stack", "name=Stack title=["+TMP_IMAGE_PREFIX+"] use");
	makeMontage();
	setBatchMode("exit and display");
}

function createImagesFromRoiZipFiles(dir) {
	files = getFileList(dir);
	zipFiles = filterZIPFiles(files);
	print("\\Clear");
	if (zipFiles.length < 1) {
		exit("Error Message : No File Zip");
	}
	for (i = 0; i<zipFiles.length; i++){
		roiPath = dir + zipFiles[i];
		roiManager("reset");
		roiManager("Open", roiPath);
		roiFileName = File.getName(roiPath);
		experimentName = cleanRoiName(roiFileName);
		title = TMP_IMAGE_PREFIX + "_" + experimentName;
		drawRois(title);
	}
}

function makeMontage() {
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
	    label = Property.getSliceLabel();
	    label = replace(label, TMP_IMAGE_PREFIX +"_", "");
	    Property.setSliceLabel(label);
	}
	stackID = getImageID();
	montageParameters = "columns=" + COLUMNS + " rows=" + ROWS + " scale=1 border="+MONTAGE_BORDER+" label";
	run("Make Montage...", montageParameters);
	selectImage(stackID);
	close();
}

//************************  Look for zip files **********************/
function filterZIPFiles(files){
	suffix =".zip";
	zipFiles = newArray();
	for (i = 0; i < files.length; i++){
		if(endsWith(files[i], suffix)){
			zipFiles = Array.concat(zipFiles, files[i]);
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
		normalizeRotation(centerX, centerY);
		normalizePosition(centerX, baseY);
		if (DRAW_LINE) drawLine(0, baseY, width, baseY);
}


function normalizePosition(centerX, baseY) {
		/******* Compute Translation Coord. ******************/
		getSelectionCoordinates(xpoints, ypoints);
		x = getValue("X");
		y = getValue("Y");
		bx = getValue("BX");
		by = getValue("BY");
		bHeight = getValue("Height");
		x1 = minOf(xpoints[0],  xpoints[1]);
		x2 = maxOf(xpoints[0],  xpoints[1]);
		y2 = maxOf(ypoints[0],  ypoints[1]);
		deltaX = x1+(x2-x1)/2-bx;
		deltaY = abs(y2 - by);
		// ******* Move the ROI ********************************/
		Roi.move(centerX-deltaX, baseY-deltaY);	
}

function normalizeRotation(centerX, centerY) {
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
		/******* Normalize oriantation, so that the base-line is at the bottom side  *******************************/
		if(ypoints[0]<y){
			run("Rotate...", " angle=180");	
		}
}

function drawRois(title) {
	newImage(title, "8-bit white", TMP_IMAGE_SIZE, TMP_IMAGE_SIZE, 1);
    imageId = getImageID();
    count = roiManager("count");
    Image_Vect_Rs = newArray(count);
    Image_Vect_Gs = newArray(count);
    Image_Vect_Bs = newArray(count);
    Array_Count = newArray(count);
    
    Overlay.remove;
	run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		color = getColor(i, count);
		normalizeROI();
		if (COLOR_SCHEME=="linear-distributed") {
			Roi.setStrokeColor(color[0],color[1],color[2]);
		}
		else if (COLOR_SCHEME=="12 colors") {
			Roi.setStrokeColor(color);
		} 
		else if (COLOR_SCHEME=="RGB colors"){
			Roi.setStrokeColor(color[0],color[1],color[2]);
		} 
		else if (STRETCH_LU){ 
			Roi.setStrokeColor(color[0],color[1],color[2]);
		}
		Roi.setStrokeWidth(STROKE_WIDTH);
		Overlay.addSelection;
		Image_Vect_Rs[i]= color[0];
		Image_Vect_Gs[i]= color[1];
		Image_Vect_Bs[i]= color[2];
		Array_Count[i] = i;
	}
	Image_Vect_Rs_Fourier = Array.fourier(Image_Vect_Rs, "Hamming");
	Image_Vect_Gs_Fourier = Array.fourier(Image_Vect_Gs, "Hamming");
	Image_Vect_Bs_Fourier = Array.fourier(Image_Vect_Bs, "Hamming");
	// image_ID_Fourier = getImageID();
	// selectImage(image_ID_Fourier);
	// newImage("RGB_Sig", "8 bit", 256, 1, 1);
	// ROI_ToSpectrum(Image_Vect_Rs_Fourier,Image_Vect_Gs_Fourier,Image_Vect_Bs_Fourier,Array_Count);
	// run("Select None");
	// run("Make Montage...", "columns=2 rows=3 scale=1 font=14");
	// run("Images to Stack", "name=RGB_Sig title=["+TMP_IMAGE_PREFIX+"] use");
	// run("Make Montage");
	// run("Make Montage...", "columns=2 rows=3 scale=1 font=14");
	// run("Make Montage...", "columns=2 rows=3 scale=1");
	// close();
	// Plot.create("GSeg and index exp", "index", "GSig", Image_Vect_Gs);
	// Plot.create("BSeg and index exp", "index", "Bsig", Image_Vect_Bs);

	cropImage();
	flattenInsitu();
}

function ROI_ToSpectrum(Roi_Rs,Roi_Gs,Roi_Bs,Array_Count) {
	// newImage("RGB_Sig", "8 bit", 256, 256, 1);
	oldImageID = getImageID();
	Plot.create("RGB Sig", "index", "RGB_Sig",Roi_Rs);
	selectWindow("RGB Sig");
	Plot.setColor("red");
	Plot.add("box", Array_Count, Roi_Gs);
	Plot.add("line", Array_Count, Roi_Gs);
	selectWindow("RGB Sig");
	Plot.setColor("green");
	Plot.add("Circle", Array_Count, Roi_Bs);
	Plot.add("line", Array_Count, Roi_Bs);
	Plot.setColor("blue");
	Plot.show;
	run("Images to Stack", "  title=RGB use");
	// run("Images to Stack", "name=[RGB Sig] title=RGB use");
	// run("Images to Stack", "title= RGB Sig fill=white use");
	// run("Images to Stack", "name=RGB-=_Sig title=RGB-=_Sig fill=white use");
	// Plot.show;
	// selectImage(oldImageID);
	// close();
	// run("Select None");
}

function cropImage() {
	x = TMP_IMAGE_SIZE / 2 -IMAGE_WIDTH / 2;
	y = TMP_IMAGE_SIZE - IMAGE_HEIGHT;
	width = IMAGE_WIDTH;
	height = IMAGE_HEIGHT;
	makeRectangle(x, y, width, height);
	run("Crop");
	run("Select None");
}

function cleanRoiName(roiName) { 
	name = replace(roiName, "ROI", "");
	name = replace(name, ".zip", "");
	name = String.trim(name);
	return name;
}

function getColor(index, count) {
	color = 0;
	if (COLOR_SCHEME=="default") {
		color = getColorDefault(index, count);
	}
	if (COLOR_SCHEME=="linear-distributed") {
		color = getColorLinearDistributed(index, count);
	}	
	if (COLOR_SCHEME=="12 colors") {
		color = getColor12Colors(index, count);
	}
	if (COLOR_SCHEME=="RGB colors") {
		color = getColorRGB(index,count);
	}
	return color;
}

function getColor12Colors(index, count) {
	len = TWELVE_COLORS.length;
	i = index % len;
	return TWELVE_COLORS[i];
}

function getColorDefault(index, count) {
	stepWidth = 256 / count;
	value = (index*stepWidth) +  stepWidth;	
	color = newArray(value, value, value);
	return color;
}

function getColorRGB(index, count) {
	/** Init Var Matrix **/
	reds = newArray(256); 
	greens = newArray(256); 
	blues = newArray(256);
	/** Look for values of Look Up Table **/
	newImage("tmp_lut", "8-bit", 256, 1, 1);
	run(LOOKUPTABLE);
	getLut(reds, greens, blues);
	close();
	mappedIndex = index;
	stepWidth = round(255/count);
	if (STRETCH_LUT && STRETCH_LUT_Linear) {
		mappedIndex = (index * stepWidth)%255;
	}else if (STRETCH_LUT && (!STRETCH_LUT_Linear)){
		mappedIndex = (Math.pow(index * stepWidth,2))%255;
	}
	print(mappedIndex);
	/** exporte results **/
	color1 = reds[mappedIndex]; 
	color2 = greens[mappedIndex]; 
	color3 = blues[mappedIndex];
	color = newArray(color1,color2,color3);
	return color;
}

function getColorLinearDistributed(index, count) {
	stepWidth = 128/count;
	offset = 0;
	value = offset + (index+1)*stepWidth;
	color = newArray(value, value, value);
	return color;
}

function flattenInsitu() {
	oldImageID = getImageID();
	title = getTitle();
	run("8-bit");
	run("Invert LUT");
	run("Invert LUT");
	run("Flatten", "stack");
	selectImage(oldImageID);
	close();
	rename(title);
	run("Select None");
}

