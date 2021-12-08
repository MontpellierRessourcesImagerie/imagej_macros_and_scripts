/*
   MRI Opera export tools
  
   The tool stitches images from the Opera Phenix HCS System.
   It reads the ``Index.idx.xml`` file to pre-arrange the images and then
   stitches and fuses them using the ``Grid/Collection stitching``-plugin.

   Images are stitched by plane and channel. Z-stacks and multi-channel images can
   optionally be created. Projections can also be created.
    
   (c) 2021, INSERM
   
   written by Volker Baecker and Léo Tellez-Arenas at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
*/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Opera_export_tools";
var _OPERA_INDEX_FILE = "";
var _BYTES_TO_READ = 10000000;
var _WELLS = newArray(0);
var _SELECTED_WELLS = newArray(0);
var _WELLS_NAMES = newArray(0);
var _WELLS_NAMES_FILE = "wellNames.txt"
var _EXPORT_ALL = true;
var _CREATE_Z_STACK = true;
var _MERGE_CHANNELS = true;
var _DO_MIP = false;
var _ZSLICE = 0;
var _CHANNEL = 1;
var _COMPUTE_OVERLAP = true;
var _FUSION_METHODS = newArray("Linear_Blending", "Average", "Median", "Max_Intensity", "Min_Intensity", "random");
var _FUSION_METHOD = "Linear_Blending";
var _REGRESSION_THRESHOLD = 0.30;
var _DISPLACEMENT_THRESHOLD = 2.5;
var _ABS_DISPLACEMENT_THRESHOLD = 3.5;
var _PSEUDO_FLAT_FIELD_RADIUS = 0;
var _ROLLING_BALL_RADIUS = 0;
var _NORMALIZE = false;
var _FIND_AND_SUB_BACK_RADIUS = 0;
var _FIND_AND_SUB_BACK_OFFSET = 3;
var _FIND_AND_SUB_BACK_ITERATIONS = 1;
var _FIND_AND_SUB_BACK_SKIP = 0.3;
var _COLORS = newArray("Red", "Green", "Blue", "Cyan", "Magenta", "Yellow", "Grays");
var _SELECTED_COLORS = newArray("Blue", "Green", "Red", "Cyan", "Magenta", "Yellow", "Grays");

var _CHANNEL_PER_ROW_IN_DIALOG = 2;

var _STITCH_ON_PROJECTION = false;

var _EXPORT_Z_STACK_FIELDS = true;
var _EXPORT_Z_STACK_FIELDS_COMPOSITE = false;
var _EXPORT_PROJECTION_FIELDS = true;
var _EXPORT_PROJECTION_FIELDS_COMPOSITE = false;
var _EXPORT_Z_STACK_MOSAIC = true;
var _EXPORT_Z_STACK_MOSAIC_COMPOSITE = false;
var _EXPORT_PROJECTION_MOSAIC = true;
var _EXPORT_PROJECTION_MOSAIC_COMPOSITE = false;
var _EXPORT_PROJECTION_MOSAIC_RGB = true;

var _NB_CHANNELS = -1;
var _MAX_NB_CHANNELS = 7;
var _EXPORT_RGB_CHANNEL = newArray(_MAX_NB_CHANNELS);
	
launchExport();
exit();

macro "Opera export tools help (f4) Action Tool - CdedD62CdddD72CdedL8292CeeeLa2b2Ca9aD43C555D53C434L6373C555L8393C666Da3C555Lb3c3C666Dd3Ca9aDe3C888D44C666D54C555D64C434L7494C555Da4C434Db4C666Lc4d4C989De4L4555C877D65C434D75C877D85C555D95C877Da5C555Db5CbbbDc5Ca9aLd5e5C989D46C877D56C666D66C434D76C989D86C877L96a6C666Db6C989Dc6C877Dd6Ca9aDe6CdddL1737Ca9aD47C666L5787C888L97a7C989Lb7d7CdddDe7CdedD08C989L1828CdddL3868CdedL78a8CeeeLb8c8CdedDd8CeeeDe8CdddD09C888L1929CdddD39CdedD49CdddD59CdedL6999CeeeLa9d9CdddD0aC989L1a2aCdddD3aCeeeL4a5aLbacaCdedDdaCeeeDeaCdedD0bC666L1b2bCbbbD3bCdddD4bCbbbL5b7bCa9aD8bC989D9bC888LabbbC666LcbdbCbbbDebCdddD1cC888D2cC666L3c5cC989D6cCa9aD7cCbbbL8c9cCdddDacCdedDbcCeeeDcc"{
	run('URL...', 'url='+helpURL);
}

