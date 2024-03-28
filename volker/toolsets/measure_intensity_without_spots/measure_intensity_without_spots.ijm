/**
 * 
 *  measure_intensity_without_spots.ijm
 * 
 *  Measure the intensities in cells. The first channel defines the cells (nuclei), the second the signal. 
 *  Bright spots are removed from the measurement of the signal. 
 * 
 *  (c) 2024 INSERM
 * 
 *  written by Volker Baecker at the MRI-Center for Image Analysis (MRI-CIA - https://www.mri.cnrs.fr/en/data-analysis.html)
 * 
 *  segment_spine.py is free software under the MIT license.
 *  
 *  MIT License
 * 
 *  Copyright (c) 2023 INSERM
 * 
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 * 
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 * 
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 *  
*/
var NUCLEI_CHANNEL = 1;
var SIGNAL_CHANNEL = 2;
var NUCLEUS_MIN_AREA = 50;
var LABEL = 1;
var NR_OF_ZOOM_OUT = 4;
var FILE_EXTENSION = "tif";
var INPUT_FILE_EXTENSION = "htd";
var CORRECT_BACKGROUND = true;
var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure-Intensity-Without-Spots"


macro "Measure Intensity Without Spots Help Action Tool - C000D0eDf8DfdDfeDffC029D42D73D82D83D9dDacDadC010D04D05D06D08D0cD13D2eD80Db3Dc3Dc4Dc5DcfDe1De8Df1Df2Df5DfaC38eD27D29D4cD57D5dD63D67D72D7dD94Da5Dc8DcdC000D00D01D02D03D07D09D0aD0bD0dD0fD10D11D12D1bD1cD1dD1eD1fD20D2cD2dD2fD3dD3eD3fD4eD4fD5fD60D6fD70D7fD8fD90D9fDa0Da1Db0Db1Db2Dc0Dc1Dc2Dd0Dd1Dd2Dd3Dd4Dd5Dd6DdfDe0De3De4De5De6De7DedDeeDefDf0Df3Df4Df6Df7Df9DfbDfcC02fD34D37D38D39D44D45D4bD54D5bD5cD64D6bD6cD75D85D95D96D99D9bDa6Da8Db8DbcDbdDccC254D2bD3cD4dD8eDa3Dc6De9C6baD16D18D23D2aD32D3bD41D51D52D6eD71D81D8dD92D93D9eDaeDb6DbeDc7DceDd8DdcDebC02dD43D53D58D6aD74D7cD84D87D8cD98D9cDa7C132D21D30D50D5eD61D91Da2Dd7De2DecCc2fD89D8aD8bDa9DaaDb9DbaDbbDc9DcaDd9DdaDdbC04fD28D35D36D3aD46D47D48D49D4aD55D59D5aD65D68D6dD78D79D7aD7bD86D88D97D9aC396D14D15D17D19D22D40D7eDa4Db5DddC8feD24D25D26D31D56D62D66DeaC13cD33D69D76D77DabDb7DcbC021D1aDafDb4DbfDde" {
    run('URL...', 'url='+_URL);
}


macro "Convert bioformats wells to tif series (f1) Action Tool - C000T8b12c" {
    convertWells()
}


macro "Convert bioformats wells to tif series [F1]" {
    convertWells()
}


macro "Remove Background (f2) Action Tool - C000T8b12r" {
    removeBackground();
}


macro "Remove Background [f2]" {
    removeBackground();
}


macro "Measure Image (f3) Action Tool - C000T4b12m" {
    measureImage();
}


macro "measure image [F3]" {
    measureImage();
}


macro "Measure Image (f3) Action Tool Options" {
    showMeasureIntensityOptions();
}


macro "Jump To Selected Label (f4) Action Tool - C000T8b12j" {
    jumpToSelectedLabel();
}


macro "Jump To Selected Label (f4) Action Tool Options" {
    showJumpToSeletedLabelOptions();
}


macro "jump to selected label [F4]" {
    jumpToSelectedLabel();
}


macro "Batch Remove Background (f5) Action Tool - C000T4b12bC000Tcb12r" {
    directory = getDir("Please select the input images!");
    batchRemoveBackground(directory);
}


macro "Batch Remove Background [f5]" {
    directory = getDir("Please select the input images!");
    batchRemoveBackground(directory);
}


