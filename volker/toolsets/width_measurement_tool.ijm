width = getWidth();
height = getHeight();
maxDimension = maxOf(width, height);

run("Set Measurements...", "area standard centroid center fit shape display redirect=None decimal=9");
setAutoThreshold("Default dark");
run("Create Selection");
run("Measure");
row = nResults-1;
angle = getResult("Angle", row);
run("Select None");
run("Rotate... ", "angle="+angle+" grid=1 interpolation=Bilinear enlarge");

waitForUser("ok");

profile = getProfile();
minima = Array.findMinima(profile, 5);
maxima = Array.findMaxima(profile, 5);
Array.print(maxima);
Array.print(minima);