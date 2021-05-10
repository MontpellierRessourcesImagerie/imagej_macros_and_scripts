title = getTitle();
run("Set Measurements...", "area mean standard min centroid display redirect=None decimal=3");
deleteUnmatchedROIs();

Stack.getDimensions(width, height, channels, slices, frames);
tableTitle = "Cell Measurements";
if (!isOpen(tableTitle)) {
	Table.create(tableTitle);
}
for (i = 1; i <= channels; i++) {
	Stack.setChannel(1);
	run("Clear Results");
	roiManager("measure");
	for (j = 0; j < nResults; i=i+2) {
			
	}
}


function deleteUnmatchedROIs() {
	inputImageID = getImageID();
	run("Clear Results");
	roiManager("reset");
	run("To ROI Manager");
	RoiManager.selectGroup(2);
	roiManager("measure");
	xNuclei = Table.getColumn("X");
	yNuclei = Table.getColumn("Y");
	toUnscaled(xNuclei, yNuclei);
	size = RoiManager.size;
	startIndexOfNuclei = getStartIndexOfGroup(2);
	
	counter = 1;
	for (i = 0; i < size; i++) {
		roiManager("select", i);
		group = Roi.getGroup();
		if (group==2) break;
		run("Create Mask");	
		run("Analyze Particles...", "include overlay");
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
	roiManager("select", indices);
	roiManager("delete");
	roiManager("deselect");
	run("Select None");
	run("From ROI Manager");
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
