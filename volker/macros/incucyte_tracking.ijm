dir = getDir("Select the input folder!");
files = getFileList(dir);
outFolder = dir + File.separator + "results"

if (!File.exists(outFolder)) {
	File.makeDirectory(outFolder);
}


for (i=0; i<files.length; i++) {
	print("Processing image nr: " + i);
	run("Clear Results");
	file = files[i];
	file = toLowerCase(file); 
	if (!endsWith(file, ".tif")) continue;
	open(dir + File.separator + file);
	analyzeImage();
	baseName = replace(file, ".tif", ""); 
	xlsFile = replace(file, ".tif", ".xls");
	selectWindow("Results");
	saveAs("results", dir + File.separator + xlsFile);
	save(outFolder + File.separator + baseName + "-labels.tif");
	close();
	save(outFolder + File.separator + baseName + "-mask.tif");
	close();
	save(outFolder + File.separator + baseName + "-paths.tif");
	close();
}


function analyzeImage() {
	run("Image Stabilizer", "transformation=Translation maximum_pyramid_levels=1 template_update_coefficient=0.90 maximum_iterations=200 error_tolerance=0.0000001");
	setThreshold(0, 124);
	setOption("BlackBackground", false);
	run("Convert to Mask", "background=Light");
	run("Fill Holes", "stack");
	run("Remove Outliers...", "radius=2 threshold=50 which=Dark stack");
	run("Dilate", "stack");
	run("MTrack2 ", "minimum=10 maximum=400 maximum_=50 minimum_=2 show show_0 show_1");
}
