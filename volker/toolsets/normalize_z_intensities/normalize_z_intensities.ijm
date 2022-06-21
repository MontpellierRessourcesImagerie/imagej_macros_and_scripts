a = 522.38927
b = 1690.71042
c = 4.93057
d = 7.72141


getDimensions(width, height, channels, slices, frames);

ZFactor = newArray(slices);

for (i = 0; i < slices; i++) {
	ZFactor[i] = gauss(i);	
}

ranks = Array.rankPositions(ZFactor);
max = ZFactor[ranks[ranks.length-1]];

for (i = 0; i < slices; i++) {
	ZFactor[i] = max / ZFactor[i];
}

for (i = 0; i < slices; i++) {
	Stack.setSlice(i+1);
	run("Multiply...", "value="+ZFactor[i]+" slice");
}

function gauss(z) {
	y = a+(b-a)*Math.exp(-(z-c)*(z-c)/(2*d*d));
	return y;
}
