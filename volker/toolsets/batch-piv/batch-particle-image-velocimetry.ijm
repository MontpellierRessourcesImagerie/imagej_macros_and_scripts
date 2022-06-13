/***
 * 
 * PIV batch 
 * 
 * Run the particle image velocimetry plugin on all pairs of neighboring frames of the time-series.
 * a 
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/
var CHANNEL = 2;
var COLOR = "Green";
var OUTPUT_FOLDER = "/media/baecker/DONNEES/mri/in/laura_picas/out/"
var piv1 = 128;
var sw1 = 256;
var vs1 = 64;
var piv2 = 64;
var sw2 = 128;
var vs2 = 32;
var piv3 = 48;
var sw3 = 96;
var vs3 = 24;
var corr = 0.8;
var OUTPUT_FOLDER = getDirectory("temp");
var LUT = "Fire";
var DISPLAY_PIV = newArray(false, false, true, false);

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Batch_PIV_Tool";


macro "Batch PIV Tool Help [f4]" {
    run('URL...', 'url='+helpURL);
}

macro "Batch PIV Tool Help (f4) Action Tool - C037T3f18?"{
    run('URL...', 'url='+helpURL);
}

macro "PIV batch Action Tool (F2) - C037T0b11PT7b09ITcb09V" {
   batchPIV();
}

macro "PIV batch [f2]" {
    batchPIV();
}

macro "PIV batch Action Tool (F2) Options" {
    Dialog.create("Multi-slice PIV");
    Dialog.addNumber("channel", CHANNEL);
    Dialog.addNumber("Interrogation window 1", piv1);
    Dialog.addNumber("search window 1", sw1);
    Dialog.addNumber("vector spacing 1", vs1);
    Dialog.addNumber("Interrogation window 2", piv2);
    Dialog.addNumber("search window 2", sw2);
    Dialog.addNumber("vector spacing 2", vs2);
    Dialog.addNumber("Interrogation window 3", piv3);
    Dialog.addNumber("search window 3", sw3);
    Dialog.addNumber("vector spacing 3", vs3);
    Dialog.addNumber("correlation threshold", corr);
    Dialog.addDirectory("output folder", OUTPUT_FOLDER)
    Dialog.addCheckbox("display piv1", DISPLAY_PIV[1]);
    Dialog.addToSameRow();
    Dialog.addCheckbox("display piv2", DISPLAY_PIV[2]);
    Dialog.addToSameRow();
    Dialog.addCheckbox("display piv3", DISPLAY_PIV[3]);
    Dialog.show;
    CHANNEL = Dialog.getNumber();
    piv1 = Dialog.getNumber();
    sw1 = Dialog.getNumber();
    vs1 = Dialog.getNumber();
    piv2 = Dialog.getNumber();
    sw2 = Dialog.getNumber();
    vs2 = Dialog.getNumber();
    piv3 = Dialog.getNumber();
    sw3 = Dialog.getNumber();
    vs3 = Dialog.getNumber();
    corr = Dialog.getNumber();
    OUTPUT_FOLDER = Dialog.getString();
    DISPLAY_PIV[1] = Dialog.getCheckbox();
    DISPLAY_PIV[2] = Dialog.getCheckbox();
    DISPLAY_PIV[3] = Dialog.getCheckbox();
}

function batchPIV() {
    setBatchMode("hide");
    run("Duplicate...", "duplicate channels="+CHANNEL+"-"+CHANNEL);
    getDimensions(width, height, channels, slices, frames);
    duplicateID = getImageID();
    if (slices>1) run("Z Project...", "projection=[Max Intensity] all");
    selectImage(duplicateID);
    close();
    run(COLOR);
    getDimensions(width, height, channels, slices, frames);
    for (i = 0; i < frames - 1; i++) {
        IJ.log("Processing pair of frames number " + (i+1) + " of " + (frames-1));
        title = getTitle();
        parts = split(title, ".");
        title = parts[0];
        run("Duplicate...", "duplicate range="+(i+1)+"-"+(i+2));
        rename(title+"-"+(i+1));
        run("iterative PIV(Advanced)...", "  piv1=128 sw1=256 vs1=64 piv2=64 sw2=128 vs2=32 piv3=32 sw3=96 vs3=16 correlation=0.60 batch postprocessing=None postprocessing_0=0.20 postprocessing_1=5 path="+OUTPUT_FOLDER);
        close();
        close();
        close();
        close();
    }
    resultChannels = newArray(0);
    projectionImageTitle = getTitle();
    for (i = 1; i <= 3; i++) {
        if (DISPLAY_PIV[i]) {
            File.openSequence(OUTPUT_FOLDER, " filter="+"PIV"+i);
            rename("PIV" + i);
            channelTitle = getTitle();
            addSliceAtBeginning();
            run("8-bit");
            run("16-bit");
            run(LUT);        
            resultChannels = Array.concat(resultChannels, channelTitle);
        }    
    }
    mergeString = "c2=" +  projectionImageTitle + " ";
    for (i = 0; i < resultChannels.length; i++) {
        mergeString = mergeString + "c" + (3+i) + "=" + resultChannels[i] + " ";
    }
    mergeString = mergeString + "create";
    if (resultChannels.length > 0) {
        run("Merge Channels...", mergeString);
        Stack.setDisplayMode("composite");
    }
    setBatchMode("exit and display");
}

function addSliceAtBeginning() {
    run("Reverse");
    setSlice(nSlices);
    run("Add Slice");
    run("Reverse");
    setSlice(1);
}

