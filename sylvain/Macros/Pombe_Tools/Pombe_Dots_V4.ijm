// MACRO  : Remi BORDONNE juillet 2019
// QUANTIFICATION du nb et de l'intensité de "dots" dans les cellules de Pombe
// Ce qu'on veut : Par cellule le nb et l'intensité des points
//
//*******DEROULEMENT du programme**********************************************
// 1. définition des variables
// 2. Boucle FOR pour batcher sur toutes les images d'un répertoire
// 3. traitement de l'image pour améliorer la première segmentation des cellules (correction de BGR, filtre median)
// 4. premiere segmentaion des cellules via un seuillage classique "Li Dark"
// 5. "analyse particle" + erosion en mode iteratif + sauvegarde des ROIs
// 6. Boucle FOR pour batcher sur l'ensemble des ROIS cells trouvées précédement
// 7. Calcule par cellule des intensités et écriture des résultats dans un fichier LOG
// 8.  Recherche des dots par un find maxima et élargissement pour créer une zone ROI
// 9. Boucle FOR pour batcher les ROI_dots et calculer quelques paramètres d'intensité par dot
// 10. Sauvegarde d'une image control avec contour cell et dots
//******************************************************************************

// 1. définition des variables
dir1 = getDirectory("Choose Source Directory");
dir2 = getDirectory("Choose the directory to save images");

list1 = getFileList(dir1);

run("Clear Results");
run("Set Measurements...", "area mean integrated redirect=None decimal=3");
run("Close All");

// 2. Boucle FOR pour batcher sur toutes les images d'un répertoire
for ( i=0; i<list1.length; i++)
	{
	
	open (dir1+list1[i]);
	run("Select None");
	name=getTitle();
	rename("image_Brute");
	
	// 3. traitement de l'image pour améliorer la première segmentation des cellules (correction de BGR, filtre median)
	run("Subtract Background...", "rolling=50");
	run("Duplicate...", " ");
	rename("duplicate");
	run("Median...", "radius=2");

	// 4. premiere segmentaion des cellules via un seuillage classique "Li Dark"
	setAutoThreshold("Li dark");

	// 5. "analyse particle" + erosion en mode iteratif + sauvegarde des ROIs
	run("Analyze Particles...", "  show=Masks exclude include");
	run("Options...", "iterations=6 count=1 do=Erode");
	run("Analyze Particles...", "size=500-4000 circularity=0.20-1.00 exclude clear add");
	m = roiManager("count");
	print("nb_celllules= "+m);
	roiManager("Save", dir2+"ROI_cells.zip");
	ROI=0;

	// 6. Boucle FOR pour batcher sur l'ensemble des ROIS cells trouvées précédement
	for (p=0; p<m; p++)
		{
		// 7. Calcule par cellule des intensités et écriture des résultats dans un fichier LOG
		selectWindow("image_Brute");
		roiManager("select", p);
		run("Enlarge...", "enlarge=5");
		roiManager("Measure");
		mean = getResult("Mean");
		IntDensity = getResult("IntDen");
		area = getResult("Area");
		ROI=ROI+1; 
		print(name+" ROI_Cell "+ROI+" Mean "+mean+" IntDen "+IntDensity+" area "+area);

		// 8.  Recherche des dots par un find maxima et élargissement pour créer une zone ROI
		run("Find Maxima...", "prominence=250 exclude output=[Point Selection]");
		run("Enlarge...", "enlarge=1");
		roiManager("Add");
		roiManager("Deselect");
		//save ROI dot
		roiManager("select", m);
		roiManager("Save", dir2+"ROI_dots.roi");
		//save sous format image avec cell et dots
		run("Flatten");
		saveAs("Tiff", dir2+name+"_cell_"+p);
		close();
		
		roiManager("Delete");
		roiManager("Deselect");
		roiManager("Delete");

		//split la region DOTS en plusieurs regions "dot" séparées les unes des autres
		roiManager("Open", dir2+"ROI_dots.roi");
		roiManager("Select", 0);
		roiManager("Split");
		roiManager("Show All with labels");
		nbDots = roiManager("count");
		print("nbDots= "+nbDots-1);

		ROI_Dot=0;

			// 9. Boucle FOR pour batcher les ROI_dots et calculer quelques paramètres d'intensité par dot
			for (k=1; k<nbDots; k++)
			{
			selectWindow("image_Brute");
			roiManager("select", k);
			roiManager("Measure");
			meanDot = getResult("Mean");
			IntDensityDot = getResult("IntDen");
			areaDot = getResult("Area");
			ROI_Dot=ROI_Dot+1;
			// Ecriture dans le fichier LOG
			print(name+" ROI_Dot "+ROI_Dot+" Mean "+meanDot+" IntDen "+IntDensityDot+" area "+areaDot);
			}
			
		print("-------------------");
		roiManager("Deselect");
		roiManager("Delete");
		roiManager("Open", dir2+"ROI_cells.zip");
			}		
		
		
	print("*******************");

	// 10. Sauvegarde d'une image control avec contour cell et dots
	selectWindow("image_Brute");
	roiManager("Show All with labels");
	run("Flatten");
	saveAs("Tiff", dir2+name);
	
	run("Close All");
	roiManager("Delete");
	}


	
	
	
	
