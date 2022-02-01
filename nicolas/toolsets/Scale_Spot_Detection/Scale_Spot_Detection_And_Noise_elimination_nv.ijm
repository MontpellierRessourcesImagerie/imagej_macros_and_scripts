// multi Scale Processing
// open an image

requires("1.48d");
var _FILE_EXTENSION = "tif";
// var _FILE_EXTENSION = "nd";
var _SSF = sqrt(2);
var _SIGMA_START = 1.6;
// av var _SIGMA_DELTA = 0.4;
var _SIGMA_DELTA = 0.4;

// av :               var _SCALE_SPACE_PARTS_OF_WIDTH = 150;
var _SCALE_SPACE_PARTS_OF_WIDTH = 100;
// var _MAXIMA_PROMINENCE = 6.984// 100;
var _MAXIMA_PROMINENCE = 0.5;

// av var _AUTO_MAXIMA_PROMINENCE = true;
var _AUTO_MAXIMA_PROMINENCE = false;

// av :      var _RADIUS_VARIANCE_FILTER = 2;
var _RADIUS_VARIANCE_FILTER = 2;
var _EXCLUDE_ON_EDGES = true;
var _MERGE_SPOTS = true;
// av :      var _MIN_COVERAGE = 100;
var _MIN_COVERAGE = 25;
var _DISPLAY_SCALE_SPACE = false;
var _CHANNEL = 2;

run("Close All");
dir = getDirectory("Select Image input folder!");
files = getFileList(dir);
// get image file name with its extension 
images_name = filterImageFiles(files, dir, _FILE_EXTENSION);

Im = newArray(2);
array = Array.concat(images_name[0],images_name[1]);
// print(images_name.lenght);
Array.print(array);
// waitForUser("quel imaje est prise pour le soft");

for(i=1; i<=2; i++){
		Array.show("title",array);
		open(images_name[i-1]);
		Im[i-1]= getImageID();
		selectImage(Im[i-1]);
}
selectImage(Im[0]);
// run("Minimum...", "radius=4 stack");
// run("Maximum...", "radius=2 stack");
// run("Top Hat...", "radius=20");
// run("Gaussian Blur...", "sigma=5");
// run("Median...", "radius=14");

//waitForUser("Minimum Maximum Top Gaussaian Median");

// run("Anisotropic Diffusion 2D", "number=20 smoothings=1 keep=20 a1=0.50 a2=0.90 dt=20 edge=5");
// run("Duplicate...", "title=Anisotropic Diffusion 2D Copy_Median_Cal_Image_Filter");
// run("Grays");

// waitForUser("ap anisotropic");


createScaleSpace();
stack_ID_Array = newArray(nSlices);
findAndLinkScaleSpaceSpots(stack_ID_Array);
// selectImage(stack_ID_Array);



// **********************************************************************************************//

function createScaleSpace(){ 
	width = getWidth();
	height = getHeight();
	max = round(width/_SCALE_SPACE_PARTS_OF_WIDTH);
	print("max"+max);
	// waitForUser("ap max");
	title = getTitle();
	run("Duplicate...", " ");
	rename("tmp");
	run("Duplicate...", " ");
	run("Images to Stack", "name=Scale-Space title=[tmp] use");
	run("Size...", "width="+width+" height="+height+" depth="+max+" constrain average interpolation=Bilinear");
	sigmas = newArray(nSlices);
	stackID = getImageID();
	run("32-bit");
	for(i=1; i<=nSlices; i++) {
	//for(i=1; i<=10; i++) {
		setSlice(i);
		run("Duplicate...", " ");
		sliceID = getImageID();
		sigma = (_SIGMA_START + 5*(i-1) * _SIGMA_DELTA);
		sigmas[i-1] = sigma;
		run("FeatureJ Laplacian", "compute smoothing="+sigma);
		laplacianID = getImageID();
		run("Multiply...", "value="+(sigma*sigma));
		run("Select All");
		run("Copy");
		selectImage(stackID);
		run("Paste");
		selectImage(sliceID);
		close();
		selectImage(laplacianID);
		close();
	}
	run("Select None");
	resetMinAndMax();
	return sigmas;
}

function findAndLinkScaleSpaceSpots(Stack_Slice_Array){
	run("Set Measurements...", "area mean standard modal min centroid center bounding feret's integrated median skewness kurtosis stack display redirect=None decimal=9");
	roiManager("reset");
	run("Clear Results");
	
	// ajouter
	// selectImage(stackID);
	waitForUser("OK ds findAndLinkScale");
    // filter.sobel()
	// run("Gran filter");
	
	sigmas = newArray(nSlices);
	
	// ID_Stack_Slice_Array = newArray(nSlices);

	for (i = 1; i <= nSlices; i++) {
		sigma = _SIGMA_START + 5*(i-1)*_SIGMA_DELTA;
		radius = sigma*_SSF;
		print("radius= "+radius);
		Stack.setSlice(i);
		
		Stack_Slice_Array[i] = getImageID();
		print(Stack_Slice_Array[i]);
		waitForUser("OK slice ID");

		run("Enhance Contrast", "saturated=0.35");
		run("Gaussian Blur...", "sigma=5");
		// run("Invert", "stack");
		run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
		getSelectionCoordinates(xpoints, ypoints);
		
		roiManager("show all without labels");
		
		for (j = 0; j < xpoints.length; j++) {
			// setLineWidth(50);
			// makeOval(xpoints[j]+0.5-radius, ypoints[j]+0.5-radius, (2*radius), (2*radius));
			// makeOval(xpoints[j]-radius, ypoints[j]-radius, (2*radius), (2*radius));
			makePoint(xpoints[j],ypoints[j],"large red cross");
			// roiManager("show all without labels");
			run("Colors...", "foreground=white background=black selection=red");
			roiManager("add");
			// waitForUser("OK ds makeOval");
		}
		run("Select None");
	}
	roiManager("measure");	
	// run("Enhance Contrast", "saturated=0.35");
}

