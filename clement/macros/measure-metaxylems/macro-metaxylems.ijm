working_dir = getDirectory("Select metaxylems dir");

function join(a, b) {
	if (endsWith(a, File.separator)) { return a + b; }
	return a + File.separator + b;
}

roiManager("reset");
setOption("Show All", true);
run("Normalize Local Contrast", "block_radius_x=100 block_radius_y=100 standard_deviations=2 center stretch");
run("32-bit");
run("Variance...", "radius=16");
run("Set Measurements...", "area mean fit display redirect=None decimal=3");
setTool("wand");

waitForUser("Make selections", "Select all your metaxylems");
count = roiManager("count");

for (i = 0 ; i < count ; ++i) {
	roiManager("select", 0);
	run("Convex Hull");
	roiManager("add");
	roiManager("select", 0);
	roiManager("delete");
}

roiManager("Measure");
results_path = join(working_dir, getTitle()+".csv");
Table.save(results_path);
