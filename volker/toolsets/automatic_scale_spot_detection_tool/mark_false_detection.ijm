count = Overlay.size;
for (i = 0; i < count; i++) {
	setSlice(1);
	Overlay.activateSelection(i);
	getStatistics(area, mean1, min);
	setSlice(2);
	getStatistics(area, mean2, min);
	if ((mean1+mean2)==0) Roi.setStrokeColor("red");
	else Roi.setStrokeColor("green");
}
setSlice(1);




