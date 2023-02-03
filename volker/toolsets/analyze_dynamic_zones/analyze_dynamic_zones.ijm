/**
  *  In a 2D+t stack, find zones in which the signal changes over time. Find if the signal increases, decreases or has a u- or n-shape. 
  *   
  *   (c) INSERM, 2022-2023
  *  
  *  written 2022-2023 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  **
*/

var FOCAL_ADHESIONS_CHANNEL = 2;
var TENSIN_CHANNEL = 1;
var FUNCTION_TO_FIT = "Gamma Variate";
var REGISTRATION_METHODS = newArray("stack reg", "sift");
var REGISTRATION_METHOD = REGISTRATION_METHODS[0];
var DYNAMICS = newArray("Total Intensity", "Area", "Mean Intensity");
var DYNAMIC = DYNAMICS[0];
var DYNAMIC_TABLES = newArray("Total Int. Dynamic Zones", "Area Dynamic Zones", "Mean Int. Dynamic Zones");
var DYNAMIC_TABLE = DYNAMIC_TABLES[0];
var CONST_THRESHOLD = 1000;  //  in physical units
var RELATIVE_CONST_THRESHOLD = 0.4;
var USE_RELATIVE_CONST_THRESHOLD = true;
var GRADIENT_FILTER_RADIUS_XY = 1;
var GRADIENT_FILTER_RADIUS_Z = 3;
var BORDER_SIZE = 10;   // in pixel
var DOG_LARGE_RADIUS = 15;
var SHOW_CONSTANT = false;
var LUTS = getList("LUTs");
var LUT = LUTS[25];
var SMOOTHING_RADIUS = 2;
var MIDDLE_THRESHOLD_FACTOR = 1;
var MIN_PROMINENCE = 5;
var ROLLING_BALL_RADIUS = 50;
var TOUCHED_THRESHOLD = 1;
var CLASSES = newArray("decreasing", "n", "constant", "u", "increasing");

var DEBUG = false;
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

macro "register frames (F4) Action Tool - C000T4b12r" {
    registerFrames();
}

macro "register frames (F4) Action Tool Options" {
    Dialog.create("Register Frames Options");
    Dialog.addChoice("registration method: ", REGISTRATION_METHODS, REGISTRATION_METHOD);
    Dialog.show();
    REGISTRATION_METHOD = Dialog.getChoice();
}

macro "register frames [F4]" {
    registerFrames();
}

macro "Analyze dynamic zones in image (F5) Action Tool - C000T4b12a" {
    analyzeDynamicZonesInImage();
}

macro "Analyze dynamic zones in image [F5]" {
    analyzeDynamicZonesInImage();
}

macro "Analyze dynamic zones in image (F5) Action Tool Options" {
    Dialog.create("Analyze Dynamic Zones Options");
    Dialog.addNumber("focal adhesions channel: ", FOCAL_ADHESIONS_CHANNEL);
    Dialog.addNumber("tensin channel: ", TENSIN_CHANNEL);
    Dialog.addChoice("Dynamic: ", DYNAMICS, DYNAMIC);
    Dialog.addNumber("Dynamic threshold: ", CONST_THRESHOLD);
    Dialog.addCheckbox("Use relative threshold", USE_RELATIVE_CONST_THRESHOLD);
    Dialog.addNumber("Relative dynamic threshold: ", RELATIVE_CONST_THRESHOLD);
    Dialog.addNumber("Radius of background filter (DoG): ", DOG_LARGE_RADIUS);
    Dialog.addNumber("Gradient filter xy-radius: ", GRADIENT_FILTER_RADIUS_XY);
    Dialog.addNumber("Gradient filter z-radius: ", GRADIENT_FILTER_RADIUS_Z);
    Dialog.addNumber("Border size: ", BORDER_SIZE);
    Dialog.addCheckbox("Show constant zones", SHOW_CONSTANT);
    Dialog.addChoice("LUT for zones", LUTS, LUT);
    
    Dialog.show();
    
    FOCAL_ADHESIONS_CHANNEL = Dialog.getNumber();
    TENSIN_CHANNEL = Dialog.getNumber();
    DYNAMIC = Dialog.getChoice();
    CONST_THRESHOLD = Dialog.getNumber();
    USE_RELATIVE_CONST_THRESHOLD = Dialog.getCheckbox();
    RELATIVE_CONST_THRESHOLD = Dialog.getNumber();
    DOG_LARGE_RADIUS = Dialog.getNumber();
    GRADIENT_FILTER_RADIUS_XY = Dialog.getNumber();
    GRADIENT_FILTER_RADIUS_Z = Dialog.getNumber();
    BORDER_SIZE = Dialog.getNumber();
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
    plotAreaOverTime();
}

