Image.removeScale;

inputImageID = getImageID();
Overlay.activateSelection(0);
width = getValue("Width");
height = getValue("Height");
size = minOf(width, height);
iterations = floor(size / 3)
run("Create Mask");
for (i = 0; i < iterations; i++) {
    selectImage("Mask");
    run("Find Edges");    
    run("Create Selection");
    selectImage(inputImageID);
    run("Restore Selection");
    run("Measure");
    selectImage("Mask");
    run("Select None");
    run("Fill Holes");
    run("Erode");
    run("Erode");
    //waitForUser("continue!");
}