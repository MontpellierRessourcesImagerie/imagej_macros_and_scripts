var _VARIANCE_RADIUS = 4;
var _THRESHOLD_METHOD = "Otsu";

var _CONVOLUTION_KERNEL = "4 4 4\n4 8 4\n4 4 4\n";
var _INTERSECTION_PROMINENCE = 5;

//README Start of the Macro Section

macro "Temp Find Touching Worms?"{
    createMaskImage(getImageID());
    run("Options...", "iterations=25 count=1 do=Nothing");
    run("Erode");
    run("Options...", "iterations=1 count=1 do=Nothing"); 
}

macro "Get Worm Segmentation Image Action Tool - C000T4b12W"{
	getWormSegmentationImage();
}

macro "Get Worm Segmentation Image Action Tool Options"{
	wormSegmentationOptionDialog();
}

macro "Get Graph Tables Action Tool - C000T4b12G"{
	getGraphTables();
}

macro "Untangle Worms Action Tool - C000T4b12U"{
	untangleWorms();
}

macro "Unused Tool 0 - " {}  // leave empty slot

var segmentationTools = newArray("Get Worm Segmentation",
								 "Visualise Worm Segmentation",
								 "Worm Segmentation Options",
								 "Get Graph Nodes",
								 "Get Graph Tables",
								 "--",
								 "Get Mask Image",
								 "Get Skeleton From Mask",
								 "Get Intersections of Skeleton",
								 "Export Nodes to Table",
								 "Create ROI of Segments",
								 "Add Nodes neighbors",
								 "Create Segments Table",
								 "--",
								 "Apply Variance Filter and Threshold",
								 "Clean Mask"
								 );
var menuSegmentation = newMenu("Worm Segmentation Menu Tool", segmentationTools);
macro "Worm Segmentation Menu Tool - C000T4b12S"{
	count = 0;
	label = getArgument();
	
	if(label == segmentationTools[count++]) getWormSegmentationImage();
	if(label == segmentationTools[count++]) getWormSegmentationVisualisation();
	if(label == segmentationTools[count++]) wormSegmentationOptionDialog();
	if(label == segmentationTools[count++]) getGraphNodes();
	if(label == segmentationTools[count++]) getGraphTables();
	count++;
	if(label == segmentationTools[count++]) createMaskImage(getImageID());
	if(label == segmentationTools[count++]) getSkeletonFromMask(getImageID());
	if(label == segmentationTools[count++]) getIntersectionsOfSkeleton(getImageID());
	if(label == segmentationTools[count++]) exportNodesFromIntersection(getImageID());
	if(label == segmentationTools[count++]) createSegmentsROI();
	if(label == segmentationTools[count++]) addNeighborsToNodesTable();
	if(label == segmentationTools[count++]) createSegmentsTable();
	count++;
	if(label == segmentationTools[count++]) applyVarianceAndThreshold(_VARIANCE_RADIUS,_THRESHOLD_METHOD);
	if(label == segmentationTools[count++]) cleanMask();
	
}

var untanglingTools = newArray("Untangle Worms",
							   "--",
							   "Populate Worm Untangler",
							   "Enumerate Possible Paths",
							   "Remove Pathless Segments",
							   "Evaluate Path Locally",
							   "Define Best Path Configuration"
							   );
var menuUntangling = newMenu("Worms Untangling Menu Tool",untanglingTools);
macro "Worms Untangling Menu Tool - C000T4b12U"{
	count = 0;
	label = getArgument();
	
	if(label == untanglingTools[count++]) untangleWorms(); //TODO
	count++;
	if(label == untanglingTools[count++]) populateWormUntangler();
	if(label == untanglingTools[count++]) enumeratePossiblePaths();
	if(label == untanglingTools[count++]) prunePathlessSegments();
	if(label == untanglingTools[count++]) evaluatePathLocally(); //TODO
	if(label == untanglingTools[count++]) defineBestPathConfiguration(); //TODO
}
//README Functions concerning the Initial Segmentation

