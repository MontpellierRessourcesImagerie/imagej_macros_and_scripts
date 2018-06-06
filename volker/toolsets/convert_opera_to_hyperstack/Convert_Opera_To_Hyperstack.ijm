/** 
 * Convert images taken with the Opera into hyperstacks
 * The image names are in the form
 *
 * r02c04f01p01-ch1sk1fk1fl1.tiff
 *
 * where r is the row, c the column, f the field, p the 
 * z position and ch the channel.
 * 
 * (c) 2018, INSERM
 * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 * 
 */
 
var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/MRI_Convert_Opera_To_Hyperstack";
var _SATURATED = 0.35;
var _OUTPUT_FOLDER = "stack";

macro "convert opera [f8]" {
  convertOpera();
}

macro "convert opera (f8) Action Tool - C037T1d13cT9d13oC555"{
  convertOpera();
}

macro "convert opera (f8) Action Tool Options" {
	 Dialog.create("Convert Opera Options");
	 Dialog.addNumber("saturated", _SATURATED);
	 Dialog.addString("output folder", _OUTPUT_FOLDER);
	 Dialog.addMessage("Press the help button below to open the online help!");
	 Dialog.addHelp(helpURL);
 	 Dialog.show();
 	 _SATURATED = Dialog.getNumber();
 	 _OUTPUT_FOLDER = Dialog.getString();
}

function convertOpera() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/convert_Opera_To_Hyperstack.py");
	dir = getDirectory("Select a directory!");
	parameter = "dir=" + dir +", saturated="+_SATURATED+", outputFolder=" + _OUTPUT_FOLDER;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}
