gtImageID = getImageID();

roiManager("Delete");
run("To ROI Manager");
roiManager("Show None");
roiManager("Show All");
roiManager("Show All without labels");
roiManager("Combine");
run("Create Mask");
maskID = getImageID();

selectImage(gtImageID);
run("Select None");
selectImage(maskID);

selectWindow("spots ground-truth table");
XC = Table.getColumn("XC");
YC = Table.getColumn("YC");
R = Table.getColumn("Radius");
selectImage(maskID);
indices = newArray(0);
for (i = 0; i < XC.length; i++) {
	makeOval(XC[i]-R[i], YC[i]-R[i], 2*R[i], 2*R[i]);
	getStatistics(area, mean);
	if (mean==0) {
		indices = Array.concat(indices, i);
	}
}

selectImage(gtImageID);
for (i = 0; i < indices.length; i++) {
	makeOval(XC[i]-R[i], YC[i]-R[i], 2*R[i], 2*R[i]);
	Overlay.addSelection("cyan");
}
run("Select None");
