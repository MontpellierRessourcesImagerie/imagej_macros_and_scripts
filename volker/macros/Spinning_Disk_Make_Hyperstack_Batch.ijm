/***
 * 
 * Spinning Disk Make Hyperstack Batch
 * 
 * Creates hyperstacks from multi-channel spinning disk z-stack images. The images 
 * must be in a folder structure like this:
 * 
 * <basefolder>/<image1>/<channel1>/
 * <basefolder>/<image1>/<channel2>/
 * <basefolder>/<image2>/<channel1>/
 * <basefolder>/<image2>/<channel2>/
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/
CHANNEL_COLORS = newArray("Blue", "Green"); 
MIN_DISPLAY = newArray(90, 88);
MAX_DISPLAY = newArray(177, 306);
CONVERT_TO_8BIT = false;

inDir = getDirectory("Please select the source directory");
outDir = getDirectory("Pease select the destination directory");
setBatchMode(true);
fishDirs = getFoldersIn(inDir);
for (i=0; i<fishDirs.length; i++) {
    fishDir = fishDirs[i];
    IJ.log("processing image "  + (i+1) + " of " +  fishDirs.length + " (" + fishDir + ")");
    channelDirs = getFoldersIn(fishDir);
    Array.sort(channelDirs);
    channelTitles = newArray(0);
    for (c=0; c<channelDirs.length; c++) {
        channelDir = channelDirs[c];
        IJ.log("processing channel "  + (c+1) + " of " + channelDirs.length + " (" + channelDir + ")");
        files = getFileList(channelDir);
        Array.sort(files); 
        file = channelDir + "/" + files[0];
        run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite group_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT dimensions axis_1_number_of_images="+files.length+" axis_1_axis_first_image=0 axis_1_axis_increment=1 contains=[] name="+file);
        title = getTitle();
        processChannel(c);       
        channelTitles = Array.concat(channelTitles, title);
    }
    mergeOptions = "";
    for (c = 0; c < channelTitles.length; c++) {
        mergeOptions = mergeOptions + "c"+(c+1)+"="+channelTitles[c]+" ";
    }
    mergeOptions = mergeOptions + " create";
    run("Merge Channels...", mergeOptions);
    part = split(File.getNameWithoutExtension(file), "_");
    outTitle = File.getName(fishDir) + "_" + part[0];
    saveAs("tiff", outDir+"/"+outTitle+".tif");
    close("*");
}
setBatchMode(false);

function getFoldersIn(baseDir) {
    fileList = getFileList(baseDir);
    folders = newArray(0);
    for (i = 0; i < fileList.length; i++) {       
        currentFile =  baseDir + "/" + fileList[i];
        if (File.isDirectory(currentFile)) {
            folders = Array.concat(folders, currentFile);
        }
    }
    return folders;
}

function processChannel(c) {
    setMinAndMax(MIN_DISPLAY[c], MAX_DISPLAY[c]);
    run(CHANNEL_COLORS[c]);
    if (CONVERT_TO_8BIT) run("8-bit");    
}
