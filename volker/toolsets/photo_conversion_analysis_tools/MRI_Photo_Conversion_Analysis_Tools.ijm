var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Photo_Conversion_Analysis_Tool";
var _CHANNEL = 2;
var _CELL_MASK_CHANNEL = 1;
var _T0 = 0;
var _USE_ROLLING_BALL=false;
var _ROLLING_BALL_RADIUS = 40;
var _USE_ROLLING_BALL_SEG = false;
var _ROLLING_BALL_RADIUS_SEG = 40;
var _FILTER = "Gaussian Blur...";
var _FILTER_PARAM = 1.2;
var _MIN_SIZE = 20;
var _MEASURE_REGION_OPTIONS = newArray("whole cell", "above threshold", "around max");
var _MEASURE_REGION_OPTION = _MEASURE_REGION_OPTIONS[1];
var _PROJECTION_IMAGE_ID = 0;


// regions are named according to the schema:
// 	I_PHOTO_C<cc>_t<tt> - photo converted region of cell cc at time point tt
//  I_BACK_t<tt>		- background region at time point tt
//  I_REF_C<cc>_t<tt>	- reference region of cell cc at time point tt
// 
// Photo-conversion begins at time-point _T0 + 1

// DEBUG
// plotCurve();
// exit();

macro "MRI Photo Conversion Analysis Help Action Tool - C000D21D22D23D24D25D26D27D28D29D2aD2bD2cD2dD2eD3eD4eD5eD6eD7eD8eD9eDaeDbeDceDdeDeeCfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD1fD20D2fD30D31D32D33D34D35D36D37D38D39D3aD3bD3cD3dD3fD40D43D44D45D46D47D48D49D4aD4bD4cD4dD4fD50D51D57D58D59D5aD5bD5cD5dD5fD60D61D62D63D64D65D68D69D6aD6bD6cD6dD6fD70D71D72D73D74D75D76D7bD7cD7dD7fD80D81D82D83D84D85D86D87D88D89D8cD8dD8fD90D91D92D93D94D95D96D97D98D99D9aD9dD9fDa0Da1Da2Da3Da4Da5Da6Da7Da8Da9DaaDabDadDafDb0Db1Db2Db3Db4Db5Db6Db7Db8Db9DbaDbbDbdDbfDc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDcdDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDddDdfDe0De1De2De3De4De5De6De7De8De9DeaDecDedDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfcDfdDfeDffCf00D41D42D52D53D54D55D56D66D67D77D78D79D7aD8aD8bD9bD9cDacDbcDccDdbDdcDebDfb" {
	run('URL...', 'url='+helpURL);
}

macro "help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "prepare image Action Tool (f2) - C000T4b12p" {
	prepareImage();	
}

macro "pepare image [f2]" {
	prepareImage();	
}

macro "prepare image Action Tool (f2) Options" {
	Dialog.create("Photo Conversion Analysis Options");
	Dialog.addCheckbox("use rolling-ball", _USE_ROLLING_BALL);
    Dialog.addNumber("rolling ball radius: ", _ROLLING_BALL_RADIUS);
    Dialog.show();
    _USE_ROLLING_BALL = Dialog.getCheckbox();
    _ROLLING_BALL_RADIUS = Dialog.getNumber();
}

macro "select cells Action Tool (f3) - C000T4b12c" {
	selectCells();	
}

macro "select cells Action Tool (f3) Options" {
	Dialog.create("Photo Conversion Segmentation Options");
	Dialog.addCheckbox("use rolling-ball", _USE_ROLLING_BALL_SEG);
    Dialog.addNumber("rolling ball radius: ", _ROLLING_BALL_RADIUS_SEG);
    Dialog.addNumber("Sigma of Gaussian blur filter: ", _FILTER_PARAM);
    Dialog.addNumber("min. size: ", _MIN_SIZE);
    Dialog.show();
    _USE_ROLLING_BALL_SEG = Dialog.getCheckbox();
    _ROLLING_BALL_RADIUS_SEG = Dialog.getNumber();
    _FILTER_PARAM = Dialog.getNumber();
    _MIN_SIZE = Dialog.getNumber();
}

macro "select cells [f3]" {
	selectCells();	
}

macro "plot intensity curve Action Tool (f4) - C000T4b12i" {
	plotCurve();
}

