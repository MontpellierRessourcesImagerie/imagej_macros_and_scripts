var _CLASS = 1;
var _MIN_AREA = 100;

batchAnalyze();

function batchAnalyze() {
	dir = getDir("Please select the input folder!");
	files = getFileList(dir);
	for(i=0; i<files.length; i++) {
		file = files[i];
		if (indexOf(file, "segmentation")>-1) continue;
		open(dir+file);	
		analyzeImage();
		close();
		otherFile = replace(file, "_Simple Segmentation", "");
		count = roiManager("count");
		if (count>0) {
			open(otherFile);
			Overlay.remove;
			run("From ROI Manager");
			save(dir+otherFile);
			close();
		}
	}
}

function analyzeImage() {
	run("Set Measurements...", "fit display redirect=None decimal=9");
	run("Macro...", "code=v=(v=="+_CLASS+")*255");
	setThreshold(1, 255);
	roiManager("reset");
	run("Analyze Particles...", "size="+_MIN_AREA+"-Infinity add");
	roiManager("Measure");
}