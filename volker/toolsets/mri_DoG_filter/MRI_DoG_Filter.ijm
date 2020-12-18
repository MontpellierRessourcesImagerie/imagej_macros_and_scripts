var _SIGMA_SMALL = 3.2
var _SIGMA_LARGE = 50
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_DoG_Filter";

macro "MRI DoG Filter Action Tool - C037T0b11DT9b10oTfb10G" {
	applyDoGAndAdjustDisplay(_SIGMA_SMALL, _SIGMA_LARGE);
}

macro "MRI DoG Filter Action Tool Options" {
	Dialog.create("MRI DoG Options");
	Dialog.addNumber("smaller sigma", _SIGMA_SMALL);
	Dialog.addNumber("bigger sigma", _SIGMA_LARGE);
	Dialog.addHelp(helpURL);
	Dialog.show();
	_SIGMA_SMALL = Dialog.getNumber();
	_SIGMA_LARGE = Dialog.getNumber();
}

function applyDoGAndAdjustDisplay(sigmaSmall, sigmaLarge) {
	setBatchMode(true);
	DoG(_SIGMA_SMALL, _SIGMA_LARGE);
	adjustDisplay();
	setBatchMode(false);
}

function adjustDisplay() {
	Stack.getDimensions(width, height, channels, slices, frames);
	if (channels>1) {
		for (i = 0; i < channels; i++) {
			Stack.setChannel(i+1);
			resetMinAndMax();
			run("Enhance Contrast", "saturated=0.35");
		}
	} else {
		run("Enhance Contrast", "saturated=0.35");
	}
}

function DoG(sigmaSmall, sigmaBig) {
	run("Duplicate...", "title=A duplicate");
	run("Duplicate...", "title=B duplicate");
	run("Gaussian Blur...", "sigma="+sigmaBig+" stack");
	selectWindow("A");
	run("Gaussian Blur...", "sigma="+sigmaSmall+" stack");
	imageCalculator("Subtract create stack", "A","B");
	selectWindow("Result of A");
	selectWindow("A");
	close();
	selectWindow("B");
	close();
}
