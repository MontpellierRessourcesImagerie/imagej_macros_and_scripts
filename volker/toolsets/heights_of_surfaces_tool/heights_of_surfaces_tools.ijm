/*
 *	Heights Pf surfaces tools 
 *	
 *	The tool compares the height in the z-dimension of the signals in two different channels (red and blue). It calculates the fraction of the volume of the
 *	red signal that lies above the blue signal and the fraction of the red signal that lies below the blue signal. Only places where both signals are present 
 *	(heights of red and blue bigger than zero) are taken into account.
 *	
 */
var	_METHODS = getList("threshold.methods");
var _METHOD = _METHODS[0];
var _EXTENSION = ".czi";
var _REMOVE_BACKGROUND = true;
var _REFERENCE_CHANNEL = 4
var _CHANNEL_FOR_CELL_SEGMENTATION = 3;
var _SHRINK_BY = 2.2;
var _MIN_SIZE = 300;
var _TOTAL_VOLUME_IN_CELL_ONLY = true;
var _CHANNELS_TO_PLOT = newArray(0);
var _CHANNEL_SELECTION = newArray(true, true, true, true, true, true, true, true, true, true, true, true);
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Heights_of_Surfaces_Tools";

// FOR DEBUGGING
//createSurfaceImage();
//plotHeights();
//calculateVolumes();

macro "MRI Heights of Surfaces Tools (f5) Help Action Tool - Cf00D1bD1cD24D25D28D29D31D32D33D41D42D43D44D45D68D69D6aD76D77D83D84D85D91D92D93D94D95Da6Da7Da9DaaDb9Dc6Dc7Dd5Dd6De7DfaDfbCfffD00D01D02D03D04D05D06D07D08D09D0aD0dD0eD0fD10D11D12D13D14D15D16D17D1dD1eD1fD20D21D22D23D2aD2bD2cD2dD2eD2fD30D34D35D37D38D39D3aD3bD3cD3dD3eD3fD40D48D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D5dD5eD5fD60D61D62D63D64D65D66D67D6dD6eD6fD70D71D72D73D74D75D78D79D7aD7cD7dD7eD7fD80D81D82D86D87D88D8bD8cD8dD8eD8fD90D96D97D99D9aD9bD9cD9dD9eD9fDa0Da1Da2Da3Da4Da5DabDacDadDaeDafDb0Db1Db2Db3Db4Db5Db6Db7DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd7Dd9DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De6DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8DfcDfdDfeDffC00fD0bD0cD18D19D36D47D6bD6cD7bD89D8aD98Dc8Dd8Df9Cf0fD1aD26D27D46D57D58D59D5aD5bD5cDa8Db8De8De9"{
	help();
}

macro "help [f5]" {
	help();
}

function help() {
	run('URL...', 'url='+helpURL);
}

macro "correct background [f6]" {
	correctBackgrounds(); 
}

macro 'Correct Background (f6) Action Tool - C000T4b12b' {
	correctBackgrounds();
}

macro "create surface image [f7]" {
	createSurfaceImage(); 
}
macro 'Create Surface Image (f7) Action Tool - C000T4b12c' {
	createSurfaceImage();
}

macro 'Create Surface Image (f7) Action Tool Options' {
	createSurfaceOptions();
}
macro "plot heights [f8]" {
	plotHeights(); 
}

macro 'Plot heights (f8) Action Tool - C000T4b12p' {
	plotHeights();
}

macro 'Plot heights (f8) Action Tool Options' {
	createPlotOptions();
}

macro 'Measure Heights (f9) Action Tool - C000T4b12h' {
	calculateHeights();
}

macro 'measure heights [f9]' {
	calculateHeights();
}

macro 'Batch process (f11) Action Tool - C444D22D2cD52D5cD68D85D9dDe8Df6C000D29D41D67D8fDd4DebCcccD32D33D39D3cD57D65D69D6bD8aDa9Db8Dc7Dd7De7CbbbD26D7cD80D8bD8cD8eD92D95D99D9bD9cDa8DaaDabDb9DbaDbbDc4Dc9DcaDccDd6C222D31D3dD90D9eDc1Dd9DdaCeeeD17D36D37D38D45D46D48D49D4aD55D56D58D59D63D64D73D82D83Da4Da5Db3Db4Dc2Dc3C888D16D28D34D3aD42D4cD62D6cD70D79D7dDa7Db2Dd2Dd8DdbDdcDe6C111D06D98Df8CeeeD44D4bD53D54D5aD72D81Db5Db6CcccD35D71D7bD8dD9aDa6Dc8DcbC333D07D23D2bD66D91DbcDd5CfffD27D47D74D84D93D94Da3C555D18D75D7eD89Da2DacDd3Df7C111D08D25D61D96DcdCdddD3bD43D5bD6aD7aDb7Dc5Dc6' {
	runBatchProcessing();
}

