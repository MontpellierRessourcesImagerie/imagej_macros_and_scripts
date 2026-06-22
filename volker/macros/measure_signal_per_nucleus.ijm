NUCLEI_CHANNEL = 4;
SIGNAL_CHANNEL = 2;
SIGMA = 4;
THRESHOLDING_METHOD = "Default dark";
MIN_VOLUME = 120000;
ROLLING_BALL_RADIUS = 10;
SIGNAL_THRESHOLD = 10;

analyzeImage();


function analyzeImage() {
    segmentNuclei();
    measureSignal();
}

function segmentNuclei() {
    inputImageID = getImageID();
    run("Duplicate...", "title=nuclei duplicate channels=" + NUCLEI_CHANNEL);
    selectImage(inputImageID);
    run("Duplicate...", "title=signal duplicate channels=" + SIGNAL_CHANNEL);
    selectImage("nuclei");
    run("Gaussian Blur...", "sigma="+SIGMA+" stack");
    setAutoThreshold(THRESHOLDING_METHOD + " stack");
//    run("Threshold...");
//    waitForUser;
    run("Convert to Mask", "background=Dark black");
    run("Dilate (3D)", "iso=255");
    run("Dilate (3D)", "iso=255");
    run("Fill Holes", "stack");
    run("Distance Transform Watershed 3D", "distances=[Borgefors (3,4,5)] output=[16 bits] normalize dynamic=6 connectivity=26");
    run("Remove Border Labels", "left right top bottom");
    run("Label Size Filtering", "operation=Greater_Than size="+MIN_VOLUME);
    rename("labels");
}
 
 
function measureSignal() {
    print("measure signal");
    selectImage("signal");
    run("Duplicate...", "title=signal_seg duplicate");
    run("Subtract Background...", "rolling="+ROLLING_BALL_RADIUS+" stack");
    run("Duplicate...", "title=signal_mask duplicate");
    setThreshold(SIGNAL_THRESHOLD, 65535);
    run("Convert to Mask", "background=Dark black");
    run("Divide...", "value=255 stack");
    imageCalculator("Multiply create stack", "signal_mask","labels");
    rename("signal_labels")
    run("Intensity Measurements 2D/3D", "input=signal_seg labels=[signal_labels] mean stddev max min median mode skewness kurtosis numberofvoxels volume");
}

