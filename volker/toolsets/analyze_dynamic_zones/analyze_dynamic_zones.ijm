/**
  *  In a 2D+t stack, find zones in which the signal changes over time. Find if the signal increases, decreases or has a u- or n-shape. 
  *   
  *   (c) INSERM, 2022
  *  
  *  written 2022 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  **
*/

var DYNAMICS = newArray("Total Intensity", "Area", "Mean Intensity");
var DYNAMIC = DYNAMICS[0];
var DYNAMIC_TABLES = newArray("Total Int. Dynamic Zones", "Area Dynamic Zones", "Mean Int. Dynamic Zones");
var DYNAMIC_TABLE = DYNAMIC_TABLES[0];
var CONST_THRESHOLD = 1000;  //  in physical units
var ALIGN_FRAMES = true;
var GRADIENT_FILTER_RADIUS_XY = 1;
var GRADIENT_FILTER_RADIUS_Z = 3;
var BORDER_SIZE = 10;   // in pixel
var DOG_LARGE_RADIUS = 15;
var SHOW_CONSTANT = false;
var LUTS = getList("LUTs");
var LUT = LUTS[25];
if (LUT!="Random") LUT = "glasbey on dark";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Dynamic_Zones_Analyzer";

analyzeDynamicZonesInImage();
exit();

macro "Dynamic Zones Analyzer (F1) Action Tool - C333L0030C587D40C7edD50C5a9D60C587D70C344D80C333L90e0C533Df0C333L0131C344D41C465D51C477D61C6ecD71C354D81C333L91e1C222Df1C333L0262C344D72C333L82e2C222Df2C333D03C444D13C565D23C454D33C333L43e3C222Df3C333D04C454D14C9c8D24C685D34C333L4474C334L8494C333La4e4C222Df4C444L0515C565D25C454D35C333L4565C447D75C66dD85C55cD95C449Da5C744Db5C944Dc5C433Dd5C333De5C323Df5C333L0666C446D76C55dD86C66fD96C55bDa6C844Db6Ca44Dc6C574Dd6C5c5De6C494Df6C333L0767C334D77C448D87C55cD97C446Da7C433Db7C443Dc7C5b5Dd7C8f8De7C5b5Df7C333L0878C344D88C444L98a8C333Db8C353Dc8C5c5Dd8C7f7De8C5b5Df8C333L0959C343D69C474L7989C5b5L99a9C474Db9C464Dc9C5d5Ld9e9C353Df9C333L0a4aC343D5aC464D6aC6d6L7a8aC585D9aC595DaaC494DbaC595DcaC6d6DdaC5b5DeaC333DfaL0b4bC454D5bC6c6D6bC7f7D7bC6d6D8bC333D9bC454DabC5a5DbbC5b5DcbC6e6DdbC5a5DebC333DfbL0c4cC454D5cC6d6D6cC8f8D7cC5c5D8cC454L9cacC5a5LbcccC595DdcC454DecC222DfcC333L0d4dC343D5dC474D6dC6d6D7dC6f6D8dC5b5D9dC454DadC333LbdedC222DfdC333L0e6eC464D7eC5d5D8eC6d6D9eC464DaeC333LbeceC222LdefeD0fC333D1fC222D2fC333L3f7fC353D8fC464D9fC343DafC333LbfdfC222Lefff" {
    run('URL...', 'url='+helpURL);    
}

macro "Dynamic Zones Analyzer  [f1]" {
    run('URL...', 'url='+helpURL);  
}

macro "Analyze dynamic zones in image (F5) Action Tool - C000T4b12a" {
    analyzeDynamicZonesInImage();
}

macro "Analyze dynamic zones in image [F5]" {
    analyzeDynamicZonesInImage();
}

macro "Analyze dynamic zones in image (F5) Action Tool Options" {
    Dialog.create("Analyze Dynamic Zones Options");
    Dialog.addChoice("Dynamic: ", DYNAMICS, DYNAMIC);
    Dialog.addNumber("Dynamic threshold: ", CONST_THRESHOLD);
    Dialog.addNumber("Radius of background filter (DoG): ", DOG_LARGE_RADIUS);
    Dialog.addNumber("Gradient filter xy-radius: ", GRADIENT_FILTER_RADIUS_XY);
    Dialog.addNumber("Gradient filter z-radius: ", GRADIENT_FILTER_RADIUS_Z);
    Dialog.addNumber("Border size: ", BORDER_SIZE);
    Dialog.addCheckbox("Align frames", ALIGN_FRAMES);
    Dialog.addCheckbox("Show constant zones", SHOW_CONSTANT);
    Dialog.addChoice("LUT for zones", LUTS, LUT);
    
    Dialog.show();
    
    DYNAMIC = Dialog.getChoice();
    CONST_THRESHOLD = Dialog.getNumber();
    DOG_LARGE_RADIUS = Dialog.getNumber();
    GRADIENT_FILTER_RADIUS_XY = Dialog.getNumber();
    GRADIENT_FILTER_RADIUS_Z = Dialog.getNumber();
    BORDER_SIZE = Dialog.getNumber();
    ALIGN_FRAMES = Dialog.getCheckbox();
    SHOW_CONSTANT = Dialog.getCheckbox();
    LUT = Dialog.getChoice();
    
    for (i = 0; i < DYNAMICS.length; i++) {
        if (DYNAMICS[i] == DYNAMIC) break;
    }
    DYNAMIC_TABLE = DYNAMIC_TABLES[i];
}