macro "Batch Measure Images (f6) Action Tool - C000T8b12b" {
    batchMeasureImages();
}


macro "Batch Measure Images [f6]" {
    batchMeasureImages();
}


macro "Install or Update Action Tool - N66C000D2dD2eD3cD58D59D5aD67D75Db3DbeDc3DcdDceDd3DddDdeDe3DeeC666D69Db4De4C222D2cD57D76D85D93DaeDc9DcaDcbDccDd9DdaDdbDdcCdddD0eD2aD47D4dD55D64D6bD8dDb9DbaDbbDc1Dd1De9DeaDebC111D3bD4aD94DadDbdDedC999D48D86D95Dc4Dd4C555D74Dc2Dd2CfffD0dD1bD46D87Da5Db1Db8De1De8C000D4bD66D84Da3C888D2bD3eD6aDa2C444D1eD3dD65D68D9dDa4CeeeD39D5cD73D79D9cDacCbbbD1cD78D92D9eDbcDc8Dd8DecC555D49D5bDb2De2C777D1dD3aD4cD56D77D83Bf0C000D35D47D58D59D5aD7cD8dD8eC666D49C222D0eD13D25D36D57D8cCdddD2dD44D4bD55D67D6dD8aDaeC111D0dD14D6aD7bC999D15D26D68C555D34CfffD05D27D66D9bDadC000D03D24D46D6bC888D02D4aD7eD8bC444D04D1dD45D48D7dD9eCeeeD0cD1cD33D39D5cD79CbbbD12D1eD38D9cC555D5bD69C777D23D37D56D6cD7aD9dB0fC000D65D74D80D81D82C666D35C222D55D64D90CdddD76D94Da0Da1C111D56D73C999D00D54D63D70D71D93C555D37D45D66D84CfffD10D67C000D06D16D26D36D46D83C888D05D15D25C444D07D17D27D75D91CeeeD01D44D62Da2CbbbD57D85C555D72D92C777D47Nf0C000D20D21D22D34D45Dc0Dd0C666D75Db1De1C222D44D55Db0De0CdddD00D01D14D36Dc3Dd3C111D23D33D56C999D13D30D31D43D54Da0C555D24D46D65D77CfffD47D90C000D66D76D86D96Da6Db6Dc1Dc6Dd1Dd6De6C888D85D95Da5Db5Dc5Dd5De5C444D10D11D35D87D97Da7Db7Dc7Dd7De7CeeeD02D42D64Da1Db2De2CbbbD25D57C555D12D32Dc2Dd2C777D67"{
    installOrUpdate();
}


function batchMeasureImages() {
    baseDir = getDir("Please select the base folder (2 levels above the .htd files)!");
    batchInputImages = getBatchInputImages(baseDir);
    for (i = 0; i < batchInputImages.length; i++) {
        path = batchInputImages[i];
        IJ.log("Exporting image " + (i + 1) + " of " + batchInputImages.length + "; path = " + path)       
        run("export wells", "choose=[" + path + "]");
        currentFolder = File.getDirectory(path);
        currentFolder = currentFolder + "export" + File.separator;
        batchRemoveBackground(currentFolder);
        currentFolder = currentFolder + "corrected" + File.separator;
        files = getFileList(currentFolder);
        images = filterImages(files);
        for (j = 0; j < images.length; j++) {
            IJ.log("Analyzing field " + (j + 1) + " of " + images.length);
            tifPath = currentFolder + images[j];
            open(tifPath);
            Overlay.remove;
            measureImage();
            save(tifPath);
            close();
        }
        run("summarize data");
        Table.save(path + "_intensity_measurements_without_spots.xls", "intensity measurements without spots");
        Table.save(path + "_intensity_by_field.xls", "Intensity by Field");
        Table.save(path + "_intensity_by_well.xls", "Intensity by Well");
        close("intensity measurements without spots");
        close("Intensity by Field");
        close("Intensity by Well");
    }
}


function removeBackground() {   
    run("remove background");
}


function convertWells() {
    run("export wells");
}


function showMeasureIntensityOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("measure without spots");
    call("ij.Prefs.set", "mri.options.only", "false");  
}


function showJumpToSeletedLabelOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("jump to label");
    call("ij.Prefs.set", "mri.options.only", "false");  
}


