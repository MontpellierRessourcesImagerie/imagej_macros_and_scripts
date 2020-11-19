/**
  * MRI g-ratio Tools
  * Collaborators: 
  *		 Jolanta M Jagodzinska
  *
  * In images from transmission electron microscopy of the optic nerve, calculate the g-ratio
  * of the axons. The pg-factor and the ag-factor will be measured. The pg-factor is the inner 
  * perimeter of the neuron devided by the outer perimeter including the myelin. The ag-factor 
  * is the square-root of the area of the inner surface devided by the area of the outer surface 
  * including the myelin.
  *
  * (c) 2017, INSERM
  * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *
*/

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/MRI_g-ratio_Tools";

var RADIUS_MEDIAN_FILTER = 9;
var MIN_SIZE = 500;
var MIN_SOLIDITY = 0.8;
var _OBJECT = "axon";
var _AXON_ROI_COLOR = "green";
var _AXON_ROI_WIDTH = 2;
var _MYELIN_ROI_COLOR = "blue";
var _MYELIN_ROI_WIDTH = 2;
var _TITLE;

macro "MRI gRatio Help Action Tool - C222D0fD15D16D19D1fD24D2fD3fD53D63D90Df4DfeC858D10D14D32D3dD45D4bD4dD59D5dD6dD84D9dDadDafDb3DdbC444D06D0eD1eD29D2bD3aD3bD44D67D72D81D9bDaeDdcDe2Cc9cD04D22D30D36D5aD70D82D83D98Da7DacDb6DbdDccDd2Dd4Df1C333D07D08D34D43D49D64D76D80Da9DbfDc1Dd0Dd1Dd7De9DebDeeDfaCb6bD0aD1bD21D27D2cD2dD4cD56D68D77D7dD86DbaDc9DcdDdaC555D35D3cD4eD62D73Da1DbeDc0Dc6Dc8DcfDd6DdfDe7Df2Cf9fD00D01D02D0cD12D1cD6bD78D87D93D94D95Da4Da5Da6C333D17D18D25D4fD5fD6eD74D75Db8Dc7De8DecDedDf3Df5Df7Df8Df9DfbDfcDfdDffC878D23D28D55D71D7fD91D99D9eDa2DabDc2DceDd9DdeDe6Df0C545D20D39D4aD57D66D9aD9cDa8DaaDb7Dd5Dd8DddDe0De4DefCf9fD03D0dD13D1dD37D41D5bD61D7cD8aD8bD8cD8dD92D96Dc3DcbDd3C434D1aD2aD2eD33D3eD54D58D5eD6fDa0Db1Db2De1De5DeaDf6Ce7eD0bD11D31D38D46D47D5cD6cD8eD8fD9fDa3Db4Db5Dc4DcaC656D05D09D26D42D48D52D65D7eD85Db0Db9Dc5De3CfcfD40D50D51D60D69D6aD79D7aD7bD88D89D97DbbDbc" {
	run('URL...', 'url='+helpURL);
}

macro 'MRI gRatio Help Action Tool Options' {
	 Dialog.create("MRI gRatio Options");
	 Dialog.addNumber("radius of median filter: ", RADIUS_MEDIAN_FILTER);
	 Dialog.addNumber("min. size of axons: ", MIN_SIZE);
	 Dialog.addNumber("min. solidity of axons: ", MIN_SOLIDITY);
	 Dialog.addString("axon roi colour: ", _AXON_ROI_COLOR); 
	 Dialog.addNumber("axon roi width: ", _AXON_ROI_WIDTH); 
	 Dialog.addString("myelin roi colour: ", _MYELIN_ROI_COLOR); 
	 Dialog.addNumber("myelin roi width: ", _MYELIN_ROI_WIDTH); 
	 Dialog.show();
	 RADIUS_MEDIAN_FILTER = Dialog.getNumber();
	 MIN_SIZE = Dialog.getNumber();
	 MIN_SOLIDITY = Dialog.getNumber();
	 _AXON_ROI_COLOR = Dialog.getString();
	 _AXON_ROI_WIDTH = Dialog.getNumber();
	 _MYELIN_ROI_COLOR = Dialog.getString();
	 _MYELIN_ROI_WIDTH = Dialog.getNumber();
}

macro 'Prepare Image Action Tool (f1) - C000T4b12p' {
	prepareImage();
}

macro 'Prepare Image [f1]' {
	prepareImage();
}

macro 'Detect Axons Action Tool (f2) - C000T4b12d' {
	detectAxons();
}

macro 'Detect Axons [f2]' {
	detectAxons();
}

macro 'Rename Rois Action Tool (f3) - C000T4b12r' {
	renameRois();
}

macro 'Rename Rois Action Tool (f3) Options' {
	 Dialog.create("MRI gRatio Rename Options");
	 Dialog.addString("object name: ", _OBJECT);
	 Dialog.show();
	 _OBJECT = Dialog.getString();
}

macro 'Rename Rois [f3]' {
	renameRois();
}

macro 'Find Outer Border Action Tool (f4) - C000T4b12f' {
	findOuterBorder();
}

