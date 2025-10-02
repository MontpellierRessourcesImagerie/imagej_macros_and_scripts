CHANNEL = 3;
SIGMA = 44;
PROEMINENCE = 0.001;
TABLE = "Number of Rosettes";

folder = getDir("Select the input folder!");
outFolder = getDir("Select_the output folder!");
files = getFileList(folder);

print("\\Clear");
setBatchMode(true);
for (i = 0; i < files.length; i++) {
    print("\\Update0:Processing image " + (i+1) + " of " + files.length);
    file = files[i];
    open(folder + file);
    //run("Bio-Formats", "open=["+folder + file+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    inputImageID = getImageID();
    title = getTitle();
    if (!isOpen(TABLE)) {
        Table.create(TABLE);
    }
    run("Clear Results");
    run("Duplicate...", "duplicate channels="+CHANNEL);
    inputImageCroppedID = getImageID();
    width = getWidth();
    height = getHeight();
    getPixelSize(unit, pixelWidth, pixelHeight);
    area = width * height * pixelWidth * pixelHeight;
    run("Duplicate...", "duplicate channels="+CHANNEL);
    selectImage(inputImageID);
    close();
    run("Invert", "stack");
    run("FeatureJ Laplacian", "compute smoothing="+SIGMA);
    run("Find Maxima...", "prominence="+PROEMINENCE+" exclude light output=[Point Selection]");
    run("Measure");
    numberOfRosettes = nResults;
    row = Table.size(TABLE);
    Table.set("image", row, title, TABLE);
    Table.set("number", row, numberOfRosettes, TABLE);
    Table.set("area", row, area, TABLE);
    Table.set("density", row, numberOfRosettes / area, TABLE); 
    close();
    close();
    run("Restore Selection");
    selectImage(inputImageCroppedID);
    run("Invert", "stack");
    parts = split(file, ".");
    filename = parts[0];
    saveAs("tiff", outFolder + filename + ".tif");
    close();
}
setBatchMode("exit and display");
print("Processing finished.");
