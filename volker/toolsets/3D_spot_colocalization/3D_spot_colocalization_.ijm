var _NUCLEUS_CHANNEL = 1;
var _SPOTS1_CHANNEL = 2;
var _SPOTS2_CHANNEL = 3;
var _SIGMA = 1;
var _MAX_FINDER_THRESHOLD = 35;
var _RADIUS_XY = 3;
var _RADIUS_Z = 5;
var _NOISE = 20;


var _J_TABLE_A = "SC1";
var _J_TABLE_B = "SC2";

var _J_ACTIONS = newArray("DistanceMatrix",
						"CumulatedNeighbors",
						"PlotDistanceDistribution",
						"CountCloserNeighbors",
						"GetCloserPairs");

var _J_MORE_ARGS = newArray("", //Get Distance Matrix
							"", //Get Cumulated Neighbors
							"256", //Get Distance Distribution
							"1",	//Count Neighbors Closer
							"1"); //Get Pairs Close


macro "Get Spots Outside of Nucleus Action Tool - C000T4b12S"{
	getSpotsOutsideOfNucleusAction();
}

macro "Get Spots Outside of Nucleus Action Tool Options"{
	showConfigDialog();
}

macro "Execute Jython Action Tool - C000T4b12P "{
	executeJythonAction();
}

macro "Execute Jython Action Tool Options "{
	showJythonConfigDialog();
}

macro "Unused Tool-1 - " {}  // leave empty slot

var cmdSpots = newArray("Get Spots Outside of Nucleus",
					"Open Settings Dialog",
					"--",
					"Segment Nucleus", 
					"Detect Spots", 
					"Remove Spots in Nucleus", 
					"Filter spots in RT");
var menuSpots = newMenu("Get Spots Outside of Nucleus Menu Tool", cmdSpots);
macro "Get Spots Outside of Nucleus Menu Tool - C000T4b12S"{
	label = getArgument();
	if(label == cmdSpots[0])	getSpotsOutsideOfNucleusAction();
	if(label == cmdSpots[1])	showConfigDialog();
	if(label == cmdSpots[3])	segmentNucleus(_NUCLEUS_CHANNEL);
	if(label == cmdSpots[4])	detectSpotsAction();
	if(label == cmdSpots[5])	removeSpotsInNucleusAction();
	if(label == cmdSpots[6])	filterSpotsAction();
}
						
var cmdJython = newArray("Execute Jython",
					"Open Settings Dialog",
					"--",
					"Get Distance Matrix", 
					"Get Cumulated Neighbors", 
					"Get Distance Distribution", 
					"Count Neighbors Closer", 
					"Get Pairs Closer");
var menuJython = newMenu("Execute Jython Menu Tool", cmdJython);
macro "Execute Jython Menu Tool - C000T4b12P"{
	label = getArgument();
	if(label == cmdJython[0])	executeJythonAction();
	if(label == cmdJython[1])	showJythonConfigDialog();
	if(label == cmdJython[3])	getDistanceMatrixAction();
	if(label == cmdJython[4])	getCumulatedNeighborsAction();
	if(label == cmdJython[5])	getDistanceDistributionAction();
	if(label == cmdJython[6])	countNeighborsCloserAction();
	if(label == cmdJython[7])	getPairsCloserAction();
}

macro "unused Tool - " {}  // leave empty slot

macro "Prepare Table for Napari Action Tool - C000T4b12p"{
	Dialog.create("Prepare Table for Napari");

	Dialog.addCheckbox("Are initial coords in microns",true);

	strHeads = Table.headings();
	heads = split(strHeads,"\t");
	Dialog.addChoice("X Column",heads,heads[0]);
	Dialog.addChoice("Y Column",heads,heads[1]);
	Dialog.addChoice("Z Column",heads,heads[2]);
	Dialog.addChoice("V Column",heads,heads[heads.length-1]);

	Dialog.show();

	transformToPixel = Dialog.getCheckbox();
	xHeader  = Dialog.getChoice();
	yHeader  = Dialog.getChoice();
	zHeader  = Dialog.getChoice();
	vHeader  = Dialog.getChoice();
	
	prepareTableForNapariExport(transformToPixel,xHeader,yHeader,zHeader,vHeader);
}

/***	****	***/
/***  getSpots	***/
/***	****	***/
function getSpotsOutsideOfNucleusAction(){
	getSpotsOutsideOfNucleus(_SPOTS1_CHANNEL,_NUCLEUS_CHANNEL);
	Table.rename("Results", "SC1");
	getSpotsOutsideOfNucleus(_SPOTS2_CHANNEL,_NUCLEUS_CHANNEL);
	Table.rename("Results", "SC2");
}

