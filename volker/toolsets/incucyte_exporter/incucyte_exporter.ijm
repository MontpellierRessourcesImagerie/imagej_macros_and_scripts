/*
 
 MRI Incucyte_Exporter
 
 Export the images from the Incucyte. Stitch the images, create a time-series and align the frames.
 (c) 2021, INSERM
 
 written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 
*/
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Incucyte_Exporter";
var PAD_NUMBERS = true;
var NR = "644";

var PROCESS_ALL = false;

var START_YEAR = "0001/";
var END_YEAR = "9901/";
var START_SERIES = "01/";
var END_SERIES = "31/";
var START_HOUR = "0000/";
var END_HOUR = "2359/";

var STITCHING_CHANNELS = newArray("C1","C2","P");
var STITCHING_CHANNEL = STITCHING_CHANNELS[0];

var ALIGNMENT_CHANNEL = "2";

var START_ROW = "A";
var END_ROW = "Z";
var START_COL = "01";
var END_COL = "26";
var BASE_DIR = "";
var GRID_SIZE_X = 4;
var GRID_SIZE_Y = 4;

var OVERLAP = 10;
var REGRESSION_THRESHOLD = 0.1;
var MAX_AVG_DISPLACEMENT_THRESHOLD = 2.50;
var ABS_DISPLACEMENT_THRESHOLD = 200;

var FUSION_METHOD = "Average";
var FUSION_METHODS = newArray("Linear Blending", "Average", "Max. Intensity", "Min Intensity", "None");
var FUSION = 1.50;
var YEARS = newArray(0);

var NUCLEI_CHANNEL = 2;
var MIN_CHOCLEA_AREA = 2000000000.00;
var MAX_CHOCLEA_AREA = 100000000000.00;

macro "Incucyte Exporter Help (f4) Action Tool-C000T4b12?" {
	help();
}

macro "Incucyte Exporter Help (f4) Action Tool Options" {
	showDialog();
}

macro "Incucyte Exporter Help [f4]" {
	help();
}

macro "export raw images as std. tif (f5) Action Tool-C999D42C555D52C111D62C000L7282C111D92C555Da2C999Db2CdddD23C111D33C000L43b3C111Dc3CdddDd3C222D24C000L34c4C222Dd4D25C000L35c5C222Dd5CdddD26C111D36C000L46b6C111Dc6CdddDd6C666D27C999D47C555D57C222D67C000L7787C222D97C555Da7C999Db7C666Dd7C000D28C555D38CcccD48Db8C444Dc8C000Dd8C999D29C000L3949C111D59C444L6999C111Da9C000Lb9c9C999Dd9CcccD2aCbbbD3aC444D4aC000L5aaaC444DbaCcccLcadaC111D2bCbbbD3bCcccL6b9bC999DcbC111DdbC444D2cC000D3cC222D4cC666D5cC888D6cCbbbL7c8cC888D9cC666DacC222DbcC000DccC444DdcC666D3dC000L4dbdC666DcdCeeeD4eC999D5eC888D6eC555L7e8eC888D9eC999DaeCeeeDbe" {
	 exportAsStdTif();
}

macro "export raw images as std. tif [f5]" {
	exportAsStdTif();
}

macro "export raw images as std. tif (f5) Action Tool Options" {
	showDialog();
}

macro "stitch images (f6) Action Tool-C111D22C000L3242CcccL5262C000L7282CcccL92a2C000Lb2c2C111Dd2C000L2343CcccL5363C000L7383CcccL93a3C000Lb3d3L2444CcccL5464C000L7484CcccL94a4C000Lb4d4CcccL2545L7585Lb5d5L2646L7686Lb6d6C000L2747CcccL5767C000L7787CcccL97a7C000Lb7d7L2848CcccL5868C000L7888CcccL98a8C000Lb8d8CcccL2949L7989Lb9d9L2a4aL7a8aLbadaC000L2b4bCcccL5b6bC000L7b8bCcccL9babC000LbbdbL2c4cCcccL5c6cC000L7c8cCcccL9cacC000LbcdcC111D2dC000L3d4dCcccL5d6dC000L7d8dCcccL9dadC000LbdcdC111Ddd" {
	stitchImages();	 
}

macro "stitch images [f6]" {
	stitchImages();	 
}

macro "stitch images (f6) Action Tool Options" {
	showDialog();
}

macro "clean images (f7) Action Tool-C000D4aD4bD5aD5bD6aD7aD7bD7cD89D8aD8bC888D29D3bD54D8eC333D6cD79D7dDb5CcccD36D53D5dD7eDb6Dc2C000D3aD6bD8cCaaaD46D49D98D9aDa5C666D4cD88Db4Dc4CeeeD6eC999D39D59D9bD9cD9dC444D5cD97Dc3Dd2CeeeD63D78D96D9eDd1C111D6dD8dDa6CbbbD37D64D75D76Dd3C777D2aD47D69D99Da7CfffD3cD85D86Db3"{
	cleanImages();	
}

macro "clean images [f7]" {
	cleanImages();	
}

macro "clean images (f7) Action Tool Options" {
	showDialog();
}

macro "merge images (f8) Action Tool-CbbbD22C222L3242CcccD52C222D23C000L3343C222D53C111D24C000L3444C111D54CcccD25C111L3545CcccD55C444D36C000D46CeeeD56C444D37C000L4757C444L6787C555D97C999Da7C444L3848C999D58C666D68C444L7898C000Da8C222Db8C444L3949CeeeDa9C000Db9C999Dc9CcccD2aC111L3a4aCcccD5aDaaC111LbacaCcccDdaC111D2bC000L3b4bC111D5bC222DabC000LbbcbC333DdbC222D2cC000L3c4cC222D5cDacC000LbcccC222DdcCbbbD2dC222L3d4dCbbbD5dDadC222LbdcdCbbbDdd" {
	mergeImages();	
}

