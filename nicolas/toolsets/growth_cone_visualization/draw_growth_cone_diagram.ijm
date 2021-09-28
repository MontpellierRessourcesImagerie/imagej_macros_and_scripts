count = roiManager("count");
newImage("growth cones", "8-bit white", 512, 512, 1);
width = getWidth();
height = getHeight();
centerY = height/2;
centerX = width/2;
Overlay.remove;
run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
colors = newArray("red", "green", "blue", "cyan", "magenta", "yellow", "orange","brown","purple","black");
colorIndex = 0;
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
	color = colors[colorIndex];
	colorIndex = (colorIndex + 1) % 10;
	Roi.setStrokeColor(color);
	Roi.setStrokeWidth(2);
	
	if(ypoints[0]<y){
		print(i, ypoints[0], y);
		run("Rotate...", " angle=180");	
	}  

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
	
	Roi.move(centerX-deltaX, centerY-deltaY);	
	
	
	Overlay.addSelection;
	
}
run("Select None");