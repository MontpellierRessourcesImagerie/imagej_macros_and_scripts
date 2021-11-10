var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/cell-transmigration-analysis";

function showHelp() {
     run('URL...', 'url='+helpURL);
}

macro "help [f1]" {
    showHelp();
}

macro "Help (f1) Action Tool - C000T4b12?" {
    showHelp();
}
macro "Enhance Image Contrast Action Tool - C000 T4b12E"{
	enhanceContrastImage();
}

macro "Get Monolayer Position Action Tool - C000 T4b12L"{
	getPosition(_CHANNEL_MONOLAYER,false,-1,-1);
}

macro "Get Nuclei Position Action Tool - C000 T4b12N"{
	getPosition(_CHANNEL_NUCLEI,true,-1,-1);
}

macro "Empty Tool Action Tool -"{}

var _WIP_STRING = "This field is temporary";
var _DO_MONOLAYER	= true;
var _DO_NUCLEI		= true;
var _DO_CELL		= true;
var _DO_HIV			= true;

macro "Batch Get Positions Action Tool - C000 T4b12B"{
	baseDir = getDir("Select folder containing the images");
	batchGetPositions(baseDir,_DO_MONOLAYER,_DO_NUCLEI,_DO_CELL,_DO_HIV);
}

macro "Batch Get Positions Action Tool Options"{
	Dialog.create(_WIP_STRING);
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

macro "Empty tool Action Tool -"{}

macro "_TMP_ Tool A Action Tool - C009 T4b12A"{
	_TMP_ActionA();
}

macro "_TMP_ Tool B Action Tool - C009 T4b12B"{
	_TMP_ActionB();
}

var _CHANNEL_MONOLAYER	= 1;
var _CHANNEL_HIV		= 2;
var _CHANNEL_OCCLUDIN	= 3;
var _CHANNEL_NUCLEI		= 4;

var _DO_PLOT = true;

var _DO_TABLE = false;
var _TABLE_INDEX = 0;
var _TABLE_NAME = "ResultsTable";

var _DEBUG = false;

function _TMP_ActionA(){
	print("Starting execution of _TMP_ActionA");
	concludeFromTable();
	print("Finishing execution of _TMP_ActionA");
}

function _TMP_ActionB(){
	print("Starting execution of _TMP_ActionB");
	_DO_PLOT = true;
	_DO_TABLE = false;
	setBatchMode(true);
	getPosition(_CHANNEL_MONOLAYER,false,-1,-1);
	cellBounds = getPosition(_CHANNEL_OCCLUDIN,true,-1,-1);
	getPosition(_CHANNEL_NUCLEI,true,cellBounds[0],cellBounds[1]);
	//getPosition(_CHANNEL_HIV,true,cellBounds[0],cellBounds[1]);
	print("Finishing execution of _TMP_ActionB");
}

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

	/*
	val1 = (meanOfMeans+min) / 2;
	val2 = (max+min) / 2;
	val3 = (max + 3 * min) / 4;
	*/
	
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
	//if(_DO_PLOT){	addToPlot("red","line", newArray(lowerSlice-2,upperSlice+2), newArray(val1,val1));}
	//if(_DO_PLOT){	addToPlot("green","line", newArray(lowerSlice-2,upperSlice+2), newArray(val2,val2));}
	//if(_DO_PLOT){	addToPlot("blue","line", newArray(lowerSlice-2,upperSlice+2), newArray(val3,val3));}
	
	if(_DO_PLOT){	Plot.show();}
	//if(_DO_PLOT){	setBatchMode(true);}
	if(_DO_PLOT){	if(batchMode){	setBatchMode(true);}}

	if(_DO_TABLE){	Table.set(channelName+"_Low", _TABLE_INDEX, lowerSlice,_TABLE_NAME);}
	if(_DO_TABLE){	Table.set(channelName+"_Up", _TABLE_INDEX, upperSlice,_TABLE_NAME);}
	//setBatchMode(true);
	
	_VERBOSE = true;
	if(_VERBOSE){	print(channelName+" is between slices ["+lowerSlice+":"+upperSlice+"]");}
	
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
			if(doCell){			cellBounds=getPosition(_CHANNEL_OCCLUDIN,true,-1,-1);
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
	imageID = getChannel(_CHANNEL_OCCLUDIN);
		
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

function getChannel(channelNumber){
	run("Select None");
	run("Duplicate...", "duplicate channels="+channelNumber);
	return getImageID();
}

function concludeFromTable(){
	nbRows = Table.size;
	for (i = 0; i < nbRows; i++) {
		M_Up	= Table.get("Monolayer_Up", i);
	    M_Low	= Table.get("Monolayer_Low", i);
		N_Up	= Table.get("Nuclei_Up", i);
	    N_Low	= Table.get("Nuclei_Low", i);
		O_Up	= Table.get("Occludin_Up", i);
	    O_Low	= Table.get("Occludin_Low", i);
		
		M_Mid	= M_Up-M_Low;
		N_Mid	= N_Up-N_Low;

		isNucleiBefore = false;
		if(N_Mid<M_Mid){Table.set("Nuclei before Monolayer", i, true );	isNucleiBefore = true;}
		else{			Table.set("Nuclei before Monolayer", i, false);	isNucleiBefore = false;}

		MO_Intersection = maxOf((minOf(M_Up, O_Up)-maxOf(M_Low, O_Low)), 0);
		MO_IntersectionOverOReach = MO_Intersection/(O_Up-O_Low);
		Table.set("Slice with Occludin in Monolayer",i, MO_Intersection);
		Table.set("Divided by Occludin reach",i, MO_IntersectionOverOReach);

		threshold = 0.5;
		if(MO_IntersectionOverOReach == 1){
			Table.set("Category",i,"Totally Inside");
		}else{
			if(isNucleiBefore){
				if(MO_IntersectionOverOReach>threshold){
					Table.set("Category",i,"Inside but mostly before");
				}else{
					Table.set("Category",i,"Before");
				}
			}else{
				if(MO_IntersectionOverOReach>threshold){
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
	Plot.create("Mean intensity over slice -"+getChannelName(channelID),"Slice","Mean");
}

function addToPlot(color,type,xValues,yValues){
	Plot.setColor(color,color);
	Plot.add(type, xValues, yValues);
	Plot.setLimitsToFit();
}

function getChannelName(channelID){
	result = "";
	if(channelID==_CHANNEL_MONOLAYER){	result = "Monolayer";}
	if(channelID==_CHANNEL_HIV){		result = "HIV";}
	if(channelID==_CHANNEL_OCCLUDIN){	result = "Occludin";}
	if(channelID==_CHANNEL_NUCLEI){		result = "Nuclei";}
	return result;
}

function getChannelColor(channelID){
	result = "";
	if(channelID==_CHANNEL_MONOLAYER){	result = "green";}
	if(channelID==_CHANNEL_HIV){		result = "blue";}
	if(channelID==_CHANNEL_OCCLUDIN){	result = "orange";}
	if(channelID==_CHANNEL_NUCLEI){		result = "red";}
	return result;
}