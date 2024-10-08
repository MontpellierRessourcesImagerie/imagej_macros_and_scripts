/**  
 *   
 *   Call the Measure Roi plugin for each selected ROI in the roi-manager or for all the ROIs 
 *   in the roi-manager if none are selected. Add the length and width of each roi to the line 
 *   of the roi in the Results-table. 
 *   
 *   The [Measure Roi plugin](https://www.optinav.info/Measure-Roi.htm) needs to be installed
 *   
 *  (c) INSERM, 2022 
 *  
 *  written 2022 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
 **
*/
/** 
 *  Select and execute the following two lines to open the help pages:
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Measure_Rois";
run('URL...', 'url='+helpURL);    
*/

run("Clear Results");
roiManager("measure");
labels = Table.getColumn("Label", "Results");
allRoisCount = roiManager("count");
for (i = 0; i < labels.length; i++) {
    for (c = 0; c < allRoisCount; c++) {
        roiManager("select", c);
        label = getInfo("roi.name");
        if (indexOf(labels[i], label) >=0) {
            run("Measure Roi");
            lengths = Table.getColumn("Roi_Length", "Results");
            widths = Table.getColumn("Roi_Width", "Results");
            length  = lengths[lengths.length - 1];
            width = widths[widths.length - 1];
            Table.deleteRows(lengths.length-1, lengths.length-1);
            setResult("Roi_Length", i, length);
            setResult("Roi_Width", i, width);
        }
    }
}
run("Select None");
roiManager("deselect");
