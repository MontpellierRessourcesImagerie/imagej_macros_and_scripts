// leave slot between text tool and magnifying glass unused
macro "Unused Tool-1 - " {}  

//CONVERT_to_MIP ******************************************
//Convertir les fichiers TIFF (Z + temps) en MIP Z + temps
// *****************************************************************
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

// CONVERT_STACKS_to_TIFFseries *********************
// Convertir les fichiers stacks en serie TIFF
// *****************************************************************
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

// CONVERT_TIFF_to_8bits **********************************
// Convertir les fichiers TIFF au format 8 bits
// *****************************************************************
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

// CREATE MIP_&_concatenate **********************************
// Convertir les fichiers TIFF (Z + temps) en MIP Z + temps
// prend en compte le fait d'avoir plusieurs blocs tiff pour concatenation
// *****************************************************************
macro "CONVERT_MIP_&_CONCATENATE Action Tool- C059T1909MT6909 T9909C" {
	
// "partie interactive" demande à l'utilisateur de paramètres d'entrées	
	Number_Zslices=getNumber("Number_Zslices", 0);
	Number_Time_For_Concatenation=getNumber("Number of timepoints for concatenation data ", 0);
	Number_Colors=getNumber("Number_Colors", 1);
	
	dir1 = getDirectory("Choose Source Directory ");
	dir2 = getDirectory("Choose Destination Directory ");
	dir3 = getDirectory("Choose Destination Directory for concatenate images");
	
//Définition de la liste d'images dans le dossier d'entrée
	list = getFileList(dir1);
	
//Boucle de création des MIP
	for (i=0; i<list.length; i++) {
   		open(dir1+list[i]);
		run("Grouped Z Project...", "projection=[Max Intensity] group=Number_Zslices");
		name=getTitle();
		save(dir2+name);
		run("Close All");
	}
	
//Définition de la liste dans le dossier MIP			
	list2 = getFileList(dir2);

//variables associées à la suite du programme sur la concatenation
	listCONC = list2.length/Number_Time_For_Concatenation;
	inc=0;
	inc2=1;
	coef=Number_Time_For_Concatenation * Number_Colors;

//Boucle des concatenations
	for (j=0; j<list2.length; j) {

		for	(c=0; c<Number_Colors; c++) {
			
			for (k=0; k<Number_Time_For_Concatenation+Number_Colors; k) {
				open(dir2+list2[j+c+k]);
				inc=inc+1;
				k=k+Number_Colors;
				name2=getTitle();
				name2=replace(name2,".tif","_");
				rename("stack_"+inc);
			}
		
			conc="";
			
			for (z=1; z<=Number_Time_For_Concatenation; z++) {
				conc=conc+" image"+z+"=stack_"+z;
				print(conc);
			}
		
			run("Concatenate...",conc);
			save(dir3+name2+"POS_"+inc2);
			run("Close All");
			inc=0;
		}
		j=j+coef;
		inc2=inc2+1;

	}
}
