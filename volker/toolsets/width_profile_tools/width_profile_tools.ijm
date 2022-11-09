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

var cmds = newMenu("Utilities Menu Tool", newArray("Select Centerline", 
                                                   "Smooth Mask", 
                                                   "Line Mask to Line ROI", 
                                                   "Re-Measure Thickness",
                                                   "---", 
                                                   "Select Centerline Options", 
                                                   "Smooth Mask Options", 
                                                   "Line Mask to Line ROI Options"));
    
macro "Utilities Menu Tool - C000Db4Dc3C999D4cD5bD6aDa3Da6C777D25D36D3bD4aD52D59D95D96CfffD15D51D57D58D75D85D8aD93D9bDa8DacDb6Db9DbdDcaDdbC444D45D54Da4Dc4DccCeeeD14D26D62D86D94Dd2Dd4C888D69D87Da9DcbC222D35D3cD4bD53D5aD66D77D88D99Da5DaaDbbCcccD23D32Dc5DcdDdcC888D63D78D9aDb5DbcC555D24D42D46D56D64D65CeeeD2bD3aD41D44D49D68D79D97DddC999D2cD67D76D89D98DabDbaDc2C111D55Db3CbbbD2dD34D3dD43Db2Dd3" {
    cmd = getArgument();
    if (cmd=="Select Centerline") {
        call("ij.Prefs.set", "mri.options.only", "false");   
        if (File.exists(getOptionsPathWPVoronoi())) {
            options = loadOptions(getOptionsPathWPVoronoi());
            run("select centerline", options);
        } else {
            run("select centerline");
        }
        return;           
    }
    if (cmd=="Smooth Mask") {
        call("ij.Prefs.set", "mri.options.only", "false");   
        if (File.exists(getOptionsPathSmoothMask())) {
            options = loadOptions(getOptionsPathSmoothMask());
            run("smooth mask", options);
        } else {
            run("smooth mask",;
        }
        return;           
    }
    if (cmd=="Line Mask to Line ROI") {
        call("ij.Prefs.set", "mri.options.only", "false");   
        if (File.exists(getOptionsPathLineMaskToLineROI())) {
            options = loadOptions(getOptionsPathLineMaskToLineROI());
            run("line mask to line roi", options);
        } else {
            run("line mask to line roi",;
        }
        return;           
    }
    if (cmd=="Re-Measure Thickness") {
        run("remeasure thickness");
        return;           
    }
    if (cmd=="Select Centerline Options") {
        call("ij.Prefs.set", "mri.options.only", "true"); 
        run("select centerline");
        call("ij.Prefs.set", "mri.options.only", "false"); 
        return;           
    }
    if (cmd=="Smooth Mask Options") {
        call("ij.Prefs.set", "mri.options.only", "true"); 
        run("smooth mask");
        call("ij.Prefs.set", "mri.options.only", "false"); 
        return;           
    }
    if (cmd=="Line Mask to Line ROI Options") {
        call("ij.Prefs.set", "mri.options.only", "true"); 
        run("line mask to line roi");
        call("ij.Prefs.set", "mri.options.only", "false"); 
        return;           
    }
}

function runVoronoi() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    if (File.exists(getOptionsPathWPVoronoi())) {
        options = loadOptions(getOptionsPathWPVoronoi());
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
        options = loadOptions(getOptionsPathWPLT());
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
        options = loadOptions(getOptionsPathPIA());
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
        options = loadOptions(getOptionsPathCenterline());
        run("width profile perpendicular to centerline", options);
    } else {
        run("width profile perpendicular to centerline");
    }   
}

function loadOptions(path) {
    optionsString = File.openAsString(path);
    optionsString = replace(optionsString, "\n", "");
    return optionsString;  
}

function getOptionsPathWPVoronoi() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wpvoronoi-options.txt";
    return optionsPath;
}

function getOptionsPathWPLT() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wplt-options.txt";
    return optionsPath;
}

function getOptionsPathPIA() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wppia-options.txt";
    return optionsPath;
}

function getOptionsPathCenterline() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/wppc-options.txt";
    return optionsPath;
}

function getOptionsPathSelectCenterline() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/select-centerline-options.txt";
    return optionsPath;
}

function getOptionsPathSmoothMask() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/smooth-mask-options.txt";
    return optionsPath;
}

function getOptionsPathLineMaskToLineROI() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "Width-Profile-Tools/lmtl-options.txt";
    return optionsPath;
}
