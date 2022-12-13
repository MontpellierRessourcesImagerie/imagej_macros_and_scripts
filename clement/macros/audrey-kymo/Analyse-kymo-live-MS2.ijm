
// In this variable we will store the path of the directory in which our image is located.
var global_workingDirectory = "";
var global_fileName = "";
var global_measures = newArray(5);
var global_units = newArray(2);
var global_exportPaths = newArray(3); // 0: kymos,  1: Results,  2: Extrapolated coordinates
var emptyStr = "";

// Function merging two elements to form a path
function joinPath(root, name) {
	if (root.endsWith(File.separator)) {
		return root + name;
	}
	return root + File.separator + name;
}

// Close an image without disturbing the that is active
function closeImage(img) {
	selectImage(img);
	close();
}


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

// "Extrapolated coordinates"


// Everything we need to do before we start.
function init() {
	// We want to close everything before starting.
	run("Close All");
	run("Clear Results");
}

// Select the video on which we want to work.
function choseImage() {
	// Sélectionner le chemin de la vidéo à traiter.
	path = File.openDialog("Choose a File");
	
	// Once the path is chosen, we keep it to name files.
	global_fileName = File.getName(path);
	global_workingDirectory = File.getParent(path);

	// Creation of export directories.
	// | Create the paths
	cleanName       = File.getNameWithoutExtension(global_fileName);
	kymos_path      = joinPath(global_workingDirectory, "kymos_" + cleanName);
	results_path    = joinPath(global_workingDirectory, "results_" + cleanName);
	extrap_cos_path = joinPath(global_workingDirectory, "extracos_" + cleanName);

	// | Save the paths in global.
	global_exportPaths[0] = kymos_path;
	global_exportPaths[1] = results_path;
	global_exportPaths[2] = extrap_cos_path;

	// | Generate the actual folders on the system, alongside the image.
	File.makeDirectory(kymos_path);
	File.makeDirectory(results_path);
	File.makeDirectory(extrap_cos_path);

	// Opening image.
	open(path);
	workingImage = getImageID();

	return workingImage; // Returns the unique ID of our image.
}

// Function opening a dialog box to ask the user for properties about the image.
// The fetched values are globally stored so they can be reused (for example, the frames interval)
function askPropertiesToUser(img) {

	// Reading current default values
	selectImage(img);
	getVoxelSize(width, height, depth, mUnit);
	Stack.getUnits(X, Y, Z, Time, Value);

	// Seting up default values
	vWidth         = width;
	vHeight        = height;
	vDepth         = depth;
	unit           = mUnit;
	interframeTime = Stack.getFrameInterval();
	interframeUnit = Time;
	nbAxons        = 5;

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

	// Reading values provided by the user.
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
	run("Gaussian Blur 3D...", "x=3.5 y=3.5 z=0.8"); // To be fixed, width of axon must be asked in dialog.
	// Z-projection according to the max intensity along the slices
	run("Z Project...", "projection=[Max Intensity] all");
	// We take the ID of the new image, and close the old one that has become useless at this point.
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


function makeCanalLine(lWidth, img, canal) {
	run("Line Width...", "line="+lWidth);
	// Due to a bug of Draw Kymo, we can only use polylines...
	setTool("polyline");
	selectImage(img);

	waitForUser("Make a line accross the channel " + canal + ".\n(double-click to end drawing)");
	roiManager("Add");
}


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

	// Retreive measurement units
	setVoxelSize(global_measures[0], 1, 1, global_units[0]);
	Stack.setTUnit(global_units[1]);
	Stack.setFrameInterval(global_measures[3]);

	return kymo;
}


function makeBladderLines(kymo, canal) {
	// Making polylines over bladders
	selectImage(kymo);
	setTool("polyline");
	run("Line Width...", "line=1");
	waitForUser("Tracer des lignes segmentées par dessus le tracé des vésicules qui se déplacent.\nSi aucune vésicule n'est visible, [OK] passe au prochain canal.\n- [Double-click] pour terminer un tracé.\n- [T] pour ajouter au ROI Manager.\n- [OK] quand tous les tracés sont terminés.");
	run("Smart Calib'", "pixel=" + global_measures[0] + " space=" + global_units[0] + " frame=" + global_measures[3] + " time=" + global_units[1]);
	
	if (RoiManager.size() == 0) {
		// No bladder was found on this channel, we can skip it.
		closeImage(kymo);
		return false;
	}

	// Launching kymograph analysis
	run("Analyse Kymo", "outward=[From left to right] lim.=0 line=2 log_all_data log_extrapolated_coordinates show");
	analysedKymo = getImageID();
	closeImage(kymo);

	// Exporting image and results
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


function kymographProcedure(lWidth, img) {
	selectImage(img);
	cleanName = File.getNameWithoutExtension(global_fileName);

	// Converting sequence of frames to stack of slices (for Draw Kymo)
	Stack.setDimensions(1, nSlices, 1);

	// global_measures[4] is the number of axons
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

	askPropertiesToUser(img);
	prep = preprocessImage(img);
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


main();

/*

	TO-DO:

- [X] Encapsuler tout le code dans des fonctions avec un main() pour pouvoir abort.
- [X] Passer en global tous les paramètres qui ont besoin d'être utilisés plusieurs fois.
- [X] Faire un dialogue clean au début du script pour les settings.
- [X] Rajouter une phase de denoising avec un gaussian.
- [X] Passer les arguments en dialogues des fonctions run plutôt que laisser ouvrir le dialogue.
- [X] Preshot tous les dialogues qui demandent des informations déjà fournies dans le dialogue de départ.
- [~] Rajouter une étape au script pour déterminer la largeur d'un canal. (pour le Gaussian)
- [~] Faire un essai de détection automatique des canaux + placement des lignes.
- [X] Exporter les kymos dans un folder et les results dans un autre, au même endroit que l'image.
- [X] Fix le bug du à la variable d'environnement de KymoToolBox.
- [X] Copie du code sur le GitHub MRI.
- [X] Changer "axons" à "canaux".
- [X] Contourner le problème de la ligne qui se tord.
- [X] Nettoyer les sélections d'une itération à l'autre.
- [X] Clear la table de "Results" avant de commencer.
- [ ] Make a macro of the main function.
- [~] Activer le mode batch par moments pour masque les images de travail ?
- [X] Renvoyer un mail à Audrey pour montrer le final.
- [ ] Mettre une copie du code final sur GitHub.
- [ ] Mettre à jour le ticket (avec un lien vers le code).


	NOTES:

- Si aucune vésicule n'est visible, simplement appuyer sur OK peut permettre de passer à la prochaine itération.
- Le sens de tracé de la ligne par dessus le canal est important.

*/