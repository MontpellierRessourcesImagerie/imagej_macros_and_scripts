NAME_FILTER = "Coleno";
NR_OF_FILES_PER_FOLDER = 10;
SUBFOLDER = "/Mosaic_16bits/";
PARTS = newArray("405", "640");
dir = getDir("Select the input folder!");
destDir = getDir("Select the target folder!");
files = getFileList(dir);
folders = filterFolders(files);
Array.print(folders);
for (i = 0; i < folders.length; i++) {
	showProgress(i+1, folders.length);
	folder = dir + folders[i] + SUBFOLDER;
	File.makeDirectory(destDir + "/" + folders[i]);
	files = getFileList(folder);
	partFiles = getPartFiles(files, PARTS[0]);
	Array.sort(partFiles);
	indices = Array.getSequence(partFiles.length);
	shuffle(indices);
	for (p = 0; p < PARTS.length; p++) {
		part = PARTS[p];
		if (p>0) replaceFile(partFiles, PARTS[p-1], PARTS[p]);
		for (f = 0; f < NR_OF_FILES_PER_FOLDER; f++) {
			File.copy(folder + "/" + partFiles[indices[f]], destDir + "/" + folders[i] + partFiles[indices[f]]);
		}
	}
}

function replaceFile(files, part1, part2) {
	for (i = 0; i < files.length; i++) {
		files[i] = replace(files[i], part1, part2);
	}
}

function shuffle(array) {
	for (i = 0; i < array.length; i++) {
		randomIndexToSwap = randomInt(array.length);
		temp = array[randomIndexToSwap];
		array[randomIndexToSwap] = array[i];
		array[i] = temp;
	}
}

function randomInt(n) {
	rand = random;
	res = floor(n * rand);
	return res;
}

function getPartFiles(files, part) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (indexOf(file, part)>-1) {
			res = Array.concat(res, file);			
		}
	}
	return res;
}

function filterFolders(files) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		if (indexOf(files[i], NAME_FILTER)>-1) {
			res = Array.concat(res, files[i]);
		}
	}
	return res;
}
