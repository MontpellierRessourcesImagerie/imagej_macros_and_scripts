
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

	// Ouvre les images, et split les channels
	open (dir1+list1[i]);
	name=getTitle();
	rename("stack");
	run("Split Channels");
	selectWindow("C1-stack");
	close();
	
	//partie interctive pour selectionner les cellules à analyser
	selectWindow("C2-stack");
	title1 = "WaitForUser";
  	msg1 = "Select ROIs and Press t";
  	waitForUser(title1, msg1);
  	roiManager("Save", dir2+list1[i]+".zip");
	n = roiManager("count");
	print("NB_CELLs= "+n);
	roiManager("Show None");
	roiManager("Show All");
	roiManager("Delete");
	
	//Traitement pour faciliter le seuillage des objets du channel vert	
	selectWindow("C2-stack");
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
		selectWindow("C2-stack");
		roiManager("select", j);
		print("cell_"+j);

	  	run("Analyze Particles...", "size=0.20-Infinity show=Nothing clear add");
	  	
	  	m = roiManager("count");
	  	print("NB_ROIs= "+m);
	  	roiManager("Save", dir2+list1[i]+"_ROI_"+j+".zip");
		
		// Open 405 image et duplique pour sauver les ROI positives sur une image405
		selectWindow("C3-stack");
		run("Duplicate...", "title=CTR");
		run("RGB Color");
		setForegroundColor(255, 255, 0);

		selectWindow("C3-stack");
		run("Set Measurements...", "mean limit display redirect=None decimal=3");
		posROI=0;
		
			for (p=0; p<m; p++)
				{
				roiManager("select", p);
				roiManager("Measure");
				mean_405=getResult("Mean");

					if (mean_405>=threshold) {
					print(name+" Cell "+j+" ROI "+p+" Mean "+mean_405+" Positiv_ROI");
					posROI = posROI+1;
					selectWindow("CTR");
					roiManager("select", p);
					run("Fill", "slice");
					}
					else {print(name+" Cell "+j+" ROI "+p+" Mean "+mean_405+" Negativ_ROI");}
					
				//roiManager("Show All");
				//roiManager("Show All without labels");
				selectWindow("C3-stack");
				
				}
		selectWindow("CTR");
		saveAs("Jpeg", dir2+list1[i]+"_cell_"+j+"_positivROI");
		close();
			
		print("Nb_ROI_positiv="+posROI);
		
		roiManager("Show All");
		roiManager("Show All without labels");
		selectWindow("C3-stack");
		run("Flatten");
		saveAs("Jpeg", dir2+list1[i]+"_cell_"+j);
		close();
		
		roiManager("Show All");
		roiManager("Delete");
		
		wait(1000);
		}
run("Close All");			
}		