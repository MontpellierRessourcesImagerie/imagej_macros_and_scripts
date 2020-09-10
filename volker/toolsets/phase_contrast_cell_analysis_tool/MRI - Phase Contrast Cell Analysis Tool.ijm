/**
  * Phase Contrast Cell Analysis Tool
  * Collaborators:
  *        Damien Planchon
  *
  * Segment and measure cells in phase contrast images
  *
  * (c) 2014 INSERM
  * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
 *
*/

var _CROP_RECT_X = 0;
var _CROP_RECT_Y = 34;
var _CROP_RECT_WIDTH = 757;
var _CROP_RECT_HEIGHT = 469;
var _CONVERT_TO_8BIT = true;
var _BATCH_MODE = false;

var _CLASSIFIERS_DIR = getDirectory("imagej") + "models";
var _CLASSIFIERS = getFileList(_CLASSIFIERS_DIR);
var _CLASSIFIER = _CLASSIFIERS[0];
var _EXCLUDE_SMALL_OBJECTS = true;
var _MIN_SIZE = 10;
var _FILL_HOLES = false;
var _SELECTION_WIDTH = 1;
var _FILE_EXT = ".tif";
var _DIR = "";

var _URL = "http://dev.mri.cnrs.fr/projects/imagej-macros/wiki/Phase_Contrast_Cell_Analysis_Tool_%28Trainable_WEKA_Segmentation%29";

macro "HELP for the MRI Phase Contrast Cell Analysis Action Tool - Cf00D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D18D19D1aD1bD1cD1eD1fD20D21D22D23D24D26D27D28D29DaD2bD2cD2eD2fD30D31D34D36D37D38D39D3aD3bD3cD3eD3fD40D41D42D43D44D45D46D47D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D56D57D5aD5bD5cD5dD5eD5fD60D61D62D63D64D6aD6bD6cD6dD6eD6fD70D71D72D73D74D75D76D7aD7bD7cD7dD7eD7fD80D81D82D83D84D85D8bD8cD8dD8eD8fD90D91D92D93D94D9bD9dD9eD9fDa0Da1Da2Da4Da5Da6Da7Da9DaaDabDacDadDaeDafDb0Db3Db4Db5Db6Db7Db8Db9DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc8Dc9DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6Dd8Dd9DddDdeDdfDe0De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC4f8D1dD25D2dD32D33D35D3dD48D58D59D65D66D67D68D69D77D78D79D86D87D88D89D8aD95D96D97D98D99D9aD9cDa3Da8Db1Db2Dc5Dc6Dc7Dd7DdaDdbDdc" {
	 run('URL...', 'url='+_URL);
}

macro "Preprocessing Action Tool - C037T4d14p" {
	dir = getDirectory("");
	files = getFileList(dir);
	out = "cropped";
	File.mkdir(dir + out);
	print("\\Clear");
	if (_BATCH_MODE) setBatchMode(true);
	count = countImages(files);
	print("preprocessing started on folder: " + dir);
	counter = 1;
	for(i=0; i<files.length; i++) {
		if (endsWith(files[i], _FILE_EXT)) {
			print("\\Update1:Processing image " + counter + " of " + count);
			open(dir+files[i]);
			resetMinAndMax();
			makeRectangle(_CROP_RECT_X, _CROP_RECT_Y, _CROP_RECT_WIDTH, _CROP_RECT_HEIGHT);
			run("Crop");
			run("8-bit");
			save(dir + out + "/" + files[i]);
			close();
			counter++;
		}
	}
	print("preprocessing finished");
	if (_BATCH_MODE) setBatchMode("exit and display");	
}

