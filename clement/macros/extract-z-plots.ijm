
auxin_index = 1;

image = getImageID();
Stack.getDimensions(width, height, channels, slices, frames);
Stack.getPosition(channel, slice, frame);

for (i = 1 ; i <= frames ; i++) {
	selectImage(image);
	Stack.setFrame(i);
	run("Plot Z-axis Profile", "profile=z-axis");
	
	Plot.getValues(x, y);
	Table.setColumn("µm", x);
	Table.setColumn("Mean", y);
	
	saveAs("Results", "/home/benedetti/Bureau/CSVs/auxin-1-frame-" + IJ.pad(i, 4) + ".csv");
	run("Clear Results");
	close();
}

Stack.setFrame(frame);