macro "merge images [f8]" {
	mergeImages();
}

macro "merge images (f8) Action Tool Options" {
	showDialog();
}

macro "mark empty images [f9]" {
	markEmptyImages();
}

macro "mark empty images (f9) Action Tool - CfffL00f0L01f1L02f2L03f3L04b4C666Dc4CaaaDd4CfffLe4f4L05a5C666Db5C111Dc5CdddDd5CfffLe5f5L0696C666Da6C111Db6CdddDc6CfffLd6f6L0717CbbbD27C111D37CdddD47CfffL5787C666D97C111Da7CdddDb7CfffLc7f7L0828C333D38C111D48CdddD58CfffL6878C666D88C111D98CdddDa8CfffLb8f8L0939C333D49C111D59CdddD69C666D79C111D89CdddD99CfffLa9f9L0a4aC333D5aC111D7aCdddD8aCfffL9afaL0b5bC444D6bCdddD7bCfffL8bfbL0cfcL0dfdL0efeL0fff" {
	markEmptyImages();
}

macro "mark empty images (f9) Action Tool Options" {
	showDialog();
}

macro "make time series [f10]" {
	makeTimeSeries();
}

macro "make time series (f10) Action Tool - C000D25D26D29D2aD52D5dD62D6dD88D92D98D9dDa2Da8DadDd5Dd6Dd9DdaCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D1bD1cD1dD1eD1fD20D21D22D2dD2eD2fD30D31D36D37D38D39D3eD3fD40D41D45D46D47D48D49D4aD4eD4fD50D54D55D56D57D58D59D5aD5bD5fD60D63D64D65D66D67D68D69D6aD6bD6cD6fD70D73D7aD7bD7cD7fD80D83D8aD8bD8cD8fD90D93D94D95D96D97D9aD9bD9cD9fDa0Da4Da5Da6Da7DaaDabDafDb0Db1Db5Db6Db7DbaDbeDbfDc0Dc1Dc6Dc7Dc8Dc9DceDcfDd0Dd1Dd2DddDdeDdfDe0De1De2De3De4DebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC666D42D71D81Db2C333D33Dc3CcccD15D1aD4bD51D74D79D84Da1Db4DbbC000D34D43Db3Dc4C999DcaC444D7dD8dCeeeD23D2cD32D3dDb9Dc2DcdDd3DdcC999D61D91C333D27D28D72D75D76D77D78D82D85D86D87Dd7Dd8CdddD44D5eDaeDe5DeaC222D3cDccCbbbD89D99Da9Db8C555D17D18D24D2bD4dD7eD8eDbdDd4DdbC888D16D19D6eD9eDe6De9C111D3bD4cDbcDcbCaaaD35D3aD53D5cDa3DacDc5C666De7De8" {
	makeTimeSeries();
}

macro "make time series (f10) Action Tool Options" {
	showDialog();
}

macro "Modular Make Time Series"{
	modularMakeTimeSeries();
}

macro "batch export images [f11]" {
	batchExportImages();
}

macro "batch export images (f11) Action Tool-C000T4b12b" {
	batchExportImages();
}

macro "batch export images (f11) Action Tool Options" {
	showDialog();
}

function help() {
	run('URL...', 'url='+helpURL);
}

function old_batchExportImages() {
	report("starting export...");
	exportAsStdTif();
	report("starting stitch...");
	stitchImages();
	report("starting clean...");
	cleanImages();
	report("starting merge...");
	mergeImages();
	report("starting mark empty...");
	markEmptyImages();
	report("starting align...");
	makeTimeSeries();
	report("export finished");
}

function batchExportImages(){
	Dialog.create("Batch Export Options");
	
	Dialog.addCheckbox("Export as Standard Tif", true);
	Dialog.addCheckbox("Stitch Images", true);
	Dialog.addCheckbox("Clean Images ", true);
	Dialog.addCheckbox("Merge Images ", true);
	Dialog.addCheckbox("Mark Empty Images", true);
	Dialog.addCheckbox("Make Time Series", true);

	Dialog.show();
	
	exportTif	= Dialog.getCheckbox();
	stitchImg	= Dialog.getCheckbox();
	cleanImg	= Dialog.getCheckbox();
	mergeImg	= Dialog.getCheckbox();
	markEmpty	= Dialog.getCheckbox();
	makeTimeSer	= Dialog.getCheckbox();
	

	setBatchMode(true);
	if(exportTif){
		report("starting export...");
		exportAsStdTif();
	}
	if(stitchImg){
		report("starting stitch...");
		stitchImages();
	}
	if(cleanImg){
		report("starting clean...");
		cleanImages();
	}
	if(mergeImg){
		report("starting merge...");
		mergeImages();
	}
	if(markEmpty){
		report("starting mark empty...");
		markEmptyImages();
	}
	if(makeTimeSer){
		report("starting align...");
		makeTimeSeries();
	}
	report("export finished");
	setBatchMode(false);
}

function report(message) {
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	print(""+year+(month+1)+dayOfMonth+"-"+hour+":"+minute+":"+second+"."+msec + " -- " + message);
}

function exportAsStdTif() {	
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				inDir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + NR + "/";
				images = getFileList(inDir);
				outDir =  inDir + "exported/";
				if (!File.exists(outDir)) File.makeDirectory(outDir);
				for(i=0; i<images.length; i++) {
					image = images[i];			
					if (File.isDirectory(inDir+image) || !endsWith(image, ".tif")) continue;
					if (PAD_NUMBERS) image = padNumbers(image);	
					parts = split(image,"-");
					well = parts[0];
					row = substring(well, 0, 1);
					column = substring(well, 1, well.length);
					if (row<START_ROW || row>END_ROW) continue;
					column = IJ.pad(column, 2);
					if (column<START_COL || column>END_COL) continue;
					print("Converting " + inDir+images[i]);
					run("Bio-Formats", "open=["+inDir+images[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
					run("16-bit");
					saveAs("tiff", outDir+image);
					close();
				}
			}
		}
	}
	setBatchMode(false);
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Export as Standard Tif");
}

