var _COLOR_CLUSTER_ONE = "cyan";
var _COLOR_CLUSTER_TWO = "magenta"
var _HIST_BINS = 10;
var _DIST_LINE_WIDTH = 3;
var _COLOR_HISTOGRAM = "blue";

function gauss(x, mu, sigma) {
	res = (1/(sigma*sqrt(2*PI)))*exp(-0.5*pow(((x-mu)/sigma),2));
	return res;
}

function plotHistogramAndGaussians() {
	selectWindow("Results");
	areas = Table.getColumn("Area");
	maxArea = 0;
	for (i = 0; i < areas.length; i++) {
		value = areas[i];
		if (value>maxArea) maxArea = value;
	}
	
	selectWindow("clusters");
	mu1 = Table.get("mean", 0);
	sigma1 = Table.get("stddev", 0);
	mu2 = Table.get("mean", 1);
	sigma2 = Table.get("stddev", 1);
	
	xValues = Array.getSequence(maxArea+1);
	yValues1 = newArray(maxArea+1);
	yValues2 = newArray(maxArea+1);
	
	scalingFactor = maxArea * _HIST_BINS;
	
	for (i = 0; i <xValues.length; i++) {
		yValues1[i] = gauss(i, mu1, sigma1) * scalingFactor;
		yValues2[i] = gauss(i, mu2, sigma2) * scalingFactor;
	}
	
	Plot.create("Area Histogram / Area Distributions", "Area", "count");
	Plot.setColor("blue");
	Plot.addHistogram(areas, _HIST_BINS);
	Plot.setStyle(0, _COLOR_HISTOGRAM+",none,1.0,Separated Bars");
	Plot.add("line", xValues, yValues1);
	Plot.setStyle(1, _COLOR_CLUSTER_ONE+",none,"+_DIST_LINE_WIDTH+",Line");
	Plot.add("line", xValues, yValues2);
	Plot.setStyle(2, _COLOR_CLUSTER_TWO+",none,"+_DIST_LINE_WIDTH+",Line");
	Plot.show();
}



