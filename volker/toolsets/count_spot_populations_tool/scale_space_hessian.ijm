width = getWidth();
height = getHeight();
max = 15;
title = getTitle();
run("Duplicate...", " ");
rename("tmp");
run("Duplicate...", " ");
run("Images to Stack", "name=Scale-Space title=[tmp] use");
run("Size...", "width="+width+" height="+height+" depth="+max+" constrain average interpolation=Bilinear");
run("32-bit");
stackID = getImageID();
for(i=1; i<=nSlices; i++) {
	setSlice(i);
	run("Duplicate...", " ");
	sliceID = getImageID();
	run("FeatureJ Hessian", "largest middle smoothing="+i);
//	run("FeatureJ Laplacian", "compute smoothing="+i);
	featureID =getImageID();
	run("Copy");
	close();
	close();
	run("Paste");
	run("Multiply...", "value="+i+" slice");
}