function createMaskImage(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	run("Duplicate...", "title="+title+"-mask2.tif");
	applyVarianceAndThreshold(_VARIANCE_RADIUS,_THRESHOLD_METHOD);
	cleanMask();
}

function applyVarianceAndThreshold(radius,thresholdMethod){
	run("Variance...", "radius="+radius);
	run("Auto Threshold", "method="+thresholdMethod+" white");
}

function cleanMask(){
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	run("Invert");
	run("Erode");
	run("Analyze Particles...", "size=100-Infinity show=Masks");
	run("Invert");
	dirtyWormImageID = getImageID();
	dirtyWormImageTitle = getTitle();
	
	run("Analyze Particles...", "size=0-1000 show=Masks");
	dirtyRestImageID = getImageID();
	dirtyRestImageTitle = getTitle();
	
	imageCalculator("Subtract create", dirtyWormImageTitle,dirtyRestImageTitle);
	run("Invert");
	cleanRestImageID = getImageID();
	cleanRestImageTitle = getTitle();
	selectImage(dirtyWormImageID);
	close();
	selectImage(dirtyRestImageID);
	close();
	
	run("Analyze Particles...", "size=0-1000 show=Masks");
	dirtyInImageID = getImageID();
	dirtyInImageTitle = getTitle();
	
	imageCalculator("Substract create", cleanRestImageTitle,dirtyInImageTitle);
	cleanImageID = getImageID();
	cleanImageTitle = getTitle();
	selectImage(cleanRestImageID);
	close();
	selectImage(dirtyInImageID);
	close();
	
	maskImageID = getImageID();
	selectImage(originalImageID);
	close();
	selectImage(maskImageID);
	rename(originalImageTitle);
}

function getSkeletonFromMask(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	run("Options...", "iterations=1 count=1 do=Nothing");
	run("Duplicate...", "title="+title+"-skeleton.tif");
	run("Skeletonize");
}

function getIntersectionsOfSkeleton(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	
	run("Duplicate...", "title="+title+"-tmp.tif");
	tmpImageID = getImageID();
	//run("Top Hat...", "radius=3");
		
	kernel = _CONVOLUTION_KERNEL;
	prominence = _INTERSECTION_PROMINENCE;
	run("Convolve...", "text1=["+kernel+"] normalize");
	run("Find Maxima...", "prominence="+prominence+" light output=[Single Points]");
	rename(title+"-intersection.tif");
	selectImage(tmpImageID);
	close();
}

function exportNodesFromIntersection(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	
	roiManagerEmpty();
	run("Analyze Particles...", "size=0-100 show=Nothing add");
	roiManager("deselect");
	run("Set Measurements...", "area mean modal min centroid perimeter shape display redirect=None decimal=3");
	roiManager("measure");	
	tableTitle = "nodesTable";
	Table.create(tableTitle);
	for (i = 0; i < nResults(); i++) {
		x = getResult("X", i);
		y = getResult("Y", i);
		Table.set("Node ID", i, "N-"+i);
		Table.set("X", i, x);
		Table.set("Y", i, y);
	}
	Table.update(tableTitle);
	roiManagerEmpty();
}

function createSegmentsROI(){
	run("Select None");
	setBatchMode(false);
	run("ROI Manager...");
	run("Analyze Particles...", "size=5-Infinity show=Nothing clear add");
	setBatchMode(true);
	segmentsCount = roiManager("count");
	for(segmentID = 0 ; segmentID < segmentsCount ; segmentID++){
		roiManager("select",segmentID);
		run("Roi Straightener");
		roiManager("update");
		roiManager("rename", "S-"+segmentID);
	}
}

