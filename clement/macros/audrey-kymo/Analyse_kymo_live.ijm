// REDMINE: Ticket #1794
// ! In the following code, whenever "channel" is mentionned, we are talking about the channels in which axons are.
// ! They have nothing to do with the color channels of an image.

// >>> GLOBAL VARIABLES DECLARATION ET INITIALISATION <<<
var global_workingDirectory = ""; // Path of the directory in which our image is located.
var global_fileName = ""; // Name of our image, extension included
var global_measures = newArray(5); // 0: height, 1: width, 2: depth, 3: frames interval, 4: number of axons channels (nothing to do with color channels)
var global_units = newArray(2); // 0: voxels' size unit, 1: frame interval time
var global_exportPaths = newArray(3); // 0: kymos,  1: Results,  2: Extrapolated coordinates
var emptyStr = "";
// -------------------------------------------------------

// Function merging two elements to form a path
// Works whether the root ends with the separator or not.
// ex: joinPath("my/path", "thing") --> "my/path/thing"
function joinPath(root, name) {
	if (root.endsWith(File.separator)) {
		return root + name;
	}
	return root + File.separator + name;
}

// Close an image by specifying its ID (<0 number)
function closeImage(img) {
	selectImage(img);
	close();
}

// Make a window active by specifying the begining of its name.
// 'target' is the begining of the title to find.
// If a window whose the begining of the title matches 'target', the window is made active and the full title is returned.
// In case no window was found, an empty string is returned and the active window doesn't change.
// ex: findByWindowTitle("Res") would make the "Results" window active and return the string "Results".
function findByWindowTitle(target) {
	windows = getList("window.titles");
	for (w = 0 ; w < windows.length ; w++) {
		if (windows[w].startsWith(target)) {
			selectWindow(windows[w]);
			return windows[w];
		}
	}
	return emptyStr;
}


// Everything we need to do before we start.
function init() {
	// We want to close everything before starting.
	run("Close All");
	// Clearing results table in case of a previous try.
	run("Clear Results");
}

// Let the user select the video on which we want to work.
function choseImage() {
	// Sélectionner le chemin de la vidéo à traiter.
	path = File.openDialog("Choose a File");
	
	// Once the path is chosen, we keep it to name files.
	global_fileName = File.getName(path);
	global_workingDirectory = File.getParent(path);

	// Creation of export directories.
	//  1. Create the paths
	cleanName       = File.getNameWithoutExtension(global_fileName);
	kymos_path      = joinPath(global_workingDirectory, "kymos_" + cleanName);
	results_path    = joinPath(global_workingDirectory, "results_" + cleanName);
	extrap_cos_path = joinPath(global_workingDirectory, "extracos_" + cleanName);

	//  2. Save the paths in global so they can be accessed everywhere.
	global_exportPaths[0] = kymos_path;
	global_exportPaths[1] = results_path;
	global_exportPaths[2] = extrap_cos_path;

	//  3. Generate the actual folders on the system, alongside the image.
	File.makeDirectory(kymos_path);
	File.makeDirectory(results_path);
	File.makeDirectory(extrap_cos_path);

	// Opening the image.
	open(path);
	workingImage = getImageID();

	// Returns the unique ID of our image.
	return workingImage; 
}

// Function opening a dialog box to ask the user for properties about the image.
// The fetched values are globally stored so they can be reused (for example, the frames interval)
function askPropertiesToUser(img) {

	// Reading current default values
	selectImage(img);
	getVoxelSize(width, height, depth, mUnit);
	Stack.getUnits(X, Y, Z, Time, Value);

	// Seting up default values
	vWidth         = width; // voxels width
	vHeight        = height; // voxels height
	vDepth         = depth; // voxels depth
	unit           = mUnit; // length measuring unit (certainly "µm")
	interframeTime = Stack.getFrameInterval(); // Time elapsed between two frames
	interframeUnit = Time; // time measuring unit ("ms", "sec", ...)
	nbAxons        = 5; // Number of channels (arbitrarily chosen now)

	// Creating dialog box fields
	Dialog.create("Image's properties");
	Dialog.addNumber("Voxel height:", vHeight);
	Dialog.addNumber("Voxel width:", vWidth);
	Dialog.addNumber("Voxel depth:", vDepth);

	Dialog.addString("Measure unit:", "µm");

	Dialog.addNumber("Interframe time:", interframeTime);
	Dialog.addString("Time unit:", interframeUnit);

	Dialog.addNumber("Nb of channels:", nbAxons);

	// Showing dialog box to user.
	Dialog.show();

	// Reading values provided by the user. Order matters. Must be the same as when we added fields.
	vHeight        = Dialog.getNumber();
	vWidth         = Dialog.getNumber();
	vDepth         = Dialog.getNumber();
	unit           = Dialog.getString();

	interframeTime = Dialog.getNumber();
	interframeUnit = Dialog.getString();

	nbAxons        = Dialog.getNumber();

	// Storing values in global variables so they can be reused later.
	global_measures[0] = vHeight;
	global_measures[1] = vWidth;
	global_measures[2] = vDepth;
	global_measures[3] = interframeTime;
	global_measures[4] = nbAxons;

	global_units[0] = unit;
	global_units[1] = interframeUnit;

	// Applying acquired properties to the current image.
	selectImage(img);
	setVoxelSize(vWidth, vHeight, vDepth, unit);
	Stack.setTUnit(interframeUnit);
	Stack.setFrameInterval(interframeTime);
}

