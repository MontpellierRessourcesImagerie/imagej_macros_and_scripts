dir = getDir("Please select a folder!");

files = getFileList(dir);
images = filterTIF(files);
Array.print(images);

for (i = 0; i < images.length; i++) {
    image = dir + images[i];
    run("Bio-Formats", "open=["+image+"] autoscale color_mode=Default display_metadata rois_import=[ROI manager] view=[Metadata only] stack_order=Default");
    winTitle = getInfo("window.title");
    content = getInfo("window.contents");
    rows = split(content, "\n");
    keys = newArray(rows.length);
    values = newArray(rows.length);
    for (r = 0; r < rows.length; r++) {
        parts = split(rows[r], "\t");
        keys[r] = parts[0];
        values[r] = parts[1];
    }
    title = images[i];
    
    for(k = 0; k<keys.length; k++) {
        if (keys[k]=="Image name") title = values[k];
    }
    File.rename(image, dir + title + "-" + images[i]);
    close(winTitle);
}



function filterTIF(files) {
    images = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = files[i];
        if (endsWith(file, ".tif")) {
            images = Array.concat(images, file);
        }
    }
    return images;
}
