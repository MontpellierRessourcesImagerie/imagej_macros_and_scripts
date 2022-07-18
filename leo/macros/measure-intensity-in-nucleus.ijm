CH1 = "gH";
CH2 = "p21";
CH3 = "H";
channels = newArray(" CH1 "," CH2 "," CH3 ");


sourceDir = getDir("Source directory");
destinationDir = getDir("Destination directory");

Dialog.create("Settings");

/*
requires("1.52r");
Dialog.addDirectory("Source directory","");
Dialog.addDirectory("Destination directory","");
*/

Dialog.addMessage("Channel Names -- Measure");
addChannelLine("CH1", CH1, true);
addChannelLine("CH2", CH2, true);
addChannelLine("CH3", CH3, false);

Dialog.addRadioButtonGroup("Nuclei Channel", channels, 1, 3, " CH3 ");

Dialog.show();

/*
sourceDir = Dialog.getString();
destinationDir = Dialog.getString();
*/

CH1 = Dialog.getString();
analyseCH1 = Dialog.getCheckbox();

CH2 = Dialog.getString();
analyseCH2 = Dialog.getCheckbox();

CH3 = Dialog.getString();
analyseCH3 = Dialog.getCheckbox();

nucleiChannel = Dialog.getRadioButton();

fileList = getFileList(sourceDir);

for (i=1; i<fileList.length; i=i+3) {
    if(!endsWith(fileList[i], ".tif")){
        continue;
    }
    
    inName = fileList[i];
    
    baseChannel = defineBaseChannel(inName, CH1, CH2, CH3);
    
    nameCH1 = replace(inName, baseChannel, CH1);
    nameCH2 = replace(inName, baseChannel, CH2);
    nameCH3 = replace(inName, baseChannel, CH3);
    print(nameCH1);
    
//      Sélection des noyaux
    nameNucleiChannel = "";
    if(nucleiChannel == " CH1 "){
        nameNucleiChannel = nameCH1;
    }else if(nucleiChannel == " CH2 "){
        nameNucleiChannel = nameCH2;
    }else if(nucleiChannel == " CH3 "){
        nameNucleiChannel = nameCH3;
    }
    
    print("Detecting Nucleus in image : " + nameNucleiChannel);
    open(sourceDir + nameNucleiChannel);
    detectNuclei(nameNucleiChannel, 1500);

    n = roiManager("count");
    print(n + " Nucleus found !");

//      Sélection du channel à analyser
    if(analyseCH1){
        open(sourceDir + nameCH1);
        measureChannel(nameCH1, destinationDir);
    }
    if(analyseCH2){
        open(sourceDir + nameCH2);
        measureChannel(nameCH2, destinationDir);
    }
    if(analyseCH3){
        open(sourceDir + nameCH3);
        measureChannel(nameCH3, destinationDir);
    }
    roiManager("reset");
}

function detectNuclei(imageTitle, minNucleiSize){
    selectWindow(imageTitle);
    run("Subtract Background...", "rolling=100");
    run("Duplicate...", imageTitle + "_bin");
    
    run("Gaussian Blur...", "sigma=2");
    run("Enhance Contrast...", "saturated=0.35");
    
    run("Auto Threshold", "method=Li white");
    //run("Auto Threshold", "method=Intermodes white");
    run("Options...", "iterations=1 count=1 black do=Nothing");
    run("Watershed");
    run("Options...", "iterations=1 count=1 do=Nothing");
    
    run("Analyze Particles...", "size=" + minNucleiSize + "-Infinity exclude add");
}

function measureChannel(imageTitle, outputDirectory){
    selectWindow(imageTitle);
    run("Subtract Background...", "rolling=100");
    setMinAndMax(0, 500);
    roiManager("Show None");
    roiManager("Show All with labels");

    run("Set Measurements...", "area mean integrated display redirect=None decimal=3");
    roiManager("measure");

    run("Flatten");
    saveAs("Tiff", outputDirectory + imageTitle);
    saveAs("Results", outputDirectory + "_Results.csv");

    run("Close All");
    //run("Clear Results");
}

function addChannelLine(lineName, channelName, analyseState){
    Dialog.addString(lineName, channelName);
    Dialog.addToSameRow();
    Dialog.addCheckbox("Measure", analyseState);
}

function defineBaseChannel(inName, CH1, CH2, CH3){
    nameCH1Less = replace(inName, CH1, "");
    nameCH2Less = replace(inName, CH2, "");
    nameCH3Less = replace(inName, CH3, "");
    
    if(nameCH1Less.length() <= nameCH2Less.length() && nameCH1Less.length() <= nameCH3Less.length() ){
        baseChannel = CH1;
    }else{
        if(nameCH2Less.length() <= nameCH1Less.length() && nameCH2Less.length() <= nameCH3Less.length() ){
            baseChannel = CH2;
        }else{
            baseChannel = CH3;
        }
    }
    
    return baseChannel;
}