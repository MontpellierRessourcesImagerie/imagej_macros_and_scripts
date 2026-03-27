var input_folder    = "";
var spots_channel   = 2;
var classifier_path = "/home/clement/Downloads/2026-03-12-cchamontin/transfer_12038429_files_8d35253f/Classifier LABKIT.classifier";
var spots_label     = 1;
var min_size        = 5;
var max_size        = 25;
var min_sphericity  = 0.2;
var excluded_pfx    = newArray(
	"inference_",
	"spots_"
);

function prompt_settings() {
	Dialog.create("Spots settings");
	
	Dialog.addDirectory("Images folder", "");
	Dialog.addNumber("Spots channel", 2);
	Dialog.addFile("Classifier path", "");
	Dialog.addNumber("Spots label", 1);
	Dialog.addNumber("Min spots size (voxels)", 10);
	Dialog.addNumber("Max spots size (voxels)", 160);
	Dialog.addNumber("Min sphericity", 0.2);
	
	Dialog.show();
	
	input_folder    = Dialog.getString();
	spots_channel   = Dialog.getNumber();
	classifier_path = Dialog.getString();
	spots_label     = Dialog.getNumber();
	min_size        = Dialog.getNumber();
	max_size        = Dialog.getNumber();
	min_sphericity  = Dialog.getNumber();
}

function check_settings() {
	if (!File.isDirectory(input_folder)) {
		exit("The input folder doesn't exist.");
	}
	if (!File.exists(classifier_path)) {
		exit("The classifier path is not correct.");
	}
	if (!endsWith(classifier_path, ".classifier")) {
		exit("The provided path doesn't point to a classifier.");
	}
	if (min_size > max_size) {
		exit("The min size cannot be bigger than the max size.");
	}
}

function get_images_list() {
	content = getFileList(input_folder);
	valid_files = newArray();
	for (i = 0 ; i < content.length ; ++i) {
		candidate = content[i];
		lowered = toLowerCase(candidate);
		valid = true;
		// check prefix
		for (j = 0 ; j < excluded_pfx.length ; ++j) {
			pfx = excluded_pfx[j];
			if (startsWith(lowered, pfx)) {
				valid = false;
				break;
			}
		}
		if (!valid) { continue; }
		// check extension
		if (!endsWith(lowered, ".tif") && !endsWith(lowered, ".tiff")) {
			continue;
		}
		valid_files[valid_files.length] = candidate;
	}
	return valid_files;
}

function ask_confirmation(images_list) {
	message = "Found images:\n";
	for (i = 0 ; i < images_list.length ; ++i) {
		item = "  - " + images_list[i] + "\n";
		message += item;
	}
	message += "\nLaunch processing?\n  [OK] Launch\n  [Alt+OK] Cancel";
	waitForUser("Launch processing?", message);
	if (isKeyDown("alt")) { return false; }
	return true;
}

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

function segment_spots() {
	run("Conversions...", " ");
	ori = getImageID();
	title = getTitle();
	run("Duplicate...", "duplicate channels="+spots_channel+"-"+spots_channel);
	ttl = getTitle();
	run("Segment Image With Labkit", "input="+ttl+" segmenter_file=["+classifier_path+"] use_gpu=false");
	imgs = getList("image.titles");
	selectImage(imgs[imgs.length-1]); // in batch mode, LabKit's output is not active https://github.com/juglab/labkit-ui/issues/85#issuecomment-1073946864
	vrt = getImageID();
	run("Duplicate...", "duplicate");
	selectImage(vrt);
	close();
	run("Select Label(s)", "label(s)="+spots_label);
	setThreshold(1, 255, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask", "background=Dark black");
	run("Distance Transform Watershed 3D", "distances=[Svensson <3,4,5,7>] output=[16 bits] dynamic=1 connectivity=6");
	run("16-bit");
	run("Analyze Regions 3D", "voxel_count volume sphericity surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
	
	valid_labels = newArray();
	tb_ttl = Table.title();
	for (i = 0 ; i < Table.size() ; ++i) {
		lbl = Table.getString("Label", i);
		vxl = Table.get("VoxelCount", i);
		sph = Table.get("Sphericity", i);
		if (vxl > max_size || vxl < min_size) { continue; }
		if (sph < min_sphericity) { continue; }
		valid_labels[valid_labels.length] = lbl;
	}
	close(tb_ttl);
	labels_str = "";
	for (i = 0 ; i < valid_labels.length ; ++i) {
		labels_str += toString(valid_labels[i]);
		if (i < valid_labels.length - 1) {
			labels_str += ",";
		}
	}
	command = "label(s)="+labels_str;
	run("Select Label(s)", command);
	run("Remap Labels");
	path = join(input_folder, "spots_"+title);
	_max = 0;
	_min = 65536;
	for (i=1; i<=nSlices; i++) {
        setSlice(i);
        getStatistics(area, mean, min, max, std, histogram);
        if (min < _min) { _min = min; }
        if (max > _max) { _max = max; }
    }
	setMinAndMax(0, _max+1);
	run("glasbey on dark");
	saveAs("TIFF", path);
}

function main() {
	run("Close All");
	prompt_settings();
	check_settings();
	images = get_images_list();
	if (!ask_confirmation(images)) {
		exit("Spots segmentation canceled.");
	}
	for (i = 0 ; i < images.length ; ++i) {
		img_name = images[i];
		r = i + 1;
		IJ.log("[" + r + "/" + images.length + "]: " + img_name);
		img_path = join(input_folder, img_name);
		open(img_path);
		segment_spots();
		run("Close All");
		run("Collect Garbage");
	}
}

setBatchMode("hide");
main();
IJ.log("DONE.");