macro 'Batch process folders [f11]' {
	runBatchProcessing();
}

macro 'Batch process (f11) Action Tool Options' {
	 Dialog.create("Create Surface Batch Image Options");
	 Dialog.addString("File extension: ", _EXTENSION);
	 Dialog.addCheckbox("Remove background: ", _REMOVE_BACKGROUND)
 	 Dialog.show();
 	 _EXTENSION = Dialog.getString();
 	 _REMOVE_BACKGROUND = Dialog.getCheckbox();
}

function findCell() {
	run("Remove Overlay");
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+_CHANNEL_FOR_CELL_SEGMENTATION+"-"+_CHANNEL_FOR_CELL_SEGMENTATION);
	run("Z Project...", "projection=[Max Intensity]");
	run("Gaussian Blur...", "sigma=8");
	setAutoThreshold("Huang dark");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity include add");
	roiManager("select", 0);
	run("Enlarge...", "enlarge=-"+_SHRINK_BY);
	roiManager("Update");
	close(); 
	close();
	run("From ROI Manager");
	roiManager("reset");
}

function createSurfaceOptions() {
	 Dialog.create("Create Surface Image Options");
	 Dialog.addChoice("Auto-threshold method: "_METHODS, _METHOD)
	 Dialog.addNumber("Reference channel ", _REFERENCE_CHANNEL);
	 Dialog.addCheckbox("Restrict total volume to cell", _TOTAL_VOLUME_IN_CELL_ONLY);
	 Dialog.addNumber("segment cell in channel: ", _CHANNEL_FOR_CELL_SEGMENTATION);
	 Dialog.addNumber("shrink roi of cell border by: ", _SHRINK_BY);
	 Dialog.addNumber("min. size of cell", _MIN_SIZE);
 	 Dialog.show();
 	 _METHOD = Dialog.getChoice();
 	 _REFERENCE_CHANNEL = Dialog.getNumber();
 	 _TOTAL_VOLUME_IN_CELL_ONLY = Dialog.getCheckbox();
 	 _CHANNEL_FOR_CELL_SEGMENTATION = Dialog.getNumber();
 	 _SHRINK_BY = Dialog.getNumber();
 	 _MIN_SIZE = Dialog.getNumber();
}

function createPlotOptions() {
	if (nImages==0) return;
	Stack.getDimensions(width, height, channels, slices, frames);
	Dialog.create("Create Plot Options");
	Dialog.addMessage("Plot Channel:");
	for (i = 1; i <= channels; i++) {	
		Dialog.addCheckbox(i+". channel", _CHANNEL_SELECTION[i-1]);
	}
	Dialog.show();
	for (i = 1; i <= channels; i++) {	
		_CHANNEL_SELECTION[i-1] = Dialog.getCheckbox();
	}
}

function createSurfaceImage() {
	getDimensions(width, height, channels, slices, frames);
	setBatchMode(true);
	imageTitle = getTitle();
	rename("image");
	method = _METHOD;
	imageID = getImageID();
	findCell();
	Overlay.copy;
	run("Split Channels");
	getVoxelSize(width, height, depth, unit);
	for (i = 1; i <= channels; i++) {
		wait(500);
		selectImage("C"+i+"-image");
		getLut(reds, greens, blues);
		currentID = getImageID();
		setAutoThreshold(method+" dark stack");
		run("Convert to Mask", "method="+method+" background=Dark black");
		zEncodeStack(); // 						run("Macro...", "code=[v=(v/255) * (z+1)] stack"); 	
		selectImage(currentID);	
		run("Z Project...", "projection=[Max Intensity]");
		projectionID = getImageID();
		selectImage(currentID);
		close();
		selectImage(projectionID);		
		setLut(reds, greens, blues);
		run("Calibrate...", "function=[Straight Line] unit="+unit+" text1=[1 10] text2=["+depth+" "+10*depth+"]");
	}
	mergeString = "";
	for (i = 1; i <= channels; i++) {
		mergeString += "c"+i+"=[MAX_C"+i+"-image] ";
	}
	mergeString += "create";
	run("Merge Channels...", mergeString);
	for (i = 1; i <= channels; i++) {
		setSlice(i);
		run("Enhance Contrast", "saturated=0.35");	
	}
	setBatchMode(false);
	rename(imageTitle + "-surface");
	Overlay.paste;
	setMetadata("original_nr_of_slices", toString(slices));
}

