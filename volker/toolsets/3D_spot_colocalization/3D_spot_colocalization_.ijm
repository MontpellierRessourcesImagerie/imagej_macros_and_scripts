var _NUCLEUS_CHANNEL = 1;
var _SPOTS1_CHANNEL = 2;
var _SPOTS2_CHANNEL = 3;

var _SIGMA = newArray(1,1);
var _MAX_FINDER_THRESHOLD = newArray(35,35);
var _RADIUS_XY = newArray(0.3,0.4);
var _RADIUS_Z = newArray(0.4,0.5);
var _NOISE = newArray(20,20);

//<Name of the channel> Spots
var _TABLE_SPOTS_1 = "SC1";
var _TABLE_SPOTS_2 = "SC2";
var _TABLE_NEIGHBORS = "Final Table";

var _J_TABLE_A = "SC1";
var _J_TABLE_B = "SC2";

var _J_ACTIONS = newArray("DistanceMatrix",
						"CumulatedNeighbors",
						"PlotDistanceDistribution",
						"CountCloserNeighbors",
						"GetCloserPairs",
						"GetNearestNeighbors",
						"GetMeanDistances"
						);

var _J_MORE_ARGS = newArray("", //Get Distance Matrix
							"", //Get Cumulated Neighbors
							"32", //Get Distance Distribution
							"1",	//Count Neighbors Closer
							"0.52",//Get Pairs Close
							"",
							""); 


macro "Get Spots Outside of Nucleus Action Tool - C000T4b12S"{
	getSpotsOutsideOfNucleusAction();
}

macro "Get Spots Outside of Nucleus Action Tool Options"{
	showConfigDialog();
}

macro "Get Nearest Neighbors Action Tool - C000T4b12N "{
	getNearestNeighborsAction();
}

macro "Export Results Action Tool - C000T4b12E "{
	exportResultsAction();
}

function getNearestNeighborsAction(){
	getSpotsOutsideOfNucleusAction();
	makeFinalTableAction();
}

function exportSpots(baseFolder){
	Table.save(baseFolder+_TABLE_SPOTS_1,_TABLE_SPOTS_1);
	Table.save(baseFolder+_TABLE_SPOTS_2,_TABLE_SPOTS_2);
}

function exportNeighbors(baseFolder){
	Table.save(baseFolder+_TABLE_NEIGHBORS,_TABLE_NEIGHBORS);
}

function exportResults(baseFolder){
	exportSpots(baseFolder);
	exportNeighbors(baseFolder);
}

function exportResultsAction(){
	Dialog.create("Enter the Export Folder");
	Dialog.addDirectory("Export folder","");
	Dialog.show();
	baseFolder = Dialog.getString();
	
	getNearestNeighborsAction();
	exportResults(baseFolder);
}

macro "Unused Tool-1 - " {}  // leave empty slot

var cmdSpots = newArray("Get Spots Outside of Nucleus",
					"Open Settings Dialog",
					"--",
					"Segment Nucleus", 
					"Detect Spots", 
					"Remove Spots in Nucleus", 
					"Filter spots in RT"
					);
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
					"Get Pairs Closer",
					"Get Nearest Neighbors",
					"Get Mean Distances"
					);
var menuJython = newMenu("Execute Jython Menu Tool", cmdJython);
macro "Execute Jython Menu Tool - C000T4b12P"{
	label = getArgument();
	if(label == cmdJython[0])	executeJythonAction();
	if(label == cmdJython[1])	showJythonConfigDialog();
	if(label == cmdJython[3])	j_getDistanceMatrixAction();
	if(label == cmdJython[4])	j_getCumulatedNeighborsAction();
	if(label == cmdJython[5])	j_getDistanceDistributionAction();
	if(label == cmdJython[6])	j_countNeighborsCloserAction();
	if(label == cmdJython[7])	j_getPairsCloserAction();
	if(label == cmdJython[8])	j_getNearestNeighborsAction();
	if(label == cmdJython[9])	j_getMeanDistancesAction();
}

