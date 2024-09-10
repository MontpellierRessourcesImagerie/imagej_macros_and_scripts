/**
  *  Tools to measure pith, bark and annual rings in stained sections of tree trunks.
  *   
  *  (c) 2024, INSERM
  *  written  by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  * 
  **
*/

var _URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Tree-Ring-Tools";

macro "MRI Tree Ring Tool Help Action Tool - C000D16D17D18D19D24D25D26D27D28D29D2aD2bD33D34D3bD3cD42D43D4cD4dD52D57D58D5dD61D62D65D66D67D68D69D6aD6dD6eD71D72D75D76D79D7aD7dD7eD81D82D85D8aD8dD8eD91D92D95D96D99D9aD9dD9eDa1Da2Da6Da7Da8Da9DadDb2Db3DbcDbdDc2Dc3Dc4DcbDccDd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDe5De6De7De8De9" {
    run('URL...', 'url='+_URL);
}

macro "extract masks Action Tool - C000T4b12e" {
    run("extract masks")
}