// **********************************************************************************************//
function filterImageFiles(list, dir, extension) {
	images = newArray(0);
	for (i = 0; i < list.length; i++) {
		file = list[i];
		path = dir + File.separator + file;
		if (File.isDirectory(path)) continue;
		if (endsWith(file, "."+_FILE_EXTENSION)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}

function detectSpots() {
	run("Set Measurements...", "area mean standard modal min centroid center feret's integrated display redirect=None decimal=9");
	Overlay.remove;
	rgb = (bitDepth()==24);
	if (rgb) {
		run("Duplicate...", " ");
		run("16-bit"); 
	}
	run("ROI Manager...");
	setBatchMode(true);
	Overlay.remove;
	run("Select None");
	imageID = getImageID();
	sigmas = createScaleSpace();
	scaleSpaceID = getImageID();
	findMinima(sigmas, imageID, scaleSpaceID);
	selectImage(imageID);
	if (_MERGE_SPOTS) {
		mergeSpots();
	}
	if (_EXCLUDE_ON_EDGES) {
		removeEdgeSpots();
	}
	if (!_DISPLAY_SCALE_SPACE) {
		selectImage(scaleSpaceID);
		close();
	}
	setBatchMode("exit and display");
	run("Clear Results");
	roiManager("reset");
	selectImage(imageID);
	if (rgb) {
		run("To ROI Manager");
		close();
		run("From ROI Manager");
	}
	startIndex = nResults;
	Overlay.measure;
	endIndex = nResults;
	reportResults(startIndex, endIndex);
	print("Done!");
}

function findMinima(sigmas, imageID, scaleSpaceID) {
	if (_AUTO_MAXIMA_PROMINENCE) {
		selectImage(imageID);
		_MAXIMA_PROMINENCE = estimateSTD(_RADIUS_VARIANCE_FILTER);
	}
	selectImage(scaleSpaceID);
	Stack.setSlice(1);
	run("Z Project...", "projection=[Min Intensity]");
	run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
	getSelectionCoordinates(xpoints, ypoints);
	close();
	run("Select None");
	selectImage(scaleSpaceID);
	Stack.setSlice(1);
	run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
	getSelectionCoordinates(xpoints2, ypoints2);
	xpoints = Array.concat(xpoints, xpoints2);
	ypoints = Array.concat(ypoints, ypoints2);
	run("Select None");
	
	for (i = 0; i < xpoints.length; i++) {
		
		oldMin = 99999999;
		currentMin = 1111111;
		
		while(oldMin!=currentMin) {
	
			selectImage(scaleSpaceID);
			x = xpoints[i];
			y = ypoints[i];
			setSlice(1);
			makePoint(x, y);
			run("Plot Z-axis Profile");
			Plot.getValues(pxpoints, pypoints);
			close();
			ranks = Array.rankPositions(pypoints);
			minIndex = ranks[0]+1;
			currentMin = pypoints[minIndex-1];
			
			sigma = sigmas[minIndex-1];
			radius = sigma*_SSF;

			setSlice(minIndex);
			makeRectangle(x-radius, y-radius, 2*radius+1, 2*radius+1);
			Roi.getContainedPoints(rxpoints, rypoints);
			oldMin = currentMin;
			for(j=0; j<rxpoints.length; j++) {
				for(k=0; k<rypoints.length; k++) {
					v = getPixel(rxpoints[j], rypoints[k]);
					if (v<currentMin) {
						currentMin = v;
						xpoints[i] = rxpoints[j];
						ypoints[i] = rypoints[k];
					}			
				}
			}
			
		}
		run("Select None");
		selectImage(imageID);
		makeOval(x+0.5-radius, y+0.5-radius, (2*radius), (2*radius));
		Overlay.addSelection;
		run("Select None");
	}
	Overlay.show;
}

function estimateSTD(radius) {
	run("Duplicate...", " ");
	run("Variance...", "radius="+radius);
	
	// run("Blobs (25K)");
	// method = "Otsu";
	// setAutoThreshold(method);
	// call("ij.plugin.frame.ThresholdAdjuster.setMethod",method)
	// run("Threshold...");
	
	setAutoThreshold("Triangle");
	
	run("Create Selection");
	getStatistics(area, mean);
	close();
	stDev = sqrt(mean);
	return stDev;
}




