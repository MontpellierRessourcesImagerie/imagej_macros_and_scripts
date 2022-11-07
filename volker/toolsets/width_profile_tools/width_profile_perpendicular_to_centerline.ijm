var SAMPLE_DISTANCE = 1;
var COLORS = newArray("black", "blue", "cyan", "darkGray", "gray", "green", "lightGray", "magenta", "orange", "pink", "red", "white", "yellow");
var LINE_COLOR = "pink";
var RADIUS = 15;
var SAVE_OPTIONS = true;
var SHOW_PROFILE_PLOT = true;
var TABLE_TITLE = "width measurements";
var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

optionsOnly = call("ij.Prefs.get", "mri.options.only", "false");
showDialog();
if (optionsOnly=="true") exit;
runWidthProfilePerpendicularToCenterline();

function showDialog() {
    if (File.exists(getOptionsPath())) loadOptions();
    Dialog.create("Options of width profile perpendicular to centerline");
    Dialog.addNumber("Sample distance: ", SAMPLE_DISTANCE);
    Dialog.addNumber("Radius: ", RADIUS);
    Dialog.addChoice("Line_color: ", COLORS, LINE_COLOR);
    Dialog.addCheckbox("Show profile plot", SHOW_PROFILE_PLOT);
    Dialog.addCheckbox("Save_options", SAVE_OPTIONS);
    Dialog.addHelp(_URL);
    Dialog.show();
    SAMPLE_DISTANCE = Dialog.getNumber();
    RADIUS = Dialog.getNumber();
    LINE_COLOR = Dialog.getChoice();
    SHOW_PROFILE_PLOT = Dialog.getCheckbox();
    SAVE_OPTIONS = Dialog.getCheckbox(); 
    
    if (SAVE_OPTIONS) saveOptions();
}

function runWidthProfilePerpendicularToCenterline() {
    Overlay.remove;
    width = getWidth();
    height = getHeight();
    roiManager("reset");
    
    Roi.getCoordinates(xpoints, ypoints);
    Overlay.addSelection("green");
    
    middleIndex = floor(xpoints.length / 2);
    
    stepWidth = SAMPLE_DISTANCE;
    
    X1 = newArray(0);
    Y1 = newArray(0);
    X2 = newArray(0);
    Y2 = newArray(0);
    
    for (i = middleIndex; i >= 0; i = i - stepWidth) {
        leftIndex = i - RADIUS;
        rightIndex = i + RADIUS;
        if (leftIndex < 0) {
            rightIndex = rightIndex + -leftIndex;
            leftIndex = 0;
            rotated = rotateLineSegmentBy90Around(xpoints[leftIndex], ypoints[leftIndex], xpoints[rightIndex], ypoints[rightIndex], xpoints[i], ypoints[i]);    
        } else {
            rotated = rotateLineSegmentBy90(xpoints[leftIndex], ypoints[leftIndex], xpoints[rightIndex], ypoints[rightIndex]);
        }
        allongatedLine = growLineToBorders(rotated[0], rotated[1], rotated[2], rotated[3]);
        X1 = Array.concat(allongatedLine[0] ,X1);
        Y1 = Array.concat(allongatedLine[1] ,Y1);
        X2 = Array.concat(allongatedLine[2] ,X2);
        Y2 = Array.concat(allongatedLine[3] ,Y2);
    }
    
    for (i = middleIndex + stepWidth; i < xpoints.length; i = i + stepWidth) {
        leftIndex = i - RADIUS;
        rightIndex = i + RADIUS;
        if (rightIndex >  xpoints.length - 1) {
            leftIndex = i-RADIUS - (rightIndex - ( xpoints.length - 1));    
            rightIndex =  xpoints.length - 1;
            rotated = rotateLineSegmentBy90Around(xpoints[leftIndex], ypoints[leftIndex], xpoints[rightIndex], ypoints[rightIndex], xpoints[i], ypoints[i]);
        } else {
            rotated = rotateLineSegmentBy90(xpoints[leftIndex], ypoints[leftIndex], xpoints[rightIndex], ypoints[rightIndex]);
        }
        allongatedLine = growLineToBorders(rotated[0], rotated[1], rotated[2], rotated[3]);
        X1 = Array.concat(X1, allongatedLine[0]);
        Y1 = Array.concat(Y1, allongatedLine[1]);
        X2 = Array.concat(X2, allongatedLine[2]);
        Y2 = Array.concat(Y2, allongatedLine[3]);
    }
    
    for (i = 0; i < X1.length; i++) {
        makeLine(X1[i], Y1[i], X2[i], Y2[i]);
        Overlay.addSelection("red");    
    }
    
    run("Select None");
}

