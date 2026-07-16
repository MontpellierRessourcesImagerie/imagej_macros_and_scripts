var INPUT_FOLDER     = "";
var INFERENCE_PREFIX = "inference_";
var CALIB_XY         = 1.0;
var CALIB_Z          = 1.0;
var UNIT             = "um";
var DO_SWAP_AXES     = true;

function join(a, b) {
	if (endsWith(a, File.separator)) { return a + b; }
	return a + File.separator + b;
}

function ask_settings() {
	Dialog.create("Recalibrate");
	Dialog.addDirectory("Input folder", "");
	Dialog.addString("Inference prefix", "inference_");
	Dialog.addNumber("Pixel size XY", 1.0);
	Dialog.addNumber("Pixel size Z", 1.0);
	Dialog.addString("Unit", "um");
	Dialog.addCheckbox("Swap axes?", true);
	Dialog.show();
	INPUT_FOLDER = Dialog.getString();
	INFERENCE_PREFIX = Dialog.getString();
	CALIB_XY = Dialog.getNumber();
	CALIB_Z = Dialog.getNumber();
	UNIT = Dialog.getString();
	DO_SWAP_AXES = Dialog.getCheckbox();
}

function main() {
	run("Close All");
	ask_settings();
	filelist = getFileList(INPUT_FOLDER);
	setBatchMode("hide");
	
	for (i = 0; i < lengthOf(filelist); i++) {
	    nuclei_name = filelist[i];
	    if (!startsWith(nuclei_name, INFERENCE_PREFIX)) { continue; }
	    if (!endsWith(nuclei_name, ".tif")) { continue; }
	    print("Processing: " + nuclei_name);
	    nuclei_path = join(INPUT_FOLDER, nuclei_name);
	    open(nuclei_path);
	    getDimensions(width, height, channels, slices, frames);
	    s = slices;
	    c = channels;
	    if (DO_SWAP_AXES) {
	    	s = channels;
	    	c = slices;
	    }
	    run("Properties...", "channels="+c+" slices="+s+" frames=1 pixel_width="+CALIB_XY+" pixel_height="+CALIB_XY+" voxel_depth="+CALIB_Z);
	    Stack.setXUnit(UNIT);
	    Stack.setYUnit(UNIT);
	    Stack.setZUnit(UNIT);
		run("Remap Labels");
	    saveAs("TIFF", nuclei_path);
	    run("Close All");
	}
	print("DONE.");
	setBatchMode("exit and display");
}

main();
