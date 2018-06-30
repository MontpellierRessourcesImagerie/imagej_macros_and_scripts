var _SIGMA = 7;
var _NOISE = 100;
var _THRESHOLD = 10400;

run("Set Measurements...", "area mean standard modal min centroid center integrated display redirect=None decimal=3");
run("Duplicate...", " ");
run("Gaussian Blur...", "sigma=" + _SIGMA);
run("Find Maxima...", "noise="+_NOISE+" output=[Point Selection] exclude");
run("Clear Results");
run("Measure");

xCoordinates = newArray();
yCoordinates = newArray();

for(i=0; i<nResults; i++) {
	mean = getResult("Mean", i);
	if (mean>_THRESHOLD) {
		x = getResult("X", i);
		y = getResult("Y", i);
		xCoordinates = Array.concat(xCoordinates, x);
		yCoordinates = Array.concat(yCoordinates, y);
	}
}

close();
makeSelection("point",xCoordinates,yCoordinates);
roiManager("reset");
roiManager("Add");
roiManager("Select", 0);
roiManager("Set Color", "blue");
roiManager("Set Line Width", 0);

macrosDir = getDirectory("macros");
script = File.openAsString(macrosDir + "/toolsets/dbscan_clustering.py");
parameter = "";
call("ij.plugin.Macro_Runner.runPython", script, parameter); 

count = roiManager("count");
indices = newArray();
for(i=1; i<count; i++) {
	Array.concat(indices, i);
}
roiManager("Select", indices);
roiManager("Set Color", "yellow");
roiManager("Show None");
roiManager("Show All");
run("Select None");