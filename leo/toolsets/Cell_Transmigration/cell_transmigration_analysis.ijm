var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/cell-transmigration-analysis";

var _DO_MONOLAYER	= true;
var _DO_NUCLEI		= true;
var _DO_CELL		= true;
var _DO_HIV			= true;

var _CHANNEL_MONOLAYER	= 1;
var _CHANNEL_HIV		= 2;
var _CHANNEL_CELL		= 3;
var _CHANNEL_NUCLEI		= 4;

var _DO_PLOT = true;

var _DO_TABLE = false;
var _TABLE_INDEX = 0;
var _TABLE_NAME = "ResultsTable";

var _DEBUG = false;

function showHelp() {
     run('URL...', 'url='+helpURL);
}

macro "help [f1]" {	showHelp();}
macro "Help (f1) Action Tool - C000T4b12?" {	showHelp();}

macro "Enhance Image Contrast Action Tool - C000 T4b12E"{
	enhanceContrastImage();
}

macro "Get Monolayer and Nuclei Positions Action Tool - C000 T4b12M"{
	_DO_PLOT = true;
	_DO_TABLE = false;
	setBatchMode(true);
	getPosition(_CHANNEL_MONOLAYER,false,-1,-1);
	cellBounds = getPosition(_CHANNEL_CELL,true,-1,-1);
	getPosition(_CHANNEL_NUCLEI,true,cellBounds[0],cellBounds[1]);
	setBatchMode(false);
}

macro "Empty Tool Action Tool -"{}

macro "Batch Get Positions Action Tool - C000 T4b12B"{
	baseDir = getDir("Select folder containing the images");
	batchGetPositions(baseDir,_DO_MONOLAYER,_DO_NUCLEI,_DO_CELL,_DO_HIV);
}

macro "Batch Get Positions Action Tool Options"{
	Dialog.create("Batch get Positions Options");
	Dialog.addCheckbox("Get monolayer z position", _DO_MONOLAYER);
	Dialog.addCheckbox("Get cell nuclei z position", _DO_NUCLEI);
	Dialog.addCheckbox("Get cell cytoplasm z position", _DO_CELL);
	Dialog.addCheckbox("Get HIV z position", _DO_HIV);

	Dialog.show();

	_DO_MONOLAYER	= Dialog.getCheckbox();
	_DO_NUCLEI		= Dialog.getCheckbox();
	_DO_CELL		= Dialog.getCheckbox();
	_DO_HIV			= Dialog.getCheckbox();
}

/***   TMP IN	***/
macro "Empty tool Action Tool -"{}
macro "_TMP_ Tool A Action Tool - C009 T4b12A"{	_TMP_ActionA();}
macro "_TMP_ Tool B Action Tool - C009 T4b12B"{	_TMP_ActionB();}

function _TMP_ActionA(){
	print("Starting execution of _TMP_ActionA");
	concludeFromTable();
	print("Finishing execution of _TMP_ActionA");
}

function _TMP_ActionB(){
	print("Starting execution of _TMP_ActionB");
	print("Finishing execution of _TMP_ActionB");
}
/***   TMP OUT  ***/

function enhanceContrastImage(){
	Stack.setDisplayMode("composite");
	run("Enhance Contrast", "saturated=0.35");
	run("Next Slice [>]");
	run("Enhance Contrast", "saturated=0.35");
	run("Next Slice [>]");
	run("Enhance Contrast", "saturated=0.35");
	run("Next Slice [>]");
	run("Enhance Contrast", "saturated=0.35");
}


