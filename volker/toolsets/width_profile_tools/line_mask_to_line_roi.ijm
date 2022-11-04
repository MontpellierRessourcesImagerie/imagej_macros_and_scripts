/**
  * Create a line-roi (polyline) from a one pixel wide line in a mask.
  *   
  *  (c) 2022, INSERM
  *  written  by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * 
  **
*/

var XDIR = newArray(-1, 0, 1, -1, 1, -1, 0, 1);
var YDIR = newArray(-1, -1, -1, 0, 0, 1, 1, 1);
var INTERPOLATION_INTERVAL = 1;
var SAVE_OPTIONS = true;

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

optionsOnly = call("ij.Prefs.get", "mri.options.only", "false");
showDialog();
if (optionsOnly=="true") exit;
runLineMaskToLineRoi();

function showDialog() {
    if (File.exists(getOptionsPath())) loadOptions();
    Dialog.create("Options of line mask to line roi");
   
    Dialog.addNumber("interpolation interval: ", INTERPOLATION_INTERVAL);
    Dialog.addCheckbox("Save_options", SAVE_OPTIONS);
    Dialog.addHelp(_URL);
    
    Dialog.show();
    
    INTERPOLATION_INTERVAL = Dialog.getNumber();
    SAVE_OPTIONS = Dialog.getCheckbox();
    
    if (SAVE_OPTIONS) saveOptions();
}

function runLineMaskToLineRoi() {
    width = getWidth();
    height = getHeight();
    Overlay.remove;
    run("Duplicate...", " ");
    skeletonID = getImageID();
    startPoint = findASkeletonEndPoint();
    numberOfPoints = getValue("RawIntDen") / 255;
    xpoints = newArray(numberOfPoints);
    ypoints = newArray(numberOfPoints);
    neighbors = newArray(8);
    oneEndPoint = findASkeletonEndPoint();
    x = oneEndPoint[0];
    y = oneEndPoint[1];
    for (i = 0; i < numberOfPoints; i++) {
        xpoints[i] = x;
        ypoints[i] = y;
        setPixel(x, y, 128);
        found = false;
        pn = 0;
        for (ix = 0; ix < 8; ix++) {
            for (iy = 0; iy < 8; iy++) {
                xn = x + XDIR[ix];
                yn = y + YDIR[iy];
                pn = getPixel(xn, yn);
                if (pn == 255) {
                    found = true;
                    break;
                }
            }   
            if (found) break;
        }
        if (pn == 255) {
            x = xn;
            y = yn; 
        } else {
            break;
        }
    }
    
    // The actual roi may have less points than the number of pixels, therefore remove unused array entries.
    xpoints = Array.deleteValue(xpoints, 0);
    ypoints = Array.deleteValue(ypoints, 0);
    
    close();
    makeSelection("freeline", xpoints, ypoints);
    run("Interpolate", "interval="+INTERPOLATION_INTERVAL+" smooth adjust");
    Overlay.addSelection("green")
}


function findASkeletonEndPoint() {
    run("Create Selection");
    Roi.getContainedPoints(xpoints, ypoints);
    run("Select None");
    nrOfPoints = xpoints.length;
    for (i = 0; i < nrOfPoints; i++) {
        x = xpoints[i];
        y = ypoints[i];
        p = getPixel(x, y);        
        nn = 0;
        if (p > 0) {
            nn = getPixel(x-1, y-1) + getPixel(x, y-1) + getPixel(x+1, y-1) + getPixel(x-1, y) + getPixel(x+1, y) + getPixel(x-1, y+1) + getPixel(x, y+1) + getPixel(x+1, y+1);
                if (nn==255) break;
        }
    }   
    return newArray(x, y);
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
        if (key=="interpolation") INTERPOLATION_INTERVAL = value;
    }
}

function getOptionsPath() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/lmtl-options.txt";
    return optionsPath;
}

function getOptionsString() {
    optionsString = "";
    optionsString = optionsString + "interpolation=" + INTERPOLATION_INTERVAL;
    return optionsString;
}

function saveOptions() {
    optionsString = getOptionsString();
    optionsPath = getOptionsPath();
    File.saveString(optionsString, optionsPath);
}