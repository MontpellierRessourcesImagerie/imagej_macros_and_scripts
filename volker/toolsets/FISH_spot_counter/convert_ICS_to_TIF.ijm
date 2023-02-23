FILE_EXTENSION = "ics";

batchconvertICS();

function batchconvertICS() {
    dir = getDir("Please select the input folder!");
    outDir = getDir("Please select the output folder!");
    files = getFileList(dir);
    images = filterImages(files);
    for (i = 0; i < images.length; i++) {
        image = images[i];
        run("Bio-Formats", "open=[" + dir + "/" + image + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
        saveAs("tiff", outDir + image);
        close();
    }
}

function filterImages(files) {
    images = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = files[i];
        if (endsWith(file, "." + FILE_EXTENSION)) {
            images = Array.concat(images, file);
        }
    }
    return images;
}