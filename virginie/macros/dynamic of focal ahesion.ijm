/**
*macro to measure retraction and protrusion of focal adhesions
*it's necessary to create 1 folder for the processed images, 1 folder for the mask and 1 folder for the results*
*macro developped by MRI
*Virginie Georget
*/

dir1 = getDirectory("Choose Destination Directory for the processed images");
dir2 = getDirectory("Choose Destination Directory for the mask");
dir3 = getDirectory("Choose Destination Directory for the results");
run("Set Measurements...", "area limit display redirect=None decimal=3");

nameImage = getTitle();
run("Bandpass Filter...", "filter_large=50 filter_small=2 suppress=None tolerance=5 autoscale saturate process");
run("Subtract Background...", "rolling=10 stack");
saveAs(dir1+nameImage+".tif");
run("Threshold...");
waitForUser("Set mask","Threshold set?");  
run("Convert to Mask", "method=Default background=Light");
saveAs(dir2+nameImage+".tif");

n = nSlices-12;
//print(n);
//setBatchMode(true);
for (i=1; i<=n; i++) {
   		  showProgress(i, n);
   		  setSlice(i);
            run("Duplicate...", "title=t0");
		setThreshold(1, 255);
		run("Measure");
            selectWindow(nameImage);
		setSlice(i+12);
            run("Duplicate...", "title=t+12");

	imageCalculator("Subtract create", "t+12","t0");
	selectWindow("Result of t+12");
	rename("protrusion");
		run("Red");
		setThreshold(1, 255);
		run("Measure");

	imageCalculator("Subtract create", "t0","t+12");
	selectWindow("Result of t0");
	rename("retraction");
		run("Blue");
		setThreshold(1, 255);
		run("Measure");

	imageCalculator("Subtract create", "t0","protrusion");
	selectWindow("Result of t0");
	rename("substract1");
	imageCalculator("Subtract create", "substract1","retraction");
	selectWindow("Result of substract1");
	rename("conservation");
	run("Green");


	run("Merge Channels...", "c1=protrusion c2=conservation c3=retraction create keep");
	saveAs(dir3+nameImage+"-"+i+".tif");
	nameResults = getTitle();
	close("t0");
	close("t+12");
	close("protrusion");
	close("retraction");
	close("conservation");
	close("substract1");
	close(nameResults);
	selectWindow(nameImage);
	setSlice(i);



  }
 close(nameImage);


