var IMAGE_A = "";
var IMAGE_B = "";

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Metrics_Tool";

macro "MRI Metrics Tool Help (f4) Action Tool - C000D23D28D29D34D35D39D3aD44D45D49D4aD53D58D59D5dD6dD7dD8dD9dDa3Da8Da9DadDb4Db5Db9DbaDc4Dc5Dc9DcaDd3Dd8Dd9CeeeD2bD4cD5bDabDbcDdbC555D13D19D26D69D99Da6De3De9C111D57D72D82Dd7CbbbD12D3bD4bD4dDbbDbdDcbDe2C000D27D2aD5aD73D83Da7DaaDdaC999D1aD38D48D6aD9aDb8Dc8DeaC333D74D75D76D77D78D79D7aD7bD84D85D86D87D88D89D8aD8bCcccD22D24D25D52D54D55Da2Da4Da5Dd2Dd4Dd5C888D37D47D62D92Db7Dc7C222D33D43D7cD8cDb3Dc3CcccD5cD6cD9cDacCaaaD18D68D98De8C666D56D71D81Dd6C111D36D46D63D93Db6Dc6" {
	run('URL...', 'url='+helpURL);
}

macro "MRI Metrics Tool Help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "Intersection over Union (Jaccard similarity coefficient) Action Tool - C037T0b10IT6b10oTeb10U" {
	showIoUDialog();
}

function showIoUDialog() {
	images = getList("image.titles");
	if (images.length<2) {
		batchIoU();
	}
	if (IMAGE_A=="") IMAGE_A = images[0];
	if (IMAGE_B=="") IMAGE_B = images[1];
	Dialog.createNonBlocking("IoU Metric (Jaccard similarity coefficient)");
	Dialog.addChoice("Image A: ", images, IMAGE_A);
	Dialog.addChoice("Image B: ", images, IMAGE_B);
	Dialog.show();
	IMAGE_A = Dialog.getChoice();
	IMAGE_B = Dialog.getChoice();
	iouValue = iou(IMAGE_A, IMAGE_B);
	reportIoU(IMAGE_A, IMAGE_B, iouValue);
	print("IoU between " + IMAGE_A + " & " + IMAGE_B + " = " + iouValue);
	createIoUImage(IMAGE_A, IMAGE_B);
	showIoUDialog();
}

function createIoUImage(a, b) {
	run("Merge Channels...", "c1="+a+" c2="+b+" keep create");
	compositeID = getImageID();
	run("RGB Color");
	selectImage(compositeID);
	close();
	setFont("SanSerif", 15, "antialiased");
  	setColor("red");
    Overlay.drawString(a, 5,15);
    setColor("green");
    Overlay.drawString(b, 5,30);
    Overlay.show;
}

function reportIoU(a, b, jaccardIndex) {
	if (!isOpen("IoU (Jaccard similarity coefficient)")) {
		Table.create("IoU (Jaccard similarity coefficient)");
	}	
	row = Table.size;
	Table.set("image a", row, a);
	Table.set("image b", row, b);
	Table.set("IoU", row, jaccardIndex);
	Table.update;
}
		
function iou(a, b) {
	setBatchMode("true");
	imageCalculator("AND create", a, b);
	getHistogram(values, counts, 256);
	I = counts[255];
	close();
	imageCalculator("OR create", a, b);
	getHistogram(values, counts, 256);
	U = counts[255];
	close();
	setBatchMode("false");
	return I/U;
}

function batchIoU() {
	dirOut = getDir("Select the folder containing the input images");
	dirGT = getDir("Select the folder containing the ground-truth images");

	outImages = getFileList(dirOut);
	outImages = filterImages(outImages, dirOut);
	gtImages = getFileList(dirGT);
	gtImages = filterImages(gtImages, dirGT);
	File.makeDirectory(dirOut + "/qc");
	for (i = 0; i < dirOut.length; i++) {
		IMAGE_A = outImages[i];
		open(dirOut + "/" + IMAGE_A);
		IMAGE_B = gtImages[i];
		open(dirGT + "/" + IMAGE_B);
		iouValue = iou(IMAGE_A, IMAGE_B);
		reportIoU(IMAGE_A, IMAGE_B, iouValue);
		print("IoU between " + IMAGE_A + " & " + IMAGE_B + " = " + iouValue);
		createIoUImage(IMAGE_A, IMAGE_B);
		save(dirOut + "/qc" + "/" + IMAGE_A);
		close("*");
	}
}

function filterImages(files, folder) {
	newList = newArray(0);
	for (i = 0; i < files.length; i++) {
		path = folder + "/" + files[i];
		if (!File.isDirectory(path) && endsWith(path, ".tif")) {
			newList = Array.concat(newList, files[i]);
		}
	}
	return newList;
}