function addNeighborsToNodesTable(){
	nodesTableTitle = "nodesTable";
	segmentsCount = roiManager("count");
	
	nodesCount =Table.size(nodesTableTitle);
	for(nodeID = 0; nodeID < nodesCount; nodeID++){
		nodeX = Table.get("X", nodeID,nodesTableTitle);
		nodeY = Table.get("Y", nodeID,nodesTableTitle);
		nbContact = 0;
		
		makeRectangle(nodeX-4, nodeY-4, 9, 9);
		roiManager("add")
		nodeRoiID = roiManager("count")-1;
		roiManager("select",nodeRoiID);
		roiManager("rename", "N-"+nodeID);
		for(segmentID = 0 ; segmentID < segmentsCount ; segmentID++){
			roiManager("select",segmentID);
			if(segmentID==nodeRoiID){
				continue;
			}
			roiManager("select", newArray(segmentID,nodeRoiID));
			roiManager("and");
			
			if(getValue("selection.size")!=0){
				//print("Contact between node n-"+nodeID+" and segment s-"+segmentID+" !");
				nbContact++;
				segmentIDString = "S-"+segmentID;
				Table.set("C"+nbContact, nodeID, segmentIDString,nodesTableTitle);
			}
		}
		roiManager("deselect");
		roiManager("select", roiManager("count")-1);
		roiManager("delete");
		run("Select None");
		Table.set("Nb Contact", nodeID, nbContact,nodesTableTitle);
		Table.update(nodesTableTitle);
	}
}

function createSegmentsTable(){
	nodesTableTitle = "nodesTable";
	segmentTableTitle = "segmentsTable";
	segmentsCount = roiManager("count");
	
	nodesCount =Table.size(nodesTableTitle);
	
	Table.create(segmentTableTitle);
	
	for(segmentID = 0; segmentID < segmentsCount; segmentID++){
		Table.set("Segment ID", segmentID, "S-"+segmentID,segmentTableTitle);
		nbContact = 0;
		for(nodeID = 0; nodeID < nodesCount; nodeID++){
			nodeContactCount = Table.get("Nb Contact", nodeID,nodesTableTitle);
			for(i=1;i<=nodeContactCount;i++){
				ithContact = Table.getString("C"+i, nodeID,nodesTableTitle);
				if(ithContact == "S-"+segmentID){
					nbContact++;
					Table.set("C"+nbContact, segmentID, "N-"+nodeID,segmentTableTitle);
				}
				if(nbContact>=2){
					continue;
				}
			}
		}
		Table.set("Nb Contact",segmentID,nbContact,segmentTableTitle);
	}
	Table.update(segmentTableTitle);
}

function getWormSegmentationImage(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	createMaskImage(originalImageID);
	maskImageID = getImageID();
	maskImageTitle = getTitle();
	
	getSkeletonFromMask(maskImageID);
	skeletonID = getImageID();
	skeletonTitle = getTitle();
	
	getIntersectionsOfSkeleton(skeletonID);
	intersectionID = getImageID();
	intersectionTitle = getTitle();
	run("Dilate");
	
	imageCalculator("Subtract create", skeletonID,intersectionID);
	segmentationID = getImageID();
	rename(replace(originalImageTitle,".tif","-segmented.tif"));
	selectImage(maskImageID);
	close();
	selectImage(skeletonID);
	close();
	selectImage(intersectionID);
	close();
	
	setBatchMode("exit and display");
}

function getWormSegmentationVisualisation(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	createMaskImage(originalImageID);
	maskImageID = getImageID();
	maskImageTitle = getTitle();
	
	getSkeletonFromMask(maskImageID);
	skeletonID = getImageID();
	skeletonTitle = getTitle();
	
	getIntersectionsOfSkeleton(skeletonID);
	intersectionID = getImageID();
	intersectionTitle = getTitle();
	run("Dilate");
	
	
	selectImage(originalImageID);
	run("Duplicate...", "title="+originalImageTitle+"-duplicate.tif");
	
	//run("Merge Channels...", "c1="+skeletonTitle+" c2="+maskImageTitle+" c4="+originalImageTitle+"-duplicate.tif create");
	run("Merge Channels...", "c1="+skeletonTitle+" c2="+maskImageTitle+" c6="+intersectionTitle+" c4="+originalImageTitle+"-duplicate.tif create");
	segmentationID = getImageID();
	rename(replace(originalImageTitle,".tif","-segmented-visualisation.tif"));

	setBatchMode("exit and display");
}

