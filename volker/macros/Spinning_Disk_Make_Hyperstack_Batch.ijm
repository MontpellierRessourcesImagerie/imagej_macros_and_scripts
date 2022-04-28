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

var T_START_MARKER = "_t";
var T_END_MARKER = "_f";
var Z_START_MARKER = "_z";
var Z_END_MARKER = ".";

var CHANNEL_COLORS = newArray("Green", "Magenta", "Red"); 
var MIN_DISPLAY = newArray(90, 88, 89);
var MAX_DISPLAY = newArray(177, 306, 175);
var CONVERT_TO_8BIT = false;

inDir = getDirectory("Please select the source directory");
outDir = getDirectory("Pease select the destination directory");
setBatchMode(true);
fishDirs = getFoldersIn(inDir);
for (i=0; i<fishDirs.length; i++) {
    fishDir = fishDirs[i];
    IJ.log("processing image "  + (i+1) + " of " +  fishDirs.length + " (" + fishDir + ")");
    channelDirs = getFoldersIn(fishDir);
    channelTitles = processChannels(channelDirs, outDir);
    if (channelTitles.length == 0) continue;
    mergeChannels(channelTitles);
    part = split(channelTitles[0], "_");
    outTitle = File.getName(fishDir) + "_" + part[0];
    saveAs("tiff", outDir+"/"+outTitle+".tif");
    close("*");
}
setBatchMode(false);

function processChannels(channelDirs, outDir) {
    channelTitles = newArray(0);
    for (c=0; c<channelDirs.length; c++) {
        channelDir = channelDirs[c];
        IJ.log("processing channel "  + (c+1) + " of " + channelDirs.length + " (" + channelDir + ")");
        files = getFileList(channelDir);
        Array.sort(files); 
        file = channelDir + "/" + files[0];
        if (isTimeSeries(files)) {
            bounds = getMinAndMaxTandZ(files); 
            template = createTemplate(files[0], bounds);  
            run("Bio-Formats", "open=["+file+"] autoscale color_mode=Default group_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT dimensions axis_1_number_of_images="+(bounds[1]-bounds[0]+1)+" axis_1_axis_first_image="+bounds[0]+" axis_1_axis_increment=1 axis_2_number_of_images="+(bounds[3]-bounds[2]+1)+" axis_2_axis_first_image="+bounds[2]+" axis_2_axis_increment=1 contains=[] name=["+channelDir+"/"+template+"]");
            title = getTitle();
            processChannel(c);                
            fishDir = File.getParent(channelDir);
            part = split(File.getNameWithoutExtension(file), "_");
            outTitle = File.getName(fishDir) + "_" + part[0]+"_c"+c;
            saveAs("tiff", outDir+"/"+outTitle+".tif");
            close("*");
        } else {
            run("Bio-Formats", "open=["+file+"] autoscale color_mode=Composite group_files rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT dimensions axis_1_number_of_images="+files.length+" axis_1_axis_first_image=0 axis_1_axis_increment=1 contains=[] name="+file);    
            title = getTitle();
            processChannel(c);       
            channelTitles = Array.concat(channelTitles, title);
        }        
    }
    return channelTitles;
}

function mergeChannels(channelTitles) {
    mergeOptions = "";
    for (c = 0; c < channelTitles.length; c++) {
        mergeOptions = mergeOptions + "c"+(c+1)+"="+channelTitles[c]+" ";
    }
    mergeOptions = mergeOptions + " create";
    run("Merge Channels...", mergeOptions);       
}

function getFoldersIn(baseDir) {
    fileList = getFileList(baseDir);
    folders = newArray(0);
    for (i = 0; i < fileList.length; i++) {       
        currentFile =  baseDir + "/" + fileList[i];
        if (File.isDirectory(currentFile)) {
            folders = Array.concat(folders, currentFile);
        }
    }
    Array.sort(folders);
    return folders;
}

function processChannel(c) {
    setMinAndMax(MIN_DISPLAY[c], MAX_DISPLAY[c]);
    run(CHANNEL_COLORS[c]);
    if (CONVERT_TO_8BIT) run("8-bit");    
}


function getMinAndMaxTandZ(files) {
    minT = 9999;
    maxT = -1;
    minZ = 9999;
    maxZ = -1;
    for (i = 0; i < files.length; i++) {
        file = files[i];
        t = extractTime(file);
        z = extractPlane(file);
    
        if (t>maxT) maxT = t;
        if (t<minT) minT = t;
        if (z>maxZ) maxZ = z;
        if (z<minZ) minZ = z;
    }
    return newArray(minT, maxT, minZ, maxZ);
}

function extractTime(filename) {
    return extractIntegerBetween(filename, T_START_MARKER, T_END_MARKER);
}

function extractPlane(filename) {
    return extractIntegerBetween(filename, Z_START_MARKER, Z_END_MARKER);
}

function extractIntegerBetween(string, start, end) {
    return parseInt(substringBetween(string, start, end));
}

function substringBetween(string, start, end) {
    startIndex = indexOf(string, start)+lengthOf(start);
    endIndex = indexOf(string, end);
    result = substring(string, startIndex, endIndex);
    return result;
}

function isTimeSeries(files) {
    result = false;
    if (indexOf(files[0], "_t")!=-1) result = true;
    return result;
}

function createTemplate(filename, bounds) {
    maxTString = "" + bounds[1];
    minTString = IJ.pad(bounds[0], lengthOf(maxTString));
    maxZString = "" + bounds[3];
    minZString = IJ.pad(bounds[2], lengthOf(maxZString));

    tStringSource =  T_START_MARKER + substringBetween(filename, T_START_MARKER, T_END_MARKER);
    zStringSource =  Z_START_MARKER + substringBetween(filename, Z_START_MARKER, Z_END_MARKER);
    tStringDest = "" + withoutLastNChars(tStringSource, lengthOf(maxTString)) + "<" + minTString + "-" + maxTString + ">";
    zStringDest = "" + withoutLastNChars(zStringSource, lengthOf(maxZString)) + "<" + minZString + "-" + maxZString + ">";

    result = replace(filename, tStringSource, tStringDest);
    result = replace(result, zStringSource, zStringDest);

    return result;
}


function withoutLastNChars(string, n) {
    res = substring(string, 0, lengthOf(string)-n);
    return res;
}