/* 
 	MRI Measure Nuclei and Membranes
 
 		Take the results of cell and nuclei segmentation done with cellpose and 
 			- transform the cytoplasm selection into a membrane selection
 			- remove rois for which one membrane does not match one nucleus
 			- measure the membranes and nuclei in all channels but the nuclei-channel
	 
 		(c) 2021, INSERM
 
		written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
*/ 
var MEMBRANE_DIAMETER = 0.5;
var MEMBRANE_CHANNEL = 2;
var NUCLEI_CHANNEL = 3;
var EXTENSION = "tif";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure_Nuclei_And_Membranes_Tool";

macro "measure nuclei and membranes tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "measure nuclei and membranes tool help (f4) Action Tool - CC021D00C031D10C032L2030C022D40C012L5060C00fL70b0C246Dc0Cf11Dd0Cf01De0C939Df0C011D01C041D11C031D21C021L3141C011L5161C00fL71b1C13fDc1Cf10Dd1Cf01De1Cb27Df1C02cD02C041D12C051D22C022D32C015D42C00fL52b2C03fDc2C722Dd2Cf01De2Cf02Df2C01fD03C037D13C025D23C00fL3363C01fL7383C12fD93C029Da3C00fLb3c3C02dDd3Cb12De3Cf00Df3C70fD04C00fL1444C01fD54C51fD64C737D74Cb24D84Cf12D94C623Da4C01fDb4C00fLc4d4C217De4Ce02Df4Cf0fD05C10fD15C00fL2535C91fD45Cf25D55Cf02D65Cf04L7585Cf02D95Cf01Da5Cd35Db5C12fDc5C00fLd5e5C11dDf5Cf03D06Cb0fD16C00fD26C20fD36Cf01D46Cf04D56Ce1bD66C31fD76C32fD86C32eD96Cf17Da6Cf11Db6Ca7aDc6C12fDd6C00fLe6f6Cf02D07Cf0fD17C00fD27C70fD37Cf02D47C91eD57C01fL6777C02fL8797C32dDa7Cf03Db7Cf42Dc7C13fDd7C00fLe7f7Cf02D08Cf23D18C00fD28C90fD38Cf08D48C52fD58C02fL6888C01fD98C12eDa8Cf27Db8Cf12Dc8C21fDd8C00fDe8C01fDf8Cf00D09Cc12D19C01aD29C60fD39Cf09L4959C11fD69C01fD79C11fD89Cd2fD99C43eDa9Cf17Db9Cf03Dc9C10fDd9C00fDe9C036Df9Cf11D0aC122D1aC022D2aC019D3aCf0fD4aCf09D5aCf0fD6aCd0fD7aC61fD8aCb2cD9aCf38DaaCf13DbaCf0fDcaC00fDdaC01fDeaC022DfaC122D0bC021D1bC011D2bC012D3bC118D4bCd19D5bCf0fD6bCf0dD7bCf0fD8bCf0aD9bCf03DabCf0fDbbC50fDcbC26fDdbC5c3DebC140DfbC121D0cC021L1c3cC031D4cC042D5cC238D6cC61fD7cC60fL8c9cC50fDacC00fLbcccC4d4DdcC7f0DecC150DfcC7a0D0dC5a0D1dC260D2dC040D3dC050D4dC051D5dC141D6dC023D7dC129D8dC02fD9dC00fLadcdC4e3DddC7f0DedC140DfdC6a0D0eC3a0D1eC280D2eC250L3e4eC140D5eC240D6eC371D7eC241D8eC132D9eC00fLaebeC01bDceC260DdeC3a0DeeC350DfeC120D0fC020L1f2fC120D3fC130D4fC140D5fC030L6f7fC020D8fC030D9fC020DafC010LbfdfC020DefC450Dff"{
	run('URL...', 'url='+helpURL);
}

macro "open cellpose2IJ roi converter (f5) Action Tool - C000T4b12o" {
	open("https://raw.githubusercontent.com/MontpellierRessourcesImagerie/cellpose/master/imagej_roi_converter_batch.py");
}

macro "open cellpose2IJ roi converter [f5]" {
	open("https://raw.githubusercontent.com/MontpellierRessourcesImagerie/cellpose/master/imagej_roi_converter_batch.py");
}

