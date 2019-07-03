var _SSF = sqrt(2);
var _SIGMA_START = 0.8;
//var _SIGMA_START = 1.2;
// var _SIGMA_START = 4;
var _SIGMA_DELTA = 0.4;
var _SCALE_SPACE_PARTS_OF_WIDTH = 15;
var _MAXIMA_PROMINENCE = 200;
//var _MAXIMA_PROMINENCE = 100;

setBatchMode(true);
Overlay.remove;
run("Select None");
imageID = getImageID();
sigmas = createScaleSpace();
scaleSpaceID = getImageID();
findMaxima(sigmas, imageID, scaleSpaceID);
// filterMaxima(imageID, scaleSpaceID);
setBatchMode("exit and display");
print("Done!");

function createScaleSpace() {
	width = getWidth();
	height = getHeight();
	max = round(width/_SCALE_SPACE_PARTS_OF_WIDTH);
	title = getTitle();
	run("Duplicate...", " ");
	rename("tmp");
	run("Duplicate...", " ");
	run("Images to Stack", "name=Scale-Space title=[tmp] use");
	run("Size...", "width="+width+" height="+height+" depth="+max+" constrain average interpolation=Bilinear");
	sigmas = newArray(nSlices);
	stackID = getImageID();
	run("32-bit");
	for(i=1; i<=nSlices; i++) {
		setSlice(i);
		run("Duplicate...", " ");
		sliceID = getImageID();
		sigma = _SIGMA_START + (i-1) * _SIGMA_DELTA;
		sigmas[i-1] = sigma;
		run("FeatureJ Laplacian", "compute smoothing="+sigma);
		laplacianID = getImageID();
		run("Multiply...", "value="+(sigma*sigma));
		run("Select All");
		run("Copy");
		selectImage(stackID);
		run("Paste");
		selectImage(sliceID);
		close();
		selectImage(laplacianID);
		close();
	}
	run("Select None");
	return sigmas;
}

function findMaxima(sigmas, imageID, scaleSpaceID) {
	selectImage(scaleSpaceID);
	Stack.setSlice(1);
	run("Find Maxima...", "prominence="+_MAXIMA_PROMINENCE+" exclude light output=[Point Selection]");
	getSelectionCoordinates(xpoints, ypoints);
	run("Select None");
	
	for (i = 0; i < xpoints.length; i++) {
		
		oldMin = 99999999;
		currentMin = 1111111;
		
		while(oldMin!=currentMin) {
	
			selectImage(scaleSpaceID);
			x = xpoints[i];
			y = ypoints[i];
			setSlice(1);
			makePoint(x, y);
			run("Plot Z-axis Profile");
			Plot.getValues(pxpoints, pypoints);
			close();
			ranks = Array.rankPositions(pypoints);
			minIndex = ranks[0]+1;
			currentMin = pypoints[minIndex-1];
			
			sigma = sigmas[minIndex-1];
			radius = sigma*_SSF;

			setSlice(minIndex);
			makeRectangle(x-radius, y-radius, 2*radius+1, 2*radius+1);
			getSelectionCoordinates(rxpoints, rypoints);
			oldMin = currentMin;
			for(j=0; j<rxpoints.length; j++) {
				for(k=0; k<rypoints.length; k++) {
					v = getPixel(rxpoints[j], rypoints[k]);
					if (v<currentMin) {
						currentMin = v;
						xpoints[i] = rxpoints[j];
						ypoints[i] = rypoints[k];
						print("min adjusted: ", xpoints[i], ypoints[i]);
					}			
				}
			}
			
		}
		selectImage(imageID);
		if (round(radius)%2==1) makeOval((x+0.5)-radius, (y+0.5)-radius, (2*radius), (2*radius));
		else makeOval((x+0.5)-radius, (y+0.5)-radius, (2*radius), (2*radius));
		Overlay.addSelection;
		run("Select None");
	}
	Overlay.show;
}

function filterMaxima(imageID, scaleSpaceID) {
	selectImage(imageID);
	Overlay.copy;
	selectImage(scaleSpaceID);
	setSlice(1);
	Overlay.paste;
	nrOfBlobs = Overlay.size;
	toBeRemoved = newArray(0);
	for (i = 0; i < nrOfBlobs; i++) {
		Overlay.activateSelection(i);
		getStatistics(area, mean, min, max, std);
		if (mean>-20) {
			toBeRemoved = Array.concat(toBeRemoved, i);
		}
	}
	roiManager("reset");
	run("To ROI Manager");
	roiManager("select", toBeRemoved);
	roiManager("Delete");

	run("From ROI Manager");
	
	Overlay.copy;
	selectImage(imageID);
	Overlay.remove;
	Overlay.paste;
	roiManager("reset");
}
