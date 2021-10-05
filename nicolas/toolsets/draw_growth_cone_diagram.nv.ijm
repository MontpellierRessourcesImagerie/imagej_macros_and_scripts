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
		images_Id[i] = drawRois(Roi_Name,i);
	}
	else {
		exit("Error Message : No File Zip");
	}
}

/********************   run("Images To Stack") anad make a montage **********/

print("images_ID");
Array.print(images_Id);
run("RGB Color", "");

//runImagesToStack.run(images_Id);
//flattenStack();

// run("Make Montage...", "columns=2 rows=2 scale=0.50 label use");


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
	// newImage(Image_Name, "8-bit white", 512, 512, 1);
	newImage(Image_Name, "8-bit black", 512, 512, 1);
	
	width = getWidth();
	height = getHeight();
	centerY = height/2;
	centerX = width/2;
	Overlay.remove;
	run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
	// colors = newArray("red", "green", "blue", "cyan", "magenta", "yellow", "orange","brown","purple","black");
	// colors = newArray(0xFF0000,0x00FFFF,0x0000FF,0x0000A0,0xAdD8E6,0x800080,0xFFFF00,0x00FF00,0xFF00FF,0xC0C0C0,0x808080,0x000000,0xFFA500,0xA52A2A,0x800000,0x008000,
	// 0x008000,0x808000)
	
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
		deltaX = x1+(x2-x1)/2-bx;
		deltaY = bHeight;
	
		/******* Move the Selected ROI ********************************/
		Roi.move(centerX-deltaX, centerY-deltaY);	
		
		Overlay.addSelection;
				
	}

	run("Select None");
	im_ID = getImageID();
	return im_ID;
		
}