macro "Opera export tools help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "Set index file (f5) Action Tool - C666D12C000L2262CaaaD72C444D13C333D23CcccL3353C888D63C000D73C444L83c3C666Dd3C444L1424CaaaD74C444L84b4C333Dc4C000Dd4C444L1525CcccDc5C000Dd5C444L1626L1727CbbbD37C444L47d7C555De7C444L1828C666D38C111D48C444L58c8C111Dd8C555De8C444L1929C222D39C888D49C111Dd9C888De9C444D1aC222D2aC000D3aCcccD4aCdddDcaC000DdaCdddDeaC444D1bC000L2b3bC888DcbC111DdbC444D1cC000D2cC333D3cCcccL4cbcC444DccC555DdcC666D1dC000L2dcdC888Ddd" {
	setIndexFile();
}

macro "set index-file [f5]" {
	setIndexFile();
}

macro "Select wells (f6) Action Tool - C111D22C000L3242CcccL5262C000L7282CcccL92a2C000Lb2c2C111Dd2C000L2343CcccL5363C000L7383CcccL93a3C000Lb3d3L2444CcccL5464C000L7484CcccL94a4C000Lb4d4CcccL2545L7585Lb5d5L2646L7686Lb6d6C000L2747CcccL5767C000L7787CcccL97a7C000Lb7d7L2848CcccL5868C000L7888CcccL98a8C000Lb8d8CcccL2949L7989Lb9d9L2a4aL7a8aLbadaC000L2b4bCcccL5b6bC000L7b8bCcccL9babC000LbbdbL2c4cCcccL5c6cC000L7c8cCcccL9cacC000LbcdcC111D2dC000L3d4dCcccL5d6dC000L7d8dCcccL9dadC000LbdcdC111Ddd" {
	selectWells();	
}

macro "select wells [f6]" {
	selectWells();
}

macro "Rename Wells Action Tool - C000T6b12T"{
	renameWells();
}

macro "Set options (f7) Action Tool - CaaaD61C555L7181CaaaD91C222L6292C888D33CcccD43C333D53C111D63CeeeL7383C111D93C333Da3CcccDb3C888Dc3C666D24C000L3444C444D54CcccD64D94C444Da4C000Lb4c4C666Dd4CeeeD15C000D25CbbbD35Dc5C000Dd5CeeeDe5CcccD16C111D26C666D36CbbbD66C333D76C222D86CbbbD96C666Dc6C111Dd6CcccDe6C888D27C111D37C222D67C666D77C444D87C333D97C111Dc7C888Dd7D28C111D38C222D68C555D78C444D88C222D98C111Dc8C888Dd8CcccD19C111D29C666D39CbbbD69C222L7989CbbbD99C666Dc9C111Dd9CcccDe9D1aC000D2aCbbbD3aDcaC000DdaCeeeDeaC444D2bC000L3b4bC444D5bCcccD6bD9bC444DabC000LbbcbC666DdbC888D3cCbbbD4cC222D5cC111D6cCeeeL7c8cC111D9cC222DacCbbbDbcC888DccC222L6d9dCaaaD6eC444L7e8eCaaaD9e" {
	setOptions();	
}

macro "set options [f7]" {
	setOptions();
}

