//FLORENCE RAGE
//18 MAI 2022
//TROUVE LE BEST FOCUS DANS UN STACK AVEC LE PLUGIN "FIND FOCUS SLICES"
//selectionne 3 plans autour de ce plan et fait une MIP

dir1 = getDirectory("Choose stack_Source Directory");
dir2 = getDirectory("Choose_result Directory");

list1 = getFileList(dir1);

redSuffix = "Cy3.tif";
outputDirectoryRed = dir2+"/"+replace(redSuffix, ".tif","");

greenSuffix = "GFP.tif";
outputDirectoryGreen = dir2+"/"+replace(greenSuffix, ".tif","");

setBatchMode(true);
mipOneChannel(redSuffix,outputDirectoryRed,list1);
mipOneChannel(greenSuffix,outputDirectoryGreen,list1);
setBatchMode(false);

/*
// boucle sur les images des diffÃ©rents dossiers
for (i=0; i<list1.length; i++) {
	if(endsWith(toLowerCase(list1[i]),toLowerCase(redSuffix))){
        open(dir1+list1[i]);
        //run("Bio-Formats Importer", "open=["+dir1+list1[i]+"] color_mode=Grayscale split_channels rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
   	 	name=getTitle();
		run("Find focused slices", "select=100 variance=0.000 edge verbose");
     
		selectWindow(name);
		m=getSliceNumber();
		//print(m);
		//min=m-3;
		min=maxOf(m-3, 1);
		//max=m+3;
		max = minOf(m+3, nSlices);
		//"Slice Keeper", "first="+min+" last="+max+" increment=1");
		//run("Z Project...", "projection=[Max Intensity]");
		run("Z Project...", "start="+min+" stop="+max+" projection=[Max Intensity]");
		save(outputDirectoryRed+"MIP_"+name);
		
		run("Close All");
	}
}*/

function mipOneChannel(fileSuffix,outputDirectory,fileList){ 
    File.makeDirectory(outputDirectory);
    
    for (i=0; i<fileList.length; i++) {
        if(endsWith(toLowerCase(fileList[i]),toLowerCase(fileSuffix))){
            open(dir1+fileList[i]);
            //run("Bio-Formats Importer", "open=["+dir1+fileList[i]+"] color_mode=Grayscale split_channels rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
            name=getTitle();
            run("Find focused slices", "select=100 variance=0.000 edge verbose");

            selectWindow(name);
            m=getSliceNumber();
            //print(m);
            //min=m-3;
            min=maxOf(m-3, 1);
            //max=m+3;
            max = minOf(m+3, nSlices);
            //"Slice Keeper", "first="+min+" last="+max+" increment=1");
            //run("Z Project...", "projection=[Max Intensity]");
            run("Z Project...", "start="+min+" stop="+max+" projection=[Max Intensity]");
            save(outputDirectory+"/MIP_"+name);
            
            run("Close All");
        }
    }
    
    outputFileList = getFileList(outputDirectory);
    if(outputFileList.length==0){
        File.delete(outputDirectory);
    }
}