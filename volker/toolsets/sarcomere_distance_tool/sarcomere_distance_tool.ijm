var _PROMINENCE = 18;
var _NR_OF_MAXIMA = 2;
var _MIN_AREA = 15000;
var _FILE_EXTENSION = "tif";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Sarcomere_Distance_Tool";

measureImage();

exit();

macro "Automatic scale spot detection Action Tool (f1) - C200D00D06D0dD10D14D15D16D1bD1cD20D24D2aD30D39D3eD45D4dD52D53D54D62D63D72D86D95D96Da5DafDb9Dd7C800D13D1eD32D35D36D41D59D5eD67D71D77D87D89DaeDccDd9De6DedDf4C500D01D08D0bD11D1aD25D29D3dD42D48D4fD51D76D82D85D9dD9fDa6DabDacDcdDd5Dd6De4Df7Df8DfcCb00D28D2dD3cD56D60D66D74D7aD83D94Da1Da2Da7Db3Db6Dc3Dc5DceDebDf3Df6DfdC400D07D21D38D4cD4eD55D8dDb8DdcDddCa00D09D22D2cD3bD4aD58D5bD65D75D8bDbdDbeDcfDd4Df1DfbC700D04D17D31D49D5aD5cD99D9aDa4DbaDd1Df5Ce00D27D84DbbDc0Dc6Dd3C300D05D0eD2bD2fD33D3fD43D44D64Da9DaaDe7De8DecC900D1fD37D47D4bD61D6aD78D7cD8aD8cD8fD91D92Dc1Dc2Dd0Dd2C600D34D46D5dD68D6dD79D81D9bDa8Db2DbfDc7Dc9De0De5Df0Cd00D12D18D19D5fD6cD80Db4DbcDdbDdeDe2De9C400D0cD1dD23D3aD40D50D69D73D7dD9cDc8Dd8De1Cb00D0fD26D57D6eD7fD88D97D98D9eDadDb7C700D0aD2eD7eD8eDb1Db5DffCf00D02D03D6bD6fD70D7bD90D93Da0Da3Db0Dc4DcaDcbDdaDdfDe3DeaDeeDefDf2Df9DfaDfe"{
	run('URL...', 'url='+helpURL);
}

macro "automatic scale spot detection tool help [f1]" {
	run('URL...', 'url='+helpURL);
}

macro "measure distance between sarcomeres Action Tool (f2) - C000T4b12m" {
	measureImage();
}

macro "measure distance between sarcomeres Action Tool (f2) Options" {
	Dialog.create("distance between sarcomeres options");
	Dialog.addNumber("min. area of cell: ", _MIN_AREA);
	Dialog.addNumber("prominence of maxima: ", _PROMINENCE);
	Dialog.addNumber("number of maxima: ", _NR_OF_MAXIMA);
	Dialog.show();
	_MIN_AREA = Dialog.getNumber();
	_PROMINENCE = Dialog.getNumber();
	_NR_OF_MAXIMA = Dialog.getNumber();
}

macro "measure distance between sarcomeres [f2]" {
	measureImage();
}

macro "batch measure distance between sarcomeres Action Tool (f3) - C000T4b12b" {
	batchMeasure();
}

macro "batch measure distance between sarcomeres Action Tool (f3) Options" {
	Dialog.create("batch measure distance between sarcomeres options");
	Dialog.addString("file extension: ", _FILE_EXTENSION);
	Dialog.show();
	_FILE_EXTENSION = Dialog.getString();
}

macro "batch measure distance between sarcomeres [f3]" {
	batchMeasure();
}

function batchMeasure() {
	setBatchMode(true);
	dir = getDirectory("Choose the input folder!");
	File.makeDirectory(dir+File.separator+"out");
	files = getFileList(dir);
	images = filterImages(files);
	Table.reset("sarcomere-results");
	for (i = 0; i < images.length; i++) {
		image = images[i];
		print("\\Update1: processing file " + (i+1) + " of " + images.length);
		open(dir + File.separator + image);
		measureImage();
		save(dir + File.separator+"out" + File.separator + image);
		close();
	}
	Table.save(dir + File.separator + "sarcomere-results.xls", "sarcomere-results");
	setBatchMode(false);
}

function measureImage() {
	area = selectCell();
	r = 0;
	if (area>0) {
		r = estimateSarcomereDistance();
	}
	report(area, r);
	run("Select None");
}

function estimateSarcomereDistance() {
	run("Clear Results");
	run("RGB Stack");
	run("Duplicate...", "use");
	run("Restore Selection");
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	setBackgroundColor(0, 0, 0);
	run("Clear Outside");
	run("FFT");
	run("Find Maxima...", "prominence="+_PROMINENCE+" output=[Point Selection]");
	run("Measure");
	close();
	close();
	run("RGB Color");
	r = 0;
	for (i = 1; i <= _NR_OF_MAXIMA; i++) {
		r = r + getResult("R", i);
	}
	r = r / _NR_OF_MAXIMA;
	return r;
}

function selectCell() {
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	cellIsSelected = true;
	if (selectionType()<0) {
		cellIsSelected = false;
	}
	if (!cellIsSelected) {
		inputImageID = getImageID();
		run("Duplicate...", " ");
		maskID = getImageID();
		run("RGB Stack");
		setAutoThreshold("Default dark");
		run("Convert to Mask", "method=Default background=Dark");
		run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity show=Masks in_situ slice");
		run("Create Selection");
		if (selectionType() < 0) {
			close();
			return 0; 
		}
		run("Convex Hull");
		selectImage(inputImageID);
		run("Restore Selection");
	}
	Overlay.remove;
	Overlay.addSelection;
	Overlay.show;
	getStatistics(area);
	if (!cellIsSelected) {
		selectImage(maskID);
		close();
	}
	return area;
}

function report(area, r) {
	imageTitle = getTitle();
	title = "sarcomere-results";
	if (!isOpen(title)) {
		Table.create(title);
	}
	row = Table.size(title);;
	Table.set("image", row, imageTitle, title);
	Table.set("area cell", row, area, title);
	Table.set("distance between sarcomere", row, r, title);
	Table.update(title);
}

function filterImages(files) {
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		fileLowerCase = toLowerCase(file);
		ext = toLowerCase(_FILE_EXTENSION);
		if (endsWith(fileLowerCase, "."+ext)) {
			images = Array.concat(images, file);
		}
	}
	return images;
}
