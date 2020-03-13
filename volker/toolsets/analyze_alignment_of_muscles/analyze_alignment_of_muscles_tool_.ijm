var _BIN_NUMBER = 90;
var _BIN_START = 0;
var _BIN_END = 180;
var _SIGNAL_CHANNEL = 2;
var _FILE_EXTENSION = "jpg";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Analyze_Alignment_of_Muscles_Tool";

macro "Analyze Alignment of Muscles Action Tool - C000D00D01D02D03D0aD0bD0cD0dD0eD0fD2dD2eD2fDe2De3De4De5De6De7De8De9C050D14D15D30D3fD59D60D6cD8dDbfC010D1aD2cD46D49D4aD73D79D7aD7cD81D82D83D92D93D94DaeDafDd0DefDf2DfdC150D2aD31D32D38D3aD3dD8cD9cD9dDabDacDbcDbdDedDfbDffC010D1bD47D48D71D72D74D78D84D85Dd1Dd2Dd3Dd4Dd5Dd7DdfDf3Df4Df5Df7Df8Df9DfaDfcDfeC1a0D20D34D35D36D8fDa1Da2Da3Db9DbaDc6Dc7Dc8DccDceC030D10D11D12D18D19D41D42D43D4cD5bD5cD66D67D69D6aD6bD90De0Df0C3c1D24D25D28D3cD4fD5fD7fD86Da6DaaDcdDdcDddDdeC000D04D05D06D07D08D09D1cD1dD1eD1fD70D75D76D77D7bDd6Dd8Dd9DdaDdbDe1DeaDebDf6C180D33D37D39D4eD56D5eD62D63D7eD8eDa0Da4Da5DbbDc9DcaC020D40D44D45D4bD68D80D91D95DadDecDf1C2d0D21D22D23D26D27D29D3bD50D51D53D54D55D6dD6eDb8Dc3Dc4C3e0D52D6fDb0Db1Db2Db3Db4Db5Db6Db7Dc0Dc1Dc2Dc5C040D13D16D17D2bD4dD5aD5dD65D7dD9eD9fDeeC19aD87D88D89D8aD8bD96D97D98D99D9aD9bDa7Da8Da9C160D3eD57D58D61D64DbeDcbDcf"{
	help();
}

macro "help [f1]" {
	help();
}

macro "Analyze current image (f2) Action Tool - C000T4b12a" {
	analyzeCurrentImage();
}

macro "Analyze current image [f2]" {
	analyzeCurrentImage();
}

macro "Analyze current image (f2) Action Tool Options" {
	Dialog.create("Analyze Current Image Options");
	Dialog.addNumber("signal channel:", _SIGNAL_CHANNEL);
	Dialog.addNumber("number of bins:", _BIN_NUMBER);
	Dialog.addNumber("bin start:", _BIN_START);
	Dialog.addNumber("bin end:", _BIN_END);
    Dialog.show();
    _SIGNAL_CHANNEL = Dialog.getNumber();
	_BIN_NUMBER = Dialog.getNumber();
	_BIN_START =  Dialog.getNumber();
	_BIN_END =  Dialog.getNumber();
}

macro "Batch Analyze images (f3) Action Tool - C000T4b12b" {
	batchAnalyzeImages();
}

macro "Batch analyze images [f3]" {
	batchAnalyzeImages();
}

macro "Batch Analyze images (f3) Action Tool Options" {
	Dialog.create("Batch Analyze Images Options");
	Dialog.addString("file ext.:", _FILE_EXTENSION);
    Dialog.show();
    _FILE_EXTENSION = Dialog.getString();
}

var dCmds = newMenu("Images Menu Tool",
    newArray("download dataset", "ctrl", "grooves-10", "grooves-20", "grooves-30", "-", "options"));
    
