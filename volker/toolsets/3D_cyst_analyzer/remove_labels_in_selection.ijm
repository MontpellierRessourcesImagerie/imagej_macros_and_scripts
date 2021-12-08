
removeLabelsInSelection();

function removeLabelsInSelection() {
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	run("Select None");
	for (i = 1; i < histogram.length; i++) {
		if (histogram[i]==0) continue;
		run("Replace/Remove Label(s)", "label(s)="+i+" final=0");
	}
	run("Restore Selection");
}