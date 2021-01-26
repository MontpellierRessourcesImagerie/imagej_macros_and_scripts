/**
  * Arabidopsis Seedlings Tools
  *
  * Use color thresholding to detect the amount of seedlings per well.  
  * Automatic measurement of the different wells present in one image. 
  *
  * written 2010-2012 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  */

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Arabidopsis_Seedlings_Tool";
var ROWS = 2;
var COLUMNS = 3;
var OFFSET_X = 280;
var OFFSET_Y = 0;
var WELL_DIAMETER = 1250;
var L_MIN = 0;
var L_MAX = 255;
var a_MIN = 112;
var a_MAX = 255;
var b_MIN = 0;
var b_MAX = 255;

macro "Unused Tool - C037" { }

macro "Arabidopsis Seedlings Tools Help Action Tool - C770D57Db8Db9DbaDc8DcbC996D05D07D12D31D3bD40D4bD84D89Da4DaeDd3DdeDedDf6DfcC781D17D23D32D49D52D59D63D74D76D99Da6DacDb4DcdDd7De6De7DebCffeD2cD70D7aD82D8cD8dDfeC771D28D33D54D55Da7Da9DaaDbdDc5Dc6Dd8Dd9DdaDdbDe8De9DeaCddbD09D30D3cD4cD71D79D83D8aD8bD94Db2DbfDc2DcfDe3Df4C883D13D22D3aD41D5aD62D85D87D88D9aDa5DadDbeDceDe5Df8Df9DfaCfffD00D0cD0dD0eD0fD1cD1dD1eD1fD2dD2eD2fD3eD3fD4eD4fD5dD5eD5fD6dD6eD6fD7bD7cD7dD7eD7fD8fD90D91D92D9fDc0Dd0De0De1Df0Df1Df2C770D24D42D48D53Db5Dc7DccCbb9D03D04D08D1aD21D2bD50D5bD61D6aD72D9cD9dDa3DdfDeeDf5C782D14D18D29D39D4aD68D77D86D96Dc4Dd4Dd5DddDecCfffD01D0bD10D3dD4dD6cD80D81D8eD93Da0Da1Db0Db1Dc1Dd1De2Df3C781D15D16D38D64D65D66D67D75D97D98DabDd6DdcCffdD02D0aD11D1bD20D5cD60D6bD9eDa2DafDd2DefDfdDffC884D06D19D2aD51D69D73D78D95D9bDb3Dc3De4Df7DfbC780D25D26D27D34D35D36D37D43D44D45D46D47D56D58Da8Db6Db7DbbDbcDc9Dca"{
    run('URL...', 'url='+helpURL);
}

macro "run batch measurements Action Tool - C037T4d14r" {
    // reset imagej settings
    run("Colors...", "foreground=white background=black selection=yellow");
    run("Options...", "iterations=1 count=1");
    run("Set Measurements...", "area display redirect=None decimal=3");
    run("Clear Results");
    call("fr.cnrs.mri.macro.io.IOSettings.resetFileLists");
    call("fr.cnrs.mri.macro.io.IOSettings.show");
    waitForUser("Please select the input files using the IOSettings dialog and press ok");
    setBatchMode(true);
    IJ.log("\\Clear");
    list = call("fr.cnrs.mri.macro.io.IOSettings.getFileList");
    files = split(list, ",");
    if (list=="none") {
        IJ.log("No files selected! Macro stopped.");
       setBatchMode("exit & display");
       return;
    }
    for (i=0; i<files.length; i++) {
      file = files[i];
      IJ.log("\\Update0:Color Threshold - processing image nr. " + (i+1) + " from " + files.length);
      IJ.log("\\Update1: processing image: " + File.getName(file));
      open(file);
      // get image information
      original = getTitle();
      getDimensions(width, height, channels, slices, frames);
      stepX = WELL_DIAMETER; 
      stepY = height/ROWS;
      inFolder = File.getParent(file);
      outFolder = inFolder + "/control/";
      if (!File.exists(outFolder)) File.makeDirectory(outFolder);
      for (y=0; y<ROWS; y++) {
         for (x=0; x<COLUMNS; x++) {
             selectWindow(original);
             makeRectangle((x * stepX ) + OFFSET_X, (y * stepY ) + OFFSET_Y, stepX, stepY);
             parts = split(original, ".");
             title = parts[0] + "-" + x + "-" + y + "." + parts[1];
             completeTitle =  inFolder + "/" + title;
             completeTitle = replace(completeTitle, " ", "_");
             run("Duplicate...", "title=" + completeTitle);
             colorThreshold();	
             selectGreenAndMeasure(completeTitle);
             run("Make Inverse");
             if (selectionType() != -1) {
                run("Fill", "slice");
             }
             saveAs("jpg", outFolder + title);
             close();
       }
     }
     close();
    }
    file = files[0];
    folder = File.getParent(file);
    saveAs("Results", folder + "/" + "results.xls");
    setBatchMode("exit & display");
    IJ.log("finished color threshold");
}