function detectSpotsAction(){
	Dialog.create("Select Spot Channel");
	channels = newArray(_SPOTS1_CHANNEL,_SPOTS2_CHANNEL);
	Dialog.addChoice("Channel", channels);
	Dialog.show();
	spotsChannel = Dialog.getChoice();
	
	detectSpots(spotsChannel, _SIGMA);
}

function removeSpotsInNucleusAction(){
	Dialog.create("Remove Spots In Nucleus");
	list = getList("image.titles");
	Dialog.addChoice("Spot Mask Image", list);
	Dialog.addChoice("Nucleus Mask Image", list);
	Dialog.show();
	spots = Dialog.getChoice();
	nucleusMask = Dialog.getChoice();
	
	removeSpotsInNucleus(spots,nucleusMask);
}

function filterSpotsAction(){
	Dialog.create("Purge Spots In Nucleus");
	list = getList("image.titles");
	Dialog.addChoice("Original Image", list);
	Dialog.addChoice("Masked Spot Image", list);
	Dialog.show();
	orignalImage = Dialog.getChoice();
	maskedSpots = Dialog.getChoice();

	selectImage(orignalImage);
	getVoxelSize(width, height, depth, unit);
	filterSpots(maskedSpots,width, height, depth);
}

/***	****	***/
/***   Jython	***/
/***	****	***/
function executeJythonAction(){
	Dialog.create("Run Jython Options");
	Dialog.addChoice("Action", _J_ACTIONS);
	addPointsTablesDialog();
	Dialog.addString("Additional args:","");
	Dialog.show();
	action = Dialog.getChoice();
	getPointsTablesDialog();
	moreArgs = Dialog.getString();

	runJython(action,_J_TABLE_A,_J_TABLE_B,moreArgs);
}

function getDistanceMatrixAction(){
	runJython(_J_ACTIONS[0],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[0]);
}

function getCumulatedNeighborsAction(){
	runJython(_J_ACTIONS[1],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[1]);
}

function getDistanceDistributionAction(){
	runJython(_J_ACTIONS[2],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[2]);
}

function countNeighborsCloserAction(){
	runJython(_J_ACTIONS[3],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[3]);	
}

function getPairsCloserAction(){
	runJython(_J_ACTIONS[4],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[4]);
}

/***	****	****	***/
/***  GetSpots Analysis	***/
/***	****	****	***/
function getSpotsOutsideOfNucleus(spotsChannel,nucleusChannel){
	setBatchMode(true);
	inputImageID = getImageID();
	
	getVoxelSize(width, height, depth, unit);
	nucleusMask = segmentNucleus(nucleusChannel);

	selectImage(inputImageID);
	detectSpots(spotsChannel, _SIGMA);
	spots = getImageID();
	
	maskedSpots = removeSpotsInNucleus(spots,nucleusMask);
	
	selectImage(spots);
	close();
	selectImage(nucleusMask);
	close();

	filterSpots(maskedSpots,width, height, depth);
	close();
	setBatchMode(false);
}

function segmentNucleus(channel) {
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	maskID = getImageID();
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	return maskID;
}

function detectSpots(channel, sigma) {
	inputImageID = getImageID();
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	channelImage = getImageID();
	run("FeatureJ Laplacian", "compute smoothing=" + sigma);	
	laplaceImage = getImageID();
	run("8-bit");
	run("Invert", "stack");
	run("3D Maxima Finder", "minimmum="+_MAX_FINDER_THRESHOLD+" radiusxy="+_RADIUS_XY+" radiusz="+_RADIUS_Z+" noise="+_NOISE);
	setThreshold(1, 65535);
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Default background=Dark");
	run("Grays");
	for (i = 0; i < 3; i++) {
		run("Dilate (3D)", "iso=255");
	}
	selectImage(channelImage);
	close();
	selectImage(laplaceImage);
	close();
}

function removeSpotsInNucleus(spotImageID,nucleusMaskID){
	selectImage(nucleusMaskID);
	run("Invert", "stack");
	imageCalculator("AND create stack", spotImageID, nucleusMaskID);
	maskedSpotsID = getImageID();
	selectImage(nucleusMaskID);
	run("Invert", "stack");
	selectImage(maskedSpotsID);
	return maskedSpotsID;
}