function measureImage() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathMeasureIntensity())) {
        options = loadOptions(getOptionsPathMeasureIntensity());
        run("measure without spots", options);
    } else {
        run("measure without spots");
    }      
}


function getOptionsPathMeasureIntensity() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Measure-Intensity-Without-Spots/mws-options.txt";
    return optionsPath;
}


function loadOptions(path) {
    optionsString = File.openAsString(path);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;  
}


function jumpToSelectedLabel() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    row = Table.getSelectionStart;
    col = Table.getColumn("Label"); 
    label =col[row];
    zoom = NR_OF_ZOOM_OUT;
    pluginsPath = getDirectory("plugins");
    path = pluginsPath + "Measure-Intensity-Without-Spots/jtl-options.txt";
    if (File.exists(path)) {
        optionsString = File.openAsString(path);    
        parts = split(optionsString, " ");
        parts = split(parts[1], "=");
        zoomTxt = parts[1];
        zoom = zoomTxt.trim();
    }
    options = "label=" + label + " zoom=" + zoom;
    run("jump to label", options);
}


function batchRemoveBackground(directory) {
    outFolder = directory + "corrected" + File.separator;
    if (!File.exists(outFolder)) {
        File.makeDirectory(outFolder);
    }
    files = getFileList(directory);
    images = filterImages(files);
    for (i = 0; i < images.length; i++) {
        imagePath = directory + images[i];
        open(imagePath);
        if (CORRECT_BACKGROUND) removeBackground();
        Stack.getDimensions(width, height, channels, slices, frames);
        for (s = 1; s <= slices; s++) {
            run("Duplicate...", "duplicate slices=" + s);
            baseName = File.getNameWithoutExtension(images[i]);
            part = split(baseName, "#");
            filename = part[0] + '#' + s;
            save(outFolder + filename + ".tif");
            close();
        }
        close();
    }
}


function filterImages(files) {
    images = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = files[i];
        if (!endsWith(toLowerCase(file), toLowerCase(FILE_EXTENSION))) continue;
        images = Array.concat(images, file);
    }
    return images;
}


function filterHTDFiles(dir, files) {
    images = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = files[i];
        if (!endsWith(toLowerCase(file), toLowerCase(INPUT_FILE_EXTENSION))) continue;
        images = Array.concat(images, dir + file);
    }
    return images;
}


function filterDirs(dir, files) {
    dirs = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = dir + files[i];
        if (File.isDirectory(file)) {
            dirs = Array.concat(dirs, file);
        }
    }
    return dirs;
}


function getBatchInputImages(baseDir) {
    paths = newArray(0);
    files = getFileList(baseDir);
    subdirs = filterDirs(baseDir, files);
    batchInputImages = newArray(0);
    for (i = 0; i < subdirs.length; i++) {
        subdir = subdirs[i];
        subsubfiles = getFileList(subdir);
        subsubdirs = filterDirs(subdir, subsubfiles);
        for (j = 0; j < subsubdirs.length; j++) {
              subsubdir = subsubdirs[j];          
              lastLevelfiles = getFileList(subsubdir);
              htdFiles = filterHTDFiles(subsubdir, lastLevelfiles);
              batchInputImages = Array.concat(batchInputImages, htdFiles);
        }            
    }
    return batchInputImages;
}

function installOrUpdate() {
    print("Downloading the updater...");
    updateUpdater()
    setToolInfo();
    print("Running the updater...");
    scriptsFolder = getDirectory("imagej") + "scripts/";
    runMacro(scriptsFolder + "mri-updater.py");
    unsetToolInfo();
}


function setToolInfo() {
    call("ij.Prefs.set", "mri.update.tool", "measure_intensity_without_spots");
    call("ij.Prefs.set", "mri.update.folder", "Measure-Intensity-Without-Spots"); 
    call("ij.Prefs.set", "mri.update.author", "volker"); 
}


function unsetToolInfo() {
    call("ij.Prefs.set", "mri.update.tool", "");
    call("ij.Prefs.set", "mri.update.folder", ""); 
    call("ij.Prefs.set", "mri.update.author", ""); 
}


function updateUpdater() {
    updaterContent = File.openUrlAsString("https://raw.githubusercontent.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/master/volker/scripts/mri-updater.py");
    scriptsFolder = getDirectory("imagej") + "scripts/";
    File.saveString(updaterContent, scriptsFolder + "mri-updater.py");
}