run("Bio-Formats Macro Extensions");
dir = getDir("Input Folder");
outDir = getDir("Output Folder");

files = getFileList(dir);

for (i = 0; i < files.length; i++) {
    file = files[i];
    path = dir + file;
    Ext.setId(path);
    Ext.getSeriesCount(seriesCount);
    for (j = 1; j <= seriesCount; j++) {
        run("Bio-Formats", "open=["+path+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_"+j);
        filename = File.nameWithoutExtension;        
        save(outDir + filename + 'series_' + j + '.tif');
        close();
    }       
}



