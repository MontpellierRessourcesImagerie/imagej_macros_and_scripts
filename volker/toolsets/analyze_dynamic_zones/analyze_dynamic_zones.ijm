CONST_THRESHOLD = 1;  //  in physical units
ALIGN_FRAMES = true;

getDimensions(width, height, channels, slices, frames);
run("ROI Manager...");
roiManager("reset");
setBatchMode("hide");
run("Properties...", "slices="+frames+" frames="+slices); 
inputImageID = getImageID();
inputImageTitle = getTitle();
run("Grays");
if (ALIGN_FRAMES) run("StackReg ", "transformation=[Rigid Body]");
removeBackground();
dogImageTitle = getTitle();
segmentActiveZones();
labelImageID = getImageID();
labelImageTitle = getTitle();
run("Properties...", "slices="+slices+" frames="+frames); 
Stack.setFrame(frames);
lastLabel = getValue("Max");
tableTitle = labelImageTitle + "-Morphometry";
iTableTitle = "in-intensity-measurements";
Table.create("Area Dynamic Zones");
Table.create("Mean Int. Dynamic Zones");
Table.create("StdDev Dynamic Zones");
for (t = 0; t <frames; t++) {
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
    Stack.setFrame(t);   
    run("Duplicate...", "title=in");
    run("Intensity Measurements 2D/3D", "input=[in] labels=labels mean stddev ");
    iLabels = Table.getColumn("Label", iTableTitle);
    means = Table.getColumn("Mean", iTableTitle);
    stdDevs = Table.getColumn("StdDev", iTableTitle);
    for(l=0; l<iLabels.length; l++) {
        Table.set(iLabels[l], t, means[l], "Mean Int. Dynamic Zones");
        Table.set(iLabels[l], t, stdDevs[l], "StdDev Dynamic Zones");
    }
    close("in");
    close("labels");   
    Table.update("Area Dynamic Zones");
    Table.update("Mean Int. Dynamic Zones");
    Table.update("StdDev Dynamic Zones");
}

run("Merge Channels...", "c1=["+labelImageTitle+"] c4=["+inputImageTitle+"] create");

for(l=1; l<labels.length; l++) {
       areaOverTime = Table.getColumn(l, "Area Dynamic Zones"); 
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
            addZoneRoi(l, "constant");
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
count = roiManager("count");
if (count>0) {
    run("From ROI Manager");
    run("Labels...", "color=white font=12 show use draw");
}

setBatchMode("exit and display");

function segmentActiveZones() {
    run("Morphological Filters (3D)", "operation=Gradient element=Cube x-radius=2 y-radius=2 z-radius=2");
    gradientImageTitle = getTitle();
    run("Convert to Mask", "method=Otsu background=Dark");
    removeXYBorderVoxels();
    run("Fill Holes", "stack");
    run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
    run("Random");
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
    run("Gaussian Blur...", "sigma=15 stack");
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
    run("Enlarge...", "enlarge=-10 pixel");
    run("Make Inverse");
    run("Fill", "stack");
    run("Select None");
}