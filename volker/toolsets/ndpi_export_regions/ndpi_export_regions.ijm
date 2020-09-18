_SLIDE_IMAGE_SERIES = "series_6";

macro "ndpi export regions Action Tool (f2) - CfffL00f0L0111CfdfD21CdbfD31Cd9fD41Cc8fL5171Cd9fD81CdafD91CedfDa1CfffLb1f1CedfD02Cd9fD12Cc8fD22Cc9fD32Cd9fL4252Cc8fL62b2CecfDc2CfffLd2f2CdbfD03CfdfD13CfffL2363CfdfD73Cc8fL83c3Cd9fDd3CfefDe3CfffDf3L0464CdbfD74Cc8fD84CedfL94a4Cc9fDb4Cc8fLc4d4Cd9fDe4CfffDf4L0555CfefD65Cc8fD75Cd9fD85CfffL95a5CfefDb5Cd9fDc5Cc8fLd5e5CecfDf5CfffL0656CdafD66Cc8fD76CfdfD86CfffL96b6CfefDc6Cc9fDd6Cc8fDe6Cd9fDf6CfffL0747CfdfD57Cc8fD67CdafD77CfffL87c7CecfDd7Cc8fLe7f7CfffL0848Cd9fD58Cc8fD68CedfD78CfffL88c8CfdfDd8Cc8fDe8Cc9fDf8CfffL0939CfdfD49Cc8fD59Cc9fD69CfffL79c9CfdfDd9Cc8fDe9CdbfDf9CfffL0a3aCdafD4aCc8fD5aCdbfD6aCfffL7acaCdbfDdaCc8fDeaCfefDfaCfffL0b2bCfefD3bCc8fL4b5bCedfD6bCfffL7bbbCfefDcbCc8fDdbCedfDebCfffDfbL0c2cCecfD3cCc8fL4c5cCfdfD6cCfffL7cacCfdfDbcCc9fDccCedfDdcCfffLecfcL0d2dCdafD3dCc8fL4d5dCecfD6dCfffL7d8dCfdfD9dCdbfDadCdafDbdCfefDcdCfffLddfdL0e2eCd9fD3eCc8fL4e8eCc9fD9eCecfDaeCfffLbefeL0f2fCfefD3fCc8fD4fCc9fD5fCdafD6fCecfD7fCfdfD8fCfffL9fff" {
	ndpiExportRegions();
}

macro "ndpi export regions [f2]" {
	ndpiExportRegions();
}

function ndpiExportRegions() {
	dir = getDirectory("Please select the input folder!");
	files = getFileList(dir);
	files = filterNDPAFiles(files);
	print(files.length + " annotation files found...");
	for (i = 0; i < files.length; i++) {
		file = files[i];
		image = replace(file, ".ndpa", "");
		xMaxResWidthInPixel = readMaxResWidth(dir + '/' + image);
		roiManager("reset");
		run("Bio-Formats", "open=["+dir+'/'+image+"] color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT "+_SLIDE_IMAGE_SERIES);
		setThreshold(1, 255);
		run("Create Selection");
		Roi.getBounds(imageOriginX, imageOriginY, imageWidthInPixel, imageHeightInPixel);
		run("Select None");
		CENTER_OF_SLICE_X = getWidth();
		CENTER_OF_SLICE_Y = getHeight();
		toScaled(CENTER_OF_SLICE_X, CENTER_OF_SLICE_Y);
		CENTER_OF_SLICE_X /= 2;
		CENTER_OF_SLICE_Y /= 2;
		annotations = File.openAsString(dir + "/" + file);
		lines = split(annotations, "\n");
		l = 0;
		inAnnotation = false;
		xPoints = newArray(0);
		yPoints = newArray(0);

		print("Processing image: "+ dir + "/" + image);
		while (l<lines.length) {
			line = String.trim(lines[l]);
			if (startsWith(line, '<annotation type="freehand" displayname="AnnotateRectangle"')) {
				inAnnotation = true;		
				xPoints = newArray(0);
				yPoints = newArray(0);
			}
			if (startsWith(line, '</annotation>')) {
				inAnnotation = false;		
				factor = xMaxResWidthInPixel / imageWidthInPixel;
				cropZone(dir, image, factor, imageOriginX, imageOriginY, xPoints, yPoints, imageWidthInPixel, imageHeightInPixel);
			}
			if (inAnnotation && startsWith(line, '<point>')) {
				x =  String.trim(lines[l+1]);
				x = replace(x, '<x>', '');
				x = replace(x, '</x>', '');
				y =  String.trim(lines[l+2]);
				y = replace(y, '<y>', '');
				y = replace(y, '</y>', '');
				x = parseInt(x);
				y = parseInt(y);
				x = (x / 1000.0) + CENTER_OF_SLICE_X;
				y = (y / 1000.0) + CENTER_OF_SLICE_Y;
				toUnscaled(x,y);
				xPoints = Array.concat(xPoints, x);
				yPoints = Array.concat(yPoints, y);
			}
			l++;
		}
		close();
	}
}

function readMaxResWidth(image) {
	run("Bio-Formats", "open=["+image+"] color_mode=Composite display_metadata rois_import=[ROI manager] view=[Metadata only] stack_order=Default");
	content = getInfo("window.contents");
	lines = split(content, "\n");
	res = 0;
	for (i = 0; i < lines.length; i++) {
		line = String.trim(lines[i]);
		if (startsWith(line, 'Series 1 SizeX')) {
			parts = split(line, "\t");
			res = parseInt(parts[1]);
			run("Close");
			return res;
		}
	}
	close("Original Metadata*");
	return res;print("imageOriginX=", imageOriginX);
}

function cropZone(dir, image, factor, imageOriginX, imageOriginY, xPoints, yPoints, imageWidthInPixel, imageHeightInPixel) {
	makeSelection("polygon", xPoints, yPoints);
	roiManager("add");
	run("Select None");
	ranks = Array.rankPositions(xPoints);
	xMin = xPoints[ranks[0]];
	xMax = xPoints[ranks[ranks.length-1]];
	ranks = Array.rankPositions(yPoints);
	yMin = yPoints[ranks[0]];
	yMax = yPoints[ranks[ranks.length-1]];
	correction1 = (xMin-imageOriginX)/imageWidthInPixel;
	xMin = (xMin-imageOriginX-correction1)*factor;
	correction2 = (xMax-imageOriginX) / imageWidthInPixel;
	xMax = (xMax-imageOriginX-correction2)*factor;
	correction1 = (yMin-imageOriginY) / imageHeightInPixel;
	yMin = (yMin-imageOriginY+correction1)*factor;
	correction2 = (yMax-imageOriginY) / imageHeightInPixel ;
	yMax = (yMax-imageOriginY+correction2)*factor;
	width = xMax - xMin;
	height = yMax - yMin;
	print("Exporting zone: x="+xMin+", y="+yMin+", width="+width+", height=" + height);
	run("Bio-Formats", "open=["+dir+"/"+image+"] color_mode=Composite crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1 x_coordinate_1="+xMin+" y_coordinate_1="+yMin+" width_1="+width+" height_1="+height);
	if (!File.exists(dir+"/"+"zones")) File.makeDirectory(dir+"/"+"zones");
	name = File.getNameWithoutExtension(image);
	saveAs("tiff", dir+"/"+"zones"+"/"+name+"-"+round(xMin)+"-"+round(yMin));
	close();
}

function filterNDPAFiles(files) {
	res = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, '.ndpa')) {
			res = Array.concat(res, file);
		}
	}
	return res;
}