macro 'Find Outer Border [f4]' {
	findOuterBorder();
}

macro 'Smooth Selection Action Tool (f5) - C000T4b12s' {
	run("Interpolate", "interval=1 smooth adjust");
	smoothSelection();
}

macro 'Smooth Selection [f5]' {
	run("Interpolate", "interval=1 smooth adjust");
	smoothSelection();
}

macro 'Measure G Ratio Action Tool (f6) - C000T4b12m'  {
	measureGRatio();
}

macro 'Measure G Ratio [f6]' {
	measureGRatio();
}

function findOuterBorder() {
	imageID = getImageID();
	countAndMeasureDensity();
	createIndexedMask();
	growRegions();
	addMyelinSelections();
	selectImage(imageID);
	close("\\Others");
	roiManager("Show None");
	roiManager("Show All");
}

function countAndMeasureDensity() {
	image = _TITLE;
	Stack.setChannel(2);
	run("Select None");
	run("Duplicate...", " ");
	fgc = getValue("color.foreground");
	roiManager("Combine");
	setForegroundColor(255, 255, 255);
	run("Fill", "slice");
	run("Select None");
	setAutoThreshold("Default");
	run("Create Selection");
	run("Measure");
	myelinArea = getResult("Area", nResults-1);
	run("Select None");
	resetThreshold();
	roiManager("Combine");
	run("Measure");
	axonArea = getResult("Area", nResults-1);
	axonNumber = roiManager("count");
	setForegroundColor(0, 0, 0);
	run("Fill", "slice");
	run("Select None");
	setAutoThreshold("Default dark");
	run("Create Selection");
	run("Measure");
	emptyArea = getResult("Area", nResults-1);
	setColor(fgc);
	close();
    title = "axon number and density";
    handle = "[" + title + "]";
	if (!isOpen(title)) {
				Table.create(title);
                print(handle, "\\Headings:n\timage\tnr. axons\tarea axons\tarea myelin\tarea empty");
    }
    selectWindow(title);
    text = getInfo("window.contents");
    lines = split(text, "\n");
    nr = lines.length;
    print(handle, nr + "\t" + image + "\t" + axonNumber + "\t" + axonArea + "\t" + myelinArea + "\t" + emptyArea);
}

function addMyelinSelections() {
	imageWidth = getWidth();
	imageHeight = getHeight();
	toBeRemoved = newArray();
	count = roiManager("Count");
	for (i=0; i<count; i++) {
		roiManager("select", i);
		getSelectionBounds(x, y, width, height);
		if(x<=0 || y<=0 || x+width>=(imageWidth-1) || y+height>=(imageHeight-1)) 
			toBeRemoved = Array.concat(toBeRemoved, i);
		else {
			getSelectionBounds(x, y, width, height);
			run("Select None");
			x = x + (width/2);
			y = y + (height/2);
			doWand(x, y);
			getSelectionBounds(x, y, width, height);
			if(x<=0 || y<=0 || x+width>=(imageWidth-1) || y+height>=(imageHeight-1)) 
			toBeRemoved = Array.concat(toBeRemoved, i);
		}
	}
	roiManager("select", toBeRemoved);
	roiManager("delete");
	count = roiManager("Count");
	for (i=0; i<count; i++) {
		roiManager("select", i);
		roiManager("Rename", "axon" + pad("" + (i+1), 4));
		roiManager("Set Color", _AXON_ROI_COLOR);
		roiManager("Set Line Width", _AXON_ROI_WIDTH);
		getSelectionBounds(x, y, width, height);
		x = x + (width/2);
		y = y + (height/2);
		doWand(x, y);
		roiManager("add");
		index = roiManager("count") - 1;
		roiManager("Select", index);
		roiManager("Rename", "myelin" + pad("" + (index+1), 4));
		roiManager("Set Color", _MYELIN_ROI_COLOR);
		roiManager("Set Line Width", _MYELIN_ROI_WIDTH);
	}
	roiManager("deselect");
}

function growRegions() {
	command="Grow Regions";
	List.setCommands;
	value = List.get(command);
	if (value!="") {
		print("Using plugin, good !");
		run(command);
		updateDisplay();
	}
	else {
		changedSomething = true;
		imageID = getImageID();
		width = getWidth();
		run("Duplicate...", " ");
		nextImageID = getImageID();
		setBatchMode(true);
		i=1;
		while(changedSomething && i<201) {
				print("\\Update0:generation " + i);
				changedSomething = attachPointsToNearestObjects(imageID, nextImageID);
				selectImage(imageID);
				close();
				if (changedSomething) {
					imageID = nextImageID;
					selectImage(nextImageID);
					run("Duplicate...", " ");
					nextImageID = getImageID();
				}
				i++;
		}
		setBatchMode("exit and display");
	}
}


