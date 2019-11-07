/***
 * 
 * MRI Intensity per nucleus tool
 * 
 * Segment the nuclei in the Hoechst or Dapi channel and measure the intensities
 * for each nucleus in the remaining channels.
 * 
 * (c) 2018, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 * 
**/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Intensity-Per-Nucleus-Tool";
var nucleiChannels = newArray("hoechst", "dapi");
var	_SCALE_FACTOR = 5.0;
var	_MIN_SIZE = 50;

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

exit();

function measureIntensityPerNucleus() {
	run("Set Measurements...", "area mean redirect=None decimal=3");
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
		headings = split(Table.headings, "\t");
		for(c=1; c<headings.length; c++) {
			data = Table.getColumn(headings[c]);
			addResultsColumnToTable(headings[c], data, channelNames[indicesOfChannelsToBeMeasured[i]-1], path, filename);
		}
	}
}

function addResultsColumnToTable(columnName, data, tableName, path, filename) {
	if (isOpen(tableName)) {
		selectWindow(tableName);
	} else {
		Table.create(tableName);
	}
	rowIndex = Table.size;
	for (i = 0; i < data.length; i++) {
		Table.set("path", rowIndex, path);
		Table.set("filename", rowIndex, filename);
		Table.set("nucleus nr.", rowIndex, i+1);
		Table.set(columnName, rowIndex, data[i]);
		Table.update;
		rowIndex++;
	}
	selectWindow("Results");
}
function selectNuclei() {
	imageID = getImageID();
	run("Scale...", "x="+(1.0/_SCALE_FACTOR)+" y="+(1.0/_SCALE_FACTOR)+" interpolation=Bilinear create title=small_tmp");
	setAutoThreshold("Huang dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Watershed");
	run("Scale...", "x="+_SCALE_FACTOR+" y="+_SCALE_FACTOR+" interpolation=Bilinear create title=big_tmp");
	setAutoThreshold("Huang");
	run("Analyze Particles...", "size="+_MIN_SIZE+"-Infinity circularity=0.00-1.00 show=Nothing exclude");
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
		if (contains(nucleiChannels, channelName, true)) return i+1;
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
