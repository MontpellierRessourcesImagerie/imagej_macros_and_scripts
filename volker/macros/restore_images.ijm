run("Bio-Formats Macro Extensions");
ROOT_PATH = "/media/baecker/Jade LEIBA Im7/work/";
OUT_PATH = "/media/baecker/Jade LEIBA Im7/out/";

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