macro "Plot area over time [f7]" {
    plotAreaOverTime();
}

macro "Plot mean intensity over time (f8) Action Tool - C000T4b12m" {
    plotMeanIntensityOverTime();
}

macro "Plot mean intensity over time [f8]" {
    plotMeanIntensityOverTime();
}

macro "Classify plot [f12]" {
    Plot.getValues(xpoints, ypoints);
    class = classifyData(ypoints);
    print(class);
}

function registerFrames() {
    if (REGISTRATION_METHOD=="stack reg") {
        run("multi stack reg");
    }
    if (REGISTRATION_METHOD=="sift") {
        title = getTitle();
        inputImageID = getImageID();
        run("Linear Stack Alignment with SIFT MultiChannel");
        alignedImageID = getImageID();
        selectImage(inputImageID);
        close();
        selectImage(alignedImageID);
        rename(title);
    }
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
    label = parseInt(parts[0]);
    deltaT = Stack.getFrameInterval(); 
    Stack.getUnits(xUnit, yUnit, zUnit, tUnit, vUnit);
    data = Table.getColumn(label, tableName);
    smoothedData = smoothArray(data);
    X = Array.getSequence(smoothedData.length);
    for (i = 0; i < X.length; i++) {
        X[i] = X[i] * deltaT;
    }
    Plot.create("Plot of "+tableName+" Label=" + label , "t ["+tUnit+"]", label);
    Plot.add("Connected Circles", X, Table.getColumn(label, tableName));
    Plot.setStyle(0, "blue,#a0a0ff,1.0,Connected Circles");
    Fit.doFit(FUNCTION_TO_FIT, X, smoothedData);
    Y = newArray(X.length);
    for(i=0; i<X.length; i++) {
        Y[i] = Fit.f(X[i]);
    }
    Plot.add("Line", X, Y);
    Plot.setStyle(1, "red,#a0a0ff,1.0,Line");
    Plot.show();
}

function analyzeDynamicZonesInImage() {
    assertStackIsMovie();
    LUTFolder = getDir("luts");
    getDimensions(width, height, channels, slices, frames);
    inputImageID = getImageID();
    inputImageTitle = getTitle();
    initAnalysis();
    setBatchMode(true);
    run("Split Channels");
    selectImage("C"+FOCAL_ADHESIONS_CHANNEL+"-"+inputImageTitle);
    focalAdhesionsImageID = getImageID(); 
    run("Properties...", "slices="+frames+" frames="+slices); 
    
    removeBackground();
    dogImageTitle = getTitle();
    
    segmentActiveZones();
    
    labelImageID = getImageID();
    labelImageTitle = getTitle();
    run("Properties...", "slices="+slices+" frames="+frames); 
    
    lastLabel = measureDynamic(frames, labelImageTitle, labelImageID, focalAdhesionsImageID);
    selectImage(labelImageID);
    
    classifyActiveZones(lastLabel);
    
    selectImage("C"+TENSIN_CHANNEL+"-"+inputImageTitle);
    tensinImageID = getImageID();
    countTimesTouchedByTensin(tensinImageID);
    reportDynamicTouchedUntouched(TOUCHED_THRESHOLD);
/**    
    run("Merge Channels...", "c1=["+labelImageTitle+"] c4=["+inputImageTitle+"] create");
    count = roiManager("count");
    if (count>0) {
        run("From ROI Manager");
        run("Labels...", "color=white font=12 show use draw");
    }
    

*/    
    setBatchMode("exit and display");
}