macro "cytoplasm to membrane (f6) Action Tool - C000T4b12c" {
	runCytoToMembrane();
}

macro "cytoplasm to membrane [f6]" {
	runCytoToMembrane();
}

macro "cytoplasm to membrane (f6) Action Tool Options" {
	Dialog.create("cyto to membrane options");	
	Dialog.addNumber("membrane diameter: ", MEMBRANE_DIAMETER);
	Dialog.addNumber("membrane channel: ", MEMBRANE_CHANNEL);
	Dialog.addString("file extension: ", EXTENSION);
	Dialog.show();
	MEMBRANE_DIAMETER = Dialog.getNumber();
	MEMBRANE_CHANNEL = Dialog.getNumber();
	EXTENSION = Dialog.getString();
}

macro "measure nuclei and membranes (f7) Action Tool - C000T4b12m" {
	runMeasureNucleiAndMembranes();
}

macro "measure nuclei and membranes [f7]" {
	runMeasureNucleiAndMembranes();
}

macro "measure nuclei and membranes (f7) Action Tool Options" {
	Dialog.create("Measure nuclei and membranes options");
	Dialog.addNumber("nuclei channel: ", NUCLEI_CHANNEL);
	Dialog.addString("file extension: ", EXTENSION);
	Dialog.show();
	NUCLEI_CHANNEL = Dialog.getNumber();
	EXTENSION = Dialog.getString();
}

function runCytoToMembrane() {
	if (nImages==0) batchCytoToMembrane();
	else cytoToMembrane();
}

function runMeasureNucleiAndMembranes() {
	if (nImages==0) batchMeasureNucleiAndMembranes();
	else measureNucleiAndMembranes();
}
function measureNucleiAndMembranes() {
	title = getTitle();
	tableTitle = "Cell Measurements";
	if (!isOpen(tableTitle)) {
		Table.create(tableTitle);
	}
	setBatchMode("hide");
	run("Set Measurements...", "area mean standard min centroid display redirect=None decimal=3");
	deleteUnmatchedROIs();
	deleteROIsOneNucleusMultipleCells();
	run("From ROI Manager");
	setBatchMode("show");
	reportResults(tableTitle, title);
	roiManager("reset");
}

function batchMeasureNucleiAndMembranes() {
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	images = filterImages(files);
	for (i = 0; i < images.length; i++) {
		print("processing image "+ (i+1) + " of " + images.length);
		image = images[i];
		open(dir+image);
		measureNucleiAndMembranes();
		save(dir+image);
		close("*");
	}
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	saveAs("results", dir+year+"-"+(month+1)+"-"+dayOfMonth+" "+hour+":"+minute+":"+second+"."+msec+"-results.xls");
}

function reportResults(tableTitle, title) {
	startIndex = Table.size(tableTitle);
	Stack.getDimensions(width, height, channels, slices, frames);
	for (i = 1; i <= channels; i++) {
		if (i==NUCLEI_CHANNEL) continue;
		Stack.setChannel(i);
		run("Clear Results");
		roiManager("measure");
		for (j = 0; j < nResults; j=j+2) {
			area = getResult("Area", j);	
			mean = getResult("Mean", j);	
			stdDev = getResult("StdDev", j);	
			areaN = getResult("Area", j+1);	
			meanN = getResult("Mean", j+1);	
			stdDevN = getResult("StdDev", j+1);	
			xN = getResult("X", j+1);	
			yN = getResult("Y", j+1);
			currentIndex = j/2+startIndex;
			Table.set("image", currentIndex, title, tableTitle);	
			Table.set("cell", currentIndex, (j/2)+1, tableTitle);	
			Table.set("X", currentIndex, xN, tableTitle);	
			Table.set("Y", currentIndex, yN, tableTitle);	
			Table.set("nucleus area", currentIndex, areaN, tableTitle);	
			Table.set("membrane area", currentIndex, area, tableTitle);	
			Table.set("c"+i+" nucleus mean int.", currentIndex, meanN, tableTitle);	
			Table.set("c"+i+" nucleus stdDev", currentIndex, stdDevN, tableTitle);	
			Table.set("c"+i+" membrane mean int.", currentIndex, mean, tableTitle);	
			Table.set("c"+i+" membrane stdDev", currentIndex, stdDev, tableTitle);	
		}
	}
	close("Results");
}

