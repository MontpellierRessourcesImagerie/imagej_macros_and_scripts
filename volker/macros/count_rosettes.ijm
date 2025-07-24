CHANNEL = 1;
SIGMA = 10;
PROEMINENCE = 0;
TABLE = "Number of Rosettes";

folder = getDir("Select the input folder!");
outFolder = getDir("Select_the output folder!");
files = getFileList(folder);

for (i = 0; i < files.length; i++) {
    file = files[i];
    run("Bio-Formats", "open=["+folder + file+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    makeRectangle(408, 393, 1374, 1353);
    inputImageID = getImageID();
    title = getTitle();
    if (!isOpen(TABLE)) {
        Table.create(TABLE);
    }
    run("Clear Results");
    run("Duplicate...", "duplicate channels="+CHANNEL);
    run("Invert");
    run("FeatureJ Laplacian", "compute smoothing="+SIGMA);
    run("Find Maxima...", "prominence="+PROEMINENCE+" exclude light output=[Point Selection]");
    run("Measure");
    numberOfRosettes = nResults;
    row = Table.size(TABLE);
    Table.set("image", row, title, TABLE);
    Table.set("number", row, numberOfRosettes, TABLE);
    close();
    run("Restore Selection");
    selectImage(inputImageID);
    close();
    run("Invert");
    parts = split(file, ".");
    filename = parts[0];
    saveAs("tiff", outFolder + filename + ".tif");
    close();
}