macro "plot intensity curve Action Tool (f4) Options" {
	Dialog.create("Photo Conversion Analysis Options");
	Dialog.addChoice("region to measure: ", _MEASURE_REGION_OPTIONS, _MEASURE_REGION_OPTION);
    Dialog.show();
    _MEASURE_REGION_OPTION = Dialog.getChoice();
}

macro "plot intensity curve [f4]" {
	plotCurve();
}

function plotCurve() {
	run("Duplicate...", "duplicate");
	run("32-bit");
	setSlice(1);
	getStatistics(area, mean);
	print("Mean before photoconversion: ", mean);
	run("Select None");
	run("Divide...", "value="+mean+" stack");
	run("Restore Selection");
	run("Clear Results");
	roiManager("reset");
	roiManager("add");
	if (_MEASURE_REGION_OPTION==_MEASURE_REGION_OPTIONS[0]) plotCurveWholeCell();
	if (_MEASURE_REGION_OPTION==_MEASURE_REGION_OPTIONS[1]) plotCurveAboveThreshold();
}

function plotCurveWholeCell() {
	roiManager("select", 0)
	roiManager("Multi Measure");
	close();
	createPlot();
}

function plotCurveAboveThreshold() {
	setAutoThreshold("Triangle dark stack");
	run("Set Measurements...", "area mean modal min centroid integrated median kurtosis stack limit display redirect=None decimal=3");
	roiManager("select", 0)
	roiManager("Multi Measure");
	run("Set Measurements...", "area mean modal min centroid integrated median kurtosis stack display redirect=None decimal=3");
	close();
	createPlot();
}

function createPlot() {
	Table.deleteRows(0, 0);
	Plot.create("Plot of Results", "x", "Mean1");
	Plot.setColor("blue")
	Plot.add("Circle", Table.getColumn("Mean1", "Results"));
}

function prepareImage() {
	inputImage = getImageID();
	run("Select None");
	run("Duplicate...", "duplicate channels="+_CHANNEL+"-"+_CHANNEL);
	run("Restore Selection");
	correctBackground(_USE_ROLLING_BALL, _ROLLING_BALL_RADIUS);
	channelImageID = getImageID();
	run("Z Project...", "projection=[Max Intensity] all");
	_PROJECTION_IMAGE_ID = getImageID();
	selectImage(channelImageID);
	close();
	setSlice(1);
	selectImage(inputImage);
	run("Restore Selection");
}


function correctBackground(rollingBall, radius) {
	run("Set Measurements...", "area mean modal min centroid integrated median kurtosis stack display redirect=None decimal=3");
	if (rollingBall) correctBackGroundRollingBall(radius);
	else correctBackgroundSubtractMean();
}

function correctBackGroundRollingBall(radius) {
	run("Subtract Background...", "rolling="+radius+" stack");
}

function correctBackgroundSubtractMean() {
	if (selectionType()<0 || selectionType()>4) {
		exit("No selection. Select a background region before running the macro!") 
	}
	roiManager("reset");
	roiManager("add");
	run("Select None");
	run("Clear Results");
	roiManager("Multi Measure");
	run("Select None");
	getDimensions(width, height, channels, slices, frames);
	for (i = 0; i < nResults; i++) {
		mean = floor(getResult("Mean1", i)) + 1;
		channel = getResult("Ch1", i);
		frame = getResult("Frame1", i);
		Stack.setPosition(channel, (i%slices)+1, frame)
		run("Subtract...", "value="+mean+" slice");
	}
}

function selectCells() {
	Stack.setPosition(_CELL_MASK_CHANNEL, 1, 1);
	run("Select None");
	run("Duplicate...", " ");
	run("Restore Selection");
	correctBackground(_USE_ROLLING_BALL_SEG, _ROLLING_BALL_RADIUS_SEG);
	run("Select None");
	run(_FILTER, "sigma="+_FILTER_PARAM);
	resetThreshold();
	setAutoThreshold("Default dark");
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Masks in_situ");
	run("Fill Holes");
	run("Close-");
	run("Open");
	run("Dilate");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity show=Nothing add");
	close();
	selectImage(_PROJECTION_IMAGE_ID);
	run("Select None");
	roiManager("Show None");
	roiManager("Show All");
	run("From ROI Manager");
	roiManager("reset");
}
