/**
  *  Kinetochore Analyzer
  *  --------------------
  *  Segment kinetochores in yeast cells and measure the co-occurence with a molecule
  *  in a different fluorescent channel.
  *   
  *  (c) 2026, INSERM, distributed under the MIT license
  *  
  *  written  by Volker Baecker (INSERM) at Montpellier RIO Imaging (https://www.mri.cnrs.fr/en/data-analysis.html)
  * 
  **
*/

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Kinetochore-Analyzer"

macro "Kinetochore Analyzer Help Action Tool - C650D00C560D10C550D20C430L3040C640D50C650D60C730D70C450D80C550D90C440Da0C330Db0C430Dc0C320Dd0C110De0C310Df0C671D01C450D11C540D21C550D31C740D41C950D51C850D61C971D71Ca71D81C760D91C450Da1C430Lb1c1C520Dd1C320Le1f1C560D02C650D12C440L2232C850D42Ca71D52Cf60D62Cd71D72Cf91D82Cfc2D92C660Da2C550Db2C540Dc2C430Dd2C420De2C230Df2C340L0313C440D23C660D33C750D43Cf70D53Cfa1D63Cfa2D73Cff4D83Cff7D93C792Da3C650Db3C550Dc3C340Dd3C520De3C330Df3C320D04C330D14C530D24C850D34Ca50D44Cb71D54Cfa2D64Cb91L7484C8a2D94C781Da4C660Db4C560Dc4C540Dd4C420De4C320Df4C430D05C420L1525C650D35Ca60D45C760D55C871D65Ca71D75C771D85C871D95C581Da5C560Db5C650Dc5C560Dd5C430De5C330Df5C320D06C330L1626C540D36C650D46C760D56C671D66C781D76C671D86C760D96C860Da6C571Db6C671Dc6C650Dd6C540De6C330Df6C420D07C320D17C430D27C550D37C750D47C671L5767C781L7787C760D97C860Da7C660Db7C860Dc7C550Dd7C540De7C330Df7C320D08C410D18C430D28C550D38C760D48C781D58C681D68C771D78C550D88C871D98C660La8c8C650Dd8C430De8C220Df8D09C410D19C430D29C530D39C660L4959C581D69C671D79C871D89C760D99C660Da9C671Db9C450Dc9C440Ld9e9C330Df9D0aC430L1a3aC640D4aC660D5aC771D6aC760D7aC860D8aC760L9abaC550DcaC440DdaC420DeaC330DfaC510D0bC320D1bC330D2bC430D3bC540D4bC650D5bC571D6bC671L7b8bC550D9bC571DabC660DbbC350LcbdbC330DebC530DfbC420D0cC320D1cC430D2cC420D3cC430D4cC440D5cC560D6cC660L7c9cC550LacccC430DdcC540DecC640DfcC430D0dC420D1dC310D2dC320D3dC330D4dC440D5dC450L6d7dC550D8dC540D9dC550DadC450DbdC540DcdC550DddC750DedC850DfdC530D0eC340D1eC420D2eC330D3eC440D4eC520D5eC430D6eC640D7eC450D8eC640D9eC630DaeC640DbeC450DceC560DdeC650DeeC571DfeC640D0fC540D1fC440D2fC430L3f4fC330L5f6fC540L7f8fC660D9fC871DafC660LbfcfC671Ldfff" {
     run('URL...', 'url=' + _URL);
}

macro "Analyze Image (f5) Action Tool - C000T4b12i" {
    analyzeImage();
}

macro "Analyze Image (f5) Action Tool Options" {
    showAnalyzeImageOptions();
}

macro "Batch Analyze Images (f6) Action Tool - C000T4b12b" {
    batchAnalyzeImages();
}

macro "Batch Analyze Images (f6) Action Tool Options" {
    showBatchAnalyzeImagesOptions();
}

macro "Batch Analyze Images [f6]" {
    batchAnalyzeImages();
}


