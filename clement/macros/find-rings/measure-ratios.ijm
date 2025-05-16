/* ----------------------------------------------------------------------------------------

How to use this macro?

1. Open one of your images.
2. Make sure that your ROIs Manager is filled
3. Click the "Run" button

Extracted metrics:

- Name: Name of the ROI in the ROIs Manager
- Total area: The area of each ROI is calculated. It is expressed in physical unit if the image is calibrated.
- Global intensity: Integrated intensity over the whole ROI without restriction.
- Ring intensity: Integrated intensity over the whole ROI after the image was multiplied with the ring mask.
                  Since the integrated intensity is the sum of pixels values over the whole area, the presence
                  of zeros (after the multiplication) doesn't affect the value.

How is the ring mask calculated ?

- The LoG filter is applied to the image, which produces a map of prominence, showing present structures.
	- A ring should be a donut-like structure
	- The absence of ring implies an absence of structure
	- An intermediate form should produce a fragmented mask over the nucleus.
- This LoG result is thresholded and divided by 255 to have a mask where ring pixels are at 1, and BG is at 0.
- We multiply the image with this mask, so the pixels of ring are left untouched while everything else is erased.
- The integrated intensity over an area is constant whether this area contains 2 or 2000 zero-pixels.

Settings:
- TABLE_PREFIX: The name of the results table will the image's name prefixed with that.
- THRESHOLDING: If "AUTO", the LoG will be thresholded with the THRESHOLD_MTD method.
                If "MANUAL", the LoG will be thresholded between -1E30 and THRESHOLD_VAL.
- THRESHOLD_MTD: See description of 'THRESHOLDING' above.
- THRESHOLD_VAL: See description of 'THRESHOLDING' above.
- OUTPUT_FOLDER: Folder in which control images are exported.
                 Make sure it ends with a separator ('/' on Mac&Linux, '\' on Windows)
                 On Windows, make sure to double every '\'. No '\' should be alone, even the last one.
- CHANNEL_INDEX: Rank of the channel in which intensity measurements have to be done. Starts at 1.
- RADIUS: Approximate radius of a ring-like structure in physical unit (== thickness of the donut)

-----------------------------------------------------------------------------------------*/

TABLE_PREFIX   = "Ratios-";
THRESHOLDING   = "AUTO" // "MANUAL" or "AUTO"
THRESHOLD_MTD  = "Triangle";
THRESHOLD_VAL  = -80.12;
OUTPUT_FOLDER  = "/home/benedetti/Downloads/2025-04-30-mauboiron/transfer_9723622_files_252ef7e0/tests/";
CHANNEL_INDEX  = 3;
RADIUS         = 0.2;


function measure_global_intensities(image, table_name) {
	selectImage(image);
	run("Select None");
	for (i = 0 ; i < roiManager("count") ; i++) {
		roiManager("select", i);
		name = RoiManager.getName(i);
		global_int  = getValue("IntDen");
		global_area = getValue("Area");
		Table.set("Name", i, name, table_name);
		Table.set("Total area", i, global_area, table_name);
		Table.set("Global intensity", i, global_int, table_name);
	}
}

function measure_ring_intensities(image, table_name) {
	selectImage(image);
	t = getTitle();
	run("Select None");
	run("FeatureJ Laplacian", "compute smoothing="+RADIUS);
	saveAs("TIFF", OUTPUT_FOLDER+getTitle());
	if (THRESHOLDING == "AUTO") {
		setAutoThreshold("Triangle no-reset");
	} else {
		setThreshold(-1E30, THRESHOLD_VAL);
	}
	run("Convert to Mask");
	run("Divide...", "value=255");
	run("16-bit");
	saveAs("TIFF", OUTPUT_FOLDER+getTitle()+"-mask.tif");
	rename("target_mask");
	target_mask = getImageID();
	imageCalculator("Multiply create", t, "target_mask");
	new_intensities = getImageID();
	selectImage(target_mask);
	close();
	
	selectImage(new_intensities);
	run("Select None");
	for (i = 0 ; i < roiManager("count") ; i++) {
		roiManager("select", i);
		ring_int  = getValue("IntDen");
		Table.set("Ring intensity", i, ring_int, table_name);
	}
	close();
}

function launch_measures() {
	image_name = getTitle();
	table_name = TABLE_PREFIX + image_name;
	Table.create(table_name);
	run("Select None");
	
	run("Duplicate...", "duplicate channels=" + CHANNEL_INDEX + "-" + CHANNEL_INDEX);
	original = getImageID();
	
	measure_global_intensities(original, table_name);
	measure_ring_intensities(original, table_name);
	close();
}

launch_measures();
