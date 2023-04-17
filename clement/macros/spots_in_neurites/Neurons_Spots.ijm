
main();

function main() {

    // Acquiring data from user / toolset manager
    mipRedSuffix   = getString("redSuffix", ""); // "_w1Cy3.tif";
    mipGreenSuffix = getString("greenSuffix", ""); //"_w3GFP.tif";
    mipDirectory   = getDirectory("MipDirectory");
    maskDir        = getDirectory("maskDirectory");
    spotsDir       = getDirectory("spotsDirectory");
    ch1a           = getNumber("ch1a", 3);
    ch1s           = getNumber("ch1s", 5);
    ch2a           = getNumber("ch2a", 4);
    ch2s           = getNumber("ch2s", 11);

    // Building paths
    red = split(mipRedSuffix, ".");
    red = red[0];
    green = split(mipGreenSuffix, ".");
    green = green[0];
    mipCy3Dir = joinPath(mipDirectory, red);
    mipGFPDir = joinPath(mipDirectory, green);

    // S'il n'y a pas de GFP, le dossier n'existe pas dans les MIPs.
    gfpMissing  = !File.isDirectory(mipGFPDir);

    maskPrefix  = "mask_";
    colocSuffix = "spotsCOLOC.tif";
    maskSuffix  = mipRedSuffix;
    spotsSuffix = mipRedSuffix + "_spotsRED.tif";

    // Starting
    run("Close All");
    cy3FilesList = getFileList(mipCy3Dir);

    // Si la GFP existe, on extrait les fichiers.
    gfpFilesList = newArray();
    if (gfpMissing) { 
        print("No GFP Directory Detected !");
    } else { 
        print("GFP Directory Detected !");
        gfpFilesList = getFileList(mipGFPDir);
    }

    tableName = "ResultsFinal";
    Table.create(tableName);

    for(i = 0 ; i < cy3FilesList.length ; i++) {
        redName = cy3FilesList[i];
        baseFileName = replace(redName, mipRedSuffix, "");
        IJ.log("Processing: " + baseFileName);
        
        showProgress(i, cy3FilesList.length);

        makeMaskROI(maskDir, baseFileName, maskPrefix, maskSuffix);
        length = measureMaskSkeleton();

        if (gfpMissing) { // Si pas de GFP spécifié
            nbSpots = detectSpotsRED(mipCy3Dir, baseFileName, spotsDir);
            fillTableRED(tableName, i, baseFileName, length, nbSpots);
        } else {
            detectSpotsCOLOC(mipCy3Dir,mipGFPDir, baseFileName, spotsDir);
            fillTableCOLOC(tableName, i, baseFileName, length);
        }
        
        cleanup();
    }
    Table.save(joinPath(spotsDir, tableName + ".csv"));
}


function detectSpotsRED(mipDir, baseFileName, outDir){
    // Process la detection de spots sur l'image CY3
    mipPath = joinPath(mipDir, baseFileName + mipRedSuffix);
    open(mipPath);

    roiManager("Select", 0);
    run("Detect Particles", "ch1a="+ch1a+" ch1s="+ch1s+" rois=Ovals add=Nothing summary=Reset");
    nb_RED_SPOTS = Table.get("Number_of_Particles", 0,"Summary");
    
    run("Select All");
    setForegroundColor(0, 0, 0);
    run("Fill", "slice");
    run("Flatten");
    run("8-bit");
    run("Convert to Mask");
    run("Red");
    save(joinPath(outDir, baseFileName + spotsSuffix));
    return nb_RED_SPOTS;
}

