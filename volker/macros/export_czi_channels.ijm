SERIES = 3;
EXT = "czi";
folder = getDir("Select the input folder");
files = getFileList(folder);
outFolder = folder + "channels" + File.separator;
setBatchMode(true);
if (!File.exists(outFolder)) File.makeDirectory(outFolder);
for (i = 0; i < files.length; i++) {
	file = folder + files[i];
	if (File.isDirectory(file)) continue;
	if (!endsWith(file, EXT)) continue;
	print(file);
	run("Bio-Formats", "open=["+file+"] color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT series_"+SERIES);
	imageTitles = getList("image.titles");
	nrOfChannels = imageTitles.length;
	for (j = 0; j < nrOfChannels; j++) {
		name = getTitle();
		save(outFolder + name + ".tif");
		close();	
	}
}
setBatchMode("exit and display");
print("Conversion finished");