macro "Launch export (f8) Action Tool - CbbbD61C444L7181CcccD91CaaaD52C000D62C555L7282C000D92CaaaDa2CcccD43C000D53CaaaD63D93C000Da3CcccDb3C555D44C444D54CdddL7484C444Da4C555Db4C111D45C999D55CdddD65C000L7585CeeeD95C999Da5C111Db5C000D46CcccD56CdddD66C000L7686CeeeD96CcccDa6C000Db6D47CcccD57CeeeL7787CcccDa7C000Db7D48CcccD58Da8C000Db8D49CcccD59Da9C000Db9C666D3aC000D4aCeeeD5aDaaC000DbaC666DcaCdddD2bC000D3bC111D4bC444L5babC111DbbC000DcbCdddDdbD2cC444L3cccCdddDdcCeeeD5dC444D6dCaaaL7d8dC444D9dCeeeDadC777D6eC000L7e8eC777D9eCbbbL7f8f" {
	launchExport();
}

macro "launch export [f8]" {
	launchExport();
}

function launchExport() {
	print("3, 2, 1, go...");
	_OPERA_INDEX_FILE = getIndexFile();
	
	options = "--wells=";
	if (_EXPORT_ALL) options = options + "all";
	else {
		for (i = 0; i < _WELLS.length; i++) {
			if (!_SELECTED_WELLS[i]) continue;
			options = options + _WELLS[i];			
		}
	}
	options = options + " --slice=" + _ZSLICE;
	options = options + " --channel=" + _CHANNEL;
	if (_STITCH_ON_PROJECTION) options = options + " --stitchOnMIP";
	
	if(_EXPORT_Z_STACK_FIELDS) options = options+ " --zStackFields";
	if(_EXPORT_Z_STACK_FIELDS_COMPOSITE) options = options+ " --zStackFieldsComposite";
	if(_EXPORT_PROJECTION_FIELDS) options = options+ " --projectionFields";
	if(_EXPORT_PROJECTION_FIELDS_COMPOSITE) options = options+ " --projectionFieldsComposite";
	
	if(_EXPORT_Z_STACK_MOSAIC) options = options+ " --zStackMosaic";
	if(_EXPORT_Z_STACK_MOSAIC_COMPOSITE) options = options+ " --zStackMosaicComposite";
	if(_EXPORT_PROJECTION_MOSAIC) options = options+ " --projectionMosaic";
	if(_EXPORT_PROJECTION_MOSAIC_COMPOSITE) options = options+ " --projectionMosaicComposite";
	if(_EXPORT_PROJECTION_MOSAIC_RGB) options = options+ " --projectionMosaicRGB";
	
	tmp = "";
	channelSelected = false;
	if(_NB_CHANNELS==-1){
		channelName = getChannelsFromIndex();
		_NB_CHANNELS = channelName.length;
	}
	for(i=0;i<_NB_CHANNELS;i++){
		if(_EXPORT_RGB_CHANNEL[i]){
			tmp = tmp+"1";
			channelSelected = true;
		}else{
			tmp = tmp+"0";
		}
	}
	if(channelSelected)	options = options+ " --channelRGB="+tmp;
	
	if (_NORMALIZE) options = options + " --normalize";
	if (_COMPUTE_OVERLAP) options = options + " --computeOverlap";
	options = options + " --fusion-method=" + _FUSION_METHOD; 
	options = options + " --regression-threshold=" + _REGRESSION_THRESHOLD;
	options = options + " --displacement-threshold=" + _DISPLACEMENT_THRESHOLD;
	options = options + " --abs-displacement-threshold=" + _ABS_DISPLACEMENT_THRESHOLD;
	options = options + " --pseudoflatfield=" + _PSEUDO_FLAT_FIELD_RADIUS;
	options = options + " --rollingball=" + _ROLLING_BALL_RADIUS;
	options = options + " --subtract-background-radius=" + _FIND_AND_SUB_BACK_RADIUS;
	options = options + " --subtract-background-offset=" + _FIND_AND_SUB_BACK_OFFSET;
	options = options + " --subtract-background-iterations=" + _FIND_AND_SUB_BACK_ITERATIONS;
	options = options + " --subtract-background-skip=" + _FIND_AND_SUB_BACK_SKIP;
	colors = String.join(_SELECTED_COLORS);
	colors = replace(colors, " ", "");
	options = options + " --colours=" + colors;
	options = options + " " + _OPERA_INDEX_FILE;
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/opera_export_tools.py");
	setBatchMode(true);
	call("ij.plugin.Macro_Runner.runPython", script, options); 
	setBatchMode(false);
	print("The eagle has landed!!!");
}

