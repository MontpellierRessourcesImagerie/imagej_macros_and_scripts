// ================================================
// EdU/DAPI per-Z Counter — v3.4 (Fiji/ImageJ macro)
// ================================================
requires("1.53");

// ---------- PARAMÈTRES UTILISATEUR ----------
eduChannel = 1;          // EdU (rouge) — index 1-based
dapiChannel = 2;         // DAPI (bleu) — index 1-based
minNucleusArea_um2 = 20;   // aire noyau min (µm²)
maxNucleusArea_um2 = 5000; // aire noyau max (µm²)
rollingBallRadius_px = 50; // soustraction de fond
gaussSigma_px = 1.0;       // lissage Gaussien
useLocalThreshold = false; // false = Otsu par tranche ; true = Phansalkar local
localRadius = 15;          // rayon Phansalkar si local
doWatershed = true;        // appliquer Watershed
morphoErodeDilate = true;  // Erode + Dilate (1 itération)
saveMasks = true;          // sauvegarder DAPI/EdU masks par Z (TIFF)
// ---------------------------------------------

// ====== Utils ======
function ensureCalibrationPxPerUm() {
    getVoxelSize(vw, vh, vz, unit);
    if (vw<=0 || vh<=0) { vw = 1.0; vh = 1.0; }  // fallback
    return newArray(vw, vh); // pixel width/height en µm
}
function areaPxFromUm2(um2, pw_um, ph_um){
    return um2 / (pw_um * ph_um);
}

// Duplique **la tranche courante uniquement** -> image 2D (zéro popup)
function dupSlice2D(stackId, titleSuffix){
    selectImage(stackId);
    run("Duplicate...", "title="+titleSuffix); // pas de mot-clé "duplicate"
    getDimensions(w_, h_, c_, s_, f_);
    if (c_>1 || s_>1 || f_>1) {
        current = getSliceNumber();
        run("Make Substack...", "slices="+current);
    }
    return getImageID();
}

function binarize2D(imgId){
    selectImage(imgId);
    run("Subtract Background...", "rolling="+rollingBallRadius_px);
    run("Gaussian Blur...", "sigma="+gaussSigma_px);
    if (useLocalThreshold) {
        run("Auto Local Threshold", "method=Phansalkar radius="+localRadius+" parameter_1=0 parameter_2=0 white");
    } else {
        run("Make Binary", "method=Otsu background=Dark");
    }
    if (morphoErodeDilate) {
        run("Options...", "iterations=1 count=1 black do=Erode");
        run("Options...", "iterations=1 count=1 black do=Dilate");
    }
}

function countNucleiOn2D(dapiMask2D, minPx, maxPx){
    selectImage(dapiMask2D);
    if (doWatershed) run("Watershed");
    run("Analyze Particles...", "size="+minPx+"-"+maxPx+" show=Nothing clear include add");
    return roiManager("count");
}

function countEdUPosOn2D(eduGray2D){
    selectImage(eduGray2D);
    setAutoThreshold("Otsu dark");
    getThreshold(lower, upper);
    n = roiManager("count");
    pos = 0;
    for (r=0; r<n; r++){
        roiManager("select", r);
        getStatistics(area, mean);
        if (!isNaN(mean) && mean >= lower) pos++;
    }
    return pos;
}

// ====== MAIN ======
inputDir = getDirectory("Choose INPUT folder");
if (inputDir=="") exit("No input folder chosen.");
outputDir = getDirectory("Choose OUTPUT folder");
if (outputDir=="") exit("No output folder chosen.");

setBatchMode(true);
list = getFileList(inputDir);

// Summary global (toutes images)
summaryAll = outputDir + "summary_EdU_DAPI_perZ_all.csv";
if (!File.exists(summaryAll)) {
    File.saveString("Image,Z,Total_Nuclei,EdU_Positive,EdU_Percent\n", summaryAll);
}

for (i=0; i<list.length; i++) {
    path = inputDir + list[i];
    if (File.isDirectory(path)) continue;
    name = list[i];
    lower = toLowerCase(name);
    if (!endsWith(lower, ".tif") && !endsWith(lower, ".tiff") && !endsWith(lower, ".czi")
        && !endsWith(lower, ".lif") && !endsWith(lower, ".nd2") && !endsWith(lower, ".lsm")
        && !endsWith(lower, ".png") && !endsWith(lower, ".jpg") && !endsWith(lower, ".jpeg")) continue;

    print("Processing: " + name);
    open(path);
    title = getTitle();
    getDimensions(w, h, c, slices, frames);

    // Dupliquer canaux (toutes Z/T)
    selectWindow(title);
    run("Duplicate...", "duplicate channels="+eduChannel+" z=1-"+slices+" t=1-"+frames);
    rename("__EDU"); idEDU = getImageID();

    selectWindow(title);
    run("Duplicate...", "duplicate channels="+dapiChannel+" z=1-"+slices+" t=1-"+frames);
    rename("__DAPI"); idDAPI = getImageID();

    // Calibration & bornes aire (px)
    cal = ensureCalibrationPxPerUm();
    pw_um = cal[0]; ph_um = cal[1];
    minPx = areaPxFromUm2(minNucleusArea_um2, pw_um, ph_um);
    maxPx = areaPxFromUm2(maxNucleusArea_um2, pw_um, ph_um);

    // CSV par image
    outCSV = outputDir + replace(name, ".", "_perZ.csv");
    File.saveString("Image,Z,Total_Nuclei,EdU_Positive,EdU_Percent\n", outCSV);

    // ---- Boucle par Z ----
    for (z=1; z<=slices; z++){
        // DAPI -> masque & ROIs
        selectImage(idDAPI); Stack.setSlice(z);
        dapi2D = dupSlice2D(idDAPI, "__DAPI_z"+z);
        binarize2D(dapi2D);
        roiManager("Reset");
        nNuclei = countNucleiOn2D(dapi2D, minPx, maxPx);

        // EdU (gris) sur le même Z
        selectImage(idEDU); Stack.setSlice(z);
        edu2D = dupSlice2D(idEDU, "__EDU_z"+z);

        if (nNuclei > 0) {
            edupos = countEdUPosOn2D(edu2D);
            edupct = 100.0 * edupos / nNuclei;
        } else {
            edupos = 0;
            edupct = 0;
        }

        // Sauvegardes masques (facultatives)
        if (saveMasks){
            selectImage(dapi2D);
            saveAs("Tiff", outputDir + replace(name, ".", "_DAPImask_z"+z+"."));
            edu2D_bin = dupSlice2D(idEDU, "__EDUbin_z"+z);
            binarize2D(edu2D_bin);
            saveAs("Tiff", outputDir + replace(name, ".", "_EDUmask_z"+z+"."));
            selectImage(edu2D_bin); close();
        }

        // Append lignes
        line = name+","+z+","+nNuclei+","+edupos+","+d2s(edupct,2)+"\n";
        File.append(line, outCSV);
        File.append(line, summaryAll);

        // Nettoyage 2D
        roiManager("Reset");
        selectImage(dapi2D); close();
        selectImage(edu2D); close();
    }

    // Fermer stacks & image source
    selectImage(idEDU); close();
    selectImage(idDAPI); close();
    selectWindow(title); close();

    print("Saved: " + outCSV);
}

setBatchMode(false);
print("DONE. Global summary: " + summaryAll);
