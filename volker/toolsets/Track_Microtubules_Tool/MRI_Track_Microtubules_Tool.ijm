var _EXT = ".nd";
var _CURRENT_IMAGE_ID = -1;
var _CURRENT_SKELETON_ID = -1;
var	_RECTANGLE_WIDTH = 10;
var _PRECISION_RADIUS = 1;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Track_Microtubules_Tool";

macro "track microtubules tools help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "track microtubules tools help Action Tool (f1) - C111D01D02D05D06D07D08D0cD0dD0eD0fD1cD1dD1fD28D29D2aD2bD2cD2dD2fD35D38D39D3aD3bD3cD3dD41D46D47D48D49D4aD4bD4cD4dD4eD4fD51D5cD5dD5eD5fD60D70D9fDa0Da1Da2Db0Db1Db2Db4Db9DbaDbeDc0Dc1Dc2Dc4Dc5Dc9DcbDccDceDcfDd0Dd1Dd2Dd3Dd4Dd5DddDdeDdfDe0De1De2De3De4DeeDefDf0Df1Df2Df3Df4C222D0aD0bD10D1aD20D27D32D33D52D53D54D58D6cD92D94D97D98D99D9aD9bD9cD9eDd7Dd8Dd9De6De8De9Df6Df7DfeDffC111D00D03D04D09D11D12D13D14D15D16D17D18D19D1bD1eD21D22D23D24D25D26D2eD30D31D34D36D37D3eD3fD40D42D43D44D45D50D55D56D57D59D5aD5bD80D90D91Da3Da4Da5Da6Da7Da8Da9DaaDabDacDadDaeDafDb3Db5Db6Db7Db8DbbDbcDbdDbfDc3Dc6Dc7Dc8DcaDcdDd6DdaDdbDdcDe5DeaDebDecDedDf5Df8Df9DfaDfbDfcDfdC333D66D69D86D87C222D6bD93D95D96De7C737D61D62D63D71D72D73D81D82D83C277D6dD6eD6fD7dD7eD7fD8dD8eD8fC333D6aD84D85C555D8cC444D64C888D74D75D76D77D78D79D7aD7bD7cC444D65D67D68D88D9dC555D89D8aD8b" {
	run('URL...', 'url='+helpURL);
}

macro 'stack registration [f2]' {
	registerStacks();
}

macro "stack registration Action Tool (f2) - C000T4b12s" {
	registerStacks();	
}

macro 'find end points [f3]' {
	skeletonizeMicrotubules();
	findEndPoints(_CURRENT_IMAGE_ID);
}


macro "find end points Action Tool (f3) - C000T4b12f" {
	skeletonizeMicrotubules();
	findEndPoints(_CURRENT_IMAGE_ID);
}


macro "add to selection Action Tool (f4) - C000T4b12a" {
	addToSelection();
}

macro 'add to selection [f4]' {
	addToSelection();
}

macro 'track ends [f5]' {
	trackEnds();
}

macro "track ends Action Tool (f5) - C000T4b12t" {
	trackEnds();
}


function registerStacks() {
	inDir = getDirectory("Please select the input directory!");
	files = getFileList(inDir);
	ndFiles = filterFiles(files);
	regDir = inDir+"reg"+File.separator;
	File.makeDirectory(regDir);
	print("\\Clear");
	print("\\Update0:Stackreg started...")
	for (i = 0; i < ndFiles.length; i++) {
		print("\\Update1:Processing image "+(i+1)+ " of "+ ndFiles.length);
		file = ndFiles[i];
		path = inDir + file;
		run("Bio-Formats", "open="+path+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		run("StackReg ", "transformation=[Rigid Body]");
		saveAs("tiff", regDir+file);
		close();
	}
	print("\\Update2:Stackreg finished...")
}

function skeletonizeMicrotubules() {
	_CURRENT_IMAGE_ID = getImageID();
	setForegroundColor(0,0,0);
	setBackgroundColor(255,255,255);
	roiManager("reset");
	run("Remove Overlay");
	run("Remove Overlay");
	run("FeatureJ Laplacian", "compute smoothing=2");
	run("Convert to Mask", "method=Default background=Light calculate");
	run("Analyze Particles...", "size=1.0-Infinity add slice exclude");
	roiManager("Combine");
	run("Clear Outside", "stack");
	run("Select None");
	run("Skeletonize", "stack");
	_CURRENT_SKELETON_ID = getImageID();
}

function filterFiles(files) {
	newFiles = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, _EXT)!=-1) {
			newFiles = Array.concat(newFiles, file);
		}
	}
	return newFiles;
}

function findEndPoints(imageID) {
	runPythonScript("microtubule-tracking.py", "exec=findEndPoints,imageID="+imageID+",maskID="+_CURRENT_SKELETON_ID);

	selectImage(imageID);
	Overlay.activateSelection(0);
	getSelectionCoordinates(START_X1, START_Y1)
	Overlay.activateSelection(1);
	getSelectionCoordinates(START_X2, START_Y2)
	run("Select None");
	
	roiManager("Deselect");
	roiManager("reset");
	for (i = 0; i < START_X1.length; i++) {
		makeRotatedRectangle(START_X1[i], START_Y1[i], START_X2[i], START_Y2[i], _RECTANGLE_WIDTH);
		roiManager("add");
	}
	run("Select None");
	roiManager("Set Color", "yellow");
	roiManager("Show None");
	roiManager("Show All");
	trackEnds();
}

function trackEnds() {
/*	index = roiManager("index");
	if (index<0) {
		print("You need to select a roi in the roi-manager for the tracking.");
		return;
	} */
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("Select", i);
	    runPythonScript("microtubule-tracking.py", "exec=trackEnds,imageID="+_CURRENT_IMAGE_ID+",maskID="+_CURRENT_SKELETON_ID);
	}
	roiManager("Deselect");
	run("Select None");
}

function addToSelection() {
	roiManager("Set Color", "green");
	run("Select None");
}

function runPythonScript(name, parameters) {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/"+name);
    call("ij.plugin.Macro_Runner.runPython", script, parameters); 
}