function setOptions() {
	channelName = getChannelsFromIndex();
	_NB_CHANNELS = channelName.length;
	Dialog.create("Options");
	items = newArray("Z-Slice","Max Intensity Projection");
	Dialog.addMessage("Base for stitching",14);
	if(_STITCH_ON_PROJECTION){
		Dialog.addRadioButtonGroup("", items, 1, 2, items[1]);
	}else{
		Dialog.addRadioButtonGroup("", items, 1, 2, items[0]);	
	}
	Dialog.addNumber("z-slice for stitching (0 for middle slice)", _ZSLICE);
	Dialog.addNumber("channel for stitching", _CHANNEL);

	Dialog.addMessage("Export Options",14);

	Dialog.addCheckbox("Export Z-Stack of Fields", _EXPORT_Z_STACK_FIELDS);
	Dialog.addToSameRow();
	Dialog.addCheckbox("+ Composite ", _EXPORT_Z_STACK_FIELDS_COMPOSITE);
	
	Dialog.addCheckbox("Export Projections of Fields", _EXPORT_PROJECTION_FIELDS);
	Dialog.addToSameRow();
	Dialog.addCheckbox("+ Composite ", _EXPORT_PROJECTION_FIELDS_COMPOSITE);
	
	Dialog.addCheckbox("Export Z-Stack of Mosaics", _EXPORT_Z_STACK_MOSAIC);
	Dialog.addToSameRow();
	Dialog.addCheckbox("+ Composite ", _EXPORT_Z_STACK_MOSAIC_COMPOSITE);
	
	Dialog.addCheckbox("Export Projection of Mosaics", _EXPORT_PROJECTION_MOSAIC);
	Dialog.addToSameRow();
	Dialog.addCheckbox("+ Composite ", _EXPORT_PROJECTION_MOSAIC_COMPOSITE);

	Dialog.addCheckbox("RGB of Projection of Mosaic", _EXPORT_PROJECTION_MOSAIC_RGB);

	Dialog.addMessage("invert and export individual channel:");
	for(i=0;i<_NB_CHANNELS;i++){
		if(i%_CHANNEL_PER_ROW_IN_DIALOG !=0){
			Dialog.addToSameRow();
		}
		Dialog.addCheckbox(channelName[i],_EXPORT_RGB_CHANNEL[i]);
	}
	
	Dialog.addMessage("Image correction/normalization:",14);
	Dialog.addNumber("pseudo flat field radius (0 = off): ", _PSEUDO_FLAT_FIELD_RADIUS);
	Dialog.addToSameRow();
	Dialog.addNumber("rolling ball radius (0 = off): ", _ROLLING_BALL_RADIUS);
	Dialog.addCheckbox("normalize", _NORMALIZE);
	Dialog.addNumber("find background radius (0 = off): ", _FIND_AND_SUB_BACK_RADIUS);
	Dialog.addToSameRow();
	Dialog.addNumber("find background offset: ", _FIND_AND_SUB_BACK_OFFSET);
	Dialog.addNumber("find background iterations: ", _FIND_AND_SUB_BACK_ITERATIONS);
	Dialog.addToSameRow();
	Dialog.addNumber("find background skip limit: ", _FIND_AND_SUB_BACK_SKIP);
	
	Dialog.addMessage("Fusion parameters:",14);
	Dialog.addCheckbox("Compute Overlap", _COMPUTE_OVERLAP);
	Dialog.addChoice("method: ", _FUSION_METHODS, _FUSION_METHOD);
	Dialog.addToSameRow();
	Dialog.addNumber("regression threshold: ", _REGRESSION_THRESHOLD);
	Dialog.addNumber("max/avg displacement threshold: ", _DISPLACEMENT_THRESHOLD);
	Dialog.addToSameRow();
	Dialog.addNumber("absolute displacement threshold: ", _ABS_DISPLACEMENT_THRESHOLD);
	Dialog.addMessage("Export Colours:",14);

	for(i=0;i<_NB_CHANNELS;i++){
		if(i%_CHANNEL_PER_ROW_IN_DIALOG !=0){
			Dialog.addToSameRow();
		}
		Dialog.addChoice(channelName[i], _COLORS, _SELECTED_COLORS[i]);
	}

	Dialog.addMessage("Export Bounds:",14);

	for(i=0;i<_NB_CHANNELS;i++){
		minMax=getMinMax(i+1);
		Dialog.addNumber(channelName[i]+":  Min",minMax[0]);
		Dialog.addToSameRow();
		Dialog.addNumber("Max",minMax[1]);
	}
	
	
	Dialog.show();

	stitchingBase = Dialog.getRadioButton();
	if(stitchingBase == items[1]){
		_STITCH_ON_PROJECTION = true;
	}else{
		_STITCH_ON_PROJECTION = false;
	}
	
	_ZSLICE = Dialog.getNumber();
	//_STITCH_ON_PROJECTION = Dialog.getCheckbox();
	_CHANNEL = Dialog.getNumber();


	_EXPORT_Z_STACK_FIELDS = Dialog.getCheckbox();
	_EXPORT_Z_STACK_FIELDS_COMPOSITE = Dialog.getCheckbox();
	_EXPORT_PROJECTION_FIELDS = Dialog.getCheckbox();
	_EXPORT_PROJECTION_FIELDS_COMPOSITE = Dialog.getCheckbox();
	_EXPORT_Z_STACK_MOSAIC = Dialog.getCheckbox();
	_EXPORT_Z_STACK_MOSAIC_COMPOSITE = Dialog.getCheckbox();
	_EXPORT_PROJECTION_MOSAIC = Dialog.getCheckbox();
	_EXPORT_PROJECTION_MOSAIC_COMPOSITE = Dialog.getCheckbox();
	_EXPORT_PROJECTION_MOSAIC_RGB = Dialog.getCheckbox();

	for(i=0;i<_NB_CHANNELS;i++){
		_EXPORT_RGB_CHANNEL[i]=Dialog.getCheckbox();
	}
	
	_PSEUDO_FLAT_FIELD_RADIUS = Dialog.getNumber();
	_ROLLING_BALL_RADIUS = Dialog.getNumber();
	_NORMALIZE = Dialog.getCheckbox();
	_FIND_AND_SUB_BACK_RADIUS = Dialog.getNumber();
	_FIND_AND_SUB_BACK_OFFSET = Dialog.getNumber();
	_FIND_AND_SUB_BACK_ITERATIONS = Dialog.getNumber();
	_FIND_AND_SUB_BACK_SKIP = Dialog.getNumber();

	_COMPUTE_OVERLAP = Dialog.getCheckbox();
	_FUSION_METHOD = Dialog.getChoice();
	_REGRESSION_THRESHOLD = Dialog.getNumber();
	_DISPLACEMENT_THRESHOLD = Dialog.getNumber();
	_ABS_DISPLACEMENT_THRESHOLD = Dialog.getNumber();

	for(i=0;i<_NB_CHANNELS;i++){
		_SELECTED_COLORS[i]=Dialog.getChoice();
	}
	for(i=1;i<=_NB_CHANNELS;i++){
		min=Dialog.getNumber();
		max=Dialog.getNumber();
		saveMinMax(i,min,max);
	}
	
}

