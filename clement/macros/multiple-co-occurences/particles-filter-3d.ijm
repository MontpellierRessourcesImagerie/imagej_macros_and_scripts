/*

Expected files hierarchy:

source_folder
  - img_01
     - _c1.tif
     - c1.tif
     - c2.tif
     - c3.tif
  - img_02
     - c1.tif
     - c2.tif
     - _c3.tif
     - c3.tif
     - c3-metrics.csv
  - img_03
     - c1.tif
     - c2.tif
     - c3.tif

This macro filters the content of ONE channel (c1 OR c2 OR c3, etc) within ALL the folders representing an image.
The filtering is made based on the morphological and/or intensity metrics of the detected particles.
The tolerated bounds are described below.
To keep the original image and be able to re-run the macro, whenever something is done, the original is saved with an "_" in front.

If "_cX.tif" exists, it means the image has already been processed and this file contains the original image.
If not, the original "cX.tif" is the original and is copied as "_cX.tif".

*/

// Following the above hierarchy, the path to 'source_folder'
var input_folder = "/home/clement/Downloads/2025-09-18-help-nelly/segmented";
// Whether to process c1, c2, c3, ...
var ch_index     = 1;
// Folder in which cropped images are (the 'raw' ones)
var sources_folder = "/home/clement/Downloads/2025-09-18-help-nelly/segmented/sources"

var use_sphericity = true;
var sphericity     = newArray(0.0, 3.0); // Only spots within this range are conserved

var use_volume = true;
var volume     = newArray(0.0, 999999.9); // Only spots within this range are conserved

var use_mean_intensity = true;
var mean_intensity     = newArray(0, 65536); // Only spots within this range are conserved

// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function join(a, b) {
	if (endsWith(a, File.separator)) { return a + b; }
	return a + File.separator + b;
}

function close_non_images() {
	list = getList("window.titles");
	for (i = 0 ; i < list.length ; ++i) {
		if (list[i] == "Log") { continue; }
		close(list[i]);
	}
}