macro 'run batch measurements Action Tool Options' {
    Dialog.create("Arabidopsis Seedlings Tool Option");
    Dialog.addMessage("Well Distribution Options");
    Dialog.addNumber("rows", ROWS);
    Dialog.addNumber("columns", COLUMNS);
    Dialog.addNumber("x-offset", OFFSET_X);
    Dialog.addNumber("y-offset", OFFSET_Y);
    Dialog.addNumber("diameter", WELL_DIAMETER);
    Dialog.addMessage("Color Thresholding Options");
    Dialog.addNumber("min. lightness ", L_MIN);
    Dialog.addNumber("max. lightness", L_MAX);
    Dialog.addNumber("min. red-green", a_MIN);
    Dialog.addNumber("max. red-green", a_MAX);
    Dialog.addNumber("min. yellow-blue", b_MIN);
    Dialog.addNumber("max. yellow-blue", b_MAX);
    Dialog.show();
    ROWS = Dialog.getNumber();
    COLUMNS = Dialog.getNumber();
    OFFSET_X = Dialog.getNumber();
    OFFSET_Y = Dialog.getNumber();
    WELL_DIAMETER =  Dialog.getNumber();
    L_MIN =  Dialog.getNumber();
    L_MAX =  Dialog.getNumber();
    a_MIN =  Dialog.getNumber();
    a_MAX =  Dialog.getNumber();
    b_MIN =  Dialog.getNumber();
    b_MAX =  Dialog.getNumber();
}

function colorThreshold() {
    // Colour Thresholding v1.8-------
    // Autogenerated macro, single images only!
    // G Landini 5/Jan/2007.
    //
    // This only works with Black background and White foreground!
    // You will probably have to uncomment the following 2 lines if
    // the settings in ImageJ are not so:
    //
    min=newArray(3);
    max=newArray(3);
    filter=newArray(3);
    original = getTitle();
    run("Duplicate...", "title=tmp-region");
    call("ij.plugin.frame.ColorThresholder.RGBtoLab");
    run("RGB Stack");
    selectWindow("tmp-region");
    run("Convert Stack to Images");
    selectWindow("Red");
    rename("0");
    selectWindow("Green");
    rename("1");
    selectWindow("Blue");
    rename("2");
    min[0]=L_MIN;
    max[0]=L_MAX;
    filter[0]="pass";
    min[1]=a_MIN;
    max[1]=a_MAX;
    filter[1]="pass";
    min[2]=b_MIN;
    max[2]=b_MAX;
    filter[2]="pass";
    for (i=0;i<3;i++){
       selectWindow(""+i);
       setThreshold(min[i], max[i]);
       run("Make Binary", "thresholded remaining");
       if (filter[i]=="stop")  run("Invert");
   }
    imageCalculator("AND create", "0","1");
    imageCalculator("AND create", "Result of 0","2");
    for (i=0;i<3;i++){
      selectWindow(""+i);
      close();
    }
    selectWindow("Result of 0");
    close();
    selectWindow("Result of Result of 0");
    // Colour Thresholding------------
}

function selectGreenAndMeasure(title) {
    run("Create Selection");
    hasSelection = true;
    if (selectionType()==-1) hasSelection = false;
    selectWindow(title);
    run("Restore Selection");
    selectWindow("Result of Result of 0");
    close();
    if (hasSelection) {
        run("Measure");
    } else {
        name = getTitle();
        setResult("Label", nResults, name);
        updateResults(); 	
    }
}
 
