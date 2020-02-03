var _NR_OF_CHANNELS = 3;
var _CHANNEL_NAMES = newArray("blue", "green", "red");
var _CHANNEL_IDS = newArray("d0", "d1", "d2");
var _FILE_EXTENSION = "tiff";

directory = getDirectory("Choose a Directory");
files = getFileList(directory);
images = filterFiles(directory, files);

if (images.length % _CHANNEL_IDS.length != 0) {
	showMessage("Wrong number of images !");
	exit();
}


outFolder = directory + "merged/";
if (!File.exists(outFolder)) {
	File.makeDirectory(outFolder);
}

blueImages = newArray(images.length / 3);
greenImages = newArray(images.length / 3);
redImages = newArray(images.length / 3);
counter = 0;
for (i = 0; i < images.length; i++) {
	image = toLowerCase(images[i]);
	if (endsWith(image, _CHANNEL_IDS[0]+"."+_FILE_EXTENSION)) {
		blueImages[counter] = images[i];
		greenImages[counter] = replace(blueImages[counter], _CHANNEL_IDS[0]+"." , _CHANNEL_IDS[1]+".");
		redImages[counter] = replace(blueImages[counter], _CHANNEL_IDS[0]+".", _CHANNEL_IDS[2]+".");
		counter++;
	}
}

setBatchMode(true);
print("\\Clear");

for (i = 0; i < blueImages.length; i++) {
	print("\\Update0:Merging image " + (i+1) + " of " + blueImages.length);	
	open(directory + blueImages[i]);
	run("Enhance Contrast", "saturated=0.35");
	blueTitle = getTitle();
	open(directory + greenImages[i]);
	run("Enhance Contrast", "saturated=0.35");
	greenTitle = getTitle();
	open(directory + redImages[i]);
	run("Enhance Contrast", "saturated=0.35");
	redTitle = getTitle();
	run("Merge Channels...", "c1="+redTitle+" c2="+greenTitle+" c3="+blueTitle+" create");
	outName = replace(blueImages[i], _CHANNEL_IDS[0]+".", ".");
	saveAs("tiff", outFolder + outName);
	close();
}
setBatchMode(false);

function filterFiles(dir, files) {
	filteredFiles = newArray(0);
	for(i=0; i<files.length; i++) {
		file = files[i];
		if (File.isDirectory(dir + "/" + file)) continue;
		if (!endsWith(toLowerCase(file), "."+toLowerCase(_FILE_EXTENSION))) continue;
		filteredFiles = Array.concat(filteredFiles, file);
	}
	return filteredFiles;
}