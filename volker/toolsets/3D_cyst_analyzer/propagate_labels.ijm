labelsID = getImageID();
Overlay.remove;
getDimensions(width, height, channels, slices, frames);
for(i = 2; i <= 2; i++) {
	run("Duplicate...", "duplicate title=one frames="+i);
	run("Analyze Regions 3D", "centroid surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
	selectImage(labelsID);
	run("Duplicate...", "duplicate title=head frames=1-"+(i-1));
	selectImage(labelsID);
	run("Duplicate...", "duplicate title=tail frames="+(i+1)+"-"+frames);
	selectImage(labelsID);
	count = Table.size("one-morpho");
	for (index = 0; index < count; index++) {
		label = Table.get("Label", index);
		x = Table.get("Centroid.X", index);
		y = Table.get("Centroid.Y", index);
		z = Table.get("Centroid.Z", index);
		toUnscaled(x, y, z);	
		makePoint(x, y);
		Overlay.addSelection;
		Overlay.setPosition(0, z, i);
		Stack.setFrame(i);
		Stack.setPosition(1, z, i);
		newLabel = getPixel(x, y);
		
	}
}