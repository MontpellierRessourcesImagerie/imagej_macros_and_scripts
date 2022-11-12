var METHODS = newArray("ROI_interpolation", "Scaling", "Morphology");
var METHOD = "ROI interpolation";
var INTERVAL = 45;
var SHRINK = 2;
var SCALE = 16;
var OPEN_RADIUS = 2;
var CLOSE_RADIUS = 4;
var SAVE_OPTIONS = true;

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

optionsOnly = call("ij.Prefs.get", "mri.options.only", "false");
showDialog();
if (optionsOnly=="true") exit;
startTime = getTime();
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
print("smooth_mask.ijm");
print(getOptionsString());
if (METHOD == "ROI_interpolation") runSmoothMaskByROIInterpolation();
if (METHOD == "Scaling") runSmoothMaskByScaling();
if (METHOD == "Morphology") runSmoothByMorphology();
endTime = getTime();
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
print("execution time: ", ((endTime - startTime) / 1000), "sec.");
print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);

function showDialog() {
    if (File.exists(getOptionsPath())) loadOptions();
    Dialog.create("Options of smooth mask");
    
    Dialog.addChoice("method: ", METHODS, METHOD);      
    Dialog.addNumber("Shrink (0 for no shrinking): ", SHRINK);
    Dialog.addMessage("ROI Interpolation Options");
    Dialog.addNumber("Interval: ", INTERVAL);
    Dialog.addMessage("Scaling options");    
    Dialog.addNumber("Scaling factor:", SCALE);
    Dialog.addMessage("Morphology options");    
    Dialog.addNumber("Open radius: ", OPEN_RADIUS);
    Dialog.addNumber("Close radius: ", CLOSE_RADIUS);
    Dialog.addCheckbox("Save_options", SAVE_OPTIONS);
    Dialog.addHelp(_URL);
    
    Dialog.show();
    METHOD = Dialog.getChoice();
    SHRINK = Dialog.getNumber();
    INTERVAL = Dialog.getNumber();
    SCALE = Dialog.getNumber();
    OPEN_RADIUS = Dialog.getNumber();
    CLOSE_RADIUS = Dialog.getNumber();
    SAVE_OPTIONS = Dialog.getCheckbox();
    
    if (SAVE_OPTIONS) saveOptions();
}

function runSmoothMaskByROIInterpolation() { 
    run("Create Selection");
    area1 = getValue("Area");
    Roi.getContainedPoints(xpoints, ypoints);
    for (i = 0; i < xpoints.length; i++) {
        run("Select None");
        doWand(xpoints[i], ypoints[i]);    
        area2 = getValue("Area");
        if (area1 == area2) {
            break; 
        } 
    }   
    run("Interpolate", "interval="+INTERVAL+" smooth adjust");
    if (SHRINK > 0) run("Enlarge...", "enlarge=-"+SHRINK);
    run("Clear Outside");
    run("Fill", "slice");
    run("Select None");
}

function runSmoothMaskByScaling() {
    width = getWidth();
    height = getHeight();
    inputImageID = getImageID();
    run("Scale...", "x="+(1/SCALE)+" y="+(1/SCALE)+" interpolation=Bilinear average create");
    smallImageID = getImageID();
    run("Scale...", "width="+width+" height="+height+" interpolation=Bilinear average create");
    setAutoThreshold("Default dark");
    run("Convert to Mask");
    if (SHRINK>0) {
        tmpImageID = getImageID();
        run("Morphological Filters", "operation=Erosion element=Square radius=" + SHRINK);
        selectImage(tmpImageID);
        close();
    }
    selectImage(smallImageID);
    close();
    selectImage(inputImageID);
    close();
}

function runSmoothByMorphology() {
    inputImageID = getImageID();
    run("Morphological Filters", "operation=Opening element=Square radius=" + OPEN_RADIUS);
    tmpImageID = getImageID();
    run("Morphological Filters", "operation=Closing element=Square radius=" + CLOSE_RADIUS);
    tmpImage2ID = getImageID();
    run("Fill Holes (Binary/Gray)");    
    selectImage(inputImageID);
    close();
    selectImage(tmpImageID);
    close();
    selectImage(tmpImage2ID);
    close();
    if (SHRINK>0) {
        tmpImageID = getImageID();
        run("Morphological Filters", "operation=Erosion element=Square radius=" + SHRINK);
        selectImage(tmpImageID);
        close();
    }
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
        if (key=="shrink") SHRINK = value;
        if (key=="interval") INTERVAL = value;
        if (key=="scaling") SCALE = value;
        if (key=="open") OPEN_RADIUS = value;
        if (key=="close") CLOSE_RADIUS = value;
    }
}

function getOptionsPath() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/smooth-mask-options.txt";
    return optionsPath;
}

function getOptionsString() {
    optionsString = "";
    optionsString = optionsString + "method=" + METHOD;
    optionsString = optionsString + " shrink=" + SHRINK;
    optionsString = optionsString + " interval=" + INTERVAL;
    optionsString = optionsString + " scaling=" + SCALE;
    optionsString = optionsString + " open=" + OPEN_RADIUS;
    optionsString = optionsString + " close=" + CLOSE_RADIUS;
    return optionsString;
}

function saveOptions() {
    optionsString = getOptionsString();
    optionsPath = getOptionsPath();
    File.saveString(optionsString, optionsPath);
}
