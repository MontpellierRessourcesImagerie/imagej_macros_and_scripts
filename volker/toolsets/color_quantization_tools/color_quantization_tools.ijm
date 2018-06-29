/** 
 * Quantize the colors of an image to identify different clones using Brainbow like cell-labeling techniques.
 * 
 * (c) 2018, INSERM
 * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 * 
 */

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/MRI_Color_Quantization_Tools";
var _NUMBER_OF_COLORS = 16;
var _COLOR_SPACE = "HSB";
var _COLOR_SPACES = newArray("RGB", "YUV", "YCbCr", "YIQ", "HSB", "HSV", "HSL", "HMMD", "Lab", "Luv", "xyY", "XYZ", "KLT/PCA", "HCL");
var _METHOD = "Wu";
var _METHODS = newArray("Histogram", "Median Cut", "Wu");
var _USE_FULL_RANGE = true;

macro "MRI Color Quantization Tools Help Action Tool - C000D06D07D0bD0cD0dD0eD0fD1bD1cD1dD1eD1fD2dD2eD2fD3dDceDcfDddDdeDdfDedDeeDefDfdDfeDffC212D27D28D36D4fD5fD60D6fD90Da0DaaDb0Dc1Dd8De9DeaDfaC011D01D12D23D2aD5eDbeDccDd1Dd2De6Df3Df4Df5Df8C365D30D40D7dD7eD82D83D8dD8eD92D93D94D9cD9dD9eDa2Db7Db8C001D02D13D16D24D25D3eD4eDbfDd3DdcDe3De4De7DecDf6Df7DfcC433D38D39D3aD46D4bD50D5cD6cD71D81D91Da1Da4Da9Dc5Dc6C121D00D34D4cDafDbaDbbDbcDc2DcbDd6Dd7DdbDebDfbC6a9D51D63D64D74D75D76D7cD85D8cD95Da5Da6Da7Da8Db5Db6C000D03D04D05D08D09D0aD14D15D1aD2cDcdDd4De2Df1Df2C233D56D6dD7fD8fDa3DabDacDadDaeDb1Db2Db3Db4Dc7Dc8Dd9C111D26D29D35D3bD3fD5dD70D80DbdDc0Dc3Dc4Dd0Dd5Df9C4a7D20D31D41D42D52D53D54D55D61D62D65D66D72D73D84C011D17D18D19D2bD3cD4dDe0De1De5De8Df0Ca43D37D47D48D49D4aD57D58D59D5aD5bD68D6aD6bD99D9aD9bC142D10D11D21D22D32D33D43D44D45D6eD9fDb9Dc9DcaDdaCc86D67D69D77D78D79D7aD7bD86D87D88D89D8aD8bD96D97D98"{
    run('URL...', 'url='+helpURL);
}

macro "MRI Color Quantization Tools Help Action Tool Options"{
     Dialog.create("Color Quantization Tools Options");
	 Dialog.addNumber("Number of Colors: ", _NUMBER_OF_COLORS);
	 Dialog.addChoice("Color Space: ", _COLOR_SPACES, _COLOR_SPACE);
	 Dialog.addChoice("Method: ", _METHODS, _METHOD);
	 Dialog.addCheckbox("Use full range: ", _USE_FULL_RANGE);
	 Dialog.show();
	 _NUMBER_OF_COLORS = Dialog.getNumber();
	 _COLOR_SPACE = Dialog.getChoice();
	 _METHOD = Dialog.getChoice();
	 _USE_FULL_RANGE = Dialog.getCheckbox();
}

macro 'Quantize Colors [f1]'  {
	quantizeColors();
}

macro 'Quantize Colors Action Tool (f1) - C000T4b12q' {
	quantizeColors();
}

function quantizeColors() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/color_quantization_tools.py");
	colorSpaceNr = getIndex(_COLOR_SPACES, _COLOR_SPACE);
	parameter = "numberOfColors=" + _NUMBER_OF_COLORS +", colorSpace="+colorSpaceNr+", method=" + _METHOD;
	max = 65535;
	if (bitDepth()==8) max = 255;
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i=1; i<=channels; i++) {
		Stack.setChannel(i)
		if (_USE_FULL_RANGE) setPixel(0,0,max);
		resetMinAndMax();
	}
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
	if (_NUMBER_OF_COLORS<256) run("8-bit Color", "number="+_NUMBER_OF_COLORS);
	getLut(reds, greens, blues);
	run("Grays");
	run("8-bit");
	reds = completeLUT(reds);
	greens = completeLUT(greens);
	blues = completeLUT(blues);
	setLut(reds, greens, blues);
}

function getIndex(array, value) {
	for (i=0; i<array.length; i++) {
		if (array[i]==value) return i;
	}
	return -1;
}

function completeLUT(array) {
	for (i=array.length; i<256; i++) {
		array = Array.concat(array, 0);
	}
	return array;
}

function indicesToStack() { 
	
}
