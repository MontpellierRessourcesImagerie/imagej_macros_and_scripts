//FLORENCE RAGE
//18 MAI 2022
//TROUVE LE BEST FOCUS DANS UN STACK AVEC LE PLUGIN "FIND FOCUS SLICES"
//selectionne 3 plans autour de ce plan et fait une MIP

dir1 = getDirectory("Choose stack_Source Directory");
dir2 = getDirectory("Choose_result Directory");

redSuffix = "w1Cy3.tif";
outputDirectoryRed = dir2+"/"+replace(redSuffix, ".tif","");

greenSuffix = "w2GFP.tif";
outputDirectoryGreen = dir2+"/"+replace(greenSuffix, ".tif","");



list = getFileList(dir1);
list = filterRedChannelImages(list);


setBatchMode(true);
mipTwoChannels(dir1, list);
setBatchMode(false);

function mipTwoChannels(dir, fileList){ 
    File.makeDirectory(outputDirectoryRed);
    File.makeDirectory(outputDirectoryGreen);
    
    for (i=0; i<fileList.length; i++) {
        open(dir+fileList[i]);
        m = getFocusedSliceNumber();
        mipProjectAroundFocus(m);
        save(outputDirectoryRed+"/MIP_"+fileList[i]);
        close();
        
        parts = split(redSuffix, ".");
        redChannelName = parts[0];
        parts = split(greenSuffix, ".");
        greenChannelName = parts[0];
        
        greenFile = replace(fileList[i], redChannelName, greenChannelName);
        if (!File.exists(dir+greenFile)) {
            run("Close All");
            continue;
        }
        open(dir+greenFile);
        mipProjectAroundFocus(m);
        save(outputDirectoryGreen+"/MIP_"+greenFile);
        
        run("Close All");
    }
    outputFileList = getFileList(outputDirectoryGreen);
    if(outputFileList.length == 0) {
        File.delete(outputDirectoryGreen);
    }
}

function mipProjectAroundFocus(slice) {
    name=getTitle();
    min=maxOf(slice-3, 1);
    max = minOf(slice+3, nSlices);
    run("Z Project...", "start="+min+" stop="+max+" projection=[Max Intensity]");
}

function filterRedChannelImages(list) {
    newList = newArray(0);
    for (i = 0; i < list.length; i++) {
        file = list[i];
        if (endsWith(toLowerCase(file), toLowerCase(redSuffix))) {
            newList = Array.concat(newList, file);
        }
    }
    return newList;
}

function getFocusedSliceNumber() {
    run("Find focused slices", "select=100 variance=0.000 edge verbose");
    close();
    m = getSliceNumber();
    return m;
}
