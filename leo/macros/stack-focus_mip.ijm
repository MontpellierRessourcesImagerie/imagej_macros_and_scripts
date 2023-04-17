// FLORENCE RAGE
// 18 MAI 2022
// TROUVE LE BEST FOCUS DANS UN STACK AVEC LE PLUGIN "FIND FOCUS SLICES"
// selectionne 3 plans autour de ce plan et fait une MIP

dir1        = getDirectory("Choose stack_Source Directory");
dir2        = getDirectory("Choose_result Directory");
slicesTol   = getNumber("Slices tolerance", 3);
redSuffix   = getString("redSuffix", "");
greenSuffix = getString("greenSuffix", "");

splittedRed    = split(redSuffix, ".");
splittedGrn    = split(greenSuffix, ".");

outputDirectoryRed   = joinPath(dir2, splittedRed[0]);
outputDirectoryGreen = joinPath(dir2, splittedGrn[0]);

IJ.log("Exporting red to: " + outputDirectoryRed);
IJ.log("Exporting green to: " + outputDirectoryGreen);

//////////////////////////////////////////////////////////////////////////////

list = filterRedChannelImages(getFileList(dir1));
setBatchMode(true);
mipTwoChannels(dir1, list);
setBatchMode(false);
IJ.log("DONE.");

//////////////////////////////////////////////////////////////////////////////

// Joins a new element to a path, considering that the first part doesn't necessarily ends with the path separator.
function joinPath(parent, leaf) {
    if (parent.endsWith(File.separator)) {
        return parent + leaf;
    } else {
        return parent + File.separator + leaf;
    }
}

function mipTwoChannels(dir, fileList) { 
    File.makeDirectory(outputDirectoryRed);
    File.makeDirectory(outputDirectoryGreen);
    
    for (i = 0 ; i < fileList.length ; i++) {
        open(joinPath(dir, fileList[i]));
        IJ.log("Processing: " + getTitle() + " (" + getImageID() + ")");
        m = getFocusedSliceNumber();
        mipProjectAroundFocus(m);
        save(joinPath(outputDirectoryRed, "MIP_" + fileList[i]));
        close();
        
        parts = split(redSuffix, ".");
        redChannelName = parts[0];
        parts = split(greenSuffix, ".");
        greenChannelName = parts[0];
        
        greenFile = replace(fileList[i], redChannelName, greenChannelName);
        
        if (!File.exists(joinPath(dir, greenFile))) {
            run("Close All");
            continue;
        }
        
        open(joinPath(dir, greenFile));
        mipProjectAroundFocus(m);
        save(joinPath(outputDirectoryGreen, "MIP_" + greenFile));
        
        run("Close All");
    }
    
    outputFileList = getFileList(outputDirectoryGreen);

    if(outputFileList.length == 0) {
        d = File.delete(outputDirectoryGreen);
        if (d) { IJ.log("\"" + outputDirectoryGreen + "\"" + " deleted."); }
    }
}

function mipProjectAroundFocus(slice) {
    min = maxOf(slice - slicesTol, 1);
    max = minOf(slice + slicesTol, nSlices);
    run("Z Project...", "start="+min+" stop="+max+" projection=[Max Intensity]");
}

function filterRedChannelImages(list) {
    newList = newArray(0);
    for (i = 0 ; i < list.length ; i++) {
        file = list[i];
        if (endsWith(toLowerCase(file), toLowerCase(redSuffix))) {
            newList = Array.concat(newList, file);
        }
    }
    IJ.log(newList.length + " files found.");
    return newList;
}

function getFocusedSliceNumber() {
    run("Find focused slices", "select=100 variance=0.000 edge");
    close();
    sl = getSliceNumber();
    IJ.log("Most in-focus slice: " + sl);
    return sl;
}
