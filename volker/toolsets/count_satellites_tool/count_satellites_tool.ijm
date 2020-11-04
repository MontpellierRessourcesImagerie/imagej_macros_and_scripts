var MIN_DIST = 10;
inputID = getImageID();
inputTitle = getTitle();
Stack.getDimensions(width, height, channels, slices, frames);
run("Duplicate...", "duplicate");
blurredID = getImageID();
blurredTitle = getTitle();
run("Gaussian Blur...", "sigma=25 stack");
imageCalculator("Subtract create stack", inputTitle, blurredTitle);
cleanID = getImageID();
cleanTitle = getTitle();
selectImage(blurredID);
close();
run("Gaussian Blur 3D...", "x=3 y=3 z=3");
run("Split Channels");
run("Convert to Mask", "method=Triangle background=Dark calculate");
run("Watershed", "stack");
run("Distance Transform Watershed 3D", "distances=[Quasi-Euclidean (1,1.41,1.73)] output=[16 bits] normalize dynamic=2 connectivity=6");
run("glasbey on dark");
run("Macro...", "code=v=(v>0)*65535 stack");
run("8-bit");
run("Erode (3D)", "iso=255");
run("Erode (3D)", "iso=255");
run("3D Objects Counter", "threshold=1 slice=25 min.=10 max.=32320800 exclude_objects_on_edges objects centroids statistics summary");
X = Table.getColumn("X");
Y = Table.getColumn("Y");
Z = Table.getColumn("Z");
MeanDist = Table.getColumn("Mean dist. to surf. (micron)");
XS = newArray(X.length);
YS = newArray(X.length);
ZS = newArray(X.length);
I = Array.getSequence(X.length);
for (i = 0; i < X.length; i++) {
	I[i] = I[i] + 1;
}
Table.setColumn("id", I);
selectImage(inputID);
for (i = 0; i < X.length; i++) {
	XS[i] = X[i];
	YS[i] = Y[i];
	ZS[i] = Z[i];
	toUnscaled(XS[i], YS[i], ZS[i]);
}
selectImage("C1-"+cleanTitle);
run("Convert to Mask", "method=Triangle background=Dark calculate");
neuronIDS = newArray(0);
satelliteIDS = newArray(0);
for (i = 0; i < X.length; i++) {
	setSlice(round(Z[i]));
	val = getPixel(round(X[i]), round(Y[i]));
	if (val>0) {
		neuronIDS = Array.concat(neuronIDS, i);
	} else {
		satelliteIDS = Array.concat(satelliteIDS, i);
	}
}

selectImage(inputID);
Overlay.remove
for (i = 0; i < neuronIDS.length; i++) {
	x = X[neuronIDS[i]];
	y = Y[neuronIDS[i]];
	z = Z[neuronIDS[i]];
	makePoint(round(x), round(y), "large cyan circle");
	Overlay.addSelection;
	Overlay.setPosition(0, round(z), 0)
}
for (i = 0; i < satelliteIDS.length; i++) {
	x = X[satelliteIDS[i]];
	y = Y[satelliteIDS[i]];
	z = Z[satelliteIDS[i]];
	makePoint(round(x), round(y), "large magenta hybrid");
	Overlay.addSelection;
	Overlay.setPosition(0, round(z), 0)
}

newImage("satellites", "8-bit", width, height, slices);
for (i = 0; i < satelliteIDS.length; i++) {
	minIndexJ = -1;
	minDistance = 9999999;
	xi = XS[satelliteIDS[i]];
	yi = YS[satelliteIDS[i]];
	zi = ZS[satelliteIDS[i]];
	for (j = 0; j < neuronIDS.length; j++) {
		xj = XS[neuronIDS[j]];
		yj = YS[neuronIDS[j]];
		zj = ZS[neuronIDS[j]];
		dX = xi - xj;
		dY = yi - yj;
		dZ = zi - zj;
		dist = sqrt(dX*dX+dY*dY+dZ*dZ);
		if (dist<minDistance) {
			minDistance = dist;
			minIndexJ = j;
		}
	}
	if (minDistance<=MIN_DIST) {
		
		run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+XS[satelliteIDS[i]]+","+YS[satelliteIDS[i]]+","+ZS[satelliteIDS[i]]+" radius=27.676,27.676,4.039 vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=0.277 res_z=0.673 unit=microns value=255 display=Overwrite");
		run("3D Draw Shape", "size=10,10,5 center=111.256,111.256,16.828 radius=27.676,27.676,4.039 vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy=0.277 res_z=0.673 unit=microns value=255 display=Overwrite");
	}
}


