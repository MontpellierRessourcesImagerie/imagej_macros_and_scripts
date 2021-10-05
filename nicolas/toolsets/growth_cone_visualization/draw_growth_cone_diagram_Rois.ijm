macro "growth coneof the macro" {
       draw_roi_growth_cone();
}




function draw_roi_growth_cone() { 
// man function description

dir = getDir("Please select the input folder!");
files = getFileList(dir);
suffix =".zip";
Array.print(files);
images_Id = newArray();
run("Close All");
Files_With_Zip = filterZIPFiles(files);
print("\\Clear");
Array.print(Files_With_Zip);
print("file = "+dir);

for (i = 0; i<Files_With_Zip.length; i++){
	if(endsWith(Files_With_Zip[i], suffix)){
		Roi_Name = dir + Files_With_Zip[i];
		print("file With Path = " + Roi_Name);
		images_Id[i]= drawRois(Roi_Name,i);
		selectImage(images_Id[i]); 
		run("RGB Color", "");
	}
	else {
		exit("Error Message : No File Zip");
	}
}

/********************   run("Images RGB To Stack" and Flatten) and make a montage **********/
print("images_ID");
run("Images to Stack", "name=Stack title=[growth cones] use keep");
//run("Images to Stack", "");
run("Flatten", "");

M_Number_Cols = Files_With_Zip.length/2;
M_Number_Rows = Files_With_Zip.length - M_Number_Cols;
M_Param_Input = "columns=" + M_Number_Cols + " rows=" + M_Number_Rows + " scale=0.5 label";
run("Gamma...");
run("Make Montage...", M_Param_Input);
run("Invert");


//*******************************************************  Program end ******************************************************// 
//***************************************************************************************************************************//


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

/************************  drawRois() **********************/
function drawRois(ROI_File_Name,FileIndex) {
	roiManager("reset");
	roiManager("Open", ROI_File_Name);
	count = roiManager("count");
	Image_Name = "growth cones "+FileIndex;
	newImage(Image_Name, "8-bit black", 512, 512, 1);
	
	width = getWidth();
	height = getHeight();
	centerY = height/2;
	centerX = width/2;
	Overlay.remove;
	
	run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
	
	colorIndex = 0;
	color=0; colors=0;
	x0=0; y0=0;
	
	for (i = 0; i < count; i++) {
		roiManager("select", i);
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
		Roi.move(centerX-deltaX, centerY-deltaY);	
		
		// colors = colors[colorIndex];
		// colorIndex = (colorIndex + 1) % 10;
	
		if (count<256){
			Color_Pas_Ech = 256/(count);
		}
		else {
			print("Error" + count);
			exit("Error roi number is not inf to count");
		} 
		
	    // ******* Move the Selected ROI ********************************/
		color=0;
		color = (i*Color_Pas_Ech) +  Color_Pas_Ech;
		
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
		y2 = maxOf(ypoints[0],  xpoints[1]);
		
		
		deltaX = x1+(x2-x1)/2-bx;
		Array.getStatistics(ypoints, min, max, mean, std);
		deltaY = min+(max-min)/2-by;

		/******* Move the Selected ROI ********************************/
		Roi.move(centerX-deltaX, centerY-deltaY);	
		
		Overlay.addSelection;
				
	}
	run("Select None");
	im_ID = getImageID();
	return im_ID;
}
}

draw_roi_growth_cone();

