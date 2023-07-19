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
     
    run("replace label", "x=" + x + " y=" + y + " z=" + (slice-1) + " frame=" + frame + " new=" + _SELECTED_LABEL);    
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


function loadOptions(path) {
    optionsString = File.openAsString(path);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;  
}

