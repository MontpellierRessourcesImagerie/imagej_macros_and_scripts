/**
  * Intensity Ratio Nuclei Cytoplasm Tool
  * Collaborators:
  *        Olivier Coux
  *
  * Subtract the background intensity and measure the ratio of the intensity in the nuclei and the intensity in 
  * the cytoplasm.
  *
  * (c) 2014, INSERM
  * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 *
*/

var _SUBTRACT_BACKGROUND_RADIUS = 1;
var _SUBTRACT_BACKGROUND_OFFSET = 1;
var _SUBTRACT_BACKGROUND_ITERATIONS = 2;
var _SUBTRACT_BACKGROUND_SKIP_LIMIT = 0.05;

var _NUCLEI_CHANNEL = "Hoechst";
var _CYTOPLASM_CHANNEL = "GFP";
var _MAX_PERCENT_SATURATED = 0.5;
var _THRESHOLD_METHOD = "Huang";
var _MIN_NUCLEUS_AREA = 20;
var _FILTER_NUCLEI = false;
var _FILTER_RADIUS = 2;
var _REMOVE_SCALE = false;
var _helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Intensity_Ratio_Nuclei_Cytoplasm_Tool";

var _FILENAME;
var _DIR;
var _ID_CYTOPLASM_IMAGE;
var _ID_NUCLEI_IMAGE;


macro "Unused Tool - C037" { }

macro 'Intensity Ratio Nuclei Cytoplasm Help (f1) Action Tool - C000D00D01D02D03D07D08D09D0aD0bD0cD0dD0eD0fD10D11D1cD1dD1eD1fD20D2dD2eD2fD3eD3fD4fD5fD6fD7fD8fD9fDafDbeDbfDc0DcdDceDcfDd0Dd1Dd5Dd6DdcDddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC444D28D29D60D6dD70D7dD8dDc9C000D04D05D06D12D19D1aD1bD4eD5eD6eD7eD8eD9eDaeDb0Dd2Dd3Dd4Dd7Dd8Dd9DdaDdbC999D38D39D61D6cD71D7cD8cC00fD87C112Dc6C99dDa8C666Db2C111D18Dc1CcccDa3C889Db8C333D15D2aD50D5dD80D9dDc3Dc8DcaCdddD44D93C444D31D3cDbcCaaaD37C44eD98C333D14D16D22D2bD40D4dD90DadDb1Dc4Dc7DcbCccdD47D48D7bC778Db7C111D13D17D21D2cD30D3dDa0DbdDccCcccD35D43D49D4aD52D5bD62D6bD72D82C999Db9CdddD53CaaaD33Da2C22eD97C222Dc5CbbdDa9C777D24D26D32D3bD41D4cD91DacDb4DbbCcccD8bD9bDaaC999D3aD51D5cD81D9cDbaCdddD45D54D5aD63D73D83C556Db5Db6CbbbDa4C44fD66D68CccdD55D59D64D6aD9aC888D25Db3C88dD95C11fD86CaaeD56D58D74D7aD84D8aCccdD46C555D23D27Da1CbbbD42D4bDabC44eD85D89CbbdD94C99bDa5C22fD76D78C222Dc2CbbbD34D36D92C55fD75D79C99eD65D69D99C11fD77C99eD57C33fD67C77bDa6C33eD96C11fD88C88cDa7'{
    intensityRatioForSingleImageHelp();
}

macro "correct background (f2) Action Tool - C000T4b12c" {
                       findAndSubtractBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS, _SUBTRACT_BACKGROUND_SKIP_LIMIT);
}

