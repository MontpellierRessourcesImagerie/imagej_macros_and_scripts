var LUT = "glasbey on dark";
var THRESHOLDING_METHOD = "Default";
Stack.getPosition(channel, slice, frame);
spineChannel = Property.get("spine-channel");
if (spineChannel != "" && channel == parseInt(spineChannel)) {
    exit("Please run the segmentation on a greyscale channel!");
}
imageID = getImageID();
spineID = segment3DObjectInRegion();
addSpine(spineID, imageID);
selectImage(spineID);
close();

function segment3DObjectInRegion() {
    setBatchMode(true);
    Stack.getPosition(channel, slice, frame);
    run("Select None");
    run("Duplicate...", "duplicate channels="+channel+" frames="+frame);
    run("Restore Selection");
    run("Clear Outside", "stack");
    setAutoThreshold(THRESHOLDING_METHOD + " dark no-reset stack");
    run("Convert to Mask", "method="+THRESHOLDING_METHOD+" background=Dark black");
    mask = getImageID();
    run("Connected Components Labeling", "connectivity=6 type=[8 bits]");
    labels = getImageID();
    run("Keep Largest Label");
    id = getImageID();
    selectImage(mask);
    close();
    selectImage(labels);
    close();
    setBatchMode("exit and display");
    return id;
}

function addSpine(spineID, imageID) {
    id = imageID;
    selectImage(imageID);
    Stack.getPosition(currentChannel, currentSlice, frame);
    channel = Property.get("spine-channel");
    if (channel=="") {
        channel = addEmptyChannel(imageID);
        Property.set("spine-channel", channel);
        id = getImageID();
        label = 1;
    } else {
        Stack.setChannel(channel);
        getStatistics(area, mean, min, label);
        label++;
    }
    copyStackTo(id, spineID, channel, frame, label);
}


function addEmptyChannel(imageID) {
    selectImage(imageID);
    Stack.getDimensions(width, height, channels, slices, frames);        
    Stack.getPosition(channel, slice, frame);
    title = getTitle();
    run("Split Channels");
    run("Duplicate...", "duplicate");
    run("Select All");
    run("Clear", "stack");
    run("Select None");
    rename("C" + (channels+1) + "-" + title);
    mergeOptions = "";
    for (c = 1; c <= (channels+1); c++) {
        mergeOptions = mergeOptions + "c"+c+"=[C" + c + "-" + title +"] "; 
    }
    run("Merge Channels...", mergeOptions);
    Stack.setPosition(channel, slice, frame);
    return channels + 1;
}


function copyStackTo(imageID, stackID, channel, frame, label) {
    setPasteMode("Transparent-zero");
    selectImage(imageID);
    Stack.getPosition(startChannel, startSlice, startFrame);
    Stack.setPosition(channel, 1, frame);
    setBatchMode(true);
    selectImage(stackID);
    run("Replace/Remove Label(s)", "label(s)=255 final="+label);
    lastSlice = nSlices;
    for (s = 1; s <= lastSlice; s++) {
        selectImage(stackID);
        Stack.setSlice(s);
        run("Select All");
        run("Copy");
        selectImage(imageID);
        Stack.setSlice(s);
        run("Paste");
    }
    selectImage(imageID);
    setMinAndMax(0, label);
    run(LUT);
    Stack.setPosition(startChannel, startSlice, startFrame);
    setBatchMode("exit and display");
}
