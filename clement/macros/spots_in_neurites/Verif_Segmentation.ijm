
main();

function main() {

	dirMip  = getDirectory("MIP Directory (IN)"); // default: 2-MIP
	dirMask = getDirectory("Mask Directory (OUT)"); // default: 3-masks
	dirROI  = getDirectory("ROI Directory");

	// Tout fermer avant de lancer la macro
	run("Close All");

	mipList  = getFileList(dirMip);
	maskList = getFileList(dirMask);
	maskPrefix = "mask_";

	Table.create("Segmentation");

	// Ouvrir les images à traiter MIP et leur Mask correspondant
	current = 0;

	for (i = 0 ; i < maskList.length ; i++) {
		MaskTitle = maskList[i];

		open(joinPath(dirMask, MaskTitle));

		MipTitle = replace(MaskTitle, maskPrefix ,"");
		MipTitle = getFileWithCase(mipList, MipTitle);
		open(joinPath(dirMip, MipTitle));

		run("Enhance Contrast", "saturated=0.35");
		selectWindow(MaskTitle);	
		run("Select None");
		run("Create Selection");
		roiManager("Add");
		selectWindow(MipTitle);
		roiManager("Select", 0);

		waitForUser("[OK] - Mask is correct.\n[Shift + OK] - Mask is wrong.");

		roiName = IJ.pad(current, 3) + ".zip";
		Table.set("origin", current, replace(MipTitle, "MIP_", ""));
		Table.set("roi", current, roiName);

		if (isKeyDown("shift")) {
			Table.set("correct", current, "NO");
		} else {
			Table.set("correct", current, "YES");
		}
		
		roiManager("Save", joinPath(dirROI, roiName));
		roiManager("Delete");
		run("Close All");
		current++;
	}
	close("Roi Manager");
}


function getFileWithCase(namesList, name) {
    for (i = 0 ; i < namesList.length ; i++) {
        t1 = toLowerCase(name);
        t2 = toLowerCase(namesList[i]);
        if (t1.matches(t2)) {
            return namesList[i];
        }
    }
    return "-";
}


// Joins a new element to a path, considering that the first part doesn't necessarily ends with the path separator.
function joinPath(parent, leaf) {
    if (parent.endsWith(File.separator)) {
        return parent + leaf;
    } else {
        return parent + File.separator + leaf;
    }
}