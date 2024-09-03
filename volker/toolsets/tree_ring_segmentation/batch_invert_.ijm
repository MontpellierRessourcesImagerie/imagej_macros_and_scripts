directory = getDir("Input Folder");
files = getFileList(directory);
for (i = 0; i < files.length; i++) {
    showProgress(i+1, files.length);
    file = files[i];
    if (!endsWith(file, '.tif')) continue;
    open(directory + file);
    run("Invert");
    save(directory + "/inverted/" + file);
}
