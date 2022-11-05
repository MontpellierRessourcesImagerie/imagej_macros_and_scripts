var METHODS = newArray("Skeletonize", "Largest shortest path", "Monte Carlo estimation");
var METHOD = "Monte Carlo estimation";

var LINE_INTERPOLATION = 1;

var DILATE_RADIUS = 8;

var MIN_RADIUS = 12;
var MIN_DIST = 1;
var SAMPLES = 100;
var MAX_TRIALS = 100;
var DEBUG = false;

var XDIR = newArray(-1, 0, 1, -1, 1, -1, 0, 1);
var YDIR = newArray(-1, -1, -1, 0, 0, 1, 1, 1);
var seedsX = newArray(0);
var seedsY = newArray(0);

Overlay.remove;
width = getWidth();
height = getHeight();
run("Clear Results");
roiManager("reset");
if (METHOD != "Monte Carlo estimation") {
    run("Select None");
    run("Duplicate...", " ");
}

if (METHOD=="Skeletonize") runCenterlineFromSkeleton();
if (METHOD=="Largest shortest path") runCenterlineFromPath();
if (METHOD=="Monte Carlo estimation") runCenterlineFromMonteCarlo();

if (METHOD != "Monte Carlo estimation") {
    run("line mask to line roi", "interpolation="+LINE_INTERPOLATION);
}
roiManager("add");
close();
roiManager("show none");
roiManager("show all without labels");
roiManager("select", 0);
Overlay.addSelection;

if (METHOD=="Monte Carlo estimation")
    run("Canvas Size...", "width="+width+" height="+height+" position=Center");

function runCenterlineFromSkeleton() {
    run("Skeletonize (2D/3D)");
}

function runCenterlineFromPath() {
    inputImageID = getImageID();
    run("Skeletonize (2D/3D)");
    run("Analyze Skeleton (2D/3D)", "prune=none prune_0 calculate");
    close("Tagged Skeleton");
    run("Replace/Remove Label(s)", "label(s)=255 final=0");
    run("Morphological Filters", "operation=Dilation element=Disk radius="+DILATE_RADIUS);
    close("Longest shortest paths");
    run("Skeletonize (2D/3D)");
    selectImage(inputImageID);
    close();
}

function runCenterlineFromMonteCarlo() {
    run("Set Measurements...", "min centroid display redirect=None decimal=3");
    inputImageTitle = getTitle();
    width = getWidth();
    height = getHeight();
    
    type = selectionType();
    
    if (selectionType() != 10) {
        showMessage("A point-roi of a single point is needed!");
        exit;
    }
    
    Roi.getCoordinates(startPointX, startPointY);
    if (startPointX.length != 1) {
        showMessage("A point-roi of a single point is needed!");
        exit;
    }
    
    run("Canvas Size...", "width="+(width+2)+" height="+(height+2)+" position=Center");
    run("ROI Manager...");
    roiManager("Show All");
    
    if (!DEBUG) setBatchMode(true);
    findCenterLine2();
    if (!DEBUG) setBatchMode(false);
    
    run("Duplicate...", " ");
    markerImageTitle = getTitle();
    run("Select All");
    run("Clear");
    run("Select None");
    setPixel(startPointX[0], startPointY[0], 255);
    run("Geodesic Distance Map", "marker=["+markerImageTitle+"] mask=["+inputImageTitle+"] distances=[Chessknight (5,7,11)] output=[32 bits] normalize");
    roiManager("measure");
    if (MIN_DIST>0) removeCloseBubbles();
    Table.sort("Min");
    X = Table.getColumn("X");
    Y = Table.getColumn("Y");
    close();
    makeSelection("polyline", X, Y);
    if (X.length>2) run("Fit Spline");
    roiManager("reset");
}


function seedPixelsInSkeleton() {
    roiManager("reset");   
    run("Duplicate...", " ");
    run("Skeletonize");
    run("Create Selection");
    Roi.getContainedPoints(seedsX, seedsY);
    close();
}

function seedAllPixelsInMask() {
    roiManager("reset");
    run("Create Selection");
    Roi.getContainedPoints(seedsX, seedsY);
}


function seedARandomPixelsInMask() {
    roiManager("reset");
    run("Create Selection");
    Roi.getContainedPoints(xpoints, ypoints);
    run("Select None");
    run("Invert");
    counter = 0
    seedsX = newArray(SAMPLES);
    seedsY = newArray(SAMPLES);
    while(counter<SAMPLES) {
        i = round(random * xpoints.length);
        makeOval(xpoints[i] - MIN_RADIUS, ypoints[i]-MIN_RADIUS, 2*MIN_RADIUS+1, 2*MIN_RADIUS+1);
        v = getValue("IntDen");
        if (v==0) {
            seedsX[counter] = xpoints[i];
            seedsY[counter] = ypoints[i];
            counter++;
        }
    }
    run("Select None");
    run("Invert");
}

