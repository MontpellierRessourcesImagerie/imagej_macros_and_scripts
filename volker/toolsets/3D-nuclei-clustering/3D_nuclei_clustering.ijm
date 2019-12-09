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
		// delete rows where Z=0 or MAx
		X= newArray(0);
		Y= newArray(0);
		Z= newArray(0);
		V= newArray(0);
		
		for(row=0; row<nResults; row++) {
			zPos = getResult("Z", row);
			if (zPos>0 && zPos<(nSlices-1)) {
				xPos = getResult("X", row);
				yPos = getResult("Y", row);
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
	run("3D Manager");
	Ext.Manager3D_AddImage();
	selectImage(imageID);
	Ext.Manager3D_Select(1);
	Ext.Manager3D_Select(1);
}

// run("Bio-Formats", "open=/media/baecker/DONNEES/mri/in/Azam/clustering/Mixed-mChesiEp50%-mYFPsiCtrl50%_CONF_1CAM_561-620_CONF_1CAM_488-525_CONF_1CAM_405-450_1_FusionStitcher.ims color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_2");

// imageID = getImageID();
// run("Duplicate...", "duplicate channels=3");
// blueChannelImageID = getImageID();
// selectImage(imageID);
// close();

