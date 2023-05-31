
main();

function main() {

    mipRedSuffix   = getString("mipRedSuffix", ""); // "_w1Cy3.tif";
    mipGreenSuffix = getString("mipGreenSuffix", ""); // "_w3";
    mipCy3Dir      = getDirectory("redMipDir");
    mipGFPDir      = getDirectory("greenMipDir");
    maskDir        = getDirectory("maskDir"); // Dialog.getString();
    spotsDir       = getDirectory("spotsDir"); // Dialog.getString();

    spotsSuffix    = mipRedSuffix + "_spotsRED.tif";
    colocSuffix    = "spotsCOLOC.tif";
    maskSuffix     = mipRedSuffix;
    maskPrefix     = "mask_";

    // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

    gfpMipFiles = getFileList(mipGFPDir);
    cy3MipFiles = getFileList(mipCy3Dir);
    noGFP       = gfpMipFiles.length == 0;

    if (noGFP) {
        print("No GFP Directory Detected !");
    } else {
        print("GFP Directory Detected !");
    }

    run("Close All");
    
    for(i = 0 ; i < cy3MipFiles.length ; i++){
        baseFileName = replace(cy3MipFiles[i], mipRedSuffix, "");
        
        showProgress(i, cy3MipFiles.length);
        print("File "+ i+1 +"/" + cy3MipFiles.length+" : "+baseFileName+" currently verified..." );

        if (noGFP) { //Si pas de GFP spécifié
            displayCompositeRED(mipCy3Dir, maskDir, spotsDir, baseFileName);
        } else { //Si GFP spécifié
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