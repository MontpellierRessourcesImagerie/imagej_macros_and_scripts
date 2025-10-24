var SUFFIX = ".tif"
var SIGMA = 5;
var THRESHOLDING_METHOD_CHANNEL1 = "Moments"
var THRESHOLDING_METHOD_CHANNEL2 = "Yen"

dir = getDir("Select the input folder!");
files = getFileList(dir);
run("Clear Results");
roiManager("reset");

for (i = 0; i < files.length; i++) {
    file = files[i];
    if (!endsWith(file, SUFFIX)) continue;
    path = dir + files[i];
    open(path);
    colocImage();
}


function colocImage() {
    id = getImageID();
    originalName = getTitle();
    nrOfRois = Overlay.size;
    if (nrOfRois > 0) {
        run("To ROI Manager");
    }
    run("Select None");
    Overlay.remove;
    run("Duplicate...", "duplicate frames=1");
    selectImage(id);
    close();
    inputImageName1 = getTitle();
    run("Duplicate...", "duplicate");
    inputImageName2 = getTitle();
    run("Gaussian Blur...", "sigma="+SIGMA+" stack");
    imageCalculator("Subtract create stack", inputImageName1, inputImageName2);
    options = "channel_a=1 channel_b=2 threshold_for_channel_a="+THRESHOLDING_METHOD_CHANNEL1+" threshold_for_channel_b="+THRESHOLDING_METHOD_CHANNEL2+" manual_threshold_a=0 manual_threshold_b=0 get_pearsons get_manders get_overlap get_fluorogram show_costes_plot costes_block_size=5 costes_number_of_shuffling=100";
    print(options);
    run("BIOP JACoP", options);
    nrOfControlImages = 1;
    if (nrOfRois > 1) nrOfControlImages = nrOfRois;
    outDir = File.getDirectory(path) + "/export/";
    name = File.nameWithoutExtension;
    File.makeDirectory(outDir);
    for (i = 0; i < nrOfControlImages; i++) {
        save(outDir + name + "_roi"+ (i+1) + ".png");
        close();
    }
    close("*");
}

saveAs("results", dir + "/export/"  + "results.csv");
