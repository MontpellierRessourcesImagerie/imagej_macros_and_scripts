width = getWidth();
height = getHeight();

inputImageID = getImageID();
makeRectangle(0, 0, width/2, height/2);
run("Duplicate...", "duplicate");
selectImage(inputImageID);
makeRectangle(width/2+1, 0, width/2, height/2);
run("Duplicate...", "duplicate");
selectImage(inputImageID);
makeRectangle(0, height/2+1, width/2, height/2);
run("Duplicate...", "duplicate");
selectImage(inputImageID);
makeRectangle(width/2+1, height/2+1, width/2, height/2);
run("Duplicate...", "duplicate");
