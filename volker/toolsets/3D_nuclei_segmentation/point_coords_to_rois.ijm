RADIUS = 5;

for (i = 0; i < nResults(); i++) {
    x = getResult("X", i);
    y = getResult("Y", i);
    z = getResult("Z", i);
    setSlice(z+1);
    makeOval(x-RADIUS, y-RADIUS, 2*RADIUS+1, 2*RADIUS+1);
    roiManager("add");
}
run("Select None");