macro "channelBounds"{
	setChannelBounds();
	channelName = getChannelsFromIndex();
	_NB_CHANNELS = channelName.length;
	for(i=1;i<=_NB_CHANNELS;i++){
		minMax=getMinMax(i);
		print("min="+minMax[0]);
		print("max="+minMax[1]);
	}
}

function setChannelBounds(){
	channelName = getChannelsFromIndex();
	_NB_CHANNELS = channelName.length;
	Dialog.create("Channel Bounds");
	for(i=1;i<=_NB_CHANNELS;i++){
		minMax=getMinMax(i);
		Dialog.addNumber("Min",minMax[0]);
		Dialog.addToSameRow();
		Dialog.addNumber("Max",minMax[1]);
	}

	Dialog.show();
	for(i=1;i<=_NB_CHANNELS;i++){
		min=Dialog.getNumber();
		max=Dialog.getNumber();
		saveMinMax(i,min,max);
	}
}

function saveMinMax(channel,min,max){
	setParameterDefault("channel"+channel+"Min",min);	
	setParameterDefault("channel"+channel+"Max",max);	
}

function getMinMax(channel){
	min = getParameterDefault("channel"+channel+"Min",0);
	max = getParameterDefault("channel"+channel+"Max",65534);
	return newArray(min,max);
}

