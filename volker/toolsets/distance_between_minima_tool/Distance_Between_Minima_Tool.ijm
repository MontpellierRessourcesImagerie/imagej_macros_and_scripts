var _TOLERANCE = 10;
var _REMOVE_ON_EDGES = true;
var _SHOW_PLOT = true;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Distance_Between_Minima_Tool";

macro "Distance Between Minima Action Tool (f1) - C644D2aD3aD83DcbDccDdbCfffD06D07D08D09D0aD0bD0cD0dD0eD0fD20D21D22D2cD2dD2eD2fD30D31D32D33D36D37D38D3dD3eD3fD40D41D42D43D4cD4dD4eD4fD50D51D52D53D59D5aD5bD5cD5dD5eD5fD60D61D62D63D68D69D6aD6bD6cD6dD6eD6fD70D71D77D78D79D7aD7bD7cD7dD7eD7fD80D81D86D87D88D89D8aD8bD8cD8dD8eD8fD90D91D97D98D99D9aD9bD9cD9dD9eD9fDa0Da1Da2Da3DabDaeDafDb0Db1Db2Db3DbfDc0Dc1Dc2Dc3Dc6Dc7Dc8Dc9DcfDd0Dd1Dd2DdeDdfDedDeeDefDf3Df6Df7Df8Df9DfaDfbDfcDfdDfeDffCcccD00D19D25D26D46D73D95Db8Dd6Dd7De9DeaDf0C888D10D11D47D56D93Da5DdaDe0De1CfddDacDadDbeC855D29DbcDdcCeeeD01D02D23D58D65D72D96Dd3Df1Df2CbbbD27D67D84Da9Dd8De7De8CfffD03D04D05D1bD1cD1dD1eD1fD34D35D44D45D54D55D64Db4Db5Db6Dc4Dc5DcaDecDf4Df5C888D12D48D49D57D66D94Da7DbaDe2De3De4De5CdddD1aD24D85D92DaaDb7Dd4Dd5DebCaaaD16D17D28D74D76Da8Db9Dd9De6CfddD3cDceDddCd44D3bD4aDbdDcdCdaaD18D2bD39D4bDa4C777D13D14D15D75D82Da6Dbb" {
	distanceBetweenMinima();	
}

macro "Distance Between Minima Action Tool (f1) Options" {
	Dialog.create("Options - Distance Between Minima");
	Dialog.addNumber("tolerance: ", _TOLERANCE);
	Dialog.addCheckbox("remove edge minima", _REMOVE_ON_EDGES);
	Dialog.addCheckbox("show plot", _SHOW_PLOT);
	Dialog.addHelp(helpURL);
	Dialog.show();
	_TOLERANCE = Dialog.getNumber();
	_REMOVE_ON_EDGES = Dialog.getCheckbox();
	_SHOW_PLOT = Dialog.getCheckbox();
}

macro 'distance between minima [f1]' {
	distanceBetweenMinima();	
}

function distanceBetweenMinima() {
	title = getTitle();
	run("Plot Profile");
	Plot.getValues(xpoints, profile);
	maxPositions = Array.findMinima(profile, _TOLERANCE);
	maxXValues = newArray(maxPositions.length);
	maxYValues = newArray(maxPositions.length);
	for (i = 0; i < maxXValues.length; i++) {
		maxXValues[i] = xpoints[maxPositions[i]];
		maxYValues[i] = profile[maxPositions[i]];
	}
	X = newArray(maxPositions.length);
	Y = newArray(maxPositions.length);
	ranks = Array.rankPositions(maxXValues);
	for (i = 0; i < ranks.length; i++) {
		X[i] = maxXValues[ranks[i]];
		Y[i] = maxYValues[ranks[i]];
	}
	if (_REMOVE_ON_EDGES) {
		if(X[0]==xpoints[0]) {
			X = Array.deleteIndex(X, 0);
			Y = Array.deleteIndex(Y, 0);
		}
		if(X[X.length-1]==xpoints[xpoints.length-1]) {
			X = Array.deleteIndex(X, X.length-1);
			Y = Array.deleteIndex(Y, Y.length-1);
		}
	}
	Plot.add("cross", X, Y);
	Plot.setStyle(1, "red,red,2.0,+");
	
	if (!_SHOW_PLOT) 
		close();
	
	distances = newArray(X.length-1);
	for (i = 0; i < distances.length; i++) {
		distances[i] = X[i+1] - X[i];
	}
	Array.getStatistics(distances, min, max, mean, stdDev);
	if (!isOpen("distance between minima")) {
		Table.create("distance between minima");
	}
	else {
		selectWindow("distance between minima");
	}
	row = Table.size;
	Table.set("image", row, title, "distance between minima");
	Table.set("mean", row, mean, "distance between minima");
	Table.set("stdDev", row, stdDev, "distance between minima");
	Table.set("min", row, min, "distance between minima");
	Table.set("max", row, max, "distance between minima");
}
