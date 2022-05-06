var _VARIANCE_RADIUS = 4;
var _THRESHOLD_METHOD = "Otsu";

var _CONVOLUTION_KERNEL = "4 4 4\n4 8 4\n4 4 4\n";
var _INTERSECTION_PROMINENCE = 5;

//README Start of the Macro Section

macro "Get Overlaping Worms Masks"{
    createMaskImage(getImageID(),true);
    getOverlapingWormsMask(getImageID(),false);
}

macro "Get Overlaping Worms Skeleton"{
    createMaskImage(getImageID(),true);
    overMaskID = getOverlapingWormsMask(getImageID(),false);
    getOverlapingWormsSkeleton(overMaskID,false);
}

macro "Get Tables With Overlap Treated"{
    getTablesWithOverlapTreated();
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
                                 "Get Skeleton Image",
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
	if(label == segmentationTools[count++]) createMaskImage(getImageID(),true);
    if(label == segmentationTools[count++]) getSkeletonFromMask(getImageID(),true);
    if(label == segmentationTools[count++]) getSkeletonImage(getImageID());
	if(label == segmentationTools[count++]) getIntersectionsOfSkeleton(getImageID(),true);
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
							   "Evaluate Path Globally",
							   "Define Best Path Configuration",
                               "--",
                               "Run Untangler Tes Function"
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
	if(label == untanglingTools[count++]) evaluatePathLocally();
	if(label == untanglingTools[count++]) evaluatePathGlobally(); //TODO
	if(label == untanglingTools[count++]) defineBestPathConfiguration(); //TODO
    count++;
    if(label == untanglingTools[count++]) runUntanglerTestFunction(); //TODO
}
//README Functions concerning the Initial Segmentation

function createMaskImage(inputImageID,duplicate){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
    if(duplicate){
	    run("Duplicate...", "title="+title+"-mask.tif");
    }
	applyVarianceAndThreshold(_VARIANCE_RADIUS,_THRESHOLD_METHOD);
	cleanMask();
    return getImageID();
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
    
    closeImage(dirtyWormImageID);
	closeImage(dirtyRestImageID);
	
	run("Analyze Particles...", "size=0-1000 show=Masks");
	dirtyInImageID = getImageID();
	dirtyInImageTitle = getTitle();
	
	imageCalculator("Substract create", cleanRestImageTitle,dirtyInImageTitle);
	cleanImageID = getImageID();
	cleanImageTitle = getTitle();
   
	closeImage(cleanRestImageID);
	closeImage(dirtyInImageID);
	closeImage(originalImageID);
    
	selectImage(cleanImageID);
	rename(originalImageTitle);
}

function getSkeletonFromMask(inputImageID,duplicate){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	if(duplicate){
	    run("Duplicate...", "title="+title+"-skeleton.tif");
	}
   run("Options...", "iterations=1 count=1 do=Nothing");
	run("Skeletonize");
    return getImageID();
}

