//MACRO pour Barrah - IGMM
// Sylvain deRossi - juin_2018

//Permet de faire un MERGE d'images prises (timelapse, 2colors) sur l'OLYMPUS microscope via MetaMorph (MDA) + sauver en AVI
//Format des time series TIF - 2 colors DsREd et CY5 - Z stack en CY5 et pas en transmission
//	"name"_w2CY5_s"i"_t"j"
//	"name"_w2CY5_s"i"_t"j"


dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory ");

list = getFileList(dir1);

Number_Positions=getNumber("Number of positions", 1);
Number_Z=getNumber("Number of Z", 1);

open(dir1+list[0]);
name=getTitle();
index=indexOf(name, "_w");
name=substring(name, 0, index);
close();

for (i=1; i<Number_Positions+1; i++) {
	run("Image Sequence...", "open=["+dir1+"] file=transRC_s"+i+"_ sort");
	rename(name+"trans");
	nameTrans=getTitle();
	run("Image Sequence...", "open=["+dir1+"] file=CY5_s"+i+"_ sort");
	rename(name+"CY5");
	run("Grouped Z Project...", "projection=[Max Intensity] group="+Number_Z);
	rename(name+"MAX_CY5");
	nameCY5=getTitle();
	close(name+"CY5");

	run("Merge Channels...", "c1=["+nameCY5+"] c4=["+nameTrans+"] create");
	close(name+"trans");

	save(dir2+name+"_MERGE_s_"+i);
	run("AVI... ", "compression=JPEG frame=7 save="+dir2+"Merge_s_"+i);

	close();   	 	 
}
