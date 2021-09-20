count = roiManager("count");
newImage("growth cones", "8-bit white", 256, 256, 1);
width = getWidth();
height = getHeight();
centerY = height/2;
centerX = width/2;
Overlay.remove;
run("Set Measurements...", "area mean min centroid perimeter bounding fit shape redirect=None decimal=3");
colors = newArray("red", "green", "blue", "cyan", "magenta", "yellow", "black");
colorIndex = 0;
for (i = 0; i < count; i++) {
	roiManager("select", i);
	angle = getValue("Angle");
	x = getValue("X");
	y = getValue("Y");
	bx = getValue("BX");
	by = getValue("BY");
	deltaX = x - bx;
	deltaY = y - by;
	run("Rotate...", "  angle="+angle);
	run("Rotate...", "  angle=-90");
	Roi.move(centerX-deltaX, centerY-deltaY);	
	color = colors[colorIndex];
	colorIndex = (colorIndex + 1) % 7;
	Roi.setStrokeColor(color);
	Roi.setStrokeWidth(2);
	Overlay.addSelection;
}
run("Select None");