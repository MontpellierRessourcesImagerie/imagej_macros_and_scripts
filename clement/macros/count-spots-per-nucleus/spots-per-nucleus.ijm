
/* ---------------------------------------------------------------------------------

This macro allows (from a nuclei and a spots segmentations) to count the number of spots per nucleus.
It creates a results table in which each line corresponds to a nucleus and its spots.
The columns are:
	- 'Label'      : The unique identifier of a nucleus.
	- 'Perimeter'  : The perimeter (in physical units) of each nucleus.
	- 'Circularity': The area ratio between the nucleus and the minimal circle containing the nucleus.
	- '# spots'    : The number of spots in this nucleus.

The calibration used for the measures is the one carried by the nuclei mask.
A warning will be emitted in the "Log" window if no calibration could be found.
The code is suitable for both 2D and 3D images.
Time series are not handled.


This macro requires:
--------------------

	- MorphoLibJ ("IJPB-plugins" in the update sites).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!!! A graphical dialog prompt will ask for the settings, you don't need to update them in the code.

Inputs:
-------

	- 'Nuclei mask'           : A binary mask of your nuclei in 8-bit OR a label map of nuclei.
	- 'Spots labels'          : A labels-map such as produced by LabKit, on which spots have a known index.
	- 'Results prefix'        : The results table will be named after the nuclei mask name, to which we concatenate this prefix.
	- 'Spots label'           : The index (value) of the spots in the labels-map.
	- 'Min. nuclei area (pxl)': The minial area/volume of a nucleus (in number of pixels/voxels). Anything below will be discarded.
	
Usage:
------

	- Open a pair of images (nuclei + spots).
	- Run the macro.
	- Get your results table where each line corresponds to a nucleus.

--------------------------------------------------------------------------------- */

nuclei_name     = "";
spots_name      = "";
table_prefix    = "spots-";
spots_lbl       = 2;
min_nuclei_area = 500;

all_titles = getList("image.titles");
if (lengthOf(all_titles) < 2) {
	exit("There should be at least to open images");
}

// Ask settings.

Dialog.create("Spots counter");
Dialog.addImageChoice("Nuclei mask", all_titles[0]);
Dialog.addImageChoice("Spots labels", all_titles[1]);
Dialog.addString("Results prefix", table_prefix);
Dialog.addNumber("Spots label", spots_lbl);
Dialog.addNumber("Min. nuclei area (pxl)", min_nuclei_area);
Dialog.show();

nuclei_name     = Dialog.getImageChoice();
spots_name      = Dialog.getImageChoice();
table_prefix    = Dialog.getString();
spots_lbl       = Dialog.getNumber();
min_nuclei_area = Dialog.getNumber();

selectImage(nuclei_name);
nuclei_img = getImageID();
table_name = table_prefix + getTitle();
getVoxelSize(vwidth, vheight, vdepth, unit);

if (vwidth == 1 || unit == "pixels") {
	IJ.log("Warning: It looks like your nuclei mask is not calibrated.");
}

selectImage(spots_name);
spots_img = getImageID();

// Clean-up spots
selectImage(spots_img);
run("Select Label(s)", "label(s)=" + spots_lbl);
run("Divide...", "value=" + spots_lbl);
clean_spots = getImageID();

// Labelize nuclei
selectImage(nuclei_img);
nt = getTitle();
run("Draw Labels As Overlay", "label=[" + nt + "] image=[" + nt + "] x-offset=-5 y-offset=-5");
if (is("binary")) {
    run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
    raw_nuclei_lbls = getImageID();
    run("Label Size Filtering", "operation=Greater_Than size=" + min_nuclei_area);
    run("Remap Labels");
    remaped_nuclei = getImageID();
    selectImage(raw_nuclei_lbls);
    close();
} 
else {
    run("Duplicate...", " ");
    run("Remap Labels");
    remaped_nuclei = getImageID();
}

selectImage(remaped_nuclei);
setVoxelSize(vwidth, vheight, vdepth, unit);
run("Analyze Regions", "area perimeter circularity");
t = Table.title;
Table.rename(t, table_name);

// Remove outside and attribute spots

selectImage(remaped_nuclei);
t1 = getTitle();
selectImage(clean_spots);
t2 = getTitle();
imageCalculator("Multiply create", t1, t2);
attributed_spots = getImageID();
selectImage(remaped_nuclei);
close();
selectImage(clean_spots);
close();

// Count spots per nucleus

getStatistics(area, mean, min, max, std, histogram);
n_nuclei = max;

for (l = 1 ; l <= n_nuclei ; l++) {
	selectImage(attributed_spots);
	run("Select Label(s)", "label(s)=" + l);
	setThreshold(1, 65535);
	run("Convert to Mask");
	run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
	getStatistics(area, mean, min, max, std, histogram);
	Table.set("# spots", l-1, max, table_name);
	Table.update(table_name);
	close();
	close();
}

close();

