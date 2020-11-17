/*
 # MRI Count Satellites Tool

 Detect and count the neurons and the neurons with satellite cells.
 The first channel is supposed to contain a staining of the neurons 
 and the second channel a staining of all nuclei (neurons and satellite cells).

 The '3D ImageJ Suite', available as an update-site needs to be installed.
 
 (c) 2020, INSERM

 written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 */

var MIN_DIST = 25;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count_Satellites_Tool";
var THRESHOLDING_METHODS = getList("threshold.methods");
var NUCLEI_THRESHOLDING_METHOD = "Triangle";
var NEURON_THRESHOLDING_METHOD = "Triangle";
var NR_OF_EROSIONS = 2;
var MIN_SIZE = 10;
var MAX_SIZE = 32320800;
var ROI_STYLE_NEURON = "large cyan circle";
var ROI_STYLE_SATELLITE = "large magenta hybrid";

countSatellites();
exit();

macro "Count Satellites Tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "Count Satellites Tool help (f4) Action Tool - C030L0060C020D70C030L8090C040La0b0C030Lc0f0L0121C020D31C030L4151C020L6171C030L81b1C040Lc1f1C030L0262C020D72C030L82b2C040Lc2d2C050Le2f2C040D03C050L1323C040L3383C030L93d3C040De3C050Df3C040D04C082D14C060L2454C061L6474C060D84C040D94C030Da4C032Lb4c4C030Dd4C040Le4f4D05C060L1525C082L3565C096L7585C061D95C032Da5C05cDb5C047Lc5d5C030Le5f5D06C050L1626C082L3646C096L5666C05cD76C096D86C064D96C032Da6C05cDb6C047Dc6C03bDd6C047De6C030Df6D07C040D17C061D27C082L3757C05cL6777C096D87C064L97a7C03bLb7c7C03dDd7C05cDe7C032Df7C020D08C030D18C050D28C082D38C064D48C082D58C096D68C05cD78C096L8898C047Da8C03dDb8C05cLc8d8C03dDe8C032Df8C020L0919C040D29C060D39C096D49C05cD59C096D69C082D79C096D89C064D99C05cDa9C03dLb9d9C03bDe9C032Df9C030L0a3aC032D4aC096L5a8aC047D9aC05cLaabaC03dDcaC05cDdaC047DeaC030DfaL0b1bC040D2bC030L3b4bC040D5bC061L6b7bC064D8bC032D9bC03bLabbbC05cLcbdbC032DebC030DfbD0cC020D1cC030D2cC020D3cC030L4c7cC040D8cC030D9cC064DacC03bDbcC03dDccC047DdcC032DecC030DfcD0dC020D1dC030D2dC020D3dC030L4dadC032LbdddC020DedC030DfdL0e6eC020D7eC030L8e9eC020DaeC030LbeceC020DdeC030LeefeL0f9fC020LafbfC030Lcfff" {
	run('URL...', 'url='+helpURL);
}

macro "count satellites in the current image (f2) Action Tool - C000T4b12c" {
	countSatellites();
}

macro "count satellites in the current image [f2]" {
	countSatellites();
}

macro "count satellites in the current image (f2) Action Tool Options" {
	Dialog.create("Count Satellites Tool Options");
	Dialog.addMessage("---Nuclei detection---");
	Dialog.addChoice("nuclei thresholding method: ", THRESHOLDING_METHODS, NUCLEI_THRESHOLDING_METHOD); 
	Dialog.addNumber("nr. of erosions: ", NR_OF_EROSIONS);
	Dialog.addNumber("min. size: ", MIN_SIZE, 0, 10, "");
	Dialog.addNumber("max. size: ", MAX_SIZE, 0, 10, "");
	Dialog.addMessage("---Neuron detection---");
	Dialog.addChoice("neuron thresholding method: ", THRESHOLDING_METHODS, NEURON_THRESHOLDING_METHOD); 
	Dialog.addMessage("---Visualization---");
	Dialog.addString("marker style neuron", ROI_STYLE_NEURON,25);
	Dialog.addString("marker style satellite", ROI_STYLE_SATELLITE,25);
	Dialog.show();
	NUCLEI_THRESHOLDING_METHOD = Dialog.getChoice();
	NR_OF_EROSIONS = Dialog.getNumber();
	MIN_SIZE = Dialog.getNumber();
	MAX_SIZE = Dialog.getNumber();
	NEURON_THRESHOLDING_METHOD = Dialog.getChoice();
	ROI_STYLE_NEURON = Dialog.getString();
	ROI_STYLE_SATELLITE = Dialog.getString();
}

