/**
  * Analyse Spots per Protoplast
  *
  * The tool counts the spots per protoplast. If a third channel is provided it is used to 
  * filter out detected protoplasts that do not have exactly one nucleus. The tool expects
  * hyperstack with the channels  
  * 1. spots (green)
  * 2. protoplasts (grey)
  * 3. nuclei (blue, optional)
  *
  *  written 2016 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *  in cooperation with Marie Ducousso
  **
  */

var _THRESHOLDING_METHODS = newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError",  "Minimum", "Moments",  "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen");
var _THRESHOLD_METHOD = "MinError";
var _MIN_SIZE = 1500;
var _BLUE_THRESHOLD_METHOD = "Huang";
var _BLUE_MIN = 100;
var _REMOVE_SCALE = true;
var helpURL = "http://dev.mri.cnrs.fr/projects/imagej-macros/wiki/Analyse_Spots_Per_Protoplast";

function showHelp() {
     run('URL...', 'url='+helpURL);
}

macro "help [f1]" {
    showHelp();
}

macro "Help (f1) Action Tool - C000D00D01D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D28D29D2aD2bD2cD2dD2eD2fD30D31D3aD3bD3cD3dD3eD3fD40D41D4cD4dD4eD4fD50D51D5eD5fD60D61D6cD6eD6fD70D7fD80D8dD8fD90D9fDa0DaeDafDb0DbeDbfDc0Dc3DcdDceDd0Dd1DddDe0De1De2De3DedDf0Df1Df2Df3DfcDfdC020D44D54D9cDabDbbDd7De8Df7Df8DffC000D04D12D13D14D24D43D48D53Dc4DcfDdeDeeDf4DfeC0c0D75D77C050D88D92D99D9bDa3Da5Da7DaaDb6Db7C010D69D6aD79Db2Db3Dd6DdbDeaDf9Cff0D25D26D27D32D33D34D35D37D38D39D42D49D4aD4bD52D5bD5cD5dD62D6dD71D76D7dD7eD81D85D86D87D8eD91D96D9dD9eDa1Da9DadDb1Db8Db9DbaDbcDbdDc1Dc2Dc9DccDd2Dd3Dd4DdcDe4De5DebDecDf5Df6DfaDfbC040D64Da2Dc6C010D02D03D36D59D5aD63D6bD72D7cDacDd5De6C070D56D65D74D83D8bDa6C020D47D58D7aD89Db4Dc5DcbDdfDe7De9C030D45D7bD8aD8cDb5Dc7Dd8Dd9DdaC060D57D97D98DcaC040D55D68D78D9aDa4Dc8C0a0D66D67D84D93D94D95Da8C030D46D73D82Def" {
    showHelp();
}

macro "analyze protoplasts [f2]" {
    analyseImage();
}

macro "Analyze Protoplasts (f2) Action Tool - C000T4b12a" {
    analyseImage();
}


macro "Analyze Protoplasts (f2) Action Tool Options" {
     Dialog.create("Analyze Protoplasts Options");
     Dialog.addChoice("Protoplasts thresholding method", _THRESHOLDING_METHODS, _THRESHOLD_METHOD);
     Dialog.addNumber("Protoplasts min. size",  _MIN_SIZE);
     Dialog.addChoice("Nuclei thresholding method", _THRESHOLDING_METHODS, _BLUE_THRESHOLD_METHOD);
     Dialog.addNumber("Nuclei min. size",  _BLUE_MIN);
     Dialog.addCheckbox("Remove scale", _REMOVE_SCALE);
     Dialog.show();
     _THRESHOLD_METHOD = Dialog.getChoice();
     _MIN_SIZE = Dialog.getNumber();
     _BLUE_THRESHOLD_METHOD =  Dialog.getChoice();
     _BLUE_MIN = Dialog.getNumber();
     _REMOVE_SCALE = Dialog.getCheckbox();
}

