/**
  * MRI Cluster Analysis of Nuclei Tools
  * 
  * Analyse the clustering behaviour of nuclei in DAPI stained images.  
  * The nuclei are detected as the maxima in the image. Using a threshold intensity
  * value maxima below the threshold are eliminated. The resulting points are clustered
  * using the DBSCAN algorithm. The nearest neighbor distances outside and inside of the clusters
  * are calculated.
  *   
  * (c) 2018, INSERM
  * 
  * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 *
*/

var _SIGMA = 7;
var _NOISE = 100;
var _THRESHOLD = 14000;
var _MAX_DIST = 120
var _MIN_PTS = 2

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI-macro-toolsets/Cluster_Analysis_Of_Nuclei";

macro "cluster nuclei tools help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "cluster nuclei tools help (f4) Action Tool - C555D27D37D47D52D5cD60D74D75D76D7bD87D9eDa1Da8Db8Dc1Dd2Dd5Df1C333D17D1cD66D7cD8aDa0Db0Dc0Dd8De0De1De2De4C888D3bD42D5bD84D85D93D9dDa4Da6Db2Db4Db5Db9Dc4DcaDcbDccDdbC222D03D14D24D36D46D53D56D5dD62D65D6dD72D81D88D89D8eD90D9fDd0Dd7De5De9Df3C777D2bD83D86D92D9aDa7Db6Dc3DdaDdcC444D02D0bD2cD61D73D91D98D99Dc8Dd6DebDecC999D22D32D39D3aD49D4aD59D5aD94DacDbaDbbC222D04D05D06D07D0cD15D16D25D26D2dD34D3dD44D4dD55D5eD5fD63D64D6eD70D71D7dD80D8fDdfDe6De7De8DeeDf4Df5Df6Df7Df8C666D00D01D09D0aD18D1bD68D79D7aD97Db1Db7Dc6Dc9DceDd3Dd4DddC333D08D13D43D67D77D78D8bD8cD8dDafDcfDd1De3DeaDedDf2C888D19D1aD28D2aD38D48D4bD50D51D69D6aD95D9bD9cDa3DadDb3DbcDbdC777D12D58D6bD96Da2Da5Da9DaeDbeDc2Dc5DcdDf0C444D23D33D3cD4cD57D6cD82DbfDc7Dd9DdeCaaaD10D11D20D21D29D30D31D40D41DaaDabC111D0dD1dD1eD1fD2eD2fD35D3eD3fD45D4eD4fD54D6fD7eD7fDefDf9DfaDfbDfcDfd" {
	run('URL...', 'url='+helpURL);
}

macro "cluster nuclei [f5]" {
	clusterNuclei();
}

macro "cluster nuclei (f5) Action Tool - C000T4b12c" {
	clusterNuclei();
}

macro "cluster nuclei (f5) Action Tool Options" {
	 Dialog.create("Cluster Nuclei Options");
	 Dialog.addNumber("sigma of gaussian filter: ", _SIGMA);
	 Dialog.addNumber("noise: ", _NOISE);
	 Dialog.addNumber("threshold: ", _THRESHOLD);
	 Dialog.addNumber("max. dist: ", _MAX_DIST);
	 Dialog.addNumber("min. pts.: ", _MIN_PTS);
	 
	 Dialog.show();
	 
	 _SIGMA = Dialog.getNumber();	
	 _NOISE = Dialog.getNumber();	
	 _THRESHOLD = Dialog.getNumber();	
	 _MAX_DIST = Dialog.getNumber();	
	 _MIN_PTS = Dialog.getNumber();	
}

macro "nearsest neighbors [f6]" {
	nearestNeighbors();
}

macro "nearest neighbors (f6) Action Tool - C000T4b12n" {
	nearestNeighbors();
}

macro "select all nuclei [f7]" {
	selectAllNuclei();
}

macro "select all nuclei (f7) Action Tool - C037T1d13sT9d13aC555" {
	selectAllNuclei();
}

macro "select unclustered nuclei [f8]" {
	selectAllUnclustered();
}

macro "select unclustered nuclei (f8) Action Tool - C037T1d13sT9d13uC555" {
	selectAllUnclustered();
}

macro "select clustered nuclei [f9]" {
	selectAllClustered();
}

macro "select unclustered nuclei (f9) Action Tool - C037T1d13sT9d13cC555" {
	selectAllClustered();
}

