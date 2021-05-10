MEMBRANE_DIAMETER = 0.5;
MEMBRANE_CHANNEL = 2;

if (nImages==0) batchCytoToMembrane();
else cytoToMembrane();

function cytoToMembrane() {
	roiManager("reset");
	run("To ROI Manager");
	size = roiManager("count");
	for (i = 0; i < size; i++) {
		roiManager("select", i);
		group = Roi.getGroup();
		if (group!=1) continue;
		Stack.setChannel(2);
		run("Interpolate", "interval=1 smooth adjust");
		run("Enlarge...", "enlarge=-"+(MEMBRANE_DIAMETER/2));
		run("Make Band...", "band="+MEMBRANE_DIAMETER);
		Roi.setGroup(1);
		roiManager("Update");
	}
	run("From ROI Manager");
	roiManager("reset");
}

function batchCytoToMembrane() {
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	images = filterImages(files);
	for (i = 0; i < images.length; i++) {
		print("processing image "+ (i+1) + " of " + images.length);
		image = images[i];
		open(dir+image);
		cytoToMembrane();
		save(dir+image);
		close("*");
	}
}

function filterImages(files) {
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(toLowerCase(file), ".tif") && indexOf(file, "_masks")==-1) {
			images = Array.concat(images, file);
		}
	}
	return images;
}