function analyseImage() {
    setForegroundColor(255, 255, 255);
    setBackgroundColor(0, 0, 0);

    if (_REMOVE_SCALE) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");

    title = getTitle();
    roiManager("Reset");
    selectImage(title);
    getDimensions(width, height, channels, slices, frames);
    if (slices>1) run("Z Project...", "projection=[Max Intensity]");
    projectionID = getImageID();
    Stack.setChannel(2);
    run("Duplicate...", " ");
    setAutoThreshold(_THRESHOLD_METHOD + " dark");
    run("Convert to Mask");
    run("Fill Holes");
    run("Watershed");
    run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Masks exclude in_situ");
    run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Nothing add");
    close();
    count = roiManager("count");
    selectImage(projectionID);
    if (channels>2) {
        Stack.setChannel(3);
        nrDeleted = 0;
        for(i=0; i<count; i++) {
           roiManager("select", i-nrDeleted);
           run("Duplicate...", " ");
           blueID = getImageID();
           run("Clear Outside");
           run("Select None");
           setAutoThreshold("Huang dark");
           selectImage(blueID);
           run("Clear Results");
           run("Analyze Particles...", "size=100-Infinity display");
           if (nResults!=1) {
	roiManager("select", i-nrDeleted);
	roiManager("delete");
	nrDeleted++;
           }
           selectImage(blueID);
           close();
           selectImage(projectionID);
        }
   }
   Stack.setChannel(1);
   count = roiManager("count");
   for(i=0; i<count; i++) {
     selectImage(projectionID);
     roiManager("select", i);
     getStatistics(area);
     getSelectionBounds(x, y, width, height);
     run("Duplicate...", " ");
     run("Clear Outside");
     run("Select None");
     protoplastID = getImageID();
     run("FindFoci", "mask=[None] background_method=[Std.Dev above mean] background_parameter=2 auto_threshold=Otsu statistics_mode=Both search_method=[Fraction of peak - background] search_parameter=0.30 minimum_size=5 minimum_above_saddle minimum_peak_height=[Relative above background] peak_parameter=0.50 sort_method=[Total intensity] maximum_peaks=500 show_mask=[Peaks above saddle] overlay_mask fraction_parameter=0.50 show_table clear_table mark_maxima show_log_messages results_directory=[] gaussian_blur=0 centre_method=[Max value (search image)] centre_parameter=2");
     numberOfFoci = getNumberOfFoci();
     results = getAverageFociAreaAndIntensity();
     fociArea = results[0];
     fociIntensity = results[1];
     fociID = getImageID();
     if (numberOfFoci>0) {
        selectImage(protoplastID);
        getSelectionBounds(x2, y2, width2, height2);
        roiManager("Add");
        selectImage(projectionID);
        roiManager("select", count);
        setSelectionLocation(x+x2, y+y2);
        run("Add Selection...");
        roiManager("select", count);
        roiManager("delete");
     }
     selectImage(protoplastID);
     close();
     selectImage(fociID);
     close();
     printResult(title, (i+1), numberOfFoci, area, fociArea, fociIntensity);
   }
}

function getNumberOfFoci() {
    selectWindow("FindFoci Results");
    text = getInfo("window.contents");
    lines = split(text, "\n");
    if (lines[2]=="") return 0;
    nr = lines.length - 3;
    return nr;
}

function getAverageFociAreaAndIntensity() {
    sizeIndex = 5;
    intensityIndex = 7;

    selectWindow("FindFoci Results");
    content = getInfo("window.contents");
    lines = split(content,"\n");
    count = 0;
    size = 0;
    intensity = 0;
    for(i=2; i<lines.length-1; i++) {
        line = lines[i];
        values = split(line, '\t');
        count++;
        currentSize = values[sizeIndex];
        size = size + currentSize;
        intensity = intensity + values[intensityIndex];    
     }

    size = size / count;
    intensity = intensity / count;

    results = newArray(2);
    results[0] = size;
    results[1] = intensity;
    return results;
}

function printResult(image, protoplast, numberOfFoci, area, fociArea, fociIntensity) {
    title = "protoplasts results";	
    handle = "["+title+"]";
    if (!isOpen(title)) {
          run("Table...", "name="+handle+" width=800 height=600");	
          print(handle, "\\Headings:image" + "\t" + "protoplast" + "\t" + "foci" + "\t" + "area" + "\t" + "density" + "\t" + "av. foci size" + "\t" + "av. total foci intensity");
    }
    density = numberOfFoci / area;
    print(handle, image + "\t" + protoplast + "\t" + numberOfFoci + "\t" + area + "\t" + density + "\t" + fociArea + "\t" + fociIntensity);
}