function countSatellites() {
	print("Count Satellites started !");
	region = "None";
	if (selectionType()>=0) {
		 getSelectionBounds(selX, selY, selWidth, selHeight);
		 region = "x="+selX+", y="+selY+", w="+selWidth+", h="+selHeight;
		 run("Duplicate...", "duplicate");
	}
	if (!isOpen("satellites")) Table.create("satellites");
	if (!isOpen("satellite count")) Table.create("satellite count");
	setBatchMode(true);
	getVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
	Stack.getDimensions(width, height, channels, slices, frames);
	inputID = getImageID();
	inputTitle = getTitle();
	
	preprocessImage();
	cleanTitle = getTitle();
	detectNuclei();
	X = Table.getColumn("X");
	Y = Table.getColumn("Y");
	Z = Table.getColumn("Z");
	bWidth = Table.getColumn("B-width");
	bHeight = Table.getColumn("B-height");
	bDepth = Table.getColumn("B-depth");
	distances = Table.getColumn("Mean dist. to surf. (micron)");
	volumes = Table.getColumn("Volume (micron^3)");
	
	XS = newArray(X.length);
	YS = newArray(X.length);
	ZS = newArray(X.length);
	I = Array.getSequence(X.length);
	for (i = 0; i < X.length; i++) {
		I[i] = I[i] + 1;
	}
	Table.setColumn("id", I);
	selectImage(inputID);
	for (i = 0; i < X.length; i++) {
		XS[i] = X[i];
		YS[i] = Y[i];
		ZS[i] = Z[i];
		toScaled(XS[i], YS[i], ZS[i]);
	}
	selectImage("C1-"+cleanTitle);
	run("Convert to Mask", "method="+NEURON_THRESHOLDING_METHOD+" background=Dark calculate");
	neuronIDS = newArray(0);
	satelliteIDS = newArray(0);
	for (i = 0; i < X.length; i++) {
		setSlice(round(Z[i]));
		val = getPixel(round(X[i]), round(Y[i]));
		if (val>0) {
			neuronIDS = Array.concat(neuronIDS, i);
		} else {
			satelliteIDS = Array.concat(satelliteIDS, i);
		}
	}
	
	selectImage(inputID);
	markDetections(neuronIDS, satelliteIDS);
	Overlay.copy;
	
	newImage("satellites", "16-bit black", width, height, slices);
	satellitesImageID = getImageID();
	satelliteImageTitle = getTitle();
	setVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
	color=1;
	
	numberOfSatellites = 0;
	numberOfNeurons = neuronIDS.length;
	for (i = 0; i < satelliteIDS.length; i++) {
		minIndexJ = -1;
		minDistance = 9999999;
		xi = X[satelliteIDS[i]];
		yi = Y[satelliteIDS[i]];
		zi = Z[satelliteIDS[i]];
		for (j = 0; j < neuronIDS.length; j++) {
			xj = X[neuronIDS[j]];
			yj = Y[neuronIDS[j]];
			zj = Z[neuronIDS[j]];
			dX = xi - xj;
			dY = yi - yj;
			dZ = zi - zj;
			dist = sqrt(dX*dX+dY*dY+dZ*dZ);
			if (dist<minDistance) {
				minDistance = dist;
				minIndexJ = j;
			}
		}
		if (minDistance<=MIN_DIST) {
			numberOfSatellites++;
			row = Table.size("satellites");
			Table.set("nr.", row, (row+1),  "satellites");
			Table.set("neuron", row, minIndexJ+1, "satellites");
			Table.set("nx", row, XS[neuronIDS[minIndexJ]], "satellites");
			Table.set("ny", row, YS[neuronIDS[minIndexJ]], "satellites");
			Table.set("nz", row, ZS[neuronIDS[minIndexJ]], "satellites");
			Table.set("satellite", row, neuronIDS.length+i+1, "satellites");
			Table.set("sx", row, XS[satelliteIDS[i]], "satellites");
			Table.set("sy", row, YS[satelliteIDS[i]], "satellites");
			Table.set("sz", row, ZS[satelliteIDS[i]], "satellites");
			Table.set("distance", row, minDistance, "satellites");
			Table.set("volume", row, volumes[satelliteIDS[i]], "satellites");
			Table.set("color", row, color, "satellites");
			vectors = getVectors(bWidth[satelliteIDS[i]], bHeight[satelliteIDS[i]], bDepth[satelliteIDS[i]], distances[satelliteIDS[i]]);
			Array.print(vectors);
			params = "size="+width+","+height+","+slices+" center="+XS[satelliteIDS[i]]+","+YS[satelliteIDS[i]]+","+ZS[satelliteIDS[i]]+" radius="+vectors[0]+","+vectors[1]+","+vectors[2]+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+voxelUnit+" value="+color+" display=Overwrite";
			run("3D Draw Shape", params);
			vectors = getVectors(bWidth[neuronIDS[minIndexJ]], bHeight[neuronIDS[minIndexJ]], bDepth[neuronIDS[minIndexJ]], distances[neuronIDS[minIndexJ]]);
			run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+XS[neuronIDS[minIndexJ]]+","+YS[neuronIDS[minIndexJ]]+","+ZS[neuronIDS[minIndexJ]]+" radius="+vectors[0]+","+vectors[1]+","+vectors[2]+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+voxelUnit+" value="+color+" display=Overwrite");
			color++;
		}
	}
	Table.update("satellites");
	row = Table.size("satellite count");
	Table.set("nr.", row, (row+1), "satellite count");
	Table.set("image", row, inputTitle, "satellite count");
	Table.set("region", row, region, "satellite count");
	Table.set("neurons", row, numberOfNeurons, "satellite count");
	Table.set("satellites", row, numberOfSatellites, "satellite count");
	
	run("glasbey on dark");
	selectImage(inputID);
	run("Split Channels");
	run("Merge Channels...", "c1=[C1-"+inputTitle+"] c2=[C2-"+inputTitle+"] c4=["+satelliteImageTitle+"] create");
	Overlay.paste;
	
	close("C1-*");
	close("C2-*");
	close("Centroids*");
	close("Objects*");
	
	print("Count Satellites finished !");
	setBatchMode(false);
}

