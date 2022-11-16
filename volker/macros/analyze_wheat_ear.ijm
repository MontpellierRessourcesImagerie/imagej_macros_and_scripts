ENLARGE = 10;

Overlay.remove;
title = getTitle();
inputImageID = getImageID();
run("Duplicate...", " ");
createMask();
run("Create Selection");
Roi.getCoordinates(xpoints, ypoints);
Roi.getBounds(bx, by, bwidth, bheight);
angle = getValue("Angle");
if (angle>90) {
    angle = -(180 - angle);
}
run("Select None");
run("Rotate... ", "angle="+angle+" grid=0 interpolation=Bilinear");
setAutoThreshold("Default dark");
run("Convert to Mask");
run("smooth mask", "method=Scaling scaling=16");
run("Create Selection");
getBoundingRect(x, y, width, height);
makeRectangle(x + ENLARGE, y-5, width - 2 * ENLARGE, height+10);
rename(title + " width");
uncroppedImage = getImageID();
run("width profile voronoi", " ");
rename(title + " length");
Overlay.activateSelection(0);
run("Measure");
run("Select All");
run("Copy");
selectImage(uncroppedImage);
run("Clear");
run("Clear Outside");
run("Paste");
run("Rotate... ", "angle="+(-angle)+" grid=0 interpolation=Bilinear");
Roi.getBounds(x, y, width2, height2);
run("Select None");
run("Translate...", "x="+(bx-x + ENLARGE)+(width2 - width)+" y="+(by-y + ENLARGE)+(height2-height)+" interpolation=None");
run("Fire");
run("RGB Color");
uncroppedTitle = getTitle();
selectImage(inputImageID);
run("Add Image...", "image=["+uncroppedTitle+"] x=0 y=0 opacity=100 zero");
makeSelection("freehand", xpoints, ypoints);
Overlay.addSelection("green", 4);
run("Select None");
close("\\Others");

function createMask() {
    run("8-bit");
    resetThreshold();
    setAutoThreshold("Default ");
    run("Convert to Mask");
    run("Morphological Filters", "operation=Opening element=Disk radius=18");
    run("Fill Holes");
    run("Morphological Filters", "operation=Closing element=Disk radius=24");
    run("Fill Holes");
}