function stitchImages() {
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				inDir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + NR + "/exported/";
				calculateStitchings(inDir);
			}
		}
	}
	setBatchMode(false);
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Stitch Images");
}


function calculateStitchings(dir) {
	files = getFileList(dir);
	images = filterChannelOneImages(files);
	wells = getWells(images);
	for (i = 0; i < wells.length; i++) {
		well = wells[i];

		run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x="+GRID_SIZE_X+" grid_size_y="+GRID_SIZE_Y+" tile_overlap="+OVERLAP+" first_file_index_i=1 directory="+dir+" file_names="+well+"-{ii}-"+STITCHING_CHANNEL+".tif output_textfile_name="+well+"-"+STITCHING_CHANNEL+"-translations.txt fusion_method=["+FUSION_METHOD+"] regression_threshold="+REGRESSION_THRESHOLD+" max/avg_displacement_threshold="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute_displacement_threshold="+ABS_DISPLACEMENT_THRESHOLD+" compute_overlap subpixel_accuracy computation_parameters=[Save memory (but be slower)] output_directory="+dir);
		close();
		
		translations = File.openAsString(dir + well+"-"+STITCHING_CHANNEL+"-translations.registered.txt");
		translations = replace(translations, well+"-", dir+well+"-");
		
		translations = replace(translations, "-"+STITCHING_CHANNEL+".tif", "-C1.tif");
		File.saveString(translations, dir + well+"-C1-translations.registered.txt");

		translations = replace(translations, "-C1.tif", "-C2.tif");
		File.saveString(translations, dir + well+"-C2-translations.registered.txt");
		
		translations = replace(translations, "-C2.tif", "-P.tif");
		File.saveString(translations, dir + well+"-P-translations.registered.txt");
	}	
}

function cleanImages() {
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	if(!isDBRootFolder(root)) exit("db not found!");
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				dir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + NR + "/exported/";
				files = getFileList(dir);
				images = filterChannelOneImages(files);
				wells = getWells(images);
				outDir = dir + "clean/";
				if (!File.exists(outDir)) File.makeDirectory(outDir);
				for (i = 0; i < wells.length; i++) {
					well = wells[i];
					print("Cleaning " + dir+well+"...");
					run("Image Sequence...", "dir="+dir+" filter=("+well+"-..-C1) sort");
					cleanImage();
					run("Image Sequence... ", "dir="+outDir+" format=TIFF use");
					close();
					run("Image Sequence...", "dir="+dir+" filter=("+well+"-..-C2) sort");
					cleanImage();
					run("Image Sequence... ", "dir="+outDir+" format=TIFF use");
					close();
					
					translations = File.openAsString(dir + well+"-C1-translations.registered.txt");
					translations = replace(translations, well+"-", "clean/"+well+"-");
					File.saveString(translations, outDir + well + "-C1-translations.registered.txt");
					translations = replace(translations, "-C1.tif", "-C2.tif");
					File.saveString(translations, outDir + well + "-C2-translations.registered.txt"); 
				}
			}
		}
	}
	setBatchMode(false);
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Clean Images");
}

function mergeImages() {
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	if(!isDBRootFolder(root)) exit("db not found!");
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				tifDir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + NR + "/exported/";
				dir = tifDir + "clean/";
				files = getFileList(dir);
				images = filterChannelOneImages(files);
				wells = getWells(images);
				outDir =  dir + "merged/";
				if (!File.exists(outDir)) File.makeDirectory(outDir);
				for (i = 0; i < wells.length; i++) {
					well = wells[i];
					run("Stitch Collection of Images", "layout="+dir+well+"-C1-translations.registered.txt channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method="+FUSION_METHOD+" fusion="+FUSION+" regression="+REGRESSION_THRESHOLD+" max/avg="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute="+ABS_DISPLACEMENT_THRESHOLD);
					rename("C1");
					run("Enhance Contrast", "saturated=0.35");
					run("Stitch Collection of Images", "layout="+dir+well+"-C2-translations.registered.txt channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method="+FUSION_METHOD+" fusion="+FUSION+" regression="+REGRESSION_THRESHOLD+" max/avg="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute="+ABS_DISPLACEMENT_THRESHOLD);
					rename("C2");
					run("Enhance Contrast", "saturated=0.35");
					run("Stitch Collection of Images", "layout="+tifDir+well+"-P-translations.registered.txt channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method="+FUSION_METHOD+" fusion="+FUSION+" regression="+REGRESSION_THRESHOLD+" max/avg="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute="+ABS_DISPLACEMENT_THRESHOLD);
					rename("P");					
					run("Enhance Contrast", "saturated=0.35");
					run("Merge Channels...", "c1=[C2] c3=[C1] c4=[P] create");
					saveAs("tiff", outDir + well + ".tif");
					run("Close All");
				}
			}
		}
	}	
	setBatchMode(false);
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Merge Images");
}

function markEmptyImages() {
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	if(!isDBRootFolder(root)) exit("db not found!");
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				mergedDir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + NR + "/exported/clean/merged/";
				files = getFileList(mergedDir);
				for (i = 0; i < files.length; i++) {
					file = files[i];
					open(mergedDir + file);
					test = testIfImageContainsCochlea();
					close("*");
					if (!test) File.rename(mergedDir + file, mergedDir+"Empty_"+file);
				}
				
			}
		}
	}
	setBatchMode(false);
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Mark Empty Images");	
}

