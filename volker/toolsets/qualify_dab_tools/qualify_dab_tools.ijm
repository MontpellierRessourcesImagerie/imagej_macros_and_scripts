var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Qualify_DAB_Tools ";
var _ORDER_X = 2;
var _ORDER_Y = 2;
var _ORDER_MIXED = 1;

macro "MRI QualifyDAB Tools Help Action Tool - C000T4b12?"{
    run('URL...', 'url='+helpURL);
}


macro "open ndpi-tiff image [f8]" {
  openFile();
}

macro "open ndpi tiff image (f8) Action Tool - C000T4b12o"{
    openFile();
}

macro "correct shading [f9]" {
	shadingCorrection();
}

macro"correct shading (f9) Action Tool - C000T4b12s" {
	 shadingCorrection();
}

function openFile() {
	path = File.openDialog("Select an NDPI-tiff file");
	run("Open TIFF...", "ndpitools=["+path+"]");
}

function shadingCorrection() {
	imageID = getImageID();
	run("Duplicate...", " ");
	run("8-bit");
	setAutoThreshold("Yen dark");
	run("Create Selection");
	close()
	selectImage(imageID);
	run("Restore Selection");
	run("Fit Polynomial", "x="+_ORDER_X+" y="+_ORDER_Y+" mixed="+_ORDER_MIXED);
	run("Select None");
}
