var INPUT_FOLDER  = "";
var CH_INDEX      = 4;
var PREFIX        = "nuclei_";

function join(a, b) {
	if (a.endsWith(File.separator)) { return a + b; }
	return a + File.separator + b;
}

function ask_settings() {
	Dialog.create("Extract channel settings");
	Dialog.addDirectory("Input directory", "");
	Dialog.addNumber("Channel index", 4);
	Dialog.addString("Prefix", "nuclei_");
	Dialog.show();
	INPUT_FOLDER = Dialog.getString();
	CH_INDEX = Dialog.getNumber();
	PREFIX = Dialog.getString();
}

function main() {
	setBatchMode("hide");
	run("Close All");
	ask_settings();
	filelist = getFileList(INPUT_FOLDER);
	
	for (i = 0; i < lengthOf(filelist); i++) {
	    current = filelist[i];
	    if (!endsWith(current, ".tif"))  { continue; }
	    if (startsWith(current, PREFIX)) { continue; }
	    print("Processing: " + current);
	    full_path = join(INPUT_FOLDER, current);
	    open(full_path);
	    run("Duplicate...", "duplicate channels=" + CH_INDEX + "-" + CH_INDEX);
	    output_name = PREFIX + current;
	    output_path = join(INPUT_FOLDER, output_name);
	    saveAs("TIFF", output_path);
	    run("Close All");
	}
	setBatchMode("exit and display");
	print("DONE.");
}


main();
