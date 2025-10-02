working_dir = getDirectory("Select steles dir");

function join(a, b) {
	if (endsWith(a, File.separator)) { return a + b; }
	return a + File.separator + b;
}

// Make a mask
run("Select None");
setAutoThreshold("Huang dark");
setOption("BlackBackground", true);
run("Convert to Mask");
resetThreshold;

run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
run("Kill Borders");
run("Keep Largest Label");
run("Morphological Filters", "operation=Opening element=Disk radius=10");
run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
run("Keep Largest Label");
run("Convexify");
run("Analyze Regions", "area equivalent_ellipse ellipse_elong.");

results_path = join(working_dir, getTitle()+".csv");
Table.save(results_path);

final_path = join(working_dir, getTitle());
saveAs("TIFF", final_path);
run("Close All");
