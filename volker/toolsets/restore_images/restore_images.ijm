NR_OF_CHANNELS = 4;
NR_OF_FIELDS = 5;
run("Bio-Formats Macro Extensions");
dir = getDir("select a folder!");
//exportFieldsPerChannel(dir);
mergeChannels(dir);
//cleanUp(dir);

function cleanUp(dir) {
	files = getFileList(dir);
	images = filterImages(files);
	for (i = 0; i < images.length; i++) {
		image = images[i];
		if (startsWith(image, "f")) File.delete(dir + image);
	}
	
	for (c = 0; c < NR_OF_CHANNELS; c++) {
		files = getFileList(dir + "channel-" + c + "/");
		for (i = 0; i < files.length; i++) {
			file = files[i];
			File.delete(dir + "channel-" + c + "/" + file);
		}
	}
	
	for (c = 0; c < NR_OF_CHANNELS; c++) {
		File.delete(dir + "channel-" + c + "/");
	}
}

function mergeChannels(dir) {
	
	images = getFileList(dir + "channel-0");
	for (i = 0; i < images.length; i++) {
		image = images[i];
		titles = newArray(NR_OF_CHANNELS);
		for (c = 0; c < NR_OF_CHANNELS; c++) {
			open(dir + "channel-" + c + "/" +  image);
			run("Enhance Contrast", "saturated=0.35");
			resetMinAndMax();
			titles[c] = getTitle();
		}	
		run("Merge Channels...", "c1=" + titles[1] + " c2=" + titles[2] + " c3=" + titles[3] + " c4=" + titles[0] +" create");
		save(dir +titles[0]);
		close("*");
	}
}

function exportFieldsPerChannel(dir) {
	files = getFileList(dir);
	
	for (i = 0; i < files.length; i++) {
	    file = files[i];
	    c = IJ.pad(i, 4);
	    File.rename(dir + file, dir + "f"+c+"ch"+(i%NR_OF_CHANNELS) + ".tif");
	}
	
	for (i = 0; i < NR_OF_CHANNELS; i++) {
	    ch = i;
	    if (!File.exists(dir + "channel-" + ch)) {
	        File.makeDirectory(dir + "channel-" + ch);
	    }
	    File.openSequence(dir, " filter=ch"+ch);
	    splitFields(NR_OF_FIELDS, dir + "channel-" + ch);
	    close();
	}
}


function splitFields(nrOfFields, outFolder) {
    title = getTitle();
    zSlices = nSlices / nrOfFields;
    field = 1;
    inputImageID = getImageID();
    for(startSlice = 1; startSlice   < nSlices; startSlice = startSlice + zSlices) {
        fieldText = IJ.pad(field, 2);
        endSlice = startSlice + zSlices - 1;
        print(startSlice, endSlice);
        run("Duplicate...", "duplicate range=" + startSlice + "-" + endSlice);
        rename("f" + fieldText + "-" + title); 
        save(outFolder + "/" + fieldText + "-" + title);
        close();
        selectImage(inputImageID);
        field++;
    }
}

function filterImages(files) {
    images = newArray(0);
    for (i = 0; i < files.length; i++) {
        file = files[i];
        if (endsWith(file, ".tif")) {
            images = Array.concat(images, file); 
        }
    }
    return images;
}

    