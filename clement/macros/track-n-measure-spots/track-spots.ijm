
input_folder = "E:\\";
target_image = "image-name.tif";
extension = ".tif";
spots_channel = 1;
results_name = "accumulated";

// --------------------------------------------

function init_table(n_tracks) {
	Table.reset(results_name);
	for (i = 0 ; i < n_tracks ; i++) {
		Table.set("Label", i, i+1, results_name);
	}
}

function pad_results(n_tracks) {
	labels = Table.getColumn("Label");
	means  = Table.getColumn("Mean");
	buffer = newArray(n_tracks);
	for (i = 0 ; i < n_tracks ; i++) {
		buffer[i] = "-";
	}
	for (i = 0 ; i < lengthOf(means) ; i++) {
		l = labels[i];
		l-=1;
		m = means[i];
		buffer[l] = m;
	}
	return buffer;
}

function add_to_results(time, n_tracks) {
	padded = pad_results(n_tracks);
	for (i = 0 ; i < n_tracks ; i++) {
		Table.set("t-"+IJ.pad(time, 2), i, padded[i], results_name);
		Table.update(results_name);
	}
}

// --------------------------------------------

setBatchMode("hide");
Table.create(results_name);

// Prepare image and labels paths
image_path = input_folder + target_image;
tracks_path = input_folder + replace(target_image, extension, "-tracked" + extension);

// Verify that they both exist
if (!File.exists(image_path)) {
	print("Couldn't find: " + image_path + ". ABORT";
	exit;
}

if (!File.exists(tracks_path)) {
	print("Couldn't find: " + tracks_path + ". ABORT";
	exit;
}

print("Image and tracks found!!");

// Open the original image and only keep the spots channel
open(image_path);
imIn = getImageID();
getDimensions(width, height, channels, slices, frames);
print("Found " + frames + " time points");
run("Duplicate...", "duplicate channels=" + spots_channel + "-" + spots_channel);
selectImage(imIn);
close();
intensities = getImageID();

// Open the labeled image, keeps the spots label and retrieve the correct shape
open(tracks_path);
tks = getImageID();
run("Conversions...", " ");
run("16-bit");
Stack.getStatistics(voxelCount, mean, min, max, stdDev);
n_tracks = max;
init_table(n_tracks);

for (f = 1 ; f <= frames ; f++) {
	print("Processing frame " + f + " over " + frames + "...");
	// Split frame from the tracks
	selectImage(tks);
	run("Duplicate...", "duplicate frames=" + f + "-" + f);
	t_tks = getImageID();
	title_tks = getTitle();
	// Split frame from the intensities
	selectImage(intensities);
	run("Duplicate...", "duplicate frames=" + f + "-" + f);
	t_intensities = getImageID();
	title_intensities = getTitle();
	// Run intensities measurements
	run("Intensity Measurements 2D/3D", "input="+title_intensities+" labels="+title_tks+" mean stddev max min median");
	add_to_results(f, n_tracks);
	selectImage(t_tks);
	close();
	selectImage(t_intensities);
	close();
}

Table.save(input_folder + results_name + ".csv");
run("Close All");
print("DONE.");
setBatchMode("show");