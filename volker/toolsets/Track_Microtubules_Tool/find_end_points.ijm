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

run("Point Tool...", "type=Circle color=Magenta size=Medium label");
makeSelection("point", START_X1, START_Y1);
Overlay.addSelection("magenta");
makeSelection("point", START_X2, START_Y2);
Overlay.addSelection("cyan");
Overlay.show