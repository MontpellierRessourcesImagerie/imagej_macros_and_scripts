
input_folder = "E:\\";
target_image = "image-name.tif";
extension = ".tif";
spots_index = 1;

// --------------------------------------------

// Prepare image and labels paths
image_path = input_folder + target_image;
labels_path = input_folder + replace(target_image, extension, "-labeled"+extension);

// Verify that they both exist
if (!File.exists(image_path)) {
	print("Couldn't find: " + image_path + ". ABORT";
	exit;
}

if (!File.exists(labels_path)) {
	print("Couldn't find: " + labels_path + ". ABORT";
	exit;
}

print("Image and labels found!!");

// Open the original image and only keep the spots channel
open(image_path);
getDimensions(width, height, channels, slices, frames);
close();

// Open the labeled image, keeps the spots label and retrieve the correct shape
open(labels_path);
lbls = getImageID();

run("Select Label(s)", "label(s)=" + spots_index);
spots_mask = getImageID();
selectImage(lbls);
close();

setThreshold(1, 255, "raw");
setOption("BlackBackground", true);
run("Convert to Mask", "background=Dark black");
run("Properties...", "channels=1 slices="+slices+" frames="+frames);

saveAs("Tiff", input_folder + replace(target_image, extension, "-mask"+extension));
print("Saved mask");

run("Close All");