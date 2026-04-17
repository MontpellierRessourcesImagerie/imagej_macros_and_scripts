var min_size = 100000;
waitForUser("Min size", "All elements smaller than " + min_size + " voxels will be removed.\n  [OK] Run\n  [Alt+OK] Provide a new value");
if (isKeyDown("alt")) {
	min_size = getNumber("Minimal size (voxels)", min_size);
}
original = getImageID();
run("Label Size Filtering", "operation=Greater_Than size="+min_size);
selectImage(original);
close();
roiManager("reset");
run("Remap Labels");