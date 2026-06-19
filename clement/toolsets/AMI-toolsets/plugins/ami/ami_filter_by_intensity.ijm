var data_folder   = "/home/clement/Downloads/2026-03-12-cchamontin/pool";
var spots_prefix  = "spots_";
var cells_prefix  = "inference_";
var output_prefix = "filtered_spots_";
var spots_channel = 1;
var std_factor    = 10;

function prompt_settings() {
	Dialog.create("Filter spots by intensity");
	
	Dialog.addDirectory("Cells, spots & images directory", "");
	Dialog.addString("Cells prefix", "inference_");
	Dialog.addString("Spots prefix", "spots_");
	Dialog.addString("Output prefix", "filtered_spots_");
	Dialog.addNumber("Spots channel", 1);
	Dialog.addNumber("Std. dev. factor", 10);
	
	Dialog.show();
	
	data_folder   = Dialog.getString();
	cells_prefix  = Dialog.getString();
	spots_prefix  = Dialog.getString();
	output_prefix = Dialog.getString();
	spots_channel = Dialog.getNumber();
	std_factor    = Dialog.getNumber();
}

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

function get_spot_images() {
	full_list = getFileList(data_folder);
	filtered_list = newArray();
	next_index = 0;
	for (i = 0 ; i < lengthOf(full_list) ; ++i) {
		current = full_list[i];
		if (!current.startsWith(spots_prefix)) { continue; }
		filtered_list[next_index++] = current;
	}
	return filtered_list;
}

function array_to_string(array) {
	total = lengthOf(array);
	buffer = "";
	
	for (i = 0 ; i < total ; ++i) {
		s = toString(array[i]);
		buffer += s;
		if (i < total - 1) {
			buffer += ", ";
		}
	}

	return buffer;
}

function get_mean_and_stddev(cells_path, image_path) {
	open(cells_path);
	rename("cells");
	setThreshold(1, 65535, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask", "background=Dark black");
	
	open(image_path);
	run("Duplicate...", "duplicate channels="+spots_channel+"-"+spots_channel);
	rename("intensities");
	
	run("Intensity Measurements 2D/3D", "input=intensities labels=cells mean stddev");
	
	mean = Table.get("Mean", 0);
	stddev = Table.get("StdDev", 0);
	arr = newArray(mean, stddev);
	run("Close All");
	
	return arr;
}

function filter_by_intensity(image_path, spots_path, output_path, mean, stddev) {
	open(image_path);
	run("Duplicate...", "duplicate channels="+spots_channel+"-"+spots_channel);
	rename("intensities");
	
	open(spots_path);
	rename("spots");
	
	run("Intensity Measurements 2D/3D", "input=intensities labels=spots mean");
	threshold = mean + std_factor * stddev;
	buffer = newArray();
	next_index = 0;
	discard_counter = 0;
	nSpots = Table.size();
	
	for (i = 0 ; i < nSpots ; ++i) {
		lbl = Table.getString("Label", i);
		lbl = parseInt(lbl);
		mean_int = Table.getString("Mean", i);
		mean_int = parseFloat(mean_int);
		if (mean_int >= threshold) {
			buffer[next_index] = lbl;
			next_index++;
		} else {
			discard_counter++;
		}
	}
	
	if (lengthOf(buffer) > 0) {
		args = array_to_string(buffer);
		args = "[" + args + "]";
		run("Select Label(s)", "label(s)="+args);
		run("Remap Labels");
	}
	
	print("   Discarded " + toString(discard_counter) + " spots on " + toString(nSpots) + ".");
	saveAs("TIFF", output_path);
	run("Close All");
}

function main() {
	prompt_settings();
	
	setBatchMode("hide");
	spots_images = get_spot_images();
	total = lengthOf(spots_images);
	run("Close All");
	
	for (i = 0 ; i < total ; ++i) {
		current_spots = spots_images[i];
		current_image = current_spots.replace(spots_prefix, "");
		current_cells = cells_prefix + current_image;
		output_name   = output_prefix + current_image;
		
		print("[" + toString(i+1) + "/" + toString(total) + "] " + current_image);
		
		spots_path  = join(data_folder, current_spots);
		image_path  = join(data_folder, current_image);
		cells_path  = join(data_folder, current_cells);
		output_path = join(data_folder, output_name);
		
		stats  = get_mean_and_stddev(cells_path, image_path);
		mean   = stats[0];
		stddev = stats[1];
		
		filter_by_intensity(
			image_path, 
			spots_path, 
			output_path, 
			mean, 
			stddev
		);
	}
	setBatchMode("exit and display");
	print("DONE.");
}

main();




