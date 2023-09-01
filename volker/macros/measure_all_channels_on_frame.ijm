macro "ROI Manager Action" {
    Stack.getDimensions(width, height, channels, slices, frames);
    nrOfRois = roiManager("count");
    for(roi = 0; roi < nrOfRois; roi++) {
        roiManager("select", roi);
        Stack.getPosition(channel, slice, frame);
        for(channel = 1; channel<=channels; channel++) {
            Stack.setChannel(channel);
            run("Measure");
            Table.set("field", nResults-1, frame);
            Table.set("channel", nResults-1, channel)
        }
    }
}

