_KI67_CHANNEL = 2;
_DAPI_CHANNEL = 3;
_LAPLACIAN_RADIUS = 12;
_PROM_NUCLEI = 0.05;
_PROM_KI67 = 0.35;

original_image = getImageID();
title = getTitle();

// Counting nuclei:
function count_items(c_idx, prom) {
	run("Duplicate...", "duplicate channels=" + c_idx + "-" + c_idx);
	dupli = getImageID();
	Stack.setXUnit("pixel");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1 pixel_height=1 voxel_depth=1");
	run("Log");
	run("FeatureJ Laplacian", "compute smoothing=" + _LAPLACIAN_RADIUS);
	lapla = getImageID();
	run("Find Maxima...", "prominence=" + prom + " light output=[Point Selection]");
	n_items = Roi.size;
	roiManager("add");
	selectImage(lapla);
	close();
	return n_items;
}

roiManager("reset");
selectImage(original_image);
n_nuclei = count_items(_DAPI_CHANNEL, _PROM_NUCLEI);
selectImage(original_image);
n_ki67 = count_items(_KI67_CHANNEL, _PROM_KI67);
print(title + " # nuclei: " + n_nuclei);
print(title + " # ki67: " + n_ki67);