function modularMakeTimeSeries(){
	Dialog.create("Which step to do ?");
	Dialog.addCheckbox("Resize Positions", true);
	Dialog.addCheckbox("Concatenate Series", true);
	Dialog.addCheckbox("Align Series Manually", true);
	Dialog.addCheckbox("Align Series with HyperStack Reg", true);

	Dialog.show();
	resizePos = Dialog.getCheckbox();
	concatSer = Dialog.getCheckbox();
	alignMan  = Dialog.getCheckbox();
	alignHSR  = Dialog.getCheckbox();
	
	timeStart = getTime();
	if(resizePos){
		resizePositions();
	}
	if(concatSer){
		concatenateSeries();
	}
	if(alignMan){
		alignSeriesManually();
	}
	if(alignHSR){
		alignSeries();
	}
	
	print("make time-series finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Modular Make Time Series" + resizePos+""+concatSer+""+alignMan+""+alignHSR);
}

macro "Make One Time Serie" {
	startPositions =getStartPositions();
	
	Dialog.create("Make One Time-series Options");
	
	Dialog.addChoice("Position", startPositions);
	Dialog.addCheckbox("Resize Positions", true);
	Dialog.addCheckbox("Concatenate Series", true);
	Dialog.addCheckbox("Align Series Manually", true);
	Dialog.addCheckbox("Align Series with HyperStack Reg", true);

	Dialog.show();
	
	pos = Dialog.getChoice();
	resizePos = Dialog.getCheckbox();
	concatSer = Dialog.getCheckbox();
	alignMan  = Dialog.getCheckbox();
	alignHSR  = Dialog.getCheckbox();
	
	modularMakeOneTimeSerie(pos,resizePos,concatSer,alignMan,alignHSR);
}
function modularMakeOneTimeSerie(pos,resizePos,concatSer,alignMan,alignHSR){
	
	
	timeStart = getTime();
	setBatchMode(true);
	if(resizePos){
		resizeCanvas(pos);
	}
	if(concatSer){
		concatenatePosition(pos);
	}
	if(alignMan){
		alignPositionManually(pos);
	}
	if(alignHSR){
		alignPosition(pos);
	}
	setBatchMode(false);
	
	print("make one time-series finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Modular Make One Time Series" + resizePos+""+concatSer+""+alignMan+""+alignHSR);

}

function makeTimeSeries(){
	timeStart = getTime();
	
	resizePositions();
	concatenateSeries();
	alignSeriesManually();
	alignSeries();
	
	print("make time-series finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Make Time Series");
}

function resizePositions(){
	checkAndGetBaseDir();
	timeStart = getTime();

	setBatchMode(true);
	startPositions = getStartPositions();
	for (i=0; i<startPositions.length; i++) {
		pos = startPositions[i];
		if(endsWith(pos, "/")) continue;
		resizeCanvas(pos);
	}
	setBatchMode(false);
	print("Resize Positions finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Resize Positions");
}

function concatenateSeries(){
	checkAndGetBaseDir();
	timeStart = getTime();
	
	setBatchMode(true);
	startPositions = getStartPositions();
	for (i=0; i<startPositions.length; i++) {
		pos = startPositions[i];
		if(endsWith(pos, "/")){	continue;}
		concatenatePosition(pos);
	}
	setBatchMode(false);
	print("Concatenate Series finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Concatenate Series");
}

function alignSeriesManually(){
	checkAndGetBaseDir();
	timeStart = getTime();
	
	setBatchMode(true);
	startPositions = getStartPositions();
	for (i=0; i<startPositions.length; i++) {
		pos = startPositions[i];
		if(endsWith(pos, "/")){	continue;}
		alignPositionManually(pos);
	}
	setBatchMode(false);
	print("Align Series Manually finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Align Series Manually");
}


function alignSeries(){
	checkAndGetBaseDir();
	timeStart = getTime();

	setBatchMode(true);
	startPositions = getStartPositions();
	for (i=0; i<startPositions.length; i++) {
		pos = startPositions[i];
		if(endsWith(pos, "/")){	continue;}
		alignPosition(pos);
	}
	setBatchMode(false);
	print("Align Series finished");
	timeEnd = getTime();
	displayPrettyTime(timeEnd-timeStart,"Align Series");
}


function resizeCanvas(pos){
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	subfolders = NR + "/exported/" + "clean/" + "merged/";
	
	dims = getMaxDimensions(pos);
	timePoints = getTimePoints(pos);
	print("Resizing Canvas "+pos+"...");
	for (t=0; t<timePoints.length; t++) {	
		if(!File.isDirectory(dataDir + timePoints[t] + subfolders +"resized/")){
			File.makeDirectory(dataDir + timePoints[t] + subfolders +"resized/");
		}
		path = dataDir + timePoints[t] + subfolders;
		if(File.exists(path+"Empty_"+pos)){
			open(path+"Empty_"+pos);
			
		}else{
			open(path + pos);
		}
		run("Canvas Size...", "width="+dims[0]+" height="+dims[1]+" position=Center zero");
		saveAs(path +"resized/"+ pos);
		close();
	}
	print("\\Update:Canvas "+pos+" Resized");
}

