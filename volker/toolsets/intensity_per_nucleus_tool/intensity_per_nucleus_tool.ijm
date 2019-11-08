/***
 * 
 * MRI Intensity per nucleus tool
 * 
 * Segment the nuclei in the Hoechst or Dapi channel and measure the intensities
 * for each nucleus in the remaining channels.
 * 
 * (c) 2019, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 * 
**/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Intensity-Per-Nucleus-Tool";
var _NUCLEI_CHANNELS = newArray("hoechst", "dapi");
var	_SCALE_FACTOR = 5.0;
var	_MIN_SIZE = 50;
var _THRESHOLDING_METHOD = "Huang";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _FILE_EXT = "nd";
var _TABLES = newArray(0);

exit();

macro "intensity per nucleus tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "intensity per nucleus tool help (f4) Action Tool - C200D06D07D17D18DafDbfDcfDdfC10bD25D26D27D28D34D36D37D38D39D43D44D45D47D48D49D4aD52D53D54D55D56D57D58D5aD5bD62D65D68D69D6bD72D73D75D78D79D7aD7bD82D83D84D85D86D87D88D89D8aD8bD92D93D94D95D96D97D98D99D9aD9bDa3Da4Da7DaaDb4Db5Db7Db8Db9Dc5Dc6Dc7Dc8C760D13D1bD2cDacDcbDebDf2DfbCa83D0dD1dD23D2dD4eD5fDbaC530D0aD15D1aD2bD3aD3bD5cD6dD7dD7eD7fD8dD9dDcdDddDfcCa90D00D0cD11D22Dd0Dd1Dd2Dd9De2De3De4De7De8Df6Df7Ce8cD2fD35D46D59D66D67D6aD76D77Da5Da6Da8Da9Db6C330D03D08D09D19D29D2aD8eD8fD9eD9fDadDbdDedDeeDfdDfeC970D0bD12D1cD3dD9cDabDbbDcaDdaDe1De9DeaDf5Df8Df9DfaCed4D0eD30D31D32D40D41D60D70D91Db2Dc3Dd5Dd6Dd7Dd8C640D02D14D3cD4bD4cD5dD6cD6eD7cD8cDbcDccDdcDecDf0Df1Ccc0D10D20D21D80D90Da0Da1Db0Db1Dc0Dc1Dc2Dd3Dd4De5De6CecbD0fD1fD33D42D50D51D61D63D64D71D74D81Da2Db3Dc4C310D04D05D16DaeDbeDceDdeDefDffC770D01D4dD5eD6fDdbDe0Df3Df4Cb86D1eD24D2eD3eD3fD4fDc9"{
	run('URL...', 'url='+helpURL);
}

macro "measure intensity per nucleus [f5]" {
	measureIntensityPerNucleus();
}

macro "measure intensity per nucleus (f5) Action Tool - C000T4b12m" {
	measureIntensityPerNucleus();
}
macro "batch measure intensity (f6) Action Tool - C000T4b12b" {
	batchMeasureIntensity(_FILE_EXT);
}

macro "batch measure intensity [f6]" {
	batchMeasureIntensity(_FILE_EXT);
}