macro "Plot total intensity over time (f6) Action Tool - C000T4b12t" {
    plotTotalIntensityOverTime();
}

macro "Plot total intensity over time [f6]" {
    plotTotalIntensityOverTime();
}

macro "Plot area over time (f7) Action Tool - C000T4b12p" {
    plotAreaOverTime()
}

macro "Plot area over time [f7]" {
    plotAreaOverTime()
}

macro "Plot mean intensity over time (f8) Action Tool - C000T4b12m" {
    plotMeanIntensityOverTime()
}

macro "Plot mean intensity over time [f8]" {
    plotMeanIntensityOverTime()
}

function plotAreaOverTime() {
    tableName = "Area Dynamic Zones";
    plotOverTime(tableName);
}

function plotMeanIntensityOverTime() {
    tableName = "Mean Int. Dynamic Zones";
    plotOverTime(tableName);
}

function plotTotalIntensityOverTime() {
    tableName = "Total Int. Dynamic Zones";
    plotOverTime(tableName);
}

function plotOverTime(tableName) {
    name = Roi.getName;
    parts = split(name, "-");
    label = parseInt(parts[0])
    Plot.create("Plot of "+tableName+" Label=" + label , "x", label);
    Plot.add("Connected Circles", Table.getColumn(label, tableName));
    Plot.setStyle(0, "blue,#a0a0ff,1.0,Connected Circles");
    data = Table.getColumn(label, tableName);
    X = Array.getSequence(data.length);
    Fit.doFit("Error Function", X, data);
    Y = newArray(X.length);
    for(i=0; i<X.length; i++) {
        Y[i] = Fit.f(X[i]);
    }
    Plot.add("Line", X, Y);
    Plot.setStyle(1, "red,#a0a0ff,1.0,Line");
    Plot.show();
}

function analyzeDynamicZonesInImage() {
    LUTFolder = getDir("luts");
    getDimensions(width, height, channels, slices, frames);
    inputImageID = getImageID();
    inputImageTitle = getTitle();
    initAnalysis();
    setBatchMode("hide");
    run("Properties...", "slices="+frames+" frames="+slices); 
    
    if (ALIGN_FRAMES) {
        stackRegCommand = "StackReg ";
        commands = List.setCommands;
        if (List.indexOf("StackReg")>=0) {
            stackRegCommand = "StackReg";
        }       
        run(stackRegCommand, "transformation=[Rigid Body]");
    }
    
    removeBackground();
    dogImageTitle = getTitle();
    
    segmentActiveZones();
    
    labelImageID = getImageID();
    labelImageTitle = getTitle();
    run("Properties...", "slices="+slices+" frames="+frames); 
    
    lastLabel = measureDynamic(frames, labelImageTitle, labelImageID, inputImageID);
    selectImage(labelImageID);
    
    classifyActiveZones(lastLabel);
    
    run("Merge Channels...", "c1=["+labelImageTitle+"] c4=["+inputImageTitle+"] create");
    count = roiManager("count");
    if (count>0) {
        run("From ROI Manager");
        run("Labels...", "color=white font=12 show use draw");
    }
    
    setBatchMode("exit and display");
}

function initAnalysis() {
    run("ROI Manager...");
    roiManager("reset");
    run("Grays");
}

