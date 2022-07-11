var _VARIANCE_RADIUS = 4;
var _THRESHOLD_METHOD = "Otsu";

var _CONVOLUTION_KERNEL = "4 4 4\n4 8 4\n4 4 4\n";
var _INTERSECTION_PROMINENCE = 5;
var _NODE_DETECTION_SIZE = 3;

var _MIN_SEGMENT_SIZE = 2;
var _MAX_WORM_RADIUS = 23;

var _MASKING_METHODS = newArray("Variance","Find Edge","Variance And Find Edge");
var _CURRENT_MASKING_METHOD = _MASKING_METHODS[2];

var _SEPARATE_SKELETONS_ON_OVERLAP = true;

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

macro "Visualize Worm Segmentation Image Action Tool - C000T4b12V"{
    getWormSegmentationVisualisation();
}

macro "Visualize Worm Segmentation Image Action Tool Options"{
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
                                 "Explore Masking Methods",
                                 "Explore Max Radius"
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
    if(label == segmentationTools[count++]) exploreMaskingMethods(getImageID());
    if(label == segmentationTools[count++]) exploreMaxRadius(getImageID());
    
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
    if(label == untanglingTools[count++]) evaluatePathGlobally();
    if(label == untanglingTools[count++]) defineBestPathConfiguration();
    count++;
    if(label == untanglingTools[count++]) runUntanglerTestFunction(); //TODO
}
//README Functions concerning the Initial Segmentation
function exploreMaskingMethods(inputImageID){
    previousMaskingMethod = _CURRENT_MASKING_METHOD;
    
    for (i = 0; i < _MASKING_METHODS.length; i++) {
        _CURRENT_MASKING_METHOD = _MASKING_METHODS[i];
        createMaskImage(inputImageID,true);
        title = getTitle();
        rename(title + _CURRENT_MASKING_METHOD);
    }
    
    _CURRENT_MASKING_METHOD = previousMaskingMethod;
}

function exploreMaxRadius(inputImageID){
    setBatchMode(true);
    previousSeparateSkeletons = _SEPARATE_SKELETONS_ON_OVERLAP;
    previousMaxWormRadius = _MAX_WORM_RADIUS;
    
    _SEPARATE_SKELETONS_ON_OVERLAP = true;
    _MAX_WORM_RADIUS = _MAX_WORM_RADIUS -10;
    for (i = 0; i < 20; i++) {
        _MAX_WORM_RADIUS++;
        getSkeletonImage(inputImageID);
        title = getTitle();
        rename(title + _MAX_WORM_RADIUS);
    }
    
    run("Images to Stack", "  title="+title+" use");
    
    _SEPARATE_SKELETONS_ON_OVERLAP = previousSeparateSkeletons;
    _MAX_WORM_RADIUS = previousMaxWormRadius;
    setBatchMode(false);
}


function createMaskImage(inputImageID,duplicate){
    if(_CURRENT_MASKING_METHOD == _MASKING_METHODS[0]){
        createMaskImageVariance(inputImageID,duplicate);
    }else{
        if(_CURRENT_MASKING_METHOD == _MASKING_METHODS[1]){
            createMaskImageFindEdge(inputImageID,duplicate);
        }else{
            if(_CURRENT_MASKING_METHOD == _MASKING_METHODS[2]){
                createMaskImageIntersection(inputImageID,duplicate);
            }else{
                print("ERROR [createMaskImage()] > Invalid Masking Method : "+ _CURRENT_MASKING_METHOD);
            }
        }
    }
    return getImageID();
}

function createMaskImageIntersection(inputImageID,duplicate){
    varMask = createMaskImageVariance(inputImageID,true);
    edgeMask= createMaskImageFindEdge(inputImageID,duplicate);
    imageCalculator("AND", varMask, edgeMask);
    closeImage(edgeMask);
    return getImageID();
}

