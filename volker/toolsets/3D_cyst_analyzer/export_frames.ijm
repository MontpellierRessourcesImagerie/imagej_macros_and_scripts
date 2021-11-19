path = getDir("Select the output-folder!");
Stack.getDimensions(width, height, channels, slices, frames);
title = getTitle();
name = File.getNameWithoutExtension(title);
for (i = 1; i <= frames; i++) {
	run("Duplicate...", "duplicate frames="+i+"-"+i);
	save(path+name+IJ.pad(i, 3)+".tif");
	close();
}
