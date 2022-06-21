
getEightPointsFromCircle();

function getEightPointsFromCircle() {
    getSelectionCoordinates(xpoints, ypoints);
    number = xpoints.length / 8
    roiManager("reset");
    print(xpoints.length);
    for (i=0; i<xpoints.length; i++) {
        if ((i%number)==0) {
            makePoint(xpoints[i], ypoints[i]);
            roiManager("add");
        }
    }
    run("Select None");
    roiManager("deselect");
    roiManager("Remove Channel Info");
    roiManager("Remove Slice Info");
    roiManager("Remove Frame Info");
}

function getStackOfZAxisPlots() {
    count = roiManager("count");
    for (i = 0; i < count; i++) {
        roiManager("select", i);
        
    }

}
