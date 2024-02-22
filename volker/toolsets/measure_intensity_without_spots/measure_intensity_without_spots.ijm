var NUCLEI_CHANNEL = 1
var SIGNAL_CHANNEL = 2;
var BACKGROUND_BLUR_SIGMA = 30;
var TOP_HAT_RADIUS = 1;

inputImageID = getImageID();
run("Duplicate...", "duplicate channels=" + NUCLEI_CHANNEL);
nucleiImageID = getImageID();
run("Duplicate...", " ");
backgroundImageID = getImageID();
run("Gaussian Blur...", "sigma=" + BACKGROUND_BLUR_SIGMA);
imageCalculator("Subtract create", nucleiImageID, backgroundImageID);
selectImage(nucleiImageID);
close();
selectImage(backgroundImageID);
close();
nucleiImageID = getImageID();
setAutoThreshold("Huang dark");
setOption("BlackBackground", true);
run("Convert to Mask");
selectImage(inputImageID);
run("Duplicate...", "duplicate channels=" + SIGNAL_CHANNEL);
signalImageID = getImageID();
run("Morphological Filters", "operation=[White Top Hat] element=Disk radius=" + TOP_HAT_RADIUS);
setAutoThreshold("Yen dark");
run("Convert to Mask");
spotImageID = getImageID();
selectImage(signalImageID);
close();
imageCalculator("Subtract create", nucleiImageID, spotImageID);
selectImage(nucleiImageID);
close()
selectImage(spotImageID);
close();
maskImageID = getImageID();

