/**
 * multi_stack_reg.ijm
 * 
 * Run the MultiStackReg plugin to align the slices of the selected channel and apply the 
 * same alignment to all other channels.
 * 
 *   (c) INSERM, 2022
 *  
 *  written 2023 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
 */

getDimensions(width, height, channels, slices, frames);
Stack.getPosition(channel, slice, frame);
if (channels>1) {
    inputImageID = getImageID(); 
    run("Duplicate...", "duplicate");
    copyOfInputImageID = getImageID();
    selectImage(inputImageID);
    multiStackReg(channel);
    inputImageID = getImageID();
    for (c = 1; c <= channels; c++) {
        selectImage(copyOfInputImageID);
        Stack.setChannel(c);
        getMinAndMax(min, max);
        Color.getLut(reds, greens, blues);
        selectImage(inputImageID);
        Stack.setChannel(c);
        Color.setLut(reds, greens, blues);
        setMinAndMax(min, max);
    }
    selectImage(copyOfInputImageID);
    close();
} 

if (channels==1) {
    multiStackReg(channel)
}

function multiStackReg(channel) {
    getDimensions(width, height, channels, slices, frames);
    if (channels==1) {
       calculateTransformation();
       return;
    }
    title = getTitle();
    run("Split Channels");
    selectImage("C" + channel + "-" + title);
    calculateTransformation();
    for (c = 1; c <= channels; c++) {
        if (c == channel) continue;
        selectImage("C" + c + "-" + title);
        applyTransformation();
    }
    mergeChannels(title, channels);
}

function calculateTransformation() {
    title = getTitle();
    path = getTransormationFilePath();
    run("MultiStackReg", "stack_1="+title+" action_1=Align file_1=["+path+"] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body] save");    
}

function applyTransformation() {
    title = getTitle();
    path = getTransormationFilePath();
    run("MultiStackReg", "stack_1="+title+" action_1=[Load Transformation File] file_1=["+path+"] stack_2=None action_2=Ignore file_2=[] transformation=[Rigid Body]");
}

function getTransormationFilePath() {
    dir = getDir("temp");
    path = dir + "transformation.txt";
    return path;
}

function mergeChannels(title, channels) {
     mergeOptions = "";
     for (c = 1; c <= channels; c++) {
        mergeOptions = mergeOptions + "c" + c + "=C"+c+"-"+title + " ";
    }
    mergeOptions = mergeOptions + "create";
    run("Merge Channels...", mergeOptions);
}
