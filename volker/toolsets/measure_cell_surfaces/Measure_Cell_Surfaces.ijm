/**
  * Measure surfaces of cells in widefield 2d images
  * 
  * written 2014 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * in collaboration with Samer Abdallah
  */

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Measure_Cell_Surfaces"

var NR_ERODE = 7;
var NR_DILATE = 2;
var THRESHOLD_METHOD = "Mean";
var DISTANCE_FROM_BORDER = 50;
var MIN_SIZE = 500;
var EXCLUDE_AT_EDGES = true;

macro "Unused Tool - C037" { }

macro "Measure Cell Surfaces Help Action Tool - C000C111D84D94D95Da6C111Da4C111D74D96Da5C111D85Db4Db5Db6C111D75C111D86Da7C111D76D83D93Db7C222D65D73D97C222D64Da3Dc5Dc6C222Db8Dc7C222D63D66C222D87Da8Db3Dc4C222Dc8C222D55D82C222D92Dd6C222D54Da2Dd5C222D98Dd7C222D72Db9Dc3Dc9C222D53D56D62D77Db2C333Dd8C333Dd4C333Dc2C333Da1Da9C333Db1Dd3Dd9C333D52D67D88D91C333D45D81De5De6De7C333D44DcaC333D61Dc1Dd2De4De8C333D71Db0C333D43D46Da0DbaDdaDe3C333D90D99Dc0Dd1C333D51De9C444D70D80DaaDd0De2Df5Df7C444D42Df4Df6C444D50D60D78De1Df3Df8C444D57De0Df2C444D40D41DeaDf1C444D34DbbDcbDf0Df9C444D33C444D32D35DdbC444DfaC444D30D36C444D01D02D07D14D15D16D31D9aDabC444D00D03D04D08D18D21D22D23D24D25D89DcfDebC444D09D10D11D13D17D20D26DbfDdfDfbDfeC444D05D06D0aD0bD12D19D1aD68DafDdeDffC444D27DccDdcDecDeeDefDfcDfdC444D0cD0dD1bD1dD1eD2aD47D9fDbcDceDddDedC555D1cD1fD28D2bD2dDbeC555D0eD0fD2eD3dD3fD4eD5eD8fC555D29D2cD2fD3eD4fD7fDcdC555D37D3cD6eC555D4dC555D5fD6fD7eDaeDbdC555D38D9eC555D8eC555D3bD9bC555D8aDacC555D79C555D39C555C666D3aD48C666D5dDadC666D4cD58C666D49C666D69D6dC666D9dC666D8bD9cC666D4aD7aC666D7dC777D8dC777D4bC777D59C777D5aD6aC777D7bD8cC777D5cC888D6bD7cC888D6cC888D5b"{
	run('URL...', 'url='+helpURL);
}

macro "Measure Surfaces Action Tool - C000T4b12m" {
    width = getWidth();
    height = getHeight();
	run("ROI Manager...");
    setBatchMode(true);
    roiManager("Reset");
    run("Abs"); 
    setOption("BlackBackground", true);
    resetThreshold();
    setAutoThreshold(THRESHOLD_METHOD + " dark");
    run("Convert to Mask");
    run("Despeckle");
    run("Fill Holes");
    for(i=0; i<NR_DILATE; i++) {
         run("Dilate");
    }
    run("Fill Holes");
    for(i=0; i<NR_ERODE; i++) {
         run("Erode");
    }
    makeRectangle(DISTANCE_FROM_BORDER, DISTANCE_FROM_BORDER, width-(2*DISTANCE_FROM_BORDER), height-(2*DISTANCE_FROM_BORDER));
    exclude = "";
    if (EXCLUDE_AT_EDGES) exclude = "exclude";
    run("Analyze Particles...", "size=" + MIN_SIZE + "-Infinity circularity=0.00-1.00 show=Nothing "+exclude+" add");
    run("Select None");
    run("Revert");
    setBatchMode("exit and display");
    roiManager("Measure");
}

macro "Measure Surfaces Action Tool Options" {
     Dialog.create("Measure Cell Surfaces Options");
     Dialog.addChoice("thresholding method", newArray("Default", "Huang", "Intermodes", "IsoData", "IJ_IsoData", "Li", "MaxEntropy", "Mean", "MinError",  "Minimum", "Moments",  "Otsu", "Percentile", "RenyiEntropy", "Shanbhag", "Triangle", "Yen"),  THRESHOLD_METHOD);
     Dialog.addNumber("number of dilations", NR_DILATE);
     Dialog.addNumber("number of erosions", NR_ERODE);
     Dialog.addNumber("distance from border", DISTANCE_FROM_BORDER);
     Dialog.addCheckbox("exclude on edges", EXCLUDE_AT_EDGES);
     Dialog.addNumber("min. size", MIN_SIZE);
     Dialog.show();
     THRESHOLD_METHOD = Dialog.getChoice();
     NR_DILATE = Dialog.getNumber();
     NR_ERODE = Dialog.getNumber();
     DISTANCE_FROM_BORDER = Dialog.getNumber();
     EXCLUDE_AT_EDGES = Dialog.getCheckbox();
     MIN_SIZE = Dialog.getNumber();
}
