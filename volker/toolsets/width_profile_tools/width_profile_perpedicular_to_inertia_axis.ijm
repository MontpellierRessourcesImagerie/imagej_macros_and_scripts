SAMPLE_WIDTH = 5;
COLORS = newArray("black", "blue", "cyan", "darkGray", "gray", "green", "lightGray", "magenta", "orange", "pink", "red", "white", "yellow");
LINE_COLOR = "red";
START_OFFSET = 5;
END_OFFSET = 5;

Dialog.create("Options of width profile to inertia axis");
Dialog.addNumber("Sample width: ", SAMPLE_WIDTH);
Dialog.addNumber("Left offset: ", START_OFFSET);
Dialog.addNumber("Right offset: ", END_OFFSET);
Dialog.addChoice("Line color: ", COLORS, LINE_COLOR);
Dialog.show();
SAMPLE_WIDTH = Dialog.getNumber();
START_OFFSET = Dialog.getNumber();
END_OFFSET = Dialog.getNumber();
LINE_COLOR = Dialog.getChoice();

toUnscaled(START_OFFSET);
toUnscaled(END_OFFSET);
getVoxelSize(pixelWidth, pixelHeight, voxelDepth, unit);
Image.removeScale();
Overlay.remove;
width = getWidth();
height = getHeight();
newWidth = width;
newHeight = height;
setThreshold(1, 65535);
run("Analyze Particles...", "display clear");
angle = Table.get("Angle", 0);
rotated = false;
if (round(angle)%180 != 0) {
    run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear fill enlarge");
    rotated = true;
    newWidth = getWidth();
    newHeight = getHeight();
}
setThreshold(1, 255);
setOption("BlackBackground", true);
run("Convert to Mask");
run("Create Selection");
run("To Bounding Box");
bbx = getValue("BX") + START_OFFSET;
bby = getValue("BY");
bbWidth = getValue("Width") - START_OFFSET - END_OFFSET;
bbHeight = getValue("Height");
SAMPLES = round(bbWidth / SAMPLE_WIDTH);
for (i = 0; i < SAMPLES; i++) {
    x = bbx + (i * SAMPLE_WIDTH);
    lastColor = 0;
    changes = newArray(0);
    for (y = bby-1; y < bby + bbHeight+1; y++) {
        v = getPixel(x, y);
        if (v == 255 && lastColor == 0) {
            changes = Array.concat(changes, y);
        }
        if (v == 0 && lastColor == 255) {
            changes = Array.concat(changes, y-1);
            
        }
        lastColor = v;
    }
    changesLength = changes.length;
    if (changesLength==0 || changesLength % 2 == 1) {
        print("anomaly at x = " + x);
        print("number of contrast changes: " + changesLength);
        print("positions of coordinate changes: ");
        Array.print(changes);
        continue;
    }
    maxDist = 0;
    maxIndex = 0;
    for (c = 0; c < changesLength; c = c + 2) {
        dist = changes[c+1] - changes[c];
        if (dist > maxDist) {
            maxIndex = c;
            maxDist = dist;
        }
    }
    makeLine(x, changes[maxIndex]-0.5, x, changes[maxIndex+1]+0.5);
    Overlay.addSelection(LINE_COLOR);
}
run("Select None");
run("Set Scale...", "distance=1 known="+pixelWidth+" unit="+unit);
run("Properties...", "pixel_width=" + pixelWidth + " pixel_height=" + pixelHeight + " voxelDepth=" + voxelDepth + " unit" + unit); 
if (rotated) {
    run("Rotate... ", "angle="+(-angle)+" grid=1 interpolation=Bilinear fill enlarge");
    run("Canvas Size...", "width="+width+" height="+height+" position=Center");
}

