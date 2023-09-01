var PROCESS_ALL = true
var USE_STACK_HISTOGRAM = true


if (!isKeyDown("alt")) showDialog();
execute();


function showDialog() {
    Dialog.create("normalize image options");
    Dialog.addCheckbox("Process all " + nSlices + " slices", PROCESS_ALL);
    Dialog.addCheckbox("Use stack histogram", USE_STACK_HISTOGRAM);
    Dialog.show();
    PROCESS_ALL = Dialog.getCheckbox();
    USE_STACK_HISTOGRAM = Dialog.getCheckbox();
}


function execute() {
    run("32-bit");
    standardizeImage();
    run("Enhance Contrast", "saturated=0.35");
}


function standardizeImage() {
    width = getWidth();
    height = getHeight();
    
    if (nSlices == 1) {
        mean = getValue("Mean");
        stdDev = getValue("StdDev");
        standardizeSlice(mean, stdDev, width, height)        
        return;
    }
    
    Stack.getStatistics(voxelCount, mean, min, max, stdDev);    
    
    if (!PROCESS_ALL) {
        if (!USE_STACK_HISTOGRAM) {
            mean = getValue("Mean");
            stdDev = getValue("StdDev");
        }
        standardizeSlice(mean, stdDev, width, height);
        return;
    }
    
    Stack.getPosition(currentChannel, currentSlice, currentFrame);
    setBatchMode("hide");
    for (slice = 1; slice <= nSlices; slice++) {
        showProgress(slice, nSlices);
        Stack.setSlice(slice);
        if (!USE_STACK_HISTOGRAM) {
            mean = getValue("Mean");
            stdDev = getValue("StdDev");
        }
        standardizeSlice(mean, stdDev, width, height);
    }
    setBatchMode("show");
    Stack.setSlice(currentSlice);
}
    
    
function standardizeSlice(mean, stdDev, width, height) {
    for (x = 0; x < width; x++) {
        for (y = 0; y < height; y++) {
            value =getPixel(x, y);
            zValue = (value - mean) / stdDev;
            setPixel(x, y, zValue);    
        }
    }
}    
 