macro "correct background (f2) Action Tool Options" {
     Dialog.create("Correct Background Options");
     Dialog.addNumber("radius", _SUBTRACT_BACKGROUND_RADIUS);
     Dialog.addNumber("offset", _SUBTRACT_BACKGROUND_OFFSET);
     Dialog.addNumber("iterations", _SUBTRACT_BACKGROUND_ITERATIONS);
     Dialog.addNumber("skip limit", _SUBTRACT_BACKGROUND_SKIP_LIMIT);
     Dialog.show();
    _SUBTRACT_BACKGROUND_RADIUS = Dialog.getNumber();
    _SUBTRACT_BACKGROUND_OFFSET = Dialog.getNumber();
    _SUBTRACT_BACKGROUND_ITERATIONS = Dialog.getNumber();
    _SUBTRACT_BACKGROUND_SKIP_LIMIT = Dialog.getNumber();
}

macro "Intensity Ratio For Single Image (f3) Action Tool - C000T4b12s" {
    intensityRatioForSingleImage();
}


macro "Intensity Ratio For Single Image (f3) Action Tool Options" {
    createOptionsDialog();
}

macro "Intensity Ratio Batch (f4) Action Tool - C000T4b12b" {
    intensityRatioBatch();
}

macro "Intensity Ratio Batch (f4) Action Tool Options" {
    createOptionsDialog();
}

function createOptionsDialog() {
     Dialog.create("Intensity Ratio Options");
     Dialog.addString("nuclei channel: ", _NUCLEI_CHANNEL);
     Dialog.addString("cytoplasm channel: ", _CYTOPLASM_CHANNEL);
     Dialog.addNumber("max. % saturation:  ", _MAX_PERCENT_SATURATED);
     Dialog.addChoice("thresholding method", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError",  "Minimum", "Moments",  "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"),  _THRESHOLD_METHOD);
     Dialog.addNumber("min. nucleus area", _MIN_NUCLEUS_AREA);
     Dialog.addCheckbox("use Gaussian-blur filter on nuclei image", _FILTER_NUCLEI); 
     Dialog.addNumber("sigma of filter: ", _FILTER_RADIUS);
     Dialog.addCheckbox("remove scale", _REMOVE_SCALE);
     Dialog.show();
    _NUCLEI_CHANNEL = Dialog.getString();
    _CYTOPLASM_CHANNEL = Dialog.getString();
    _MAX_PERCENT_SATURATED = Dialog.getNumber();
    _THRESHOLD_METHOD = Dialog.getChoice();
    _MIN_NUCLEUS_AREA = Dialog.getNumber();
    _FILTER_NUCLEI = Dialog.getCheckbox();
    _FILTER_RADIUS = Dialog.getNumber();
    _REMOVE_SCALE = Dialog.getCheckbox();
}

macro "intensityRatioNucleiCytoplasmHelp [f1]" {
    intensityRatioForSingleImageHelp();
}

macro "correctBackground [f2]" {
    findAndSubtractBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS, _SUBTRACT_BACKGROUND_SKIP_LIMIT);
}

macro "intensityRatioForSingleImage [f3]" {
    intensityRatioForSingleImage();
}

macro "intensityRatioBatch [f4]" {
    intensityRatioBatch();
}

function intensityRatioForSingleImageHelp() {
    run('URL...', 'url='+_helpURL);
}

function intensityRatioForSingleImage() {
    measureIntensityRatioForOpenImage();
}

function intensityRatioBatch() {
    print("\\Clear");
    setBatchMode(true);
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
    print(dayOfMonth + "-" + (month+1) + "-" + year + " " + hour + ":" + minute + ":" + second + "." + msec);
    dir = getDirectory("Select the folder containing the images");
    files = getFileList(dir);
    numberOfImages = 0;
    for (i=0; i<files.length; i++) {
        file = files[i];
        if (isInputImage(file)) {
            numberOfImages++;
        }
    }
    counter = 1;
    for (i=0; i<files.length; i++) {
        file = files[i];
        if (isInputImage(file)) {
            print("\\Update1:Processing file " + (counter) + " of " + numberOfImages);
            open(dir+"/"+file);
            measureIntensityRatioForOpenImage();
            outDir = dir + "/" + "control-images";
            if (!File.exists(outDir)) {
                File.makeDirectory(outDir);
            }
            save(outDir + "/" + _FILENAME);
            close();
            counter++;
        }
    }
    selectWindow("INTENSITY-RATIO");
    saveAs("Text", _DIR + "/INTENSITY-RATIO" + ".xls");
    print("FINISHED");
        getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);    
    print(dayOfMonth + "-" + (month+1) + "-" + year + " " + hour + ":" + minute + ":" + second + "." + msec);
    setBatchMode("exit and display");
}

