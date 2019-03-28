title = "DoG";
type = "line";
mu1 = 0;
mu2 = 0;
k = 1;
diameter = 45;
height = 0.04;
stdDev1 = diameter/2.5;
stdDev2 = 1.6*stdDev1; 
title = title + " k="+k+", sigma="+stdDev1;

xValues = getRange(mu1-3*stdDev2, mu2+3*stdDev2, 0.1);
gauss1 = getGaussian1D(mu1, stdDev1, xValues);
gauss2 = getGaussian1D(mu2, stdDev2, xValues);
k = height * (1 / (gauss(0, mu1, stdDev1)-gauss(0, mu2, stdDev2)));
k2 = height * (1 / LoG(0, mu1, stdDev1));
dog = difference(gauss1, gauss2, k);
Log = getLoG1D(mu1, stdDev1, xValues, k2);

createPlot(title, "acmes", "prob. density");
addToPlot(title, type, "cyan", xValues, gauss1, 2);
addToPlot(title, type, "magenta", xValues, gauss2, 2);
addToPlot(title, type, "blue", xValues, dog, 2);

createPlot("LoG", "acmes", "prob. density");
addToPlot("LoG", type, "red", xValues, Log, 2);
addToPlot("LoG", type, "blue", xValues, dog, 2);

function gauss(x, mu, sigma) {
	res = (1/(sigma*sqrt(2*PI)))*exp(-0.5*pow(((x-mu)/sigma),2));
	return res;
}

function LoG(x, mu, sigma) {
	res = (1/(sigma*sqrt(2*PI)))*((((x*x)-(2*sigma*sigma))/pow(sigma,4)))*exp(-0.5*pow(((x-mu)/sigma),2));
	return res;
}

function difference(list1, list2, k) {
	diff = newArray(list1.length);
	for (i = 0; i < list1.length; i++) {
		diff[i] = k*(list1[i] - list2[i]);	
	}
	return diff;
}

function getRange(start, end, step) {
	N = (floor((end-start) / step))+1;
	range = newArray();
	for (i = start; i <= end; i=i+step) {
		range = Array.concat(range,i);
	}
	return range;
}

function getGaussian1D(mu, sigma, xValues) {
	gaussian = newArray(xValues.length);
	for(i=0; i<xValues.length; i++) {
		gaussian[i] = gauss(xValues[i], mu, sigma);
	}
	return gaussian;
}

function getLoG1D(mu, sigma, xValues, k) {
	Log = newArray(xValues.length);
	for(i=0; i<xValues.length; i++) {
		Log[i] = k*LoG(xValues[i], mu, sigma);
	}
	return Log;
}

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
