Plot.getValues(xpoints, profile);

delta=xpoints[1] - xpoints[0];

first = firstDerivative(delta, profile);
second = firstDerivative(delta, first);

crossings = zeroCrossings(xpoints, second);

yZeros = newArray(crossings.length);


results = valuesBetween(crossings, 11, 17);

Plot.add("connected circle", xpoints, second);
Plot.add("diamond", results, yZeros);
Plot.setStyle(2, "red,red,2.0,+");

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
