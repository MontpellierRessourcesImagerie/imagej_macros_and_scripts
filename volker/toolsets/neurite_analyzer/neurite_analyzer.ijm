var SIGMA = 7;
var THRESHOLDING_METHOD = "Intermodes";
CHANNELS = newArray("405", "640");

batchSegmentNuclei();

function batchSegmentNuclei() {
	dir = getDir("Select the input folder!");
	subfolders = getFileList(dir);
	for (i = 0; i < subfolders.length; i++) {
		folder = dir + subfolders[i];
		files = getFileList(folder);
		files = getFilesForChannel(files, CHANNELS[0]);
		for (f = 0; f < files.length; f++) {
			file = files[f];
			open(folder + file);
			segmentNuclei();
			save(folder + file);
			close();
		}
	}
}

function filterChannel3Segmentation() {
	toBeDeleted = newArray(0);
	circThreshold = 0.4;
	areaThreshold = 0.001;
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		r = getValue("Circ.");
		a = getValue("Area");
		print(r);
		if (r>=circThreshold || a<areaThreshold) {
			toBeDeleted = Array.concat(toBeDeleted, i);
		}
	}
	roiManager("select", toBeDeleted);
	roiManager("delete");
}


function segmentNucleiSimple() {
	run("Duplicate...", " ");
	setAutoThreshold("Li dark");
	run("Analyze Particles...", "size=200-Infinity circularity=0-1.00 show=Masks");
	run("Fill Holes");
	run("Watershed");
	setThreshold(1, 255);
	run("Analyze Particles...", "size=200-Infinity circularity=0.45-1.00 show=Nothing add");
	close();
	close();
	run("From ROI Manager");
}

function segmentNeurites() {
	roiManager("reset");
	setAutoThreshold("Huang dark");
	run("Analyze Particles...", "size=1000-Infinity show=Masks exclude");
	run("Create Selection");
	run("Create Mask");
	run("Select None");
	run("Options...", "iterations=4 count=1 do=Dilate");
	run("Options...", "iterations=4 count=1 do=Erode");
}

function segmentNuclei() {
	Overlay.remove;
	setBatchMode("hide");
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma="+SIGMA);
	setAutoThreshold(THRESHOLDING_METHOD + " dark");
	run("Analyze Particles...", "  show=Overlay ");
	Overlay.copy;
	close();
	Overlay.paste;
	setBatchMode("show");
}

function getFilesForChannel(files, channel) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, channel)>-1) {
			res = Array.concat(res, file);			
		}
	}
	return res;
}
