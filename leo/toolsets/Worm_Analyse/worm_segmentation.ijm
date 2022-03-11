var _BLUR_SIGMA = 4;
var _MAXIMA_PROMINENCE = 35;
var _VARIANCE_RADIUS = 4;
var _THRESHOLD_METHOD = "Otsu";

//README Start of the Macro Section

macro "Get Worm Segmentation Image Action Tool - C000T4b12W"{
	getWormSegmentationImage();
}

macro "Get Worm Segmentation Image Action Tool Options"{
	wormSegmentationOptionDialog();
}

macro "Find Worms ROI from Segmentation Action Tool - C000T4b12F"{
	makeWormsROI();
}

macro "Unused Tool 0 - " {}  // leave empty slot

var segmentationTools = newArray("Get Worm Segmentation",
								 "Visualise Worm Segmentation",
								 "Get Old Worm Segementation",
								 "Visualise Old Worm Segmentation",
								 "Worm Segmentation Options",
								 "--",
								 "Get Mask Image",
								 "Get Skeleton From Mask",
								 "Get Intersections of Skeleton",
								 "--",
								 "Apply Variance Filter and Threshold",
								 "Clean Mask"
								 );
var menuSpots = newMenu("Worm Segmentation Menu Tool", segmentationTools);
macro "Worm Segmentation Menu Tool - C000T4b12W"{
	count = 0;
	label = getArgument();
	
	if(label == segmentationTools[count++])	getWormSegmentationImage();
	if(label == segmentationTools[count++])	getWormSegmentationVisualisation();
	
	if(label == segmentationTools[count++])	getOldWormSegmentationImage();
	if(label == segmentationTools[count++])	getOldWormSegmentationVisualisation();
	
	if(label == segmentationTools[count++]) wormSegmentationOptionDialog();
	count++;
	if(label == segmentationTools[count++])	createMaskImage(getImageID());
	if(label == segmentationTools[count++])	getSkeletonFromMask(getImageID());
	if(label == segmentationTools[count++])	getIntersectionsOfSkeleton(getImageID());
	
	count++;
	if(label == segmentationTools[count++])	applyVarianceAndThreshold(_VARIANCE_RADIUS,_THRESHOLD_METHOD);
	if(label == segmentationTools[count++])	cleanMask();	
	
}

//README Start of the Function Section

function getSeparationLine(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","-separation.tif");
	
	run("Duplicate...", "title="+title+"-tmp.tif");
	tmpImage = getImageID();
	blurSigma = 4;
	run("Gaussian Blur...", "sigma="+blurSigma);
	
	prominenceValue = _MAXIMA_PROMINENCE;
	run("Find Maxima...", "prominence="+prominenceValue+" light output=[Segmented Particles]");
	run("Invert");
	rename(title);
	selectImage(tmpImage);
	close();
}

function getMaxima(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","-maxima.tif");
	
	run("Duplicate...", "title="+title+"-tmp.tif");
	tmpImage = getImageID();
	blurSigma = 4;
	run("Gaussian Blur...", "sigma="+blurSigma);
	
	prominenceValue = _MAXIMA_PROMINENCE;
	run("Find Maxima...", "prominence="+prominenceValue+" light output=[Single Points]");
	run("Dilate");
	run("Dilate");
	run("Dilate");
	rename(title);
	selectImage(tmpImage);
	close();
}

function createOldMaskImage(inputImageID){
	selectImage(inputImageID);
	title = getTitle(); 
	title = title.replace(".tif","");
	run("Duplicate...", "title="+title+"-mask.tif");
	applyVarianceAndThreshold(_VARIANCE_RADIUS,_THRESHOLD_METHOD);
	oldCleanMask();
}

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
	rename("DirtyWorm");
	dirtyWormImageTitle = getTitle();
	
	run("Analyze Particles...", "size=0-1000 show=Masks");
	dirtyRestImageID = getImageID();
	rename("DirtyOutside");
	dirtyRestImageTitle = getTitle();
	
	imageCalculator("Subtract create", dirtyWormImageTitle,dirtyRestImageTitle);
	run("Invert");
	cleanRestImageID = getImageID();
	rename("CleanOutside");
	cleanRestImageTitle = getTitle();
	
	selectImage(dirtyWormImageID);
	close();
	selectImage(dirtyRestImageID);
	close();
	
	run("Analyze Particles...", "size=0-1000 show=Masks");
	dirtyInImageID = getImageID();
	rename("DirtyInside");
	dirtyInImageTitle = getTitle();
	
	imageCalculator("Substract create", cleanRestImageTitle,dirtyInImageTitle);
	cleanImageID = getImageID();
	rename("CleanOutside");
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