function getPosition(channel,onlyInMonocyte,zMin,zMax){
	if(zMin == -1){	zMin = 1;}
	if(zMax == -1){	zMax = nSlices/4;}
	
	lowerSlice=-1;
	upperSlice=-1;
	channelName = getChannelName(channel);
	
	if(_DO_PLOT){	initPlot(channel);}	
	imageID = getImageID();
	
	//setBatchMode(true);
	channelImageID = getChannel(channel);
	
	if(onlyInMonocyte){
		selectImage(imageID);
		cellMaskID = makeCellMask();
		
		imageCalculator("Transparent-zero stack", channelImageID,cellMaskID);
		
		selectImage(cellMaskID);
		close();
		selectImage(channelImageID);
	}
	
	nbSlices = nSlices;
	means = newArray(zMax-zMin);
	for (i = zMin; i <= zMax; i++) {
	    setSlice(i);
	    if(onlyInMonocyte){
			setThreshold(256, 65535);
			run("Create Selection");
			resetThreshold();
	    }
		getStatistics(area,mean);
		means[i-zMin]=mean;
	}
	close();
	
	Array.getStatistics(means,min,max,meanOfMeans,stdDev);

	
	val1 = (meanOfMeans+min) / 2;
	val2 = (max+min) / 2;
	val3 = (max + 3 * min) / 4;
	
	
	sliceSequence =newArray(zMax-zMin);
	for (i = zMin; i <= zMax; i++) {
	    if(meanOfMeans<means[i-zMin]){
	    	if(lowerSlice == -1){	lowerSlice = i;}
	    	if(upperSlice  <  i){	upperSlice = i;}
		}
		sliceSequence[i-zMin]=i;
	}

	batchMode = is("Batch Mode");
	if(_DO_PLOT){	if(batchMode){	setBatchMode(false);}}
	if(_DO_PLOT){	addToPlot(getChannelColor(channel),"connected circle",sliceSequence, means);}
	if(_DO_PLOT){	addToPlot(getChannelColor(channel),"line", newArray(lowerSlice-2,upperSlice+2), newArray(meanOfMeans,meanOfMeans));}
	if(_DO_PLOT){	addToPlot("yellow","line", newArray(lowerSlice-2,upperSlice+2), newArray(val1,val1));}
	if(_DO_PLOT){	addToPlot("cyan","line", newArray(lowerSlice-2,upperSlice+2), newArray(val2,val2));}
	if(_DO_PLOT){	addToPlot("magenta","line", newArray(lowerSlice-2,upperSlice+2), newArray(val3,val3));}
	
	if(_DO_PLOT){	Plot.show();}
	if(_DO_PLOT){	if(batchMode){	setBatchMode(true);}}

	if(_DO_TABLE){	Table.set(channelName+"_Low", _TABLE_INDEX, lowerSlice,_TABLE_NAME);}
	if(_DO_TABLE){	Table.set(channelName+"_Up", _TABLE_INDEX, upperSlice,_TABLE_NAME);}
	//setBatchMode(true);
	
	print(channelName+" is between slices ["+lowerSlice+":"+upperSlice+"]");
	
	selectImage(imageID);
	return newArray(lowerSlice,upperSlice);
}

function batchGetPositions(path,doMonolayer,doNuclei,doCell,doHIV){
	_DO_PLOT = false;
	_DO_TABLE = true;
	
	filelist = getFileList(path);
	
	if(_DO_TABLE){ Table.create(_TABLE_NAME);}
	if(_DO_TABLE){ _TABLE_INDEX = 0;}

	i=0;
	while (i < lengthOf(filelist)){
		if (endsWith(filelist[i], ".ims")) {
			showProgress(i, lengthOf(filelist));
			print(i +"/"+ lengthOf(filelist));
			print("Opening file : "+ path + File.separator + filelist[i]);
			if(_DO_TABLE){	Table.set("FileName",_TABLE_INDEX,filelist[i],_TABLE_NAME);}
			setBatchMode(true);
	        run("Bio-Formats Importer", "open=[" + path + File.separator + filelist[i] +"] view=Hyperstack stack_order=XYCZT");
	             
			if(doMonolayer){	getPosition(_CHANNEL_MONOLAYER,false,-1,-1);}
			if(doCell){			cellBounds=getPosition(_CHANNEL_CELL,true,-1,-1);
				if(doNuclei){		getPosition(_CHANNEL_NUCLEI,true,cellBounds[0],cellBounds[1]);}
				if(doHIV){			getPosition(_CHANNEL_HIV,true,cellBounds[0],cellBounds[1]);}
			}else{
				if(doNuclei){		getPosition(_CHANNEL_NUCLEI,true,-1,-1);}
				if(doHIV){			getPosition(_CHANNEL_HIV,true,-1,-1);}
			}
			
			if(_DO_TABLE){	_TABLE_INDEX=_TABLE_INDEX+1;}
			//if(_DO_TABLE){	Table.update(_TABLE_NAME);}
	        close("*");
	    }
	    i++;
	}
	
	if(_DO_TABLE){	Table.update(_TABLE_NAME);}
	if(_DO_TABLE){	concludeFromTable();}
	
	if(_DO_TABLE){	Table.save(path+File.separator+"table.csv",_TABLE_NAME);}
}

