
_NUCLEI_CHANNEL = 3;
_MIN_N_PIXELS   = 11000;

// ---------------------------------------------------------

t = getTitle();
new_title = "nuclei-" + t;

setOption("ExpandableArrays", true);
buffer = newArray();

getVoxelSize(vwidth, vheight, vdepth, unit);
run("Duplicate...", "duplicate channels=" + _NUCLEI_CHANNEL + "-" + _NUCLEI_CHANNEL);
buffer[0] = getImageID();

run("Z Project...", "projection=[Max Intensity]");
run("Gaussian Blur...", "sigma=3");
setAutoThreshold("Huang dark no-reset");
setOption("BlackBackground", true);
run("Convert to Mask");
buffer[1] = getImageID();

run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
buffer[2] = getImageID();

run("Label Size Filtering", "operation=Greater_Than size=" + _MIN_N_PIXELS);
buffer[3] = getImageID();

run("Fill Holes (Binary/Gray)");
buffer[4] = getImageID();

run("Dilate Labels", "radius=2");
rename(new_title);
run("Remap Labels");
setVoxelSize(vwidth, vheight, vdepth, unit);

for (i = 0 ; i < lengthOf(buffer) ; i++) {
	selectImage(buffer[i]);
	close();
}

IJ.log("DONE: " + new_title);