function classifyActiveZones(lastLabel) {
    for(l=1; l<=lastLabel; l++) {
       areaOverTime = Table.getColumn(l, DYNAMIC_TABLE); 
       timePoints = Array.getSequence(areaOverTime.length);
       Fit.doFit("Error Function", timePoints, areaOverTime);
       valueZero = Fit.f(0);
       indexAbsMax = 0;
       valueAbsMax = valueZero;
       valueLast = Fit.f(timePoints.length-1);
       for (t = 1; t <frames; t++) {
           value = Fit.f(t);
           if(abs(value)>abs(valueAbsMax)) {
                valueAbsMax = value;
                indexAbsMax = t;
           }
       }
       diff1 = abs(valueZero - valueAbsMax);
       diff2 = abs(valueLast - valueAbsMax);
       diff3 = abs(valueZero - valueLast);
       if (diff1 <= CONST_THRESHOLD && diff2 <= CONST_THRESHOLD && diff3 <= CONST_THRESHOLD) {
            if (SHOW_CONSTANT) addZoneRoi(l, "constant");
            continue;
       }
       if (valueZero <= valueAbsMax && valueAbsMax <= valueLast) {
            addZoneRoi(l, "increasing");
            continue;
       }
       if (valueZero >= valueAbsMax && valueAbsMax >= valueLast) {
            addZoneRoi(l, "decreasing");
            continue;
       }
       if (valueZero <= valueAbsMax && valueAbsMax >= valueLast) {
            addZoneRoi(l, "n");*
            continue;
       }
       if (valueZero >= valueAbsMax && valueAbsMax <= valueLast) {
            addZoneRoi(l, "u");
            continue;
       }
    }
}

function measureDynamic(frames, labelImageTitle, labelImageID, inputImageID) {
    Stack.setFrame(frames);
    lastLabel = getValue("Max");
    tableTitle = labelImageTitle + "-Morphometry";
    iTableTitle = "in-intensity-measurements";
    Table.create("Area Dynamic Zones");
    Table.create("Mean Int. Dynamic Zones");
    Table.create("Total Int. Dynamic Zones");
    Table.create("StdDev Dynamic Zones");
    for (t = 0; t < frames; t++) {
        selectImage(labelImageID);
        Stack.setFrame(t+1);    
        run("Analyze Regions", "pixel_count area");
        labels = Table.getColumn("Label", tableTitle);
        areas = Table.getColumn("Area", tableTitle);
        for(l=0; l<labels.length; l++) {
            Table.set(labels[l], t, areas[l], "Area Dynamic Zones");
        }
        run("Duplicate...", "title=labels");
        selectImage(inputImageID);
        Stack.setFrame(t+1);   
        run("Duplicate...", "title=in");
        run("Intensity Measurements 2D/3D", "input=in labels=labels mean stddev ");
        iLabels = Table.getColumn("Label", iTableTitle);
        means = Table.getColumn("Mean", iTableTitle);
        stdDevs = Table.getColumn("StdDev", iTableTitle);
        totalInt = newArray(means.length);
        for (i = 0; i < means.length; i++) {
            totalInt[i] = means[i] * areas[i];
        }

        for(l=0; l<iLabels.length; l++) {
            Table.set(iLabels[l], t, means[l], "Mean Int. Dynamic Zones");
            Table.set(iLabels[l], t, stdDevs[l], "StdDev Dynamic Zones");
            Table.set(iLabels[l], t, totalInt[l], "Total Int. Dynamic Zones");
        }
        close("in");
        close("labels");   
        Table.update("Area Dynamic Zones");
        Table.update("Mean Int. Dynamic Zones");
        Table.update("StdDev Dynamic Zones");
        Table.update("Total Int. Dynamic Zones");
    }
    close(iTableTitle);
    close(tableTitle);
    return lastLabel;
}

function segmentActiveZones() {
    run("Morphological Filters (3D)", "operation=Gradient element=Cube x-radius="+GRADIENT_FILTER_RADIUS_XY+" y-radius="+GRADIENT_FILTER_RADIUS_XY+" z-radius="+GRADIENT_FILTER_RADIUS_Z);
    gradientImageTitle = getTitle();
    run("Convert to Mask", "method=Otsu background=Dark");
    removeXYBorderVoxels();
    run("Fill Holes", "stack");
    run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
    run(LUT);
    labelImageID = getImageID();
    labelImageTitle = getTitle();
    close(dogImageTitle);
    close(gradientImageTitle);    
}

function removeBackground() {
    dogRemoveBackground();
}

function dogRemoveBackground() {
    title = getTitle();
    run("Duplicate...", "duplicate");
    titleSmoothed = getTitle();
    run("Gaussian Blur...", "sigma="+DOG_LARGE_RADIUS+" stack");
    imageCalculator("Subtract create stack", title, titleSmoothed);
    close(titleSmoothed);
}

function addZoneRoi(label, class) {
    run("Select Label(s)", "label(s)="+l);
    run("Z Project...", "projection=[Max Intensity]");
    setThreshold(1, 65535, "raw");
    run("Create Selection");
    roiManager("add");
    index = roiManager("count") - 1;
    roiManager("select", index);
    roiManager("rename", l+" - "+class);
    close();
    close();    
}

function removeXYBorderVoxels() {
    run("Select All");
    run("Enlarge...", "enlarge=-"+BORDER_SIZE+" pixel");
    run("Make Inverse");
    run("Fill", "stack");
    run("Select None");
}