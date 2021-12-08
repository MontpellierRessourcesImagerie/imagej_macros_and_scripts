labelsID = getImageID();
title = getTitle();
Overlay.remove;
getDimensions(width, height, channels, slices, frames);
run("Conversions...", " ");
for(frame = 2; frame < frames; frame++) {
	print("current frame = " + frame);
	run("Duplicate...", "duplicate title=one frames="+frame);
	run("Analyze Regions 3D", "centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
	run("32-bit");
	selectImage(labelsID);
	run("Duplicate...", "duplicate title=head frames=1-"+(frame-1));
	selectImage(labelsID);
	run("Duplicate...", "duplicate title=tail frames="+(frame+1)+"-"+frames);
	count = Table.size("one-morpho");
	newLabels = newArray(0);
	for (index = 0; index < count; index++) {
		selectImage(labelsID);
		label = Table.getString("Label", index, "one-morpho");
		x = Table.get("Centroid.X", index);
		y = Table.get("Centroid.Y", index);
		z = Table.get("Centroid.Z", index);
		toUnscaled(x, y, z);	
		Stack.setPosition(1, z, frame-1);
		newLabel = getPixel(x, y);
		if (newLabel==0) continue;
		if (label==newLabel) continue;
		newLabels = Array.concat(newLabels, newLabel);
		selectImage("one");
		run("Replace/Remove Label(s)", "label(s)="+label+" final=-"+newLabel);
	}
	selectImage("one");
	for (l = 0; l < newLabels.length; l++) {
		label = newLabels[l];
		run("Replace/Remove Label(s)", "label(s)=-"+label+" final="+label);
	}
	selectImage("one");
	run("16-bit");
	selectImage(labelsID);
	close();
	run("Concatenate...", "  title="+title+" open image1=head image2=one image3=tail");
	labelsID = getImageID();
}

