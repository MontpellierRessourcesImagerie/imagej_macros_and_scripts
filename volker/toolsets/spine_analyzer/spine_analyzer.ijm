/**
 * 
 *  spine_analyzer.ijm
 * 
 *  Tools to measure the density and volume of dendritic spines.
 * 
 *  (c) 2023 INSERM
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

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine-Analyzer";
var _SELECTED_LABEL = 0;
var _REPLACE_LABEL_MODES = newArray("selected label", "next label");
var _REPLACE_LABEL_MODE = _REPLACE_LABEL_MODES[0];


macro "Spine Analyzer Help Action Tool - CfffL00e0Cd86Df0CfffL01f1L02f2L03f3L0444Cea9D54Cd87D64Cea9L7494Cd87Da4CfcbDb4CfffLc4f4L0545Cc64D55Cc53L65a5Cd86Db5CfffLc5f5L0646Cd87D56Cc53L66a6Cd87Db6CfffLc6f6L0747CfedD57Cc53L67a7CfdcDb7CfffLc7f7CfdcD08CfffL1858Cea9D68Cc53L7898CebaDa8CfffLb8f8Cd75D09CfffL1959CfedD69Cc53L7989Cc64D99CfffLa9f9Ce98D0aCfffL1a6aCc53L7a8aCd86D9aCfffLaafaL0b6bCd75D7bCc53D8bCea9D9bCfffLabfbL0c6cCd75D7cCc53D8cCea9D9cCfffLacfcL0d6dCc53L7d8dCd87D9dCfffLadfdL0e5eCfdcD6eCc53L7e8eCd86D9eCfffLaefeCc54L0f6fCc53L7f9fCc54Lafff" {
    run('URL...', 'url='+_URL);
}


macro "Segment Spine (f5) Action Tool - C000T4b12s" {
    runSegmentSpine();
}


macro "Segment Spine (f5) Action Tool Options" {
    showSegmentSpineOptions();
}


macro "Segment Spine [F5]" {
    runSegmentSpine();
}


macro "Pick A Label Tool - C000D2bD2cD2dD3aD3dD49D4dD58D5cD67D6bD76D7aD84D85D89D95D98Da4Da5Da6Da7Db3Db4Db5Db7Dc4C555D4aD59D5bD68D6aD77D79D86D88D97Dd4C111D3cDc3CcccD73Dc2Dc8Dd3C999D2aD39D48D57D5dD66D6cD74D75D7bD83D8aD96D99Da8Db8Dc7C222Dc5CeeeD93Da2Dc6Dd5C111Db6C444D3bC333Da3C222D94C555D4cDb2"{
     Stack.getPosition(channel, slice, frame);
     getCursorLoc(x, y, z, flags);
     
     pickLabel(x, y, slice, frame);
}


macro "Pick A Label Tool Options" {
    Dialog.create("Pick A Label Options");
    Dialog.addNumber("Label: ", _SELECTED_LABEL);
    Dialog.show();
    _SELECTED_LABEL = Dialog.getNumber();
}


macro "Replace Label Tool - C000D25D51D61D76D86Da4Db5Dc6Dc8Dd6Dd7Dd8De8De9CeeeD06D30D39D4aD57D5bD5eD97DdaC888D23D32D36D7cD85D8bD9aDa9Db8Dc9Df8DfdC333D19D26D31D52D53D56D5dD62D72Df9DfbCfffD11Db3DfeCbbbD15D1aD2bD3cD4dD65D77DecC222D18D2aD35D3bD4cD66D7dDc7DfaCaaaD08D55D60D8dDd5DebC555D14D16D29D3aD43D45D46D4bD5cDb4DeaCdddD09D28D33D54D63D67D70D73D7eD81D84D92Da6Db7DedC222D17D22D41D6dD8cD9bDaaDb9Dc5De7C999D12D21D44D87D9cDabDbaDe6C444D13D24D71D82D83D93D94Da5Db6Dd9DfcCcccD27D34D40D6cD6eD95Da3Dc4Df7CaaaD07D42D50D75D96" {
    runReplaceLabel();
}


macro "Replace Label Tool Options" {
    Dialog.create("Replace Label Tool Options");
    Dialog.addRadioButtonGroup("Replace Label Mode: ", _REPLACE_LABEL_MODES, 1, 2, _REPLACE_LABEL_MODE);
    Dialog.show();
    _REPLACE_LABEL_MODE = Dialog.getRadioButton();
}


macro "Add Dendrite (f6) Action Tool - C000D4aD50D60D75D78D86D87D97C888D0bD3bD79D88DdaC444D1aD1bD5aDeaCdddD39D58D71D72D84Da9C222D59D61D62Da8CbbbD4bD53D65D6aC666D76D85Db9CfffD19D1cD5bD66D89D95De8DebC111D3aD63D69Db8Dc9Dd9C999D0aD49D70D73D98DfaC555D2bD68D77Da7De9CeeeD29D41D54D67Da6C333D2aD51D64D74CcccDb7DcaDd8Df9C777D40D52D96Dc8" {
    runAddDendrite();
}


macro "Add Dendrite [F6]" {
    runAddDendrite();
}


macro "Track Dendrites (f7) Action Tool - C111D2bD49D62D7bDadDb7DbdDd7CfffD19D44D4cD68D76Db5DbbC666D38D54D5bD6aD6eD74D7eDa6Da9C444D41D53D55D6cD8eD9bDa7DacDc6Dc8CcccD15D1bD27D3aD43D56D5eD61D87D96Dd6DdcC333D22D23D24D2aD33D37D3bD4bD52D63D64D65D66D98D99D9aDc7Dd8Dd9C999D13D14D29D5aD6bDcbDe8De9C555D34D51D6dD7cD9eDa8DaeCeeeD12D21D2cD3cD46D47D7dD8cDb9DbcDceDe7C333D25D39D42D45D48D97Db6DbaDccDdaC888D31D5dD73D7aD88D89DcdC555D26D32D35D57D58DaaDbeDc9CdddD4aD59D5cD72D8dDb8DeaCbbbD1aD36D67D75D8aD8bD9cD9dDabC666DcaDdb" {
    runTrackDendrites();    
}


macro "Track Dendrites [F7]" {
    runTrackDendrites(); 
}


macro "Track Dendrites (f7) Action Tool Options" {
    showTrackDendritesOptions();
}


macro "Track Spines (f8) Action Tool - C000D17D18D19D26D27D28D29D36D39D49D4bD4cD4dD4eD59D5bD5eD69D6aD6bD6eD6fD7fD8fD9eD9fDaeDbeCf60D11D21D22D23D31D32D33D34D35D41D42D43D51DaaDbaDbbDbcDcaDcbDccDcdDceDdaDdbDdcDea" {
    runTrackSpines();
}


macro "Track Spines [F8]" {
    runTrackSpines(); 
}


macro "Track Spines (f8) Action Tool Options" {
    showTrackSpinesOptions();
}


macro "Attach Spines (f9) Action Tool - C222D0aD0bD1dDf3Df4CeeeD3dC777D19D28D29D37D46D55D64D6cD73D7bD8aD99Da8Db7C555D2aD3cD4eD6eDc1De1CfffD6fDa0CcccD08D4dDe3De4C444D0cD39D3eD48D57D66D75D7dD84D8cD93D9bDa2DaaDb9Dc8Dd1Dd7De6CeeeD91Dd2Dd5De0CbbbD17D1aD26D2dD35D44D53D5bD5dD5fD62D6aD71D79D88D97Da6Db0Db5Dd0C666D2bD6dD7cD8bD92D9aDa1Da9Db8Dc7Dd6De2Df2Df5CdddD2cD2fD49D4bD58D67D76D7eD85D8dD94D9cDa3DabDbaDc9Dd8De7Df1Df6C333D18D27D2eD36D45D4cD54D5cD5eD63D6bD72D7aD89D98Da7Db1Db6C999D0dD1cD1eD3aD3fD4fD81D82Dc0Dc5Dc6C666D09D38D3bD47D56D65D74D83De5CdddD1bDb2" {
    runAttachSpines();    
}


macro "Attach Spines [F9]" {
    runAttachSpines();    
}


macro "Measure (f10) Action Tool - C000D22D23D27D28D2cD2dD32D33D37D38D3cD3dD42D43D47D48D4cD4dD52D53D57D58D5cD5dD62D63D67D68D6cD6dD72D73D77D78D7cD7dD87D88D8cD8dD97D98D9cD9dDa7Da8Db7Db8Dc7Dc8Dd7Dd8C333D24D2bD34D44D54D64D74DacDadDe7De8CcccD36D46D56D66D76D86D96Da6Db6Dc6Dd6C666DabCcccDe6De9C444D3bD4bD5bD6bD7bD8bD9bCbbbD26D29D39D49D59D69D79D89D99Da9Db9Dc9Dd9" {
    runMeasure();    
}


macro "Measure [F10]" {
    runMeasure();
}


macro "Set First Slice [&1]" {
    setFirstSlice();
}


macro "Set Last Slice [&2]" {
    setLastSlice();
}


macro "Reset Slice Boundaries [&0]" {
    resetSliceBoundaries();
}


macro "Install or Update Action Tool - N66C000D2dD2eD3cD58D59D5aD67D75Db3DbeDc3DcdDceDd3DddDdeDe3DeeC666D69Db4De4C222D2cD57D76D85D93DaeDc9DcaDcbDccDd9DdaDdbDdcCdddD0eD2aD47D4dD55D64D6bD8dDb9DbaDbbDc1Dd1De9DeaDebC111D3bD4aD94DadDbdDedC999D48D86D95Dc4Dd4C555D74Dc2Dd2CfffD0dD1bD46D87Da5Db1Db8De1De8C000D4bD66D84Da3C888D2bD3eD6aDa2C444D1eD3dD65D68D9dDa4CeeeD39D5cD73D79D9cDacCbbbD1cD78D92D9eDbcDc8Dd8DecC555D49D5bDb2De2C777D1dD3aD4cD56D77D83Bf0C000D35D47D58D59D5aD7cD8dD8eC666D49C222D0eD13D25D36D57D8cCdddD2dD44D4bD55D67D6dD8aDaeC111D0dD14D6aD7bC999D15D26D68C555D34CfffD05D27D66D9bDadC000D03D24D46D6bC888D02D4aD7eD8bC444D04D1dD45D48D7dD9eCeeeD0cD1cD33D39D5cD79CbbbD12D1eD38D9cC555D5bD69C777D23D37D56D6cD7aD9dB0fC000D65D74D80D81D82C666D35C222D55D64D90CdddD76D94Da0Da1C111D56D73C999D00D54D63D70D71D93C555D37D45D66D84CfffD10D67C000D06D16D26D36D46D83C888D05D15D25C444D07D17D27D75D91CeeeD01D44D62Da2CbbbD57D85C555D72D92C777D47Nf0C000D20D21D22D34D45Dc0Dd0C666D75Db1De1C222D44D55Db0De0CdddD00D01D14D36Dc3Dd3C111D23D33D56C999D13D30D31D43D54Da0C555D24D46D65D77CfffD47D90C000D66D76D86D96Da6Db6Dc1Dc6Dd1Dd6De6C888D85D95Da5Db5Dc5Dd5De5C444D10D11D35D87D97Da7Db7Dc7Dd7De7CeeeD02D42D64Da1Db2De2CbbbD25D57C555D12D32Dc2Dd2C777D67"{
    installOrUpdate();
}


function setFirstSlice() {
    Stack.getPosition(channel, slice, frame);
    saveSegmentSpineOption("start", slice)
    print("first slice set to " + slice);
}


function setLastSlice() {
    Stack.getPosition(channel, slice, frame);
    saveSegmentSpineOption("end", slice)
    print("last slice set to " + slice);
}


function resetSliceBoundaries() {
    saveSegmentSpineOption("start", 0)
    saveSegmentSpineOption("end", 0)
    print("the slice boundaries have been reset");
}


function saveSegmentSpineOption(option, value) {
    path = getOptionsPathSegmentSpine();
    optionsString = loadOptions(path);
    newOptionString = replace(optionsString, option + "=[0-9]+", option+"=" + value);
    File.saveString(newOptionString, path);
}


function runMeasure() {
    run("measure spines");    
}


function runAttachSpines() {
    run("attach spines");
}


function runTrackSpines() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathTrackSpines())) {
        options = loadOptions(getOptionsPathTrackSpines());
        run("track spines", options);
    } else {
        run("track spines");
    }      
}


function runTrackDendrites() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathTrackDendrites())) {
        options = loadOptions(getOptionsPathTrackDendrites());
        run("track dendrites", options);
    } else {
        run("track dendrites");
    }      
}


function runAddDendrite() {
    run("add dendrite");
}


function runReplaceLabel() {
    Stack.getPosition(channel, slice, frame);
    getCursorLoc(x, y, z, flags);
     
    label =  _SELECTED_LABEL;
    if (_REPLACE_LABEL_MODE == "next label") {
        label = getNextLabel();
    }
    run("replace label", "x=" + x + " y=" + y + " z=" + (slice-1) + " frame=" + frame + " new=" + label);    
}


function runSegmentSpine() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathSegmentSpine())) {
        options = loadOptions(getOptionsPathSegmentSpine());
        run("segment spine", options);
    } else {
        run("segment spine");
    }  
}


function showSegmentSpineOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("segment spine");
    call("ij.Prefs.set", "mri.options.only", "false");  
}


function showTrackDendritesOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("track dendrites");
    call("ij.Prefs.set", "mri.options.only", "false");  
}


function showTrackSpinesOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("track spines");
    call("ij.Prefs.set", "mri.options.only", "false"); 
}


function pickLabel(x, y, sllice, frame) {
    labelChannel = Property.get("mricia-label-channel");
    if (labelChannel=="") exit("No label channel found!");
    labelChannel = parseInt(labelChannel);    
    Stack.setPosition(labelChannel, slice, frame);
    _SELECTED_LABEL = getPixel(x, y);
    Stack.setPosition(channel, slice, frame);
    showStatus("Selected label: " + _SELECTED_LABEL);
}


function getOptionsPathSegmentSpine() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Spine-Analyzer/sass-options.txt";
    return optionsPath;
}    


function getOptionsPathTrackDendrites() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Spine-Analyzer/satd-options.txt";
    return optionsPath;
}


function getOptionsPathTrackSpines() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Spine-Analyzer/sats-options.txt";
    return optionsPath;
}


function loadOptions(path) {
    optionsString = File.openAsString(path);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;  
}


function getNextLabel() {
    Stack.getPosition(channel, slice, frame) 
    getDimensions(width, height, channels, slices, frames);
    Stack.setChannel(channels);
    getStatistics(area, mean, min, max);
    Stack.setPosition(channel, slice, frame);
    return max + 1;
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
    call("ij.Prefs.set", "mri.update.tool", "spine_analyzer");
    call("ij.Prefs.set", "mri.update.folder", "Spine-Analyzer"); 
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

