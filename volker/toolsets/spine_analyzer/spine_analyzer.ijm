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


macro "Pick A Label Tool - CfffL00f0L01f1L02a2C555Db2CdddDc2CfffLd2f2L0363CdddD73CaaaD83CfffD93C333Da3C111Dc3CdddDd3CfffLe3f3L0464CaaaD74C222D94C666Dd4CfffLe4f4L0565CaaaD75C333Dc5CfffLd5f5L0656CaaaD66C666D86CaaaD96C222Db6CfffLc6f6L0747CaaaD57C666D77CfffD87C666D97CaaaDc7CfffLd7f7L0838CaaaD48C666D68CfffD78C666D88CaaaLa8b8CdddDc8CfffLd8f8L0929CaaaD39C666D59CfffD69C666D79CaaaD99CfffLa9f9L0a1aCaaaD2aC666D4aCfffD5aC666D6aCaaaD8aCfffL9afaL0b1bC555D3bCfffD4bC666D5bCaaaD7bCfffL8bfbL0c1cC111D3cC555D4cCaaaD6cCfffL7cfcL0d1dCaaaD5dCfffL6dfdL0efeL0fff"{
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


macro "Replace Label Tool - C000T4b12r" {
    runReplaceLabel()
}


macro "Replace Label Tool Options" {
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


function loadOptions(path) {
    optionsString = File.openAsString(path);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;  
}

