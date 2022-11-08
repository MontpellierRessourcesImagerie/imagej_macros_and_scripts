/**
  *  Tools to calculate the width-profile of an object given as a binary mask. 
  *  - calculate the width profile of the objext
  *    - as local thickness 
  *    - as voronoi distance between two parts of the contour-line
  *    - perpendicular to the axis of inertia
  *    - at regular distances using rays perpendicular to a centerline segment 
  *   
  *  (c) 2022, INSERM
  *  written  by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * 
  **
*/

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Width-Profile-Tools";

macro "Width Profile Tools Help Action Tool - C000L00f0L01f1C111D02C000D12C111D22C000L32d2C222De2C333Df2C000L03b3C222Dc3C111Dd3C444De3C999Df3C222D04C111L1444C222D54C111L6474C000D84C111L94b4C333Dc4C777Dd4C999Le4f4C222D05C333L1525C777L3555Cf00D65C777D75C444D85C555D95C777La5b5Cf00Dc5CbbbLd5e5C777Df5Cf00D06C777D16C999D26CeeeD36CdddD46CeeeD56Cf00D66CdddD76C999D86CbbbD96CcccLa6b6Cf00Dc6CdddDd6CbbbDe6C999Df6Cf00D07CbbbD17CdddL2737CeeeD47CdddD57Cf00D67CdddL7787CeeeD97CbbbLa7b7CcccDc7Cf00Dd7CbbbDe7C999Df7CeeeD08Cf00D18CeeeD28CcccD38CdddD48CcccD58CeeeD68Cf00D78CcccD88CdddD98CbbbDa8CcccDb8C999Dc8Cf00Dd8C444De8C333Df8CeeeD09Cf00D19CeeeD29CdddD39CeeeD49CdddD59CcccD69Cf00D79C999L8999C777Da9C555Db9C333Dc9C555Dd9C222De9C111Df9CeeeD0aCf00D1aCdddD2aCeeeD3aCcccL4a5aCbbbD6aCf00D7aC444D8aC333D9aC222LaadaC111LeafaCcccL0b1bCf00D2bC777L3b4bC555D5bC444D6bC333D7bC222D8bC111D9bC222LabbbC000LcbfbC777D0cC555L1c2cC222D3cC333L4c6cC111D7cC222D8cC000L9cfcC333D0dC222L1d3dC000L4dfdL0efeL0fff" {
     run('URL...', 'url='+_URL);
}

macro "Local Thickness (f5) Action Tool - C000T4b12t" {
    runLocalThickness();
}

macro "Local Thickness (f5) Action Tool Options" {
    showLocalThicknessOptions();
}

macro "Local Thickness [f5]" {
    runLocalThickness();
}


macro "Voronoi (f6) Action Tool - C000T4b12v" {
    runVoronoi();
}

macro "Voronoi (f6) Action Tool Options" {
    showVoronoiOptions();
}

macro "Voronoi [f6]" {
    runVoronoi();
}

macro "Perpendicular to inertia axis (f7) Action Tool - C000T4b12i" {
    runPerpendicularToInertiaAxis();
}

macro "Perpendicular to inertia axis (f7) Action Tool Options" {
    showPerpendicularToInertiaAxisOptions();
}

macro "Perpendicular to inertia axis [f7]" {
    runPerpendicularToInertiaAxis();
}

macro "Perpendicular to centerline (f8) Action Tool - C000T4b12c" {
    runPerpendicularToCenterline();
}

macro "Perpendicular to centerline (f8) Action Tool Options" {
    showPerpendicularToCenterlineOptions();
}

macro "Perpendicular centerline [f8]" {
    runPerpendicularToCenterline();
}

function runVoronoi() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathWPVoronoi())) {
        options = loadOptionsWPVoronoi();
        run("width profile voronoi", options);
    } else {
        run("width profile voronoi");
    }     
}

function showVoronoiOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("width profile voronoi");
    call("ij.Prefs.set", "mri.options.only", "false");  
}

function showLocalThicknessOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("width profile by local thickness");
    call("ij.Prefs.set", "mri.options.only", "false");   
}

function runLocalThickness() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathWPLT())) {
        options = loadOptionsWPLT();
        run("width profile by local thickness", options);
    } else {
        run("width profile by local thickness");
    }   
}

function showPerpendicularToInertiaAxisOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("width profile perpendicular to inertia axis");
    call("ij.Prefs.set", "mri.options.only", "false");   
}

function runPerpendicularToInertiaAxis() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathPIA())) {
        options = loadOptionsPIA();
        run("width profile perpendicular to inertia axis", options);
    } else {
        run("width profile perpendicular to inertia axis");
    }   
}

function showPerpendicularToCenterlineOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("width profile perpendicular to centerline");
    call("ij.Prefs.set", "mri.options.only", "false");   
}

function runPerpendicularToCenterline() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathCenterline())) {
        options = loadOptionsCenterline();
        run("width profile perpendicular to centerline", options);
    } else {
        run("width profile perpendicular to centerline");
    }   
}

function loadOptionsWPVoronoi() {
    optionsPath = getOptionsPathWPVoronoi();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;
}

function getOptionsPathWPVoronoi() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wpvoronoi-options.txt";
    return optionsPath;
}

function loadOptionsWPLT() {
    optionsPath = getOptionsPathWPLT();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;
}

function getOptionsPathWPLT() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wplt-options.txt";
    return optionsPath;
}

function loadOptionsPIA() {
    optionsPath = getOptionsPathPIA();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;
}

function getOptionsPathPIA() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wppia-options.txt";
    return optionsPath;
}

function loadOptionsCenterline() {
    optionsPath = getOptionsPathCenterline();
    optionsString = File.openAsString(optionsPath);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;
}

function getOptionsPathCenterline() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wppc-options.txt";
    return optionsPath;
}