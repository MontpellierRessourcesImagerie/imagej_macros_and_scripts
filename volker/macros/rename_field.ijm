fDigits = 3;

dir = getDirectory("Please select the input folder!");
files = getFileList(dir);
for (i = 0; i < files.length; i++) {
	file = files[i];
	if (!endsWith(file, ".tiff")) continue;
	parts = split(file, "-");
	r = getNumberBetween('r', 'c', parts[0]);
	c = getNumberBetween('c', 'f', parts[0]);
	f = getNumberBetween('f', 'p', parts[0]);
	f = IJ.pad(f, fDigits);
	remaining = parts[0];
	remaining = remaining + 'q';
	p = getNumberBetween('p', 'q', remaining);
	name = "r"+r+"c"+c+"f"+f+"p"+p;
	name = name + "-" + parts[1];
	print("renaming", file, " to ", name);
	File.rename(dir+file, dir+name);
}
print("---DONE---");

function getNumberBetween(char1, char2, text) {
	start = indexOf(text, char1);
	end = indexOf(text, char2);
	result = substring(text, start+1, end);
	return result;
}
