DIAMETERXY = 18;
RADIUSZ = 9;

removeLabelsInTheCenter();

function removeLabelsInTheCenter() {
	title = getTitle();
	inputImageID = getImageID();
	newTitle = title + "-cleaned";
	Stack.getDimensions(width, height, channels, slices, frames);
	for (frame = 1; frame <= frames; frame++) {
		selectImage(inputImageID);
		run("Duplicate...", "title=frame duplicate frames="+frame+"-"+frame);
		removeLabelsInTheCenterForFrame();
		if (frame==1) {
			rename("movie");
			continue;
		}
		run("Concatenate...", "open title=nmovie image1=movie image2=frame image3=[-- None --]");
		rename("movie");
	}
	rename(newTitle);
}

function removeLabelsInTheCenterForFrame() {
	firstSlice = 0;
	for (slice = 1; slice <= nSlices; slice++) {
		Stack.setSlice(slice);
		getStatistics(area, mean, min, max, std, histogram);
		if (min==0 && max==0) {
			firstSlice++;
		} else {
			firstSlice++;
			break;
		}
	}
	lastSlice = nSlices+1;
	for (slice = lastSlice; slice >= 1; slice--) {
		Stack.setSlice(slice);
		getStatistics(area, mean, min, max, std, histogram);
		if (min==0 && max==0) {
			lastSlice--;
		} else {
			lastSlice--;
			break;
		}
	}
	
	middleSlice = firstSlice + ((lastSlice - firstSlice) / 2);
	print(firstSlice, lastSlice, middleSlice);
	Stack.setSlice(middleSlice);
	setThreshold(1, 65535);
	run("Create Selection");
	xCentroid = getValue("X");
	yCentroid = getValue("Y");
	toUnscaled(xCentroid, yCentroid);
	run("Select None");
	
	labelsToBeRemoved = newArray(0);
	start = maxOf(1, middleSlice - RADIUSZ);
	end = minOf(middleSlice + RADIUSZ, nSlices);
	for (slice = start; slice <= end; slice++) {
		setSlice(slice);
		makeOval(xCentroid-(DIAMETERXY/2), yCentroid-(DIAMETERXY/2), DIAMETERXY, DIAMETERXY);
		removeLabelsInSelection();
		run("Select None");
	}
	resetThreshold();
}


function removeLabelsInSelection() {
	getRawStatistics(nPixels, mean, min, max, std, histogram);
	run("Select None");
	for (i = 1; i < histogram.length; i++) {
		if (histogram[i]==0) continue;
		run("Replace/Remove Label(s)", "label(s)="+i+" final=0");
	}
	run("Restore Selection");
}
