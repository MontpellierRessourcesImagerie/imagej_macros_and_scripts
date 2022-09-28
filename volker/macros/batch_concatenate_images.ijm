#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

processFolder(input);

function processFolder(input) {
    list = getFileList(input);
    images = newArray(0);
    subFolders = newArray(0);
    for (i = 0; i < list.length; i++) {
        file = list[i];
        if (File.isDirectory(input + File.separator + file)) {
           subFolders = Array.concat(subFolders, input + File.separator + file);
           continue;
        }
        if (endsWith(file, suffix)) {
            images = Array.concat(images, file);       
        }
    }
    for (j = 0; j < images.length; j++) {
        open(input + File.separator + images[j]);
    }
    title = getTitle();
    run("Concatenate...", "all_open");
    subFolderName  = File.getName(input);
    save(output + File.separator + subFolderName + "-" + title);
    close();
    for (j = 0; j < subFolders.length; j++) {
        processFolder(subFolders[j]);
    }
}