macro "Install or Update Action Tool - N66C000D2dD2eD3cD58D59D5aD67D75Db3DbeDc3DcdDceDd3DddDdeDe3DeeC666D69Db4De4C222D2cD57D76D85D93DaeDc9DcaDcbDccDd9DdaDdbDdcCdddD0eD2aD47D4dD55D64D6bD8dDb9DbaDbbDc1Dd1De9DeaDebC111D3bD4aD94DadDbdDedC999D48D86D95Dc4Dd4C555D74Dc2Dd2CfffD0dD1bD46D87Da5Db1Db8De1De8C000D4bD66D84Da3C888D2bD3eD6aDa2C444D1eD3dD65D68D9dDa4CeeeD39D5cD73D79D9cDacCbbbD1cD78D92D9eDbcDc8Dd8DecC555D49D5bDb2De2C777D1dD3aD4cD56D77D83Bf0C000D35D47D58D59D5aD7cD8dD8eC666D49C222D0eD13D25D36D57D8cCdddD2dD44D4bD55D67D6dD8aDaeC111D0dD14D6aD7bC999D15D26D68C555D34CfffD05D27D66D9bDadC000D03D24D46D6bC888D02D4aD7eD8bC444D04D1dD45D48D7dD9eCeeeD0cD1cD33D39D5cD79CbbbD12D1eD38D9cC555D5bD69C777D23D37D56D6cD7aD9dB0fC000D65D74D80D81D82C666D35C222D55D64D90CdddD76D94Da0Da1C111D56D73C999D00D54D63D70D71D93C555D37D45D66D84CfffD10D67C000D06D16D26D36D46D83C888D05D15D25C444D07D17D27D75D91CeeeD01D44D62Da2CbbbD57D85C555D72D92C777D47Nf0C000D20D21D22D34D45Dc0Dd0C666D75Db1De1C222D44D55Db0De0CdddD00D01D14D36Dc3Dd3C111D23D33D56C999D13D30D31D43D54Da0C555D24D46D65D77CfffD47D90C000D66D76D86D96Da6Db6Dc1Dc6Dd1Dd6De6C888D85D95Da5Db5Dc5Dd5De5C444D10D11D35D87D97Da7Db7Dc7Dd7De7CeeeD02D42D64Da1Db2De2CbbbD25D57C555D12D32Dc2Dd2C777D67"{
    installOrUpdate();
}


function analyzeImage() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    params = readOptionsAnalyzeImage();
    run("analyze kinetochores", params);   
}


function batchAnalyzeImages() {
    call("ij.Prefs.set", "mri.options.only", "false");   
    params = readOptionsBatchAnalyzeImages();
    run("batch analyze kinetochores", params); 
}


function showAnalyzeImageOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("analyze kinetochores");
    call("ij.Prefs.set", "mri.options.only", "false");   
}


function showBatchAnalyzeImagesOptions() {
    call("ij.Prefs.set", "mri.options.only", "true");
    run("batch analyze kinetochores");
    call("ij.Prefs.set", "mri.options.only", "false");   
}

function getOptionsPathAnalyzeImage() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "kinetochore_analyzer/analyze_image_options.json";
    return optionsPath;
}


function getOptionsPathBatchAnalyzeImages() {
    pluginsPath = getDirectory("plugins");
    optionsPath = pluginsPath + "kinetochore_analyzer/batch_analyze_images_options.json";
    return optionsPath;
}

function readOptionsAnalyzeImage() {
    path = getOptionsPathAnalyzeImage();
    options = readOptions(path);
    return options;
}


function readOptionsBatchAnalyzeImages() {
    path = getOptionsPathBatchAnalyzeImages();
    options = readOptions(path);
    return options;
}

function readOptions(path) {
    if (!File.exists(path)) {
        return "";
    }
    text = File.openAsString(path);
    text = replace(text, "https:", "httpsD");
    text = replace(text, '\\:\\\\', '\\*\\\\');
    parts = split(text, '}');
    options = "";
    booleanOptions = "";
    for (i = 0; i < parts.length; i++) {    
        line = parts[i];
        if (line.length==0) continue;
        line = replace(line, '{', "");
        line = replace(line, '"', '');
        name = split(line, ":");
        name = replace(name[0], ", ", "");
        name = String.trim(name);
        if (name == "") continue;
        nameParts = split(name, " ");
        option = nameParts[0]; 
        params = substring(line, indexOf(line, ":"));
        params = split(params, ",");
        type = split(params[1], ':');
        type = String.trim(type[1]);
        transient = split(params[2], ':');
        transient = String.trim(transient[1]);
        if (transient=='true') continue;
        value = split(params[5], ':');
        value = String.trim(value[1]);
        if (type=='bool' && value=='true') {
            booleanOptions = booleanOptions + " " + option;
        }
        if (type=='int' || type=='float' || type=='str') {
            options = options + " " + option + "=" + value;
        }
    }
    options = options + booleanOptions;
    options = replace(options, "httpsD", "https:");
    options = replace(options, '\\*\\\\', '\\:\\\\');
    options = String.trim(options);
    return options;
}


function installOrUpdate() {        

       
}