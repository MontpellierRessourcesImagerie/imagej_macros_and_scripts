var _SHOW_ZERO_CROSSINGS = true;
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Plot_Tool";

exit();

macro "MRI Plot Tools Help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "MRI Plot Tools Help (f4) Action Tool - C000D1eD2eD3dD3eD4cD4dD4eD58D5dD5eD66D6eD7eD81D83D8eD91D97D98D99D9aD9bD9cD9dD9eDaeDbeDceDdeDeeC222D93Da2DdcC000D5aD5bC999D3cD7dC555D55D67D73D96C222D68D76D77DddCcccD56D71D82D8cC444D57D59C111D46D84CbbbD4bD86D95DadDbdC888D0dD85D94Da3DfeCeeeD2dD69D92C333D0eD5cD65D8dC111D47D72CaaaD6dD74"{
	run('URL...', 'url='+helpURL);
}

macro "first derivative (f5) Action Tool - C000T4b12f" {
	Plot.getValues(xpoints, profile);	
	title = getTitle();
	
	delta=xpoints[1] - xpoints[0];
	first = firstDerivative(delta, profile);

	crossings = zeroCrossings(xpoints, first);
	yZeros = newArray(crossings.length);

	results = valuesBetween(crossings, xpoints[0], xpoints[xpoints.length-1]);

	Plot.create(title + "'", "x", "Y-axis Label");
	Plot.add("connected circle", xpoints, first);
	if (_SHOW_ZERO_CROSSINGS) {
		Plot.add("diamond", results, yZeros);
		Plot.setStyle(1, "red,red,2.0,+");
	}
	Plot.setLimitsToFit();
}

macro "first derivative (f5) Action Tool Options" {
	Dialog.create("first derivative options");
	Dialog.addCheckbox("show zero crossings", _SHOW_ZERO_CROSSINGS);
	Dialog.show();
	_SHOW_ZERO_CROSSINGS = Dialog.getCheckbox();
}

function firstDerivative(delta, discreteCurve) {
	length = discreteCurve.length;
	derivative = newArray(length);
	if (discreteCurve.length<2) return derivative;
	derivative[0] = (discreteCurve[1]-discreteCurve[0]) / delta;
	derivative[length-1] = (discreteCurve[length-1]-discreteCurve[length-2]) / delta;
	for (i = 1; i < discreteCurve.length-1; i++) {
		derivative[i] = (discreteCurve[i+1]-discreteCurve[i-1]) / (2*delta);
	}
	return derivative;
}

function zeroCrossings(xpoints, discreteCurve) {
	crossings = newArray(0);
	deltaX = xpoints[1] - xpoints[0];
	for (i = 0; i < discreteCurve.length-1; i++) {
		if (discreteCurve[i] == 0) {
			crossings = Array.concat(crossings, xpoints[i]);
			continue;
		}
		if (discreteCurve[i]*discreteCurve[i+1]<0) {
			m = (discreteCurve[i+1] - discreteCurve[i]) / deltaX;
			b = discreteCurve[i] - (m * xpoints[i]);
			xIntercept = -b/m;
			crossings = Array.concat(crossings, xIntercept);
		}
	}
	return crossings;
}

function valuesBetween(values, min, max) {
	valuesInInterval = newArray(0);
	if (min>max) {
		tmp = min;
		min = max;
		max = min;
	}
	for (i = 0; i < values.length; i++) {
		if (values[i]>min && values[i]<max) {
			valuesInInterval = Array.concat(valuesInInterval, values[i]);
		}
	}
	return valuesInInterval;
}
