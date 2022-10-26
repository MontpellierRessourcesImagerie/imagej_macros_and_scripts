var XDIR = newArray(-1, 0, 1, -1, 1, -1, 0, 1);
var YDIR = newArray(-1, -1, -1, 0, 0, 1, 1, 1);
var RADIUS = 1;
SAMPLES = 101;
width = getWidth();
height = getHeight();
roiManager("reset");
Overlay.remove;
maskID = getImageID();
setOption("BlackBackground", true);
run("Duplicate...", " ");
skeletonID = getImageID();
run("Skeletonize");
for (y = 0; y < height; y++) {
    for (x = 0; x < width; x++) {
        p = getPixel(x, y);
        if (p > 0) break;
    }   
    if (p > 0) break; 
}
numberOfPoints = getValue("RawIntDen") / 255;
xpoints = newArray(numberOfPoints);
ypoints = newArray(numberOfPoints);
neighbors = newArray(8);
for (i = 0; i < numberOfPoints; i++) {
    xpoints[i] = x;
    ypoints[i] = y;
    setPixel(x, y, 128);
    found = false;
    pn = 0;
    for (ix = 0; ix < 8; ix++) {
        if (found) break;
        for (iy = 0; iy < 8; iy++) {
            xn = x + XDIR[ix];
            yn = y + YDIR[iy];
            pn = getPixel(xn, yn);
            if (pn == 255) {
                found = true;
                break;
            }
        }   
    }
    if (pn == 255) {
        x = xn;
        y = yn; 
    } else {
        xpoints[i+1] = xn;
        ypoints[i+1] = yn;    
        break;
    }
}
close();
makeSelection("freeline", xpoints, ypoints);
run("Interpolate", "interval=1 smooth adjust");
Roi.getCoordinates(xpoints, ypoints);
Overlay.addSelection;

middleIndex = floor(xpoints.length / 2);

stepWidth = floor(middleIndex / ((SAMPLES - 1) / 2 ));
print(stepWidth);



for (i = middleIndex; i > 0; i = i - stepWidth) {
    if ((i-RADIUS) > -1 && (i+RADIUS)<xpoints.length) {
        makeLine(xpoints[i-RADIUS], ypoints[i-RADIUS], xpoints[i+RADIUS], ypoints[i+RADIUS]);
        Roi.getCoordinates(xSampleLine, ySampleLine);
        rotated = rotateLineSegmentBy90(xSampleLine[0], ySampleLine[0], xSampleLine[xSampleLine.length-1], ySampleLine[xSampleLine.length-1]);
        makeLine(rotated[0], rotated[1], rotated[2], rotated[3]);
        Overlay.addSelection;
    }
}

for (i = middleIndex; i < xpoints.length; i = i + stepWidth) {
    if ((i-RADIUS) > -1 && (i+RADIUS)<xpoints.length) {
        makeLine(xpoints[i-RADIUS], ypoints[i-RADIUS], xpoints[i+RADIUS], ypoints[i+RADIUS]);
        Roi.getCoordinates(xSampleLine, ySampleLine);
        rotated = rotateLineSegmentBy90(xSampleLine[0], ySampleLine[0], xSampleLine[xSampleLine.length-1], ySampleLine[xSampleLine.length-1]);
        makeLine(rotated[0], rotated[1], rotated[2], rotated[3]);
        Overlay.addSelection;
    }    
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
    x1 = -ytemp; 
    y1 = xtemp; 
    
    xtemp = x2; 
    ytemp = y2;
    x2 = -ytemp; 
    y2 = xtemp; 
    
    //move the center point back to where it was
    x1 = x1 + cx; 
    y1 = y1 + cy;
    x2 = x2 + cx; 
    y2 = y2 + cy;
    
    res = newArray(x1, y1, x2, y2);
    return res;
}


