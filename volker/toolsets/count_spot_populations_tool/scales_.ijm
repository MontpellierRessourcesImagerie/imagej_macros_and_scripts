t0 = 0.5;
r = 1.5;
length = 15;
title = "Scales";
type = "line";

t = newArray(length);
t[0]=t0;

xValues = Array.getSequence(length);

for (i = 1; i < t.length; i++) {
	t[i] = r*t[i-1]; 
}

createPlot(title, "acmes", "scale");
addToPlot(title, type, "cyan", xValues, t, 2);

function createPlot(title, xAxisLabel, yAxisLabel) {
	Plot.create(title, xAxisLabel, yAxisLabel);
	Plot.show();
	return title;
}

function addToPlot(title, type, color, xValues, yValues, width) {
	selectWindow(title);
	Plot.setColor(color);
	Plot.add(type, xValues, yValues);
	Plot.setLimitsToFit();
}