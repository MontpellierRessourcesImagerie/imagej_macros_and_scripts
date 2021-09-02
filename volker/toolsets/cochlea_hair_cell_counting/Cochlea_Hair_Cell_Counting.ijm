/**
  * Cochlea Hair Cell Counting
  *
  *  The tool expects a stack of segmented hair cells (mask) in the cochlea.
  *  The tool creates the z-projection of the stack and waits for the user to select 
  *  the cochlea with a line selection tool using a width of the line that covers the 
  *  hair cells. The tool will straigthen the image under the line-selection and count
  *  the cells per segment of a given length.
  *
  *  written 2016-2018 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *  in cooperation with Aurélie Saleur
  */
  
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Cochlea-Hair-Cell-Counting";
var _USE_WATERSHED = true;
var _CORRECT_AFTER_STRAIGHTEN = true;
var _MIN_SIZE = 10;
var _MAX_SIZE = 150;
var _SEGMENT_LENGTH = 200;
var _DO_NOT_STRAIGHtEN = false;
var _STRAIGTHEN_COUNTER = 1;

function showHelp() {
     run('URL...', 'url='+helpURL);
}

macro "count hair cells [f2]" {
    countHairCells();
}

macro "help [f1]" {
    showHelp();
}

macro "draw grid [f3]" {
   drawGrid();
   Overlay.show();
}

macro "manual count [f4]" {
   reportCount();
}

macro "z-projection [f5]" {
   zProjection();
}

macro "z-projection-spots [f6]" {
   zProjectionSpots();
}


macro "combine-projections [f7]" {
	combineProjections();
}

macro "Help (f1) Action Tool - C000T4b12?" {
    showHelp();
}

macro "Count Hair Cells (f2) Action Tool - C000D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D17D18D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D26D27D28D29D2aD2bD2cD2dD2eD2fD30D31D32D33D36D37D38D39D3aD3bD3cD3dD3eD3fD40D41D45D46D47D48D4eD4fD50D51D55D56D57D5aD5bD5eD5fD60D61D65D66D67D68D69D6aD6bD6eD6fD70D71D75D76D77D78D79D7aD7bD7cD7eD7fD80D81D84D85D86D87D88D89D8aD8bD8cD8eD8fD90D91D95D96D97D98D99D9aD9bD9eD9fDa0Da1Da5Da6Da7Da8Da9DaaDabDaeDafDb0Db1Db6Db7Db8Db9DbaDbeDbfDc0Dc1Dc8DceDcfDd0Dd1Dd2DdeDdfDe0De1De2De3DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC000D74Dc2De4DecC000Dc7Dc9C000C111Db5DbbC111D94C111D9cDddC111Dd3C111D6cC111D64C222C333D42C333C444C555Dc6DcaC555D54D5cC555C666Da4DacC666Db2C666De5C666DebC666C777C888C999D52C999CaaaCbbbDa2CbbbDe6DeaCbbbCcccD4cCcccDcdCcccDc3CcccDd4CcccCdddD62DdcCdddDc5DcbCdddDb4DbcCdddCeeeCfffD92CfffDe7De9CfffD72CfffD82CfffDe8CfffD15D16D25D34D35D43D44D49D4aD4bD4dD53D58D59D5dD63D6dD73D7dD83D8dD93D9dDa3DadDb3DbdDc4DccDd5Dd6Dd7Dd8Dd9DdaDdb" {
    countHairCells();
}

macro "Count Hair Cells (f2) Action Tool Options" {
    Dialog.create("Cochlea Hair Cell Counting");
    Dialog.addNumber("min. cell area", _MIN_SIZE);
    Dialog.addNumber("max. cell area", _MAX_SIZE);
    Dialog.addNumber("segment length", _SEGMENT_LENGTH);
    Dialog.addCheckbox("use watershed", _USE_WATERSHED);
    Dialog.addCheckbox("correct after straighten", _CORRECT_AFTER_STRAIGHTEN);
    Dialog.addCheckbox("do not straighten", _DO_NOT_STRAIGHtEN);
    Dialog.addHelp(helpURL);
    Dialog.show();
    _MIN_SIZE = Dialog.getNumber();
    _MAX_SIZE = Dialog.getNumber();
    _SEGMENT_LENGTH = Dialog.getNumber();
    _USE_WATERSHED = Dialog.getCheckbox();
    _CORRECT_AFTER_STRAIGHTEN = Dialog.getCheckbox();
    _DO_NOT_STRAIGHtEN = Dialog.getCheckbox();
}

macro "Draw Grid (f3) Action Tool - C0a0L18f8L818f" {
    drawGrid();
    Overlay.show();
}

macro "Manual Count (f4) Action Tool - C000T4b12m" {
  reportCount();
}

macro "ZProjection (f5) Action Tool - C000T4b12z" {
   zProjection();
}

macro "ZProjectionSpots (f6) Action Tool - C037T1d13zT9d13sC555" {
   zProjectionSpots();
}

