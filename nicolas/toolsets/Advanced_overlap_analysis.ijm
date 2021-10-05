// This macro originated after discussion on the ImageJ forum.
// See the original thread:
//    http://forum.imagej.net/t/creating-object-class-with-rois-from-multiple-channels/210
//
// It expands on the "Overlap_Analysis_by_Channel" template to show 3-channel analysis with more
// complex analysis techniques.
//
// This macro takes a multi-channel image as input.
// The purpose of this macro is to identify objects in each channel, and determine
// which of these objects overlap with each other.
// This is a non-destructive alternative to the ROI manager's "AND" operation
//
// This template is written assuming 3-channel data, with a reference object
// in the red channel. Update as needed for your data.
//
// Search for "TODO" comments for parameters that need to be adjusted
//
// For general information on image processing (selecting preprocessing techniques) see:
//  http://imagej.net/Image_Processing_Principles

// NOTE: As written, requires the Biomedgroup update site to be enabled.
//            See http://imagej.net/How_to_follow_a_3rd_party_update_site

// *** Start of macro ***

//remove previous scales
run("Set Scale...", "distance=0 known=0 global");

//TODO rename these to something appropriate for your objects
redObject = "Red Object";
blueObject = "Blue Object";
greenObject = "Green Object";

// split images
title = getTitle();
run("Split Channels");

// cache channel names
selectImage("C1-" + title);
redImage = getTitle();
selectImage("C2-" + title);
greenImage = getTitle();
selectImage("C3-" + title);
blueImage = getTitle();

// general preprocessing
//TODO If you need to do any high-level image processing, do so here.
//          For example, you may want to run the imageCalculator to limit the search
//          scope of an image to regions of overlap.
imageCalculator("and", greenImage, redImage);


// BLUE channel
selectImage(blueImage);

// Preprocessing - BLUE channel

// TODO Use the threshold that best fits your data (AutoThreshold > Try all_
// Minimum threshold is fairly aggressive, so it's helpful to Dilate after thresholding
setAutoThreshold("Minimum dark");
run("Convert to Mask");
run("Despeckle");
run("Dilate");

// Analysis - BLUE channel

// TODO Analyze Particles allows specification of particle size, roundness, and other options.
//           Adjust these parameters to best fit your data
run("Analyze Particles...", "  show=Outlines display exclude summarize add");

blueObjectCount = roiManager("count");

setBatchMode("hide"); // hide the UI for this computation to avoid unnecessary overhead of ROI selection

// Rename each blue object ROI to keep track of them.
for(i=0;i<blueObjectCount;i++){
	roiManager("select",i);
	cIndex = i+1;
	// rename to keep track of rois
	roiManager("Rename", blueObject + " "+ cIndex);
	// link to object index
	setResult(blueObject + " Index", i, cIndex);
}

setBatchMode("exit and display");

// End of BLUE channel



// RED channel

selectImage(redImage);

// Preprocessing - RED channel

// TODO Use the threshold that best fits your data (AutoThreshold > Try all_
setAutoThreshold("Default dark");
run("Convert to Mask");
run("Dilate");
run("Despeckle");

// Analysis - RED channel

// TODO Analyze Particles works great in general. However we can also use more specialized plugins to find regions of interest.
//            For example, the Ridge Detection plugin (http://imagej.net/Ridge_Detection) is great at finding lines, and has options
//            to preserve lines through intersection.
//            In this example we'll use Ridge Detection. If Analyze Particles is sufficient for your data though, use it!
run("Skeletonize");
run("Invert LUT");

//TODO find the parameters you want for ridge detection. You can record them using the Macro Recorder (Plugins>Macros>Record...) and then paste the command you use below 
//          - replacing the "waitForUser" line.
waitForUser("Wait for Ridge Detection...", "Please run Plugins>Ridge Detection.\nTune the parameters as needed - preview mode is recommended.\nAfter ridge detection is complete,  click \"OK\" in this dialog to continue.");
//run("Ridge Detection", "line_width=2 high_contrast=255 low_contrast=240 estimate_width extend_line show_junction_points show_ids displayresults add_to_manager method_for_overlap_resolution=SLOPE sigma=1.2 lower_threshold=16.83 upper_threshold=40");

setBatchMode("hide"); // hide the UI for this computation to avoid unnecessary overhead of ROI selection

// Clean up from Ridge Detection
// - Remove junction points
// - Coutn red objects
redObjectCount = 0;
for(i=blueObjectCount;i<roiManager("count");i++){
	roiManager("select",i);
	if (startsWith(Roi.getName(), "JP-")) {
		roiManager("delete");
		i--;
	}
	else {
		redObjectCount++;
		// renaming to keep track of rois
		roiManager("Rename", redObject + " "+ redObjectCount);
		// In the blue channel, analyze particles measured for us.
		// Since we used ridge detection here we need to manually measure.
		roiManager("measure");
		// link to object index
		setResult(redObject + " Index", i, redObjectCount);
	}
}
setBatchMode("exit and display");