function detectSpotsCOLOC(mipDirRed, mipDirGreen, baseFileName, outDir){
//Process la detection de spots sur les images Cy3 et GFP
    redPath   = joinPath(mipDirRed, baseFileName + mipRedSuffix);
    greenPath = joinPath(mipDirGreen, baseFileName + mipGreenSuffix);

    open(redPath);
    nameRed = getTitle();

    open(greenPath);
    nameGreen = getTitle();

    run("Merge Channels...", "c1="+nameRed+" c2="+nameGreen+" create");
    roiManager("Select", 0);
    maxDist = (ch1a + ch2a) / 2.0;
    run("Detect Particles", "calculate max=3.5 plot rois=Ovals add=Nothing summary=Reset ch1a="+ch1a+" ch1s="+ch1s+" ch2a="+ch2a+" ch2s="+ch2s);
    
    run("Select All");
    setForegroundColor(0, 0, 0);
    run("Fill", "stack");
    run("Flatten");
    title = getTitle();
    run("Split Channels");
    
    setAutoThreshold("Default dark no-reset");
    selectWindow(title + " (blue)");
    close();
    selectWindow(title + " (red)");
    run("Convert to Mask");
    run("Red");
    selectWindow(title + " (green)");
    run("Convert to Mask");
    run("Green");
    run("Merge Channels...", "c1=["+title+" (red)] c2=["+title+" (green)] create");

    save(joinPath(outDir, baseFileName + colocSuffix));
}

function makeMaskROI(maskDir, baseFileName, titlePrefix, titleSuffix){
    // récupère le mask binaire des neurones, fait un filtre de taille et créé les régions
    maskPath = joinPath(maskDir, titlePrefix + baseFileName + titleSuffix);
    open(maskPath);
    run("Invert");
    run("Analyze Particles...", "size=3000-Infinity show=Masks");
    run("Create Selection");
    roiManager("Add");
}

function measureMaskSkeleton(){
    // fait un squelette du mask pour calculer la longueur totale des prolongements neuronaux
    run("Skeletonize");
    run("Set Measurements...", "perimeter redirect=None decimal=3");
    run("Measure");
    length = getResult("Perim.", nResults-1);
    run("Clear Results");
    return length;
}

function fillTableRED(tableName, rowIndex, fileName, length, nbSpots){
    // Remplissage du tableau de résultat dans le cas sans coloc
    Table.set("Nom_Fichier",    rowIndex, fileName,tableName);
    Table.set("Longueur_Totale",rowIndex, length,tableName);
    Table.set("Nb_Spots_Rouges", rowIndex, nbSpots,tableName);

    Table.update(tableName);
}

function fillTableCOLOC(tableName, rowIndex, fileName, length){
    //Remplissage du tableau de résultat dans le cas sans coloc
    Table.set("Nom_Fichier",    rowIndex, fileName,tableName);
    Table.set("Longueur_Totale",rowIndex, length,tableName);

    nbSpotsRed = Table.get("Particles_in_Ch1", 0,"Summary");
    Table.set("Nb_Spots_Rouges", rowIndex, nbSpotsRed,tableName);

    nbSpotsGreen = Table.get("Particles_in_Ch2", 0,"Summary");
    Table.set("Nb_Spots_Verts", rowIndex, nbSpotsGreen,tableName);

    nbSpotsColoc = Table.get("Colocalized_ch1&ch2", 0,"Summary");
    Table.set("Nb_Spots_Coloc", rowIndex, nbSpotsColoc,tableName);

    Table.update(tableName);
}

function cleanup(){
    run("Clear Results");
    roiManager("Deselect");
    roiManager("Delete");
    run("Close All");
}

function getFileWithCase(namesList, name) {
    for (i = 0 ; i < namesList.length ; i++) {
        t1 = toLowerCase(name);
        t2 = toLowerCase(namesList[i]);
        if (t1.matches(t2)) {
            return namesList[i];
        }
    }
    return "-";
}

// Joins a new element to a path, considering that the first part doesn't necessarily ends with the path separator.
function joinPath(parent, leaf) {
    if (parent.endsWith(File.separator)) {
        return parent + leaf;
    } else {
        return parent + File.separator + leaf;
    }
}