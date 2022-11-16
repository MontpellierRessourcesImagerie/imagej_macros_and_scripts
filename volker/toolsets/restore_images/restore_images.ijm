NR_OF_CHANNELS = 4;
NR_OF_FIELDS = 5;
run("Bio-Formats Macro Extensions");
ROOT_PATH = "/media/baecker/Jade LEIBA Im7/work/";
OUT_PATH = "/media/baecker/Jade LEIBA Im7/out/";

dir = getDir("select a folder!");
files = getFileList(dir);

for (i = 0; i < files.length; i++) {
    file = files[i];
    c = IJ.pad(i, 4);
    File.rename(dir + file, dir + "f"+c+"ch"+(i%4));
}

for (i = 0; i < NR_OF_CHANNELS; i++) {
    ch = IJ.pad(i, 2);
    if (!File.exists(dir + "channel-" + ch)) {
        File.makeDirectory(dir + "channel-" + ch);
    }
    File.openSequence(dir, " filter=ch"+ch);
    splitFields(NR_OF_FIELDS, dir + "channel-" + ch);
    close();
}


function splitFields(nrOfFields, outFolder) {
    title = getTitle();
    zSlices = nSlices / nrOfFields;
    field = 1;
    inputImageID = getImageID();
    for(startSlice = 1; startSlice   < nSlices; startSlice = startSlice + zSlices) {
        fieldText = IJ.pad(field, 2);
        endSlice = startSlice + zSlices - 1;
        print(startSlice, endSlice);
        run("Duplicate...", "duplicate range=" + startSlice + "-" + endSlice);
        rename("f" + fieldText + "-" + title); 
        save(outFolder + "/" + fieldText + "-" + title);
        close();
        selectImage(inputImageID);
        field++;
    }
}

function reorderImages() {
    dirs = getFileList(ROOT_PATH);
    for (i = 0; i < dirs.length; i++) {
        dir = ROOT_PATH + dirs[i];
        files = getFileList(dir);
        images = filterImages(files);
        print("" + images.length + " images found.");
        for (f = 0; f < images.length; f++) {
            image = images[f];
            Ext.setId(dir +  image);
            Ext.getMetadataValue("Date", date);       
            Ext.getMetadataValue("Time", time);
            Ext.getMetadataValue("Image name", name);
            Ext.getMetadataValue("Timestamp for Z= 0, C= 0, T= 0", ts);
            print(i, image, name, date, time, ts);
            if (!File.exists(ROOT_PATH + name)) File.makeDirectory(ROOT_PATH + name);
            print(dir + image);
            print(OUT_PATH + name + image);
            File.copy(dir + image, OUT_PATH + "/" + name + "/" + image);
        }
    }
}

function filterImages(files) {
    images = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = files[i];
        if (endsWith(file, ".tif")) {
            images = Array.concat(images, file); 
        }
    }
    return images;
}

    