
dir1 = getDirectory("Choose Source Directory");
dir2 = getDirectory("Choose the directory to save images");
threshold = getNumber("Enter the threshold value -> positiv405", 10000);

list1 = getFileList(dir1);

run("Set Measurements...", "area limit display redirect=None decimal=3");
run("Close All");

roiManager("Show None");
roiManager("Show All");
run("Clear Results");

for ( i=0; i<list1.length; i++)
	{

	roiManager("Show None");
	roiManager("Show All");
	//Ouvre les images - split les channels - duplique les images verte-bleue et fait un combine appelé RGB
	open (dir1+list1[i]);
	name=getTitle();
	print(name);
	rename("stack");
	run("Split Channels");
	selectWindow("C1-stack");
	run("Duplicate...", "title=image488");
	selectWindow("C2-stack");
	run("Duplicate...", "title=image405");
	
	//partie interctive pour selectionner les cellules à analyser
	selectWindow("C2-stack");
	title1 = "WaitForUser";
  	msg1 = "Select 'C2-stack' image then draw ROI and Press t";
  	waitForUser(title1, msg1);
  	roiManager("Save", dir2+list1[i]+".zip");
	n = roiManager("count");
	print("NB_CELLs= "+n);
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Delete");
	
	//Traitement pour faciliter le seuillage des objets du channel vert	
	selectWindow("C1-stack");
	run("Unsharp Mask...", "radius=3 mask=0.6");
	run("Median...", "radius=2");
	run("Threshold...");
	title2 = "WaitForUser";
	msg2 = "Fix the threshold for green image,  then click \"OK\".";
	waitForUser(title2, msg2);
	  	

	// Boucle sur les cellules precemment dessinees
	for (j=0; j<n; j++)
		{
		
		roiManager("open", dir2+list1[i]+".zip");
		roiManager("Show All");
		selectWindow("C1-stack");
		roiManager("select", j);
		print("cell_"+j+1);

	  	run("Analyze Particles...", "size=0.20-Infinity show=Nothing clear add");
	  	
	  	m = roiManager("count");
	  	print("NB_ROIs= "+m);
	  	roiManager("Save", dir2+list1[i]+"_ROI_"+j+".zip");
		
		// Open 405 image et duplique pour sauver les ROI positives sur une image405
		selectWindow("C2-stack");
		run("Duplicate...", "title=CTR");
		run("RGB Color");
		setForegroundColor(255, 255, 0);

		run("Merge Channels...", "c2=image488 c5=image405 keep");

		selectWindow("C2-stack");
		run("Set Measurements...", "mean limit display redirect=None decimal=3");
		posROI=0;
		
			for (p=0; p<m; p++)
				{
				roiManager("select", p);
				roiManager("Measure");
				mean_405=getResult("Mean");

					if (mean_405>=threshold) {
					print(name+" Cell "+j+" ROI "+p+1+" Mean "+mean_405+" Positiv_ROI");
					posROI = posROI+1;
					selectWindow("CTR");
					roiManager("select", p);
					run("Fill", "slice");

					selectWindow("RGB");
					roiManager("select", p);
					run("Fill", "slice");
					}
					else {print(name+" Cell "+j+" ROI "+p+1+" Mean "+mean_405+" Negativ_ROI");}
					
				//roiManager("Show All");
				//roiManager("Show All without labels");
				selectWindow("C2-stack");
				
				}
		selectWindow("CTR");
		saveAs("Jpeg", dir2+list1[i]+"_cell_"+j+1+"_positivROI_405");
		close();
		
		selectWindow("RGB");
		saveAs("Jpeg", dir2+list1[i]+"_cell_"+j+1+"_positivROI_COMBINE");
		close();		
			
		print("Nb_ROI_positiv="+posROI);
		
		roiManager("Show All");
		roiManager("Show All without labels");
		selectWindow("C2-stack");
		run("Flatten");
		saveAs("Jpeg", dir2+list1[i]+"_cell_"+j+1);
		close();

		selectWindow("image488");
		roiManager("Show All");
		roiManager("Show All without labels");
		run("Flatten");
		saveAs("Jpeg", dir2+list1[i]+"_cell_"+j+1+"_488");
		close();
		
		roiManager("Show All");
		roiManager("Delete");
		
		wait(1000);
		}
run("Close All");			
}		