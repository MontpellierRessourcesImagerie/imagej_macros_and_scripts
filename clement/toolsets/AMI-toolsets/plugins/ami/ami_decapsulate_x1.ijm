root_dir = getDirectory("Select the directory containing all images");
content = getFileList(root_dir);

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

setBatchMode("hide");
for (f = 0 ; f < content.length ; ++f) {
	current = content[f];
	print("Processing: " + current);
	input_path = join(root_dir, current);
	print(current);
	images_path = join(input_path, "images");
	raw_path = join(images_path, "RAW_DATA");
	tif_path_1 = join(raw_path, "image_xy0.ome.tif");
	tif_path_2 = join(raw_path, "image_Pos0.ome.tif");
	tif_path = "";
	if (File.exists(tif_path_1)) {
		tif_path = tif_path_1;
	} else {
		tif_path = tif_path_2;
	}
	if (!File.exists(tif_path)) {
		print("Couldn't find TIF in " + tif_path);
		continue;
	}
	run("Bio-Formats", "open=" + tif_path + " autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	current = replace(current, "/", "");
	current = replace(current, "\\", "");
	output_path = join(root_dir, current + ".tif");
	saveAs("TIFF", output_path);
	close();
}
