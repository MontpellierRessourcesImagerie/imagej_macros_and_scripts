
input_directory = "/home/clement/Downloads/2025-08-07-mgalopin/data";
extension = ".czi";
nuclei_channel = 1;
inflammation_channel = 2;
dilation_rad = 5;
table_name = "inflammation-measurements";

Dialog.create("Settings");
Dialog.addDirectory("Images location", getDirectory("home"));
Dialog.addString("Images extension", ".czi");
Dialog.addNumber("Nuclei ch.", 1);
Dialog.addNumber("Inflammation ch.", 2);
Dialog.addNumber("Dilation radius", 5);

Dialog.show();

input_directory = Dialog.getString();
extension = Dialog.getString();
nuclei_channel = Dialog.getNumber();
inflammation_channel = Dialog.getNumber();
dilation_rad = Dialog.getNumber();

// -------------------------------------------------------

function join(a, b) {
	if (endsWith(a, File.separator)) {
		return a + b;
	}
	return a + File.separator + b;
}

images_pool = getFileList(input_directory);

run("Close All");
run("Collect Garbage");
run("Set Measurements...", "area integrated redirect=None decimal=3");

Table.create(table_name);
line_count = 0;

for (i = 0 ; i < images_pool.length ; ++i) {
	image_name = images_pool[i];

	if (!endsWith(image_name, extension)) { continue; }
	IJ.log("[" + (i+1) + "∕" + images_pool.length + "] Processing: " + image_name);
	raw_name = replace(image_name, extension, "");
	
	output_dir = join(input_directory, "control-"+raw_name);
	File.makeDirectory(output_dir);
	
	full_path = join(input_directory, image_name);
	run("Bio-Formats", "open=[" + full_path + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	original = getImageID();
	
	// Make a mask from nuclei
	run("Duplicate...", "duplicate channels="+nuclei_channel+"-"+nuclei_channel);
	run("Subtract Background...", "rolling=150 sliding");
	setAutoThreshold("Otsu dark no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	rename("original");
	base_mask = getImageID();
	run("Morphological Filters", "operation=Dilation element=Disk radius="+dilation_rad);
	rename("dilated");
	dilate_mask = getImageID();
	imageCalculator("Subtract create", "dilated","original");
	final_mask = getImageID();
	selectImage(base_mask);
	close();
	selectImage(dilate_mask);
	close();
	selectImage(final_mask);
	output_path = join(output_dir, "mask.tif");
	saveAs("TIFF", output_path);
	run("Create Selection");
	Roi.copy();
	close();
	
	// Transfer the ROI and measure intensity
	selectImage(original);
	run("Duplicate...", "duplicate channels="+inflammation_channel+"-"+inflammation_channel);
	inf_channel = getImageID();
	Roi.paste();
	run("Measure");
	
	// Transfer the measures to the buffer
	area = Table.get("Area", 0, "Results");
	int = Table.get("RawIntDen", 0, "Results");
	Table.set("Source", line_count, raw_name, table_name);
	Table.set("Area", line_count, area, table_name);
	Table.set("Integrated int.", line_count, int, table_name);
	close("Results");
	line_count++;
	run("Close All");
}