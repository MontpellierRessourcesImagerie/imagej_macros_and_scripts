function find_bubbles(original, labels) {
	arr = newArray(65536);
	run("Set Measurements...", "min redirect=None decimal=3");
	run("Measure");
	
	for (i = 0 ; i < Table.size() ; ++i) {
		lbl = Table.get("Min", i);
		lbl = parseInt(lbl);
		arr[lbl] += 1;
	}
	
	str_settings = "";
	
	for (i = 1 ; i < 65536 ; ++i) {
		if (arr[i] == 1) {
			str_settings += toString(i);
			str_settings += ",";
		}
	}
	
	s = str_settings.length;
	l = str_settings;
	if (l.length > 0) {
		l = substring(str_settings, 0, s - 1);
	}
	command = "label(s)=" + l + " final=0";
	run("Replace/Remove Label(s)", command);
}

function run_segmentation() {
	run("8-bit");
	roiManager("reset");
	run("Gaussian Blur...", "sigma=1.5");
	
	if (Roi.size == 0) {
		exit("An ROI on the image is expected");
	}
	
	original = getImageID();
	roiManager("add"); // roi[0] = working area
	run("Select None");
	
	run("Find Maxima...", "prominence=2 output=[Point Selection]");
	roiManager("add"); // roi[1] == bubbles
	run("Select None");
	run("Median...", "radius=8");
	
	run("Morphological Filters", "operation=Closing element=Disk radius=40");
	rename("bg");
	
	selectImage(original);
	rename("ori");
	
	imageCalculator("Difference create", "ori","bg");
	rename("cleared");
	
	setAutoThreshold("Huang dark");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	
	run("Morphological Filters", "operation=Closing element=Octagon radius=8");
	run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
	
	run("Select None");
	roiManager("select", 0);
	run("Clear Outside");
	run("Fill Holes (Binary/Gray)");
	labels = getImageID();
	rename("raw-labels");
	
	roiManager("select", 1);
	find_bubbles(original, labels);
	
	run("Label Size Filtering", "operation=Greater_Than size=100");
	run("Remap Labels");
	resetMinAndMax;
}

function clean_up() {
	titles = getList("image.titles");
	for (i = 0 ; i < titles.length ; ++i) {
		t = titles[i];
		// if (t.startsWith("labeled-")) { continue; }
		close(t);
	}
	titles = getList("window.titles");
	for (i = 0 ; i < titles.length ; ++i) {
		t = titles[i];
		close(t);
	}
}

function main() {
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	setBatchMode("hide");
	dir = File.directory;
	title = getTitle();
	run_segmentation();
	output_path = dir + "labeled-" + title;
	saveAs("TIFF", output_path);
	clean_up();
	setBatchMode("exit and display");
	print(title + " done.");
}

main();