function concatenatePosition(pos){
	root = BASE_DIR;
	dataDir = root + "EssenFiles/ScanData/";
	subfolders = NR + "/exported/" + "clean/" + "merged/";
	outDir	= dataDir + "concat/";
	if(!File.isDirectory(outDir)){
		File.makeDirectory(outDir); 
	}
	
	timePoints = getTimePoints(pos);
	print("Concatenating position " + pos + " " + 0 +"/" + timePoints.length);
	for (t=0; t<timePoints.length; t++) {
		path = dataDir + "/" + timePoints[t] + subfolders + "resized/"+ pos;
		if (File.exists(path)) {
			open(path);				
		}
		else {
			path = dataDir + "/" + timePoints[t] + subfolders + pos;	
			open(path);				
		}
		if(t==0){
			rename("title_0");
		}else{
			title = getTitle();
			print("\\Update:Concatenating position " + pos + " " + t + "/" + timePoints.length);
			run("Concatenate...", " title=title_0 open image1=title_0 image2="+title);
		}
	}
	print("\\Update:Position " + pos + " concatenated:" +outDir+pos);
	saveAs("tiff", outDir + pos);
	close("*");
}

function alignPositionManually(pos){
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	inDir = dataDir + "concat/";
	outDir = dataDir + "manually_aligned/";
	if(!File.isDirectory(outDir)){
		File.makeDirectory(outDir); 
	}
	
	open(inDir + pos);
	print("Manually Aligning position " + pos);
	manualAlignment();
	
	print("\\Update:Position " + pos + " manually Aligned!");
	saveAs("tiff", outDir + pos);
	close("*");
}

function alignPosition(pos){
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	inDir = dataDir + "manually_aligned/";
	outDir = dataDir + "aligned/";
	if(!File.isDirectory(outDir)){
		File.makeDirectory(outDir); 
	}
	
	open(inDir + pos);
	print("Aligning position " + pos);
	run("HyperStackReg ", "transformation=[Rigid Body] channel"+ALIGNMENT_CHANNEL+" show");
	
	print("Position " + pos + " Aligned!");
	saveAs("tiff", outDir + pos);
	close("*");
}

function manualAlignment(){
	run("Duplicate...", "duplicate channels=2");
	
	run("Enhance Contrast...", "saturated=0.2 process_all");
	
	setThreshold(65530, 65535);
	run("Make Binary", "method=Default background=Dark");
	run("Set Measurements...", "centroid center stack display redirect=None decimal=3");
	
	run("Options...", "iterations=20 count=1 do=Nothing");
	run("Close-", "stack");
	run("Options...", "iterations=10 count=1 do=Nothing");
	run("Open", "stack");

	roiManager("Deselect");
	if(roiManager("count")>=1){
		roiManager("Delete");
	}
	
	centerX = newArray();
	centerY = newArray();
	timePointCount = nSlices;
	for(s=1;s<=timePointCount;s++){
		setSlice(s);
		run("Create Selection");
		run("Convex Hull");
		centerX[s-1]=getValue("X");
		centerY[s-1]=getValue("Y");
		//print(centerX[s-1]," ",centerY[s-1]);
	}
	close();
	for(s=2;s<=timePointCount;s++){
		dX=centerX[0]-centerX[s-1];
		dY=centerY[0]-centerY[s-1];
		toUnscaled(dX);
		toUnscaled(dY);
		for(c=1;c<=3;c++){
			Stack.setPosition(c, 1, s); 
			run("Select All");
			run("Translate...", "x="+dX+" y="+dY+" interpolation=None slice");
		}
	}
}

function padNumbers(image) {
	parts = split(image, '-');
	leftPart=parts[0];
	nrString = parts[1];
	rightPart = parts[2];
	nrString = IJ.pad(nrString, 2);
	result = leftPart+"-"+nrString+"-"+rightPart;
	return result;
}

function contains(array, element) {
	for (i = 0; i < array.length; i++) {
		if (array[i]==element) return true;
	}
	return false;
}

function filterChannelOneImages(files) { 
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (File.isDirectory(file) || !endsWith(file, "C1.tif")) continue;
		images = Array.concat(images, file);
	}
	return images;
}

function getWells(images) {
	wells = newArray(0);
	for (i = 0; i < images.length; i++) {
		image = images[i];
		parts = split(image, '-');
		well = parts[0];
		if (!contains(wells, well)) wells = Array.concat(wells, well);
	}
	return wells;
}

function cleanImage() {
	Stack.getDimensions(width, height, channels, slices, frames);
	run("32-bit");
	sumOfMeans = 0;
	maxIndes = 1;
	bestMax = 0;
	for (i = 0; i < slices; i++) {
		setSlice(i+1);
		getStatistics(area, mean, min, max, std, histogram);
		sumOfMeans += mean;
		run("Divide...", "value="+mean+" slice");
		if (max>bestMax) {
			maxIndex = (i+1);
			bestMax = max;
		}
	}
	avgMean = sumOfMeans / slices;
	run("Multiply...", "value="+avgMean + " stack");
	setSlice(maxIndex);
	run("16-bit");
	run("Subtract Background...", "rolling=50 stack");
}

function checkAndGetBaseDir() {
	requires("1.53j");
	BASE_DIR = call("ij.Prefs.get", "incucyte.basedir", "");
	while (!isDBRootFolder(BASE_DIR)) {
		BASE_DIR = getDir("Please select the root folder of the database!");
	}
	if (indexOf(BASE_DIR, " ")>-1) {
		call("ij.Prefs.set", "incucyte.basedir", "");
		BASE_DIR = "";
		showMessage("WARNING!", "Your path contains spaces. Please remove all spaces from the path first!");
		return;
	}
	call("ij.Prefs.set", "incucyte.basedir", BASE_DIR);
}

function isDBRootFolder(dir) {
	files = getFileList(dir);
	result = contains(files, "EssenFiles/");
	return result;
}
	
function testIfImageContainsCochlea() {
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+NUCLEI_CHANNEL+"-"+NUCLEI_CHANNEL);
	run("Median...", "radius=2");
	setAutoThreshold("Default dark");
	run("Create Selection");
	getStatistics(area);
	run("Select None");
	run("Analyze Particles...", "size="+MIN_CHOCLEA_AREA+"-Infinity add");
	count = roiManager("count");
	if ((count<1) ||  (area>MAX_CHOCLEA_AREA)) return false;
	return true;
}

