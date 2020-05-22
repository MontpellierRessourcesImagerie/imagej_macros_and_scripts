_CHANNEL = 1;
_SIGMA = 33;
_THRESHOLDING_METHOD = "IsoData";

inputImageID = getImageID();
run("Duplicate...", "duplicate channels="+_CHANNEL+"-"+_CHANNEL);
run("Gaussian Blur...", "sigma="+_SIGMA);
setAutoThreshold(_THRESHOLDING_METHOD + " dark");
run("Convert to Mask");
run("Watershed");
// run("Analyze Particles...", "  show=Masks exclude in_situ");