// What must be applied to the image before we can start working on it.
function preprocessImage(img) {
	// Make the good image active
	selectImage(img);
	// Fix contrast
	run("Enhance Contrast...", "saturated=0.35 normalize process_all");
	// Denoising
	run("Gaussian Blur 3D...", "x=3.5 y=3.5 z=0.8");
	// Z-projection according to the max intensity along the slices
	run("Z Project...", "projection=[Max Intensity] all");
	// We take the ID of the new image (the projection), and close the old one (the original image) that has become useless at this point.
	proj = getImageID();
	closeImage(img);
	selectImage(proj);
	// Display in shades of gray, and inverting intensities.
	run("Grays");
	run("Invert LUT");
	// Renaming according to the original file name
	rename("preprocessed_" + global_fileName);

	return proj;
}

// Simply make a stroke over the projection image.
function makeCanalLine(lWidth, img, canal) {
	run("Line Width...", "line="+lWidth);
	// Due to a bug of Draw Kymo, we can only use polylines...
	setTool("polyline");
	selectImage(img);

	waitForUser("Make a line accross the channel " + canal + ".\n(double-click to end drawing)");
	roiManager("Add");
}

// Build the kymograph from a line on the original image.
function makeKymograph(img, canal) {
	// Selecting original image
	selectImage(img);
	originalTitle = getTitle();

	// Building kymograph
	run("Draw Kymo", "width=30 get_kymo");
	kymo = getImageID();
	selectImage(kymo);

	// Renaming and fixing contrast
	rename("kymo_canal_" + canal + "_" + global_fileName);
	run("Enhance Contrast", "saturated=0.35");
	run("Invert LUT");

	// The generated kymograph didn't copy the values from the image, we need to copy them before analyse.
	setVoxelSize(global_measures[0], 1, 1, global_units[0]);
	Stack.setTUnit(global_units[1]);
	Stack.setFrameInterval(global_measures[3]);

	return kymo;
}

// Making lines over bladders in kymograph images
function makeBladderLines(kymo, canal) {
	// Making polylines over bladders
	selectImage(kymo);
	setTool("polyline");
	run("Line Width...", "line=1");
	waitForUser("Tracer des lignes segmentées par dessus le tracé des vésicules qui se déplacent.\nSi aucune vésicule n'est visible, [OK] passe au prochain canal.\n- [Double-click] pour terminer un tracé.\n- [T] pour ajouter au ROI Manager.\n- [OK] quand tous les tracés sont terminés.");
	run("Smart Calib'", "pixel=" + global_measures[0] + " space=" + global_units[0] + " frame=" + global_measures[3] + " time=" + global_units[1]);
	
	// No bladder was found on this channel, we can skip it.
	if (RoiManager.size() == 0) {
		closeImage(kymo);
		return false;
	}

	// Launching kymograph analysis
	run("Analyse Kymo", "outward=[From left to right] lim.=0 line=2 log_all_data log_extrapolated_coordinates show");
	analysedKymo = getImageID();
	closeImage(kymo);

	// Exporting kymograph image with strokes.
	selectImage(analysedKymo);
	newTitle = "canal_" + canal + "_" + File.getNameWithoutExtension(global_fileName);
	rename(newTitle);
	saveAs("Tiff", joinPath(global_exportPaths[0], newTitle)+".tif");
	closeImage(analysedKymo);

	// Exporting extrapolated coordinates
	extra = findByWindowTitle("Extrapolated coordinates");
	if (!emptyStr.matches(extra)) {
		saveAs("Results", joinPath(global_exportPaths[2], newTitle+".csv"));
		close(newTitle+".csv");
	}

	return true;
}

// Loop processing each channel one after the other.
function kymographProcedure(lWidth, img) {
	selectImage(img);
	cleanName = File.getNameWithoutExtension(global_fileName);

	// Forcing conversion from sequence of frames, to stack of slices (for Draw Kymo)
	Stack.setDimensions(1, nSlices, 1);

	// global_measures[4] is the number of channels
	// c is the index of the current canal
	for (c = 1 ; c <= global_measures[4] ; c++) {
		selectImage(img);

		// Clearing ROI manager
		roiManager("reset");
		Roi.remove;

		// Making a line accross a canal
		makeCanalLine(lWidth, img, c);
		RoiManager.select(0);
		roiManager("Rename", cleanName + "_canal_" + c);

		// Make the kymograph
		kymo = makeKymograph(img, c);

		roiManager("reset");
		Roi.remove;

		// Make lines over bladders
		makeBladderLines(kymo, c);

		// Clearing ROI manager
		roiManager("reset");
		Roi.remove;
	}
}

// # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
// |                   MAIN                                                          |
// # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

// Function launching the whole procedure.
function main() {
	init();
	img = choseImage();

	// The ID of an image is a negative number. If we have something greater or equal than zero, it's an error, and we can stop the macro.
	if (img >= 0) { return -1; }
	
	// Blurring and z-projection
	prep = preprocessImage(img);

	// Dialog box asking properties to the user.
	askPropertiesToUser(prep);

	// Building kymographs and extracting them to files
	kymographProcedure(30, prep);

	// Saving results all at once in a folder.
	results = findByWindowTitle("Results");
	if(!emptyStr.matches(results)) {
		newTitle = "results_" + File.getNameWithoutExtension(global_fileName);
		saveAs("Results", joinPath(global_exportPaths[1], newTitle+".csv"));
		close("Results");
	}

	// Closing all remaining windows.
	close("*");
	close("ROI Manager");

	return 0;
}


// # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #
// |                   MACRO                                                         |
// # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - #

macro "Live Kymo Analysis" {
	main();
}
