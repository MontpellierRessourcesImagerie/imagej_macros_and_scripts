var OUT_FOLDER = "converted/";
var EXTENSION = "TIF";
var INTERVAL = 600;			// in seconds
var FRAME_RATE = 2;

dir = getDir("Please select the input folder!");
files = getFileList(dir);
ndFiles = getNDFilesInList(dir, files);
numberOfTimepoints = 0;
paths = newArray(0);
numberOfPositions = 0;
if (!File.exists(dir+OUT_FOLDER)) {
	File.makeDirectory(dir+OUT_FOLDER);
}
for (i = 0; i < ndFiles.length; i++) {
	ndFile = ndFiles[i];
	ndContent = File.openAsString(ndFile);
	lines = split(ndContent, "\n");
	numberOfTimepoints = getNumberOfTimepoints(lines);
	numberOfPositions = getNumberOfPositions(lines);
	paths = getPaths(lines, dir, OUT_FOLDER);
	for (pos = 0; pos < numberOfPositions; pos++) {
		options = "filter=."+EXTENSION+" start="+((pos*numberOfTimepoints)+1)+" count="+numberOfTimepoints+" sort";
		print(options);
		File.openSequence(ndFile, options);
		Stack.setDimensions(1, 1, numberOfTimepoints) 
		Stack.setFrameInterval(INTERVAL);
		Stack.setTUnit("sec") 
		run("Time Bar...", "offset=0 thickness=4 font=28 color=Black background=White location=[Lower Right] time=D-HH:mm bold hide overlay");
		saveAs("tiff", paths[pos]);
		run("Remove Overlay");
		run("Time Bar...", "offset=0 thickness=4 font=28 color=Black background=White location=[Lower Right] time=D-HH:mm bold hide");
		outPath = replace(paths[pos], ".tif", ".avi");
		run("AVI... ", "compression=JPEG frame="+FRAME_RATE+" save="+outPath);
		close();
	}
}
function getPaths(lines, dir, out) {
	paths = newArray(0);
	for (i = 0; i < lines.length; i++) {
		line = lines[i];
		parts = split(line, ", ");
		name = replace(parts[0], '"', '');
		if (startsWith(name, 'Stage')) {
			value = replace(parts[1], '"', '');
			paths = Array.concat(paths, dir+out+value+'.tif');
		}
	}
	return paths;
}

function getNumberOfTimepoints(lines) {
	number = getValueAt('NTimePoints', lines);
	return number;
}

function getNumberOfPositions(lines) {
	number = getValueAt('NStagePositions', lines);
	return number;	
}

function getValueAt(key, lines) {
	for (i = 0; i < lines.length; i++) {
		line = lines[i];
		parts = split(line, ",");
		name = replace(parts[0], '"', '');
		if (name==key) {
			return parseInt(parts[1]);
		}
	}
	return 0;
}
	
function getNDFilesInList(dir, aList) {
	ndFiles = newArray(0);
	for (i = 0; i < aList.length; i++) {
		file = aList[i];
		if (endsWith(file, ".nd")) {
			ndFiles = Array.concat(ndFiles, dir + file);
		}
	}
	return ndFiles;
}


