// ===== Batch EdU/DAPI Counter (Fiji/ImageJ macro) =====
requires("1.53");

// ===== USER PARAMETERS =====
minNucleusArea_um2 = 20;
maxNucleusArea_um2 = 5000;
rollingBallRadius_px = 50;
gaussSigma_px = 1.0;
pixelWidth_um = NaN;
pixelHeight_um = NaN;
saveMasks = true; // sauvegarde masques et overlay
// ===== END USER PARAMETERS =====

function ensureCalibration() {
    getPixelSize(unit, pw, ph, pd);
    if (isNaN(pixelWidth_um)) pixelWidth_um = pw;
    if (isNaN(pixelHeight_um)) pixelHeight_um = ph;
    if (pixelWidth_um==0 || pixelHeight_um==0) {
        pixelWidth_um = 1.0;
        pixelHeight_um = 1.0;
    }
}

function areaPxFromUm2(um2){
    return um2 / (pixelWidth_um*pixelHeight_um);
}

function autoThresholdDuplicate(id, method) {
    selectImage(id);
    run("Duplicate...", "title=__dup duplicate");
    run("Subtract Background...", "rolling="+rollingBallRadius_px);
    run("Gaussian Blur...", "sigma="+gaussSigma_px);
    setAutoThreshold(method+" dark");
    run("Convert to Mask");
    run("Options...", "iterations=1 count=1 black do=Erode");
    run("Options...", "iterations=1 count=1 black do=Dilate");
    return getImageID();
}

function labelNucleiFromDAPI(dapiId) {
    selectImage(dapiId);
    run("Watershed");
    ensureCalibration();
    minAreaPx = areaPxFromUm2(minNucleusArea_um2);
    maxAreaPx = areaPxFromUm2(maxNucleusArea_um2);
    run("Analyze Particles...", "size="+minAreaPx+"-"+maxAreaPx+" show=Outlines display exclude add");
}

// ===== MAIN =====
inputDir = getDirectory("Choose INPUT folder");
if (inputDir=="") exit("No input chosen.");
outputDir = getDirectory("Choose OUTPUT folder");
if (outputDir=="") exit("No output chosen.");

list = getFileList(inputDir);
summaryPath = outputDir + "summary_edu_dapi.csv";
File.saveString("Image,Total_Nuclei,EdU_Positive,EdU_Percent\n", summaryPath);

for (i=0; i<list.length; i++) {
    path = inputDir + list[i];
    if (File.isDirectory(path)) continue;
    if (!endsWith(list[i], ".tif") && !endsWith(list[i], ".tiff") && !endsWith(list[i], ".czi")
        && !endsWith(list[i], ".lif") && !endsWith(list[i], ".nd2") && !endsWith(list[i], ".lsm")
        && !endsWith(list[i], ".png") && !endsWith(list[i], ".jpg") && !endsWith(list[i], ".jpeg")) continue;

    print("Processing: " + list[i]);
    open(path);
    title = getTitle();
    run("Enhance Contrast", "saturated=0.35");

    // === Récupérer dimensions (C,Z,T) ===
    getDimensions(w, h, c, slices, frames);

    // === Dupliquer EdU (canal 1, toutes tranches Z/T) ===
    selectWindow(title);
    run("Duplicate...", "duplicate channels=1 z=1-"+slices+" t=1-"+frames);
    rename("__edu");
    idEdu = getImageID();

    // === Dupliquer DAPI (canal 2, toutes tranches Z/T) ===
    selectWindow(title);
    run("Duplicate...", "duplicate channels=2 z=1-"+slices+" t=1-"+frames);
    rename("__dapiMask");
    idDapi = getImageID();

    // === Construction des masques ===
    eduMaskId = autoThresholdDuplicate(idEdu, "Otsu");
    dapiPreMaskId = autoThresholdDuplicate(idDapi, "Otsu");

    // Label nuclei from DAPI
    labelNucleiFromDAPI(dapiPreMaskId);

    // Mesures EdU
    selectImage(idEdu);
    roiCount = roiManager("count");
    if (roiCount==0) {
        totalNuclei = 0; eduPos = 0; eduPct = 0;
    } else {
        run("Duplicate...", "title=__edu_tmp duplicate");
        setAutoThreshold("Otsu dark");
        getThreshold(lower, upper);
        run("Set Measurements...", "mean area redirect=None decimal=3");

        totalNuclei = roiCount;
        eduPos = 0;
        for (r=0; r<roiCount; r++) {
            roiManager("select", r);
            getStatistics(area, mean);
            if (!isNaN(mean) && mean >= lower) eduPos++;
        }
        if (totalNuclei > 0) eduPct = 100.0 * eduPos / totalNuclei;
        else eduPct = 0;
    }

    // Save per-image CSV
    csvPath = outputDir + replace(list[i], ".tif", "_results.csv");
    csvPath = replace(csvPath, ".tiff", "_results.csv");
    csvPath = replace(csvPath, ".czi", "_results.csv");
    csvPath = replace(csvPath, ".lif", "_results.csv");
    csvPath = replace(csvPath, ".nd2", "_results.csv");
    csvPath = replace(csvPath, ".lsm", "_results.csv");
    csvPath = replace(csvPath, ".png", "_results.csv");
    csvPath = replace(csvPath, ".jpg", "_results.csv");
    csvPath = replace(csvPath, ".jpeg", "_results.csv");

    header = "ROI,Area_px,Mean_EdU\n";
    content = header;
    for (r=0; r<roiCount; r++) {
        roiManager("select", r);
        getStatistics(area, mean);
        content += (r+1) + "," + d2s(area,0) + "," + d2s(mean,3) + "\n";
    }
    File.saveString(content, csvPath);

    // Append to summary
    File.append(list[i] + "," + totalNuclei + "," + eduPos + "," + d2s(eduPct,2) + "\n", summaryPath);

    // Sauvegarde des masques
    if (saveMasks) {
        selectImage(dapiPreMaskId); saveAs("Tiff", outputDir + replace(list[i], ".", "_dapiMask."));
        selectImage(eduMaskId); saveAs("Tiff", outputDir + replace(list[i], ".", "_eduMask."));
        selectImage(idDapi);
        run("Duplicate...", "title=__overlay duplicate");
        roiManager("Show All with labels");
        saveAs("Tiff", outputDir + replace(list[i], ".", "_overlay.tif"));
        close("__overlay");
    }

    roiManager("Reset");
    while (nImages>0) { selectImage(nImages); close(); }
}

print("Done. Summary saved to: " + summaryPath);
