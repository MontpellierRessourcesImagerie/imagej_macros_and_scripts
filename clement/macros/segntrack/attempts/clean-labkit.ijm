
var table = 0;

setBatchMode(true);

// Ce script s'utilise sur le retour de LabKit et qu'on ait retire l'outline.

function f(){
	path = "/home/benedetti/Bureau/frames/";
	
	selectWindow("segmented");
	originalImage = getImageID();	
	Stack.getDimensions(width, height, channels, slices, frames);
	
	newImage("final", "8-bit black", width, height, channels);
	buffer = getImageID();
	
	selectImage(originalImage);
	run("Stack Splitter", "number=" + channels);
	
	for (i = 1 ; i <= channels ; i++) {
		selectWindow("" + i);
		run("Connected Components Labeling", "connectivity=4 type=[16 bits]");
		run("Label Size Filtering", "operation=Lower_Than size=20000");
		run("Label Size Filtering", "operation=Greater_Than size=1500");
		run("Fill Holes (Binary/Gray)");
		Image.copy();
		close();
		close();
		close();
		close();
		selectImage(buffer);
		setSlice(i);
		Image.paste(0, 0);
	}
	setBatchMode(false);
}

f();