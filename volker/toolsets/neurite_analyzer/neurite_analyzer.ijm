segmentNuclei();

function filterChannel3Segmentation() {
	toBeDeleted = newArray(0);
	circThreshold = 0.4;
	areaThreshold = 0.001;
	count = roiManager("count");
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		r = getValue("Circ.");
		a = getValue("Area");
		print(r);
		if (r>=circThreshold || a<areaThreshold) {
			toBeDeleted = Array.concat(toBeDeleted, i);
		}
	}
	roiManager("select", toBeDeleted);
	roiManager("delete");
}


function segmentNuclei() {
	run("Duplicate...", " ");
	setAutoThreshold("Li dark");
	run("Analyze Particles...", "size=200-Infinity circularity=0-1.00 show=Masks");
	run("Fill Holes");
	run("Watershed");
	setThreshold(1, 255);
	run("Analyze Particles...", "size=200-Infinity circularity=0.45-1.00 show=Nothing add");
	close();
	close();
	run("From ROI Manager");
}