macro "Select Cells Action Tool - C037T4d14s" {
	if (!isOpen("progress"))
		run("Text Window...", "name=[progress] width=60 height=16 menu");
	else 
		print("[progress]", "Update:");
	_DIR = getDirectory("");
	files = getFileList(_DIR);
	out = "segmented";
	File.mkdir(_DIR + out);
	//setBatchMode(true);
	run("Trainable Weka Segmentation", "open=["+_DIR+files[0]+"]");
	wait(3000);
	wekaTitle = getTitle();
	call("trainableSegmentation.Weka_Segmentation.loadClassifier", _CLASSIFIERS_DIR + "/" + _CLASSIFIER);
	count = countImages(files);
	print("[progress]", "measurement started on folder: " + _DIR);
	counter = 1;
	for(i=0; i<files.length; i++) {
		if (endsWith(files[i], _FILE_EXT)) {
			print("[progress]", "\\Update:Processing image " + counter + " of " + count);
			call("trainableSegmentation.Weka_Segmentation.applyClassifier", _DIR, files[i], "showResults=false", "storeResults=true", "probabilityMaps=false", _DIR + out);
			counter++;
		}
	}
	counter = 1;
	for(i=0; i<files.length; i++) {
			if (endsWith(files[i], _FILE_EXT)) {
			print("[progress]", "\\Update:Creating selection image " + counter + " of " + count);
			open(_DIR+out+"/"+files[i]);
			idMask = getImageID();
			run("8-bit");
			setAutoThreshold("Default dark");
			run("Convert to Mask");
			if (_EXCLUDE_SMALL_OBJECTS) {
				run("Analyze Particles...", "size="+ _MIN_SIZE +"-Infinity show=Masks in_situ");
			}
			if (_FILL_HOLES) {
				run("Fill Holes");
			}
			run("Create Selection");
			open(_DIR+"/"+files[i]);
			run("Restore Selection");
			run("Properties... ", "  width=" + _SELECTION_WIDTH);
			save(_DIR+"/"+files[i]);
			close();
			close();
			counter++;
		}
	}
	selectWindow(wekaTitle/*"Trainable Weka Segmentation v2.1.5"*/);
	close();
	print("[progress]", "\nmeasurement finished");
	setBatchMode("exit and display");	
}

macro "Create Classifier Action Tool - C037T4d14c" {
	dir = getDirectory("");
	files = getFileList(dir);
	run("Image Sequence...", "open=["+ dir + files[0] +"] sort");
	run("Trainable Weka Segmentation");
}

macro "Select Cells Action Tool Options" {
	Dialog.create("Measure Cells Options");
	Dialog.addChoice("classifier: ", _CLASSIFIERS, _CLASSIFIER);
	Dialog.addCheckbox("exclude small objects", _EXCLUDE_SMALL_OBJECTS);
	Dialog.addNumber("min. size", _MIN_SIZE);
	Dialog.addCheckbox("fill holes", _FILL_HOLES);
	Dialog.addNumber("selection width", _SELECTION_WIDTH);
	Dialog.show();
	_CLASSIFIER = Dialog.getChoice();
	_EXCLUDE_SMALL_OBJECTS = Dialog.getCheckbox();
	_MIN_SIZE = Dialog.getNumber();
	_FILL_HOLES = Dialog.getCheckbox();
	_SELECTION_WIDTH = Dialog.getNumber();
}

macro "Preprocessing Action Tool Options" {
	Dialog.create("Cell Analysis Options");
	Dialog.addNumber("x of crop rect.: ", _CROP_RECT_X);
	Dialog.addNumber("y of crop rect.: ", _CROP_RECT_Y);
	Dialog.addNumber("width of crop rect.: ", _CROP_RECT_WIDTH);
	Dialog.addNumber("height of crop rect.: ", _CROP_RECT_HEIGHT);
	Dialog.addCheckbox("convert to 8bit", _CONVERT_TO_8BIT);
	Dialog.addCheckbox("run in batch-mode", _BATCH_MODE);
	Dialog.show();
	_CROP_RECT_X = Dialog.getNumber();
	_CROP_RECT_Y = Dialog.getNumber();
	_CROP_RECT_WIDTH = Dialog.getNumber();
	_CROP_RECT_HEIGHT = Dialog.getNumber();
	_CONVERT_TO_8BIT = Dialog.getCheckbox();
	_BATCH_MODE = Dialog.getCheckbox();
}

function countImages(files) {
	result = 0;
	for (i=0; i<files.length; i++) {
		if (endsWith(files[i], ".tif")) result++;
	}
	return result;
}
