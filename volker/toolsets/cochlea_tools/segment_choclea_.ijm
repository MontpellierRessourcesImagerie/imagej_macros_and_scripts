_INTERPOLATION_LENGTH = 20;
title = getTitle();
roiManager("reset");
run("Clear Results");
run("Skeletonize", "stack");
for (i = 1; i <= nSlices; i++) {
	Stack.setFrame(i);
	run("Geodesic Diameter", "label="+title+" distances=[Chessknight (5,7,11)] export");
	roiManager("Select", i-1);
	run("Interpolate", "interval="+_INTERPOLATION_LENGTH+" smooth ");
	run("Interpolate", "interval=1 smooth adjust");
	roiManager("Update");
	run("Select None");
}
Stack.setFrame(1);
roiManager("measure");
lengths = Table.getColumn("Length", "Results");
Plot.create("Length cochlea", "X-axis Label", "Y-axis Label", lengths);
Plot.show();	
