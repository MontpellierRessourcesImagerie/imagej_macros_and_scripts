/***
 * 
 * MRI 3D nuclei clustering
 * 
 * Detect nuclei in 3D images and run a cluster analysis on them
 * 
 * (c) 2019-2020, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/

var _NUCLEI_CHANNEL = 3;
var _SCALE = 6;
var _RADIUS_XY = 1.50;
var _RADIUS_Z = 1.50;
var _NOISE = 500;
var _EXCLUDE_ON_EDGES = true;
var _RADIUS_SPHERE = 3 	// in scaled units (for exampel µm)
var _LOOKUP_TABLE = "glasbey on dark";
var _CREATE_RESULTS_CHANNEL = true;
var _DECIMALS = 3;

// parameters for filtering the nuclei according to the signal in another channel
var _SIGNAL_CHANNEL = 1;
var _RADIUS_MEASUREMENT = 1;
var _THRESHOLD = 900;

// parameters for the clustering of the nuclei
var _MAX_DIST = 18;
var _MIN_PTS = 5;
var _X_COLUMN = 'X';
var _Y_COLUMN = 'Y';
var _Z_COLUMN = 'Z';
var _NR_COLUMN = "NR";

// parameters for batch processing
var _FILE_EXTENSION = "ims";
var _SERIES = "series_2"

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/3D_Nuclei_Clustering_Tool";

exit();

macro "3D nuclei clustering tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "3D nuclei clustering tool help (f4) Action Tool - Cf00L0010Le0f0L0111C555D51C666L6181C444D91Cf00Ld1e1L0212C555D32C999D42CaaaL5282C999D92C777Da2Cf00Lc2d2L0313C555D23C999D33CbbbD43CcccL5383CbbbD93CaaaDa3C666Lb3c3Cf00L0414C999D24CbbbD34CcccD44CdddL5494CcccDa4CbbbDb4C666Dc4Cf00L0515CaaaD25CcccD35CdddD45CfffL5585CdddL95a5CbbbDb5C777Dc5Cf00L0616CaaaD26CcccD36CdddD46CfffL5696CdddDa6CbbbDb6C999Dc6Cf00L0717CaaaD27CcccD37CdddD47CfffL5797CdddDa7CbbbDb7C999Dc7C111Dd7Cf00L0818CaaaD28CcccD38CdddD48CfffL5898CdddDa8CbbbDb8C999Dc8Cf00L0919C999D29CbbbD39CdddL4959CfffL6989CdddD99CcccDa9CbbbDb9C777Dc9Cf00L0a1aC777D2aCaaaD3aCcccD4aCdddL5a8aCcccD9aCbbbDaaC999DbaC444DcaCf00L0b1bC666D3bCbbbL4b9bC999DabC666DbbCf00L0c2cC666L3c4cC777D5cC999L6c8cC777D9cC444DacCf00L0d2dC111D7dCf00L0efeL0fff"{
	run('URL...', 'url='+helpURL);
}


macro "process image (f2) Action Tool - C000T4b12p" {
	processImage();
}

macro "process image [f2]" {
	processImage();
}

macro "run batch analysis (f3) Action Tool - C000T4b12b" {
	batchProcessImages();
}

macro "run batch analysis [f3]" {
	batchProcessImages();
}

macro "run batch analysis (f3) Action Tool Options" {
	Dialog.create("Batch processing options");
	Dialog.addString("image file-extension: ", _FILE_EXTENSION);
	Dialog.addString("name of image series (empty if none): ", _SERIES);
	Dialog.show();
	_FILE_EXTENSION = Dialog.getString();
	_SERIES = Dialog.getString();
}

macro " Action Tool - " {
}

macro "detect nuclei (f5) Action Tool - C000T4b12d" {
	detectNuclei();
}

macro "detect nuclei [f5]" {
	detectNuclei();
}

macro "detect nuclei (f5) Action Tool Options" {
	Dialog.create("Detect nuclei options");
	Dialog.addNumber("scale: ", _SCALE);
	Dialog.addNumber("radius xy: ", _RADIUS_XY);
	Dialog.addNumber("radius z: ", _RADIUS_Z);
	Dialog.addNumber("noise: ", _NOISE);
	Dialog.addCheckbox("exclude on edges ", _EXCLUDE_ON_EDGES);
	Dialog.addNumber("nuclei channel: ", _NUCLEI_CHANNEL);
	Dialog.addCheckbox("create results channel ", _CREATE_RESULTS_CHANNEL);
	Dialog.show();
	_SCALE = Dialog.getNumber();
	_RADIUS_XY = Dialog.getNumber();
	_RADIUS_Z = Dialog.getNumber();
	_NOISE = Dialog.getNumber();
	_EXCLUDE_ON_EDGES = Dialog.getCheckbox();
	_NUCLEI_CHANNEL = Dialog.getNumber();
	_CREATE_RESULTS_CHANNEL = Dialog.getCheckbox();
}

macro "add nuclei (f6) Action Tool - C000T4b12a" {
	addNuclei();
}

macro "add nuclei [f6]" {
	addNuclei();
}


macro "remove nuclei (f7) Action Tool - C000T4b12r" {
	removeNuclei();
}

macro "add nuclei [f7]" {
	removeNuclei();
}

macro "filter above threshold (f8) Action Tool - C000T4b12f" {
	filterAboveThreshold();
}

macro "filter above threshold [f8]" {
	filterAboveThreshold();
}

macro "filter above threshold (f8) Action Tool Options" {
	Dialog.create("Filter nuclei options");
	Dialog.addNumber("signal channel: ", _SIGNAL_CHANNEL);
	Dialog.addNumber("radius: ", _RADIUS_MEASUREMENT);
	Dialog.addNumber("threshold: ", _THRESHOLD);
	Dialog.show();
	_SIGNAL_CHANNEL = Dialog.getNumber();
	_RADIUS_MEASUREMENT = Dialog.getNumber();
	_THRESHOLD = Dialog.getNumber();
}

macro "cluster nuclei (f9) Action Tool - C000T4b12c" {
	clusterNuclei(_MAX_DIST, _MIN_PTS, _X_COLUMN, _Y_COLUMN, _Z_COLUMN, _NR_COLUMN);
}

macro "cluster nuclei [f9]" {
	clusterNuclei(_MAX_DIST, _MIN_PTS, _X_COLUMN, _Y_COLUMN, _Z_COLUMN, _NR_COLUMN);
}

macro "cluster nuclei (f9) Action Tool Options" {
	Dialog.create("Clustering options");
	Dialog.addNumber("max. distance: ", _MAX_DIST);
	Dialog.addNumber("min. nr. points: ", _MIN_PTS);
	Dialog.addString("x-column: ", _X_COLUMN);
	Dialog.addString("y-column: ", _Y_COLUMN);
	Dialog.addString("z-column: ", _Z_COLUMN);
	Dialog.addString("nr-column: ", _NR_COLUMN);
	Dialog.show();
	_MAX_DIST = Dialog.getNumber();
	_MIN_PTS = Dialog.getNumber();
	_X_COLUMN = Dialog.getString();
	_Y_COLUMN = Dialog.getString();
	_Z_COLUMN = Dialog.getString();
	_NR_COLUMN = Dialog.getString();
}

macro "nearest neighbors (f11) Action Tool - C000T4b12n" {
	winTitle = getInfo("window.title");
	if (winTitle=="clusters" || winTitle=="unclustered" || winTitle=="Results") {
		calculateNearestNeighbors(winTitle);
	} else {
		showMessage("Please select a table (clusters, unclustered or Results)!");
	}
}

macro "nearest neighbors [f11]" {
	winTitle = getInfo("window.title");
	if (winTitle=="clusters" || winTitle=="unclustered" || winTitle=="Results") {
		calculateNearestNeighbors(winTitle);
	} else {
		showMessage("Please select a table (clusters, unclustered or Results)!");
	}
}

macro "visualize nn_connections (v) Action Tool - C000T4b12v;" {
	winTitle = getInfo("window.title");
	if (winTitle=="clusters" || winTitle=="unclustered" || winTitle=="Results") {
		drawNearestNeighborConnections(winTitle);
	} else {
		showMessage("Please select a table (clusters, unclustered or Results)!");
	}
}

macro "visualize nn-connections [v]" {
	winTitle = getInfo("window.title");
	if (winTitle=="clusters" || winTitle=="unclustered" || winTitle=="Results") {
		drawNearestNeighborConnections(winTitle);
	} else {
		showMessage("Please select a table (clusters, unclustered or Results)!");
	}
}

var dCmds = newMenu("Images Menu Tool",
    newArray("download dataset", "spheroid-01", "spheroid-02", "spheroid-03", "-", "options"));

macro "Images Menu Tool - CfffL00f0L0161CeeeD71CfffL81f1L0252CeeeD62C666D72CeeeD82CfffL92f2L0353CeeeD63C444D73CeeeD83CfffL93f3L0454CeeeD64C444D74CeeeD84CfffL94f4L0555CeeeD65C444D75CeeeD85CfffL95f5L0636CdddD46CfffD56CeeeD66C444D76CeeeD86CfffD96CdddDa6CfffLb6f6L0727CdddD37C444D47CbbbD57CeeeD67C444D77CeeeD87CbbbD97C444Da7CdddDb7CfffLc7f7L0838CbbbD48C444D58C999D68C444D78C999D88C444D98CbbbDa8CfffLb8f8L0949CbbbD59C333D69C111D79C333D89CbbbD99CfffLa9f9L0a5aCbbbD6aC444D7aCbbbD8aCfffL9afaL0b6bCeeeD7bCfffL8bfbL0c2cCeeeL3cbcCfffLccfcL0d1dCeeeD2dC666D3dC444L4dadC666DbdCeeeDcdCfffLddfdL0e2eCeeeL3ebeCfffLcefeL0fff" {
       cmd = getArgument();
       DATASET_DIR = call("ij.Prefs.get", "mribia.datasetDir", "/media/baecker/DONNEES1/mri/in");
       DATASET_NAME = "spheroids";
       DATASET_SOURCE = 'https://zenodo.org/record/3636087';
       DATASET_PATTERN = ".ome.tif";
       if (cmd=="download dataset") {
       	   print("Starting download of the spheroids-dataset...");
       	   script = 'import os'+"\n"
                    +'print(os.popen("wget -np -nd -r -P '+DATASET_DIR+"/"+DATASET_NAME+"/"+' -l1 -A'+DATASET_PATTERN+' '+DATASET_SOURCE+'").read())';
		   eval("python", script);
		   print("...download of the spheroids-dataset finished.");
       } 
       if (cmd=="spheroid-01") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/spheroid01.ome.tif autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="spheroid-02") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/spheroid02.ome.tif autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="spheroid-03") {
       	   options = "open="+DATASET_DIR+"/"+DATASET_NAME+"/spheroid03.ome.tif autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT";
       	   run("Bio-Formats", options);
       }
       if (cmd=="options") {
       	   Dialog.create("mribia options");
       	   Dialog.addMessage("These options are global and persistent.")
       	   Dialog.addString("input datasets directory: " , DATASET_DIR, 36);
       	   Dialog.show();
       	   DATASET_DIR = Dialog.getString();
       	   call("ij.Prefs.set", "mribia.datasetDir", DATASET_DIR); 
       }
       
}

function addNuclei() {
	xC = Property.getNumber("originx");
	yC = Property.getNumber("originy");
	zC = Property.getNumber("originz");
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	zoom = getZoom();
	if (selectionType() != 10) return;
	getSelectionCoordinates(xpoints, ypoints);
	run("Select None");
	getStatistics(area, mean, min, max, std, histogram);
	if (min!=0 || max>1) {
		showMessage("Please select a mask channel!");
		return;
	}
	Stack.getPosition(channel, z, frame);
	for (p=0; p<xpoints.length; p++) {
		x = xpoints[p];
		y = ypoints[p];
		xScaled = x;
		yScaled = y;
		zScaled = z-1;
		toScaled(xScaled, yScaled);
		zScaled = zScaled * voxelDepth;
		X = Table.getColumn("X", "Results");
		Y = Table.getColumn("Y", "Results");
		Z = Table.getColumn("Z", "Results");
		D = Table.getColumn("Dist. from center", "Results");
		xS = xC;
		yS = yC;
		zS = zC;
		toScaled(xS, yS, zS);
		dX = x-xS; 
		dY = y-yS;
		dZ = z-zS;
		dist = sqrt(dX*dX + dY*dY + dZ*dZ);
		X = Array.concat(X, xScaled);
		Y = Array.concat(Y, yScaled);
		Z = Array.concat(Z, zScaled);
		D = Array.concat(D, dist);
		run("Clear Results");
		Table.setColumn("X", X, "Results");
		Table.setColumn("Y", Y, "Results");
		Table.setColumn("Z", Z, "Results");
		Table.setColumn("Dist. from center", D, "Results");
		Table.sort(_Z_COLUMN, "Results");
		Table.applyMacro("NR=row+1 ", "Results");
		c=1;
		
		inputStackID = getImageID();
		inputTitle = getTitle();

		setBatchMode(true);
		if (channels>1) {
			run("Duplicate...", "duplicate channels="+channel+"-"+channel);		
		}
		run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+xScaled+","+yScaled+","+zScaled+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+","+_RADIUS_SPHERE+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
		run(_LOOKUP_TABLE);
		updatedChannelID = getImageID();
		updatedChannelTitle = getTitle();
		
		selectImage(inputStackID);
		run("Split Channels");
		
		selectImage("C"+channel+"-"+inputTitle);
		close();
		
		mergeString = "";
		
		if (channels>1) {
			for (i = 1; i < channel; i++) {
				mergeString = mergeString + "c"+i+"=C"+i+"-"+inputTitle+" ";
			}
			mergeString = mergeString + "c"+channel+"="+updatedChannelTitle + " ";
			for (i = channel+1; i <= channels; i++) {
				mergeString = mergeString + "c"+i+"=C"+i+"-"+inputTitle+" ";
			}
			mergeString = mergeString + "create";
		}
		run("Merge Channels...", mergeString);
		rename(inputTitle);
		setBatchMode(false);
		run("Set... ", "zoom="+zoom*100+" x="+x+" y="+y);
	}
	
	Stack.setSlice(round(zC));
	makePoint(round(xC), round(yC), "hybrid extra large");
	Overlay.addSelection;
	Overlay.setPosition(0, round(zC), 0);
	run("Select None");

	Stack.setPosition(channel, z, frame);
	makePoint(x, y);
		
	Property.set("originx", xC);
	Property.set("originy", yC);
	Property.set("originz", zC);
}

function removeNuclei() {
	xC = Property.getNumber("originx");
	yC = Property.getNumber("originy");
	zC = Property.getNumber("originz");
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	zoom = getZoom();
	if (selectionType() != 10) return;
	getSelectionCoordinates(xpoints, ypoints);
	run("Select None");
	getStatistics(area, mean, min, max, std, histogram);
	if (min!=0 || max>1) {
		showMessage("Please select a mask channel!");
		return;
	}
	Stack.getPosition(channel, z, frame);
	for (p=0; p<xpoints.length; p++) {
		x = xpoints[p];
		y = ypoints[p];
		value = getPixel(x, y);
		if (value==0) continue;
		xScaled = x;
		yScaled = y;
		zScaled = z-1;
		toScaled(xScaled, yScaled);
		zScaled = zScaled * voxelDepth;
		X = Table.getColumn("X", "Results");
		Y = Table.getColumn("Y", "Results");
		Z = Table.getColumn("Z", "Results");
		D = Table.getColumn("Dist. from center", "Results");
		minDist = 999999999;
		minIndex = -1;
		for (i = 0; i < X.length; i++) {
			Dx = xScaled - X[i];
			Dy = yScaled - Y[i];
			Dz = zScaled - Z[i];
			dist = sqrt(Dx*Dx + Dy*Dy + Dz*Dz);
			if (dist<minDist) {
				minDist = dist;
				minIndex = i;
			}
		}
		run("Clear Results");
		xCN = X[minIndex];
		yCN = Y[minIndex];
		zCN = Z[minIndex];
		X  = Array.concat(Array.slice(X,0,minIndex), Array.slice(X,minIndex+1,X.length));
		Y  = Array.concat(Array.slice(Y,0,minIndex), Array.slice(Y,minIndex+1,Y.length));
		Z  = Array.concat(Array.slice(Z,0,minIndex), Array.slice(Z,minIndex+1,Z.length));
		D  = Array.concat(Array.slice(D,0,minIndex), Array.slice(D,minIndex+1,D.length));
		Table.setColumn("X", X, "Results");
		Table.setColumn("Y", Y, "Results");
		Table.setColumn("Z", Z, "Results");
		Table.setColumn("Dist. from center", D, "Results");
		Table.sort(_Z_COLUMN, "Results");
		Table.applyMacro("NR=row+1 ", "Results");
		c=0;
		inputStackID = getImageID();
		inputTitle = getTitle();

		setBatchMode(true);
		if (channels>1) {
			run("Duplicate...", "duplicate channels="+channel+"-"+channel);		
		}
		run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+xCN+","+yCN+","+zCN+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+","+_RADIUS_SPHERE+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
		run(_LOOKUP_TABLE);
		updatedChannelID = getImageID();
		updatedChannelTitle = getTitle();
		
		selectImage(inputStackID);
		run("Split Channels");
		
		selectImage("C"+channel+"-"+inputTitle);
		close();
		
		mergeString = "";
		
		if (channels>1) {
			for (i = 1; i < channel; i++) {
				mergeString = mergeString + "c"+i+"=C"+i+"-"+inputTitle+" ";
			}
			mergeString = mergeString + "c"+channel+"="+updatedChannelTitle + " ";
			for (i = channel+1; i <= channels; i++) {
				mergeString = mergeString + "c"+i+"=C"+i+"-"+inputTitle+" ";
			}
			mergeString = mergeString + "create";
		}
		
		run("Merge Channels...", mergeString);
		setBatchMode(false);
		run("Set... ", "zoom="+zoom*100+" x="+x+" y="+y);
	}
	Stack.setSlice(round(zC));
	makePoint(round(xC), round(yC), "hybrid extra large");
	Overlay.addSelection;
	Overlay.setPosition(0, round(zC), 0);
	run("Select None");

	Stack.setPosition(channel, z, frame);
	makePoint(x, y);

	Property.set("originx", xC);
	Property.set("originy", yC);
	Property.set("originz", zC);
}

function batchProcessImages() {
	inputFolder = getDirectory("Choose the input folder!");
	files = getFileList(inputFolder);
	images = filterImages(files, _FILE_EXTENSION);
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	ctrlFolder = inputFolder + "clustering-"+year+"-"+month+"-"+dayOfMonth+"-"+hour+"_"+minute+"_"+second+"/";
	if (images.length > 0 && !File.exists(ctrlFolder)) {
		File.makeDirectory(ctrlFolder)
	}
	for (i = 0; i < images.length; i++) {
		image = images[i];
		path = inputFolder + image;
		run("Bio-Formats Importer", "open="+path+" color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT "+_SERIES);
		imageID = getImageID();
		title = getTitle();
		processImage();
		saveAs("tiff", ctrlFolder + title);
		close();
		selectWindow("unclustered");
		saveAs("results", ctrlFolder + "unclustered-" + title+".xls");
		selectWindow("clusters");
		saveAs("results", ctrlFolder + "clusters-" + title+".xls");
		selectWindow("Results");
		saveAs("results", ctrlFolder + "above_thr-" + title+".xls");		
	}
	selectWindow("Log");
	saveAs("text", ctrlFolder + "Log.txt");
	selectWindow("cluster analysis of nuclei");
	saveAs("results", ctrlFolder + "results.xls");
}

function filterImages(files, ext) {
	images = newArray();
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, "."+ext)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}

function processImage() {
	totalNumberOfNuclei = 0;	  		// The total number of nuclei detected in the image
	numberOfRedNuclei = 0;		  		// The number of nuclei with a signal above the threshold in the red channel
	numberOfClusters = 0;		  		// The number of clusters
	numberOfNucleiInClusters = 0;  		// The number of nuclei that belong to a cluster
	numberOfNucleiOutsideClusters = 0; 	// The number of nuclei outside of clusters 
	meanNNDistAll = 0;					// The mean of the nearest neighbor distance for all nuclei (above the red threshold)
	stdDevNNDistAll = 0;				// The standard deviation of the nearest neighbor distances
	meanNNDistUnclustered = 0;			// The mean of the nearest neighbor distance for all unclustered nuclei
	stdDevNNDistUnclustered = 0;		// The standard deviation of the nearest neighbor distances
	meanNNDistClustered = 0;			// The mean of the nearest neighbor distance for all clustered nuclei.
	stdDevNNDistClustered = 0;			// The standard deviation of the nearest neighbor distances

	imageID = getImageID();
	title = getTitle();
	
	print(title);
	print("parameter values:");
	print("-----------------");
	print("detect nuclei:");
	print("---");
	print("scale: \t" + _SCALE);
	print("radius xy: \t" + _RADIUS_XY);
	print("radius z: \t" + _RADIUS_Z);
	print("noise: \t" + _NOISE);
	print("excluse on edges: \t" + _EXCLUDE_ON_EDGES);
	print("nuclei channel \t" + _NUCLEI_CHANNEL);
	print("---");
	print("filtering:");
	print("---");
	print("signal channel: \t" + _SIGNAL_CHANNEL);
	print("radius: \t" + _RADIUS_MEASUREMENT);
	print("threshold: \t" + _THRESHOLD);
	print("---");
	print("dbscan clustering:");
	print("---");
	print("max. distance: \t" + _MAX_DIST);
	print("min nr. of points: \t" + _MIN_PTS);
	print("-----------------");
	totalNumberOfNuclei = detectNuclei();
	print("total number of nuclei: " + totalNumberOfNuclei);

	numberOfRedNuclei = filterAboveThreshold();
	print("number of nuclei above threshold ("+_THRESHOLD+") in red channel ("+_SIGNAL_CHANNEL+"): " + numberOfRedNuclei);

	numberOfClusters = clusterNuclei(_MAX_DIST, _MIN_PTS, _X_COLUMN, _Y_COLUMN, _Z_COLUMN, _NR_COLUMN);
	print("number of clusters (maxDist="+_MAX_DIST+", minPts="+_MIN_PTS+"): " + numberOfClusters);

	numberOfNucleiInClusters = Table.size("clusters");
	print("number of nuclei in clusters: " + numberOfNucleiInClusters);
	
	numberOfNucleiOutsideClusters = numberOfRedNuclei - numberOfNucleiInClusters;
	print("number of nuclei outside of clusters: " + numberOfNucleiOutsideClusters);

	nnDistancesAll = calculateNearestNeighbors("Results");
	Array.getStatistics(nnDistancesAll, min, max, meanNNDistAll, stdDevNNDistAll);
	print("mean nn-distance all nuclei: " + meanNNDistAll); 
	print("stdDev nn-distance all nuclei: " + stdDevNNDistAll); 

	NNDistancesUnclustered = calculateNearestNeighbors("unclustered");
	Array.getStatistics(NNDistancesUnclustered, min, max, meanNNDistUnclustered, stdDevNNDistUnclustered);
	print("mean nn-distance unclustered nuclei: " + meanNNDistUnclustered); 
	print("stdDev nn-distance unclustered nuclei: " + stdDevNNDistUnclustered); 

	NNDistancesClustered = calculateNearestNeighbors("clusters");
	Array.getStatistics(NNDistancesClustered, min, max, meanNNDistClustered, stdDevNNDistClustered);
	print("mean nn-distance clustered nuclei: " + meanNNDistClustered); 
	print("stdDev nn-distance clustered nuclei: " + stdDevNNDistClustered); 

	tableTitle = "cluster analysis of nuclei";
	if (!isOpen(tableTitle)) {
		Table.create(tableTitle);
	}else {
		selectWindow(tableTitle);
	}
	row = Table.size;
	Table.set("title", row, title);
	Table.set("total nr. of nuclei", row, totalNumberOfNuclei);
	Table.set("nr. of nuclei above thr.", row, numberOfRedNuclei);
	Table.set("nr. of clusters", row, numberOfClusters);
	Table.set("clustered", row, numberOfNucleiInClusters);
	Table.set("unclustered", row, numberOfNucleiOutsideClusters);
	Table.set("mean nn-distance all", row, meanNNDistAll);
	Table.set("stddev. all", row, stdDevNNDistAll);
	Table.set("mean nn-distance unclustered", row, meanNNDistUnclustered);
	Table.set("stddev. unclustered", row, stdDevNNDistUnclustered);
	Table.set("mean nn-distance clustered", row, meanNNDistClustered);
	Table.set("stddev. clustered", row, stdDevNNDistClustered);
}

function detectNuclei() {
	findCenterAndSetOrigin();
	x = Property.getNumber("originx");
	y = Property.getNumber("originy");
	z = Property.getNumber("originz");
	run("Set Measurements...", "mean modal min centroid center integrated stack display redirect=None");
	inputStackID = getImageID();
	inputStackTitle = getTitle();
	run("Duplicate...", "duplicate channels="+_NUCLEI_CHANNEL+"-"+_NUCLEI_CHANNEL);
	imageID = getImageID();
	getVoxelSize(width, height, depth, unit);
	run("FeatureJ Laplacian", "compute smoothing="+_SCALE);
	run("Invert", "stack");
	filteredID = getImageID();
	run("3D Maxima Finder", "radiusxy="+_RADIUS_XY+" radiusz="+_RADIUS_Z+" noise="+_NOISE);
	selectWindow("peaks");
	peaksID = getImageID();
	if (_EXCLUDE_ON_EDGES) {
		Stack.setSlice(1);
		run("Select All");
		run("Clear", "slice");
		run("Select None");
		Stack.setSlice(nSlices);
		run("Select All");
		run("Clear", "slice");
		run("Select None");
		Stack.setSlice(1);
		// delete rows where Z=0 or MAX
		X= newArray(0);
		Y= newArray(0);
		Z= newArray(0);
		V= newArray(0);
		
		for(row=0; row<nResults; row++) {
			zPos = getResult(_Z_COLUMN, row) * depth;
			if (zPos>0 && zPos<(nSlices-1)*depth) {
				xPos = getResult(_X_COLUMN, row) * width;
				yPos = getResult(_Y_COLUMN, row) * height;
				vObj = getResult("V", row);
				Z = Array.concat(Z, zPos);
				X = Array.concat(X, xPos);
				Y = Array.concat(Y, yPos);
				V = Array.concat(V, vObj);
			}
		}
		run("Clear Results");
		Table.create("Results");
		Table.setColumn(_X_COLUMN, X, "Results");
		Table.setColumn(_Y_COLUMN, Y, "Results");
		Table.setColumn(_Z_COLUMN, Z, "Results");
		Table.setColumn("V", V, "Results");
	}
	Table.sort(_Z_COLUMN, "Results");
	Table.applyMacro("NR=row+1 ", "Results");
	selectWindow("peaks");
	setVoxelSize(width, height, depth, unit);
	if (_CREATE_RESULTS_CHANNEL) {
		drawNuclei();
		addImageAtEndOfStack(inputStackID, "Results-indexed-mask");		
	}
	selectImage(filteredID);
	close();
	selectImage(peaksID);
	close();
	selectImage(imageID);
	close();
	Property.set("originx", x);
	Property.set("originy", y);
	Property.set("originz", z);
	addDistancesFromCenterToTable();

	Stack.setSlice(round(z));
	makePoint(round(x), round(y), "hybrid extra large");
	Overlay.addSelection;
	Overlay.setPosition(0, round(z), 0);
	run("Select None");
	return X.length;
}

function addDistancesFromCenterToTable() {
	xTrans = Property.getNumber("originx");
	yTrans = Property.getNumber("originy");
	zTrans = Property.getNumber("originz");
	toScaled(xTrans, yTrans, zTrans);
	Z = Table.getColumn("Z");
	X = Table.getColumn("X");
	Y = Table.getColumn("Y");
	D = newArray(X.length);
	for (i = 0; i < X.length; i++) {
		deltaX = X[i]-xTrans;
		deltaY = Y[i]-yTrans;
		deltaZ = Z[i]-zTrans;
		D[i] = sqrt(deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ);
	}
	Table.setColumn("Dist. from center", D, "Results");
}

function addImageAtEndOfStack(stackID, title) {
	selectImage(stackID);
	stackTitle = getTitle();
	Stack.getDimensions(width, height, channels, slices, frames);
	mergeString = "";
	if (channels>1) {
		run("Split Channels");
		for (i = 0; i < channels; i++) {
			mergeString += "c"+(i+1)+"=[C"+(i+1)+"-"+stackTitle+"] ";
		}
		mergeString += "c"+(channels+1)+"=["+title+"] create ";
	} else {
		mergeString = "c1=["+stackTitle+"] c2=["+title+"] create ";
	}
	run("Merge Channels...", mergeString);
}

function drawClusters() {
	drawNucleifromTable("clusters", "C");
}

function drawNuclei() {
	drawNucleifromTable("Results", "none");
}

function drawNucleifromTable(nameOfTable, nameOfColorColumn) {
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	newImage(nameOfTable + "-indexed-mask", "16-bit black", width, height, slices);
	setVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	X = Table.getColumn(_X_COLUMN, nameOfTable);
	Y = Table.getColumn(_Y_COLUMN, nameOfTable);
	Z = Table.getColumn(_Z_COLUMN, nameOfTable);
	if (nameOfColorColumn != "none"){
		C = Table.getColumn(nameOfColorColumn, nameOfTable);
		Table.sort(nameOfColorColumn, nameOfTable);
	}
	if (nameOfColorColumn != "none") {
		for (i = 0; i < X.length; i++) {
			x = X[i];
			y = Y[i];
			z = Z[i];
			c = C[i];
			run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+x+","+y+","+z+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+","+_RADIUS_SPHERE+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
		}
	} else {
		for (i = 0; i < X.length; i++) {
			x = X[i];
			y = Y[i];
			z = Z[i];
			c = 1;
			run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+x+","+y+","+z+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+","+_RADIUS_SPHERE+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
		}
	}
	run(_LOOKUP_TABLE);
}

function filterAboveThreshold() {
	xC = Property.getNumber("originx");
	yC = Property.getNumber("originy");
	zC = Property.getNumber("originz");
	inputStackID = getImageID();
	inputStackTitle = getTitle();
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	Stack.setChannel(_SIGNAL_CHANNEL);
	M = measureIntensityInOtherChannel();	
	X = Table.getColumn(_X_COLUMN);
	Y = Table.getColumn(_Y_COLUMN);
	Z = Table.getColumn(_Z_COLUMN);
	D = Table.getColumn("Dist. from center");
	XN = newArray(0);
	YN = newArray(0);
	ZN = newArray(0);
	MN = newArray(0);
	DN = newArray(0);
	for (i = 0; i < X.length; i++) {
		if (M[i]>=_THRESHOLD) {
			XN = Array.concat(XN, X[i]);
			YN = Array.concat(YN, Y[i]);
			ZN = Array.concat(ZN, Z[i]);
			MN = Array.concat(MN, M[i]);
			DN = Array.concat(DN, D[i]);
		}
	}	
	run("Clear Results");
	Table.create("Results");
	Table.setColumn(_X_COLUMN, XN);
	Table.setColumn(_Y_COLUMN, YN);
	Table.setColumn(_Z_COLUMN, ZN);
	Table.setColumn("Dist. from center", DN);
	Table.setColumn("Mean", MN);
	Table.applyMacro(""+_NR_COLUMN+"=row+1 ", "Results");
	if (_CREATE_RESULTS_CHANNEL) {
		drawNuclei();
		selectImage(inputStackID);
		Stack.getDimensions(width, height, channels, slices, frames);
		if (channels>1) {
			run("Split Channels");
			run("Merge Channels...", "c1=[C1-"+inputStackTitle+"] c2=[C2-"+inputStackTitle+"] c3=[C3-"+inputStackTitle+"] c4=[C4-"+inputStackTitle+"] c5=[Results-indexed-mask] create ");
		} else {
			run("Merge Channels...", "c1=["+inputStackTitle+"] c5=[Results-indexed-mask] create ");			
		}
	}
	Stack.setSlice(round(zC));
	makePoint(round(xC), round(yC), "hybrid extra large");
	Overlay.addSelection;
	Overlay.setPosition(0, round(zC), 0);
	run("Select None");

	Property.set("originx", xC);
	Property.set("originy", yC);
	Property.set("originz", zC);

	return XN.length;
}

function measureIntensityInOtherChannel() {
	X = Table.getColumn(_X_COLUMN, "Results");
	Y = Table.getColumn(_Y_COLUMN, "Results");
	Z = Table.getColumn(_Z_COLUMN, "Results");
	M = newArray(X.length);
	Overlay.remove;
	for (i = 0; i < X.length; i++) {
		x = X[i];
		y = Y[i];
		z = Z[i];
		toUnscaled(x, y, z);
		Stack.setSlice(z);
		makeOval(x-_RADIUS_MEASUREMENT, y-_RADIUS_MEASUREMENT, 2*_RADIUS_MEASUREMENT+1, 2*_RADIUS_MEASUREMENT+1);
		getStatistics(area, mean);
		M[i] = mean;
	}
	return M;
}

function clusterNuclei(maxDist, minPts, xColumn, yColumn, zColumn, nrColumn) {
	if (nImages>0) {
		inputStackID = getImageID();
	}
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/dbscan_clustering_3D.py");
	parameter = "maxDist="+maxDist+",minPts="+minPts+",X="+xColumn+",Y="+yColumn+",Z="+zColumn+",NR="+nrColumn;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	if (_CREATE_RESULTS_CHANNEL) {
		if (nImages>0) {
			drawClusters();
			addImageAtEndOfStack(inputStackID, "clusters-indexed-mask");		
		}
	}
	nrOfClusters = 0;
	rows = Table.size("clusters");
	if (rows>0) {
		C = Table.getColumn("C", "clusters");
		ranks = Array.rankPositions(C);
		nrOfClusters = C[ranks[ranks.length-1]];
	}
	copyDistToTable("clusters");
	copyDistToTable("unclustered");
	return nrOfClusters;
}

function calculateNearestNeighbors(tableName) {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/nearest_neighbor_distances_3D.py");
	parameter = "tableName="+tableName;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	nnDistances = Table.getColumn("nn. dist", tableName);
	return nnDistances;
}

function drawNearestNeighborConnections(tableName) {
	inputStackID = getImageID();
	Stack.getDimensions(width, height, channels, slices, frames);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	size = Table.size(tableName);
	newImage(tableName + "-neighbors", "16-bit black", width, height, slices);
	setVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	for (row = 0; row < size; row++) {
		x1 = Table.get(_X_COLUMN, row, tableName);
		y1 = Table.get(_Y_COLUMN, row, tableName);
		z1 = Table.get(_Z_COLUMN, row, tableName);
		neighbor = Table.get("neighbor", row, tableName)-1;
		x2 = Table.get(_X_COLUMN, neighbor, tableName);
		y2 = Table.get(_Y_COLUMN, neighbor, tableName);
		z2 = Table.get(_Z_COLUMN, neighbor, tableName);
		toUnscaled(x1, y1, z1);
		toUnscaled(x2, y2, z2);
		run("3D Draw Line", "size_x="+width+" size_y="+height+" size_z="+slices+" x0="+x1+" y0="+y1+" z0="+z1+" x1="+x2+" y1="+y2+" z1="+z2+" thickness=1.000 value=65535 display=Overwrite");
	}
	addImageAtEndOfStack(inputStackID, tableName+"-neighbors");	
}

function findCenterAndSetOrigin() {
	Overlay.remove;
	imageID = getImageID();
	title = getTitle();
	setBatchMode(true);
	run("Duplicate...", "duplicate");
	titleOfCopy = getTitle();
	run("Split Channels");
	run("Merge Channels...", "c1=C1-"+titleOfCopy+" c2=C2-"+titleOfCopy+" c3=C3-"+titleOfCopy);
	run("8-bit");
	setAutoThreshold("Default dark stack");
	run("Convert to Mask", "method=Default background=Dark");
	run("Fill Holes", "stack");
	run("Options...", "iterations=10 count=1 do=Close stack");
	run("Analyze Particles...", "size=5000-Infinity show=Masks stack");
	run("3D Centroid");
	x = getResult("CX(pix)", nResults-1);
	y = getResult("CY(unit)", nResults-1);
	z = getResult("CZ(pix)", nResults-1);
	close();
	close();
	close();
	selectImage(imageID);
	Stack.setSlice(round(z));
	makePoint(round(x), round(y), "hybrid extra large");
	Overlay.addSelection;
	Overlay.setPosition(0, round(z), 0);
	run("Select None");
	setBatchMode(false);
	Property.set("originx", x);
	Property.set("originy", y);
	Property.set("originz", z);
}

function copyDistToTable(aTable) {
	XC = Table.getColumn("X", aTable);
	YC = Table.getColumn("Y", aTable);
	ZC = Table.getColumn("Z", aTable);
	
	XR = Table.getColumn("X", "Results");
	YR = Table.getColumn("Y", "Results");
	ZR = Table.getColumn("Z", "Results");
	Dist = Table.getColumn("Dist. from center", "Results");

	for (i = 0; i < XC.length; i++) {
		xc = XC[i];
		yc = YC[i];
		zc = ZC[i];
		minDist = parseFloat("Infinity");
		minIndex = -1;
		for(j=0; j<XR.length; j++) {
			xr = XR[j];
			yr = YR[j];
			zr = ZR[j];		
			dX = xc - xr;
			dY = yc - yr;
			dZ = zc - zr;
			dist = dX*dX + dY*dY + dZ*dZ;
			if (dist<minDist) {
				minDist = dist;
				minIndex = j;
			}
		}
		Table.set("Dist. from center", i, Dist[minIndex], aTable);
	}
	Table.update(aTable);
}

