var BORDER_WIDTH = 75;
var GAMMA = 0.5;
var IMAGE_SIZE = 512;

numberOfImages = batchDrawGrowthCones();
/********************   run("Images RGB To Stack" and Flatten) and make a montage **********/
print("images_ID");
run("Images to Stack", "name=Stack title=[growth cones] use keep");
run("Flatten", "stack");

M_Number_Cols = numberOfImages/2;
M_Number_Rows = numberOfImages - M_Number_Cols;
M_Param_Input = "columns=" + M_Number_Cols + " rows=" + M_Number_Rows + " scale=0.5 label";
run("Gamma...", "value="+GAMMA+" stack");
run("Make Montage...", M_Param_Input);
run("Invert");
close("\\Others");
//*******************************************************  Program end ******************************************************// 
//***************************************************************************************************************************//

function batchDrawGrowthCones() { 
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	suffix =".zip";
	Array.print(files);
	images_Id = newArray();
	run("Close All");
	zipFiles = filterZIPFiles(files);
	print("\\Clear");
	Array.print(zipFiles);
	print("file = "+dir);
	
	for (i = 0; i<zipFiles.length; i++){
		if(endsWith(zipFiles[i], suffix)){
			Roi_Name = dir + zipFiles[i];
			print("file With Path = " + Roi_Name);
			images_Id[i]= drawRois(Roi_Name,i);
			selectImage(images_Id[i]); 
			run("RGB Color", "");
		}
		else {
			exit("Error Message : No File Zip");
		}
	}
	numberOfImages = zipFiles.length;
	return numberOfImages;
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

function drawROI(color) {
		getSelectionCoordinates(xpoints, ypoints);
		makeLine(xpoints[0], ypoints[0], xpoints[1], ypoints[1]);
		angle = getValue("Angle");
		run("Select None");
		roiManager("select", i);
		run("Rotate...", " rotate angle="+angle);

		getSelectionCoordinates(xpoints, ypoints);
		x = getValue("X");
		y = getValue("Y");
		bx = getValue("BX");
		by = getValue("BY");
		bHeight = getValue("Height");
		deltaX = x - bx;
		deltaY = y - by;
		Roi.move(centerX-deltaX, baseY-deltaY);	
		
		/******* Display The Indicated ROI_Lines   ******************/
		print("color = "+color);
		Roi.setStrokeColor(color,color,color);
		Roi.setStrokeWidth(2);
	
		/******* ROI PI Rotation      *******************************/
		if(ypoints[0]<y){
			print(i, ypoints[0], y);
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
		deltaY = bHeight;
				
		/******* Move the Selected ROI ********************************/
		Roi.move(centerX-deltaX, baseY-deltaY);	
		
		Overlay.addSelection;
}

/************************  drawRois() **********************/
function drawRois(ROI_File_Name,FileIndex) {
	roiManager("reset");
	roiManager("Open", ROI_File_Name);
	print(ROI_File_Name);
	count = roiManager("count");
	Image_Name = "growth cones "+FileIndex;
	newImage(Image_Name, "8-bit black", IMAGE_SIZE, IMAGE_SIZE, 1);
	width = getWidth();
	height = getHeight();
	baseY = height-BORDER_WIDTH;
	centerX = width/2;
	Overlay.remove;
	
	run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
	
	colorIndex = 0;
	color=0; colors=0;
	x0=0; y0=0;
	
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		if (count<256){
			Color_Pas_Ech = 256/(count);
		}
		else {
			print("Error" + count);
			exit("Error roi number is not inf to count");
		} 
		color=0;
		color = (i*Color_Pas_Ech) +  Color_Pas_Ech;
		drawROI(color);
	}
	run("Select None");
	im_ID = getImageID();
	return im_ID;
}



