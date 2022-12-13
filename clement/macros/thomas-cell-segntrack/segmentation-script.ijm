
var voxelsDimensions = newArray(0.102, 0.102, 0.4);
var tempDirectory = "";
var segmentationChannel = 1;
var dataChannel = 2;

// Functions that create and delete a temporary directory to dump on the disk what is useless for the current step.
function createTemporaryDirectory(path, name) {
	tempPath = path + name + File.separator;
	File.makeDirectory(tempPath);
	tempDirectory = tempPath;
}

function removeTemporaryDirectory() {
	files = getFileList(tempDirectory);
	for (i = 0 ; i < files.length ; i++) {
		File.delete(tempDirectory + files[i]);
	}
	Files.delete(tempDirectory);
}


// Opening the image to be processed.
function openOriginalFile() {
	path     = File.openDialog("Select a File");
	dir      = File.getParent(path);
	name     = File.getName(path);
	bareName = File.getNameWithoutExtension(path);
	createTemporaryDirectory(dir, bareName);
	
	open(path);
	setVoxelSize(voxelsDimensions[0], voxelsDimensions[1], voxelsDimensions[2], "um");
	
	return getImageID();
}


function splitFramesAndDump(originalID) {
	selectImage(originalID);
	getDimensions(width, height, channels, slices, frames);
	
	for (f = 1 ; f <= frames ; f++) {
		run("Duplicate...", "duplicate frames=" + i + "-" + i);
		saveAs("Tiff", tempDirectory + "frame-" + IJ.pad(f, 4) + ".tif");
		close();
	}
	
	close(); // closing original image that we don't need.
	return frames;
}

// Locates the image whose the name starts with a given prefix. Does not change the active image.
function locateImage(prefix) {
	before = getImageID();
	result = 0;
	i = 1;
	
	while ((result == 0) && (i <= nImages)) {
		selectImage(i);
		if (startsWith(getTitle(), prefix)) {
			result = getImageID();
		}
		i++;
	}
	
	selectImage(before);
	return result;
}


// Unfortunately the array is not necessarily sorted, so we have to proceed to a linear search ...
// If the value is in the array, returns its index. -1 otherwise.
function isIn(val, array) {
	for (i = 0 ; i < array.length ; i++) {
		if (array[i] == val) {
			return i;
		}
	}
	return -1;
}


// Closes every opened image except the ones passed in parameter.
function closeEverythingBut(toBeKept) {
	toBeClosed = newArray(nImages);
	Array.fill(toBeClosed, 0);
	activeIndex = 0;
	
	// This operation has to be performed in two steps. If we did everything in a single loop, we would disrupt the nImages variable.
	for (i = 1 ; i <= nImages ; i++) {
		selectImage(i);
		if (!isIn(getImageID(), toBeKept)) {
			toBeClosed[activeIndex] = getImageID();
			activeIndex++;
		}
	}
	
	for (i = 0 ; i < toBeClosed.length ; i++) {
		if (toBeClosed[i] != 0) {
			selectImage(toBeClosed[i]);
			close();
		}
	}
}


function splitAndDump(frameIndex) {
	open(tempDirectory + "frame-" + IJ.pad(frameIndex, 4)) + ".tif";
	run("Split Channels");
	
	segmentationID = locateImage("C1-");
	dataID         = locateImage("C2-");
	
	selectWindow(segmentationID);
	rename("SegmentationBasis");
	saveAs("Tiff", tempDirectory + "segmentation-basis-" + IJ.pad(frameIndex, 4) + ".tif");
	
	selectWindow(dataID);
	rename("DataBasis");
	saveAs("Tiff", tempDirectory + "data-basis-" + IJ.pad(frameIndex, 4) + ".tif");
	
	closeEverythingBut(newArray(segmentationID, 0));
	
	return segmentationID;
}


function detectInFocusRange(segmentationImage) {
	selectImage(segmentationImage);
	run("Median (3D)");
	median = getImageID();
	run("FeatureJ Laplacian", "compute smoothing=1.0 detect");
	laplacian = getImageID();
	
	// Processing z-plot on each slice.
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.getPosition(channel, slice, frame);
	
	for (i = 1 ; i <= frames ; i++) {
		selectImage(laplacian);
		Stack.setFrame(i);
		run("Plot Z-axis Profile", "profile=z-axis");
		
		Plot.getValues(x, y);
		Table.setColumn("µm", x);
		Table.setColumn("Mean", y);
		
		saveAs("Results", tempDirectory + "z-plot-frame-" + IJ.pad(i, 4) + ".csv");
		run("Clear Results");
		close();
	}
	
	Stack.setFrame(frame);
	// Run Python script here, and figure a way to get its output.
}


function keepChannel(originalID, segmentationChannel) {
	run("Duplicate...", "duplicate channels=" + segmentationChannel + "-" + segmentationChannel);
	segmImage = getImageID();
	selectImage(originalID);
	close();
	return segmImage;
}

// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
// #   MAIN FUNCTION                                                                         #
// # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

function main() {
	
	setBatchMode(true);
	
	originalID = openOriginalFile();
	segmentationImage = keepChannel(originalID, segmentationChannel);
	range = detectInFocusRange(segmentationImage);
	
	/*frames = splitFramesAndDump(originalID);
	
	for (f = 1 ; f <= frames ; f++) {
		segmentationImage = splitAndDump(f);
		range = detectInFocusRange(segmentationImage);
	}*/
	
	removeTemporaryDirectory();
	setBatchMode(false);
	
	return 0;
}

main();

/*

On va d'abord retirer le channel de data en un bloc car il ne sert à rien, on va pas split les frames en premier.

- [ ] Plutot que split les frames, on devrait batcher pour determiner l'ecart minimum et ne garder que celui-la.
- [ ] Rajouter un safety-check au depart pour s'assurer qu'on part bien d'un hyperstack.
- [ ] Verifier que l'index 0 ne fait pas crash la sélection d'image quand selectImage y est confronte.
- [ ] Lancer une detection des plugins pour check que tous ceux qui sont utilises sont presents chez l'utilisateur.

*/




