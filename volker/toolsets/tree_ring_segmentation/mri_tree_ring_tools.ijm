/**
  *  Tools to measure pith, bark and annual rings in stained sections of tree trunks.
  *   
  *  (c) 2024, INSERM
  *  written  by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * 
  **
*/

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Tree-Ring-Tools";


macro "MRI Tree Ring Tool Help Action Tool - C000D16D17D18D19D24D25D26D27D28D29D2aD2bD33D34D3bD3cD42D43D4cD4dD52D57D58D5dD61D62D65D66D67D68D69D6aD6dD6eD71D72D75D76D79D7aD7dD7eD81D82D85D8aD8dD8eD91D92D95D96D99D9aD9dD9eDa1Da2Da6Da7Da8Da9DadDb2Db3DbcDbdDc2Dc3Dc4DcbDccDd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDe5De6De7De8De9" {
    run('URL...', 'url='+_URL);
}


macro "extract masks Action Tool - C000T4b12e" {
    extractMasks();
}


macro "batch extract masks Action Tool - C000T4b12b" {
    batchExtractMasksFromZip();
}


macro "extract masks Action Tool Options" {
    showOptionsForCommand("extract masks");
}


function extractMasks() {
    call("ij.Prefs.set", "mri.options.only", "false");  
    if (File.exists(getOptionsPathExtractMasks())) {
        options = loadOptions(getOptionsPathExtractMasks());
        run("extract masks", options);
    } else {
        run("extract masks");
    }
}

// Unused
function batchExtractMasks() {
    folder = getDir("Select the input folder!");
    if (!File.exists(folder + "masks/")) {
        File.makeDirectory(folder + "masks/");
    }
    files = getFileList(folder);
    for (i=0; i<files.length; i++) {
        file = files[i];
        if (!endsWith(file, ".tif")) {
            continue;
        }
        open(folder + file);
        extractMasks();
        save(folder + "masks/" + file);
        close("*");
    }
}

function batchExtractMasksFromZip() {
    folder = getDir("Select the input folder!");
    if (!File.exists(folder + "masks/")) {
        File.makeDirectory(folder + "masks/");
    }
    files = getFileList(folder);
    zipFiles = filterFilesByExtension(files, "zip");
    for (i=0; i<zipFiles.length; i++) {
        zipFile = zipFiles[i];
        image = replace(zipFile, ".zip", ".tif");
        open(folder + image);
        Overlay.remove()
        roiManager("open", folder + zipFile);
        run("From ROI Manager");
        roiManager("reset");
        extractMasks();
        save(folder + "masks/" + image);
        close("*");
    }
}


function filterFilesByExtension(files, ext) {
    results = newArray(0);    
    for (i=0; i<files.length; i++) {
        file = files[i];
        if (!endsWith(file, "." + ext)) {
            continue;
        }
        results = Array.concat(results, file);
    }
    return results;
}


function showOptionsForCommand(command) {
    call("ij.Prefs.set", "mri.options.only", "true");
    run(command);
    call("ij.Prefs.set", "mri.options.only", "false");  
}


function loadOptions(path) {
    optionsString = File.openAsString(path);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;  
}


function getOptionsPathExtractMasks() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "mri-tree-rings-tool/cmfr-options.txt";
    return optionsPath;
}