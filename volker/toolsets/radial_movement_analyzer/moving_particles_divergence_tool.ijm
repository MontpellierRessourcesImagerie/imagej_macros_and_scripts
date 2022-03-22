/*
 Moving particles divergence tool. 

(c) 2022, INSERM
written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)

The tool takes a results table of tracking data (as created by Trackmate) and calculates the mean of the scalar projections of the vector of the 
displacement of each particle from one timepoint t to the next t+1, onto the vector from a given point to the coordinates of the particle at timepoint t 

If the particles are moving away from the given point the result will be positive, if they are moving towards the given point the result will be negative.
If neither of the above is the case, the result will be near zero.
*/

var DISPLAY_PLOT = true;

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Moving_Particles_Divergence_Tool";

macro "Moving Particles Divergence Tool Help [f4]" {
    run('URL...', 'url='+helpURL);
}

macro "Moving Particles Divergence Help (f4) Action Tool - CfffL00f0L0161CeeeD71CfffL81f1L0262C333D72CfffL82f2L0313CaaaD23C666D33CeeeD43CfffD53CdddD63CbbbD83CfffL93a3CaaaDb3C777Dc3CfffLd3f3L0424C222D34CeeeD54CbbbD64D84CfffD94C333Da4CbbbDc4CfffLd4f4L0525CaaaD35C333D45C666D55CfffD65D85C888D95C333Da5C666Db5CfffLc5f5L0646C333D56CbbbD66CcccD86C444D96CfffDa6CeeeDb6CfffLc6f6D07CdddD17C666D27C444D37CaaaL4757CfffD67CbbbD77CfffD87C888D97C666Da7C222Db7C333Dc7CaaaDd7CfffLe7f7D08C888D18C222L2838C666D48CaaaD58CfffD68CeeeD78CfffD88CbbbD98CaaaDa8C444Lb8c8CbbbDd8CfffLe8f8L0929CeeeD39CfffD49C777D59CfffD69CcccD89C666D99CfffLa9f9L0a2aCbbbD3aC444D4aC666D5aCfffD6aD8aC333D9aC777DaaCdddDbaCfffLcafaL0b1bCdddD2bC444D4bCfffD5bCdddD6bCcccL8b9bC444DbbCfffLcbfbL0c1cC444D2cC666D3cCbbbD4cCfffD5cCbbbD6cCaaaD8cCfffD9cC888DacC222DbcCeeeDccCfffLdcfcL0d1dCdddD2dCfffL3d6dC222D7dCfffL8dbdCdddDcdCfffLddfdL0e6eCcccD7eCfffL8efeL0fff"{
    run('URL...', 'url='+helpURL);
}


macro "calculate particle divergence (f5) Action Tool - C000T4b12d" {
    calculateDivergence();
}

macro "calculate particle divergence [f5]" {
    calculateDivergence();
}

macro "calculate particle divergence (f5) Action Tool Options" {
    Dialog.create("calculate particles divergence options");
    Dialog.addCheckbox("display plot", DISPLAY_PLOT);
    Dialog.show();
    DISPLAY_PLOT = Dialog.getCheckbox();
}

function calculateDivergence() {
    table = Table.title
    macrosDir = getDirectory("macros");
    script = File.openAsString(macrosDir + "/toolsets/moving_particles_divergence_tool.py");
    plotParam = "false";
    if (DISPLAY_PLOT)
        plotParam = "true";
    parameter = "table="+table+",plot="+plotParam;
    call("ij.plugin.Macro_Runner.runPython", script, parameter);      
}