function getFirstYearDayAndHour() {
	checkAndGetBaseDir();
	root = BASE_DIR;
	if(!isDBRootFolder(root)) exit("db not found!");
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	year = -1;
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		break;
	}
	days = getFileList(dataDir + "/" + year);
	for(d=0; d<days.length; d++) {
		if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
		day = days[d];
		break;
	}
	hours = getFileList(dataDir + "/" + year + "/" + day);
	for(h=0; h<hours.length; h++) {
		if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
		hour = hours[h];	
		break;	
	}
	return newArray(year, day, hour);
}

function getStartPositions() {
	firstTime = getFirstYearDayAndHour();
	root = BASE_DIR;
	if(!isDBRootFolder(root)) exit("db not found!");
	dataDir = root+"EssenFiles/ScanData/";
	
	folder = dataDir + firstTime[0] + "/" + firstTime[1] + "/" + firstTime[2] + "/" + NR + "/exported/clean/merged";
	startPositions = getFileList(folder);
	startPositions = filterEmpty(startPositions);
	return startPositions;
}

function filterEmpty(files) {
	newFiles = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, "Empty")<0) newFiles = Array.concat(newFiles, file);
	}
	return newFiles;
}

function getTimePoints(position) {
	checkAndGetBaseDir();
	root = BASE_DIR;
	if(!isDBRootFolder(root)) exit("db not found!");
	dataDir = root+"EssenFiles/ScanData/";
	timePoints = newArray(0);
	years = getFileList(dataDir);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				files = getFileList(dataDir + "/" + year + "/" + day + "/" + hour + "/" + NR + "/exported/clean/merged");
				if (!contains(files, position)) continue;
				timePoints = Array.concat(timePoints, year+day+hour);
			}
		}
	}
	return timePoints;
}

function displayPrettyTime(time_ms,message){
	secondElapsed 	= (time_ms) / 1000;
	minuteElapsed 	= 0;
	hourElapsed 	= 0;
	dayElapsed		= 0;
	
	prettyTime = "Duration: ";
	if(secondElapsed>60){
		minuteElapsed = floor(secondElapsed/60);
		if(minuteElapsed>60){
			hourElapsed = floor(minuteElapsed/60);
			if(hourElapsed>24){
				dayElapsed = floor(hourElapsed/24);

				dayElapsed = dayElapsed%24;
				prettyTime = prettyTime + dayElapsed +" d ";
			}
			hourElapsed = hourElapsed%24;
			prettyTime = prettyTime + hourElapsed +" h ";
		}
		minuteElapsed = minuteElapsed % 60;
		prettyTime = prettyTime + minuteElapsed +" min ";
	}
	secondElapsed = secondElapsed % 60;
	prettyTime = prettyTime + secondElapsed +" s";
	print(message + ":" + prettyTime);
	
	if(Table.title == "Results"){
		Table.create("Durations");
	}
	size = Table.size;
	Table.set("Action",size,message,"Durations");
	Table.set("Day",size,dayElapsed,"Durations");
	Table.set("Hour",size,hourElapsed,"Durations");
	Table.set("Minute",size,minuteElapsed,"Durations");
	Table.set("Second",size,secondElapsed,"Durations");
	Table.update;
	
}

function getMaxDimensions(position) {
	timePoints = getTimePoints(position);
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	path1 = dataDir + "/" + timePoints[0] + NR + "/exported/clean/merged/" + pos;
	
	run("Bio-Formats Macro Extensions");
	
	Ext.setId(path1);
	Ext.getSizeX(width);
	Ext.getSizeY(height);
	
	maxWidth = width;
	maxHeight = height;
	for (t=0; t<timePoints.length-1; t++) {
		path2 = dataDir + "/" + timePoints[t+1] + NR + "/exported/clean/merged/" + pos;
		Ext.setId(path2);
		Ext.getSizeX(width);
		Ext.getSizeY(height);
		if (width > maxWidth) maxWidth = width;
		if (height > maxHeight) maxHeight = height;
		if(verbose){
			Table.set("timePoint", t, timePoints[t+1]);
			Table.set("width" , t, width );
			Table.set("height", t, height);
			Table.set("maxWidth" , t, maxWidth );
			Table.set("maxHeight", t, maxHeight);
		}
	}
	
	Ext.close();
	return newArray(maxWidth, maxHeight);
}