macro "Combine projections (f7) Action Tool - Cf00D15D17D19D35D37D39D56D58D5aDb4Db6Db8Dd5Dd7Dd9Df5Df7Df9" {
	combineProjections();
}


macro "straigthen and correct [f8]" {
	straighten();
}

macro "straigthen and correct (f8) Action Tool - C037T1d13sT9d13cC555" {
	straighten();
}

macro "stitch straigthened parts [f9]" {
	stitchStraigthenedParts();
}

macro "stitch straigthened parts (f9) Action Tool - C037T1d13sT9d13tC555" {
	stitchStraigthenedParts();
}

macro "find cells and measure [f10]" {
	findCellsAndMeasure();
}

macro "find cells and measure (f10) Action Tool - C037T1d13fT9d13mC555" {
	findCellsAndMeasure();
}

function countHairCells() {
	if (!_DO_NOT_STRAIGHtEN) straighten();	
    findCellsAndMeasure();
}

function findCellsAndMeasure() {
	findCells();
    sortMeasurements();
    countPerSegment() ;
}

function drawGrid() {
   setColor(0,255,255);
   setJustification("center");
   fontHeight = getValue("font.height");
   
   width = getWidth();
   height = getHeight();

    startX = 0;
    len = _SEGMENT_LENGTH;
	i = 1;
    while (startX<width) {
   		xR = startX;
		toUnscaled(xR);
		lenR = len;
		toUnscaled(lenR);
		makeRectangle(xR, 0, lenR, height);
		run("Add Selection...");
		Overlay.drawString(i, xR+lenR/2 , height/2);
		startX = startX + len;
		i++;
    }
}

function straighten() {
    run("Select None");
    imageCellsID = getImageID();
    getPixelSize(unit, pixelWidth, pixelHeight);
    roiManager("Reset");
    run("Set Measurements...", "area centroid display redirect=None decimal=3");
   if (selectionType==-1)
	    waitForUser("Please make a selection and then select the SPOTS-Image!");
    run("Set Scale...", "distance=1 known="+pixelWidth+" pixel=1 unit="+unit);
    if (nSlices>1) run("Z Project...", "projection=[Max Intensity]");
    imageSpotsID = getImageID();
    run("Restore Selection");
    run("Straighten...");
    imageSpotsStraightenedID = getImageID();
    imageSpotsStraightenedTitle = getTitle();
    setAutoThreshold("Default dark");
    run("Convert to Mask");
    if( _USE_WATERSHED) run("Watershed");

    selectImage(imageCellsID);
    run("Straighten...");
    run("8-bit");

    imageCellsStraightenedID = getImageID();
    imageCellsStraightenedTitle = getTitle();

    selectImage(imageCellsID);
    close();
    if(isOpen(imageSpotsID)){
	    selectImage(imageSpotsID);
	    close();
    }

    run("Merge Channels...", "c1="+imageSpotsStraightenedTitle+" c2="+imageCellsStraightenedTitle+" create");    
	run("Set Scale...", "distance=1 known="+pixelWidth+" pixel=1 unit="+unit);
    
    if(_CORRECT_AFTER_STRAIGHTEN)   waitForUser("Please correct!");
    number = zeroPad(_STRAIGTHEN_COUNTER++, 5);
    rename("chcc-part " + number);
}

function findCells() {
	run("Duplicate...", "title=mask duplicate channels=1-1");
    setThreshold(1, 255);
    run("Analyze Particles...", "size="+_MIN_SIZE+"-"+_MAX_SIZE+" show=Nothing display clear add");
    roiManager("Show None");
    roiManager("Show All");
    wait(100);
}

function countPerSegment() {
    startX = 0;
    len = _SEGMENT_LENGTH;
    counter = 0;
    segment = 1;
    height = getHeight();
	width = getWidth();
	toScaled(width);

	fontHeight = getValue("font.height");
    run("Remove Overlay");

    title1 = "Count per segment";
    title2 = "["+title1+"]";
    f = title2;
    if (isOpen(title1))
         print(f, "\\Clear");
    else
         run("Table...", "name="+title2+" width=250 height=600");
    print(f, "\\Headings:segment\tcount");

	
	nrOfSegments = floor(width / len);
	segments = newArray(nrOfSegments);
	Array.fill(segments, 0);
	x = 0;
    for (i=0; i<nResults; i++) {
		x = getResult("X", i);
		segmentNr = floor(x / len);
		if (segmentNr < nrOfSegments) segments[segmentNr] =  segments[segmentNr] + 1;
    }
    drawGrid();
    lenUnscaled = len;
    toUnscaled(lenUnscaled);
    for (i=0; i<segments.length; i++) {
    	print(f, (i+1)+"\t"+segments[i]);
    	Overlay.drawString(segments[i], (i*lenUnscaled) + (lenUnscaled/2) , height/2+fontHeight);
    }
    Overlay.show(); 
    run("Select None");
}