function preprocessImage() {
	run("Duplicate...", "duplicate");
	blurredID = getImageID();
	blurredTitle = getTitle();
	run("Gaussian Blur...", "sigma=25 stack");
	imageCalculator("Subtract create stack", inputTitle, blurredTitle);
	cleanID = getImageID();
	selectImage(blurredID);
	close();
	run("Gaussian Blur 3D...", "x=3 y=3 z=3");
}

function detectNuclei() {
	run("Split Channels");
	run("Convert to Mask", "method="+NUCLEI_THRESHOLDING_METHOD+" background=Dark calculate");
	run("Watershed", "stack");
	run("Distance Transform Watershed 3D", "distances=[Quasi-Euclidean (1,1.41,1.73)] output=[16 bits] normalize dynamic=2 connectivity=6");
	run("glasbey on dark");
	run("Macro...", "code=v=(v>0)*65535 stack");
	run("8-bit");
	for (i = 0; i < NR_OF_EROSIONS; i++) {
		run("Erode (3D)", "iso=255");	
	}
	run("3D Objects Counter", "threshold=1 slice=25 min.="+MIN_SIZE+" max.="+MAX_SIZE+" exclude_objects_on_edges objects centroids statistics summary");
}

function markDetections(neuronIDS, satelliteIDS) {
	Overlay.remove
	for (i = 0; i < neuronIDS.length; i++) {
		x = X[neuronIDS[i]];
		y = Y[neuronIDS[i]];
		z = Z[neuronIDS[i]];
		makePoint(round(x), round(y), ROI_STYLE_NEURON);
		Overlay.addSelection;
		Overlay.setPosition(0, round(z), 0)
	}
	for (i = 0; i < satelliteIDS.length; i++) {
		x = X[satelliteIDS[i]];
		y = Y[satelliteIDS[i]];
		z = Z[satelliteIDS[i]];
		makePoint(round(x), round(y), ROI_STYLE_SATELLITE);
		Overlay.addSelection;
		Overlay.setPosition(0, round(z), 0)
	}
}

function getVectors(bWidth, bHeight, bDepth, distance) {
		relVecX = bWidth;
		relVecY = bHeight;
		relVecZ = bDepth;
		
		max = maxOf(relVecX, relVecY);
		max = maxOf(max, relVecZ);
		
		relVecX /= max;
		relVecY /= max;
		relVecZ /= max; 
		
		dist = distance;
		distX = dist * relVecX;
		distY = dist * relVecY;
		distZ = dist * relVecZ;
		res = newArray(distX, distY, distZ);
		return res;
}