function prepareImage() {
	dir = getInfo("image.directory");
	file = getInfo("image.filename");
	imageID = getImageID();
	imageTitle = getTitle();
	_TITLE = imageTitle;
	run("8-bit");
	run("Duplicate...", " ");
	maskID = getImageID();
	maskTitle = getTitle();
	run("Median...", "radius="+RADIUS_MEDIAN_FILTER);
	setAutoThreshold("Default dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Merge Channels...", "c4=["+imageTitle+"] c6=["+maskTitle+"] create ");
	selectImage("Composite");
	Stack.setChannel(2);
}

function detectAxons() {
	run("Set Measurements...", "area mean standard perimeter shape integrated skewness kurtosis display redirect=None decimal=3");
	imageID = getImageID();
	width = getWidth();
	height = getHeight();
	totalArea = width * height;
	image = getTitle();
	Stack.setChannel(2);
	run("Select None");
	roiManager("Reset");
	run("Clear Results");
	run("Duplicate...", "duplicate channels=2-2");
	setAutoThreshold("Default dark");
	run("Analyze Particles...", "size=0-Infinity add");
	close();
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Measure");
	indices = newArray();
	for(i=0; i<nResults; i++) {
		area = getResult("Area", i);
		circularity = getResult("Circ.", i);
		solidity = getResult("Solidity", i);
		if (area<MIN_SIZE || /* circularity<MIN_CIRCULARITY ||*/ solidity<MIN_SOLIDITY) {
			indices = Array.concat(indices, i);
		}
	}
	roiManager("Select", indices);
	roiManager("Delete");
	nr = roiManager("count");
	Stack.setChannel(2);
	for(i=0;i<nr;i++) {
			roiManager("select", 0);
			smoothSelection();
			roiManager("Add");
			roiManager("select", 0);
			roiManager("delete");
			roiManager("select", nr-1);
			roiManager("Rename", "axon" + pad("" + (i+1), 4));
			roiManager("Set Color", _AXON_ROI_COLOR);
			roiManager("Set Line Width", _AXON_ROI_WIDTH);
	}
	roiManager("deselect");
}

function renameRois() {
	index = roiManager("index");
	if (index<0) index = 0;
	count = roiManager("count");
	for (i=index; i<count; i++) {
		roiManager("select", i);
		roiManager("Rename", _OBJECT + pad("" + (i+1), 4));
	}
	roiManager("deselect");
}

function smoothSelection() {
	if (selectionType==-1) return;
	run("Convex Hull");
	run("Interpolate", "interval=1 smooth adjust");
}

function pad(text, size) {
	diff = size - lengthOf(text);
	if (diff<=0) return text;
	result = text;
	for (i=0; i<diff; i++) {
		result = "0" + result;	
	}
	return result;
}

function attachPointsToNearestObjects(currentImageID, nextImageID) {
	selectImage(currentImageID);
	changedSomething = false;
	width = getWidth();
	height = getHeight();
	neighbors = newArray(4);
	for (x=0; x<width; x++) {
		for (y=0; y<height; y++) {
			v = getPixel(x,y);
			if (v==0) {
				n = getPixel(x, y-1);
				if (n==255) n=0;
				neighbors[0] = n;

				n = getPixel(x+1, y);
				if (n==255) n=0;
				neighbors[1] = n;

				n = getPixel(x-1, y);
				if (n==255) n=0;
				neighbors[2] = n;

				n = getPixel(x, y+1);
				if (n==255) n=0;
				neighbors[3] = n;

				Array.getStatistics(neighbors, min, max);
				if (max>0) {
					selectImage(nextImageID);
					setPixel(x,y,max);
					changedSomething = true;
					selectImage(currentImageID);
				} 
			}			
		}
	}
	return changedSomething;
}

function createIndexedMask() {
	Stack.setChannel(2);
	imageID = getImageID();
	roiManager("Deselect");
	roiManager("Combine");
	run("Create Mask");
	maskID = getImageID();
	run("Connected Components Labeling", "connectivity=4 type=[8 bits]");
	setPasteMode("Transparent-zero");
	run("Select All");
	run("Copy");
	selectImage(imageID);
	run("Duplicate...", " ");
	newImageID = getImageID();
	run("Paste");
	run("glasbey");
	selectImage(maskID);
	close();
	selectImage(newImageID);
	run("Select None");
}

function measureGRatio() {
	   roiManager("Deselect");
       run("Set Measurements...", "area perimeter shape display redirect=None decimal=3");
       run("Clear Results");
       roiManager("Measure");
       image = _TITLE;
       title = "g-ratio measurements";
       handle = "[" + title + "]";
       if (!isOpen(title)) {
       			Table.create(title);
                print(handle, "\\Headings:n\timage\tpg\tag");
       }
       for(i=0; i<nResults/2; i=i+1) {
               innerArea = getResult("Area", i);
               innerPerimeter = getResult("Perim.", i);
               outerArea = getResult("Area", i+(nResults/2));
               outerPerimeter = getResult("Perim.", i+(nResults/2));
               pg = innerPerimeter / outerPerimeter;
               ag = sqrt(innerArea / outerArea);
               print(handle, "" + (i+1) + "\t" + image + "\t" + pg + "\t" + ag);
       }
}

