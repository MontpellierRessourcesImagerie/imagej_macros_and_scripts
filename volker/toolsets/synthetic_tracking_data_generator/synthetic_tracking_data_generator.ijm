/***
 * 
 * Synthetic Tracking Data Generator
 * 
 * Create a time series of moving particles and a results table with the coordinates per timepoint, compatible with trackmate. 
 * The particles can move arbirarily, or they can move towards or away from a point.
 * By default the particles will move away from a center. By inversion they can move towards a center. Setting the ANGULAR_DEVIATION_MEAN and
 * ANGULAR_DEVIATION_STD to appropriate values the particles will neither move towards nor away from the center.
 * 
 * (c) 2022, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/
var TIMEPOINTS = 500;
var IMAGE_WIDTH = 1600;
var IMAGE_HEIGHT = 1600;
var NR_OF_PARTICLES = 30;
var MEAN_SPEED = 5;
var SPEED_STDDEV = 1;
var ANGULAR_DEVIATION_MEAN = 30;
var ANGULAR_DEVIATION_STD = 3;
var CENTER_X = IMAGE_WIDTH/2;
var CENTER_Y = IMAGE_HEIGHT/2;
var INITIAL_DISTANCE = 150;
var INITIAL_DISTANCE_STD_DEV = 7;
var INVERTED = false;
var SPOT_RADIUS = 3;
var X_COORDS = newArray(NR_OF_PARTICLES);
var Y_COORDS = newArray(NR_OF_PARTICLES);
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Synthetic_Tracking_Data_Generator";


macro "Synthetic_Tracking_Data_Generator help [f4]" {
    run('URL...', 'url='+helpURL);
}

macro "Synthetic_Tracking_Data_Generator help (f4) Action Tool - C111D30C222D40C111D50D21C666D31CaaaD41C666D51C111D61Da1C222Db1C111Dc1C222D22CaaaD32CfffD42CaaaD52C222D62C111D92C666Da2CaaaDb2C666Dc2C111Dd2D23C666D33CaaaD43C666D53C111D63C222D93CaaaDa3CfffDb3CaaaDc3C222Dd3C111D34C222D44C111D54D94C666Da4CaaaDb4C666Dc4C111Dd4D25C222D35C111D45Da5C333Lb5c5C111Dd5D16C666D26CaaaD36C666D46C111D56Da6C666Db6CaaaDc6C666Dd6C111De6C222D17CaaaD27CfffD37CaaaD47C222D57Da7CaaaDb7CfffDc7CaaaDd7C222De7C111D18C666D28CaaaD38C666D48C111D58Da8C777Db8CcccDc8C777Dd8C111De8C222D29C444D39C222D49C111Da9C777Db9CcccDc9C777Dd9C111De9D1aC666D2aCaaaD3aC666D4aC111D5aC222DaaCaaaDbaCfffDcaCaaaDdaC222DeaD1bCaaaD2bCfffD3bCbbbD4bC444D5bC111D6bDabC666DbbCaaaDcbC666DdbC111DebD1cC666D2cCbbbD3cCcccD4cCbbbD5cC666D6cC111D7cDbcC222DccC111DdcD2dC444D3dCbbbD4dCfffD5dCaaaD6dC222D7dC111D3eC666D4eCaaaD5eC666D6eC111D7eD4fC222D5fC111D6f"{
    run('URL...', 'url='+helpURL);
}

macro "Create Tracks [f5]"{
    createTracks();
}

macro "Create Tracks Action Tool (f5) - C000T4b12c" {
    createTracks();
}

macro "Create Tracks Action Tool (f5) Options" {
    Dialog.create("Create tracks Options");
    Dialog.addMessage("Image setup:");
    Dialog.addNumber("Nr. of frames: ", TIMEPOINTS);
    Dialog.addNumber("Image width: ", IMAGE_WIDTH);
    Dialog.addNumber("Image height: ", IMAGE_HEIGHT);
    Dialog.addMessage("Initial particle setup:");
    Dialog.addNumber("Nr. of particles: ", NR_OF_PARTICLES);
    Dialog.addNumber("Center x: ", CENTER_X);
    Dialog.addToSameRow();
    Dialog.addNumber("Center y: ", CENTER_Y);
    Dialog.addNumber("Initial distance: ", INITIAL_DISTANCE);
    Dialog.addToSameRow();
    Dialog.addNumber("Initial distance stdDev: ", INITIAL_DISTANCE_STD_DEV);
    Dialog.addMessage("Particle movement setup:");
    Dialog.addNumber("Mean speed", MEAN_SPEED);
    Dialog.addToSameRow();
    Dialog.addNumber("StdDev speed", SPEED_STDDEV);
    Dialog.addNumber("Mean angular deviation: ", ANGULAR_DEVIATION_MEAN);
    Dialog.addToSameRow();
    Dialog.addNumber("StdDev angular deviation", ANGULAR_DEVIATION_STD);
    Dialog.addCheckbox("Reverse time", INVERTED);
    Dialog.show();
    TIMEPOINTS = Dialog.getNumber();
    IMAGE_WIDTH = Dialog.getNumber();
    IMAGE_HEIGHT = Dialog.getNumber();
    NR_OF_PARTICLES = Dialog.getNumber();
    CENTER_X = Dialog.getNumber();
    CENTER_Y = Dialog.getNumber();
    INITIAL_DISTANCE = Dialog.getNumber();
    INITIAL_DISTANCE_STD_DEV = Dialog.getNumber();
    MEAN_SPEED = Dialog.getNumber();
    SPEED_STDDEV = Dialog.getNumber();
    ANGULAR_DEVIATION_MEAN = Dialog.getNumber();
    ANGULAR_DEVIATION_STD = Dialog.getNumber();
    INVERTED = Dialog.getCheckbox();
}

macro "Draw Tracks [f6]"{
    drawTracks();
}

macro "Draw Tracks Action Tool (f6) - C000T4b12d" {
    drawTracks();
}

macro "Draw Tracks Action Tool (f6) Options" {
    Dialog.create("Draw Tracks Options");
    Dialog.addNumber("spot radius: ", SPOT_RADIUS);
    Dialog.show();
    SPOT_RADIUS = Dialog.getNumber();
}

function createTracks() {
    X_COORDS = newArray(NR_OF_PARTICLES);
    Y_COORDS = newArray(NR_OF_PARTICLES);
    for (i = 0; i < NR_OF_PARTICLES; i++) {
        angle = random * 360;
        distance = random("gaussian") * INITIAL_DISTANCE_STD_DEV + INITIAL_DISTANCE;
        X_COORDS[i] = distance * cos(angle* PI/180);
        Y_COORDS[i] = distance * sin(angle* PI/180);
    }
    report(0, X_COORDS, Y_COORDS);
    for (t = 1; t < TIMEPOINTS; t++) {
        for (i = 0; i < X_COORDS.length; i++) {
            speed = random("gaussian") * SPEED_STDDEV + MEAN_SPEED; 
            angle = random("gaussian") * ANGULAR_DEVIATION_STD + ANGULAR_DEVIATION_MEAN;
            cDist = sqrt(X_COORDS[i] * X_COORDS[i] + Y_COORDS[i] * Y_COORDS[i]);
            cAngle1 = asin(Y_COORDS[i] / cDist);
            cAngle1 = (cAngle1 * 180) / PI;
            cAngle2 = acos(X_COORDS[i] / cDist);
            cAngle2 = (cAngle2 * 180) / PI;
            sign = -1;
            if (random > 0.5) sign = 1;
            newAngle1 = ((sign * angle) + cAngle1) % 360;
            newAngle2 = ((sign * angle) + cAngle2) % 360;
            X_COORDS[i] =  X_COORDS[i] + speed * cos(newAngle2 * PI / 180);
            Y_COORDS[i] =  Y_COORDS[i] + speed * sin(newAngle1 * PI / 180);
        }
        report(t, X_COORDS, Y_COORDS);
    }
}

function drawTracks() {
    tColumn = Table.getColumn("T");
    xColumn = Table.getColumn("X");
    yColumn = Table.getColumn("Y");
    Array.getStatistics(tColumn, tmin, tmax);
    frames = tmax + 1;
    newImage("TRACKS", "8-bit grayscale-mode", 1600, 1600, 1, 1, frames);
    for (i = 0; i < xColumn.length; i++) {
        Stack.setFrame(tColumn[i]+1);    
        setColor("white");
        fillOval(xColumn[i], yColumn[i], 2*SPOT_RADIUS+1, 2*SPOT_RADIUS+1);  
    }
    Stack.setSlice(1);
    doCommand("Start Animation [\\]");
}

function report(t, X_COORDS, Y_COORDS) {
    if (!isOpen("Tracks")) {
        Table.create("Tracks");
    }
    for (i = 0; i < X_COORDS.length; i++) {
        rowIndex = t * X_COORDS.length + i;
        Table.set("LABEL", rowIndex, "ID"+IJ.pad(i, 3));
        Table.set("ID", rowIndex, i);
        Table.set("TRACK_ID", rowIndex, i);
        Table.set("QUALILTY", rowIndex, 1);
        Table.set("X", rowIndex, CENTER_X + X_COORDS[i]);
        Table.set("Y", rowIndex, CENTER_Y + Y_COORDS[i]);
        Table.set("Z", rowIndex, 0.0);
        realTime = t;
        if (INVERTED) realTime = (TIMEPOINTS-1)-t;
        Table.set("T", rowIndex, realTime);
    }

}