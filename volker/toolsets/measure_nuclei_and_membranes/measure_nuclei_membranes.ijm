NUCLEI_CHANNEL = 3;
tableTitle = "Cell Measurements";
if (!isOpen(tableTitle)) {
	Table.create(tableTitle);
}
setBatchMode("hide");
title = getTitle();
run("Set Measurements...", "area mean standard min centroid display redirect=None decimal=3");
deleteUnmatchedROIs();
deleteROIsOneNucleusMultipleCells();
run("From ROI Manager");
reportResults(tableTitle);
setBatchMode("show");

function reportResults(tableTitle) {
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
			Table.set(i+" cell", currentIndex, (j/2)+1, tableTitle);	
			Table.set("c"+i+" X", currentIndex, xN, tableTitle);	
			Table.set("c"+i+" Y", currentIndex, yN, tableTitle);	
			Table.set("c"+i+" nucleus area", currentIndex, areaN, tableTitle);	
			Table.set("c"+i+" nucleus mean int.", currentIndex, meanN, tableTitle);	
			Table.set("c"+i+" nucleus stdDev", currentIndex, stdDevN, tableTitle);	
			Table.set("c"+i+" membrane area", currentIndex, area, tableTitle);	
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
