var _MIN_VOXELS = 870;

getRawStatistics(nPixels, mean, min, max, std, histogram);
toBeDeleted = newArray(0);
for (i = 1; i < histogram.length; i++) {
	if (histogram[i] >= _MIN_VOXELS) {
		toBeDeleted = Array.concat(toBeDeleted, i);
	}
}
toBeDeletedText = String.join(toBeDeleted);
run("Replace/Remove Label(s)", "label(s)="+toBeDeletedText+" final=0");