function reportDynamicTouchedUntouched(threshold) {
    untouched = newArray(5);
    touched = newArray(5);
    tableName = "dynamic touched/untouched";
    tableHandle = "[" + tableName + "]";
    Table.create(tableName);
    for (i = 0; i < CLASSES.length; i++) {
        Table.set("class", i, CLASSES[i]);
    }
    for (i = 0; i < nResults; i++) {
        class = getResult("class", i);
        contacts = getResult("Nr. of tensin contacts", i);
        if (contacts >= threshold) {
            touched[class] = touched[class] + 1;
        } else {
            untouched[class] = untouched[class] + 1;
        }
    }
    touchedPercent = newArray(5);
    untouchedPercent = newArray(5);
    for (i = 0; i < touched.length; i++) {
        touchedPercent[i] = touched[i] / (touched[i] + untouched[i]);
        untouchedPercent[i] = untouched[i] / (touched[i] + untouched[i]);
    }

    Table.setColumn("untouched (< "+threshold+")", untouched);
    Table.setColumn("touched (>= "+threshold+")", touched);
    Table.setColumn("fraction untouched", untouchedPercent);
    Table.setColumn("fraction touched", touchedPercent);
    Table.update;
}

function countTimesTouchedByTensin(imageID) {
    selectImage(imageID);    
    run("Duplicate...", "duplicate");
    run("Subtract Background...", "rolling="+ROLLING_BALL_RADIUS+" stack");
    setAutoThreshold("Moments dark stack");
    run("Convert to Mask", "method=Moments background=Dark");    
    run("Clear Results");
    roiManager("deselect");
    roiManager("measure");
    count = roiManager("count");
    for (i = 0; i < count; i++) {
        roiManager("select", i);
        run("Plot Z-axis Profile");
        Plot.getValues(xpoints, ypoints);
        maxima = Array.findMaxima(ypoints, MIN_PROMINENCE);
        close();
        setResult("Nr. of tensin contacts", i, maxima.length);
        label = getResultString("Label", i);
        class = getClassFromLabel(label);
        setResult("class", i, class);
    }
    close();
}

function getClassFromLabel(label) {
    class = -1;
    if (indexOf(label, "- decreasing") >= 0) {
        class = 0;
    }
    if (indexOf(label, "- n") >= 0) {
        class = 1;
    }
    if (indexOf(label, "- constant") >= 0) {
        class = 2;
    }
    if (indexOf(label, "- u" ) >= 0) {
        class = 3;
    }
    if (indexOf(label, "- i" ) >= 0) {
        class = 4;
    }
    return class;
}

function assertStackIsMovie() {
     getDimensions(width, height, channels, slices, frames);
     if (slices>1 && frames == 1) {
        run("Properties...", "slices="+frames+" frames="+slices); 
     }
}

function initAnalysis() {
    run("ROI Manager...");
    roiManager("reset");
    run("Grays");
}

function classifyActiveZones(lastLabel) {
    for(l = 1; l <= lastLabel; l++) {
       areaOverTime = Table.getColumn(l, DYNAMIC_TABLE); 
       class = classifyData(areaOverTime); 
       if (class == "constant") {
           if (SHOW_CONSTANT) addZoneRoi(l, "constant");
           continue;
       }
       addZoneRoi(l, class);
    }
}

function classifyData(data) {
    inf = parseFloat("Infinity");
    areaOverTime = data;
    timePoints = Array.getSequence(areaOverTime.length);
    smoothedAreaOverTime = smoothArray(areaOverTime);
    fittedAreaOverTime = getFittedSeries(smoothedAreaOverTime);
    data = fittedAreaOverTime;
    if (data[0] == inf) data = smoothedAreaOverTime;
    valueZero = data[0];
    indexAbsMax = 0;
    valueAbsMax = valueZero;
    valueLast = data[timePoints.length-1];
    for (t = 1; t < timePoints.length; t++) {
       value = data[t];
       if(abs(value)>abs(valueAbsMax)) {
            valueAbsMax = value;
            indexAbsMax = t;
       }
    }
    if (DEBUG) {
        print(valueZero, valueAbsMax, valueLast);
        differencesAndThreshold = getDifferencesAndThreshold(valueZero, valueAbsMax, valueLast);  
        Array.print(differencesAndThreshold);
    }
    constant = isConstant(valueZero, valueAbsMax, valueLast);
    if (constant) {
       return "constant";
    }
    increasing = isIncreasing(valueZero, valueAbsMax, valueLast);
    if (increasing) {
        return "increasing";
    }
    decreasing = isDecreasing(valueZero, valueAbsMax, valueLast);
    if (decreasing) {
        return "decreasing";
    }
    if (valueZero <= valueAbsMax && valueAbsMax >= valueLast) {
        return "n";
    }
    if (valueZero >= valueAbsMax && valueAbsMax <= valueLast) {
        return "u";
    }
    return "undefined";
}

