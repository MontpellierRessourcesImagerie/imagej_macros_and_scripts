var THRESHOLDING_METHODS = getList("threshold.methods");
var THRESHOLDING_METHOD = "Huang";
var SMOOTH = true;
var SIGMA = 2;
var SMOOTH_CONTOUR = true;
var SMOOTH_LENGTH = 40;
var MIN_SIZE = 2000;
var TABLE_TITLE = "width measurements";
var OVERLAY = true;
var LEGEND = true;
var SAVE_OPTIONS = true;

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

optionsOnly = call("ij.Prefs.get", "mri.options.only", "false");
showDialog();
if (optionsOnly=="true") exit;
runLocalThickness();

function showDialog() {
    if (File.exists(getOptionsPath())) loadOptions();
    Dialog.create("Options of Width profile by local thickness");
    
    Dialog.addMessage("Thresholding options (only used if the input image is not a mask)");
    Dialog.addCheckbox("Smooth_image", SMOOTH);
    Dialog.addNumber("Sigma for smoothing: ", SIGMA);
    Dialog.addChoice("Auto-thresholding method: ", THRESHOLDING_METHODS, THRESHOLDING_METHOD);
    Dialog.addCheckbox("Smooth_contour: ", SMOOTH_CONTOUR);
    Dialog.addNumber("Smoothing length: ", SMOOTH_LENGTH);
    Dialog.addNumber("Min_area: ", MIN_SIZE);
    
    Dialog.addMessage("Output options");
    Dialog.addCheckbox("Create_overlay", OVERLAY);
    Dialog.addCheckbox("Create_legend", LEGEND);
    
    Dialog.addCheckbox("Save_options", SAVE_OPTIONS);
    Dialog.addHelp(_URL);
    
    Dialog.show();
    SMOOTH = Dialog.getCheckbox();
    SIGMA = Dialog.getNumber();
    THRESHOLDING_METHOD = Dialog.getChoice();
    SMOOTH_CONTOUR = Dialog.getCheckbox();
    SMOOTH_LENGTH = Dialog.getNumber();
    MIN_SIZE = Dialog.getNumber();
    
    OVERLAY = Dialog.getCheckbox();
    LEGEND = Dialog.getCheckbox();
    SAVE_OPTIONS = Dialog.getCheckbox();
    
    if (SAVE_OPTIONS) saveOptions();
}

function runLocalThickness() {
    startTime = getTime();
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
    print("width_profile_by_local_thickness.ijm");
    print(getOptionsString());
    run("Select None");
    title = getTitle();
    imageID = getImageID();
    run("Duplicate...", " ");
    if (!imageIsABinaryMask()) {
        createMask();
    }
    run("Local Thickness (masked, calibrated, silent)");
    thicknessMap = getImageID();
    resetMinAndMax();
    run("Enhance Contrast", "saturated=0.35");
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
    Table.set("Method", row, "width profile by local thickness");
    run("Select All");
    run("Copy");
    setPasteMode("Blend");
    selectImage(imageID);
    run("RGB Color");
    run("Paste");
    run("Select None");
    selectImage(thicknessMap);
    getPixelSize(unit, pixelWidth, pixelHeight);
    run("Calibrate...", "function=None unit="+unit);
    run("Calibration Bar...", "location=[Separate Image] fill=Black label=White number=9 decimal=0 font=12 zoom=1 overlay");
    setPasteMode("Copy");
    endTime = getTime();
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print("execution time: ", ((endTime - startTime) / 1000), "sec.");
    print(year + "-" + IJ.pad(month+1, 2) + "-" + IJ.pad(dayOfMonth, 2) + " " + hour + ":" + minute + ":" + second + "." + msec);
}


function imageIsABinaryMask() {
    width = getWidth();
    height = getHeight();

    getHistogram(values, counts, 256);
    nrPixelsBlackAndWhite = counts[0] + counts[255];
    if (bitDepth()==8 && nrPixelsBlackAndWhite == width*height) {
        return true;
    }
    return false;
}

function createMask() {
    if (SMOOTH) {
        run("Gaussian Blur...", "sigma="+SIGMA);
    }
    setAutoThreshold(THRESHOLDING_METHOD + " dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    tmpImageID = getImageID();
    run("Fill Holes");  
    run("Analyze Particles...", "size="+MIN_SIZE+"-Infinity show=Masks");
    selectImage(tmpImageID);
    close();
    run("Invert LUT");
    if (SMOOTH_CONTOUR) {
        run("Create Selection");
        run("Interpolate", "interval="+SMOOTH_LENGTH+" smooth");
        run("Clear Outside");
        run("Fill");
        run("Select None");        
    }
}

function loadOptions() {
    optionsPath = getOptionsPath();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    options = split(optionsString, " ");
    SMOOTH = false;
    SMOOTH_CONTOUR = false;
    OVERLAY = false;
    LEGEND = false;
    for (i = 0; i < options.length; i++) {
        option = options[i];
        parts = split(option, "=");
        key = parts[0];
        value = "";
        if (indexOf(option, "=") > -1) value = parts[1];
        if (key=="sigma") SIGMA = value;
        if (key=="auto-thresholding") THRESHOLDING_METHOD = value;
        if (key=="smoothing") SMOOTH_LENGTH = value;
        if (key=="min_area") MIN_SIZE = value;
        if (key=="smooth_image") SMOOTH = true;
        if (key=="smooth_contour") SMOOTH_CONTOUR = true;
        if (key=="create_overlay") OVERLAY = true;
        if (key=="create_legend") LEGEND = true;
    }
}

function getOptionsPath() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wplt-options.txt";
    return optionsPath;
}

function getOptionsString() {
    optionsString = "";
    optionsString = optionsString + "sigma=" + SIGMA;
    optionsString = optionsString + " auto-thresholding=" + THRESHOLDING_METHOD;
    optionsString = optionsString + " smoothing=" + SMOOTH_LENGTH;
    optionsString = optionsString + " min_area=" + MIN_SIZE;
    if (SMOOTH) optionsString = optionsString + " smooth_image";
    if (SMOOTH_CONTOUR) optionsString = optionsString + " smooth_contour";
    if (OVERLAY) optionsString = optionsString + " create_overlay";
    if (LEGEND) optionsString = optionsString + " create_legend";
    return optionsString;
}

function saveOptions() {
    optionsString = getOptionsString();
    optionsPath = getOptionsPath();
    File.saveString(optionsString, optionsPath);
}