function createMaskImageVariance(inputImageID,duplicate){
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

function createMaskImageFindEdge(inputImageID,duplicate){
    selectImage(inputImageID);
    title = getTitle(); 
    title = title.replace(".tif","");
    if(duplicate){
        run("Duplicate...", "title="+title+"-mask.tif");
    }
    run("Find Edges");
    run("Auto Threshold", "method="+_THRESHOLD_METHOD+" white");
    ALT_cleanMask();
    return getImageID();
}

function ALT_cleanMask(){
    DEBUG = false;
    originalImageID = getImageID();
    if(DEBUG){
        rename("Original Image");
    }
    originalImageTitle = getTitle();
    
    run("Invert");
    //run("Erode");
    run("Analyze Particles...", "size=1000-Infinity show=Masks");
    dirtyWormImageID = getImageID();
    if(DEBUG){
        rename("Dirty Worm");
    }else{
        closeImage(originalImageID);
    }
    dirtyWormImageTitle = getTitle();
    
    run("Fill Holes");
    run("Options...", "iterations=4 count=1 do=Nothing");

    run("Erode");
    run("Dilate");
    run("Options...", "iterations=1 count=1 do=Nothing");
    
    rename(originalImageTitle);
}

function applyVarianceAndThreshold(radius,thresholdMethod){
    run("Variance...", "radius="+radius);
    run("Auto Threshold", "method="+thresholdMethod+" white");
}

function cleanMask(){
    originalImageID = getImageID();
    originalImageTitle = getTitle();
    
    run("Invert");
    //run("Erode");
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
    run("Erode");
    run("Erode");
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
    run("Analyze Particles...", "size=0-Infinity show=Nothing add");
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
    minSegmentSize = _MIN_SEGMENT_SIZE;
    run("Select None");
    setBatchMode(false);
    run("ROI Manager...");
    run("Analyze Particles...", "size="+minSegmentSize+"-Infinity show=Nothing clear add");
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
        // Diameter >detectionSize = 1+ _NODE_DETECTION_SIZE * 3 * sqrt(2);
        detectionSize = _NODE_DETECTION_SIZE * 1.5 * sqrt(2);
        makeRectangle(nodeX-detectionSize, nodeY-detectionSize, 1+2*detectionSize, 1+2*detectionSize);
        roiManager("add");
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
    if(_SEPARATE_SKELETONS_ON_OVERLAP){
        getSkeletonImageOverlap(originalImageID);
    }else{
        getSkeletonImageNoOverlap(originalImageID);
    }
    return getImageID();
}

function getSkeletonImageNoOverlap(originalImageID){
    selectImage(originalImageID);
    title = getTitle(); 
    maskImageID = createMaskImage(originalImageID,true);
    skeletonID = getSkeletonFromMask(maskImageID,false);
    rename(title+"-skeleton.tif");
}

function getSkeletonImageOverlap(originalImageID){
    selectImage(originalImageID);
    title = getTitle(); 
    title = title.replace(".tif","");

    baseMaskID = createMaskImage(originalImageID,true);
    //baseMaskID = createMaskImage(originalImageID,true);
    baseSkelID = getSkeletonFromMask(baseMaskID,true);
    
    overMaskID = getOverlapingWormsMask(baseMaskID,false);
    overSkelID = getOverlapingWormsSkeleton(overMaskID,true);
    
    selectImage(overMaskID);
    run("Erode");
    
    imageCalculator("Substract", baseSkelID, overMaskID);
    skelWithoutOverlapID = getImageID();
    
    
    imageCalculator("Add", skelWithoutOverlapID, overSkelID);
    skeletonID = getImageID();
    
    closeImage(overMaskID);
    closeImage(overSkelID);
    
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
    
    //run("Merge Channels...", "c1="+skeletonTitle+" c2="+maskImageTitle+" c6="+intersectionTitle+" c4="+originalImageTitle+"-duplicate.tif create");
    run("Merge Channels...", "c2="+maskImageTitle+" c6="+skeletonTitle+" c1="+intersectionTitle+" c4="+originalImageTitle+"-duplicate.tif create");
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
    run("Options...", "iterations="+_NODE_DETECTION_SIZE+" count=1 do=Dilate");
    
    run("Options...", "iterations=1 count=1 do=Nothing");

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
    erodeStrength = _MAX_WORM_RADIUS;
    selectImage(imageID);
    originalImageTitle = getTitle();
    if(duplicate){
        run("Duplicate...", "title="+originalImageTitle+"-overMask.tif");
    }
    run("Options...", "iterations="+erodeStrength+" count=1 do=Nothing");
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
    runUntangler("DefineWorms");
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
    addDialogCreateMask();
    addDialogSkeleton();
    Dialog.show();
    getDialogCreateMask();
    getDialogSkeleton();
}

function addDialogSkeleton(){
    Dialog.addMessage("Skeleton", 14);
    Dialog.addCheckbox("Separate the skeleton when worms are touching", _SEPARATE_SKELETONS_ON_OVERLAP);
    Dialog.addSlider("If enabled, specify the estimated max worm radius", 0, 40, _MAX_WORM_RADIUS);
    //Dialog.addString("Convolution Kernel",_CONVOLUTION_KERNEL);
    //Dialog.addSlider("Find Intersection Prominence", 0, 255, _INTERSECTION_PROMINENCE);
    Dialog.addSlider("Radius of Detected Nodes",2,15,_NODE_DETECTION_SIZE);
}

function getDialogSkeleton(){
    _SEPARATE_SKELETONS_ON_OVERLAP = Dialog.getCheckbox();
    _MAX_WORM_RADIUS = Dialog.getNumber();
    //_CONVOLUTION_KERNEL = Dialog.getString();
    //_INTERSECTION_PROMINENCE = Dialog.getNumber();
    _NODE_DETECTION_SIZE = Dialog.getNumber();
}

function addDialogCreateMask(){
    Dialog.addMessage("Worm Mask", 14);
    Dialog.addRadioButtonGroup("Masking Method",_MASKING_METHODS, 1, 3,_CURRENT_MASKING_METHOD);
    Dialog.addSlider("Variance Filter Radius", 0, 20, _VARIANCE_RADIUS);
    methods = getList("threshold.methods");
    Dialog.addRadioButtonGroup("Threshold Method", methods, 5, 5,_THRESHOLD_METHOD);
}

function getDialogCreateMask(){
    _CURRENT_MASKING_METHOD = Dialog.getRadioButton();
    _VARIANCE_RADIUS = Dialog.getNumber();
    _THRESHOLD_METHOD = Dialog.getRadioButton();
}
