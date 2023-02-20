var RADIUS = 7;
var SIGMA = 0.45;
var DYNAMIC = 5000;
var CONNECTIVITY = 6;
var FILE_EXTENSION = "ics";

batchCountFISHSpots();
exit;

macro "Count FISH Spots (f5) Action Tool - C000T4b12c" {
    countFISHSpots();
}

macro "Count FISH Spots [f5]" {
    countFISHSpots();
}

macro "Count FISH Spots (f5) Action Tool Options" {
    Dialog.create("Count FISH Spots Options");
    Dialog.addNumber("radius: ", RADIUS);
    Dialog.addNumber("sigma: ", SIGMA);
    Dialog.addNumber("dynamic: ", DYNAMIC);
    Dialog.addNumber("connectivity: ", CONNECTIVITY);
    Dialog.show();
    RADIUS = Dialog.getNumber();
    SIGMA = Dialog.getNumber();
    DYNAMIC = Dialog.getNumber();
    CONNECTIVITY = Dialog.getNumber();
}


macro "Batch Count FISH Spots (f6) Action Tool - C000T4b12b" {
    batchCountFISHSpots();
}

macro "Batch Count FISH Spots [f6]" {
    batchCountFISHSpots();
}

macro "Batch Count FISH Spots (f6) Action Tool Options" {
    Dialog.create("Batch Count FISH Spots Options");
    Dialog.addString("file extensions: ", FILE_EXTENSION);
    Dialog.show();
    FILE_EXTENSION = Dialog.getString();
}

function countFISHSpots() {
    run("count spots", "rolling=" + RADIUS + " sigma=" + SIGMA + " dynamic=" + DYNAMIC + " connectivity=" + CONNECTIVITY);
}

function batchCountFISHSpots() {
    dir = getDir("Please select the input folder!");
    files = getFileList(dir);
    images = filterImages(files);
    for (i = 0; i < images.length; i++) {
        image = images[i];
        run("Bio-Formats", "open=[" + dir + "/" + image + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
        countFISHSpots();
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
