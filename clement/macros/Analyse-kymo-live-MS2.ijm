
// In this variable we will store the path of the directory in which our image is located.
var global_workingDirectory = "";
var global_fileName = "";
var global_measures = newArray(4);
var global_units = newArray(2);

// Everything we need to do before we start.
function init() {
	// We want to close everything before starting.
	run("Close All");
}

// Select the video on which we want to work.
function choseImage() {
	// Ouvrir la vidéo à traiter (MN dans chip)
	path = File.openDialog("Choose a File");
	open(path);
	workingImage = getImageID();
	global_fileName = File.getName(path);
	global_workingDirectory = File.getParent(path);

	return workingImage; // Returns the unique ID of our image.
}

// Function opening a dialog box to ask the user for properties about the image.
// The fetched values are globally stored so they can be reused (for example, the frames interval)
function askPropertiesToUser() {

	// Reading current default values
	getVoxelSize(width, height, depth, mUnit);
	Stack.getUnits(X, Y, Z, Time, Value);

	// Seting up default values
	vWidth         = width;
	vHeight        = height;
	vDepth         = depth;
	unit           = mUnit;
	interframeTime = Stack.getFrameInterval();
	interframeUnit = Time;

	// Creating dialog box fields
	Dialog.create("Image's properties");
	Dialog.addNumber("Voxel height:", vHeight);
	Dialog.addNumber("Voxel width:", vWidth);
	Dialog.addNumber("Voxel depth:", vDepth);

	Dialog.addString("Measure unit:", "µm");

	Dialog.addNumber("Interframe time:", interframeTime);
	Dialog.addString("Time unit:", interframeTime);

	// Showing dialog box to user.
	Dialog.show();

	// Reading values provided by the user.
	vHeight        = Dialog.getNumber();
	vWidth         = Dialog.getNumber();
	vDepth         = Dialog.getNumber();
	unit           = Dialog.getString();

	interframeTime = Dialog.getNumber();
	interframeUnit = Dialog.getString();

	// Storing values in global variables so they can be reused later.
	global_measures[0] = vHeight;
	global_measures[1] = vWidth;
	global_measures[2] = vDepth;
	global_measures[3] = interframeTime;

	global_units[0] = unit;
	global_units[1] = interframeUnit;

	// Applying acquired properties to the current image.
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
	run("Gaussian Blur 3D...", "x=3.5 y=3.5 z=0.8"); // To be fixed, width of axon must be asked in dialog.
	// Z-projection according to the max intensity along the slices
	run("Z Project...", "projection=[Max Intensity] all");
	// We take the ID of the new image, and close the old one that has become useless at this point.
	proj = getImageID();
	close(img);
	// Display in shades of gray, and inverting intensities.
	run("Grays");
	run("Invert LUT");

	// Renaming according to the original file name
	rename("preprocessed_" + global_fileName);
}

function temporary() {

	// Max Projection de tous les Z, mise en gris/inversé
	// run("Z Project...", "projection=[Max Intensity] all");
	// run("Enhance Contrast", "saturated=0.35");
	// run("Grays");
	// run("Invert LUT");

	//Réglage des propriétés de l'image
	// run("Properties...");

	// rename(file_name);

	//Boucle pour faire plusieurs canaux dans une même vidéo
	for (i = 1; i < 6; i++) {
		
	//Tracer une ligne le long du canal à analyser
	run("Line Width...", "line=30");
	setTool("line");
	waitForUser("Tracer une ligne droite le long d'un canal");
	roiManager("Add");
	roiManager("select", 0);
	roiManager("Rename", file_name + "canal" + i);
	//roiManager("Save", directory + File.separator + i + ".zip");

	//Faire un kymographe avec KymographBuilder

	run("KymographBuilder", file_name);
	run("Enhance Contrast", "saturated=0.35");
	run("Invert LUT");
	run("Properties...");

	//Tracer le chemin des vésicules sur le kymographe
	roiManager("Delete");
	setTool("polyline");
	run("Line Width...", "line=1");
	waitForUser("Tracer des lignes segmentées par dessus le tracé des vésicules qui se déplacent. A la fin de chaque ligne, double cliquer puis appuyer sur t pour ajouter au ROI Manager");

	run("Smart Calib'");

	run("Analyse Kymo");

	// Enregistrer le tableau de résultats
	//save("results")

	}
}

// Function launching the whole procedure.
function main() {
	init();
	img = choseImage();

	// The ID of an image is a negative number. If we have something greater or equal than zero, it's an error, and we can stop the macro.
	if (img >= 0) { return -1; }

	askPropertiesToUser();
	preprocessImage(img);
}


main();