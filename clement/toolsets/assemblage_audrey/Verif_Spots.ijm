var mipRedSuffix = "_w1Cy3.tif";
var mipGreenSuffix = "_w3";
var maskPrefix = "mask_";
var maskSuffix = mipRedSuffix;

var colocSuffix = "_spotsCOLOC.tif";
var spotsSuffix = mipRedSuffix + "_spotsRED.tif";

macro "Verif Spots" {
    Dialog.create("Spots Verif Options");
    Dialog.addMessage("Leave the GFP Directory blank if you only have one channel of spots");
    Dialog.addDirectory("Cy3 Mip Directory","");
    Dialog.addDirectory("GFP Mip Directory","");
    Dialog.addDirectory("Masks   Directory","");
    Dialog.addDirectory("Spots/Coloc Directory","");

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
    for(i=0;i<fileList.length;i++){
        baseFileName = replace(fileList[i],mipRedSuffix,"");
        
        showProgress(i, fileList.length);
        print("File "+ i+1 +"/" + fileList.length+" : "+baseFileName+" currently verified..." );

        if(mipGFPDir == ""){ //Si pas de GFP spécifié
            displayCompositeRED(mipCy3Dir, maskDir, spotsDir, baseFileName);
        }else{ //Si GFP spécifié
            displayCompositesColoc(mipCy3Dir, mipGFPDir, maskDir, spotsDir, baseFileName);
        }
        
        waitForUser("Ready to check next MIP ?");
        run("Close All");
    }
}

function displayCompositeRED(mipCy3Dir, maskDir, spotsDir, baseFileName){
    mipTitleRed = openMipImage(mipCy3Dir, baseFileName, mipRedSuffix);
    maskTitle = openMaskImage(maskDir, baseFileName, maskPrefix, maskSuffix);
    
    spotsTitle = openSpotImage(spotsDir, baseFileName, spotsSuffix);
    
    mergeRedImage(maskTitle,mipTitleRed,spotsTitle);
}

function displayCompositesColoc(mipCy3Dir, mipGFPDir, maskDir, colocDir, baseFileName){
    mipTitleRed   = openMipImage(mipCy3Dir, baseFileName, mipRedSuffix);
    mipTitleGreen = openMipImage(mipGFPDir, baseFileName, mipGreenSuffix);
    maskTitle = openMaskImage(maskDir, baseFileName, maskPrefix, maskSuffix);
    
    colocTitle = openSpotImage(colocDir, baseFileName, colocSuffix);
    colocTitleRed = "C1-" + colocTitle;
    colocTitleGreen = "C2-" + colocTitle;
    
    mergeRedImage(maskTitle,mipTitleRed,colocTitleRed);
    mergeGreenImage(maskTitle,mipTitleGreen,colocTitleGreen);
}

function openMipImage(mipDir, baseFileName, titleSuffix){
    mipPath = mipDir + baseFileName + titleSuffix;
    
    open(mipPath);
    run("8-bit");
    run("Enhance Contrast", "saturated=0.35");
    return getTitle();
}

function openMaskImage(maskDir, baseFileName, titlePrefix, titleSuffix){
    maskPath = maskDir + titlePrefix + baseFileName + titleSuffix;
    
    open(maskPath);
    run("8-bit");
    run("Invert");
    return getTitle();
}

function openSpotImage(spotsDir, baseFileName, titleSuffix){
    spotsPath = spotsDir + baseFileName + titleSuffix;
    
    open(spotsPath);
    spotsTitle = getTitle();
    getDimensions(width, height, channels, slices, frames);
    if(channels>1){
        run("Split Channels");
    }
    
    return spotsTitle;
}

function mergeRedImage(maskTitle,mipTitleRed,colocTitleRed){
    run("Merge Channels...", "c1=["+colocTitleRed+"] c3=["+maskTitle+"] c4=["+mipTitleRed+"] create keep ignore");
    rename("Red Spots");
}

function mergeGreenImage(maskTitle,mipTitleGreen,colocTitleGreen){
    run("Merge Channels...", "c2=["+colocTitleGreen+"] c3=["+maskTitle+"] c4=["+mipTitleGreen+"] create keep ignore");
    rename("Green Spots");
}