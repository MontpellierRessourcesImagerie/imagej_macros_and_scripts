dir=getDirectory("Choose a Directory");
fileList=getFileList(dir);

//---Boite de dialogue
Dialog.create("Acquisition parameters");

Dialog.addMessage("Tile scan parameters:");
Dialog.addNumber("Number of Row:", 4,0,3,"");
Dialog.addNumber("Number of Column:", 4,0,3,"");
Dialog.addNumber("Overlap:", 10,1,2,"%");

Dialog.addMessage("\nPosition parameters:");
Dialog.addNumber("Number of position/well:", 4,0,3,"");
Dialog.addNumber("Number of well:", 12,0,3,"");

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
WellNb=Dialog.getNumber();//Nb de puits
Ch0=Dialog.getCheckbox();
Ch1=Dialog.getCheckbox();
Ch2=Dialog.getCheckbox();

Mosaic=NbRow*NbColumn;//permet d'avoir le nombre d'image de la mosaique
ChannelNb=Ch0+Ch1+Ch2;
increment=Mosaic*ChannelNb;

//Creation de nouveax dossiers pour discriminer les images en fonctions du channel
CreateDirectory (Ch0, dir, ChannelArray[0]);
CreateDirectory (Ch1, dir, ChannelArray[1]);
CreateDirectory (Ch2, dir, ChannelArray[2]);

//Deplacement des fichiers dans les sous dossiers
n=0;
for (i=0; i<fileList.length; i=i+increment){ 
	for (k=0;k<increment;k++){
		name=dir+fileList[n];
		if (endsWith(name, ChannelArray[0]+".TIF")){
			File.rename(name, dir+ChannelArray[0]+"/"+fileList[n]);
		}
		if (endsWith(name, ChannelArray[1]+".TIF")){
			File.rename(name, dir+ChannelArray[1]+"/"+fileList[n]);
		}
		if (endsWith(name, ChannelArray[2]+".TIF")){
			File.rename(name, dir+ChannelArray[2]+"/"+fileList[n]);
		}
		n++;
	}
}

fileListTransPH=getFileList(dir+ChannelArray[0]);
fileListGFP=getFileList(dir+ChannelArray[1]);
fileListDAPI=getFileList(dir+ChannelArray[2]);

//reconstruction de la mosaique
setBatchMode(true);
GridStitching (NbRow, NbColumn, Overlap, dir, ChannelArray[0], fileListTransPH, "1");
GridStitching (NbRow, NbColumn, Overlap, dir, ChannelArray[1], fileListGFP, "2");
GridStitching (NbRow, NbColumn, Overlap, dir, ChannelArray[2], fileListDAPI, "3");


//---------------------------FONCTIONS--------------------------------

function CreateDirectory (Channel, directory, string){
	if (Channel==true){
		File.makeDirectory(directory+string);
	}
}

//bug a corriger : incrementation pas bonne, prendre en compte les 2 dossiers
function GridStitching (NumbX, NumbY, Percentage, directory, string, FileList, ChannelNumber){
	j=1;
	for (i=0; i<FileList.length; i=i+Mosaic){
		run("Grid/Collection stitching", "type=[Grid: snake by rows] order=[Right & Down                ] grid_size_x="+NumbX+" grid_size_y="+NumbY+" tile_overlap="+Percentage+" first_file_index_i="+i+" directory=["+directory+string+"/] file_names=12Puits-Mosaic4x4_{iiii}_w"+ChannelNumber+string+".tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 computation_parameters=[Save memory (but be slower)] image_output=[Fuse and display]");
		saveAs("tif", directory+string+"/"+string+"_position-"+j+".tif");
		j++;
	}
}
