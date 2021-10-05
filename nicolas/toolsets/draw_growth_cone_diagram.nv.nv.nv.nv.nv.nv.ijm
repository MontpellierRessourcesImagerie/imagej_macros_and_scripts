count = roiManager("count");
newImage("growth cones", "8-bit white", 512, 512, 1);
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
color=0;
colors=0;
x0=0;
y0=0;

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
		// Color_Pas_Ech = 256/count;
		Color_Pas_Ech = 256/(count+128);
		
	}
	else {
		print("Error" + count);
		close();
	} 
	
    /******* Compute R,G,B Components ***************************/
    /******* Space Sampling Method    ***************************/
    pas = count-i;
    if (count <= 256){
		alpha = (i+1)*pas; 
		beta  = (i)*pas;  
		gamma = (i-1)*pas;
	}

	/******* Compute Color Norm and Display it   ****************/
	color=0; 
	// color = Math.log(Math.sqrt( Math.pow(alpha,2) + Math.pow(beta,2) + Math.pow(gamma,2) )*256);
	//*** Color according a gaussian law */
	gamma = 2;
	centre = count/2;
	x= (i-centre)/10;
	amplitude = 1/(Math.sqrt(2)*10);
	// color = amplitude * Math.exp(-1*Math.pow(x,2)/2 )*65536;
	// color = pow(i/255, 1/gamma)*255;
	
	// ******* Move the Selected ROI ********************************/
	color = (i*Color_Pas_Ech) +  Color_Pas_Ech;
	print("color "+ color);
	// setColor(color,0,0);
	// Roi.setStrokeColor(color);
	
	
	/******* Display The Indicated ROI_Lines   ******************/
	// setColor(0, color, 0);
	Roi.setStrokeColor(Math.pow(color,2));
	Roi.setStrokeWidth(1);

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

