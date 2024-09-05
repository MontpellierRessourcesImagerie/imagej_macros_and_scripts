PIXEL_SIZE = 0.1031746;  // pixel size in micro-meter
NUCLEI_CHANNEL = 1;
SIGNAL_CHANNEL = 4;
SIGMA = 2;
EXT = ".czi";
CLOSE_RADIUS = 4;
SCALE_DOWN_FACTOR = 8;

directory = getDir("Select the input folder!");
files = getFileList(directory);
File.makeDirectory(directory + "control-images");
run("Clear Results");
fileNames = newArray(0);
intensities = newArray(0);
cells = newArray(0);
for (i = 0; i < files.length; i++) {
    showProgress(i+1, files.length);
    file = files[i];
    if (!endsWith(file, EXT)) continue;
    run("Bio-Formats", "open=[" + directory + file + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
    values = measureIntensityInImage();
    nrOfCells = values[0];
    intensityPerCell = values[1];
    outfilename = replace(file, EXT, ".tif");
    save(directory + "/" + "control-images/" + outfilename);
    fileNames = Array.concat(fileNames, file);
    intensities = Array.concat(intensities, intensityPerCell);
    cells = Array.concat(cells, nrOfCells);
    close("*");
}
Table.create("measurements");
Table.setColumn("file", fileNames);
Table.setColumn("number of cells", cells);
Table.setColumn("intensity per cell", intensities);
Table.save(directory + "measurements.xls", "measurements");


function measureIntensityInImage() {
    run("Select None");
    width = getWidth();
    height = getHeight();
    roiManager("reset");
    inputImageID = getImageID();
    run("Set Scale...", "distance=1 known=0.1031746 unit=µm");
    run("Duplicate...", "duplicate channels=" + NUCLEI_CHANNEL);
    nucleiID = getImageID();
    nucleiTitle = getTitle();
    run("Gaussian Blur...", "sigma=" + SIGMA);
    setAutoThreshold("Huang dark 16-bit no-reset");
    run("Convert to Mask");

//    run("Options...", "iterations="+CLOSE_RADIUS+" count=1 do=Close");
    run("Fill Holes");
//    run("Scale...", "x=" + 1/SCALE_DOWN_FACTOR + " y=" + 1/SCALE_DOWN_FACTOR + " interpolation=Bilinear average create");
//    run("Scale...", "width="+width+" height="+height+" interpolation=Bilinear average create");
//    setThreshold(1, 255);
//    run("Convert to Mask");
//    run("Options...", "iterations=4 count=1 do=Erode");
//    run("Options...", "iterations=1 count=1 do=Nothing");   
    run("Watershed");
    run("Analyze Particles...", "size=10-Infinity show=Masks add");
    nrOfCells = roiManager("count");
    
    selectImage(inputImageID);
    run("Duplicate...", "duplicate channels=" + SIGNAL_CHANNEL);
    signalID = getImageID();
    signalTitle = getTitle();
    setAutoThreshold("Yen dark 16-bit no-reset");
    run("Create Selection");
    run("Make Inverse");    
    meanBackground = getValue("Mean");
    run("Select None");
    run("Gaussian Blur...", "sigma=" + SIGMA);
    run("Subtract...", "value=" + meanBackground);
    
    selectImage(nucleiID);
    run("Create Selection");
    run("Make Inverse");
    selectImage(signalID);
    run("Restore Selection");
    intensityCytoplasm = getValue("IntDen");
    run("HiLo");
    intensityPerCell = intensityCytoplasm / nrOfCells;
    run("Restore Selection");
    Overlay.addSelection();
    return newArray(nrOfCells, intensityPerCell);
}
