var MIN_DIST = 25;

print("Count Satellites started !");

getVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
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
bWidth = Table.getColumn("B-width");
bHeight = Table.getColumn("B-height");
bDepth = Table.getColumn("B-depth");
distances = Table.getColumn("Mean dist. to surf. (micron)");
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
	toScaled(XS[i], YS[i], ZS[i]);
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

newImage("satellites", "16-bit black", width, height, slices);
satellitesImageID = getImageID();
satelliteImageTitle = getTitle();
setVoxelSize(voxelWidth, voxelHeight, voxelDepth, voxelUnit);
color=0;
for (i = 0; i < satelliteIDS.length; i++) {
	minIndexJ = -1;
	minDistance = 9999999;
	xi = X[satelliteIDS[i]];
	yi = Y[satelliteIDS[i]];
	zi = Z[satelliteIDS[i]];
	for (j = 0; j < neuronIDS.length; j++) {
		xj = X[neuronIDS[j]];
		yj = Y[neuronIDS[j]];
		zj = Z[neuronIDS[j]];
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
		vectors = getVectors(bWidth[satelliteIDS[i]], bHeight[satelliteIDS[i]], bDepth[satelliteIDS[i]], distances[satelliteIDS[i]]);
		params = "size="+width+","+height+","+slices+" center="+XS[satelliteIDS[i]]+","+YS[satelliteIDS[i]]+","+ZS[satelliteIDS[i]]+" radius="+vectors[0]+","+vectors[1]+","+vectors[2]+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+voxelUnit+" value="+color+" display=Overwrite";
		print(params);
		run("3D Draw Shape", params);
		vectors = getVectors(bWidth[neuronIDS[minIndexJ]], bHeight[neuronIDS[minIndexJ]], bDepth[neuronIDS[minIndexJ]], distances[neuronIDS[minIndexJ]]);
		run("3D Draw Shape", "size="+width+","+height+","+slices+" center="+XS[neuronIDS[minIndexJ]]+","+YS[neuronIDS[minIndexJ]]+","+ZS[neuronIDS[minIndexJ]]+" radius="+vectors[0]+","+vectors[1]+","+vectors[2]+" vector1=1.0,0.0,0.0 vector2=0.0,1.0,0.0 res_xy="+voxelWidth+" res_z="+voxelDepth+" unit="+voxelUnit+" value="+color+" display=Overwrite");
		color++;
	}
}
run("glasbey on dark");
selectImage(inputID);
run("Split Channels");
run("Merge Channels...", "c1=C1-"+inputTitle+" c2=C2-"+inputTitle+" c4="+satelliteImageTitle+" create");
close("\\Others");

print("Count Satellites finished !");

function getVectors(bWidth, bHeight, bDepth, distance) {
		relVecX = bWidth;
		relVecY = bHeight;
		relVecZ = bDepth;
		
		max = maxOf(relVecX, relVecY);
		max = maxOf(max, relVecZ);
		
		relVecX /= max;
		relVecY /= max;
		relVecZ /= max; 
		
		dist = distance;
		distX = dist * relVecX;
		distY = dist * relVecY;
		distZ = dist * relVecZ;
		res = newArray(distX, distY, distZ);
		return res;
}