function oldCleanMask(){
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	run("Options...", "iterations=1 count=1 black do=Nothing");
	run("Erode");
	run("Fill Holes");
	//run("Analyze Particles...", "size=1000-Infinity display clear add");
	run("Analyze Particles...", "size=1000-Infinity show=Masks");
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
		
	run("Convolve...", "text1=[4 4 4\n4 8 4\n4 4 4\n] normalize");
	run("Find Maxima...", "prominence=5 light output=[Single Points]");
	rename(title+"-intersection.tif");
	run("Dilate");
	selectImage(tmpImageID);
	close();
}

function getOldWormSegmentationImage(){
	setBatchMode(true);
	originalImageID = getImageID();
	
	getSeparationLine(originalImageID);
	separationLinesID = getImageID();
	separationLinesTitle = getTitle();
	
	createOldMaskImage(originalImageID);
	maskImageID = getImageID();
	maskImageTitle = getTitle();
	
	imageCalculator("Subtract create", maskImageTitle,separationLinesTitle);
	segmentationID = getImageID();
	selectImage(separationLinesID);
	close();
	selectImage(maskImageID);
	close();
	setBatchMode("exit and display");
}

function getOldWormSegmentationVisualisation(){
	setBatchMode(true);
	originalImageID = getImageID();
	originalImageTitle = getTitle();
	
	getSeparationLine(originalImageID);
	separationLinesID = getImageID();
	separationLinesTitle = getTitle();
	
	getMaxima(originalImageID);
	maximaID = getImageID();
	maximaTitle = getTitle();
	
	createOldMaskImage(originalImageID);
	maskImageID = getImageID();
	maskImageTitle = getTitle();
	
	selectImage(originalImageID);
	run("Duplicate...", "title="+originalImageTitle+"-duplicate.tif");
	
	run("Merge Channels...", "c1="+separationLinesTitle+" c2="+maskImageTitle+" c7="+maximaTitle+" c4="+originalImageTitle+"-duplicate.tif create");
	segmentationID = getImageID();

	setBatchMode("exit and display");
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
	
	
	selectImage(originalImageID);
	run("Duplicate...", "title="+originalImageTitle+"-duplicate.tif");
	
	//run("Merge Channels...", "c1="+skeletonTitle+" c2="+maskImageTitle+" c4="+originalImageTitle+"-duplicate.tif create");
	run("Merge Channels...", "c1="+skeletonTitle+" c2="+maskImageTitle+" c6="+intersectionTitle+" c4="+originalImageTitle+"-duplicate.tif create");
	segmentationID = getImageID();
	rename(replace(originalImageTitle,".tif","-segmented-visualisation.tif"));

	setBatchMode("exit and display");
}


function makeWormsROI(){
	run("Analyze Particles...", "size=10000-Infinity display add");
}


//README Dialog Functions

function wormSegmentationOptionDialog(){
	Dialog.create("Worm Segmentation Options");
	addDialogGetSeparationLine();
	addDialogCreateMask();
	Dialog.show();
	getDialogGetSeparationLine();
	getDialogCreateMask();
}

function addDialogGetSeparationLine(){
	Dialog.addMessage("Separation Lines", 14);
	Dialog.addSlider("Gaussian Blur Sigma", 0, 20, _BLUR_SIGMA);
	
	Dialog.addSlider("Find Maxima Prominence", 0, 255, _MAXIMA_PROMINENCE);
}

function getDialogGetSeparationLine(){
	_BLUR_SIGMA = Dialog.getNumber();
	_MAXIMA_PROMINENCE = Dialog.getNumber();
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
