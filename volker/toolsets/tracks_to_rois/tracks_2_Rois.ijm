var COLORS = newArray('Red', 'Green', 'Blue', 'Magenta', 'Cyan', 'Yellow', 'Orange', 'Gray', 'lightGray', 'darkGray', 'Pink');
var CURRENT_COLOR = 0;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Tracks2Rois";

createTracksAsRois();
exit();

macro "Tracks 2 Rois Action Tool (F11) - C037T0b11TT7b092Tcb09R" {
   createTracksAsRois();
}

macro "Tracks 2 Rois [f11]" {
   createTracksAsRois();
}

macro "Tracks 2 Rois Action Tool (F11) Options" {
    Dialog.create("Tracks 2 Rois");
    Dialog.addMessage("Tracks2Rois - Convert Trackmate tracks to ROIS\n(c) 2022 INSERM\nwritten by Volker Baecker at Montpellier Ressources Imagerie");
    Dialog.addHelp(helpURL);
    Dialog.show();
}

function createTracksAsRois() {
    roiManager("reset");
    X = Table.getColumn("POSITION_X");
    Y = Table.getColumn("POSITION_Y");
    TRACKS = Table.getColumn("TRACK_ID");
    currentTrack = TRACKS[0];
    roiX = newArray(0);
    roiY = newArray(0);
    for(i=0; i<X.length; i++) {
        newTrack = TRACKS[i];
        if (currentTrack==newTrack) {
            roiX = Array.concat(roiX, X[i]);
            roiY = Array.concat(roiY, Y[i]);
        } 
        if (currentTrack != newTrack || i==X.length-1) {
            makeSelection("polyline ", roiX, roiY);
            roiManager("add");
            count = roiManager("count");
            roiManager("select", count-1);
            roiManager("Set Color", COLORS[CURRENT_COLOR]);
            CURRENT_COLOR = (CURRENT_COLOR + 1) % COLORS.length;
            run("Select None");
            if (i<X.length-1) {
                 currentTrack = newTrack;
                 roiX = newArray();
                 roiY = newArray();
                 roiX = Array.concat(roiX, X[i]);
                 roiY = Array.concat(roiY, Y[i]);
            }
        }
    }
    roiManager("Remove Channel Info");
    roiManager("Remove Slice Info");
    roiManager("Remove Frame Info");
}

