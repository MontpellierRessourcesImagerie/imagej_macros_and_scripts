
input=(getDirectory("image"));
print("input"+input);
id=File.nameWithoutExtension;
print("id"+id);
roiManager("open", input + id + ".zip");



// dir= getDirectory("Select the input folder!"); 

dir = getDir("Select the input folder!");
liste = getFileList(dir);
Array.print(liste);

// roiManager("Open", " ");
roiManager("Open", +dir+"*.zip");
print(dir);

// loop through the ROI Manager
n = roiManager('count');
print(n);


for (i = 0; i < n; i++) {
    roiManager('select', i);

    // process roi here
	roi_name = Roi.getName();
    filename = roi_name + ".tif";
    open(filename);
    // run("Subtract Background...", "rolling=100 light");
    // etc etc.
     
}


for (i=0; i<liste.length; i++){
	if (endsWith(liste[i],".zip")) {
		run("From ROI Manager", "");
		print(liste[i]);
		run("Close");
	}
}