#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output
#@ String (label = "File suffix", value = ".tif") suffix

processFolder(input+File.separator);

function processFolder(input) {
    subFolders = getSubFoldersIn(input);
    images = getImagesIn(input);
    if (images.length>=2) {
	    openImagesInList(images);
	    title = getTitle();
	    run("Concatenate...", "all_open");
	    namePrefix = File.getName(input);
        save(output + File.separator + namePrefix + "-" +title);
	    close();
    }
    for (i = 0; i < subFolders.length; i++) {
        processFolder(subFolders[i]);
    }
}

function openImagesInList(images) {
    for (j = 0; j < images.length; j++) {
        open(images[j]);
    }    
}

function getSubFoldersIn(aFolder) {
    list = getFileList(input);
    subFolders = newArray(0);
    for (i = 0; i < list.length; i++) {
        file = list[i];
        if (File.isDirectory(input + file)) {
           subFolders = Array.concat(subFolders, input + file);     
        }
    } 
    return subFolders;
}

function getImagesIn(aFolder) {
    list = getFileList(aFolder);
    images = newArray(0);
    for (i = 0; i < list.length; i++) {
        file = list[i];
        if (endsWith(file, suffix)) {
            images = Array.concat(images, aFolder + file);       
        }
    } 
    return images;
}