function plotHeights() {
	imageWidth = getWidth();
	imageHeight = getHeight();
	imageID = getImageID();

	Stack.getDimensions(iwidth, iheight, channels, slices, frames)
	getVoxelSize(width, height, depth, unit);
	_CHANNELS_TO_PLOT = newArray();
	for (i = 1; i <= channels; i++) {	
		if (_CHANNEL_SELECTION[i-1]) _CHANNELS_TO_PLOT = Array.concat(_CHANNELS_TO_PLOT, i);
	}
	type = selectionType();
	if (type!=5) makeLine(imageWidth, 0, 0, imageHeight);
	getLine(x1, y1, x2, y2, lineWidth);
	if (lineWidth==1) run("Line Width...", "line=20");
	dy = y2-y1;
	dx = x2-x1; 
	length=sqrt(dx*dx + dy*dy)*width;
	setSlice(_REFERENCE_CHANNEL);
	getStatistics(area, mean, min, max, std, histogram);

	Plot.create("Height of channels", "Distance ("+unit+")", "Height ("+unit+")");
	setSlice(_CHANNELS_TO_PLOT[0]);
	profile = getProfile();
	xValues = newArray(profile.length);
	for (i = 0; i < xValues.length; i++) {
		xValues[i] = width*i;
	}
	for (i = 0; i < _CHANNELS_TO_PLOT.length; i++) {
		setSlice(_CHANNELS_TO_PLOT[i]);
		getLut(reds, greens, blues);
		color = nameOfColor(reds, greens, blues);
		profile = getProfile();
		
		Plot.setColor(color);
		Plot.add("line", xValues, profile);
		upperRange = max + (max/10.0);
		Plot.setLimits(0.0,length + (0.02 * length),0.00, upperRange);
	}
	Plot.show();
}

function zEncodeStack() {
	run("Divide...", "value=255 stack");
	for(z=1; z<=nSlices ; z++) {
		setSlice(z);
		run("Multiply...", "value="+z+" slice");
	}
	setSlice(1);
}

function calculateHeights() {
	inputImageID = getImageID();
	imageName = getTitle();
	Overlay.remove;
	roiManager("reset");
	run("Select None");
	Stack.setChannel(_REFERENCE_CHANNEL);
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	cmax = calibrate(max);
	print("max. height is " + cmax + " determined using channel " + _REFERENCE_CHANNEL);
	run("Duplicate...", " ");
	run("Macro...", "code=[v=(v=="+max+") * 255]");
	referenceMaskID = getImageID();
	referenceMaskTitle = getTitle();
	selectImage(inputImageID);
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(width, height, depth, unit);
	xValues = newArray(256);
	for (j = 0; j < histogram.length; j++) {
		xValues[j] = (j * depth) / cmax;
	}
	title = "histograms";
	if (!isOpen(title)) {
		Table.create(title);
	}
	Table.setColumn("rel. height max="+cmax+" "+unit + " - " + imageName, xValues, "histograms");
	for (i = 1; i <= channels; i++) {
		if (i==_REFERENCE_CHANNEL) continue;
		roiManager("reset");
		run("Select None");
		Stack.setChannel(i);
		run("Duplicate...", " ");
		run("Macro...", "code=[v=(v>0) * 255]");
		maskID = getImageID();
		maskTitle = getTitle();
		imageCalculator("AND create", referenceMaskTitle, maskTitle);
		setThreshold(1, 255);
		run("Create Selection");
		roiManager("Add");
		close();
		close();
		selectImage(inputImageID);
		roiManager("select", 0);

		imageName = getTitle();
		getStatistics(area, mean, min, max, std, histogram);
		Table.setColumn(imageName + "_" + i, histogram, "histograms");

		run("From ROI Manager");
		roiManager("select", 0);
		run("Measure");

		quartilesIOneAndThree = getQuartilesOneAndThree(histogram, xValues);
		Table.set("Q1", nResults-1, quartilesIOneAndThree[0], "Results");
		Table.set("Q3", nResults-1, quartilesIOneAndThree[1], "Results");
	}
	selectImage(referenceMaskID);
	close();	
	roiManager("reset");
}