function renameWells() {
	_OPERA_INDEX_FILE = getIndexFile();
	_WELLS = getWells();
	wells = _WELLS;

	wellsNameUndefined = false;
	if (_WELLS_NAMES.length != _WELLS.length){
		wellsNameUndefined =true;
		_WELLS_NAMES = newArray(_WELLS.length);
	}
	
	baseDir =File.getDirectory(_OPERA_INDEX_FILE);
	
	if(File.exists(baseDir + _WELLS_NAMES_FILE)){
		str = File.openAsString(baseDir + _WELLS_NAMES_FILE);
		lines=split(str,"\n");
		for(i=0;i<_WELLS.length;i++){
			line = split(lines[i],":");
			_WELLS_NAMES[i]=line[1];
		}
		wellsNameUndefined = false;
	}
	
	Dialog.create("Rename Wells");
	lastRow = "00";
	for(i=0;i<_WELLS.length;i++){
		well = wells[i];
		if(wellsNameUndefined){
			_WELLS_NAMES[i]="r"+substring(well, 0, 2)+"c"+substring(well, 2, 4);
		}
		
		row = substring(well, 0, 2);  
		if (row==lastRow) {
			Dialog.addToSameRow();
		}
		lastRow = row;
		Dialog.addString(well, _WELLS_NAMES[i],8);
	}

	Dialog.show();

	path = baseDir + _WELLS_NAMES_FILE;
	File.delete(baseDir + _WELLS_NAMES_FILE);
	for(i=0;i<_WELLS.length;i++){
		well = wells[i];
		_WELLS_NAMES[i] = Dialog.getString();
		File.append(""+well+":"+_WELLS_NAMES[i]+"", path);
	}
}

function selectWells() {
	_OPERA_INDEX_FILE = getIndexFile();
	_WELLS = getWells();
	wells = _WELLS;
	if (_SELECTED_WELLS.length != _WELLS.length) _SELECTED_WELLS = newArray(_WELLS.length);
	
	Dialog.create("Select Wells");
	lastRow = "00";
	for (i = 0; i < wells.length; i++) {
		well = wells[i];
		row = substring(well, 0, 2);  
		if (row==lastRow) {
			Dialog.addToSameRow();
		}
		lastRow = row;
		Dialog.addCheckbox(well, _SELECTED_WELLS[i]);
	}
	Dialog.addCheckbox("export all", _EXPORT_ALL);
	
	Dialog.show();
	
	for (i = 0; i < wells.length; i++) {
		_SELECTED_WELLS[i] = Dialog.getCheckbox();
	}
	_EXPORT_ALL = Dialog.getCheckbox();

	
}

function setIndexFile() {
	newFile  = File.openDialog("Please select the index file (Index.idx.xml)!");
	newFile = replace(newFile, "\\", "/");
	if (File.exists(newFile)) {
		setParameterDefault("indexFile",newFile);
	}
}

function getIndexFile() {
	res = _OPERA_INDEX_FILE;
	if (!File.exists(res)) res = getParameterDefault("indexFile","");
	return res;
}

function getParameterDefault(parameter,default) {
	return call("ij.Prefs.get", "operaExportTools."+parameter, default);
}

function setParameterDefault(parameter,value) {
	call("ij.Prefs.set", "operaExportTools."+parameter, value); 
}

function getWells() {
	content = File.openAsRawString(_OPERA_INDEX_FILE, _BYTES_TO_READ);
	lines = split(content, "\n");
	wells = newArray(0);
	started = false;
	finished = false;
	for (i = 0; i < lines.length && !finished; i++) {
		line = String.trim(lines[i]);
		if (startsWith(line, "<Well id=")) {
			started = true;
			line = replace(line, '<Well id="', "");
			line = replace(line, '" />', "");
			wells = Array.concat(wells, line);
		} else {
			if (started) finished = true;
		}
	}
	return wells;
}