function clusterNuclei() {
	run("Set Measurements...", "area mean standard modal min centroid center integrated display redirect=None decimal=3");
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=" + _SIGMA);
	run("Find Maxima...", "noise="+_NOISE+" output=[Point Selection] exclude");
	run("Clear Results");
	run("Measure");
	
	xCoordinates = newArray();
	yCoordinates = newArray();
	
	for(i=0; i<nResults; i++) {
		mean = getResult("Mean", i);
		if (mean>_THRESHOLD) {
			x = getResult("X", i);
			y = getResult("Y", i);
			xCoordinates = Array.concat(xCoordinates, x);
			yCoordinates = Array.concat(yCoordinates, y);
		}
	}
	
	close();
	makeSelection("point",xCoordinates,yCoordinates);
	roiManager("reset");
	roiManager("Add");
	roiManager("Select", 0);
	roiManager("Set Color", "blue");
	roiManager("Set Line Width", 0);
	
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/dbscan_clustering.py");
	parameter = "maxDist="+_MAX_DIST+",minPts="+_MIN_PTS;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	
	randomColorRois(1);

  	title = "Cluster Analysis of Nuclei Results";
  	handle = "["+title+"]";
  if (!isOpen(title)) {
     run("Table...", "name="+handle+" width=800 height=600");
     print(handle, "\\Headings:n\ttitle\tnr. of nuclei\tnr. of clusters\tclustered nuclei\tunclustered nuclei\tmean-nn-dist. all\tstdev. all\tmean-nn-dist. unclustered\tstdev unclustered\tmean-nn-dist. clustered\tstdev. clustered");
     line = "0\tmax. dist.="+_MAX_DIST+", min pts.="+_MIN_PTS + ", s="+_SIGMA + ", n=" + _NOISE + ", t=" + _THRESHOLD;
  	 print(handle, line);
  }
  lineNr = 1;
  selectAllNuclei();
  Roi.getCoordinates(xpoints, ypoints);
  run("Select None");
  totalNumberOfNuclei = xpoints.length;
  count = roiManager("count");
  numberOfClusters =  count - 1;
  clusteredNuclei = 0;
  for(i=1; i<count; i++) {
  	roiManager("select", i); 
  	Roi.getCoordinates(xpoints, ypoints);
  	clusteredNuclei = clusteredNuclei + xpoints.length;
  }
  selectAllNuclei();
  nearestNeighbors();
  allMean = getResult("Length", nResults-4);
  allSD = getResult("Length", nResults-3);

  selectAllUnclustered();
  nearestNeighbors();
  unclusteredMean = getResult("Length", nResults-4);
  unclusteredSD = getResult("Length", nResults-3);
  
  selectAllClustered();
  nearestNeighbors();
  clusteredMean = getResult("Length", nResults-4);
  clusteredSD = getResult("Length", nResults-3);

  line = "" + lineNr + "\t" + getTitle() + "\t" + totalNumberOfNuclei + "\t" + numberOfClusters + "\t" + clusteredNuclei + "\t" + (totalNumberOfNuclei-clusteredNuclei) + "\t"; 
  line = line + allMean + "\t" + allSD + "\t" + unclusteredMean + "\t" + unclusteredSD + "\t" + clusteredMean + "\t" + clusteredSD;
  print(handle, line);
}

function randomColorRois(startIndex) {
	count = roiManager("count");
	if (startIndex>=count) return;
	for(i=startIndex; i<count; i++) {
		roiManager("Select", i);
		r = 0 + (255 * random);
		g = 0 + (255 * random);
		b = 0 + (155 * random);
		Roi.setStrokeColor(r,g,b);
		roiManager("update");
	}
	run("Select None");
	roiManager("Show None");
	roiManager("Show All");
}

function nearestNeighbors() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/find_nearest_neighbors.py");
	parameter = "";
	count = roiManager("count");
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	count2 = roiManager("count");
	run("Remove Overlay");
	for (i=count; i<count2; i++) {
		roiManager("select", i);
		Overlay.addSelection;
	}
	
	for (i=count2-1; i>=count; i--) {
		roiManager("select", i);
		roiManager("delete");
	}
	run("Clear Results");
	Overlay.measure
	run("Summarize");
}

function selectAllNuclei() {
	roiManager("select", 0);
	roiManager("deselect");
}

function selectAllClustered() {
	count = roiManager("count");
	if (count<2) return;
	if (count==2) {
		roiManager("select", 1);
		return;
	}
	indices = newArray();
	for(i=1; i<count; i++) {
	 	indices = Array.concat(indices, i);
	}
	roiManager("select", indices);
	roiManager("Combine")
	roiManager("deselect");
}

function selectAllUnclustered() {
	count = roiManager("count");
	if (count==1) {
		roiManager("select", 0);
		return;
	}
	inputImageID = getImageID();
	setBatchMode(true);
	run("Duplicate...", " ");
	tmpImage = getImageID();
	run("Select All");
	setBackgroundColor(0, 0, 0);
	run("Clear", "slice");
	run("Remove Overlay");
	roiManager("select", 0);
	setForegroundColor(255, 255, 255);
	run("Draw", "slice");
	if (count==2) {
		roiManager("select", 1);
	} else {
		indices = newArray();
		for(i=1; i<count; i++) {
		 	indices = Array.concat(indices, i);
		}
		roiManager("select", indices);
		roiManager("Combine")
	}
	roiManager("deselect");
	setForegroundColor(0, 0, 0);
	run("Draw", "slice");
	setForegroundColor(255, 255, 255);
	run("Find Maxima...", "noise=100 output=[Point Selection]");
	selectImage(inputImageID);
	run("Restore Selection");
	selectImage(tmpImage);
	close();
	setBatchMode(false);
}
