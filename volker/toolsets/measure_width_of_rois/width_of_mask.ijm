var XDIR = newArray(-1, 0, 1, -1, 1, -1, 0, 1);
var YDIR = newArray(-1, -1, -1, 0, 0, 1, 1, 1);
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
Roi.getCoordinates(xpoints, ypoints);
Overlay.addSelection;

middleIndex = floor(xpoints.length / 2);

function measureWidthAt(index, xpoints, ypoints) {
    
    
    
}