function getNrOfRowsAndColumns() {
	indexFile = getIndexFile();
	content = File.openAsRawString(indexFile, _BYTES_TO_READ);
	lines = split(content, "\n");
	found=false;
	nrCols = 0;
	nrRows = 0;
	for (i = 0; i < lines.length && !found; i++) {
		line = String.trim(lines[i]);
		if (startsWith(line, "<PlateRows>")) {
			line = replace(line, "<PlateRows>", "");
			line = replace(line, "</PlateRows>", "");
			nrRows = parseInt(line);
			line = String.trim(lines[i+1]);
			line = replace(line, "<PlateColumns>", "");
			line = replace(line, "</PlateColumns>", "");
			nrCols = parseInt(line);
			found = true;
		}
	}
	res = newArray(nrRows, nrCols);
	return res;
}
macro "getChannelsNames"{
	getChannelsFromIndex();
}

function getChannelsFromIndex(){
	indexFile = getIndexFile();
	content = File.openAsRawString(indexFile, _BYTES_TO_READ);
	lines = split(content, "\n");
	channels = newArray();
	
	startMarker = "ChannelName: ";
	endMarker = ",";
	for (i = 0; i < lines.length; i++) {
		line = String.trim(lines[i]);
		if (startsWith(line, "<FlatfieldProfile>")) {
			startIndex = indexOf(line,startMarker)+startMarker.length;
			channelName = substring(line, startIndex);
			endIndex = indexOf(channelName,endMarker);
			channelName = substring(channelName, 0, endIndex);
			channels = Array.concat(channels,channelName);
		}
	}
	return channels;
}

macro "getFlatfieldCoefficients"{
	getFlatfieldCoefficients(1);
}

function getDataFromIndex(lineStart,startMarker,endMarker){
	indexFile = getIndexFile();
	content = File.openAsRawString(indexFile, _BYTES_TO_READ);
	lines = split(content, "\n");
	outData = newArray();
	
	for (i = 0; i < lines.length; i++) {
		line = String.trim(lines[i]);
		if (startsWith(line, lineStart)) {
			startIndex = indexOf(line,startMarker)+startMarker.length;
			subString = substring(line, startIndex);
			subString = substring(subString, 0, indexOf(subString,endMarker));
			outData = Array.concat(outData,subString);
		}
	}
	return outData;
}

function getFlatfieldCoefficients(channelNumber){
	indexFile = getIndexFile();
	content = File.openAsRawString(indexFile, _BYTES_TO_READ);
	lines = split(content, "\n");
	found=false;
	nrCols = 0;
	nrRows = 0;
	channels = newArray();
	
	//print("Reading indexFile");
	startMarker = "Coefficients: ";
	endMarker = ", Dims: ";
	count = 0;
	for (i = 0; i < lines.length; i++) {
		line = String.trim(lines[i]);
		if (startsWith(line, "<FlatfieldProfile>")) {
			count = count+1;
			if(count==channelNumber){
				startIndex = indexOf(line,startMarker)+startMarker.length;
				endIndex = indexOf(line,endMarker);
				coeffLine = substring(line, startIndex, endIndex);
				coeffDirty = split(coeffLine,",");
				coeffClean = newArray(coeffDirty.length);
				for(tmp=0;tmp<coeffDirty.length;tmp++){
					coeffClean[tmp] = String.trim( replace(replace(coeffDirty[tmp], "[", ""),"]","") );
				}
				Array.print(coeffClean);
				
			}
		}
	}
	return coeffClean;
}

macro "correctFlatfield"{
	setBatchMode(true);
	correctFlatfield();
	setBatchMode(false);
}