function makeCellMask(){
	imageID = getChannel(_CHANNEL_CELL);
		
	run("Gaussian Blur...", "sigma=2 stack");

	printDebugImage("Blurry");
	run("Subtract Background...", "rolling=30 stack");
	run("Enhance Contrast...", "saturated=0.3 process_all use");
	printDebugImage("NoBG");
	run("Convert to Mask", "method=MaxEntropy background=Dark calculate");
	printDebugImage("Mask");

	repeat = 10;
	for(i=0;i<repeat/2;i++){	run("Dilate (3D)", "iso=255");}
	run("Fill Holes", "stack");
	for(i=0;i<repeat;i++){	run("Erode", "stack");}
	//for(i=0;i<repeat/2;i++){	run("Dilate", "stack");}
	run("Invert", "stack");
	rename("Cell Mask");
	
	return imageID;
}

function concludeFromTable(){
	nbRows = Table.size;
	for (i = 0; i < nbRows; i++) {
		Monolayer_Up	= Table.get(getChannelName(_CHANNEL_MONOLAYER)+"_Up", i);
	    Monolayer_Low	= Table.get(getChannelName(_CHANNEL_MONOLAYER)+"_Low", i);
		Nuclei_Up	= Table.get(getChannelName(_CHANNEL_NUCLEI)+"_Up", i);
	    Nuclei_Low	= Table.get(getChannelName(_CHANNEL_NUCLEI)+"_Low", i);
		Cell_Up		= Table.get(getChannelName(_CHANNEL_CELL)+"_Up", i);
	    Cell_Low	= Table.get(getChannelName(_CHANNEL_CELL)+"_Low", i);
		
		Monolayer_Mid	= (Monolayer_Up + Monolayer_Low) / 2;
		Nuclei_Mid		= (Nuclei_Up + Nuclei_Low) / 2;

		isNucleiBefore = false;
		if(Nuclei_Mid<Monolayer_Mid){isNucleiBefore = true;}
		Table.set("Nuclei before Monolayer", i, isNucleiBefore);
		
		print(Nuclei_Mid +" < "+ Monolayer_Mid +" = "+isNucleiBefore);

		MC_Intersection = maxOf((minOf(Monolayer_Up, Cell_Up)-maxOf(Monolayer_Low, Cell_Low)), 0);
		MC_IntersectionOverOReach = MC_Intersection/(Cell_Up-Cell_Low);
		Table.set("Slice with "+getChannelName(_CHANNEL_CELL)+" in "+getChannelName(_CHANNEL_MONOLAYER),i, MC_Intersection);
		Table.set("Divided by "+getChannelName(_CHANNEL_CELL)+" height",i, MC_IntersectionOverOReach);

		threshold = 0.5;
		if(MC_IntersectionOverOReach == 1){
			Table.set("Category",i,"Totally Inside");
		}else{
			if(isNucleiBefore){
				if(MC_IntersectionOverOReach>threshold){
					Table.set("Category",i,"Inside but mostly before");
				}else{
					Table.set("Category",i,"Before");
				}
			}else{
				if(MC_IntersectionOverOReach>threshold){
					Table.set("Category",i,"Inside but mostly after");
				}else{
					Table.set("Category",i,"After");
				}
			}
		}
	}
	Table.update;
}


function printDebugImage(title){
	if(_DEBUG){
		imageID = getImageID();
		run("Duplicate...","title="+title+" duplicate");
		selectImage(imageID);
	}
}

function initPlot(channelID){
	Plot.create("Mean intensity over slice - "+getChannelName(channelID),"Slice","Mean Intensity");
}

function addToPlot(color,type,xValues,yValues){
	Plot.setColor(color,color);
	Plot.add(type, xValues, yValues);
	Plot.setLimitsToFit();
}

function getChannel(channelID){
	run("Select None");
	run("Duplicate...", "duplicate channels="+channelID);
	return getImageID();
}

function getChannelName(channelID){
	result = "";
	if(channelID==_CHANNEL_MONOLAYER){	result = "Monolayer";}
	if(channelID==_CHANNEL_HIV){		result = "HIV";}
	if(channelID==_CHANNEL_CELL){		result = "Occludin";}
	if(channelID==_CHANNEL_NUCLEI){		result = "Nuclei";}
	return result;
}

function getChannelColor(channelID){
	result = "";
	if(channelID==_CHANNEL_MONOLAYER){	result = "green";}
	if(channelID==_CHANNEL_HIV){		result = "blue";}
	if(channelID==_CHANNEL_CELL){		result = "orange";}
	if(channelID==_CHANNEL_NUCLEI){		result = "red";}
	return result;
}