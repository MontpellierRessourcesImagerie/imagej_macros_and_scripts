/*
 * export selections as images
 */

outputFolder = getDirectory("Choose an output folder!");
filename = File.nameWithoutExtension;
count = roiManager("count");
for(i=0; i<count; i++) {
	roiManager("select", i);
	run("Duplicate...", " ");
	path = outputFolder + "/" + filename + "-" + (i+1) + ".tif";
	save(path);
	close();
}
roiManager("Save", outputFolder + "/" + filename + ".zip");
roiManager("Deselect");
run("Select None");