function showDialog() {
	checkAndGetBaseDir();
	dataDir = BASE_DIR+"EssenFiles/ScanData/";
	Dialog.create("Options of Incucyte Exporter");
	Dialog.addDirectory("db base folder: ", BASE_DIR);

	START_YEAR = replace(START_YEAR, "/", "");
	END_YEAR = replace(END_YEAR, "/", "");
	START_SERIES = replace(START_SERIES, "/", "");
	END_SERIES = replace(END_SERIES, "/", "");
	START_HOUR = replace(START_HOUR, "/", "");
	END_HOUR = replace(END_HOUR, "/", "");
	
	Dialog.addString("   start year/month: ", START_YEAR);
	Dialog.addToSameRow();
	Dialog.addString("   end year/month: ", END_YEAR);
	
	Dialog.addString("   start day: ", START_SERIES);
	Dialog.addToSameRow();
	Dialog.addString("   end day: ", END_SERIES);

	Dialog.addString("   start hour: ", START_HOUR);
	Dialog.addToSameRow();
	Dialog.addString("   end hour: ", END_HOUR);

	Dialog.addString("   start row: ", START_ROW);
	Dialog.addToSameRow();
	Dialog.addString("   end row: ", END_ROW);

	Dialog.addString("   start column: ", START_COL);
	Dialog.addToSameRow();
	Dialog.addString("   end column: ", END_COL);

	Dialog.addNumber("nuclei channel: ", NUCLEI_CHANNEL);
	Dialog.addNumber("min. object area: ", MIN_CHOCLEA_AREA, 2, 25, "");
	Dialog.addNumber("max. object area: ", MAX_CHOCLEA_AREA, 2, 25, "");

	Dialog.addMessage("Stitching:");

	Dialog.addChoice("stitching channel: ", STITCHING_CHANNELS, STITCHING_CHANNEL);
	Dialog.addNumber("grid size x: ", GRID_SIZE_X);
	Dialog.addNumber("grid size y: ", GRID_SIZE_Y);
	Dialog.addNumber("overlap: ", OVERLAP);
	Dialog.addNumber("regression threshold: ", REGRESSION_THRESHOLD);
	Dialog.addNumber("max/avg displacement threshold: ", MAX_AVG_DISPLACEMENT_THRESHOLD);
	Dialog.addNumber("abs displacement threshold: ", ABS_DISPLACEMENT_THRESHOLD);
	Dialog.addChoice("fusion method: ", FUSION_METHODS, FUSION_METHOD);
	Dialog.addNumber("fusion: ", FUSION);

	Dialog.addMessage("Aligment");

	Dialog.addNumber("Alignment channel", ALIGNMENT_CHANNEL);
			
	Dialog.show();
	
	BASE_DIR = Dialog.getString();
	call("ij.Prefs.set", "incucyte.basedir", BASE_DIR);
	checkAndGetBaseDir();
	START_YEAR = Dialog.getString();
	END_YEAR = Dialog.getString();
	START_SERIES = Dialog.getString();
	END_SERIES = Dialog.getString();
	START_HOUR = Dialog.getString();
	END_HOUR = Dialog.getString();
	START_ROW = Dialog.getString();
	END_ROW = Dialog.getString();
	START_COL = Dialog.getString();
	END_COL = Dialog.getString();

	START_YEAR = START_YEAR + "/";
	END_YEAR = END_YEAR + "/";
	START_SERIES = START_SERIES + "/";
	END_SERIES = END_SERIES + "/";
	START_HOUR = START_HOUR + "/";
	END_HOUR = END_HOUR + "/";
	START_COL = IJ.pad(START_COL, 2);
	END_COL = IJ.pad(END_COL, 2);

	NUCLEI_CHANNEL = Dialog.getNumber();
	MIN_CHOCLEA_AREA = Dialog.getNumber();
	MAX_CHOCLEA_AREA = Dialog.getNumber();

	STITCHING_CHANNEL = Dialog.getChoice();
	GRID_SIZE_X = Dialog.getNumber();
	GRID_SIZE_Y = Dialog.getNumber();
	OVERLAP = Dialog.getNumber();
	REGRESSION_THRESHOLD = Dialog.getNumber();
	MAX_AVG_DISPLACEMENT_THRESHOLD = Dialog.getNumber();
	ABS_DISPLACEMENT_THRESHOLD = Dialog.getNumber();
	FUSION_METHOD = Dialog.getChoice();
	FUSION = Dialog.getNumber();

	ALIGNMENT_CHANNEL = Dialog.getNumber();
}

macro "TMP Stitch with propagation on one position" {
	
	checkAndGetBaseDir();
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	firstTime = getFirstYearDayAndHour();
	firstTimeFolder = dataDir + firstTime[0] + firstTime[1] + firstTime[2] + NR + "/exported/";
	files = getFileList(firstTimeFolder);
	images = filterChannelOneImages(files);
	wells=getWells(images);

	
	Dialog.create("Stitch with propagation on one position");
	
	Dialog.addChoice("Position", wells);
	Dialog.addCheckbox("Calculate First Stitching", true);
	Dialog.addCheckbox("Propagate Stitching", true);
	Dialog.addCheckbox("Clean Well", true);
	Dialog.addCheckbox("Execute Stitching", true);
	Dialog.addCheckbox("Concatenate Time-serie", true);

	Dialog.show();
	
	pos = Dialog.getChoice();
	calcStitch = Dialog.getCheckbox();
	propStitch = Dialog.getCheckbox();
	cleanWell  = Dialog.getCheckbox();
	execStitch = Dialog.getCheckbox();
	concatTime = Dialog.getCheckbox();
	

	setBatchMode(true);
	
	if(calcStitch){
		calculateOneStitching(firstTimeFolder,pos);
	}
	if(propStitch){
		propagateStitching(pos);
	}
	if(cleanWell){
		cleanOnePosition(pos);
	}
	if(execStitch){
		stitchPositionAtEachTime(pos);
	}
	if(concatTime){
		concatenatePosition(pos+".tif");
	}
	setBatchMode(false);
	print("Stitching of well " + pos + " finished");
}



