title = getTitle();
run("Invert");
run("Duplicate...", " ");
run("Gaussian Blur...", "sigma=32");
blurredTitle = getTitle();
imageCalculator("Subtract create", title, blurredTitle);
selectImage(title)
run("Gaussian Blur...", "sigma=7");
run("Find Maxima...", "prominence=10 exclude output=[Point Selection]");
run("Create Mask");
rename("seeds");
selectImage(title);
run("Select None");
run("Find Edges");
run("Marker-controlled Watershed", "input=["+title+"] marker=seeds mask=None compactness=0 binary calculate use");
run("Label Size Filtering", "operation=Lower_Than size=10000");
run("glasbey on dark");
run("Analyze Regions", "area perimeter circularity euler_number bounding_box centroid equivalent_ellipse ellipse_elong. convexity max._feret_diameter oriented_box oriented_box_elong. geodesic_diameter tortuosity max._inscribed_disc geodesic_elong. average_thickness");
