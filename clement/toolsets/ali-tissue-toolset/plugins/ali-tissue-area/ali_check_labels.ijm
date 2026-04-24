
title = getTitle();
other = "";
dir = File.directory;
ext = ".jpg";

labels = 0;
image  = 0;
setTool("multipoint");

if (title.startsWith("labeled-")) {
	labels = getImageID();
	name = replace(title, "labeled-", "");
	name = replace(name, ".tif", ext);
	other = dir + name;
	open(other);
	image = getImageID();
	
} else {
	image = getImageID();
	name = "labeled-" + title;
	name = replace(name, ext, ".tif");
	other = dir + name;
	open(other);
	labels = getImageID();
}

selectImage(labels);
setThreshold(1, 65535, "raw");
run("Create Selection");
roiManager("reset");
roiManager("add");
roiManager("show all without labels");
run("Select None");
resetThreshold;

selectImage(image);
roiManager("select", 0);

run("Sync Windows");





