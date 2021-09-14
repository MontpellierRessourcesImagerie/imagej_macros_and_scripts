count = roiManager("count");
for (i = 0; i < count; i++) {
	roiManager("select", i);
	getSelectionCoordinates(xpoints, ypoints);
    makeSelection("polygon", xpoints, ypoints);
    roiManager("update");
}
run("Select None");