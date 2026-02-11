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
                                                   "Reverse Plot",
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
            run("smooth mask");
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
    if (cmd=="Reverse Plot") {
        run("reverse plot");
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

macro "Install or Update Action Tool - N66C000D2dD2eD3cD58D59D5aD67D75Db3DbeDc3DcdDceDd3DddDdeDe3DeeC666D69Db4De4C222D2cD57D76D85D93DaeDc9DcaDcbDccDd9DdaDdbDdcCdddD0eD2aD47D4dD55D64D6bD8dDb9DbaDbbDc1Dd1De9DeaDebC111D3bD4aD94DadDbdDedC999D48D86D95Dc4Dd4C555D74Dc2Dd2CfffD0dD1bD46D87Da5Db1Db8De1De8C000D4bD66D84Da3C888D2bD3eD6aDa2C444D1eD3dD65D68D9dDa4CeeeD39D5cD73D79D9cDacCbbbD1cD78D92D9eDbcDc8Dd8DecC555D49D5bDb2De2C777D1dD3aD4cD56D77D83Bf0C000D35D47D58D59D5aD7cD8dD8eC666D49C222D0eD13D25D36D57D8cCdddD2dD44D4bD55D67D6dD8aDaeC111D0dD14D6aD7bC999D15D26D68C555D34CfffD05D27D66D9bDadC000D03D24D46D6bC888D02D4aD7eD8bC444D04D1dD45D48D7dD9eCeeeD0cD1cD33D39D5cD79CbbbD12D1eD38D9cC555D5bD69C777D23D37D56D6cD7aD9dB0fC000D65D74D80D81D82C666D35C222D55D64D90CdddD76D94Da0Da1C111D56D73C999D00D54D63D70D71D93C555D37D45D66D84CfffD10D67C000D06D16D26D36D46D83C888D05D15D25C444D07D17D27D75D91CeeeD01D44D62Da2CbbbD57D85C555D72D92C777D47Nf0C000D20D21D22D34D45Dc0Dd0C666D75Db1De1C222D44D55Db0De0CdddD00D01D14D36Dc3Dd3C111D23D33D56C999D13D30D31D43D54Da0C555D24D46D65D77CfffD47D90C000D66D76D86D96Da6Db6Dc1Dc6Dd1Dd6De6C888D85D95Da5Db5Dc5Dd5De5C444D10D11D35D87D97Da7Db7Dc7Dd7De7CeeeD02D42D64Da1Db2De2CbbbD25D57C555D12D32Dc2Dd2C777D67"{
    installOrUpdate();
}

var dCmds = newMenu("Images Menu Tool", newArray("download dataset", "mask_green.tif", "mask_red.tif", "nile_mask.tif", "test_mask.tif"));
    
macro "Images Menu Tool - CfffL00f0L0161CeeeD71CfffL81f1L0252CeeeD62C666D72CeeeD82CfffL92f2L0353CeeeD63C444D73CeeeD83CfffL93f3L0454CeeeD64C444D74CeeeD84CfffL94f4L0555CeeeD65C444D75CeeeD85CfffL95f5L0636CdddD46CfffD56CeeeD66C444D76CeeeD86CfffD96CdddDa6CfffLb6f6L0727CdddD37C444D47CbbbD57CeeeD67C444D77CeeeD87CbbbD97C444Da7CdddDb7CfffLc7f7L0838CbbbD48C444D58C999D68C444D78C999D88C444D98CbbbDa8CfffLb8f8L0949CbbbD59C333D69C111D79C333D89CbbbD99CfffLa9f9L0a5aCbbbD6aC444D7aCbbbD8aCfffL9afaL0b6bCeeeD7bCfffL8bfbL0c2cCeeeL3cbcCfffLccfcL0d1dCeeeD2dC666D3dC444L4dadC666DbdCeeeDcdCfffLddfdL0e2eCeeeL3ebeCfffLcefeL0fff" {
       cmd = getArgument();       
       URLS = newArray('https://dev.mri.cnrs.fr/attachments/download/3514/mask_green.tif', 'https://dev.mri.cnrs.fr/attachments/download/3513/mask_red.tif', 'https://dev.mri.cnrs.fr/attachments/download/3515/nile_mask.tif', 'https://dev.mri.cnrs.fr/attachments/download/3512/test_mask.tif');
       MRI_DATA_FOLDER = getDirectory("imagej");
       if (startsWith(MRI_DATA_FOLDER, "./")) {
           cwd = getDir("cwd");
           MRI_DATA_FOLDER = replace(MRI_DATA_FOLDER, "./", cwd);
       }
       MRI_DATA_FOLDER = MRI_DATA_FOLDER + "mri-datasets" + "/";
       DATASET_DIR = MRI_DATA_FOLDER + "width-profile/";
       DATASET_NAME = "width-profile-dataset";
       if (!File.exists(MRI_DATA_FOLDER)) File.makeDirectory(MRI_DATA_FOLDER);
       if (!File.exists(DATASET_DIR)) File.makeDirectory(DATASET_DIR);
       
       if (cmd=="download dataset") {
           print("Starting download of the "+DATASET_NAME+"...");
           for (i = 0; i < URLS.length; i++) {
              downloadImage(URLS[i], DATASET_DIR);   
           }
           print("...download of the "+DATASET_NAME+" finished.");
           return;
       } else {
           open(DATASET_DIR + cmd); 
       }
}

function downloadImage(url, folder) {
    setBatchMode(true);
    print("downloading " + url);
    open(url);
    parts = split(url, "/");
    name = parts[parts.length - 1];
    save(folder + name);
    close();
    setBatchMode(false);    
}

function installOrUpdate() {
    scriptsFolder = getDirectory("imagej") + "scripts/";
    if (File.exists(scriptsFolder + "mri-updater.py")) {
        print("Running the updater...");
        setToolInfo();
        run("mri-updater");   
        unsetToolInfo();
    } else {
        print("Installing the updater...");
        updateUpdater();  
        print("Please restart FIJI and press the install/update button again!");
    }
}


function setToolInfo() {
    call("ij.Prefs.set", "mri.update.tool", "width_profile_tools");
    call("ij.Prefs.set", "mri.update.folder", "Width-Profile-Tools"); 
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