function findCenterLine2() {
    roiManager("reset");
    run("Select None");
    maskID = getImageID();
    run("Duplicate...", " ");
    samplesID = getImageID();
    selectImage(maskID);
    run("Select None");
    run("Invert");
    for (i = 0; i < SAMPLES; i++) {
        showProgress(i+1, SAMPLES);
        selectImage(samplesID);
        run("Create Selection");
        Roi.getContainedPoints(xpoints, ypoints);
        run("Select None");
        run("Invert");    
        trials = 0;
        do {
            index = floor(random * xpoints.length);
            makeOval(xpoints[index] - MIN_RADIUS, ypoints[index]-MIN_RADIUS, 2*MIN_RADIUS+1, 2*MIN_RADIUS+1);
            v = getValue("IntDen");
            trials++;
            if (trials > MAX_TRIALS) break;
        } while (v>0);
        fill();
        run("Select None");
        selectImage(maskID);
        seedsX = newArray(xpoints[i]);
        seedsY = newArray(ypoints[i]);
        run("Restore Selection");
        growAndPosition();
        selectImage(samplesID);
        count = roiManager("count");
        roiManager("select", count - 1);
        selectImage(samplesID);
        fill();
        run("Select None");
        run("Invert");
    }
    selectImage(maskID);
    run("Select None");
    run("Invert");
}

function findCenterLine(xpoints, ypoints) {
    run("Select None");
    run("Invert");
    for (i = 0; i < xpoints.length; i++) {
        makeOval(xpoints[i] - MIN_RADIUS, ypoints[i]-MIN_RADIUS, 2*MIN_RADIUS+1, 2*MIN_RADIUS+1);
        v = getValue("IntDen");
        if (v==0) growAndPosition();
    }
    
    run("Select None");
    run("Invert");
}



function growAndPosition() {
    roiManager("add");
    count = roiManager("count");
    roiManager("select", count-1);
    
    MAX_ITER = 1000;
    counter = 0;
    while (counter<MAX_ITER) {
        grew = grow();
        if (grew) continue;
        moved = moveit();
        if (!grew && !moved) break;
        counter++;
    }
}


function grow() {
    v = getValue("IntDen");
    counter = 0;
    while(v==0) {
        run("Enlarge...", "enlarge=1");
        v = getValue("IntDen");
        counter++;
    }
    run("Enlarge...", "enlarge=-1");
    roiManager("update");
    return (counter>1);
}

function moveit() {
    x = getValue("BX");
    y = getValue("BY");
    Array.reverse(XDIR);
    Array.reverse(YDIR);
    for (i = 0; i < XDIR.length; i++) {
        Roi.move(x + MIN_RADIUS*XDIR[i], y + MIN_RADIUS*YDIR[i]);
        v = getValue("IntDen");
        if (v>0) {
            Roi.move(x - XDIR[i], y - YDIR[i]);
            continue;
        } 
        else {
           grew = grow();
           if (grew) return true;
           Roi.move(x - XDIR[i], y - YDIR[i]);
        }
    }
    for (i = 0; i < XDIR.length; i++) {
        Roi.move(x + XDIR[i], y + YDIR[i]);
        v = getValue("IntDen");
        if (v>0) {
            Roi.move(x - XDIR[i], y - YDIR[i]);
            continue;
        } 
        else {
           grew = grow();
           if (grew) return true;
           Roi.move(x - XDIR[i], y - YDIR[i]);
        }
    }
    return false;
}

function removeDuplicates() {
    X = Table.getColumn("X", "Results");
    Y = Table.getColumn("Y", "Results");
    run("Duplicate...", " ");
    run("Select All");
    run("Clear", "slice");
    run("Select None");
    toBeDeleted = newArray(0);
    for (i = 0; i < X.length; i++) {
        v = getPixel(X[i], Y[i]);
        if (v>0) {
            toBeDeleted = Array.concat(toBeDeleted, i);
        } else {
            setPixel(X[i], Y[i], i+1);
        }
    }
    if (toBeDeleted.length>0) {
        roiManager("select", toBeDeleted);
        roiManager("delete");
        print("deleted " + toBeDeleted.length + " bubbles");
    }
    run("Clear Results");
    close();
    roiManager("measure");
}

function drawCenters() {
    X = Table.getColumn("X", "Results");
    Y = Table.getColumn("Y", "Results");
    
    run("Duplicate...", " ");
    run("Select All");
    run("Clear", "slice");
    run("Select None");
    for (i = 0; i < X.length; i++) {
        setPixel(X[i], Y[i], 255);
    }
}

function removeCloseBubbles() {
    drawCenters();
    run("Morphological Filters", "operation=Dilation element=Disk radius="+MIN_DIST);
    title = getTitle();
    setAutoThreshold("Default dark");
    run("Analyze Particles...", "display clear");
    X = Table.getColumn("X", "Results");
    Y = Table.getColumn("Y", "Results");
    close();
    close();
    makeSelection("point", X, Y);
    run("Clear Results");
    run("Measure");
    run("Select None");
}

