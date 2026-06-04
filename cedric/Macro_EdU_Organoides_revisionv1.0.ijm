// =====================================================
// EdU/DAPI per-Z Counter — v1.0 + QA Overlay (Fiji macro)
// (Phansalkar local, anti-bruit renforcé, skip slices sombres)
// =====================================================
requires("1.53");

// ---------- PARAMÈTRES UTILISATEUR ----------
eduChannel = 1;            // EdU (rouge) — index 1-based
dapiChannel = 2;           // DAPI (bleu) — index 1-based

useLocalThreshold   = true;   // << demandé
rollingBallRadius_px= 120;    // << demandé
gaussSigma_px       = 1.2;    // << demandé
minNucleusArea_um2  = 40;     // << demandé
maxNucleusArea_um2  = 5000;

localRadius         = 15;     // Phansalkar: 11–25 selon taille noyaux
doWatershed         = true;   // séparer noyaux collés
saveMasks           = true;   // sauver masques DAPI/EdU par Z
saveOverlays        = true;   // 🚀 exporter un overlay QC par Z

// Skip automatique des tranches très sombres (optionnel)
enableSkipDarkSlices = true;
skipMeanThreshold    = 3;     // intensité moyenne (0–255) en-dessous de laquelle on skip
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
    run("Duplicate...", "title="+titleSuffix); // surtout pas "duplicate"
    getDimensions(w_, h_, c_, s_, f_);
    if (c_>1 || s_>1 || f_>1) {
        current = getSliceNumber();
        run("Make Substack...", "slices="+current);
    }
    return getImageID();
}

// ---- Anti-bruit + seuillage (Phansalkar local ou Otsu) ----
function binarize2D(imgId){
    selectImage(imgId);

    // 1) Nettoyage/égalisation (ok en 16-bit)
    run("Subtract Background...", "rolling="+rollingBallRadius_px);
    run("Median...", "radius=1");
    run("Enhance Contrast", "saturated=0.35 normalize");

    // 2) Passer en 8-bit pour les étapes qui l'exigent
    run("8-bit");

    // 3) Seuillage
    if (useLocalThreshold) {
        run("Auto Local Threshold", "method=Phansalkar radius="+localRadius+" parameter_1=0 parameter_2=0 white");
    } else {
        run("Make Binary", "method=Otsu background=Dark");
    }

    // 4) Nettoyage morphologique / anti-débris
    run("Options...", "iterations=1 count=1 black do=Open");
    run("Remove Outliers...", "radius=3 threshold=50 which=Bright");
}

function countNucleiOn2D(dapiMask2D, minPx, maxPx){
    selectImage(dapiMask2D);
    if (doWatershed) run("Watershed");
    run("Analyze Particles...", "size="+minPx+"-"+maxPx+" show=Nothing clear include add");
    return roiManager("count");
}

function countEdUPosOn2D(eduGray2D){
    selectImage(eduGray2D);
    setAutoThreshold("Otsu dark");   // décision simple et robuste
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

// === Overlay QC couleur par Z — compatible Fiji 1.54 ===
// Fond: DAPI_z (contraste normalisé, LUT bleue inchangée)
// Contours overlay: Rouge = EdU+, Vert = EdU− puis Flatten
function saveOverlayQA_Color(name, z, idDAPI, idEDU, outputDir) {
    // 1) Support : DAPI_z → contraste + RGB
    selectImage(idDAPI); Stack.setSlice(z);
    run("Duplicate...", "title=QA_overlay_z"+z);
    idOverlay = getImageID();
    run("Enhance Contrast", "saturated=0.35 normalize");
    run("RGB Color");  // conversion nécessaire

    // 2) EdU_z pour le seuil
    eduMeas = dupSlice2D(idEDU, "__EDU_meas_z"+z);
    selectImage(eduMeas);
    run("8-bit");
    setAutoThreshold("Otsu dark");
    getThreshold(lower, upper);

    // 3) Prépare l’overlay
    selectImage(idOverlay);
    Overlay.remove;                  // enlever overlay existants
    Overlay.show;                    // important pour que addSelection colore correctement

    n = roiManager("count");
    edupos_count = 0;
    for (r=0; r<n; r++) {
        selectImage(eduMeas);
        roiManager("select", r);
        getStatistics(area, mean);
        isPos = (!isNaN(mean) && mean >= lower);
        if (isPos) edupos_count++;

        selectImage(idOverlay);
        roiManager("select", r);
        if (isPos) {
            Overlay.addSelection("red");
        } else {
            Overlay.addSelection("lime");
        }
    }

    // 4) Texte résumé
    if (n > 0) { pct = 100.0 * edupos_count / n; } else { pct = 0; }
    makeText("Z="+z+"   N="+n+"   EdU+="+edupos_count+" ("+d2s(pct,1)+"%)", 10, 20);
    Overlay.addSelection("yellow");

    // 5) Aplatir & sauvegarde
    selectImage(idOverlay);
    run("Flatten");
    saveAs("PNG", outputDir + replace(name, ".", "_QAoverlay_z"+z+".png"));
    close();
    selectImage(eduMeas); close();
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
    lowerName = toLowerCase(name);
    if (!endsWith(lowerName, ".tif") && !endsWith(lowerName, ".tiff") && !endsWith(lowerName, ".czi")
        && !endsWith(lowerName, ".lif") && !endsWith(lowerName, ".nd2") && !endsWith(lowerName, ".lsm")
        && !endsWith(lowerName, ".png") && !endsWith(lowerName, ".jpg") && !endsWith(lowerName, ".jpeg")) continue;

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
        // (Optionnel) skip des tranches très sombres (mesure sur DAPI_z)
        if (enableSkipDarkSlices){
            selectImage(idDAPI); Stack.setSlice(z);
            getRawStatistics(nPix, mean, minV, maxV, stdV, hist);
            if (mean < skipMeanThreshold) {
                File.append(name+","+z+",0,0,0\n", outCSV);
                File.append(name+","+z+",0,0,0\n", summaryAll);
                continue;
            }
        }

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

        // === Overlay QC coloré
        if (saveOverlays && nNuclei > 0) {
            saveOverlayQA_Color(name, z, idDAPI, idEDU, outputDir);
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
close();