var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Qualify_DAB_Tools ";
var _ORDER_X = 2;
var _ORDER_Y = 2;
var _ORDER_MIXED = 1;
var _R1 = 0.250;
var _G1 = 0.500;
var _B1 = 0.850;
var _R2 = 0.0;
var _G2 = 0.0;
var _B2 = 0.0;
var _R3 = 0.0;
var _G3 = 0.0;
var _B3 = 0.0;
var _THRESHOLDING_METHOD_SHADING = "Yen";
var _THRESHOLDING_METHODS = getList("threshold.methods");

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

macro "correct shading (f9) Action Tool Options" {
	 Dialog.create("Correct Shading Options");
	 Dialog.addNumber("order x", _ORDER_X);
	 Dialog.addNumber("order y", _ORDER_Y);
	 Dialog.addNumber("order mixed", _ORDER_MIXED);
	 Dialog.addChoice("thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD_SHADING);
 	 Dialog.show();
 	 _ORDER_X = Dialog.getNumber();
 	 _ORDER_Y = Dialog.getNumber();
 	 _ORDER_MIXED = Dialog.getNumber();
 	 _THRESHOLDING_METHOD_SHADING = Dialog.getChoice();
}

macro "colour deconvolution [f10]" {
	colourDeconvolution();
}

macro "colour deconvolution (f10) Action Tool - C000T4b12c" {
	colourDeconvolution();
}

macro "colour deconvolution (f10) Action Tool Options" {
	 Dialog.create("Colour Deconvolution Options");
	 Dialog.addNumber("R1", _R1);
	 Dialog.addNumber("G1", _G1);
	 Dialog.addNumber("B1", _B1);
	 Dialog.addNumber("R2", _R2);
	 Dialog.addNumber("G2", _G2);
	 Dialog.addNumber("B2", _B2);
	 Dialog.addNumber("R3", _R3);
	 Dialog.addNumber("G3", _G3);
	 Dialog.addNumber("B3", _B3);
 	 Dialog.show();
 	 _R1 = Diaolog.getNumber();
 	 _G1 = Diaolog.getNumber();
 	 _B1 = Diaolog.getNumber();
 	 _R2 = Diaolog.getNumber();
 	 _G2 = Diaolog.getNumber();
 	 _B2 = Diaolog.getNumber();
 	 _R1 = Diaolog.getNumber();
 	 _G2 = Diaolog.getNumber();
 	 _B3 = Diaolog.getNumber();
}

function openFile() {
	path = File.openDialog("Select an NDPI-tiff file");
	run("Open TIFF...", "ndpitools=["+path+"]");
}

function shadingCorrection() {
	imageID = getImageID();
	run("Duplicate...", " ");
	run("8-bit");
	setAutoThreshold(_THRESHOLDING_METHOD_SHADING + " dark");
	run("Create Selection");
	close()
	selectImage(imageID);
	run("Restore Selection");
	run("Fit Polynomial", "x="+_ORDER_X+" y="+_ORDER_Y+" mixed="+_ORDER_MIXED);
	run("Select None");
}

function colourDeconvolution() {
	run("Colour Deconvolution", "vectors=[User values] [r1]="+_R1+" [g1]="+_G1+" [b1]="+_B1+" [r2]="+_R2+" [g2]="+_G2+" [b2]="+_B2+" [r3]="+_R3+" [g3]="+_G3+" [b3]="+B3);
}
