// leave slot between text tool and magnifying glass unused
macro "Unused Tool-1 - " {}  

//CONVERT_to_MIP *********************************************
//Convertir les fichiers TIFF (Z + temps) en MIP Z + temps
// ***********************************************************
macro "CONVERT_to_MIP Action Tool- C059T1909MT7909IT9909P" {
	Number_Zslices=getNumber("Number_Zslices", 0);

	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");

	list = getFileList(dir1);

	for (i=0; i<list.length; i++) {
   	 	open(dir1+list[i]);
		run("Grouped Z Project...", "projection=[Max Intensity] group=Number_Zslices");
		name=getTitle();
		save(dir2+name);
		run("Close All");
	}

}

// CONVERT_STACKS_to_TIFFseries *******************************
// Convertir les fichiers stacks en serie TIFF
// ************************************************************
macro "CONVERT_STACKS_to_TIFFseries Action Tool- C059T1909TT6909IT9909F" {

	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");

	list = getFileList(dir1);

	for (i=0; i<list.length; i++) {
    	open(dir1+list[i]);
		imagename=getTitle();
		run("Image Sequence... ", "format=TIFF start=0 digits=4 use save=[dir2]");
		close();
	}
}

// CONVERT_TIFF_to_8bits **************************************
// Convertir les fichiers TIFF au format 8 bits
// ************************************************************
macro "CONVERT_TIFF_to_8bits Action Tool- C059T19098T6909 T9909b" {

	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");

	list = getFileList(dir1);

	for (i=0; i<list.length; i++) {
    	open(dir1+list[i]);
		name=getTitle();
		run("8-bit");
		save(dir2+name);
		close();
	}
}

// APPLY_B&C**************************************************
// Apply automatic B&C (brightness and contras
// ************************************************************
macro "APPLY_B&C Action Tool- C059T1909BT6909&T9909C" {

	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");
	
	list = getFileList(dir1);
	
	for ( i=0; i<list.length; i++) {
		open (dir1+list[i]);
		name=getTitle();
		resetMinAndMax();
		run("Enhance Contrast", "saturated=0.35");
		saveAs("Tiff", dir2+name);
		close();
	}
}