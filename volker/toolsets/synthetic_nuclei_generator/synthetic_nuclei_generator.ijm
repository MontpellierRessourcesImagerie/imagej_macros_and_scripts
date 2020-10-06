var _IMG_WIDTH = 1024;
var _IMG_HEIGHT = 1024;
var _NR_OF_IMAGES = 100;
var _NR_OF_NUCLEI_MEAN = 12;
var _NR_OF_NUCLEI_STD = 2;
var _RADIUS_MEAN = 30;
var _RADIUS_STD = 3;
var _RADIUS_NUCLEOLI = 2;
var _DEPTH_NUCLEOLI = 50;
var _MEAN_INTENSITY_NUCLEI = 128;
var _STD_INTENSITY_NUCLEI = 20;
var _BACKGROUND_LEVEL = 80;
var _STD_PHOTON_NOISE = 2;
var _STD_DETECTOR_NOISE = 1;
var _PSF_SIGMA = 2;
var _GRADIENT = 1/200;
var _TYPE = "8-bit";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Synthetic_NUCLEI_GENERATOR";

macro "MRI Synthetic Nuclei Generator (f1) Action Tool - C444L00f0L01f1L0242C555D52C666D62C888D72C999D82C888D92C666Da2C444Lb2c2C333Dd2C444Le2f2L0333C555D43C999D53CbbbD63CcccD73CbbbL83a3C888Db3C555Dc3C444Ld3f3L0434C888D44CdddL5464CeeeD74CdddD84CcccD94CdddDa4CcccDb4C888Dc4C444Ld4e4C333Df4C444L0525C666D35CaaaD45CdddD55CcccD65CdddL7595CcccDa5CdddDb5CbbbDc5C555Dd5C444Le5f5L0626C888D36CbbbD46CdddD56CbbbL6676CcccL86a6CdddDb6CcccDc6C777Dd6C444Le6f6L0727C888D37CdddD47CcccD57CbbbD67CcccL7787CdddL97a7CcccDb7CbbbDc7C777Dd7C444Le7f7L0828C777D38CcccL4858CbbbL6878CdddD88CcccL98a8CbbbDb8C999Dc8C666Dd8C444Le8f8L0929C555D39C999D49CcccD59CdddD69CcccL7989CbbbL99b9C999Dc9C555Dd9C444Le9f9L0a3aC666D4aCbbbD5aCeeeD6aCdddD7aCbbbD8aCcccD9aCdddDaaCaaaDbaC666DcaC444LdafaL0b4bC777D5bCaaaL6b7bC999D8bCbbbD9bCaaaDabC666DbbC444LcbfbL0c5cC555D6cC666L7c9cC555DacC444LbcfcL0dfdL0efeL0fff"{
	help();
}

macro 'MRI Synthetic Nuclei Generator [f1]' {
	help();
}

macro "create image (f2) Action Tool - C000T4b12c" {
	createImage(0, 1);
}

macro "create image [f2]" {
	createImage(0, 1);
}

macro "create image (f2) Action Tool Options" {
	Dialog.create("Synthetic Nuclei Generator Options");
	Dialog.addMessage("image");
	Dialog.addNumber("image width: ", _IMG_WIDTH);
	Dialog.addNumber("image height: ", _IMG_HEIGHT);
	Dialog.addChoice("image type: ", newArray("8-bit", "16-bit", "32-bit", _TYPE));
	Dialog.addMessage("nuclei");
	Dialog.addNumber("mean nr. of nuclei: ", _NR_OF_NUCLEI_MEAN);
	Dialog.addNumber("stdDev nr. of nuclei: ", _NR_OF_NUCLEI_STD);
	Dialog.addNumber("mean radius of nuclei: ", _RADIUS_MEAN);
	Dialog.addNumber("stdDev radius of nuclei: ", _RADIUS_STD);
	Dialog.addNumber("mean intensity of nuclei: ", _MEAN_INTENSITY_NUCLEI);
	Dialog.addNumber("stdDev intensity of nuclei: ", _STD_INTENSITY_NUCLEI);
	Dialog.addNumber("radius of nucleoli", _RADIUS_NUCLEOLI);
	Dialog.addNumber("depth of nucleoli", _DEPTH_NUCLEOLI);
	Dialog.addMessage("noise");
	Dialog.addNumber("stdDev photon noise: ", _STD_PHOTON_NOISE);
	Dialog.addNumber("stdDev detector noise: ", _STD_DETECTOR_NOISE);
	Dialog.addMessage("background and psf");
	Dialog.addNumber("background level: ", _BACKGROUND_LEVEL);
	Dialog.addNumber("gradient: ", _GRADIENT);
	Dialog.addNumber("stdDev psf: ", _PSF_SIGMA);
	Dialog.show();
	_IMG_WIDTH = Dialog.getNumber();
	_IMG_HEIGHT = Dialog.getNumber();
	_TYPE = Dialog.getChoice();
	_NR_OF_NUCLEI_MEAN = Dialog.getNumber();
	_NR_OF_NUCLEI_STD = Dialog.getNumber();
	_RADIUS_MEAN = Dialog.getNumber();
	_RADIUS_STD = Dialog.getNumber();
	_MEAN_INTENSITY_NUCLEI = Dialog.getNumber();
	_STD_INTENSITY_NUCLEI = Dialog.getNumber();
	_RADIUS_NUCLEOLI = Dialog.getNumber();
	_DEPTH_NUCLEOLI = Dialog.getNumber();
	_STD_PHOTON_NOISE = Dialog.getNumber();
	_STD_DETECTOR_NOISE = Dialog.getNumber();
	_BACKGROUND_LEVEL = Dialog.getNumber();
	_GRADIENT = Dialog.getNumber();
	_PSF_SIGMA = Dialog.getNumber();
}

