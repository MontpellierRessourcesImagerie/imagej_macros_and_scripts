width = getWidth();
height = getHeight();
max = round(width/30);
title = getTitle();
run("Duplicate...", " ");
rename("tmp");
run("Duplicate...", " ");
run("Images to Stack", "name=Scale-Space title=[tmp] use");
run("Size...", "width="+width+" height="+height+" depth="+max+" constrain average interpolation=Bilinear");
for(i=2; i<=nSlices; i++) {
	setSlice(i);
	sigma = (i-1)/2.5;
	run("Gaussian Blur...", "sigma="+sigma+" slice");
}