function preprocess(channel_path, source_image_path, label_map_path, morpho_metrics_path, intensity_metrics_path) {
	if (File.isFile(label_map_path)) { return; }
	open(channel_path);
	run("Connected Components Labeling", "connectivity=6 type=[16 bits]");
	saveAs("TIFF", label_map_path);
	lbl_title = getTitle();
	if (use_sphericity || use_volume) {
		run("Analyze Regions 3D", "volume surface_area mean_breadth sphericity centroid equivalent_ellipsoid ellipsoid_elongations surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
		Table.save(morpho_metrics_path);
	}
	if (use_mean_intensity) {
		open(source_image_path);
		full_img = getImageID();
		run("Duplicate...", "duplicate channels="+ch_index+"-"+ch_index);
		selectImage(full_img);
		close();
		int_title = getTitle();
		run("Intensity Measurements 2D/3D", "input="+int_title+" labels="+lbl_title+" mean stddev max min median mode skewness kurtosis");
		Table.save(intensity_metrics_path);
	}
	run("Close All");
	close_non_images();
}

function filter_labels(morpho_metrics_path, intensity_metrics_path) {
	labels_lut = newArray();
	if ((use_sphericity || use_volume) && File.isFile(morpho_metrics_path)) {
		Table.open(morpho_metrics_path);
		count_sphericity = 0;
		count_volume = 0;
		if (labels_lut.length == 0) { // Init the labels LUT
			max_lbl = Table.get("Label", Table.size - 1);
			labels_lut = newArray(max_lbl + 1);
			for (i = 0 ; i < labels_lut.length ; ++i) { labels_lut[i] = true; }
			labels_lut[0] = false; // background
		}
		for (line_idx = 0 ; line_idx < Table.size ; ++line_idx) {
			label_id = Table.get("Label", line_idx);
			if (use_sphericity) {
				sph = Table.get("Sphericity", line_idx);
				if (sph < sphericity[0] || sph > sphericity[1]) { 
					labels_lut[label_id] = false;
					count_sphericity++;
				}
			}
			if (use_volume) {
				vol = Table.get("Volume", line_idx);
				if (vol < volume[0] || vol > volume[1]) { 
					labels_lut[label_id] = false; 
					count_volume++;
				}
			}
		}
		print("  Filtered by sphericity: " + toString(count_sphericity));
		print("  Filtered by volume: " + toString(count_volume));
	}
	close_non_images();
	if (use_mean_intensity && File.isFile(intensity_metrics_path)) {
		Table.open(intensity_metrics_path);
		count_intensity = 0;
		if (labels_lut.length == 0) { // Init the labels LUT
			max_lbl = Table.get("Label", Table.size - 1);
			labels_lut = newArray(max_lbl + 1);
			for (i = 0 ; i < labels_lut.length ; ++i) { labels_lut[i] = true; }
			labels_lut[0] = false; // background
		}
		for (line_idx = 0 ; line_idx < Table.size ; ++line_idx) {
			label_id = Table.get("Label", line_idx);
			mean_int = Table.get("Mean", line_idx);
			if (mean_int < mean_intensity[0] || mean_int > mean_intensity[1]) { 
				labels_lut[label_id] = false; 
				count_intensity++;
			}
		}
		print("  Filtered by mean intensity: " + toString(count_intensity));
	}
	close_non_images();
	return labels_lut;
}

function apply_filter(label_map_path, ori_path, labels_lut) {
	as_str_list = "[";
	count_kept = 0;
	for (i = 0 ; i < labels_lut.length ; ++i) {
		if (labels_lut[i]) {
			as_str_list += toString(i);
			as_str_list += ", ";
			count_kept++;
		}
	}
	if (as_str_list.length > 1) { as_str_list = substring(as_str_list, 0, as_str_list.length - 2); }
	as_str_list += "]";
	print("  Keeping " + count_kept + " labels out of " + (labels_lut.length - 1));
	
	open(label_map_path);
	run("Select Label(s)", "label(s)="+as_str_list);
	setThreshold(1, 65535, "raw");
	setOption("BlackBackground", true);
	run("Convert to Mask", "background=Dark black");
	saveAs("TIFF", ori_path);
	run("Close All");
}

function name_without_sep(name) {
	new_name = replace(name, File.separator, "");
	return new_name;
}

run("Close All");
close_non_images();
images_pool = getFileList(input_folder);
for (i = 0 ; i < images_pool.length ; ++i) {
	image_name = images_pool[i];
	image_name = name_without_sep(image_name);
	image_path = join(input_folder, image_name);
	if (!File.isDirectory(image_path)) { continue; } // contains c1.tif, c2.tif, ...
	
	channel_path = join(image_path, "_c"+ch_index+".tif"); // use original
	ori_path     = join(image_path,  "c"+ch_index+".tif"); // final file
	if (!File.isFile(ori_path))     { continue; }
	if (!File.isFile(channel_path)) { File.copy(ori_path, channel_path); }
	print("Processing image: " + image_name);
	
	source_image_path      = join(sources_folder, image_name+".tif");
	label_map_path         = join(image_path, "c"+ch_index+"-labeled.tif");
	morpho_metrics_path    = join(image_path, "c"+ch_index+"-morpho-metrics.csv");
	intensity_metrics_path = join(image_path, "c"+ch_index+"-intensity-metrics.csv");

	if (use_mean_intensity && !File.isFile(source_image_path)) {
		print("  Source image not found: " + source_image_path);
		continue;
	}

	preprocess(channel_path, source_image_path, label_map_path, morpho_metrics_path, intensity_metrics_path);
	labels_lut = filter_labels(morpho_metrics_path, intensity_metrics_path);
	apply_filter(label_map_path, ori_path, labels_lut);
}