function correctFlatfield(){
	_OPERA_INDEX_FILE = getIndexFile();
	channels = getChannelsFromIndex();
	nbChannels = channels.length;
	directory = File.getDirectory(_OPERA_INDEX_FILE);
	outDirectory = directory + "/noBG/";
	print(outDirectory);
	filelist = getFileList(directory);
	imageSize = newArray(2);
	for (i = 0; i < lengthOf(filelist); i++) {
		if (endsWith(filelist[i], ".tiff")){
			open(directory+filelist[i]);
			imageSize[0]=getWidth();
			imageSize[1]=getHeight();
			close();
		}
	}

	channelMeans = getDataFromIndex("<FlatfieldProfile>",", Mean: ",", ");
	for(chan=1;chan<=nbChannels;chan++){
		coeffs = getFlatfieldCoefficients(chan);
		originalBackgroundID = createBackgroundImage(coeffs,imageSize);
		currentMean = channelMeans[chan-1];
	    close();
		for (i = 0; i < lengthOf(filelist); i++) {
			showProgress(i, lengthOf(filelist));
			
			if (endsWith(filelist[i], ".tiff")&& (indexOf(filelist[i], "ch"+chan)> -1)) { 
			
				open(directory + File.separator + filelist[i]);
				imageID = getImageID();
				getStatistics(areaI, meanI, minI, maxI, stdDevI);
				
				bgPixels = Table.getColumn("pixelIntensity");
				Array.getStatistics(bgPixels, minB, maxB, meanB, stdDevB);
				
				newImage("background_rescaled", "16-bit",imageSize[0], imageSize[1], 1);
 				backgroundID = getImageID();
 				
 				tableItt=0;
				for (y=0; y<imageSize[1]; y++) {
					for (x=0; x<imageSize[0]; x++){
						pixel = Table.get("pixelIntensity",tableItt);
						a = 0;
						b= currentMean; 
						
						//a = meanI - meanB;
						//b= stdDevI / stdDevB; 
						pixelOut = a + (pixel * b);
						setPixel(x, y, pixelOut);
						tableItt=tableItt+1;
					}
				}
				imageCalculator("substract create", imageID, backgroundID);
				saveAs(outDirectory+filelist[i]);
				close();
				close();	
			}
	    }
	}
}

function createBackgroundImage(coeffs,size){
	newImage("background", "32-bit", size[0], size[1], 1);
	imageID = getImageID();
 	w = getWidth(); 
 	h = getHeight();
 	Table.create("Background values");
 	i=0;
	for (y=0; y<h; y++) {
		for (x=0; x<w; x++){
			pixelOut = getValueOfPixelAfterPolynom(coeffs,x,y,size[0], size[1]);
			setPixel(x, y, pixelOut);
			Table.set("pixelIntensity",i,pixelOut);
			i=i+1;
		}
	}
 	//run("Enhance Contrast...", "saturated=0 normalize");
	return imageID;
}

function getValueOfPixelAfterPolynom(coeffs,x,y,scaleX,scaleY){
	polX = (x/(0.5*scaleX))-1;
	polY = (y/(0.5*scaleY))-1;
	pixelValue = getValueOfPolynom(coeffs,x,y);
	//print(pixelValue);
	return pixelValue;
}

function getValueOfPolynom(coeffs,x,y){
	outPixelValue0= 0 + coeffs[0]; 
	outPixelValue1= 0 + coeffs[1]	* polX 				 	+ coeffs[2] * polY;
	outPixelValue2= 0 + coeffs[3]	* polX*polX 			+ coeffs[4] * polX*polY 			+ coeffs[5] * polY*polY;
	outPixelValue3= 0 + coeffs[6]	* polX*polX*polX 		+ coeffs[7] * polX*polX*polY 		+ coeffs[8] * polX*polY*polY 		+ coeffs[9] * polY*polY*polY;
	outPixelValue4= 0 + coeffs[10]	* polX*polX*polX*polX 	+ coeffs[11]* polX*polX*polX*polY	+ coeffs[12]* polX*polX*polY*polY 	+ coeffs[13]* polX*polY*polY*polY + coeffs[14] * polY*polY*polY*polY;
	outPixelValue = outPixelValue0+outPixelValue1+outPixelValue2+outPixelValue3+outPixelValue4;
	return outPixelValue;
}