// determine which blue objects overlap with red objects
for(i=0;i<blueObjectCount;i++) {
	found = false;

	// find the red object containing this blue object
	for (j=blueObjectCount;j<blueObjectCount + redObjectCount && !found;j++) {
		roiManager("select", j); // select next red object

		pair = getResult("Paired " + blueObject, j);

		// skip previously paired red objects
		if (isNaN(pair) || pair==0) {
			// get coordinates that make up this red object
			Roi.getCoordinates(xPoints, yPoints);

			// select the current blue object
			roiManager("select", i);

			// TODO optional: limit our search range to a section of the red object.
			//           In this example, we care about the position of intersection between
			//           objects. Since our red objects are skeletons, we can limit our
			//           search area to a few "body lengths" around either end of the skeleton.

			Roi.getBounds(cX, cY, cW, cH);
			// We won't go more than "maxDist" away from either end point.
			bodyLengths = 1.7;
			maxDist = ((cW + cH) / 2) * bodyLengths;
			index = -1;

			// search through the skeleton from "head" position
			for (k=0; k<xPoints.length && k<maxDist && !found; k++) {
				x = xPoints[k];
				y = yPoints[k];

				// Check if the blue object roi contains this skeleton point
				if (Roi.contains(x, y)) {
					found = true;
					index = k;
				}
			}

			// search the skeleton from "tail" position
			for (k=xPoints.length-1; k>0 && k>=xPoints.length - maxDist && !found; k--) {
				x = xPoints[k];
				y = yPoints[k];

				// Check if the blue object roi contains this skeleton point
				if (Roi.contains(x, y)) {
					found = true;
					index = k;
				}
			}

			if (found) {
				setResult("Paired " + blueObject, j, i+1); // record link between object indices
				setResult("Position in skeleton", i, index); // record the position on the skeleton where the overlap was detected
			}
		}
	}
}

setBatchMode("exit and display");

// End of RED channel



// GREEN channel

selectImage(greenImage);

// Preprocessing - GREEN channel

//TODO adjust threshold as needed
run("Auto Threshold", "method=Intermodes white");
run("Convert to Mask");

// Analysis - GREEN channel

// TODO in this example, we assume the green channel has noise but our objects of
//            interest are larger than the background. Thus we bump up the minimum size a bit.
run("Analyze Particles...", "size=6-Infinity display exclude summarize add");

setBatchMode("hide"); // hide the UI for this computation to avoid unnecessary overhead of ROI selection

// label green objects
greenObjectCount = 0;
for(i=blueObjectCount + redObjectCount;i<roiManager("count");i++) {
	greenObjectCount++;

	roiManager("select", i);
	//renaming to keep track of rois
	roiManager("Rename", greenObject +" "+ greenObjectCount);
	// Record index
	setResult(greenObject + " Index",i, greenObjectCount);
}

// In this example we assume red objects are significantly larger than green.
// Thus we iterate once over the red objects and find each overlapping green.
for (j=blueObjectCount;j<blueObjectCount + redObjectCount;j++) {
	roiManager("select", j); // select next red object

	// get coordinates that make up this red object
	Roi.getCoordinates(xPoints, yPoints);

	// For each point in this red object, search the green objects for a match.
	for (k=0; k<xPoints.length; k++) {
		x = xPoints[k];
		y = yPoints[k];

		for(i=blueObjectCount + redObjectCount;i<roiManager("count");i++) {
			result = getResult("Paired " + redObject, i);
			// only check green objects not already paired
			if (isNaN(result) || result ==0) {
				// make the current green object roi active
				roiManager("select", i);

				// Check for overlap
				if (Roi.contains(x, y)) {
					// record the index of the containing red object
					setResult("Paired " + redObject, i, j+1-blueObjectCount);

					//TODO here's an optional step where multiple green objects can overlap a single red object.
					//           so we keep count of the number of overlaps.
					count = getResult(greenObject + " Count", j);
					if (isNaN(count)) count = 0;
					count++;
					setResult(greenObject + " Count", j, count);

					//TODO another optional step. Because multiple green objects overlap a single red,
					//          but only one blue object overlaps per red, we can record the distance between
					//          green and blue objects that overlap the same red object.
					// this is a lookup of the blue object index previously paired to our overlapping red object
					blueIndex = getResult("Paired " + blueObject, j);
					if (blueIndex > 0) {
						// record that this green object is paired to a blue
						setResult("Paired " + blueObject, i, blueIndex);
						// record the position of overlap between green object and red skeleton
						setResult("Position in skeleton", i, k);
						blueIndex--; // adjust for object index vs row index

						// recall the position of the blue object in this skeleton
						bluePos = getResult("Position in skeleton", blueIndex);

						// Set the skeletal distance, which is simply the difference in
						// indices within the skeleton between blue and green objects
						if (!isNaN(bluePos)) {
							length = abs(bluePos - k);
							setResult(greenObject + " to " + blueObject + "i distance", i, length);
						}
					}
					wait(50); // wait briefly when we find a match to ensure the UI has caught up.
				}
			}
		}
	}
}
setBatchMode("exit and display");

// End of GREEN channel

// End of macro
