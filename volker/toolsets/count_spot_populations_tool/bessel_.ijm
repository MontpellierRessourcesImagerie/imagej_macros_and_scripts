type = "line";

delta = 0.01;
epsilon = 1e-307;
xValues = getRange(0,4,delta);
mBessel0 = newArray(xValues.length);
mBessel1 = newArray(xValues.length);
mBessel2 = newArray(xValues.length);
mBessel3 = newArray(xValues.length);
mBessel4 = newArray(xValues.length);
mBessel5 = newArray(xValues.length);
for (i = 0; i < mBessel0.length; i++) {
	mBessel0[i] = I0(xValues[i],epsilon);
	mBessel1[i] = I1(xValues[i],epsilon);
	mBessel2[i] = I(2,xValues[i],epsilon);
	mBessel3[i] = I(3,xValues[i],epsilon);
	mBessel4[i] = I(4,xValues[i],epsilon);
	mBessel5[i] = I(5,xValues[i],epsilon);
}
title = "modified bessel";

createPlot(title, "acmes", "mBessel0");
addToPlot(title, type, "cyan", xValues, mBessel0, 2);
addToPlot(title, type, "magenta", xValues, mBessel1, 2);
addToPlot(title, type, "red", xValues, mBessel2, 2);
addToPlot(title, type, "blue", xValues, mBessel3, 2);
addToPlot(title, type, "yellow", xValues, mBessel4, 2);
addToPlot(title, type, "green", xValues, mBessel5, 2);

t0=0.5;
t1=t0*1.5;
t2=t1*1.5;
t3=t2*1.5;
delta = 1;
nValues = getRange(-10,10,delta);
T05 = newArray(nValues.length);
T075 = newArray(nValues.length);
T1125 = newArray(nValues.length);
T16875 = newArray(nValues.length);

for (i = 0; i < nValues.length; i++) {
	T05[i] = T(nValues[i], t0, epsilon);
	T075[i] = T(nValues[i], t1, epsilon);
	T1125[i] = T(nValues[i], t2, epsilon);
	T16875[i] = T(nValues[i], t3, epsilon);
}

title = "kernel";
createPlot(title, "acmes", "T");
addToPlot(title, type, "cyan", nValues, T05, 2);
addToPlot(title, type, "magenta", nValues, T075, 2);
addToPlot(title, type, "red", nValues, T1125, 2);
addToPlot(title, type, "blue", nValues, T16875, 2);

function factorial(n) {
	res = 1;
	while(n>=1) {
		res = res * n--;	
	}
	return res;
}

function I0(x, epsilon) {
	sum = 0;
	j=1;
	do {
		jFac = factorial(j);
		term = pow(0.25 * (x*x),j) / (jFac*jFac);
		sum += term;
		j++;
	} while(abs(term) > epsilon);
	res = 1 + sum;
	return res;
}

function I1(x, epsilon) {
	sum = 0;
	j=0;
	do {
		jFac = factorial(j);
		jFacPlusOne = (j+1)*jFac;
		term = pow(0.25 * (x*x),j) / (jFac*jFacPlusOne);
		sum += term;
		j++;
	} while(abs(term) > epsilon);
	res = 0.5 * x * sum;
	return res;	
}

function I_rec(n, x, epsilon) {
	if (n<0) n=-n;
	if (n==0) return I0(x, epsilon);
	if (n==1) return I1(x, epsilon);
	result = I(n-2, x, epsilon)-(((((2*n)-2))/x)*I(n-1, x, epsilon));
	return result;
}

function I(n, x, epsilon) {
	if (n<0) n=-n;
	if (n==0) return I0(x, epsilon);
	if (n==1) return I1(x, epsilon);
	InMinus2 = I0(x, epsilon);
	InMinus1 = I1(x, epsilon);
	InNow = 0;
	for (i = 2; i <= n; i++) {
		InNow = InMinus2-(((2*i-2)/x)*InMinus1);
		InMinus2 = InMinus1;
		InMinus1 = InNow;
	}
	return InNow;
}

function IN(n, x, epsilon) {
	sum = 0;
	j=0;
	do {
		jFac = factorial(j);
		jFacPlusOne = factorial(j+n);
		term = pow(0.25 * (x*x),j) / (jFac*jFacPlusOne);
		sum += term;
		j++;
	} while(term > epsilon);
	res = pow(0.5 * x,n) * sum;
	return res;	
}

function T(n, t, epsilon) {
	return exp(-t)*I(n,t,epsilon);	
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
	Plot.setLimits(0, xValues[xValues.length-1], 0, xValues[xValues.length-1]);
}

function getRange(start, end, step) {
	N = (floor((end-start) / step))+1;
	range = newArray();
	for (i = start; i <= end; i=i+step) {
		range = Array.concat(range,i);
	}
	return range;
}