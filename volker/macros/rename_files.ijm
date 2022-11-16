dir = getDir("select a folder!");
files = getFileList(dir);
Array.print(files);

for (i = 0; i < files.length; i++) {
    file = files[i];
    c = IJ.pad(i, 4);
    File.rename(dir + file, dir + "f"+c+"ch"+(i%4));
}