macro "unused Tool - " {}  // leave empty slot

macro "Prepare Table for Napari Action Tool - C000T4b12p"{
	Dialog.create("Prepare Table for Napari");

	Dialog.addCheckbox("Are initial coords in microns",true);

	strHeads = Table.headings();
	heads = split(strHeads,"\t");
	iX = 0;
	iY = 1;
	iZ = 2;
	iV = 3;
	for(i=heads.length-1;i>=0;i--){
		if(heads[i]=="X" || heads[i]=="x"){	iX = i;}
		if(heads[i]=="Y" || heads[i]=="y"){	iY = i;}
		if(heads[i]=="Z" || heads[i]=="z"){	iZ = i;}
		if(heads[i]=="V" || heads[i]=="v"){	iV = i;}
		
	}
	Dialog.addChoice("X Column",heads,heads[iX]);
	Dialog.addChoice("Y Column",heads,heads[iY]);
	Dialog.addChoice("Z Column",heads,heads[iZ]);
	Dialog.addChoice("V Column",heads,heads[iV]);

	Dialog.show();

	transformToPixel = Dialog.getCheckbox();
	xHeader  = Dialog.getChoice();
	yHeader  = Dialog.getChoice();
	zHeader  = Dialog.getChoice();
	vHeader  = Dialog.getChoice();
	
	prepareTableForNapariExport(transformToPixel,xHeader,yHeader,zHeader,vHeader);
}

macro "TEMP Action Tool - C000 T0b09T T3b09m Tcb09p"{
	prepareTableForPairExport(true);
}

/***	****	***/
/***  getSpots	***/
/***	****	***/
function getSpotsOutsideOfNucleusAction(){
	getSpotsOutsideOfNucleus(_SPOTS1_CHANNEL,_NUCLEUS_CHANNEL,0);
	Table.rename("Results", "SC1");
	getSpotsOutsideOfNucleus(_SPOTS2_CHANNEL,_NUCLEUS_CHANNEL,1);
	Table.rename("Results", "SC2");
}

