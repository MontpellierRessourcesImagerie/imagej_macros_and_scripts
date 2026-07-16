var INPUT_FOLDER     = "";
var SPOTS_INDEX      = 2;
var INFERENCE_PREFIX = "inference_";

function join(a, b) {
	if (endsWith(a, File.separator)) { return a + b; }
	return a + File.separator + b;
}

function ask_settings() {
	Dialog.create("Measure nuclei intensity");
	Dialog.addDirectory("Input folder", "");
	Dialog.addNumber("Spots channel index", 2);
	Dialog.addString("Inference prefix", "inference_");
	Dialog.show();
	INPUT_FOLDER = Dialog.getString();
	SPOTS_INDEX = Dialog.getNumber();
	INFERENCE_PREFIX = Dialog.getString();
}

function main() {
	run("Close All");
	ask_settings();
	filelist = getFileList(INPUT_FOLDER);
	setBatchMode("hide");
	
	for (i = 0; i < lengthOf(filelist); i++) {
	    nuclei_name = filelist[i];
	    if (!startsWith(nuclei_name, INFERENCE_PREFIX)) { continue; } 
	    print("Processing: " + nuclei_name);
	    original_name = replace(nuclei_name, INFERENCE_PREFIX, "");
	    nuclei_path = join(INPUT_FOLDER, nuclei_name);
	    original_path = join(INPUT_FOLDER, original_name);
	    open(original_path);
	    ori = getImageID();
	    run("Duplicate...", "duplicate channels=" + SPOTS_INDEX + "-" + SPOTS_INDEX);
	    spots_id = getImageID();
	    selectImage(ori);
	    close();
	    selectImage(spots_id);
	    rename("intensities");
	    open(nuclei_path);
	    title = getTitle();
	    rename("nuclei");
	    run("Intensity Measurements 2D/3D", "input=intensities labels=nuclei mean stddev max min median");
	    table_name = replace(title, ".tif", ".csv");
		table_name = replace(table_name, INFERENCE_PREFIX, "intensities_");
	    Table.rename("intensities-intensity-measurements", table_name);
	    table_path = join(INPUT_FOLDER, table_name);
	    Table.save(table_path);
	    close(table_name);
	    run("Close All");
	}
	print("DONE.");
	setBatchMode("exit and display");
}

main();