function getQuartilesOneAndThree(histogram, xValues) {
	sum = 0;
	for (i = 1; i < histogram.length; i++) {
		count = histogram[i];
		if (i==0) break;
		sum += count;
	}

	oneFourth = sum / 4;
	threeFourth =  oneFourth * 3;

	qOneIndex = 0;
	qThreeIndex = 0;
	doneQ1 = false;
	doneQ3 = false;
	runningSum = 0;
	for (i = 1; i < histogram.length; i++) {
		if ( histogram[i]==0) break;
		runningSum += histogram[i];
		if (runningSum>oneFourth && !doneQ1) {
			qOneIndex = i-1;
			doneQ1 = true;
		}
		if (runningSum>threeFourth && !doneQ3) {
			qThreeIndex = i-1;
			doneQ3 = true;
		}
		sum += count;
	}

	result = newArray(xValues[qOneIndex], xValues[qThreeIndex]);
	return result;
}

function calculateVolumes() {
	inputImageID = getImageID();
	run("Duplicate...", "duplicate");
	imageID = getImageID();
	title=getTitle();
	run("Split Channels");
	selectImage("C1-"+title);
	getVoxelSize(width, height, depth, unit);
	imageBlueID = getImageID();
	selectImage("C2-"+title);
	imageRedID = getImageID();
	commonSupportMaskID = createCommonSupportSelection(imageBlueID, imageRedID, depth);
	selectImage(inputImageID);
	run("Duplicate...", "duplicate");
	imageID = getImageID();
	title=getTitle();
	run("Split Channels");
	selectImage("C1-"+title);
	getVoxelSize(width, height, depth, unit);
	imageCalculator("Subtract create 32-bit", "C1-"+title,"C2-"+title);
	diffImageBlueID = getImageID();
	imageCalculator("Subtract create 32-bit", "C2-"+title,"C1-"+title);
	diffImageRedID = getImageID();
	selectImage(diffImageBlueID);
	volumeBlue = measureVolume(depth, commonSupportMaskID);
	selectImage(diffImageRedID);
	volumeRed = measureVolume(depth, commonSupportMaskID);
	selectImage(diffImageRedID);
	close();
	selectImage(diffImageBlueID);
	close();
	selectImage("C1-"+title);
	close();
	selectImage("C2-"+title);
	close();
	close();
	totalVolumes = measureTotalVolumes();
	reportVolumes(title, volumeRed[0], volumeRed[1], volumeBlue[0], volumeBlue[1], totalVolumes, unit);
	run("Restore Selection");
}

function createCommonSupportSelection(blueID, redID, zStep) {
	selectImage(blueID);
	setThreshold(zStep, 255*zStep);
	run("Convert to Mask");
	blueMask = getTitle();
	selectImage(redID);
	setThreshold(zStep, 255*zStep);
	run("Convert to Mask");
	redMask = getTitle();
	imageCalculator("AND create", blueMask, redMask);
	run("Create Selection");
	id = getImageID();
	selectImage(redID);
	close();
	selectImage(blueID);
	close();
	selectImage(id);
	return id;
}

function measureVolume(depth, commonSupportMaskID) {
	run("Set Measurements...", "area mean standard min integrated limit display redirect=None decimal=3");
	inputImageID = getImageID();
	selectImage(commonSupportMaskID);
	selectImage(inputImageID);
	setThreshold(0, 255*depth);				
	run("Restore Selection");
	run("Measure");
	volumeAbove = getResult("IntDen", nResults-1);
	resetThreshold();
	setThreshold(-255*depth, 0);		
	run("Measure");
	volumeBelow = getResult("IntDen", nResults-1);
	run("Select None");
	result = newArray(abs(volumeBelow), abs(volumeAbove));
	return result;
}

function measureTotalVolumes() {
	if (_TOTAL_VOLUME_IN_CELL_ONLY) Overlay.activateSelection(0);
	getStatistics(area);
	Stack.setChannel(1);
	slices = parseInt(getMetadata("original_nr_of_slices"));
	getVoxelSize(pixelWidth, pixelHeight, pixelDepth, unit);
	total = area*slices*pixelDepth;
	run("Measure");
	volumeBlue = getResult("IntDen", nResults-1);
	Stack.setChannel(2);
	run("Measure");
	volumeRed = getResult("IntDen", nResults-1);
	run("Select None");
	fractionBlue = volumeBlue / total;
	fractionRed = volumeRed / total;
	results = newArray(fractionBlue, fractionRed, volumeBlue, volumeRed);
	return results;
}