function detectSpotsAction(){
	Dialog.create("Select Spot Channel");
	channels = newArray(_SPOTS1_CHANNEL,_SPOTS2_CHANNEL);
	Dialog.addChoice("Channel", channels);
	Dialog.show();
	spotsChannel = Dialog.getChoice();

	detectSpots(spotsChannel, 0);
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

function j_getDistanceMatrixAction(){
	runJython(_J_ACTIONS[0],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[0]);
}

function j_getCumulatedNeighborsAction(){
	runJython(_J_ACTIONS[1],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[1]);
}

function j_getDistanceDistributionAction(){
	runJython(_J_ACTIONS[2],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[2]);
}

function j_countNeighborsCloserAction(){
	runJython(_J_ACTIONS[3],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[3]);	
}

function j_getPairsCloserAction(){
	runJython(_J_ACTIONS[4],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[4]);
}

function j_getNearestNeighborsAction(){
	runJython(_J_ACTIONS[5],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[5]);
}

function j_getMeanDistancesAction(){
	runJython(_J_ACTIONS[6],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[6]);
}

/***	****	****	***/
/***  GetSpots Analysis	***/
/***	****	****	***/
function getSpotsOutsideOfNucleus(spotsChannel,nucleusChannel,paramID){
	setBatchMode(true);
	inputImageID = getImageID();
	
	getVoxelSize(width, height, depth, unit);
	nucleusMask = segmentNucleus(nucleusChannel);

	selectImage(inputImageID);
	detectSpots(spotsChannel, paramID);
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

function detectSpots(channel, paramID) {
	inputImageID = getImageID();
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	getVoxelSize(width, height, depth, unit);
	radiusXY = _RADIUS_XY[paramID] / width;
	radiusZ = _RADIUS_Z[paramID] / depth;
	
	channelImage = getImageID();
	run("FeatureJ Laplacian", "compute smoothing=" + _SIGMA[paramID]);	
	laplaceImage = getImageID();
	run("8-bit");
	run("Invert", "stack");
	run("3D Maxima Finder", "minimmum="+_MAX_FINDER_THRESHOLD[paramID]+" radiusxy="+radiusXY+" radiusz="+radiusZ+" noise="+_NOISE[paramID]);
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
/***	Temp	***/
/***	****	***/
/*
macro "Get Gaussian"{
	getGaussian();
}

function getGaussian(){
	tableName="Nearest Neighbors SC2>SC1";
	distanceColumn = "Distance";
	Table.sort(distanceColumn,tableName);
	distances = Table.getColumn(distanceColumn);
	Fit.doFit('Gaussian',Array.getSequence(distances.length),distances);
	Fit.plot()
	center = Fit.p(2);
	sigma = Fit.p(3);
	nSteps = 32
	Table.create("G_Outb2");
	for(i=0;i<nSteps;i++){
		thresholdX = center - (i * sigma);
		thresholdY = Fit.f(thresholdX);
		Table.set("i",i,i);
		Table.set("C - i*Sigma",i,thresholdX);
		Table.set("f(C - i*Sigma)",i,thresholdY);
		print("ThresholdX = C - "+i+" * sigma = "+thresholdX);
		print("ThresholdY = f("+thresholdX+") = "+thresholdY);
		print("");
	}
	print(Fit.f(150));
}
*/

macro "Make Final Table"{
	makeFinalTableAction();
}

function makeFinalTableAction(){
	
	runJython(_J_ACTIONS[5],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[5]);
	tableA = "Nearest Neighbors SC1>SC2";
	tableB = "Nearest Neighbors SC2>SC1";
	makeFinalTable(tableA,tableB);
}

//A means from A to B
//B means from B to A
function makeFinalTable(tableA,tableB){
	finalTable = "Final Table";
	Table.create(finalTable);

	nbPointsA = Table.size(tableA);
	nbPointsB = Table.size(tableB);

	nearestOf = newArray(nbPointsA+nbPointsB);
	for(i=0;i<nbPointsA+nbPointsB;i++){
		if(i<nbPointsA){
			nearestOf[i]="a";
		}else{
			nearestOf[i]="b";
		}
	}

	itselfA = Array.getSequence(nbPointsA);
	neighborsA = Table.getColumn("ID Neighbor",tableA);
	distanceA = Table.getColumn("Distance",tableA);

	itselfB = Array.getSequence(nbPointsB);
	neighborsB = Table.getColumn("ID Neighbor",tableB);
	distanceB = Table.getColumn("Distance",tableB);	
	duplicates = newArray();
	t=0;
	for(idB=0;idB<nbPointsB;idB++){
		for(idA=0;idA<nbPointsA;idA++){
			if(idB == neighborsA[idA] && idA == neighborsB[idB]){
				duplicates[t++]=idB;
				nearestOf[idA]="ab";
				break;
			}
		}
	 }

	 for(t=0;t<duplicates.length;t++){
 		print(duplicates[t]);
		itselfB = Array.deleteIndex(itselfB,duplicates[t]-t);
		neighborsB = Array.deleteIndex(neighborsB,duplicates[t]-t);
		distanceB = Array.deleteIndex(distanceB,duplicates[t]-t);
		nearestOf = Array.deleteIndex(nearestOf,nbPointsA+duplicates[t]-t);
	 }
	

	nbPointsA = Table.size(tableA);
	nbPointsB = Table.size(tableB);
	
	for(i=0;i<nearestOf.length;i++){
		if(i<nbPointsA){
			indexA = i;
			Table.set("ID A", i, itselfA[indexA],finalTable);
			Table.set("ID B", i, neighborsA[indexA],finalTable);
			
			Table.set("Distance", i, distanceA[indexA],finalTable);
			
		}else{
			indexB = i-nbPointsA;
			Table.set("ID A", i, neighborsB[indexB],finalTable);
			Table.set("ID B", i, itselfB[indexB],finalTable);
			
			Table.set("Distance", i, distanceB[indexB],finalTable);
			
		}
		Table.set("Nearest neighbor of A", i, nearestOf[i].contains("a") ,finalTable);
		Table.set("Nearest neighbor of B", i, nearestOf[i].contains("b")  ,finalTable);
	}
	
}

macro "Send Active Image to Napari Action Tool - C000 T6b12I"{
	sendImageToNapari();
}

macro "Send Spots to Napari Action Tool - C000 T6b12S"{
	sendPointsToNapari();
}

macro "Send Neighbors to Napari Action Tool - C000 T6b12N"{
	sendDistancesToNapari();
}

function sendImageToNapari(){
	sendToNapari("sendActiveImage","","");
}

function sendPointsToNapari(){
	headers = Table.headings();
	headings = split(headers,"\t");
	Table.deleteColumn(headings[5],_TABLE_SPOTS_1);
	Table.deleteColumn(headings[6],_TABLE_SPOTS_1);
	Table.deleteColumn(headings[7],_TABLE_SPOTS_1);
	Table.deleteColumn(headings[5],_TABLE_SPOTS_2);
	Table.deleteColumn(headings[6],_TABLE_SPOTS_2);
	Table.deleteColumn(headings[7],_TABLE_SPOTS_2);
	sendToNapari("sendPoints",_TABLE_SPOTS_1,_TABLE_SPOTS_2);
}

function sendDistancesToNapari(){
	sendToNapari("sendLines",_TABLE_NEIGHBORS);
}


function sendToNapari(action,table1,table2){
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/3D_spot_py_interface.py");
	parameter = "action="+action+",tableName1="+table1+",tableName2="+table2;
	
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
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
	if(inTable == outTable){
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
		print(x+"-"+y+"-"+z+"-"+v);
		row = Table.size(outTable);
		Table.set("X", row, x, outTable);
		Table.set("Y", row, y, outTable);
		Table.set("Z", row, z, outTable);
		Table.set("V", row, v, outTable);
	}
	Table.update(outTable);
}


function prepareTableForPairExport(transformToPixel){
	inTable = Table.title();
	headings = Table.headings
	tableHeader = split(headings,"\t");
	
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
		row = Table.size(outTable);
		for(h=0;h<tableHeader.length;h++){
			if(tableHeader[h]=="")	continue;
			currentVal = Table.get(tableHeader[h], i,inTable);
			if(startsWith(tableHeader[h], "x")){
				currentVal = currentVal / width;
			}
			if(startsWith(tableHeader[h], "y")){
				currentVal = currentVal / height;
			}
			if(startsWith(tableHeader[h], "z")){
				currentVal = currentVal / depth;
			}
			Table.set(tableHeader[h], row, currentVal, outTable);
		}
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

function addDetectSpotDialog(){
	Dialog.addNumber("Sigma of Laplacian", _SIGMA[0]);
	Dialog.addToSameRow();
	Dialog.addNumber("", _SIGMA[1]);
	
	Dialog.addNumber("Local Maxima Threshold", _MAX_FINDER_THRESHOLD[0]);
	Dialog.addToSameRow();
	Dialog.addNumber("", _MAX_FINDER_THRESHOLD[1]);
	
	Dialog.addNumber("Local Maxima Radius XY", _RADIUS_XY[0]);
	Dialog.addToSameRow();
	Dialog.addNumber("", _RADIUS_XY[1]);
	
	Dialog.addNumber("Local Maxima Radius Z ", _RADIUS_Z[0]);
	Dialog.addToSameRow();
	Dialog.addNumber("", _RADIUS_Z[1]);
	
	Dialog.addNumber("Local Maxima Noise", _NOISE[0]);
	Dialog.addToSameRow();
	Dialog.addNumber("", _NOISE[1]);
}

function getDetectSpotDialog(){
	_SIGMA[0]=Dialog.getNumber();
	_SIGMA[1]=Dialog.getNumber();
	
	_MAX_FINDER_THRESHOLD[0]=Dialog.getNumber();
	_MAX_FINDER_THRESHOLD[1]=Dialog.getNumber();
	
	_RADIUS_XY[0]=Dialog.getNumber();
	_RADIUS_XY[1]=Dialog.getNumber();
	
	_RADIUS_Z[0]=Dialog.getNumber();
	_RADIUS_Z[1]=Dialog.getNumber();
	
	_NOISE[0]=Dialog.getNumber();
	_NOISE[1]=Dialog.getNumber();
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

macro "Export To NaparIO"{
	exportToNaparIOAction();
}
function exportToNaparIOAction(){
	Dialog.create("Enter the Export Folder");
	Dialog.addDirectory("Export folder","");
	Dialog.show();
	baseFolder = Dialog.getString();
	exportToNaparIO(baseFolder);
}

function exportToNaparIO(baseFolder){
	configFile = baseFolder +"config.yml";
	configString = initConfigFile();
	configString = exportImagesToNaparIO(baseFolder,configString);
	configString = exportSpotsToNaparIO (baseFolder,configString);
	configString = exportLinesToNaparIO (baseFolder,configString);

	file = File.open(configFile);
	print(file,configString);
}

var _COLORS = newArray("magenta","cyan","yellow","red","green","blue","orange","brown","white");
var _POINTS_COLORS = newArray("inferno","viridis");
function exportImagesToNaparIO(baseFolder,configString){
	print("Images to NaparIO");
	sliceLabels = Property.getSliceLabel
	sliceLabelsSplit = split(sliceLabels, "/");
	getDimensions(width, height, channels, slices, frames);
	title = getTitle();
	run("Deinterleave", "how="+channels+" keep");
	for (i = 1; i < channels+1; i++) {
		selectImage(title+" #"+i);
		if(sliceLabelsSplit.length>=i+1){
			save(baseFolder+sliceLabelsSplit[i+1]+".tif");
			filename = sliceLabelsSplit[i+1]+".tif";
			configString = addLayerToConfig(configString,sliceLabelsSplit[i+1],filename,"image",_COLORS[i-1]);
			
			selectImage(title+" #"+i);
			close();
		}
	}
	return configString;
}

function exportSpotsToNaparIO(baseFolder,configString){
	print("Spots to NaparIO");
	for(i=0;i<2;i++){
		tableName = "_";
		if(i==0){
			tableName = _TABLE_SPOTS_1;
		}else{
			tableName = _TABLE_SPOTS_2;
		}
		layerName = "tmpSpots "+i;
		fileName = layerName+".csv";
		makeSpotsCSV(baseFolder,fileName,tableName);
		configString = addLayerToConfig(configString,layerName,fileName,"points",_POINTS_COLORS[i]);		
	}
	return configString;
}

function makeSpotsCSV(baseFolder,fileName,tableName){
	selectWindow(tableName);
	prepareTableForNapariExport(false,"Z","Y","X","V");
	Table.applyMacro("V = V/255","Results");
	Table.renameColumn("X", "axis-0","Results");
	Table.renameColumn("Y", "axis-1","Results");
	Table.renameColumn("Z", "axis-2","Results");
	Table.renameColumn("V", "confidence","Results");
	Table.save(baseFolder+fileName,"Results");
}

function exportLinesToNaparIO(baseFolder,configString){
	print("Lines to NaparIO");
	
	return configString;
	
}


function initConfigFile(){
	layer = "layers:\n"
	out = addCalibrationToConfig();
	out = out + layer;
	print(out);
	return out;
}

function addCalibrationToConfig(){
	getVoxelSize(width, height, depth, unit);
	cal = "calibration:\n" + "  x: "+width +"\n" + "  y: "+height+"\n" + "  z: "+depth +"\n";
	return cal;
}

function addLayerToConfig(configString,name,filename,type,colormap){
	layer =	"- name: "+name+"\n"+
			"  filename: "+filename+"\n"+
			"  type: "+type+"\n"+
			"  colormap: "+colormap+"\n";
	return configString+layer;
}