function growLineToBorders(x1, y1, x2, y2) {
        deltaX = x2 - x1;
        deltaY = y2 - y1;
        n = round(sqrt(deltaX*deltaX + deltaY*deltaY));
        deltaX = deltaX / n;
        deltaY = deltaY / n;
        x0 = x1;
        y0 = y1;
        while(true) {
            v = getPixel(x0, y0);
            if (v<255) break;
            x0 = x0 + deltaX;
            y0 = y0 + deltaY;
        }    
        xN = x1;
        yN = y1;
        while(true) {
            v = getPixel(xN, yN);
            if (v<255) break;
            xN = xN - deltaX;
            yN = yN - deltaY;
        }
        return newArray(xN, yN, x0, y0);
}

function rotateLineSegmentBy90(x1, y1, x2, y2) {
    cx = (x1 + x2) / 2;
    cy = (y1 + y2) / 2;

    //move the line to center on the origin
    x1 = x1 - cx; 
    y1 = y1 - cy;
    x2 = x2 - cx; 
    y2 = y2 - cy;
   
    //rotate both points
    xtemp = x1; 
    ytemp = y1;
    x1 = ytemp; 
    y1 = -xtemp;
    
    xtemp = x2; 
    ytemp = y2;
    x2 = ytemp; 
    y2 = -xtemp; 
   
    deltaX = x2 - x1;
    deltaY = y2 - y1;
    n = round(sqrt(deltaX*deltaX + deltaY*deltaY));
    //move the center point back to where it was
    x1 = (2*deltaX/n) + cx; 
    y1 = (2*deltaY/n) + cy;
    x2 = cx - (2*deltaX/n); 
    y2 = cy - (2*deltaY/n);
    
    res = newArray(x1, y1, x2, y2);
    return res;
}

function rotateLineSegmentBy90AroundP2(x1, y1, x2, y2) {
    cx = x2;
    cy = y2;

    //move the line to center on the origin
    x1 = x1 - cx; 
    y1 = y1 - cy;
    x2 = x2 - cx; 
    y2 = y2 - cy;
   
    //rotate both points
    xtemp = x1; 
    ytemp = y1;
    x1 = ytemp; 
    y1 = -xtemp;
    
    xtemp = x2; 
    ytemp = y2;
    x2 = ytemp; 
    y2 = -xtemp; 
   
    deltaX = x2 - x1;
    deltaY = y2 - y1;
    n = round(sqrt(deltaX*deltaX + deltaY*deltaY));
    //move the center point back to where it was
    x1 = (2*deltaX/n) + cx; 
    y1 = (2*deltaY/n) + cy;
    x2 = cx - (2*deltaX/n); 
    y2 = cy - (2*deltaY/n);
    
    res = newArray(x1, y1, x2, y2);
    return res;
}

function rotateLineSegmentBy90Around(x1, y1, x2, y2, xp, yp) {
    cx = xp;
    cy = yp;

    //move the line to center on the origin
    x1 = x1 - cx; 
    y1 = y1 - cy;
    x2 = x2 - cx; 
    y2 = y2 - cy;
   
    //rotate both points
    xtemp = x1; 
    ytemp = y1;
    x1 = ytemp; 
    y1 = -xtemp;
    
    xtemp = x2; 
    ytemp = y2;
    x2 = ytemp; 
    y2 = -xtemp; 
   
    deltaX = x2 - x1;
    deltaY = y2 - y1;
    n = round(sqrt(deltaX*deltaX + deltaY*deltaY));
    //move the center point back to where it was
    x1 = (2*deltaX/n) + cx; 
    y1 = (2*deltaY/n) + cy;
    x2 = cx - (2*deltaX/n); 
    y2 = cy - (2*deltaY/n);
    
    res = newArray(x1, y1, x2, y2);
    return res;
}

function loadOptions() {
    optionsPath = getOptionsPath();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    options = split(optionsString, " ");
    SHOW_PROFILE_PLOT = false;
    for (i = 0; i < options.length; i++) {
        option = options[i];
        parts = split(option, "=");
        key = parts[0];
        value = "";
        if (indexOf(option, "=") > -1) value = parts[1];
        if (key=="sample") SAMPLE_DISTANCE = value;
        if (key=="radius") RADIUS = value;
        if (key=="line_color") LINE_COLOR = value;
        if (key=="show") SHOW_PROFILE_PLOT = true;
    }
}

function getOptionsPath() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wppc-options.txt";
    return optionsPath;
}

function getOptionsString() {
    optionsString = "";
    optionsString = optionsString + "sample=" + SAMPLE_DISTANCE;
    optionsString = optionsString + " radius=" + RADIUS;
    optionsString = optionsString + " line_color=" + LINE_COLOR;
    if (SHOW_PROFILE_PLOT) optionsString = optionsString + " show";
    return optionsString;
}

function saveOptions() {
    optionsString = getOptionsString();
    optionsPath = getOptionsPath();
    File.saveString(optionsString, optionsPath);
}