function reportVolumes(imageTitle, volumeRedBelow, volumeRedAbove, volumeBlueAbove, volumeBlueBelow, totalVolumes, unit) {
  volumeRedTotal = volumeRedBelow + volumeRedAbove;
  title = "Volumes Table";
  handle = "["+title+"]";
  if (!isOpen(title)) {
     run("Table...", "name="+handle+" width=1000 height=600");
  	 print(handle, "\\Headings:image\tthreshold\tfraction red above\tfraction red below\tvolume red above ("+unit+"^3)\tvolume red below ("+unit+"^3)\tfraction blue total\tfraction red total\tvolume blue total ("+unit+"^3)\tvolume red total ("+unit+"^3)");
  }
  fractionRedAbove = volumeRedAbove / volumeRedTotal;
  fractionRedBelow = volumeRedBelow / volumeRedTotal;
  print(handle, imageTitle + "\t" + _METHOD + "\t" + fractionRedAbove + "\t" + fractionRedBelow + "\t" + volumeRedAbove + "\t" + volumeRedBelow + "\t" + totalVolumes[0] + "\t" + totalVolumes[1] + "\t" + totalVolumes[2] + "\t" + totalVolumes[3] + "\t");
}

function correctBackgrounds() {
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= channels; i++) {
		correctBackground(i);
	}
	return;
}

function correctBackground(channel) {
	imageID = getImageID();
	Stack.setChannel(channel);
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	run("Maximum...", "radius=20 stack");
	run("Z Project...", "projection=[Sum Slices]");
	setAutoThreshold("Triangle dark no-reset");
	run("Create Selection");
	run("Fill", "stack");
	run("Select None");
	setAutoThreshold("Default dark no-reset");
	run("Create Selection");
	run("Make Inverse");
	close();
	close();
	run("Restore Selection");
	run("Plot Z-axis Profile");
	Plot.getValues(xpoints, ypoints);
	close();
	selectImage(imageID);
	run("Select None");
	Fit.doFit("3rd Degree Polynomial", xpoints, ypoints);
	for (i = 0; i < xpoints.length; i++) {
		Stack.setSlice(i+1);
		y = Fit.f(xpoints[i]);
		run("Subtract...", "value="+y+" slice");
	}
	Stack.setSlice(1);
}

function runBatchProcessing() {
	input = getDirectory("Choose the input folder!");
	output = getDirectory("Choose the output folder!");	
	run("Clear Results");
	processFolder(input, output);
	selectWindow("Results");
	t = getTime();
	ts = d2s(t, 0);
	saveAs("results", output + "heights_of_surfaces-"+ts+".xls");
	selectWindow("histograms");
	saveAs("results", output + "histograms_of_heights-"+ts+".xls");
	
}

function processFolder(input, output) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output);
		if(endsWith(list[i], _EXTENSION))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	print("Processing: " + input + File.separator + file);
	run("Bio-Formats Importer", "open=["+input + file +"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	if (_REMOVE_BACKGROUND) correctBackgrounds();
	createSurfaceImage();
	image = getImageID();
	plotHeights();
	Plot.makeHighResolution("Height of channels_HiRes",4.0);
	save(output + file +"-plot.tif");
	close();
	close();
	run("Select None");
	calculateHeights();
	print("Saving to: " + output + File.nameWithoutExtension + ".png");
	selectImage(image);
	wait(500);
	run("Capture Image");
	save(output + File.nameWithoutExtension + ".png");
	close();
	close();
}

function nameOfColor(red, green, blue) {
	Array.getStatistics(red, min, max);
	redIsZero = (max==0);
	Array.getStatistics(green, min, max);
	greenIsZero = (max==0);
	Array.getStatistics(blue, min, max);
	blueIsZero = (max==0);
	
	name = "Grays";
	if (!redIsZero && !greenIsZero && blueIsZero) name = "yellow";
	if (!redIsZero && greenIsZero && !blueIsZero) name = "magenta";
	if (redIsZero && !greenIsZero && !blueIsZero) name = "cyan";
	if (!redIsZero && greenIsZero && blueIsZero) name = "red";
	if (redIsZero && !greenIsZero && blueIsZero) name = "green";
	if (redIsZero && greenIsZero && !blueIsZero) name = "blue";
	return name;
}