function getGraphNodes(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	createMaskImage(originalImageID);
	maskImageID = getImageID();
	maskImageTitle = getTitle();
	
	getSkeletonFromMask(maskImageID);
	skeletonID = getImageID();
	skeletonTitle = getTitle();
	
	getIntersectionsOfSkeleton(skeletonID);
	intersectionID = getImageID();
	intersectionTitle = getTitle();
	exportNodesFromIntersection(getImageID());
	
	selectImage(maskImageID);
	close();
	selectImage(skeletonID);
	close();
	selectImage(intersectionID);
	close();
	
	setBatchMode("exit and display");
}

function getGraphTables(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	createMaskImage(originalImageID);
	maskImageID = getImageID();
	maskImageTitle = getTitle();
	
	getSkeletonFromMask(maskImageID);
	skeletonID = getImageID();
	skeletonTitle = getTitle();
	
	getIntersectionsOfSkeleton(skeletonID);
	intersectionID = getImageID();
	intersectionTitle = getTitle();
	run("Dilate");
	
	imageCalculator("Subtract create", skeletonID,intersectionID);
	segmentationID = getImageID();
	rename(replace(originalImageTitle,".tif","-segmented.tif"));
	setBatchMode("show");
	exportNodesFromIntersection(intersectionID);
	selectImage(segmentationID);
	
	createSegmentsROI();
	addNeighborsToNodesTable();
	createSegmentsTable();
	/*
	selectImage(maskImageID);
	close();
	selectImage(skeletonID);
	close();
	selectImage(intersectionID);
	close();
	*/
	setBatchMode("exit and display");
}

//README Worm Untanglement Functions

function untangleWorms(){
	runUntangler("Untangle");
}

function populateWormUntangler(){
	runUntangler("Populate");
}

function enumeratePossiblePaths(){
	runUntangler("Enumerate");
}

function prunePathlessSegments(){
	runUntangler("Prune");
}

function evaluatePathLocally(){
	runUntangler("Evaluate");
}

function defineBestPathConfiguration(){
	runUntangler("Define?"); //TODO Change this option Code
}


function runUntangler(options){
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/worm_untangling.py");
	call("ij.plugin.Macro_Runner.runPython", script, options); 
}

//README Misc Functions

function roiManagerEmpty(){
	if(roiManager("count") != 0){
		roiManager("deselect");
		roiManager("delete");
	}
}

//README Dialog Functions

function wormSegmentationOptionDialog(){
	Dialog.create("Worm Segmentation Options");
	addDialogGetIntersectionsOfSkeleton();
	addDialogCreateMask();
	Dialog.show();
	getDialogGetIntersectionsOfSkeleton();
	getDialogCreateMask();
}


function addDialogGetIntersectionsOfSkeleton(){
	Dialog.addMessage("Worm Intersections", 14);
	//Dialog.addString("Convolution Kernel",_CONVOLUTION_KERNEL);
	Dialog.addSlider("Find Intersection Prominence", 0, 255, _INTERSECTION_PROMINENCE);
}

function getDialogGetIntersectionsOfSkeleton(){
	//_CONVOLUTION_KERNEL = Dialog.getString();
	_INTERSECTION_PROMINENCE = Dialog.getNumber();
}

function addDialogCreateMask(){
	Dialog.addMessage("Worm Mask", 14);
	Dialog.addSlider("Variance Filter Radius", 0, 20, _VARIANCE_RADIUS);
	methods = getList("threshold.methods");
	Dialog.addRadioButtonGroup("Threshold Method", methods, 5, 5,_THRESHOLD_METHOD);
}

function getDialogCreateMask(){
	_VARIANCE_RADIUS = Dialog.getNumber();
	_THRESHOLD_METHOD = Dialog.getRadioButton();
}
