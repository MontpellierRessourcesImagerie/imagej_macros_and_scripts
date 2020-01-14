/***
 * 
 * MRI 3D nuclei clustering
 * 
 * Detect nuclei in 3D images and run a cluster analysis on them
 * 
 * (c) 2019, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
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

// parameters for filtering the nuclei according to the signal in another channel
var _SIGNAL_CHANNEL = 1;
var _RADIUS_MEASUREMENT = 1;
var _THRESHOLD = 700;

// parameters for the clustering of the nuclei
var _MAX_DIST = 18;
var _MIN_PTS = 5;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/3D_Nuclei_Clustering_Tool";

exit();

macro "3D nuclei clustering tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "3D nuclei clustering tool help (f4) Action Tool - Cf00L0010Le0f0L0111C555D51C666L6181C444D91Cf00Ld1e1L0212C555D32C999D42CaaaL5282C999D92C777Da2Cf00Lc2d2L0313C555D23C999D33CbbbD43CcccL5383CbbbD93CaaaDa3C666Lb3c3Cf00L0414C999D24CbbbD34CcccD44CdddL5494CcccDa4CbbbDb4C666Dc4Cf00L0515CaaaD25CcccD35CdddD45CfffL5585CdddL95a5CbbbDb5C777Dc5Cf00L0616CaaaD26CcccD36CdddD46CfffL5696CdddDa6CbbbDb6C999Dc6Cf00L0717CaaaD27CcccD37CdddD47CfffL5797CdddDa7CbbbDb7C999Dc7C111Dd7Cf00L0818CaaaD28CcccD38CdddD48CfffL5898CdddDa8CbbbDb8C999Dc8Cf00L0919C999D29CbbbD39CdddL4959CfffL6989CdddD99CcccDa9CbbbDb9C777Dc9Cf00L0a1aC777D2aCaaaD3aCcccD4aCdddL5a8aCcccD9aCbbbDaaC999DbaC444DcaCf00L0b1bC666D3bCbbbL4b9bC999DabC666DbbCf00L0c2cC666L3c4cC777D5cC999L6c8cC777D9cC444DacCf00L0d2dC111D7dCf00L0efeL0fff"{
	run('URL...', 'url='+helpURL);
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
	Dialog.addCheckbox("create results channel ", _CREATE_RESULTS_CHANNEL);
	Dialog.show();
	_SCALE = Dialog.getNumber();
	_RADIUS_XY = Dialog.getNumber();
	_RADIUS_Z = Dialog.getNumber();
	_NOISE = Dialog.getNumber();
	_EXCLUDE_ON_EDGES = Dialog.getCheckbox();
	_CREATE_RESULTS_CHANNEL = Dialog.getCheckbox();
}

macro "filter above threshold (f6) Action Tool - C000T4b12f" {
	filterAboveThreshold();
}

macro "filter above threshold (f6) Action Tool Options" {
	Dialog.create("Filter nuclei options");
	Dialog.addNumber("signal channel: ", _SIGNAL_CHANNEL);
	Dialog.addNumber("radius: ", _RADIUS_MEASUREMENT);
	Dialog.addNumber("threshold: ", _THRESHOLD);
	Dialog.show();
	_SIGNAL_CHANNEL = Dialog.getNumber();
	_RADIUS_MEASUREMENT = Dialog.getNumber();
	_THRESHOLD = Dialog.getNumber();
}

macro "cluster nuclei (f7) Action Tool - C000T4b12c" {
	clusterNuclei(_MAX_DIST, _MIN_PTS);
}

function detectNuclei() {
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
			zPos = getResult("Z", row) * depth;
			if (zPos>0 && zPos<(nSlices-1)*depth) {
				xPos = getResult("X", row) * width;
				yPos = getResult("Y", row) * height;
				vObj = getResult("V", row);
				Z = Array.concat(Z, zPos);
				X = Array.concat(X, xPos);
				Y = Array.concat(Y, yPos);
				V = Array.concat(V, vObj);
			}
		}
		run("Clear Results");
		Table.create("Results");
		Table.setColumn("X", X, "Results");
		Table.setColumn("Y", Y, "Results");
		Table.setColumn("Z", Z, "Results");
		Table.setColumn("V", V, "Results");
	}
	Table.applyMacro("NR=row+1 ", "Results");
	selectWindow("peaks");
	setVoxelSize(width, height, depth, unit);
	run("3D Manager");
	Ext.Manager3D_AddImage();
	selectImage(imageID);
	Ext.Manager3D_Select(1);
	Ext.Manager3D_Select(1);

	if (_CREATE_RESULTS_CHANNEL) {
		drawNuclei();
		selectImage(inputStackID);
		run("Split Channels");
		run("Merge Channels...", "c1=[C1-"+inputStackTitle+"] c2=[C2-"+inputStackTitle+"] c3=[C3-"+inputStackTitle+"] c4=[Results-indexed-mask] create ");
	}

	selectImage(filteredID);
	close();
	selectImage(peaksID);
	close();
	selectImage(imageID);
	close();
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
	Table.sort("Z");
	X = Table.getColumn("X", nameOfTable);
	Y = Table.getColumn("Y", nameOfTable);
	Z = Table.getColumn("Z", nameOfTable);
	if (nameOfColorColumn != "none"){
		C = Table.getColumn(nameOfColorColumn, nameOfTable);
		Table.sort(nameOfColorColumn);
	}
	if (nameOfColorColumn != "none") {
		for (i = 0; i < X.length; i++) {
			x = X[i];
			y = Y[i];
			z = Z[i];
			c = C[i];
			r = _RADIUS_SPHERE;
			run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+x+","+y+","+z+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+",3 vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
		}
	} else {
		for (i = 0; i < X.length; i++) {
			x = X[i];
			y = Y[i];
			z = Z[i];
			c = 1;
			r = _RADIUS_SPHERE;
			run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+x+","+y+","+z+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+",3 vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
		}
	}
	run(_LOOKUP_TABLE);
	Table.sort("NR");
}

function filterAboveThreshold() {
	inputStackID = getImageID();
	inputStackTitle = getTitle();
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);
	measureIntensityInOtherChannel();	
	X = Table.getColumn("X");
	Y = Table.getColumn("Y");
	Z = Table.getColumn("Slice");
	for (i = 0; i < Z.length; i++) {
		Z[i] = Z[i] * voxelDepth;
	}
	M = Table.getColumn("Mean");
	XN = newArray(0);
	YN = newArray(0);
	ZN = newArray(0);
	MN = newArray(0);
	for (i = 0; i < X.length; i++) {
		if (M[i]>=_THRESHOLD) {
			XN = Array.concat(XN, X[i]);
			YN = Array.concat(YN, Y[i]);
			ZN = Array.concat(ZN, Z[i]);
			MN = Array.concat(MN, M[i]);
		}
	}	
	run("Clear Results");
	Table.create("Results");
	Table.setColumn("X", XN);
	Table.setColumn("Y", YN);
	Table.setColumn("Z", ZN);
	Table.setColumn("Mean", MN);
	Table.applyMacro("NR=row+1 ", "Results");

	
	if (_CREATE_RESULTS_CHANNEL) {
		drawNuclei();
		selectImage(inputStackID);
		run("To ROI Manager");
		run("Split Channels");
		run("Merge Channels...", "c1=[C1-"+inputStackTitle+"] c2=[C2-"+inputStackTitle+"] c3=[C3-"+inputStackTitle+"] c4=[Results-indexed-mask] create ");
		run("From ROI Manager");
	}
}

function measureIntensityInOtherChannel() {
	X = Table.getColumn("X", "Results");
	Y = Table.getColumn("Y", "Results");
	Z = Table.getColumn("Z", "Results");
	Table.sort("Z");
	Overlay.remove;
	for (i = 0; i < X.length; i++) {
		x = X[i];
		y = Y[i];
		z = Z[i];
		toUnscaled(x, y, z);
		Stack.setSlice(z);
		makeOval(x-_RADIUS_MEASUREMENT, y-_RADIUS_MEASUREMENT, 2*_RADIUS_MEASUREMENT+1, 2*_RADIUS_MEASUREMENT+1);
		Overlay.addSelection;
		Overlay.setPosition(_SIGNAL_CHANNEL, z, 1);
	}
	run("Set Measurements...", "mean modal min centroid center integrated stack display redirect=None decimal=9");
	run("Clear Results");
	size = Overlay.size;
	for (i = 0; i < size; i++) {
		Overlay.activateSelection(i);
		run("Measure");
	}
	Overlay.show;
}

function clusterNuclei(maxDist, minPts) {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/dbscan_clustering_3D.py");
	parameter = "maxDist="+maxDist+",minPts="+minPts;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	drawClusters();
}