function stitchAllChannels(inDir,well){
	cleanDir = inDir + "clean/";
	outDir = cleanDir + "merged/";
	if (!File.exists(outDir)) File.makeDirectory(outDir);
	
	run("Stitch Collection of Images", "layout="+cleanDir+well+"-C1-translations.registered.txt channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method="+FUSION_METHOD+" fusion="+FUSION+" regression="+REGRESSION_THRESHOLD+" max/avg="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute="+ABS_DISPLACEMENT_THRESHOLD);
	rename("C1");
	run("Enhance Contrast", "saturated=0.35");
	run("Stitch Collection of Images", "layout="+cleanDir+well+"-C2-translations.registered.txt channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method="+FUSION_METHOD+" fusion="+FUSION+" regression="+REGRESSION_THRESHOLD+" max/avg="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute="+ABS_DISPLACEMENT_THRESHOLD);
	rename("C2");
	run("Enhance Contrast", "saturated=0.35");
	run("Stitch Collection of Images", "layout="+inDir+well+"-P-translations.registered.txt channels_for_registration=[Red, Green and Blue] rgb_order=rgb fusion_method="+FUSION_METHOD+" fusion="+FUSION+" regression="+REGRESSION_THRESHOLD+" max/avg="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute="+ABS_DISPLACEMENT_THRESHOLD);
	rename("P");				
	run("Enhance Contrast", "saturated=0.35");
	run("Merge Channels...", "c1=[C2] c3=[C1] c4=[P] create");
	saveAs("tiff", outDir + well + ".tif");
	run("Close All");
}


function calculateOneStitching(dir,well){
	run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x="+GRID_SIZE_X+" grid_size_y="+GRID_SIZE_Y+" tile_overlap="+OVERLAP+" first_file_index_i=1 directory="+dir+" file_names="+well+"-{ii}-"+STITCHING_CHANNEL+".tif output_textfile_name="+well+"-"+STITCHING_CHANNEL+"-translations.txt fusion_method=["+FUSION_METHOD+"] regression_threshold="+REGRESSION_THRESHOLD+" max/avg_displacement_threshold="+MAX_AVG_DISPLACEMENT_THRESHOLD+" absolute_displacement_threshold="+ABS_DISPLACEMENT_THRESHOLD+" compute_overlap subpixel_accuracy computation_parameters=[Save memory (but be slower)] output_directory="+dir);
	close();
	
	translations = File.openAsString(dir + well+"-"+STITCHING_CHANNEL+"-translations.registered.txt");
	translations = replace(translations, well+"-", dir+well+"-");
	
	translations = replace(translations, "-"+STITCHING_CHANNEL+".tif", "-C1.tif");
	File.saveString(translations, dir + well+"-C1-translations.registered.txt");

	translations = replace(translations, "-C1.tif", "-C2.tif");
	File.saveString(translations, dir + well+"-C2-translations.registered.txt");
	
	translations = replace(translations, "-C2.tif", "-P.tif");
	File.saveString(translations, dir + well+"-P-translations.registered.txt");
}

function propagateStitching(pos){
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	firstDir = "";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + year + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				if(firstDir == ""){
					firstDir = dataDir + year + day + hour + NR + "/exported/" + pos;
					print("Propagating Stiching from : "+firstDir+"...");
					translations = File.openAsString(firstDir+"-C1-translations.registered.txt");
				}
				else{
					translations = File.openAsString(firstDir+"-C1-translations.registered.txt");
					currentDir = dataDir + year + day + hour + NR + "/exported/" + pos;
				
					print("Propagating Stiching to : "+currentDir+"...");
					translations = replace(translations, firstDir, currentDir);
					File.saveString(translations, currentDir + "-C1-translations.registered.txt");
					
					translations = replace(translations, "-C1.tif", "-C2.tif");
					File.saveString(translations, currentDir + "-C2-translations.registered.txt");
					
					translations = replace(translations, "-C2.tif", "-P.tif");
					File.saveString(translations, currentDir + "-P-translations.registered.txt");
				}
				
			}
		}
	}
	setBatchMode(false);
}

function cleanOnePosition(pos){
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + year + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				dir = dataDir + year + day + hour + NR + "/exported/";
				outDir = dir + "clean/";
				if (!File.exists(outDir)) File.makeDirectory(outDir);
				well=replace(pos,".tif","");
				print("Cleaning " + dir+well+"...");
				run("Image Sequence...", "dir="+dir+" filter=("+well+"-..-C1) sort");
				cleanImage();
				run("Image Sequence... ", "dir="+outDir+" format=TIFF use");
				close();
				run("Image Sequence...", "dir="+dir+" filter=("+well+"-..-C2) sort");
				cleanImage();
				run("Image Sequence... ", "dir="+outDir+" format=TIFF use");
				close();
				
				translations = File.openAsString(dir + well+"-C1-translations.registered.txt");
				translations = replace(translations, well+"-", "clean/"+well+"-");
				File.saveString(translations, outDir + well + "-C1-translations.registered.txt");
				translations = replace(translations, "-C1.tif", "-C2.tif");
				File.saveString(translations, outDir + well + "-C2-translations.registered.txt"); 
			}
		}
	}
	setBatchMode(false);
}

function translateConfigClean(dir,well){
	cleanDir = dir+"clean/";
	translations = File.openAsString(dir + well+"-C1-translations.registered.txt");
	translations = replace(translations, well+"-", "clean/"+well+"-");
	File.saveString(translations, cleanDir + well + "-C1-translations.registered.txt");
	translations = replace(translations, "-C1.tif", "-C2.tif");
	File.saveString(translations, cleanDir + well + "-C2-translations.registered.txt"); 
}

function stitchPositionAtEachTime(pos){
	checkAndGetBaseDir();
	timeStart = getTime();
	root = BASE_DIR;
	dataDir = root+"EssenFiles/ScanData/";
	subfolders = NR + "/exported/";
	
	years = getFileList(dataDir);
	setBatchMode(true);
	for (y=0; y<years.length; y++) {
		if (years[y]<START_YEAR || years[y]>END_YEAR) continue;
		year = years[y];
		days = getFileList(dataDir + year);
		for(d=0; d<days.length; d++) {
			if (days[d]<START_SERIES || days[d]>END_SERIES) continue;
			day = days[d];
			hours = getFileList(dataDir + year + day);
			for(h=0; h<hours.length; h++) {
				if (hours[h]<START_HOUR || hours[h]>END_HOUR) continue;
				hour = hours[h];
				dir = dataDir + year + day + hour + subfolders;
				
				print("Merging " + dir + pos + "...");
				stitchAllChannels(dir,pos);	
			}
		}
	}
	setBatchMode(false);
	
}