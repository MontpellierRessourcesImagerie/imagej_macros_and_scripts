
open("/home/nnafati/Desktop/Data/images_tiff/spots.tif");
run("8-bit");
id_noise = getImageID();
selectImage(id_noise);
// print(id_noise);
Title_Image_Noise = getTitle();
// print("Title_Image_Noise "+Title_Image_Noise);
selectImage(id_noise);
run("Duplicate...", " ");

run("Subtract Background...", "rolling=100");
// run("Find Edges");
// run("Invert");
// waitForUser("ok ap Fide Edge");
// run("Close");
//run("Brightness/Contrast...");

run("Enhance Contrast", "saturated=0.35");
run("Apply LUT");
run("Gaussian Blur...", "sigma=8");

run("Convert to Mask");
// run("Dilate");
// run("Close");
// run("Close");

run("Erode"); run("Erode");
run("Erode"); run("Erode");

run("Invert");
id_mask = getImageID();
Title_mask= getTitle();
print("MaskImage "+ Title_mask);
print("Title_Image_Noise "+Title_Image_Noise);
// selectWindow("spots.tif");

imageCalculator("Add create",Title_Image_Noise,Title_mask);
run("Invert");


// selectWindow("Result of Result of spots-1 with small spot detection.tif");