function isInputImage(name) {
    if (!endsWith(name, ".tif") && !endsWith(name, ".TIF")) return false;
    if (indexOf(name, _CYTOPLASM_CHANNEL)==-1) return false;
    return true;
}

function measureIntensityRatioForOpenImage() {
    run("Set Measurements...", "area mean integrated area_fraction display redirect=None decimal=3");
    _FILENAME = getInfo("image.filename");
    _DIR= getInfo("image.directory");
    if (isImageSaturated(_MAX_PERCENT_SATURATED)) {
        print("skipped saturated image: " + _DIR + "/" + _FILENAME);
        return;
    }
    loadOtherChannel();
    selectImage(_ID_CYTOPLASM_IMAGE);
    if (_REMOVE_SCALE) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    findAndSubtractBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS, _SUBTRACT_BACKGROUND_SKIP_LIMIT);    
    selectImage(_ID_NUCLEI_IMAGE);
    if (_REMOVE_SCALE) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    if (_FILTER_NUCLEI) {
        run("Gaussian Blur...", "sigma=" + _FILTER_RADIUS);
    }
    setAutoThreshold(_THRESHOLD_METHOD + " dark");
    setOption("BlackBackground", true);
    run("Convert to Mask");
    run("Analyze Particles...", "size="+_MIN_NUCLEUS_AREA+"-Infinity show=Masks in_situ");    
    run("Fill Holes");
    run("Create Selection");
    resetThreshold();
    selectImage(_ID_CYTOPLASM_IMAGE);
    run("Restore Selection");
    run("Measure");
    run("Make Inverse");
    run("Measure");
    totalIntensityNuclei = getResult("IntDen", nResults-2);
    meanIntensityNuclei = getResult("Mean", nResults-2);
    areaNuclei = getResult("Area", nResults-2);
    totalIntensityCytoplasm = getResult("IntDen", nResults-1);
    areaOutside = getResult("Area", nResults-1);
    percentAreaAboveZero = getResult("%Area",  nResults-1);
    areaCytoplasm = (areaOutside * percentAreaAboveZero ) / 100; 
    meanIntensityCytoplasm = totalIntensityCytoplasm / areaCytoplasm;
    tableTitle="INTENSITY-RATIO";
    table="["+tableTitle+"]";
    if (!isOpen(tableTitle)) {
        run("Table...", "name="+tableTitle+" width=550 height=250");
        print(table, "\\Headings:n\timage\ticn factor\t% nuclei\t% cytoplasm\tav. nuclei intensity\tav. cytoplasm intensity\tnuclei area\tcytoplasm area\tt. nuclei intensity\tt. cytoplasm intensity\tfolder");
    }
    selectWindow(tableTitle);
    info = split(getInfo("window.contents"), "\n");
    index = lengthOf(info);
    percentIntensityNuclei = 100 * (totalIntensityNuclei / ((totalIntensityCytoplasm + totalIntensityNuclei) * 1.0));
    percentIntensityCytoplasm = 100 * (totalIntensityCytoplasm / ((totalIntensityCytoplasm + totalIntensityNuclei) * 1.0));
    icnFactor = percentIntensityNuclei / (percentIntensityCytoplasm * 1.0);
    line = "" + index + "\t" + _FILENAME + "\t" + icnFactor + "\t" + percentIntensityNuclei + "\t" + percentIntensityCytoplasm + "\t" + meanIntensityNuclei + "\t" + meanIntensityCytoplasm + "\t" + areaNuclei + "\t" + areaCytoplasm + "\t" + totalIntensityNuclei + "\t" + totalIntensityCytoplasm + "\t" + _DIR; 
    print (table, line);
    createControlImage();
}