function deleteUnmatchedROIs() {
	inputImageID = getImageID();
	run("Clear Results");
	roiManager("reset");
	run("To ROI Manager");
	roiManager("Remove Channel Info");
	roiManager("Remove Slice Info");
	roiManager("Remove Frame Info")
	RoiManager.selectGroup(2);
	roiManager("measure");
	xNuclei = Table.getColumn("X");
	yNuclei = Table.getColumn("Y");
	toUnscaled(xNuclei, yNuclei);
	size = RoiManager.size;
	startIndexOfNuclei = getStartIndexOfGroup(2);	
	counter = 1;
	showProgress(0, size);
	for (i = 0; i < size; i++) {
		roiManager("select", i);
		group = Roi.getGroup();
		showProgress(i+1, size);
		if (group==2) break;
		run("Create Mask");	
		run("Analyze Particles...", "show=Overlay include");
		Overlay.activateSelection(Overlay.size-1)
		for (p = 0; p < xNuclei.length; p++) {
			if (Roi.contains(xNuclei[p], yNuclei[p])) {
					roiManager("select", i);
					roiManager("rename", ""+IJ.pad(counter, 5)+"-m");
					roiManager("select", startIndexOfNuclei+p);
					roiManager("rename", ""+IJ.pad(counter, 5)+"-n");
					counter++;
					break;
			}
		}
		close("Mask");
	}
	indices = newArray(0);
	for (i = 0; i < size; i++) {
		roiManager("select", i);
		if (!(endsWith(Roi.getName, "-n") ||  endsWith(Roi.getName, "-m"))) {
			indices = Array.concat(indices, i);
		}
	}
	if (indices.length>0) {
		roiManager("select", indices);
		roiManager("delete");
	}
	roiManager("deselect");
	run("Select None");
	roiManager("sort");
}

function deleteROIsOneNucleusMultipleCells() {
	size = RoiManager.size;
	indices = newArray(0);
	deleteMode = false;
	showProgress(0, size);
	for (i = 0; i < size; i++) {
			roiManager("select", i);
			if (endsWith(Roi.getName, "-m")) {
			if (i<size-1) {
				roiManager("select", i+1);		
				if (endsWith(Roi.getName, "-m")) {
					deleteMode = true;
					indices = Array.concat(indices, i);
				}
			}
			if (deleteMode) {
				indices = Array.concat(indices, i);
			}
		} else {
			if (deleteMode) {
				indices = Array.concat(indices, i);
				deleteMode = false;
			}
		}
		showProgress(i+1, size);
	}
	if (indices.length>0) {
		roiManager("select", indices);
		roiManager("delete");
	}
	roiManager("deselect");
	run("Select None");
}

function getStartIndexOfGroup(aGroup) {
	size = RoiManager.size;
	for (i = 0; i < size; i++) {
		roiManager("select", i);
		group = Roi.getGroup();
		if (group==aGroup) {
			return i;
		}
	}
	return -1;
}

function cytoToMembrane() {
	roiManager("reset");
	run("To ROI Manager");
	size = roiManager("count");
	setBatchMode("hide");
	showProgress(0, size);
	for (i = 0; i < size; i++) {
		roiManager("select", i);
		group = Roi.getGroup();
		showProgress(i+1, size);
		if (group!=1) continue;
		Stack.setChannel(MEMBRANE_CHANNEL);
		run("Interpolate", "interval=1 smooth adjust");
		run("Enlarge...", "enlarge=-"+(MEMBRANE_DIAMETER/2));
		run("Make Band...", "band="+MEMBRANE_DIAMETER);
		Roi.setGroup(1);
		roiManager("Update");
	}
	setBatchMode("show");
	run("From ROI Manager");
	roiManager("reset");
}

function batchCytoToMembrane() {
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	images = filterImages(files);
	for (i = 0; i < images.length; i++) {
		print("processing image "+ (i+1) + " of " + images.length);
		image = images[i];
		open(dir+image);
		cytoToMembrane();
		save(dir+image);
		close("*");
	}
}

function filterImages(files) {
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(toLowerCase(file), "."+EXTENSION) && indexOf(file, "_masks")==-1) {
			images = Array.concat(images, file);
		}
	}
	return images;
}