macro "measure intensity per nucleus (f5) Action Tool Options" {
	Dialog.create("measure intensity options");
	Dialog.addNumber("scale factor: ", _SCALE_FACTOR);
	Dialog.addNumber("min. size: ", _MIN_SIZE);
	Dialog.addChoice("thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD);
	Dialog.show();
	_SCALE_FACTOR = Dialog.getNumber();
	_MIN_SIZE = Dialog.getNumber();
	_THRESHOLDING_METHOD = Dialog.getChoice();
}

function batchMeasureIntensity(fileExt) {
	print("\\Clear");
	print("batch measure intensities started...");
	_TABLES = newArray(0);
	dir = getDirectory("Choose the input folder!");
	processFolder(dir, dir, fileExt);
	Array.print(_TABLES);
	for (i = 0; i < _TABLES.length; i++) {
		table = _TABLES[i];
		selectWindow(table);
		saveAs("Results", dir + File.separator + table + ".xls");
	}
	print("batch measure intensities finished!");
	selectWindow("Log");
}

function measureIntensityPerNucleus() {
	run("Clear Results");
	path = File.directory;
	filename = File.name;
	channelNames = getChannelNames();	
	indexOfNucleiChannel = getIndexOfNucleiChannel(channelNames);
	indicesOfChannelsToBeMeasured = getIndicesOfChannelsToBeMeasured(indexOfNucleiChannel, channelNames.length);
	Stack.setChannel(indexOfNucleiChannel);
	run("Duplicate...", " ");
	selectNuclei();
	close();
	roiManager("Show All");
	for (i = 0; i < indicesOfChannelsToBeMeasured.length; i++) {
		run("Clear Results");
		Stack.setChannel(indicesOfChannelsToBeMeasured[i]);
		roiManager("Measure");
		selectWindow("Results");
		headings = split(Table.headings, "\t");
		for(c=1; c<headings.length; c++) {
			data = Table.getColumn(headings[c]);
			newRows = false;
			if (c==1) newRows = true;
			addResultsColumnToTable(headings[c], data, channelNames[indicesOfChannelsToBeMeasured[i]-1], path, filename, newRows);
		}
	}
	run("Close");
}

function addResultsColumnToTable(columnName, data, tableName, path, filename, newRows) {
	if (isOpen(tableName)) {
		selectWindow(tableName);
	} else {
		Table.create(tableName);
		_TABLES = Array.concat(_TABLES,tableName);
		getLocationAndSize(x, y, width, height);
		Table.setLocationAndSize(x, y, 1100, 600);
	}
	Table.update;
	if (newRows) {
		rowIndex = Table.size;
	} else {
		rowIndex = Table.size - data.length;
	}
	for (i = 0; i < data.length; i++) {
		if (newRows) {
			selectWindow(tableName);
			Table.set("path", rowIndex, path);
			Table.set("filename", rowIndex, filename);
			Table.set("nucleus nr.", rowIndex, i+1);
		}
		Table.set(columnName, rowIndex, data[i]);
		Table.update;
		rowIndex++;
	}
	selectWindow("Results");
}

function selectNuclei() {
	imageID = getImageID();
	run("Scale...", "x="+(1.0/_SCALE_FACTOR)+" y="+(1.0/_SCALE_FACTOR)+" interpolation=Bilinear create title=small_tmp");
	setAutoThreshold(_THRESHOLDING_METHOD + " dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Watershed");
	run("Scale...", "x="+_SCALE_FACTOR+" y="+_SCALE_FACTOR+" interpolation=Bilinear create title=big_tmp");
	setAutoThreshold(_THRESHOLDING_METHOD);
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity circularity=0.00-1.00 show=Nothing add exclude");
	selectWindow("small_tmp");
	close();
	selectWindow("big_tmp");
	close();
	selectImage(imageID);
	roiManager("Show All");
}

function getChannelNames() {
	subtitle = getInfo("image.subtitle");
	parts = split(subtitle, ";");
	channelString = parts[0];
	parts = split(channelString, "-");
	channelString = parts[1];
	parts = split(channelString, ")");
	channelString = parts[0];
	parts = split(channelString, " ");
	channelString = parts[0];
	channelNames = split(channelString, "/");
	return channelNames;
}

function getIndexOfNucleiChannel(channelNames) {
	for (i = 0; i < channelNames.length; i++) {
		channelName = channelNames[i];
		channelName = toLowerCase(channelName);
		if (contains(_NUCLEI_CHANNELS, channelName, true)) return i+1;
	}
	return -1;
}

function contains(aList, aString, ignoreCase) {
	searchString = aString;
	if (ignoreCase) searchString = toLowerCase(searchString);
	for (i = 0; i < aList.length; i++) {
		anElement = aList[i];
		if (ignoreCase) anElement = toLowerCase(anElement);
		if (anElement==aString) return true;
	}
	return false;
}

function getIndicesOfChannelsToBeMeasured(excludedChannel, nrOfChannels) {
	indices = newArray(0);
	for (i = 1; i <= nrOfChannels; i++) {
		if (i!=excludedChannel) indices = Array.concat(indices, i);
	}
	return indices;
}

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input, output, fileExt) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i], output, fileExt);
		if(endsWith(toLowerCase(list[i]), toLowerCase(fileExt)))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	path = input + File.separator + file;
	print("Processing: " + path);
	
	run("Bio-Formats", "open=["+path+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	measureIntensityPerNucleus();
	run("From ROI Manager");
	path = input + File.separator + "control";
	if (!File.exists(path)) File.makeDirectory(path);
	newFileName = replace(file, "."+_FILE_EXT, ".tif");
	saveAs("Tiff", path + File.separator + file);
	close();
}