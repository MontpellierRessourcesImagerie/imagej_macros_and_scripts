//AIM : OPEN h5 temporal series, copy 8bits and convert in MIP for FUSION, save Tiff or h5
//S.DeRossi_2017

dir1= getDirectory("Input directory");
dir2= getDirectory("Choose output directory");
list= getFileList(dir1);
print(list.length);

//Création boite de dialogue pour le choix de la reconstruction des images CAM LEFT / CAM RIGHT / FUSED
  rows = 3;
  columns = 1;
  n = rows*columns;
  labels = newArray(n);
  defaults = newArray(n);
  labels[0]="Cam_Left";
  labels[1]="Cam_Right";
  labels[2]="Fused";
  for (i=0; i<n; i++) {
    if ((i%2)==0) defaults[i] = true;
    else defaults[i] = false;
  }
  Dialog.create("MONTAGE");
  Dialog.addCheckboxGroup(rows,columns,labels,defaults);
  Dialog.show();
  
  if (Dialog.getCheckbox()==1) {choix1="Cam_Left";}
  	else {choix1="nothing";}
  if (Dialog.getCheckbox()==1) {choix2="Cam_Right";}
  	else {choix2="nothing";} 	
  if (Dialog.getCheckbox()==1) {choix3="Fused";}
  	 else {choix3="nothing";}
  	 
//Creation de la boite de dialogue pour choisir la resolution
	Dialog.create("");
	items = newArray("111", "222", "444");
	items2 = newArray(".h5", ".tif");
	items3 = newArray("yes", "no");
	Dialog.addRadioButtonGroup("SAVE AS", items2, 2, 1, ".tif");
	Dialog.addRadioButtonGroup("ONLY FOR FUSED IMAGES\n\n111 means best resolution\n222 means half resolution\n444 means quarter resolution", items, 3, 1, "111");
	Dialog.addRadioButtonGroup("MIP", items3, 2, 1, "no");
	
//Affichage boite de dialogue et creation des variables associes
	Dialog.show;
	ext=Dialog.getRadioButton();
	res="\Data"+Dialog.getRadioButton();
	MIP=Dialog.getRadioButton();

//construction des variables nom des images en fonction des choix de l'utilisateur
	if (substring(choix3, 4)=="d") { name="Time";}
	if (substring(choix2, 5, 6)=="i") { name="Cam_Right_";}
	if (substring(choix1, 5, 6)=="e") { name="Cam_Left_";}

//Definition des variables supplementaires en option
	if (endsWith(MIP, "s")==true) {NBZ=getNumber("Number of Z slices",0);}
	if (endsWith(ext, "5")==true) {comp=getNumber("h5 Compression from 0 to 9",0);}

//Ouverture du 1er stk pour definir la ROI
	if (substring(choix3, 4)=="d") { run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"00000.h5] datasetnames="+res+" nframes=1 nchannels=1");}
	else {run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"00000.h5] datasetnames=/Data nframes=1 nchannels=1");}
//Recherche du max value de la pile d'images	
	Maxi=0;
	run("Set Measurements...", "min redirect=None decimal=3");
	for (i=1; i<nSlices+1; i++) {
		setSlice(i);
		run("Measure");
		if (getResult("Max", 0) > Maxi){ Maxi=getResult("Max", 0);}
		run("Clear Results");
	}

	roiManager("Show All");
	waitForUser("draw a ROI");
	run("ROI Manager...");
	roiManager("Add");
	roiManager("Select", 0);
	//Roi.getBounds(x, y, width, height);
	//print (x, y, width, height); 
	close();
	Left=0;

//PROGRAMME PRINCIPAL
	if (substring(choix1, 5, 6)=="e") {
	name="Cam_Left_";
	print(choix1);
	OpenList();
	Left=1;
	}

	if (substring(choix2, 5, 6)=="i") {
	name="Cam_Right_";
	run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"00000.h5] datasetnames=/Data nframes=1 nchannels=1");
	roiManager("Select", 0);
	Roi.getBounds(x, y, width, height);
	Roi.move(2048-x-width,y);
	roiManager("Update");
	print(choix2);
	OpenList();
	}

	if (substring(choix3, 4)=="d") {
	name="Time";
	print(choix3);
	OpenList();
	}	
	
// LES FONCTIONS du programme

function CropAndSave(){
	setMinAndMax(0, Maxi);
	run("8-bit");
	if (endsWith(MIP, "s")==true) {run("Z Project...", "projection=[Max Intensity]");}
	roiManager("Select", 0);
	run("Crop");
		if (endsWith(ext, "f")==true) { saveAs("Tiff", dir2+name+"_"+i+".tif");}
		if (endsWith(ext, "5")==true) { run("Scriptable save HDF5 (new or replace)...", "save="+dir2+res+"_"+name+"_"+i+".h5 dsetnametemplate=/t{t}/channel{c} formattime=%d formatchannel=%d compressionlevel="+comp+"");}
	run("Close All");
}

function OpenList(){
	//Boucle sur les images comprises entre 1 et 10
	if ((list.length<10) && (substring(choix3, 4)=="d")) {
		for (i=0; i<10; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"0000"+i+".h5] datasetnames="+res+" nframes=1 nchannels=1");
			CropAndSave();}
	}
	if ((list.length<10) && (substring(choix3, 4)!="d")) {
		for (i=0; i<((list.length-2)/2); i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"0000"+i+".h5] datasetnames=/Data nframes=1 nchannels=1");
			CropAndSave();}
	}
	//Boucle sur les images comprises entre 10 et 100
	if ((9<list.length) && (list.length<100) && (substring(choix3, 4)=="d")) {
		
		for (i=0; i<10; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"0000"+i+".h5] datasetnames="+res+" nframes=1 nchannels=1");
			CropAndSave();}
		for (i=10; i<100; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"000"+i+".h5] datasetnames="+res+" nframes=1 nchannels=1");
			CropAndSave();}
	}
	if ((9<list.length) && (list.length<100) && (substring(choix3, 4)!="d")) {
		
		for (i=0; i<10; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"0000"+i+".h5] datasetnames=/Data nframes=1 nchannels=1");
			CropAndSave();}
		for (i=10; i<((list.length-2)/2); i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"000"+i+".h5] datasetnames=/Data nframes=1 nchannels=1");
			CropAndSave();}
	}
	//Boucle sur les images comprises entre 100 et 1000
	if ((99<list.length) && (list.length<1000) && (substring(choix3, 4)=="d")) {

		for (i=0; i<10; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"0000"+i+".h5] datasetnames="+res+" nframes=1 nchannels=1");
			CropAndSave();}
		for (i=10; i<100; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"000"+i+".h5] datasetnames="+res+" nframes=1 nchannels=1");
			CropAndSave();}
		for (i=100; i<1000; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"00"+i+".h5] datasetnames="+res+" nframes=1 nchannels=1");
			CropAndSave();}
	}
	if ((99<list.length) && (list.length<1000) && (substring(choix3, 4)!="d")) {
		for (i=0; i<10; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"0000"+i+".h5] datasetnames=/Data nframes=1 nchannels=1");
			CropAndSave();}
		for (i=10; i<100; i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"000"+i+".h5] datasetnames=/Data nframes=1 nchannels=1");
			CropAndSave();}
		for (i=100; i<((list.length-2)/2); i++) {
			run("Scriptable load HDF5...",  "load=" + "["+dir1+"\\"+name+"00"+i+".h5] datasetnames=/Data nframes=1 nchannels=1");
			CropAndSave();}
	}
	}