function getFittedSeries(series) {
    timePoints = Array.getSequence(series.length);
    Fit.doFit(FUNCTION_TO_FIT, timePoints, series);
    fittedSeries = newArray(series.length);
    for (t = 0; t <series.length; t++) {
       value = Fit.f(t);
       fittedSeries[t] = value;
    }
    return fittedSeries;
}

function isConstant(valueZero, valueMax, valueLast) {
    constant = false;
    differencesAndThreshold = getDifferencesAndThreshold(valueZero, valueMax, valueLast);  
    if (differencesAndThreshold[0] <= differencesAndThreshold[3] && differencesAndThreshold[1] <= differencesAndThreshold[3]  && differencesAndThreshold[2] <= differencesAndThreshold[3]) {
        constant = true;
    }
    return constant;
}

function isIncreasing(valueZero, valueMax, valueLast) {
    differencesAndThreshold = getDifferencesAndThreshold(valueZero, valueMax, valueLast);  
    smallerThreshold = differencesAndThreshold[3] * MIDDLE_THRESHOLD_FACTOR;
    increasing = (valueZero < valueLast && (valueZero <= valueMax || differencesAndThreshold[0] <= smallerThreshold)  && (valueMax <= valueLast || differencesAndThreshold[1] <= smallerThreshold));
    return increasing;
}


function isDecreasing(valueZero, valueMax, valueLast) {
    differencesAndThreshold = getDifferencesAndThreshold(valueZero, valueMax, valueLast);  
    smallerThreshold = differencesAndThreshold[3] * MIDDLE_THRESHOLD_FACTOR;
    decreasing = (valueZero > valueLast && (valueZero >= valueMax || differencesAndThreshold[0] <= smallerThreshold)  && (valueMax >= valueLast || differencesAndThreshold[1] <= smallerThreshold));
    return decreasing;
}

function getDifferencesAndThreshold(valueZero, valueMax, valueLast) {
    result = newArray(4);    
    vz = Math.max(0, valueZero);
    vl = Math.max(0, valueLast);
    vm = Math.max(0, valueMax);
    threshold = CONST_THRESHOLD;
    if (USE_RELATIVE_CONST_THRESHOLD) {
        vz = vz / valueMax;
        vl = vl / valueMax;
        vm = vm / valueMax;
        threshold = RELATIVE_CONST_THRESHOLD;
    } 
    result[0] = abs(vz - vm);
    result[1] = abs(vl - vm);
    result[2] = abs(vz - vl);
    result[3] = threshold;
    
    return result;
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

function smoothArray(anArray) {
    kernel = meanKernel(SMOOTHING_RADIUS);
    smoothedArray = convolve(anArray, kernel, "constant");
    return smoothedArray;
}

function meanKernel(radius) {
    n = 2 * radius + 1;
    kernel = newArray(n);
    for (i = 0; i < n; i++) {
        kernel[i] = 1 / n;
    }
    return kernel;
}
 
function convolve(array, kernel, borderHandling) {
    if ((kernel.length % 2) == 0) {
        exit("The size of the kernel needs to be odd but the kernel size is: " + kernel.length);
    }
    
    kernelCenterIndex = Math.floor(kernel.length / 2);
    resultArray = newArray(array.length);
    for (i = 0; i < resultArray.length; i++) {
        sum = 0;
        for (k = 0; k < kernel.length; k++) {
            currentFactor = kernel[k];
            currentIndex = i - kernelCenterIndex + k;
            currentValue = array[i];
            if (currentIndex > -1 && currentIndex < array.length) {
                currentValue = array[currentIndex];
            }
            sum = sum + currentValue * currentFactor;
        }
        resultArray[i] = sum;
    }
    return resultArray;
}