function createControlImage() {
    selectImage(_ID_NUCLEI_IMAGE);
    nucleiTitle = getTitle();
    run("RGB Color");
    selectImage(_ID_CYTOPLASM_IMAGE);
    cytoplasmTitle = getTitle();
    run("RGB Color");
    run("Make Inverse");
    foreground = getValue("color.foreground");
    run("Line Width...", "line=3");
    setForegroundColor(255, 0, 229);
    run("Draw");
    setForegroundColor(foreground);
    run("Line Width...", "line=1");
    run("Select None");
    run("Combine...", "stack1=[" + cytoplasmTitle + "] stack2=["+ nucleiTitle+ "] combine");
}

function loadOtherChannel() {
    if (indexOf(_FILENAME, _NUCLEI_CHANNEL)!=-1) {
        otherFilename = replace(_FILENAME, _NUCLEI_CHANNEL,  _CYTOPLASM_CHANNEL);
        _ID_NUCLEI_IMAGE = getImageID();
    }
    else {
        otherFilename = replace(_FILENAME, _CYTOPLASM_CHANNEL, _NUCLEI_CHANNEL);    
        _ID_CYTOPLASM_IMAGE = getImageID();
    }
    open(_DIR + "/" + otherFilename);
    if (indexOf(_FILENAME, _NUCLEI_CHANNEL)!=-1) {
        _ID_CYTOPLASM_IMAGE = getImageID();    
    }
    else {
        _ID_NUCLEI_IMAGE = getImageID();
    }
}
    
function isImageSaturated(maxPercentSaturated) {
    getStatistics(area, mean, min, max, std, histogram);
    maxValue = 255;
    theBitDepth = bitDepth();
    width = getWidth();
    height = getHeight();
    if (theBitDepth==16) {
    maxValue = 65535;
       getHistogram(0, counts, 65536);
                        histogram = counts;
    }
    totalNumberOfPixels = width * height;
    numberOfSaturatedPixels = histogram[maxValue];
    percent = (numberOfSaturatedPixels * 100) / (totalNumberOfPixels * 1.0);
    result = (percent>maxPercentSaturated);
    return result;
}

function findAndSubtractBackground(radius, offset, iterations, skipLimit) {
   width = getWidth();
   height = getHeight();
   getStatistics(area, mean, min, max, std, histogram);
   ratio = histogram[0] / ((width * height) * 1.0);
   if (ratio>skipLimit) {
    run("HiLo");
    run("Enhance Contrast", "saturated=0.35");
    return;
   }
   for(i=0; i<iterations; i++) {
        getStatistics(area, mean, min, max, std, histogram); 
        minPlusOffset =  min + offset;
        currentMax = 0;
        for(x=0; x<width; x++) {
    for(y=0; y<height; y++) {
        intensity = getPixel(x,y);
        if (intensity<=minPlusOffset) {
             value = getMaxIntensityAround(x, y, mean, radius, width, height);
            if (value>currentMax) currentMax = value;    
        }
    }
        }
        result = currentMax / (i+1);
        run("Subtract...", "value=" + result);
    }
    run("HiLo");
    run("Enhance Contrast", "saturated=0.35");
}

function getMaxIntensityAround(x, y, mean, radius, width, height) {
    max = 0;
    for(i=x-radius; i<=x+radius; i++) {
        if (i>=0 && i<width) {
               for(j=y-radius; j<=y+radius; j++) {
                      if (j>=0 && j<height) {
        value = getPixel(i,j);
                            if (value<mean && value>max)  max = value;
                      }
               }
        }
    }
    return max;
}
