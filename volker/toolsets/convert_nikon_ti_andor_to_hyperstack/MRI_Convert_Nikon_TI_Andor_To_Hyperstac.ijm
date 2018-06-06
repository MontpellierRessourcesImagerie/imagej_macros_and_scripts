/** 
 * Convert images taken with the SPINNING DISC NIKON TI ANDOR CSU-X1 into hyperstacks. 
 * When the image is too big the time-points are broken down into multiple chunks. Concatenate
 * the z-projections of the different chunks and save one file per date/position/wavelength.
 *
 * 20180528-_f0000_t0000_w0000.tif
 *
 * where f is the position, t the time and w the channel
 * 
 * (c) 2018, INSERM
 * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 * 
 */

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/MRI_Convert_Nikon_Andor_To_Hyperstack";
var _OUTPUT_FOLDER = "stacks";
var _ZSLICES = 31;
var _PIXEL_SIZE = 0;
var _PIXEL_UNIT = "nm";
var _TIME_INTERVAL = 0;
var _TIME_UNIT = "sec";

macro "convert Nikon_TI_Andor [f9]" {
  convertNikonTIAndor();
}

macro "convert Nikon_TI_Andor (f9) Action Tool - C037T1d13cT9d13nC555"{
  convertNikonTIAndor();
}

macro "convert Nikon_TI_Andor (f9) Action Tool Options" {
	 Dialog.create("Convert Nikon_TI_Andor Options");
	 Dialog.addNumber("z-slices: ", _ZSLICES);
	 Dialog.addString("output folder: ", _OUTPUT_FOLDER);
	 Dialog.addNumber("pixel size (0 to skip): " , _PIXEL_SIZE);
	 Dialog.addString("pixel unit: ", _PIXEL_UNIT);
	 Dialog.addNumber("time-interval (0 to skip): " , _TIME_INTERVAL);
	 Dialog.addString("time unit: ", _TIME_UNIT);
	 Dialog.addMessage("Press the help button below to open the online help!");
	 Dialog.addHelp(helpURL);
 	 Dialog.show();
 	 _ZSLICES = Dialog.getNumber();
 	 _OUTPUT_FOLDER = Dialog.getString();
 	 _PIXEL_SIZE = Dialog.getNumber();
 	 _PIXEL_UNIT = Dialog.getString();
 	 _TIME_INTERVAL = Dialog.getNumber();
 	 _TIME_UNIT = Dialog.getString();
}

function convertNikonTIAndor() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/MRI_Convert_Nikon_TI_Andor_To_Hyperstac.py");
	dir = getDirectory("Select a directory!");
	parameter = "dir="+ dir +", "; 
	parameter = parameter + "outputFolder=" + _OUTPUT_FOLDER + ", ";
	parameter = parameter + "zslices=" + _ZSLICES + ", ";
	parameter = parameter + "pixelSize=" + _PIXEL_SIZE + ", ";
	parameter = parameter + "pixelUnit=" + _PIXEL_UNIT + ", ";
	parameter = parameter + "timeInterval=" + _TIME_INTERVAL + ", ";
	parameter = parameter + "timeUnit=" + _TIME_UNIT;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}