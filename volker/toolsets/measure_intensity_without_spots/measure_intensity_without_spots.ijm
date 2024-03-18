var NUCLEI_CHANNEL = 1;
var SIGNAL_CHANNEL = 2;
var NUCLEUS_MIN_AREA = 50;

var LABEL = 1;
var NR_OF_ZOOM_OUT = 4;


URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure-Intensity-Without-Spots";

macro "Measure Intensity Without Spots Help Action Tool - C000D0eDf8DfdDfeDffC029D42D73D82D83D9dDacDadC010D04D05D06D08D0cD13D2eD80Db3Dc3Dc4Dc5DcfDe1De8Df1Df2Df5DfaC38eD27D29D4cD57D5dD63D67D72D7dD94Da5Dc8DcdC000D00D01D02D03D07D09D0aD0bD0dD0fD10D11D12D1bD1cD1dD1eD1fD20D2cD2dD2fD3dD3eD3fD4eD4fD5fD60D6fD70D7fD8fD90D9fDa0Da1Db0Db1Db2Dc0Dc1Dc2Dd0Dd1Dd2Dd3Dd4Dd5Dd6DdfDe0De3De4De5De6De7DedDeeDefDf0Df3Df4Df6Df7Df9DfbDfcC02fD34D37D38D39D44D45D4bD54D5bD5cD64D6bD6cD75D85D95D96D99D9bDa6Da8Db8DbcDbdDccC254D2bD3cD4dD8eDa3Dc6De9C6baD16D18D23D2aD32D3bD41D51D52D6eD71D81D8dD92D93D9eDaeDb6DbeDc7DceDd8DdcDebC02dD43D53D58D6aD74D7cD84D87D8cD98D9cDa7C132D21D30D50D5eD61D91Da2Dd7De2DecCc2fD89D8aD8bDa9DaaDb9DbaDbbDc9DcaDd9DdaDdbC04fD28D35D36D3aD46D47D48D49D4aD55D59D5aD65D68D6dD78D79D7aD7bD86D88D97D9aC396D14D15D17D19D22D40D7eDa4Db5DddC8feD24D25D26D31D56D62D66DeaC13cD33D69D76D77DabDb7DcbC021D1aDafDb4DbfDde" {
    run('URL...', 'url='+_URL);
}


macro "Remove Background (f1) Action Tool - C000T4b12r" {
    removeBackground();
}


macro "Remove Background [f1]" {
    removeBackground();
}


macro "Measure Image (f2) Action Tool - C000T4b12m" {
    measureImage();
}


macro "measure image [F2]" {
    measureImage();
}


macro "Measure Image (f2) Action Tool Options" {
    showMeasureIntensityOptions();
}


macro "Jump To Selected Label (f3) Action Tool - C000T4b12j" {
    jumpToSelectedLabel();
}


macro "Jump To Selected Label (f3) Action Tool Options" {
    showJumpToSeletedLabelOptions();
}


macro "jump to selected label [F2]" {
    jumpToSelectedLabel();
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