function reportCount() {
     id = getImageID();
     getSelectionCoordinates(xpoints, ypoints);
     count = xpoints.length;
    title1 = "Manual count";
    title2 = "["+title1+"]";
    f = title2;
    if (!isOpen(title1)) {
         run("Table...", "name="+title2+" width=250 height=600");
         print(f, "\\Headings:segment\tcount");
    }
    selectWindow("Manual count"); 
    content = getInfo("window.contents");
    comp = split(content, "\n");
    index = comp.length;
    print(f, index+"\t"+count);
    selectImage(id);
    run("Add Selection...");
}

function sortMeasurements() {
    FEATURE = "X";
    REVERSE = false;

    column = newArray(nResults);
    for (i=0; i<nResults; i++) {
	column[i] = getResult(FEATURE, i);
    }
    positions = Array.rankPositions(column);
    if (REVERSE) Array.reverse(positions);
    ranks = Array.rankPositions(positions);
    
    for (i=0; i<roiManager("count"); i++) {
	roiManager("select", i);
	roiManager("Rename", IJ.pad(ranks[i], 4)); 
    }
    roiManager("Deselect");
    roiManager("Sort");
    selectWindow("Results");
    run("Close");
    roiManager("Show None");
    roiManager("Show All");
    roiManager("Measure");
}

function zProjection() {
   dir = getDirectory("Select the input folder!");
   files = getFileList(dir);
   print("\\Clear");
   setBatchMode(true);
   for(i=0; i<files.length; i++) {
	print("\\Update1:Calculating projection of image " + (i+1) + " from " + files.length);
	path = dir + "/" + files[i];
	if (!File.isDirectory(path)) {
		run("Bio-Formats Importer", "open=["+path+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		name = File.nameWithoutExtension();
		run("Z Project...", "projection=[Max Intensity]");
		saveAs("tiff", dir + "/" + "MAX_" + name +".tif"); 
		close();
		close();
	}
   }
   setBatchMode("exit and display");
   print("Finished projections");
}

function zProjectionSpots() {
	dir = getDirectory("Select the input folder!");
	files = getFileList(dir);
	files = filterDirectories(dir,files);
	print("\\Clear");
	setBatchMode(true);
	for(i=0; i<files.length; i++) {
		print("\\Update1:Calculating projection of image " + (i+1) + " from " + files.length);
		path = dir + "/" + files[i];
		images = getFileList(path);
		imagefound = false;
		image1="";
		j=0;
		while(!imagefound){
			if(j==images.length){
				break;
			}
			if(endsWith(images[j], ".tif")){
				imagefound=true;
				image1 = images[j];	
			}
			j++;
		}
		if(!imagefound){
			continue;
		}
		imagePath = dir + "/" + files[i] + "/" + image1;
		run("Image Sequence...", "open=["+imagePath+"] sort");
		run("Z Project...", "projection=[Max Intensity]");
		title = getTitle();
		saveAs("tiff", dir + "/" + "SPOTS_" + title); 
		close();
		close();
	}
	setBatchMode("exit and display");
	print("Finished projections");
}

function filterDirectories(dir,files){
	results = newArray(0);
	for (i=0; i<files.length; i++) {
		file = files[i];
		if (File.isDirectory(dir+files[i])) {
			results = Array.concat(results, file);
		}
	}
	return results;
}

function combineProjections() {
	titles = getList("image.titles");
	xCoordinates = newArray(titles.length);
	for(i=0; i<titles.length; i++) {
		selectImage(titles[i]);
		getLocationAndSize(x, y, width, height);
		xCoordinates[i] = x;
	}
	indicesInOrder = Array.rankPositions(xCoordinates);
	for(i=0; i<titles.length-1; i++) {
		title1 = titles[i];
		selectImage(title1);
		id1 = getImageID();
		title2 = titles[i+1];
		selectImage(title2);
		id2 = getImageID();
		run("Pairwise stitching", "first_image=["+title1+"] second_image=["+title2+"] fusion_method=[Linear Blending] fused_image=["+title2+"] check_peaks=5 ignore display_fusion compute_overlap subpixel_accuracy x=-0.0044 y=0.0015 registration_channel_image_1=[Average all channels] registration_channel_image_2=[Average all channels]");
		selectImage(id1);
		close();
		selectImage(id2);
		close();
	}
}

function stitchStraigthenedParts() {
	titles = getList("image.titles");
	titles = filterList(titles, "chcc-part"); 
	if (lengthOf(titles)<2) return;
	Array.sort(titles);
	selectImage(titles[0]);
	rename("Combined Stacks");
	for(i=1; i<titles.length; i++) {
		run("Combine...", "stack1=["+"Combined Stacks"+"] stack2=["+titles[i]+"]");
		wait(100);
	}
	run("Red");
	Stack.setChannel(2);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(1);
}

function zeroPad(value, digits) {
	len = lengthOf("" + value);
	nrOfLeadingZeros = digits - len;
	result = "" + value;
	for (i=0; i<nrOfLeadingZeros; i++) {
		result = "0" + result;
	}
	return result;
}

function filterList(list, prefix) {
	result = newArray();
	for(i=0; i<list.length; i++) {
		elem = list[i];
		if (startsWith(elem, prefix)) result = Array.concat(result, elem);
	}
	return result;
}
