/*
 * Voronoi based width profile
 * 
 * Input: a binary mask that either
 *          a) touches the borders of the image in two places,
 *          so that the contour is separated into two parts
 *          b) does not touch the borders of the image, but has 
 *          two selections in the overlay that "cut the caps",
 *          so that the contour will be separated into two parts
 *          
 * Output: The voronoi line between the two contour segments 
 *         The measured width profile of the object
 *         
 * (c) 2022 INSERM
 * written by Volker Baecker at Montpellier Ressources Imagerie
 */

var TABLE_TITLE = "width measurements";
var SHOW_PROFILE_PLOT = true;
var OVERLAY = true;

run("Options...", "iterations=1 count=1 black edm=32-bit do=Nothing");
title = getTitle();
getPixelSize(unit, pixelWidth, pixelHeight);
nrOfRoisInOverlay = Overlay.size;
run("Duplicate...", " ");
inputMaskID = getImageID();
inputMaskTitle = getTitle();
if (nrOfRoisInOverlay > 0) Overlay.copy;
run("Morphological Filters", "operation=Gradient element=Disk radius=1");
gradientID = getImageID();
if (nrOfRoisInOverlay > 0) Overlay.paste;
run("Connected Components Labeling", "connectivity=8 type=[8 bits]");
nrOfLabels = getValue("Max");
close();
if (nrOfLabels != 2 && nrOfRoisInOverlay != 2) {
    print("To separate the contour into two parts, the mask must either touch the image borders in two places or there must be two selections 'cutting the caps' in the overlay"); 
    selectWindow("Log");
    exit;    
}

capsCut = false;

if (nrOfLabels != 2) {
    removeCaps();
    run("Connected Components Labeling", "connectivity=8 type=[8 bits]");
    nrOfLabels = getValue("Max");
    close();
    if (nrOfLabels != 2) {
        print("Couldn't separate the contour into two parts");
        selectWindow("Log");
        exit;
    }
    capsCut = true;
    
}

//run("Skeletonize (2D/3D)");
run("Voronoi");
voronoiTitle = getTitle();
voronoiID = getImageID();
selectImage(inputMaskID);
run("Create Selection");
selectImage(voronoiID);
run("Restore Selection");
run("Clear Outside");
run("Select None");

if (capsCut) {
    Overlay.paste
    removeCaps();
}

run("Multiply...", "value=2.000");
run("Duplicate...", " ");
setThreshold(2.0000, 1000000000000000000000000000000.0000);
setOption("BlackBackground", true);
run("Convert to Mask");
run("Skeletonize (2D/3D)");
run("line mask to line roi", "interpolation=1");
Overlay.activateSelection(0);
Roi.getCoordinates(xpoints, ypoints);
run("Select None");
close();
run("Morphological Filters", "operation=Dilation element=Square radius=4");
makeSelection("polyline", xpoints, ypoints);
run("Interpolate", "interval=1 smooth adjust");
resetMinAndMax();
min = getValue("Min");
max = getValue("Max");
setMinAndMax(min, max);
run("Fire");
Overlay.addSelection;
resultImageID = getImageID();
run("Calibrate...", "function=None unit="+unit);
report();
if (SHOW_PROFILE_PLOT) run("Plot Profile");
if (OVERLAY) createOverlay(resultImageID, inputMaskID, title, capsCut);
selectImage(inputMaskID);
close();
selectImage(gradientID);
close();
selectImage(voronoiID);
close();
selectImage(resultImageID);
Overlay.activateSelection(Overlay.size-1);

function createOverlay(resultImageID, inputMaskID, title, capsCut) {
   selectImage(resultImageID);
   resultTitle = getTitle();
   selectImage(title);
   run("Add Image...", "image="+resultTitle+" x=0 y=0 opacity=100 zero");
   run("Invert");
   run("Flatten");  
   rgbResultImageID = getImageID();
   selectImage(title);
   if (capsCut) 
       Overlay.removeSelection(2);
   else 
       Overlay.removeSelection(0);
   run("Invert");
   selectImage(resultImageID);
   run("Calibration Bar...", "location=[Separate Image] fill=Black label=White number=9 decimal=0 font=12 zoom=1 overlay");
}

function removeCaps() {
    Overlay.activateSelection(0);
    run("Clear");
    Overlay.activateSelection(1);
    run("Clear");
    run("Select None"); 
}

function report() {
    mean = getValue("Mean");
    stddev = getValue("StdDev");
    mode = getValue("Mode");
    min = getValue("Min");
    max = getValue("Max");
    median = getValue("Median");
    if (!isOpen(TABLE_TITLE)) {
        Table.create(TABLE_TITLE);
    }
    row = Table.size(TABLE_TITLE);
    Table.set("Image", row, title);    
    Table.set("Mean", row, mean);
    Table.set("StdDev", row, stddev);
    Table.set("Mode", row, mode);
    Table.set("Min", row, min);
    Table.set("Max", row, max);
    Table.set("Median", row, median);
    Table.set("Method", row, "width profile voronoi");
}
