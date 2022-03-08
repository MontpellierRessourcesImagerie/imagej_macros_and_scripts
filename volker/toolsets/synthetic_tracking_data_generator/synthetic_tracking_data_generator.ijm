TIMEPOINTS = 10;
IMAGE_WIDTH = 1600;
IMAGE_HEIGHT = 1600;
NR_OF_PARTICLES = 30;
MEAN_SPEED = 5;
SPEED_STDDEV = 1;
ANGULAR_DEVIATION_MAX = 30;
CENTER_X = IMAGE_WIDTH/2;
CENTER_Y = IMAGE_HEIGHT/2;
INITIAL_DISTANCE = 150;
INITIAL_DISTANCE_STD_DEV;


X_COORDS = newArray(NR_OF_PARTICLES);
Y_COORDS = newArray(NR_OF_PARTICLES);

for (i = 0; i < NR_OF_PARTICLES; i++) {
    // Create a random position with distance INITIAL_DISTANCE and stdDev INITIAL_DISTANCE_STD_DEV
    angle = random * 360;
    distance = random("gaussian") * INITIAL_DISTANCE_STD_DEV + INITIAL_DISTANCE;
    X_COORDS[i] = distance * cos(angle*(PI/180));
    Y_COORDS[i] = distance * sin(angle*(PI/180));
}

report(0, 

for (t = 1; t < TIMEPOINTS; t++) {
    
}

Table.create("moving particles");




function report(label, spotID, trackID, quality, x, y, z, t) {
    
}