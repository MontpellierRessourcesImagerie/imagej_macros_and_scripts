/**
  * Count Spines On Dendrite
  *
  *  The tool allows you to draw the path of a dendrite, manually select the spines and count the number of spines in each group.
  *
  *  written 2022 by Léo Tellez-Arenas (CNRS) at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
  */

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count_Spines_On_Dendrite";
var _DEFAULT_INPUT_FILE = "";

var _LUT = "Grays";
var _INVERT_LUT = true;
var _ENLARGE_RADIUS = 30; //In Pixel
var _MIN_DENDRITE_AREA = 5000; //In Pixel
var _SPINE_CIRCLE_RADIUS = 15;


function showHelp() {
     run("URL...", "url="+helpURL);
}

macro "Help Action Tool - C000T4b12?" {
    showHelp();
}

macro "Open Image Action Tool - C000T4b12O"{
    openImageAction();
}

macro "Open Image Action Tool Options"{
    openImageOption();
}

macro "Draw Dendrite Action Tool - C000T4b12D"{
    drawDendriteAction();
}

macro "Draw Dendrite Action Tool Options"{
    drawDendriteOption();
}

macro "Draw Spines Tool - C000T4b12S"{
    drawSpinesAction();
}

macro "Draw Spines Tool Options"{
    drawSpinesOption();
}

macro "Count Spines Action Tool - C000T4b12C"{
    countSpinesAction();
}

macro "Add Selection to Group 1 [&1]"{  setSelectionToGroup(1);}
macro "Add Selection to Group 2 [&2]"{  setSelectionToGroup(2);}
macro "Add Selection to Group 3 [&3]"{  setSelectionToGroup(3);}
macro "Add Selection to Group 4 [&4]"{  setSelectionToGroup(4);}
macro "Add Selection to Group 5 [&5]"{  setSelectionToGroup(5);}

function setSelectionToGroup(groupID){
    Roi.setGroup(groupID);
    roiManager("add");
    count = roiManager("count");
    roiManager("select", count-1);
    roiName = Roi.getName();
    roiManager("rename", groupID);
}

function drawSpinesAction(){
    getCursorLoc(x, y, z, flags);
    size = _SPINE_CIRCLE_RADIUS;
    makeOval(x-size/2, y-size/2, size, size);
}

function countSpinesAction(){
    roiManager("deselect");
    
    run("Clear Results");
    roiManager("measure");
    spineInGroup = newArray(0,0,0,0,0);
    for (i = 0; i < nResults(); i++) {
        v = getResult("Group", i);
        if(0 < v && v < 6) {
            spineInGroup[v-1]+=1;
        }
    }
    
    print("Length of the Dendrite = " + getResult("Length", 0));
    for(i=0;i<spineInGroup.length;i++){
        print("Number of Spines in group "+ i+1 + " = " + spineInGroup[i]);
    }

    Dialog.create("Roi Saving Options");
    Dialog.addDirectory("ROI Directory","");
    Dialog.addString("File Name", "");
    Dialog.show();
    directory = Dialog.getString();
    file = Dialog.getString();
    
    roiManager("save",directory+"/ROI_"+file+".zip");
}

function openImageAction(){
    Dialog.create("Enter Input File");
    Dialog.addFile("Input File", _DEFAULT_INPUT_FILE);
    Dialog.show();
    fileToOpen = Dialog.getString();
    openAndCleanImage(fileToOpen);
}

function drawDendriteAction(){
    enlargeRadius = _ENLARGE_RADIUS;
    minDendriteArea = _MIN_DENDRITE_AREA; 
    
    run("ROI Manager...");
    setBatchMode(true);
    drawDendrite(enlargeRadius,minDendriteArea);
    skeletonAndAnalyse();
    setBatchMode(false);
}

function drawDendrite(enlargeRadius,minDendriteArea){
    roiManager("add"); 
    run("Z Project...", "projection=[Max Intensity]");
    projectionID = getImageID();
    run("Auto Threshold", "method=Li white");
    
    count = roiManager("count");
    roiManager("Select", count-1);
    
    keepAreaAroundSelection(enlargeRadius);
    run("Select None");

    //run("Options...", "iterations=5 count=1 black pad do=Erode");
    run("Options...", "iterations=1 count=1 black do=Open");
    run("Analyze Particles...", "size="+minDendriteArea+"-Infinity pixel show=Masks");
    
    selectImage(projectionID);
    close();
}

function keepAreaAroundSelection(enlargeRadius){
    run("Line to Area");
    run("Enlarge...", "enlarge="+enlargeRadius+" pixel");
    run("Make Inverse");
    run("Fill", "slice");
}

function skeletonAndAnalyse(){
    run("Skeletonize (2D/3D)");
    title = getTitle();
    run("Geodesic Diameter", "label=["+title+"] distances=[Chessboard (1,1)] image=["+title+"] export");
    title = replace(title," ","");
    close(replace(title,".czi-C=0","-GeodDiameters"));
    
    count = roiManager("count");
    roiManager("Select", count-2);
    roiManager("delete");
    roiManager("Select", count-2);
    roiManager("rename", "Dendrite");
    
    count = roiManager("count");
    roiManager("Select", count-1);
    
    run("Interpolate", "interval=5 smooth");
    roiManager("update");
    
    close();
    run("Set Measurements...", "mean modal min redirect=None decimal=3");
    roiManager("measure");
}

function openAndCleanImage(fileName){
    run("Bio-Formats Importer", 
    "open=["+fileName+"] color_mode=Grayscale split_channels view=Hyperstack stack_order=XYCZT");
    
    close();
    close();
    
    run(_LUT);
    if(_INVERT_LUT){    run("Invert LUT");}
    
    setSlice(nSlices/2);
    run("Enhance Contrast", "saturated=0.35");
    run("Brightness/Contrast...");
}

function openImageOption(){
    lutArray = getList("LUTs");
    Dialog.create("LUT Options");
    
    Dialog.addChoice("LUT", lutArray, _LUT);
    Dialog.addCheckbox("Invert", _INVERT_LUT);
    
    Dialog.show();
    
    _LUT = Dialog.getChoice();
    _INVERT_LUT = Dialog.getCheckbox();
}

function drawDendriteOption(){
    Dialog.create("Draw Dendrite Options");
    Dialog.addMessage("The higher this value is, the more the trajectory of your path will be modified");
    Dialog.addSlider("Enlarge Radius", 5, 50, _ENLARGE_RADIUS);
    Dialog.show();
    _ENLARGE_RADIUS = Dialog.getNumber();
}

function drawSpinesOption(){
    Dialog.create("Spine Selection Options");
    Dialog.addMessage("This option will only change the visualisation of the ROI");
    Dialog.addSlider("Selection radius", 5, 25, _SPINE_CIRCLE_RADIUS);
    
    Dialog.show();
    
    _SPINE_CIRCLE_RADIUS = Dialog.getNumber();
}