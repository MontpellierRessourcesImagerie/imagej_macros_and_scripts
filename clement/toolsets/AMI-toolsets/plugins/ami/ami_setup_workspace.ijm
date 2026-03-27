prefix = "inference_";
channels_of_interest = newArray(3, 4);
luts = newArray("Green", "Red");

// Close everything but the current image
all_imgs = getList("image.titles");
if (all_imgs.length == 0) {
	exit("The active image should be a raw image.");
}

current  = getTitle();
raw = getImageID();
if (startsWith(current, prefix)) {
	exit("You opened a labeled image. You should open a raw image.");
}

for (i = 0 ; i < all_imgs.length ; ++i) {
	ttl = all_imgs[i];
	if (ttl == current) { continue; }
	close(ttl);
}

// Hide not interesting channels, adjust LUTs and contrasts
getDimensions(width, height, channels, slices, frames);
mid = parseInt(slices / 2);
activated_array = newArray(channels);
activated_str   = "";
Stack.setDisplayMode("composite");

for (c = 0 ; c < channels ; ++c) {
	activated_array[c] = 0;
}
for (i = 0 ; i < channels_of_interest.length ; ++i) {
	index = channels_of_interest[i] - 1;
	activated_array[index] = 1;
	Stack.setChannel(channels_of_interest[i]);
	Stack.setSlice(mid);
	run("Enhance Contrast", "saturated=0.15");
	run(luts[i]);
}
for (i = 0 ; i < activated_array.length ; ++i) {
	activated_str += toString(activated_array[i]);
}
Stack.setActiveChannels(activated_str);

// Open the associated labels
folder = File.directory;
inference_path = folder + prefix + current;
if (!File.exists(inference_path)) {
	exit("Couldn't find the associated inference: " + inference_path);
}

open(inference_path);
labels = getImageID();

// Set LUT, sync windows, adjust contrast
run("glasbey on dark");
run("Sync Windows");

print("DONE.");