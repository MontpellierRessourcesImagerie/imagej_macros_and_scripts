//5-detect-spots

var mipRedSuffix = "_w1Cy3.tif";
var mipGreenSuffix = "_w2GFP.tif";
var maskPrefix = "mask_";
var maskSuffix = mipRedSuffix;

var colocSuffix = "_spotsCOLOC.tif";
var spotsSuffix = mipRedSuffix + "_spotsRED.tif";

Dialog.create("Spots Detect Options");
Dialog.addMessage("Leave the GFP Directory blank if you only have one MIP channel");
Dialog.addDirectory("Cy3 Mip Directory","");
Dialog.addDirectory("GFP Mip Directory","");
Dialog.addDirectory("Masks   Directory","");
Dialog.addDirectory("Destination Directory","");

Dialog.show();

mipCy3Dir = Dialog.getString();
mipGFPDir = Dialog.getString();
maskDir   = Dialog.getString();
spotsDir  = Dialog.getString();

if(mipGFPDir == ""){ //Si pas de GFP spécifié
    print("No GFP Directory Detected !");
}else{ //Si GFP spécifié
    print("GFP Directory Detected !");
}

run("Close All");
fileList = getFileList(mipCy3Dir);

tableName = "ResultsFinal";
Table.create(tableName);

for(i=0;i<fileList.length;i++){
    baseFileName = replace(fileList[i],mipRedSuffix,"");
    
    showProgress(i, fileList.length);
    print("File "+ i+1 +"/" + fileList.length+" : "+baseFileName+" currently processed..." );

    makeMaskROI(maskDir, baseFileName, maskPrefix, maskSuffix);
    length = measureMaskSkeleton();

    if(mipGFPDir == ""){ //Si pas de GFP spécifié
        nbSpots = detectSpotsRED(mipCy3Dir, baseFileName, spotsDir);
        fillTableRED(tableName, i, baseFileName, length, nbSpots);
    }else{ //Si GFP spécifié
        detectSpotsCOLOC(mipCy3Dir,mipGFPDir, baseFileName, spotsDir);
        fillTableCOLOC(tableName, i, baseFileName, length);
    }
    
    cleanup();
}
Table.save(spotsDir+"_Results.csv",tableName);
waitForUser("Execution Terminée !");

function detectSpotsRED(mipDir, baseFileName, outDir){
//Process la detection de spots sur l'image CY3
    mipPath = mipDir + baseFileName + mipRedSuffix;
    open(mipPath);

    roiManager("Select", 0);
    run("Detect Particles", "ch1a=4 ch1s=12 rois=Ovals add=Nothing summary=Reset");
    nb_RED_SPOTS = Table.get("Number_of_Particles", 0,"Summary");
    
    run("Select All");
    setForegroundColor(0, 0, 0);
    run("Fill", "slice");
    run("Flatten");
    run("8-bit");
    run("Convert to Mask");
    run("Red");
    save(outDir+baseFileName+spotsSuffix);
    return nb_RED_SPOTS;
}

function detectSpotsCOLOC(mipDirRed, mipDirGreen, baseFileName, outDir){
//Process la detection de spots sur les images Cy3 et GFP
    redPath = mipDirRed + baseFileName + mipRedSuffix;
    greenPath = mipDirGreen + baseFileName + mipGreenSuffix;

    open(redPath);
    nameRed = getTitle();

    open(greenPath);
    nameGreen = getTitle();

    run("Merge Channels...", "c1="+nameRed+" c2="+nameGreen+" create");
    roiManager("Select", 0);
    run("Detect Particles", "calculate max=4 plot rois=Ovals add=Nothing summary=Reset ch1a=4 ch1s=12 ch2a=4 ch2s=12");
    
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
    save(outDir+baseFileName+colocSuffix);
}

function makeMaskROI(maskDir, baseFileName, titlePrefix, titleSuffix){
//récupère le mask binaire des neurones, fait un filtre de taille et créé les régions
    maskPath = maskDir + titlePrefix + baseFileName + titleSuffix;
    open(maskPath);
    run("Invert");
    run("Analyze Particles...", "size=3000-Infinity show=Masks");
    run("Create Selection");
    roiManager("Add");
}

function measureMaskSkeleton(){
//fait un squelette du mask pour calculer la longueur totale des prolongements neuronaux
    run("Skeletonize");
    run("Set Measurements...", "perimeter redirect=None decimal=3");
    run("Measure");
    length = getResult("Perim.", nResults-1);
    run("Clear Results");
    return length;
}

function fillTableRED(tableName, rowIndex, fileName, length, nbSpots){
//Remplissage du tableau de résultat dans le cas sans coloc
    Table.set("Nom_Fichier",    rowIndex, fileName,tableName);
    Table.set("Longueur_Totale",rowIndex, length,tableName);
    Table.set("Nb_Spots_Rouge", rowIndex, nbSpots,tableName);

    Table.update(tableName);
}

function fillTableCOLOC(tableName, rowIndex, fileName, length){
//Remplissage du tableau de résultat dans le cas sans coloc
    Table.set("Nom_Fichier",    rowIndex, fileName,tableName);
    Table.set("Longueur_Totale",rowIndex, length,tableName);

    nbSpotsRed = Table.get("Particles_in_Ch1", 0,"Summary");
    Table.set("Nb_Spots_Rouge", rowIndex, nbSpotsRed,tableName);

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