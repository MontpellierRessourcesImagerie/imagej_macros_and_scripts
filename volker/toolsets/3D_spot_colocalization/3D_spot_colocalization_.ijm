var _COLORS = newArray("magenta","cyan","yellow","red","green","blue","orange","brown","white");
var _POINTS_COLORS = newArray("inferno","viridis");

var _NUCLEUS_CHANNEL = 1;
var _SPOTS1_CHANNEL = 2;
var _SPOTS2_CHANNEL = 3;

var _SIGMA = newArray(1,1);
var _MAX_FINDER_THRESHOLD = newArray(35,35);
var _RADIUS_XY = newArray(0.3,0.4);
var _RADIUS_Z = newArray(0.4,0.5);
var _NOISE = newArray(20,20);

//<Name of the channel> Spots
var _TABLE_SPOTS_1 = "C"+_SPOTS1_CHANNEL+"-Spots";
var _TABLE_SPOTS_2 = "C"+_SPOTS2_CHANNEL+"-Spots";
var _TABLE_NEIGHBORS = "Neighbors";

var _J_TABLE_A = _TABLE_SPOTS_1;
var _J_TABLE_B = _TABLE_SPOTS_2;

var _J_ACTIONS = newArray("DistanceMatrix",
						"CumulatedNeighbors",
						"PlotDistanceDistribution",
						"CountCloserNeighbors",
						"GetCloserPairs",
						"GetNearestNeighbors",
						"GetMeanDistances",
						"CalculateRipley"
						);

var _J_MORE_ARGS = newArray("", //Get Distance Matrix
							"", //Get Cumulated Neighbors
							"32", //Get Distance Distribution
							"1",	//Count Neighbors Closer
							"0.52",//Get Pairs Close
							"",
							"",
							""
							); 

var _VOLUME_NUCLEI = -1;
var _VOLUME_CYTOPLASM = -1;


macro "Get Spots Outside of Nucleus Action Tool - C000T4b12S"{
	getSpotsOutsideOfNucleusAction();
	sendPointsToNapari();
}

macro "Get Spots Outside of Nucleus Action Tool Options"{
	showSpotsConfigDialog();
}

macro "Get Nearest Neighbors Action Tool - C000T4b12N "{
	j_calculateRipleyAction();
	radius = findColocThreshold("Ripley's Table");
	_J_MORE_ARGS[4] = radius;
	getNearestNeighborsAction();
	neighborsTableA = "Nearest Neighbors "+_TABLE_SPOTS_1+">"+_TABLE_SPOTS_2;
	neighborsTableB = "Nearest Neighbors "+_TABLE_SPOTS_2+">"+_TABLE_SPOTS_1;
	countColocs(neighborsTableA,neighborsTableB,radius);
	sendDistancesToNapari();
}

macro "Get Nearest Neighbors Action Tool Options "{
	showNeighborsConfigDialog();
}

macro "Export Results Action Tool - C000T4b12E "{
	
	exportResultsAction();
}

function getNearestNeighborsAction(){
	//getSpotsOutsideOfNucleusAction();
	makeNeighborsTableAction();
}

function exportResultsAction(){
	Dialog.create("Enter the Export Folder");
	Dialog.addDirectory("Export folder","");
	Dialog.show();
	baseFolder = Dialog.getString();
	
	exportResults(baseFolder);
}

function exportResults(baseFolder){
	exportTable(baseFolder,_TABLE_SPOTS_1);
	exportTable(baseFolder,_TABLE_SPOTS_2);
	exportTable(baseFolder,_TABLE_NEIGHBORS);
}

function exportTable(baseFolder,tableName){
	Table.save(baseFolder+tableName+".csv",tableName);
}

macro "Unused Tool 0 - " {}  // leave empty slot

var cmdSendToNapari = newArray("Send Everything",
					"--",
					"Send Active Image", 
					"Send Spots", 
					"Send Neighbors Lines"
					);
var menuSpots = newMenu("Send to Napari Menu Tool", cmdSendToNapari);
macro "Send to Napari Menu Tool - C000T4b12^"{
	label = getArgument();
	if(label == cmdSendToNapari[0])	sendEverythingToNapari();
	if(label == cmdSendToNapari[2])	sendImageToNapari();
	if(label == cmdSendToNapari[3])	sendPointsToNapari();
	if(label == cmdSendToNapari[4])	sendDistancesToNapari();
}

macro "Unused Tool 1 - " {}  // leave empty slot

var cmdSpots = newArray("Get Spots Outside of Nucleus",
					"Open Settings Dialog",
					"--",
					"Segment Nucleus",
					"Segment Cytoplasm",
					"Detect Spots", 
					"Remove Spots in Nucleus", 
					"Filter spots in RT"
					);
