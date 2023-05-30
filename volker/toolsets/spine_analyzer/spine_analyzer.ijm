Stack.getPosition(channel, slice, frame);
imageID = getImageID();
spineID = segment3DObjectInRegion()

// addSpine(spineID, imageID);

selectImage(imageID);
addEmptyChannel(imageID);
imageID = getImageID();

copyStackTo(imageID, spineID, 3, frame)

function segment3DObjectInRegion() {
    setBatchMode(true);
    Stack.getPosition(channel, slice, frame);
    run("Select None");
    run("Duplicate...", "duplicate channels="+channel+" frames="+frame);
    run("Restore Selection");
    run("Clear Outside", "stack");
    setAutoThreshold("Huang dark no-reset stack");
    run("Convert to Mask", "method=Huang background=Dark black");
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
    selectImage(imageID);
    channel = Property.get("spine-channel");
    
}


function addEmptyChannel(imageID) {
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
}


function copyStackTo(imageID, stackID, channel, frame) {
    selectImage(imageID);
    Stack.getPosition(startChannel, startSlice, startFrame);
    Stack.setPosition(channel, 1, frame);
    selectImage(stackID);
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
    Stack.setPosition(startChannel, startSlice, startFrame);
}
