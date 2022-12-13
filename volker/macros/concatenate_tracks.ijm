dir = getDir("Select the input folder!");
files = getFileList(dir) ;
csvFiles = filterCSV(files);

for (i = 0; i < csvFiles.length; i++) {
	content = File.openAsString(dir + csvFiles[i]);
	lines = split(content, "\n");
	if (i==0) {
		for (l = 0; l < 4; l++) {
			File.append(lines[l], dir+"tracks.csv");
		}
	}
	for (l = 4; l < lines.length; l++) {
		line = lines[l];
		values = split(line, ",");
		x = values[0];
		y = values[1];
		t = values[6];
		trackID = toString(i+1) + toString(values[7]);
		id = "" + (i+1) + IJ.pad(values[8], 9);
		File.append(""+x+","+y+",0,µm,Spot,Position,"+t+","+trackID+","+id, dir+"tracks.csv");
	}
}

function filterCSV(files) {
	csvFiles = newArray(0);
	for (i = 0; i < files.length; i++) {
		if (endsWith(files[i], ".csv")) {
			csvFiles = Array.concat(csvFiles, files[i]);
		}
	}
	return csvFiles;
}
