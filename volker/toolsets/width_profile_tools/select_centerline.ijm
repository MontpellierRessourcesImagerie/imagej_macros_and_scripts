var METHODS = newArray("Voronoi", "Skeletonize", "Largest_Shortest_Path", "Monte_Carlo_Centerline_Estimation");
var METHOD = "Voronoi";

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

var SAVE_OPTIONS = true;

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

optionsOnly = call("ij.Prefs.get", "mri.options.only", "false");
showDialog();
if (optionsOnly=="true") exit;

startTime = getTime();
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
print("select_centerline.ijm");
print(getOptionsString());

selectCenterline();

endTime = getTime();
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("execution time: ", ((endTime - startTime) / 1000), "sec.");
print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
    
function showDialog() {
    if (File.exists(getOptionsPath())) loadOptions();
    Dialog.create("Options of select centerline");
    Dialog.addChoice("method:", METHODS, METHOD);
    Dialog.addMessage("Skeletonize and Largest Shortest Path Options");
    Dialog.addNumber("Interpolation interval", LINE_INTERPOLATION);
    Dialog.addMessage("Monte Carlo Centerline Estimation Options");
    Dialog.addNumber("min_radius", MIN_RADIUS);
    Dialog.addNumber("min_distance", MIN_DIST);
    Dialog.addNumber("samples", SAMPLES);
    Dialog.addNumber("max_trials", MAX_TRIALS);
    Dialog.addCheckbox("Save_options", SAVE_OPTIONS);
    Dialog.addHelp(_URL);
    Dialog.show();
    
    METHOD = Dialog.getChoice();
    LINE_INTERPOLATION = Dialog.getNumber();
    MIN_RADIUS = Dialog.getNumber();
    MIN_DIST = Dialog.getNumber();
    SAMPLES = Dialog.getNumber();
    MAX_TRIALS = Dialog.getNumber();
    
    SAVE_OPTIONS = Dialog.getCheckbox(); 
    
    if (SAVE_OPTIONS) saveOptions();
}


function selectCenterline() {
    Overlay.remove;
    width = getWidth();
    height = getHeight();
    run("Clear Results");
    roiManager("reset");
    if (METHOD != "Monte_Carlo_Centerline_Estimation") {
        run("Select None");
        run("Duplicate...", " ");
    }
    
    if (METHOD=="Voronoi") runCenterlineFromVoronoi();
    if (METHOD=="Skeletonize") runCenterlineFromSkeleton();
    if (METHOD=="Largest_Shortest_Path") runCenterlineFromPath();
    if (METHOD=="Monte_Carlo_Centerline_Estimation") runCenterlineFromMonteCarlo();
    
    if (METHOD != "Monte_Carlo_Centerline_Estimation" && METHOD != "Voronoi") {
        run("line mask to line roi", "interpolation="+LINE_INTERPOLATION);
    }
    Overlay.activateSelection(Overlay.size - 1);
    run("Interpolate", "interval=1 smooth adjust");
    roiManager("add");
    close();
    roiManager("show none");
    roiManager("show all without labels");
    roiManager("select", 0);
    Overlay.addSelection;
    
    if (METHOD=="Monte_Carlo_Centerline_Estimation")
        run("Canvas Size...", "width="+width+" height="+height+" position=Center");
}

function runCenterlineFromVoronoi() {
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
    run("Duplicate...", " ");
    setThreshold(1.0000, 1000000000000000000000000000000.0000);
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Skeletonize (2D/3D)");
    run("line mask to line roi", "interpolation=1");
    Overlay.activateSelection(0);
    Roi.getCoordinates(xpoints, ypoints);
    run("Select None");
    close();
    close();
    close();
    close();
    makeSelection("polyline", xpoints, ypoints);
    run("Interpolate", "interval=1 smooth adjust");
    Overlay.addSelection;
}


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
    Overlay.addSelection;
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

function loadOptions() {
    optionsPath = getOptionsPath();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    options = split(optionsString, " ");   
    for (i = 0; i < options.length; i++) {
        option = options[i];
        parts = split(option, "=");
        key = parts[0];
        value = "";
        if (indexOf(option, "=") > -1) value = parts[1];
        if (key=="method") METHOD = value;
        if (key=="interpolation") LINE_INTERPOLATION = value;
        if (key=="min_radius") MIN_RADIUS = value;
        if (key=="min_distance") MIN_DIST = value;
        if (key=="samples") SAMPLES = value;
        if (key=="max_trials") MAX_TRIALS = value;
    }
}

function getOptionsPath() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/select-centerline-options.txt";
    return optionsPath;
}

function getOptionsString() {
    optionsString = "";
    optionsString = optionsString + "method=" + METHOD;
    optionsString = optionsString + " interpolation=" + LINE_INTERPOLATION;
    optionsString = optionsString + " min_radius=" + MIN_RADIUS;
    optionsString = optionsString + " min_distance=" + MIN_DIST;
    optionsString = optionsString + " samples=" + SAMPLES;
    optionsString = optionsString + " max_trials=" + MAX_TRIALS;
    return optionsString;
}

function saveOptions() {
    optionsString = getOptionsString();
    optionsPath = getOptionsPath();
    File.saveString(optionsString, optionsPath);
}