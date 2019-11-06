dir=getDirectory("Choose a Directory");
fileList=getFileList(dir);
Array.show(fileList);

//---Boite de dialogue
Dialog.create("Acquisition parameters");

Dialog.addMessage("Tile scan parameters:");
Dialog.addNumber("Number of Row:", 4,0,3,"");
Dialog.addNumber("Number of Column:", 4,0,3,"");
Dialog.addNumber("Overlap:", 10,1,2,"%");

Dialog.addMessage("\nPosition parameters:");
Dialog.addNumber("Number of position/well:", 1,0,3,"");
Dialog.addNumber("Number of well:", 1,0,3,"");

Dialog.addMessage("\nAcquired Channels:");
ChannelArray=newArray("transPH","GFP","DAPI");
ChannelDefault=newArray(true, true, false);
Dialog.addCheckboxGroup(3,1,ChannelArray, ChannelDefault);

Dialog.show();

//---Recuperation des infos de la boite de dialogue
NbRow=Dialog.getNumber();
NbColumn=Dialog.getNumber();
Overlap=Dialog.getNumber();
Positions=Dialog.getNumber();//Nb de position par puits
WellNb=Dialog.getNumber();
Ch0=Dialog.getCheckbox();
Ch1=Dialog.getCheckbox();
Ch2=Dialog.getCheckbox();

Mosaic=NbRow*NbColumn;//permet d'avoir le nombre d'image de la mosaique
ChannelNb=Ch0+Ch1+Ch2;
increment=Mosaic*ChannelNb;


if (Ch0==true){
	File.makeDirectory(dir+ChannelArray[0]);
}
if (Ch1==true){
	File.makeDirectory(dir+ChannelArray[1]);
}
if (Ch2==true){
	File.makeDirectory(dir+ChannelArray[2]);
}


n=0;
for (i=0; i<fileList.length; i=i+increment){
	for (k=0;k<increment;k++){
		name=dir+fileList[n];
		if (endsWith(name, ChannelArray[0]+".TIF")){
			File.rename(name, dir+ChannelArray[0]+"/"+fileList[n]);
			print(name);
		}
		if (endsWith(name, ChannelArray[1]+".TIF")){
			File.rename(name, dir+ChannelArray[1]+"/"+fileList[n]);
			print(name);
		}
		if (endsWith(name, ChannelArray[2]+".TIF")){
			File.rename(name, dir+ChannelArray[2]+"/"+fileList[n]);
			print(name);
		}
		n++;
	}
}

//----A faire : Rajouter le canal dapi si besoin ou faire une condition pour la suite de la macro et essayer d'utiliser les fonctions
fileListTransPH=getFileList(dir+ChannelArray[0]);
fileListGFP=getFileList(dir+ChannelArray[1]);

setBatchMode(true);
for (i=0; i<fileListTransPH.length; i++){
	open(dir+ChannelArray[0]+"/"+fileListTransPH[i]);
	if (i>1000){
		rename(ChannelArray[0]+"_"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_"+i+".tif");
		close(ChannelArray[0]+"_"+i);
	}
	if (i<1000 && i>=100){
		rename(ChannelArray[0]+"_0"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_0"+i+".tif");
		close(ChannelArray[0]+"_0"+i);	
	}
	if (i<100 && i>=10){
		rename(ChannelArray[0]+"_00"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_00"+i+".tif");
		close(ChannelArray[0]+"_00"+i);	
	}
	if (i<10){
		rename(ChannelArray[0]+"_000"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_000"+i+".tif");
		close(ChannelArray[0]+"_000"+i);	
	}
}

for (i=0; i<fileListGFP.length; i++) {
	open(dir+ChannelArray[1]+"/"+fileListGFP[i]);
	if (i>1000){
		rename(ChannelArray[1]+"_"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListGFP[i], dir+ChannelArray[1]+"/"+"GFP_"+i+".tif");
		close(ChannelArray[1]+"_"+i);	
	}
	if (i<1000 && i>=100){
		rename(ChannelArray[1]+"_0"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListGFP[i], dir+ChannelArray[1]+"/"+"GFP_0"+i+".tif");
		close(ChannelArray[1]+"_0"+i);	
	}
	if (i<100 && i>=10){
		rename(ChannelArray[1]+"_00"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListGFP[i], dir+ChannelArray[1]+"/"+"GFP_00"+i+".tif");
		close(ChannelArray[1]+"_00"+i);	
	}
	if (i<10){
		rename(ChannelArray[1]+"_000"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListGFP[i], dir+ChannelArray[1]+"/"+"GFP_000"+i+".tif");
		close(ChannelArray[1]+"_000"+i);	
	}
}

j=1;
for (i=0; i<fileList.length; i=i+increment){
	run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+NbRow+" grid_size_y="+NbColumn+" tile_overlap="+Overlap+" first_file_index_i="+i+" directory=["+dir+ChannelArray[0]+"/] file_names="+ChannelArray[0]+"_{iiii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
	saveAs("tif", dir+ChannelArray[0]+"/position-"+j+".tif");
	j++;
}

k=1;
for (i=0; i<fileList.length; i=i+increment){
	run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+NbRow+" grid_size_y="+NbColumn+" tile_overlap="+Overlap+" first_file_index_i="+i+" directory=["+dir+ChannelArray[1]+"/] file_names="+ChannelArray[1]+"_{iiii}.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
	saveAs("tif", dir+ChannelArray[1]+"/position-"+k+".tif");
	k++;
}



