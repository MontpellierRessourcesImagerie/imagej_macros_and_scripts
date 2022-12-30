var maskPrefix = "mask_";

macro "Verif Segmentation" {
	//Tout fermer avant de lancer la macro
	run("Close All");

	dirMip = getDirectory("Choose a directory - IN - MIP");
	dirMask = getDirectory("Choose a directory - OUT - Mask");
	dirROI = getDirectory("Choose a Directory to save ROI");

	fileList1 = getFileList(dirMip);
	fileList2 = getFileList(dirMask);

	// Ouvrir les images à traiter MIP et leur Mask correspondant
	for (i = 0; i < fileList2.length; i++) {
		MaskTitle = fileList2[i];
		open(dirMask + MaskTitle);

		MipTitle = replace(MaskTitle, maskPrefix ,"");
		open(dirMip + MipTitle);
		run("Enhance Contrast", "saturated=0.35");

		selectWindow(MaskTitle);	
		run("Select None");
		run("Create Selection");
		roiManager("Add");
		selectWindow(MipTitle);
		roiManager("Select", 0);

		waitForUser("Dire si oui ou non masque correct dans un fichier excel");
		
		roiManager("Save", dirROI + File.separator + i + ".zip");
		roiManager("Delete");
		run("Close All");
	}
}