var MIN_SIZE=8000;
var INTERPOLATION_LENGTH=150;
inputImageID = getImageID();
box = Roi.getCoordinates(xpoints, ypoints);
run("Duplicate...", " ");
zoneImageID = getImageID();
run("Threshold...");
waitForUser("Set a threshold to select the object(s) of interest");
run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity add");
count = roiManager("count");
for (r = 0; r < count; r++) {
    roiManager("select", r);
    run("Interpolate", "interval="+INTERPOLATION_LENGTH+" smooth");
    roiManager("update");
}
roiManager("deselect");

count = roiManager("count");
for (r = 0; r < count; r++) {
    roiManager("select", r);
    run("Interpolate", "interval="+INTERPOLATION_LENGTH+" smooth");
    roiManager("update");
}