macro "Images Menu Tool - CfffL00f0L0161CeeeD71CfffL81f1L0252CeeeD62C666D72CeeeD82CfffL92f2L0353CeeeD63C444D73CeeeD83CfffL93f3L0454CeeeD64C444D74CeeeD84CfffL94f4L0555CeeeD65C444D75CeeeD85CfffL95f5L0636CdddD46CfffD56CeeeD66C444D76CeeeD86CfffD96CdddDa6CfffLb6f6L0727CdddD37C444D47CbbbD57CeeeD67C444D77CeeeD87CbbbD97C444Da7CdddDb7CfffLc7f7L0838CbbbD48C444D58C999D68C444D78C999D88C444D98CbbbDa8CfffLb8f8L0949CbbbD59C333D69C111D79C333D89CbbbD99CfffLa9f9L0a5aCbbbD6aC444D7aCbbbD8aCfffL9afaL0b6bCeeeD7bCfffL8bfbL0c2cCeeeL3cbcCfffLccfcL0d1dCeeeD2dC666D3dC444L4dadC666DbdCeeeDcdCfffLddfdL0e2eCeeeL3ebeCfffLcefeL0fff" {
       cmd = getArgument();
       DATASET_DIR = call("ij.Prefs.get", "mribia.datasetDir", "/media/baecker/DONNEES1/mri/in");
       DATASET_NAME = "grooves";
       DATASET_SOURCE = ' http://dev.mri.cnrs.fr/attachments/download/';
       DATASET_VERSIONS = newArray('2177', '2179', '2180', '2181');
       DATASET_IMAGES = newArray('ctrl-002.jpg', 'grooves10-009.jpg', 'grooves20-020.jpg', 'grooves30-034.jpg');
       if (cmd=="download dataset") {
       	   print("Starting download of the grooves-dataset...");
       	   for (i = 0; i < DATASET_IMAGES.length; i++) {
       	   	   command = "wget -P "+DATASET_DIR+"/"+DATASET_NAME+"/"+" "+DATASET_SOURCE+DATASET_VERSIONS[i]+"/"+DATASET_IMAGES[i];
       	   	   print(command);
	       	   script = 'import os'+"\n"
	                   +'print(os.popen("'+command+'").read())';
	           print(script);
			   eval("python", script);
       	   }
		   print("...download of the grooves-dataset finished.");
       } 
       if (cmd=="ctrl") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/"+DATASET_IMAGES[0]+" autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="grooves-10") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/"+DATASET_IMAGES[1]+" autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="grooves-20") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/"+DATASET_IMAGES[2]+" autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="grooves-30") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/"+DATASET_IMAGES[3]+" autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="options") {
       	   Dialog.create("mribia options");
       	   Dialog.addMessage("These options are global and persistent.")
       	   Dialog.addString("input datasets directory: " , DATASET_DIR, 36);
       	   Dialog.show();
       	   DATASET_DIR = Dialog.getString();
       	   call("ij.Prefs.set", "mribia.datasetDir", DATASET_DIR); 
       }
       
}
function help() {
	run('URL...', 'url='+helpURL);
}

function analyzeCurrentImage() {
	title = getTitle();
	run("RGB Stack");
	setSlice(_SIGNAL_CHANNEL);
	run("Duplicate...", "title="+title+"-green");
	analyzeAlignment();
	close();
	run("RGB Color");
}

function batchAnalyzeImages() {
	dir = getDirectory("Choose the input folder!");
	files = getFileList(dir);
	images = filterFiles(dir, files);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("\\Clear"); 
	print("Analyze Alignment of Muscles started at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
	for (i = 0; i < images.length; i++) {
		print("\\Update1: Processing image " + (i+1) + "/" + images.length);
		image = images[i];
		open(dir + "/" + image);
		analyzeCurrentImage();
		close();
		selectWindow("Directionality histograms");
		
		saveAs("Results", dir + "/" + File.nameWithoutExtension + ".csv");
		close(File.nameWithoutExtension + ".csv");
	}
	selectWindow("Results");
    saveAs("Results", dir + "/directions.csv");
    getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print("Analyze Alignment of Muscles finished at: " + dayOfMonth + "." + (month+1) + "." + year + " " + hour + ":" + minute + ":" + second + "." + msec);
}

function filterFiles(dir, files) {
	filteredFiles = newArray(0);
	for(i=0; i<files.length; i++) {
		file = files[i];
		if (File.isDirectory(dir + "/" + file)) continue;
		if (!endsWith(file, "."+_FILE_EXTENSION)) continue;
		filteredFiles = Array.concat(filteredFiles, file);
	}
	return filteredFiles;
}

function analyzeAlignment() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/analyze_alignment_of_muscles_tool_.py");

	parameter = "binNumber=" + _BIN_NUMBER + ", binStart=" + _BIN_START+", binEnd="+_BIN_END;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}