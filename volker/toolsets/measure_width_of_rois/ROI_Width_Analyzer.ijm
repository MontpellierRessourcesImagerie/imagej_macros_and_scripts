var MIN_SIZE=8000;
var INTERPOLATION_LENGTH=150;
var _PROEMINENCE = 0.5;

inputImageID = getImageID();

if (selectionType() == -1) {
    run("Select All");
}

box = Roi.getCoordinates(xpoints, ypoints);
run("Duplicate...", " ");
workingImage = getImageID();
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

for (r = 0; r < count; r++) {
    roiManager("select", r);
    run("Create Mask");
    run("Exact Euclidean Distance Transform (3D)");
    close("Mask");
    run("Find Maxima...", "prominence="+_PROEMINENCE+" output=[Point Selection]");
}