function filterSpots(imageID,voxelWidth,voxelHeight,voxelDepth) {
	Table.create("spots");
	selectImage(imageID);
	for (i = 0; i < nResults(); i++) {
		x = getResult("X", i);	
		y = getResult("Y", i);	
		z = getResult("Z", i);	
		q = getResult("V", i);
		Stack.setSlice(z);
		v = getPixel(x, y);
		if (v>0) {
			row = Table.size("spots");
			Table.set("X", row, x, "spots");
			Table.set("Y", row, y, "spots");
			Table.set("Z", row, z, "spots");
			Table.set("V", row, q, "spots");
			Table.set("X (microns)", row, x*voxelWidth, "spots");
			Table.set("Y (microns)", row, y*voxelHeight, "spots");
			Table.set("Z (microns)", row, z*voxelDepth, "spots");
		}
	}
	close("Results");
	Table.rename("spots", "Results");
}

/***	****	***/
/***	Misc	***/
/***	****	***/
function runJython(action,table1,table2,matrixTable){
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/3D_spot_nearest_neighbor.py");
	parameter = "action="+action+",tableName1="+table1+",tableName2="+table2+",matrixTable="+matrixTable;
	
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}

function prepareTableForNapariExport(transformToPixel,xHeader,yHeader,zHeader,vHeader){
	inTable = Table.title();
	outTable = "Results";
	if(inTable ==outTable){
		Table.rename(inTable, inTable+"-1");
		inTable = Table.title();
	}
	Table.create(outTable);

	width = 1;
	height = 1;
	depth = 1;
	if(transformToPixel){
		getVoxelSize(width, height, depth, unit);
	}
	
	count = Table.size(inTable);
	for (i = 0; i < count; i++) {
		x = Table.get(xHeader, i,inTable) / width;
		y = Table.get(yHeader, i,inTable) / height;
		z = Table.get(zHeader, i,inTable) / depth;
		v = Table.get(vHeader, i,inTable);
		
		row = Table.size(outTable);
		Table.set("X", row, x, outTable);
		Table.set("Y", row, y, outTable);
		Table.set("Z", row, z, outTable);
		Table.set("V", row, v, outTable);
	}
}

function showConfigDialog(){
	Dialog.create("Get Spots Options");
	
	addChannelsDialog();
	addDetectSpotDialog();

	Dialog.show()

	getChannelsDialog();
	getDetectSpotDialog();
}

function showJythonConfigDialog(){
	Dialog.create("Jython Options");

	addPointsTablesDialog();

	Dialog.addMessage("Specific arguments of each actions");
	for(i=0;i<_J_ACTIONS.length;i++){
		Dialog.addString(_J_ACTIONS[i], _J_MORE_ARGS[i]);
	}

	Dialog.show();
	
	getPointsTablesDialog();
	
	for(i=0;i<_J_ACTIONS.length;i++){
		_J_MORE_ARGS[i] = Dialog.getString();
	}
}

function addDetectSpotDialog(){
	Dialog.addNumber("Sigma of Laplacian", _SIGMA);
	Dialog.addNumber("Local Maxima Threshold", _MAX_FINDER_THRESHOLD);
	Dialog.addNumber("Local Maxima Radius XY", _RADIUS_XY);
	Dialog.addNumber("Local Maxima Radius Z ", _RADIUS_Z);
	Dialog.addNumber("Local Maxima Noise", _NOISE);
}

function getDetectSpotDialog(){
	_SIGMA=Dialog.getNumber();
	_MAX_FINDER_THRESHOLD=Dialog.getNumber();
	_RADIUS_XY=Dialog.getNumber();
	_RADIUS_Z=Dialog.getNumber();
	_NOISE=Dialog.getNumber();
}

function addChannelsDialog(){
	Dialog.addNumber("Nucleus Channel", _NUCLEUS_CHANNEL);
	Dialog.addNumber("First Spots Channel", _SPOTS1_CHANNEL);
	Dialog.addNumber("Second Spots Channel", _SPOTS2_CHANNEL);
}

function getChannelsDialog(){
	_NUCLEUS_CHANNEL=Dialog.getNumber();
	_SPOTS1_CHANNEL =Dialog.getNumber();
	_SPOTS2_CHANNEL =Dialog.getNumber();
}

function addPointsTablesDialog(){
	titles = getList("window.titles");
	
	Dialog.addChoice("First  Points Table",titles,_J_TABLE_A);
	Dialog.addChoice("Second Points Table",titles,_J_TABLE_B);
}

function getPointsTablesDialog(){
	_J_TABLE_A = Dialog.getChoice();
	_J_TABLE_B = Dialog.getChoice();
}























