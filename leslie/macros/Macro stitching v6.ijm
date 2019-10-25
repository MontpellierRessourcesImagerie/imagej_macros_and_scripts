dir=getDirectory("Choose a Directory");
fileList=getFileList(dir);

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
Ch1=Dialog.getCheckbox();
Ch2=Dialog.getCheckbox();
Ch3=Dialog.getCheckbox();

Mosaic=NbRow*NbColumn;//permet d'avoir le nombre d'image de la mosaique
ChannelNb=Ch1+Ch2+Ch3;
ChAvecND=ChannelNb+1;
FrameTot=Mosaic*Positions*ChannelNb;

if (ChannelDefault[0]==true){
	File.makeDirectory(dir+ChannelArray[0]);
}
if (ChannelDefault[1]==true){
	File.makeDirectory(dir+ChannelArray[1]);
}
if (ChannelDefault[2]==true){
	File.makeDirectory(dir+ChannelArray[2]);
}


increment=Mosaic*ChannelNb;
print(increment);

n=0;
for (i=0; i<fileList.length; i=i+increment){
	for (k=0;k<increment;k++){
		//name=dir+fileList[n];
		if (endsWith(dir+fileList[n], ChannelArray[0]+".TIF")){
			File.rename(dir+fileList[n], dir+ChannelArray[0]+"/"+fileList[n]);
		}
		if (endsWith(dir+fileList[n], ChannelArray[1]+".TIF")){
			File.rename(dir+fileList[n], dir+ChannelArray[1]+"/"+fileList[n]);
		}
		if (endsWith(dir+fileList[n], ChannelArray[2]+".TIF")){
			File.rename(dir+fileList[n], dir+ChannelArray[2]+"/"+fileList[n]);
		}
		n++;
	}
}

fileListTransPH=getFileList(dir+ChannelArray[0]);
fileListGFP=getFileList(dir+ChannelArray[1]);

setBatchMode(true);
for (i=0; i<fileListTransPH.length; i++) {
	open(dir+ChannelArray[0]+"/"+fileListTransPH[i]);
	if (i>1000){
		rename("transPH_"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_"+i+".tif");
	}
	if (i<1000 && i>=100){
		rename("transPH_0"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_0"+i+".tif");
	}
	if (i<100 && i>=10){
		rename("transPH_00"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_00"+i+".tif");
	}
	if (i<10){
		rename("transPH_000"+i);
		File.rename(dir+ChannelArray[0]+"/"+fileListTransPH[i], dir+ChannelArray[0]+"/"+"transPH_000"+i+".tif");
	}
}

for (i=0; i<fileListGFP.length; i++) {
	open(dir+ChannelArray[1]+"/"+fileListTransPH[i]);
	if (i>1000){
		rename("GFP_"+i);
		1
	}
	if (i<1000 && i>=100){
		rename("GFP_0"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListTransPH[i], dir+ChannelArray[1]+"/"+"GFP_0"+i+".tif");
	}
	if (i<100 && i>=10){
		rename("GFP_00"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListTransPH[i], dir+ChannelArray[1]+"/"+"GFP_00"+i+".tif");
	}
	if (i<10){
		rename("GFP_000"+i);
		File.rename(dir+ChannelArray[1]+"/"+fileListTransPH[i], dir+ChannelArray[1]+"/"+"GFP_000"+i+".tif");
	}
}



/*
run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+NbRow+" grid_size_y="+NbColumn+" tile_overlap="+Overlap+" first_file_index_i="+i+" directory=["+dir+ChannelArray[0]+"] file_names=MacroTEST{ii}_w1"+ChannelArray[0]+".tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+NbRow+" grid_size_y="+NbColumn+" tile_overlap="+Overlap+" first_file_index_i="+j+" directory=["+dir+ChannelArray[1]+"] file_names=MacroTEST{ii}_w2"+ChannelArray[1]+".tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
*/