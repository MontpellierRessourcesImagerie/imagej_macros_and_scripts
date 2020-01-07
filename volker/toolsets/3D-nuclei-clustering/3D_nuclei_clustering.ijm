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

var _SCALE = 6;
var _RADIUS_XY = 1.50;
var _RADIUS_Z = 1.50;
var _NOISE = 500;
var _EXCLUDE_ON_EDGES = true;
var _RADIUS_SPHERE = 3 	// in scaled units (for exampel µm)
var _LOOKUP_TABLE = "glasbey on dark";
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


function detectNuclei() {
	imageID = getImageID();
	getVoxelSize(width, height, depth, unit);
	run("FeatureJ Laplacian", "compute smoothing="+_SCALE);
	run("Invert", "stack");
	run("3D Maxima Finder", "radiusxy="+_RADIUS_XY+" radiusz="+_RADIUS_Z+" noise="+_NOISE);
	if (_EXCLUDE_ON_EDGES) {
		selectWindow("peaks");
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
			if (zPos>0 && zPos<(nSlices-1)) {
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
		Table.setColumn("X", X);
		Table.setColumn("Y", Y);
		Table.setColumn("Z", Z);
		Table.setColumn("V", V);
	}
	selectWindow("peaks");
	setVoxelSize(width, height, depth, unit);
	run("3D Manager");
	Ext.Manager3D_AddImage();
	selectImage(imageID);
	Ext.Manager3D_Select(1);
	Ext.Manager3D_Select(1);
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
	newImage("clusters-indexed-mask", "16-bit black", width, height, slices);
	setVoxelSize(voxelWidth, voxelHeight, voxelDepth, unit);

	Table.sort("Z");
	X = Table.getColumn("X", nameOfTable);
	Y = Table.getColumn("Y", nameOfTable);
	Z = Table.getColumn("Z", nameOfTable);
	if (nameOfColorColumn != "none") C = Table.getColumn(nameOfColorColumn, nameOfTable);
	Table.sort("C");

	if (nameOfColorColumn != "none") {
		for (i = 0; i < X.length; i++) {
			x = X[i];
			y = Y[i];
			z = Z[i];
			c = C[i];
			r = _RADIUS_SPHERE;
			run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+x+","+y+","+z+" radius="+_RADIUS_SPHERE+","+_RADIUS_SPHERE+",3 vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+unit+" value="+c+" display=Overwrite");
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
}