function getIntersectionsOfSkeleton(inputImageID,duplicate){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	if(duplicate){
	    run("Duplicate...", "title="+title+"-tmp.tif");
	}
	tmpImageID = getImageID();
	//run("Top Hat...", "radius=3");
    
	kernel = _CONVOLUTION_KERNEL;
	prominence = _INTERSECTION_PROMINENCE;
	run("Convolve...", "text1=["+kernel+"] normalize");
	run("Find Maxima...", "prominence="+prominence+" light output=[Single Points]");
	rename(title+"-intersection.tif");
  
	closeImage(tmpImageID);
    return getImageID();
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
	run("Analyze Particles...", "size=2-Infinity show=Nothing clear add");
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
		print("Treating Node N-"+nodeID);
        detectionSize = 3;
		makeRectangle(nodeX-detectionSize, nodeY-detectionSize, 1+2*detectionSize, 1+2*detectionSize);
		roiManager("add")
		nodeRoiID = roiManager("count")-1;
		roiManager("select",nodeRoiID);
		roiManager("rename", "N-"+nodeID);
		for(segmentID = 0 ; segmentID < segmentsCount ; segmentID++){
        //print("Test between node n-"+nodeID+" and segment s-"+segmentID+" !");
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
                Table.update();
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
	
	skeletonID = getSkeletonImage(originalImageID);
    intersectionID = extractIntersectionsFromSkeleton(skeletonID);
	closeImage(intersectionID);
	
	setBatchMode(false);
}

function getSkeletonImage(originalImageID){
    getSkeletonImageOverlap(originalImageID);
    //getSkeletonImageNoOverlap(originalImageID);
    return getImageID();
}

function getSkeletonImageNoOverlap(originalImageID){
    maskImageID = createMaskImage(originalImageID,true);
    skeletonID = getSkeletonFromMask(maskImageID,false);
}

function getSkeletonImageOverlap(originalImageID){
    selectImage(originalImageID);
    title = getTitle(); 
    title = title.replace(".tif","");
    baseMaskID = createMaskImage(originalImageID,true);
    baseSkelID = getSkeletonFromMask(baseMaskID,true);
    
    overMaskID = getOverlapingWormsMask(baseMaskID,false);
    overSkelID = getOverlapingWormsSkeleton(overMaskID,true);
    
    selectImage(overMaskID);
    run("Erode");
    
    imageCalculator("Substract create", baseSkelID, overMaskID);
    skelWithoutOverlapID = getImageID();
    
    
    imageCalculator("Add create", skelWithoutOverlapID, overSkelID);
    skeletonID = getImageID();
    
    closeImage(skelWithoutOverlapID);
    closeImage(overSkelID);
    closeImage(overMaskID);
    rename(title+"-skeleton.tif");
}

function getWormSegmentationVisualisation(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	maskImageID = createMaskImage(originalImageID,true);
    maskImageTitle = getTitle();
    
    skeletonID = getSkeletonImage(originalImageID);
    skeletonTitle = getTitle();
    
    intersectionID = extractIntersectionsFromSkeleton(skeletonID);
    selectImage(intersectionID);
    intersectionTitle = getTitle();
	
	selectImage(originalImageID);
	run("Duplicate...", "title="+originalImageTitle+"-duplicate.tif");
	
	run("Merge Channels...", "c1="+skeletonTitle+" c2="+maskImageTitle+" c6="+intersectionTitle+" c4="+originalImageTitle+"-duplicate.tif create");
	segmentationID = getImageID();
	rename(replace(originalImageTitle,".tif","-segmented-visualisation.tif"));

	setBatchMode(false);
}

function getGraphNodes(){
	setBatchMode(true);
	originalImageID = getImageID();
	
	skeletonID = getSkeletonImage(originalImageID);
    intersectionID = extractIntersectionsFromSkeleton(skeletonID);
	exportNodesFromIntersection(intersectionID);
	
	closeImage(intersectionID);
	
	setBatchMode("exit and display");
}

function getGraphTables(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
    skeletonID = getSkeletonImage(originalImageID);
    intersectionID = extractIntersectionsFromSkeleton(skeletonID);
	exportNodesFromIntersection(intersectionID);
    getGraphTablesFromSegments(skeletonID);
    
	setBatchMode("exit and display");
}
/*
function getGraphTablesOverlap(){
    setBatchMode(true);
    originalImageID = getImageID();
    originalImageTitle = getTitle();
    
    baseMaskID = createMaskImage(originalImageID,true);
    baseSkelID = getSkeletonFromMask(baseMaskID,true);
    overMaskID = getOverlapingWormsMask(baseMaskID,false);
    
    imageCalculator("Substract create", baseSkelID, overMaskID);
    skelWithoutOverlapID = getImageID();
    
    overSkelID = getOverlapingWormsSkeleton(overMaskID,false);
    
    imageCalculator("Add create", skelWithoutOverlapID, overSkelID);
    skeletonID = getImageID();
    
    closeImage(skelWithoutOverlapID);
    closeImage(overSkelID);
    
    intersectionID = extractIntersectionsFromSkeleton(skeletonID);
    
    exportNodesFromIntersection(intersectionID);
    getGraphTablesFromSegments(skeletonID);
    
    setBatchMode("exit and display");
}
*/

function extractIntersectionsFromSkeleton(skeletonID){
    intersectionID = getIntersectionsOfSkeleton(skeletonID,true);
    intersectionTitle = getTitle();
    rename(replace(intersectionTitle,".tif","-nodes.tif"));
    run("Dilate");
    
    imageCalculator("Subtract", skeletonID,intersectionID);
    
    return intersectionID;
}

function getGraphTablesFromSegments(segmentsID){
    selectImage(segmentsID);
    createSegmentsROI();
    addNeighborsToNodesTable();
    createSegmentsTable();
}

function closeImage(ID){
    selectImage(ID);
    close();
}

function getOverlapingWormsMask(imageID,duplicate){
    selectImage(imageID);
    originalImageTitle = getTitle();
    if(duplicate){
        run("Duplicate...", "title="+originalImageTitle+"-overMask.tif");
    }
    run("Options...", "iterations=24 count=1 do=Nothing");
    run("Erode");
    run("Options...", "iterations=3 count=1 do=Nothing");
    run("Open");
    run("Options...", "iterations=1 count=1 do=Nothing");
    return getImageID();
}

function getOverlapingWormsSkeleton(imageID,duplicate){
    selectImage(imageID);
    originalImageTitle = getTitle();
    if(duplicate){
        run("Duplicate...", "title="+originalImageTitle+"-overSkel.tif");
    }
    run("Outline");
    run("Skeletonize");
    return getImageID();
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

function evaluatePathGlobally(){
	runUntangler("GlobalEvaluate");
}

function defineBestPathConfiguration(){
	runUntangler("Define?"); //TODO Change this option Code
}

function runUntanglerTestFunction(){
    runUntangler("Test");
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