macro "batch create images (f3) Action Tool - C000T4b12b" {
	batchCreateImages(_NR_OF_IMAGES);
}

macro "batch create images (f3) Action Tool Options" {
	Dialog.create("Batch Create Images Options");
	Dialog.addNumber("number of images: ", _NR_OF_IMAGES);
	Dialog.show();
	_NR_OF_IMAGES = Dialog.getNumber();
}

macro 'batch create images [f3]' {
	batchCreateImages(_NR_OF_IMAGES);
}

function batchCreateImages(nr) {
	outFolder = getDirectory("Select the folder for the output images.");
	gtFolder = getDirectory("Select the folder for the ground-truth images.");
	setBatchMode(true);
	for (i = 0; i < nr; i++) {
		showProgress(i, nr-1);
		createImage(i, nr);
		title = getTitle();
		save(gtFolder+"/"+title+".tif");
		close();
		title = getTitle();
		save(outFolder+"/"+title+".tif");
		close();
	}
	setBatchMode(false);
}

function createImage(i, nr) {
	roiManager("reset");
	counter = IJ.pad(i+1, Math.log10(nr+1)+1);
	newImage("nuclei-"+counter, "8-bit black", _IMG_WIDTH, _IMG_HEIGHT, 1);	
	nrOfNuclei = round(random("gaussian")*_NR_OF_NUCLEI_STD + _NR_OF_NUCLEI_MEAN);	
	for (n = 0; n < nrOfNuclei; n++) {
		doesTouch = true;
		while(doesTouch) {
			radius =  round(random("gaussian")*_RADIUS_STD + _RADIUS_MEAN);	
			x = round(random * _IMG_WIDTH);
			y = round(random * _IMG_HEIGHT);
			angle = random * 2 * PI;
			r = random * radius;
			x2 = x + r * cos(angle);
			y2 = y + r * sin(angle);
			radius2 =  round(random("gaussian")*_RADIUS_STD*2 + _RADIUS_MEAN);	
			makeOval(x-radius, y-radius, 2*radius+1, 2*radius+1);
			setKeyDown("shift");
			makeOval(x2-radius2, y2-radius2, 2*radius2+1, 2*radius2+1);
			getStatistics(area, mean);
			if (mean==0) doesTouch = false;
		}
		roiManager("add");
		setKeyDown("none");
		setColor(n+1);
		run("Fill");
		run("Select None");
	}
	setColor(255);
	gtImage = getImageID();
	run("Select None");
	run("Duplicate...", " ");
	setThreshold(1, 255);
	run("Convert to Mask");
	nucleiImage = getImageID();
	rename("nuclei-"+counter);
	selectImage(gtImage);
	rename("gt-"+counter);
	run("16 colors");
	run("Enhance Contrast", "saturated=0.35");
	selectImage(nucleiImage);
	setThreshold(128, 255);
	run("Create Selection");
	run("Salt and Pepper");
	for (d = 0; d < _RADIUS_NUCLEOLI; d++) {
		run("Erode");
	}
	run("Select None");
	resetThreshold;
	selectImage(gtImage);
	setThreshold(1, 255);
	run("Create Selection");
	selectImage(nucleiImage);
	run("Restore Selection");
	run("Add...", "value="+(255-_DEPTH_NUCLEOLI));
	run("Select None");

	run("32-bit");
	run("Grays");
	run("Divide...", "value=255");
	count = roiManager("count");
	for (r = 0; r < count; r++) {
		roiManager("select", r);
		mean = _STD_INTENSITY_NUCLEI*random("gaussian")+_MEAN_INTENSITY_NUCLEI;	
		run("Multiply...", "value="+mean);
	}
	roiManager("deselect");
	roiManager("Combine");
	run("Make Inverse");
	run("Add...", "value="+_BACKGROUND_LEVEL);
	run("Select None");

	run("Add Specified Noise...", "standard="+_STD_PHOTON_NOISE);
	run("Gaussian Blur...", "sigma="+_PSF_SIGMA);
	run("Add Specified Noise...", "standard="+_STD_DETECTOR_NOISE);

	factor = 2*random;
	if(random>=0.5) {
		factorX = factor;
		factorY = 1/factor;
	} else {
		factorX = 1/factor;
		factorY = factor;
	}
	run("Macro...", "code=v=v+(("+factorX+"*x+"+factorY+"*y)*"+_GRADIENT+")");
	intRand = round(random()*3);
	for(r=0; r<intRand; r++) {
		run("Rotate 90 Degrees Right");
	}
	run(_TYPE);
	selectImage(gtImage);
	for(r=0; r<intRand; r++) {
		run("Rotate 90 Degrees Right");
	}
	roiManager("reset");
	run("Select None");
	print("nuclei-"+counter, nrOfNuclei);
}

