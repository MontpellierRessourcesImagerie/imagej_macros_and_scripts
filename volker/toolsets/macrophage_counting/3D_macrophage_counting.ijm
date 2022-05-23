/***
 * 
 * MRI 3D macrophage counting
 * 
 * Count macrophages 
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/3D_Macrophage_Counting";

var X_SIZE = 100;
var Y_SIZE = 100;
var Z_SIZE = 100;
var SIGMA = 1.7;
var MINIMUM = 0;
var RADIUSXY = 6.15;
var RADIUSZ = 1.67;
var NOISE = 50;

macro "3D macrophage counting tool help [f4]" {
    run('URL...', 'url='+helpURL);
}

macro "3D macrophage counting tool help (f4) Action Tool - C100D40C200D50C100L60a0D31C200D41C400D51C500L6171C400D81C300L91a1C100Db1C200D32C400D42C600D52C800L6282C600D92C400Da2C200Db2D33C500D43C800D53Cc00D63Ce00L7383C800D93C500Da3C200Db3D34C600D44Ca00D54Cf00L6484Ca00D94C600Da4C300Db4C200D35C600D45Ca00D55Cf00L6585Cc00D95C600Da5C300Db5C200D36C600D46Cc00D56Cf00L6686Cc00D96C600Da6C200Db6D37C500D47Cc00D57Cf00L6787Cc00D97C600Da7C200Db7C100D38C400D48Ca00D58Cf00L6888Cc00D98C500Da8C100Db8D39C300D49C800D59Ce00D69Cf00L7989Cc00D99C500Da9C100Db9C300D4aC800D5aCf00L6a8aCe00D9aC500DaaC100DbaC200D4bC600D5bCe00D6bCf00L7b8bCa00D9bC400DabC100DbbD4cC400D5cC800D6cCe00L7c8cC600D9cC300DacC100DbcLdcecD5dC500D6dCa00L7d8dC400D9dC200DadC100LddedC200D6eC500L7e8eC200D9eC100DaeLdeeeL7f9fDef"{
    run('URL...', 'url='+helpURL);
}

macro "random substack (f2) Action Tool - C000T4b12r" {
    randomSubstack();
}

macro "random substack [f2]" {
    randomSubstack();
}

macro "random substack (f2) Action Tool Options" {
    Dialog.create("3D macrophage counting options");
    Dialog.addNumber("width: ", X_SIZE);
    Dialog.addNumber("height: ", Y_SIZE);
    Dialog.addNumber("depth: ", Z_SIZE);
    Dialog.show();
    X_SIZE = Dialog.getNumber();
    Y_SIZE = Dialog.getNumber();
    Z_SIZE = Dialog.getNumber();
}


macro "count macrophages (f3) Action Tool - C000T4b12c" {
    countMacrophages();
}

macro "count macrophages [f3]" {
    countMacrophages();
}

function randomSubstack() {
    getDimensions(width, height, channels, slices, frames);
    xMax = width - X_SIZE;
    yMax = height - Y_SIZE;
    zMax = slices - Z_SIZE;
    x = floor(random * xMax);
    y = floor(random * yMax);
    z = floor(random * zMax);
    makeRectangle(x, y, X_SIZE, Y_SIZE);
    run("Duplicate...", "duplicate range="+z+"-"+zMax+" use");    
}

function countMacrophages() {
    run("FeatureJ Laplacian", "compute smoothing="+SIGMA);
    run("Invert", "stack");
    run("3D Maxima Finder", "minimmum="+MINIMUM+" radiusxy="+RADIUSXY+" radiusz="+RADIUSZ+" noise="+NOISE);
}
