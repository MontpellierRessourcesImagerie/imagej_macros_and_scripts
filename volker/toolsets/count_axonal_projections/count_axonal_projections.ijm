/***
 * 
 * MRI count axonal projections tool
 * 
 * Count the number of axonal projections that cross a given line.
 * 
 * (c) 2020, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 *
 * 
**/

var _DETECT_THRESHOLD = true;
var _DETECT_TOLERANCE = true;

var _THRESHOLD = 11000;
var _TOLERANCE = 2000;


var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Count-Axonal-Projections-Tool";

exit();

macro "count axonal projections tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "count axonal projections tool help (f4) Action Tool - Cf00L00f0C00cL0141Cf00L51f1C00cL0232Cf00D42C00cD52Cf00L62f2C00cL0333Cf00D43C00cL5373Cf00L83b3C00cDc3Cf00Ld3f3C00cL0424Cf00L3444C00cL5474Cf00D84C00cL94c4Cf00Ld4f4C00cD05Cf00L1525C00cL3565Cf00L7585C00cL95d5Cf00Le5f5L0626C00cL3646Cf00L5676C00cL86d6Cf00Le6f6L0797C00cLa7d7Cf00Le7f7L0898C00cLa8d8Cf00Le8f8L0969C00cL7999Cf00La9f9C00cL0a4aCf00D5aC00cL6adaCf00LeafaC00cL0b4bCf00D5bC00cL6bdbCf00LebfbC00cL0c4cCf00L5c9cC00cLacccCf00LdcfcL0dfdL0efeL0fff"{
	run('URL...', 'url='+helpURL);
}

macro "count axonal projections [f5]" {
	countProjections();
}

macro "count axonal projections (f5) Action Tool - C000T4b12c" {
	countProjections();
}

macro "count axonal projections (f5) Action Tool Options" {
	Dialog.create("options - count axonal projections");
	Dialog.addCheckbox("auto detect threshold", _DETECT_THRESHOLD);
	Dialog.addNumber("threshold: ", _THRESHOLD);
	Dialog.addCheckbox("auto detect threshold", _DETECT_TOLERANCE);
	Dialog.addNumber("tolerance: ", _TOLERANCE);
	Dialog.show();
	_DETECT_THRESHOLD = Dialog.getCheckbox();
	_THRESHOLD = Dialog.getNumber();
	_DETECT_TOLERANCE = Dialog.getCheckbox();
	_TOLERANCE = Dialog.getNumber();
}

function countProjections() {
	run("Remove Overlay");
	
	imageID = getImageID();

	getStatistics(area, mean, min, max, stdDev, histogram); 
	if (_DETECT_THRESHOLD) {
		_THRESHOLD = mean;
	}
	if (_DETECT_TOLERANCE) {
		_TOLERANCE = stdDev/2;
	}
	roiManager("Add");
	getSelectionCoordinates(sPointsX, sPointsY);

	ypoints = getProfile();

	print(sPointsX.length);
	print(ypoints.length);
	
	run("Add Selection...");
	
	maximaPositions = Array.findMaxima(ypoints, _TOLERANCE);
	
	rPointsX = newArray(0);
	rPointsY = newArray(0);
	for (i = 0; i < maximaPositions.length; i++) {
		maximum = ypoints[maximaPositions[i]];	
		if (maximum>_THRESHOLD) {
			rPointsX = Array.concat(rPointsX, sPointsX[maximaPositions[i]]);
			rPointsY = Array.concat(rPointsY, sPointsY[maximaPositions[i]]);
		}
	}
	
	makeSelection("point", rPointsX, rPointsY);
	number = rPointsX.length;
	run("Add Selection...");
	
	tableName = "projection count";
	if (!isOpen(tableName)) {
		Table.create(tableName);
	}
	row = Table.size(tableName);
	Table.set("image", row, File.directory + File.name, tableName);
	Table.set("nr. of projections",  row, number, tableName);

	roiManager("Show All");
	roiManager("Show None");
}