var menuSpots = newMenu("Get Spots Outside of Nucleus Menu Tool", cmdSpots);
macro "Get Spots Outside of Nucleus Menu Tool - C000T4b12S"{
	label = getArgument();
	if(label == cmdSpots[0])	getSpotsOutsideOfNucleusAction();
	if(label == cmdSpots[1])	showSpotsConfigDialog();
	if(label == cmdSpots[3])	segmentNucleus(_NUCLEUS_CHANNEL);
	if(label == cmdSpots[4])	segmentCytoplasm(3);
	if(label == cmdSpots[5])	detectSpotsAction();
	if(label == cmdSpots[6])	removeSpotsInNucleusAction();
	if(label == cmdSpots[7])	filterSpotsAction();
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
					"Get Mean Distances",
					"Calculate Ripley"
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
	if(label == cmdJython[10])	j_calculateRipleyAction();
}

macro "Prepare Spots Table for Napari"{
	Dialog.create("Prepare Spots Table for Napari");

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

macro "Prepare Distances Table for Napari"{
	prepareTableForPairExport(true,"");
}


/***	****	***/
/***  getSpots	***/
/***	****	***/
function getSpotsOutsideOfNucleusAction(){
	getSpotsOutsideOfNucleus(_SPOTS1_CHANNEL,_NUCLEUS_CHANNEL,0);
	if(isOpen(_TABLE_SPOTS_1)){	close(_TABLE_SPOTS_1);}
	Table.rename("Results", _TABLE_SPOTS_1);
	
	getSpotsOutsideOfNucleus(_SPOTS2_CHANNEL,_NUCLEUS_CHANNEL,1);
	if(isOpen(_TABLE_SPOTS_2)){	close(_TABLE_SPOTS_2);}
	Table.rename("Results", _TABLE_SPOTS_2);
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

function j_calculateRipleyAction(){
	_VOLUME_CYTOPLASM = calculateCytoplasmVolume();
	_VOLUME_NUCLEI = calculateNucleiVolume();
	runJython(_J_ACTIONS[7],_J_TABLE_A,_J_TABLE_B,_VOLUME_CYTOPLASM - _VOLUME_NUCLEI);
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
	cytoplasmMask = segmentCytoplasm(spotsChannel);
	
	selectImage(inputImageID);
	detectSpots(spotsChannel, paramID);
	spots = getImageID();
	
	maskedNucleiSpots = removeSpotsInNucleus(spots,nucleusMask);
	maskedSpots = removeSpotsInNucleus(maskedNucleiSpots,cytoplasmMask);
	
	selectImage(spots);
	close();
	selectImage(maskedNucleiSpots);
	close();
	selectImage(nucleusMask);
	close();
	selectImage(cytoplasmMask);
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

function segmentCytoplasm(channel) {
	run("Duplicate...", "duplicate channels="+channel+"-"+channel);
	maskID = getImageID();
	setOption("BlackBackground", false);
	run("Convert to Mask", "method=Percentile background=Default calculate");
	for (i = 1; i <= nSlices; i++) {
	    setSlice(i);
		run("Analyze Particles...", "size=10000-Infinity pixel add slice");
		if (roiManager("count")>1){
			print("Multiple Particles for only one slice");
		}
		roiManager("select", 0);

		run("Create Mask");	
		run("Select All");
		run("Copy");
		close();
		selectImage(maskID);
		run("Paste");
		roiManager("delete");
		if(roiManager("count")>1){
			roiManager("delete");
		}
	}
	run("Invert","stack");
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

macro "Make Neighbors Table"{
	makeNeighborsTableAction();
}

function makeNeighborsTableAction(){
	runJython(_J_ACTIONS[5],_J_TABLE_A,_J_TABLE_B,_J_MORE_ARGS[5]);
	tableA = "Nearest Neighbors "+_TABLE_SPOTS_1+">"+_TABLE_SPOTS_2;
	tableB = "Nearest Neighbors "+_TABLE_SPOTS_2+">"+_TABLE_SPOTS_1;
	makeNeighborsTable(tableA,tableB);
}

//A means from A to B
//B means from B to A
function makeNeighborsTable(tableA,tableB){
	neighborsTable = _TABLE_NEIGHBORS;
	Table.create(neighborsTable);

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
	
	for(i=0;i<nearestOf.length;i++){
		if(i<nbPointsA){
			indexA = i;
			Table.set("ID A", i, itselfA[indexA],neighborsTable);
			Table.set("ID B", i, neighborsA[indexA],neighborsTable);
			Table.set("Distance", i, distanceA[indexA],neighborsTable);
		}else{
			indexB = i-nbPointsA;
			Table.set("ID A", i, neighborsB[indexB],neighborsTable);
			Table.set("ID B", i, itselfB[indexB],neighborsTable);
			Table.set("Distance", i, distanceB[indexB],neighborsTable);
		}
		Table.set("Nearest neighbor of A", i, nearestOf[i].contains("a") ,neighborsTable);
		Table.set("Nearest neighbor of B", i, nearestOf[i].contains("b")  ,neighborsTable);
	}
	
}

function sendEverythingToNapari(){
	sendImageToNapari();
	sendPointsToNapari();
	sendDistancesToNapari();
}

function sendImageToNapari(){
	sendToNapari("sendActiveImage","","");
}

function sendPointsToNapari(){
	removeMicronsFromPointsTable(_TABLE_SPOTS_1,"X","Y","Z");
	removeMicronsFromPointsTable(_TABLE_SPOTS_2,"X","Y","Z");
	
	sendToNapari("sendPoints",_TABLE_SPOTS_1,_TABLE_SPOTS_2);

	addMicronsToPointsTable(_TABLE_SPOTS_1,"X","Y","Z");
	Table.update(_TABLE_SPOTS_1);
	addMicronsToPointsTable(_TABLE_SPOTS_2,"X","Y","Z");
	Table.update(_TABLE_SPOTS_2);
}

function sendDistancesToNapari(){
	j_getPairsCloserAction();
	tableName = "Pairs Coords";
	prepareTableForPairExport(true,tableName);
	sendToNapari("sendLines",tableName,"");
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

macro "FindColocThreshold"{
	findColocThreshold("Ripley's Table");
}

function findColocThreshold(table){
	tableLength = Table.size(table);
	firstRadiusUnder = -1;
	alreadyUnder = false;
	for(idx=0;idx<tableLength;idx++){
		currentRadius = Table.get("Radius", idx,table);
		currentL = Table.get("Ripley's L", idx,table);
		if(currentL <= 0){
			if(!alreadyUnder){
				alreadyUnder = true;
				firstRadiusUnder = currentRadius;
			}
		}
		if(currentL > 0){
			alreadyUnder = false;
		}
		print(currentRadius+" : "+currentL+" >>> "+alreadyUnder);
	}
	print(firstRadiusUnder);
	return firstRadiusUnder;
}

macro "TMP"{
	print("Total Image Volume	: "+calculateImageVolume());
	print("Nuclei Volume		: "+calculateNucleiVolume());
	print("Cytoplasm Volume		: "+calculateCytoplasmVolume());
}

macro "TMP-2"{
	neighborsTableA = "Nearest Neighbors "+_TABLE_SPOTS_1+">"+_TABLE_SPOTS_2;
	neighborsTableB = "Nearest Neighbors "+_TABLE_SPOTS_2+">"+_TABLE_SPOTS_1;
	radius = findColocThreshold("Ripley's Table");
	countColocs(neighborsTableA,neighborsTableB,radius);
}

function countColocs(neighborsTableA,neighborsTableB,radius){
	tableA = neighborsTableA;
	tableB = neighborsTableB;

	Table.sort("Distance",tableA);
	Table.sort("Distance",tableB);

	countColocA = 0;
	countColocB = 0;

	for(i=0;i<Table.size(tableA);i++){
		if(Table.get("Distance", i,tableA)>radius){
			countColocA = i;
			break;
		}
	}
	
	for(i=0;i<Table.size(tableB);i++){
		if(Table.get("Distance", i,tableB)>radius){
			countColocB = i;
			break;
		}
	}
	
	print("Coloc from "+_TABLE_SPOTS_1+">"+_TABLE_SPOTS_2+" : "+countColocA+" / "+Table.size(tableA));
	print("Coloc from "+_TABLE_SPOTS_2+">"+_TABLE_SPOTS_1+" : "+countColocB+" / "+Table.size(tableB));	
}

function calculateNucleiVolume(){
	if(isOpen("Results")){
		selectWindow("Results");
		close();
	}
	segmentNucleus(_NUCLEUS_CHANNEL);
	run("Measure Stack...");
	run("Summarize");
	volumeN = getResult("Mean", nSlices);
	run("Close");
	run("Close");
	return volumeN/255 * calculateImageVolume();
}

function calculateCytoplasmVolume(){
	if(isOpen("Results")){
		selectWindow("Results");
		close();
	}
	segmentCytoplasm(_SPOTS1_CHANNEL);
	run("Measure Stack...");
	run("Summarize");
	volumeS1 = getResult("Mean", nSlices);
	run("Close");
	run("Close");
	segmentCytoplasm(_SPOTS2_CHANNEL);
	run("Measure Stack...");
	run("Summarize");
	volumeS2 = getResult("Mean", nSlices);
	run("Close");
	run("Close");
	volumeS = 255-((volumeS1+volumeS2)/2); 
	return volumeS/255 * calculateImageVolume();
}

function calculateImageVolume(){
	getVoxelSize(width, height, depth, unit);
	getDimensions(widthP, heightP, a, depthP, b);
	return width * widthP * height * heightP * depth * depthP;
}


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


function prepareTableForPairExport(transformToPixel,tableName){
	inTable = tableName;
	if(tableName == ""){
		inTable = Table.title();
	}
	headings = Table.headings(inTable);
	tableHeader = split(headings,"\t");
	
	outTable = "tmpRes";
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
		Table.set("_", row, row, outTable);
	}
	close(inTable);
	Table.rename(outTable,inTable);
	Table.update();
	
}

macro "AddMicrons"{
	xhead = "X";
	yhead = "Y";
	zhead = "Z";
	inTable = "SC1"
	addMicronsToPointsTable(inTable,xhead,yhead,zhead)
}

macro "RemoveMicrons"{
	xhead = "X";
	yhead = "Y";
	zhead = "Z";
	inTable = "SC1"
	removeMicronsFromPointsTable(inTable,xhead,yhead,zhead)
}

function addMicronsToPointsTable(inTable,xHeader,yHeader,zHeader){
	getVoxelSize(width, height, depth, unit);
	
	count = Table.size(inTable);
	for (i = 0; i < count; i++) {
		x = Table.get(xHeader, i,inTable) * width;
		y = Table.get(yHeader, i,inTable) * height;
		z = Table.get(zHeader, i,inTable) * depth;
		print(x+"-"+y+"-"+z);
		Table.set(xHeader+" (microns)", i, x, inTable);
		Table.set(yHeader+" (microns)", i, y, inTable);
		Table.set(zHeader+" (microns)", i, z, inTable);
	}
}

function removeMicronsFromPointsTable(inTable,xHeader,yHeader,zHeader){
	strHeads = Table.headings(inTable);
	heads = split(strHeads,"\t");
	for(i=0;i<heads.length;i++){
		if(heads[i]==xHeader+" (microns)"){	Table.deleteColumn(xHeader+" (microns)",inTable);}
		if(heads[i]==yHeader+" (microns)"){	Table.deleteColumn(yHeader+" (microns)",inTable);}
		if(heads[i]==zHeader+" (microns)"){	Table.deleteColumn(zHeader+" (microns)",inTable);}
	}
}


function showSpotsConfigDialog(){
	Dialog.create("Get Spots Options");
	
	addChannelsDialog();
	addDetectSpotDialog();

	Dialog.show()

	getChannelsDialog();
	getDetectSpotDialog();
}

function showNeighborsConfigDialog(){
	Dialog.create("Get Neighbors Options");

	addNeighborsDialog();

	Dialog.show();

	getNeighborsDialog();
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

function addNeighborsDialog(){
	//Dialog.addSlider("Maximum distance for spot pairs", 0, 5, _J_MORE_ARGS[4]);
	Dialog.addNumber("Maximum distance for spot pairs", _J_MORE_ARGS[4], 2, 8, "microns");
}

function getNeighborsDialog(){
	_J_MORE_ARGS[4]=Dialog.getNumber();
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
		layerName = tableName;
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
	j_getPairsCloserAction();
	tableName = "Pairs Coords";
	
	layerName = tableName;
	fileName = layerName+".csv";
	makeLinesCSV(baseFolder,fileName,tableName);
	configString = addLayerToConfig(configString,layerName,fileName,"shapes","magenta");		

	return configString;
}

function makeLinesCSV(baseFolder,fileName,tableName){
	selectWindow(tableName);
	
	prepareTableForPairExport(true,tableName);
	Table.create("Line-Results");
	for (i = 0; i < nResults(); i++) {
		for(lineStep = 0 ;lineStep <2 ;lineStep++){
			lineIndex = 2*i + lineStep;
			stepLeter = "";
			if(lineStep %2 == 0){
				stepLeter = "A";	
			}else{
				stepLeter = "B";
			}
			X = Table.get("x"+stepLeter,i,"Results");
			Y = Table.get("y"+stepLeter,i,"Results");
			Z = Table.get("z"+stepLeter,i,"Results");
			
			Table.set("index", lineIndex, i,"Line-Results");
			Table.set("shape-type", lineIndex, "line","Line-Results");
			Table.set("vertex-index", lineIndex, lineStep,"Line-Results");
			Table.set("axis-0",lineIndex,Z,"Line-Results");
			Table.set("axis-1",lineIndex,Y,"Line-Results");
			Table.set("axis-2",lineIndex,X,"Line-Results");	
		}
	}
	Table.save(baseFolder+fileName,"Line-Results");
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
