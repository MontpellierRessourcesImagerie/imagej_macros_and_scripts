/**
  * MRI Skin Tools
  * 
  * The Skin Tools allow to analyse masks of skin 
  * tissue that touch the right and left border of the image. 
  * The length of the lower border line is measured. For 
  * each extremum on the lower border line of the mask the 
  * length of a vertical line across the mask is measured.
  *
  * The interdigitation index can be measured using a given number of segments.
  * The thickness is estimated by using random lines across the skin, that are perpendicular 
  * to the skin border. 
  *
  * written 2011-2012 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  */

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Skin_Tools"
var minRadius = 15;
var numberOfSegments = 4;
var numberOfLines = 10;
var randomSet = false;
var removeScale = true;
var COLOR1_R = 255;
var COLOR1_G = 255;
var COLOR1_B = 0;
var COLOR2_R = 0;
var COLOR2_G = 255;
var COLOR2_B = 0;
var LINE_WIDTH1 = 4;
var LINE_WIDTH2 = 1;
var SMOOTH_BORDER = true;
var SMOOTH_BORDER_RADIUS = 5;

macro "Unused Tool - C037" { }

macro "MRI Skin Tools Help Action Tool -C000D00D01D02D03D04D0aD0bD0cD0dD0eD0fD10D11D12D13D14D1aD1bD1cD1dD1eD1fD20D21D22D23D24D2aD2bD2cD2dD2eD2fD30D31D32D33D34D3bD3cD3dD3eD3fD40D41D42D43D4cD4dD4eD4fD50D51D52D5dD5eD5fD60D6eD6fD70D7eD7fD80D8dD8eD8fD90D91D9bD9cD9dD9eD9fDa0Da1Da2DaaDabDacDadDaeDafDb0Db1Db2DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3DdbDdcDddDdeDdfDe0De1De2De3DebDecDedDeeDefDf0DfcDfdDfeDffCfffD05D06D07D08D09D25D26D27D28D29D35D36D37D38D39D3aD44D45D46D47D48D49D4aD4bD53D54D55D56D57D58D59D5aD5bD5cD61D62D63D64D65D66D67D68D69D6aD6bD6cD6dD81D82D83D84D85D86D87D88D89D8aD8bD8cD92D93D94D95D96D97D98D99D9aDa3Da4Da5Da6Da7Da8Da9Dc4Dc5Dc6Dc7Dc8Dc9Dd4Dd5Dd6Dd7Dd8Dd9DdaDe4De5De6De7De8De9DeaDf1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbC0ffD15D16D17D18D19D71D72D73D74D75D76D77D78D79D7aD7bD7cD7dDb3Db4Db5Db6Db7Db8Db9"{
	run('URL...', 'url='+helpURL);
}

macro "Options Action Tool- C000T4b12o" {
    Dialog.create("MRI Skin Tools Options");
    Dialog.addNumber("minimum radius", minRadius);
    Dialog.addCheckbox("remove scale", removeScale);
    Dialog.addCheckbox("smooth border", SMOOTH_BORDER);
    Dialog.addNumber("smooth border radius", SMOOTH_BORDER_RADIUS);
    Dialog.show();
    minRadius = Dialog.getNumber();
    removeScale = Dialog.getCheckbox();
    SMOOTH_BORDER = Dialog.getCheckbox();
    SMOOTH_BORDER_RADIUS = Dialog.getNumber();
}

macro "Measure Filaggrin Thickness (vertical lines) Action Tool- C000T4b12m" {
    run("Set Measurements...", "  bounding display redirect=None decimal=3");
    measureOneImage();
    roiManager("Show All"); 
    roiManager("Measure");
}

macro "Measure Interdigitation Index Action Tool- C000T4b12i" {
	lengths = newArray(numberOfSegments);
	distances = newArray(numberOfSegments);
	measureSegments(lengths, distances);
	title1 = "Interdigitation Indices";
	title2 = "["+title1+"]";
        	f = title2;
	if (isOpen(title1))
    		print(f, "\\Clear");
	else
        		run("Table...", "name="+title2+" width=250 height=600");
	print(f, "\\Headings:nr\tlength\tdistance\tinterdigitation index");
	for (i=0; i<numberOfSegments; i++) {
		print(f, (i+1) + "\t" + lengths[i] + "\t" + distances[i] +"\t" + (lengths[i] / distances[i]));
  	}
}

macro "Measure Interdigitation Index Action Tool Options" {
    Dialog.create("Interdigitation Index Options");
    Dialog.addNumber("segments", numberOfSegments);
    Dialog.show();
    numberOfSegments = Dialog.getNumber();
}

macro "Measure Filaggrin Thickness Action Tool- C000T4b12t" {
    prepareImage();
    roiManager("Reset");
    run("Clear Results");
    measureWidthPerpendicularLines();
    run("Clear Results");
    roiManager("Measure");
    run("Summarize");
}

macro "Measure Filaggrin Thickness Action Tool Options" {
    Dialog.create("Filaggrin Thickness Options");
    Dialog.addNumber("number of lines", numberOfLines);
    Dialog.show();
    numberOfLines = Dialog.getNumber();
}

macro "Measure Advanced Skin Properties Batch Action Tool- C000T4b12bit" {
     roiManager("Reset");

     showStatus("measure advanced skin properties...");
     run("Clear Results");
     setForegroundColor(255, 255, 0);
     run("Set Measurements...", "  bounding display redirect=None decimal=3");

    call("fr.cnrs.mri.macro.io.IOSettings.resetFileLists");
    call("fr.cnrs.mri.macro.io.IOSettings.show");
    waitForUser("Please select the input files using the IO_Settings dialog and press ok");
    list = call("fr.cnrs.mri.macro.io.IOSettings.getFileList");
    if (list=="none") {IJ.log("No files selected! Macro stopped."); return;}
    files = split(list, ",");
    if (files.length>0) {
        file = files[0];
        folder = File.getParent(file);

        headings =  "File\t" + "length of border\t" + "distance\t"+ "segments\t" + "length\t" + "distance\t" 
	      + "mean interdigitation index\t" + "stdDev\t" + "min\t" + "max\t" 
	      + "vertical lines\t" + "mean width\t" +  "stdDev\t" + "min\t" + "max\t" 
	      + "perpendicular lines\t" + "mean width\t" +  "stdDev\t" + "min\t" + "max\t" + "path\n";
        filenameSummary = folder + "/skin-tools-summary.csv";
        fileSummary = openCSVFile(filenameSummary, headings);
    
        headings = "file\tn\tlength\tpath\n";
        tableVerticalLines = createTable("vertical-lines", headings);

        tablePerpendicularLines = createTable("perpendicular-lines", headings);

         headings = "file\tn\tlength\tdistance\tindex\tpath\n";
         tableInterdigitationIndex = createTable("interdigitation-index", headings);
    }
    for (fileIndex=0; fileIndex< files.length; fileIndex++) {
       	setBatchMode(true);
       	file = files[fileIndex];
	path = File.getParent(file);
       	open(file);
       	prepareImage();
       	folder = File.getParent(file);
      
	// measure length of lower border

	length = measureLengthOfLowerBorder();
	getSelectionCoordinates(x, y);
	xs = x[0];
	ys = y[0];
	xe = x[x.length-1];
	ye = y[y.length-1];
	toScaled(xs, ys);
	toScaled(xe, ye);
	distance = sqrt (((xe - xs) * (xe - xs)) + ((ye - ys) * (ye - ys)));

       	// Interdigitation index 

      	lengths = newArray(numberOfSegments);
       	distances = newArray(numberOfSegments);

       	measureSegments(lengths, distances);
	index = newArray(distances.length);
	for (i=0; i<distances.length; i++) {
		index[i] = lengths[i] / distances[i];
	}
	Array.getStatistics(lengths, minLength, maxLength, meanLength, stdDevLength);
	Array.getStatistics(distances, minDistance, maxDistance, meanDistance, stdDevDistance);
	Array.getStatistics(index, minIndex, maxIndex, meanIndex, stdDevIndex);

	// Width (perpendicular lines)

	run("Clear Results");
	widths = measureWidthPerpendicularLines();
	Array.getStatistics(widths, minWidth, maxWidth, meanWidth, stdDevWidth);

	// Width (vertical lines)
	
	run("From ROI Manager");
	
	widthsVertical = measureWidthVerticalLines();
	Array.getStatistics(widthsVertical, minWidthsVertical, maxWidthsVertical, meanWidthsVertical, stdDevWidthsVertical);
	for (i=0; i<roiManager("count");i++) {
		roiManager("Select", i);
		run("Add Selection...");
	}
	run("To ROI Manager");
	run("Remove Overlay");

	// report 
	print(fileSummary, File.name+"\t" +length+"\t"+ distance+"\t"+ distances.length + "\t" + meanLength + "\t" + meanDistance +"\t" 
		          + meanIndex +"\t" +stdDevIndex +"\t" + minIndex +"\t"+ maxIndex + "\t" 
                                                          + widthsVertical.length + "\t" + meanWidthsVertical + "\t" + stdDevWidthsVertical + "\t" + minWidthsVertical + "\t" + maxWidthsVertical + "\t"
		          + widths.length +"\t" + meanWidth+ "\t" + stdDevWidth + "\t" + minWidth + "\t" + maxWidth + "\t" 
		          + path +"\n");
	saveControlImage(widths, distances);

	roiManager("reset");

	for (i=0; i<widthsVertical.length; i++) {
		print(tableVerticalLines, File.name + "\t" + (i+1) + "\t" + widthsVertical[i] + "\t" + path + "\n");
	} 
	for (i=0; i<widths.length; i++) {
		print(tablePerpendicularLines, File.name + "\t" + (i+1) + "\t" + widths[i] + "\t" + path + "\n");
	}
	for (i=0; i<index.length; i++) {
		print(tableInterdigitationIndex, File.name + "\t" + (i+1) + "\t" + lengths[i] + "\t" +  distances[i] + "\t" +  index[i] + "\t" + path + "\n");
	}
	showProgress(fileIndex/(files.length-1));
	print("\\Clear");
	print("\\Update0:Measuring file " + (fileIndex+1) + " from " + files.length);
   }
   if (files.length>0) {
	File.close(fileSummary);
	selectWindow("vertical-lines");
 	saveAs("results", folder + "/" + "vertical-lines" + ".csv");
	run("Close");
	selectWindow("perpendicular-lines");
 	saveAs("results", folder + "/" + "perpendicular-lines" + ".csv");
	run("Close");
	selectWindow("interdigitation-index");
 	saveAs("results", folder + "/" + "interdigitation-index" + ".csv");
	run("Close");
	selectWindow("Results");
	run("Close");
   }
   print("\\Update1:finished processing");
   setBatchMode("exit and display");
}

macro "Measure Advanced Skin Properties Batch Action Tool Options" {
    Dialog.create("Measure Advanced Skin Properties Batch Options");
    Dialog.addNumber("color one red", COLOR1_R);
    Dialog.addNumber("color one green", COLOR1_G);
    Dialog.addNumber("color one blue", COLOR1_B);
    Dialog.addNumber("color two red", COLOR2_R);
    Dialog.addNumber("color two green", COLOR2_G);
    Dialog.addNumber("color two blue", COLOR2_B);
    Dialog.addNumber("line width one", LINE_WIDTH1);
    Dialog.addNumber("line width two", LINE_WIDTH2);
    Dialog.show();
    COLOR1_R = Dialog.getNumber();
    COLOR1_G = Dialog.getNumber();
    COLOR1_B = Dialog.getNumber();
    COLOR2_R = Dialog.getNumber();
    COLOR2_G = Dialog.getNumber();
    COLOR2_B = Dialog.getNumber();
    LINE_WIDTH1 = Dialog.getNumber();
    LINE_WIDTH2 = Dialog.getNumber();
}

function measureOneImage() {
    prepareImage();
    selectSkinBorder();
    run("MRI Extrema", minRadius);
    call("roi.RoiConverter.addVerticalLinesToRoiManager");
}

function writeResultsTableToFile(filename) {
    if (File.exists(filename)) File.delete(filename);
    f = File.open(filename);
    print(f, "File\t" + "x\t" + "y\t" + "angle\t" + "length\n");	
    for (i=0; i<nResults; i++) {
        label = getResultLabel(i);
        BX = getResult("BX", i);
        BY = getResult("BY", i);
        Angle = getResult("Angle", i);
        Length = getResult("Length", i);
       if (Length!=0)
            print(f, label + "\t" + BX + "\t" + BY + "\t" + Angle + "\t" + Length + "\n");	
    }
    File.close(f);
}

function selectSkinBorder() {
    run("Select None");
    setThreshold(0,224);
    run("Analyze Particles...", "size=500-Infinity circularity=0.00-1.00 show=Nothing add");
    lastIndex = roiManager("count")-1;
    roiManager("Select", lastIndex-1);
    roiManager("Delete");
    roiManager("Select", lastIndex-1);
    roiManager("Delete");
    if (roiManager("count")>0) run("Restore Selection");
    run("MRI Roi Converter");
}

function getIndexAt(x, y, value) {
     start = 0;
     for (i=0; i<x.length-1; i++) {
          if (x[i] == value || (x[i]<value && x[i+1]>value)) {
                start = i;
          }
     }
     if (x[x.length-1]==value) start = x.length-1;
     xValue = x[start];
     yValue = y[start];
     index = i;
     for (i=start+1; i<x.length; i++) {
         xValueNew = x[i];
         yValueNew = y[i];
         index = i;
         if (xValueNew!=xValue || ((xValueNew!=xValue) && (yValueNew<=yValue))) return index;
         else {
           xValue = xValueNew;  
           yValue = yValueNew;   
         }
     }
     return index;
}

function findUpperEdgeIndex(x1, y1, x2, y2) {
    dx = x2-x1;	
    dy = y2-y1;
    n = round(sqrt(dx*dx + dy*dy));
    xInc = dx / n;
    yInc = dy / n;
    n++;
    rx = x2;
    ry = y2;
    for (i=n-1; i>=0; i--) {
        v = getPixel(rx+0.5,ry+0.5);
        if (v>0) {
	i=-1;
        } else {
	        rx = rx - xInc; 
	        ry = ry - yInc;
        }
    }
    xE = rx+0.5;
    yE = ry+0.5;
    makeLine(x1, y1,xE, yE);
    toScaled(x1, y1);
    toScaled(xE, yE);
    length =  sqrt(((xE-x1) * (xE-x1)) + ((yE-y1)*(yE-y1)));
    return length;
}

function selectLowerObject() {
    run("Select None");
    setThreshold(0,224);
    run("Analyze Particles...", "size=500-Infinity circularity=0.00-1.00 show=Nothing add");
    lastIndex = roiManager("count")-1;
    roiManager("Select", lastIndex-1);
    roiManager("Delete");
    roiManager("Select", lastIndex-1);
    roiManager("Delete");
    if (roiManager("count")>0) run("Restore Selection");
    roiManager("Add");
}

function prepareImage() {
    if (removeScale) run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
    run("8-bit");
    run("Grays");
    resetThreshold();
    setAutoThreshold("Default dark");
    run("Convert to Mask");
    run("Fill Holes");
    run("Invert");
    run("Fill Holes");
    run("Invert");
    if (SMOOTH_BORDER) {
	run("Options...", "iterations="+ SMOOTH_BORDER_RADIUS +" count=1 black edm=Overwrite");	
	run("Invert");
	run("Open");
	run("Invert");
    }
}

function measureLengthOfLowerBorder() {
	roiManager("Reset");
	selectLowerObject();
	run("MRI Roi Converter");
	roiManager("Add");
	resetThreshold();
	roiManager("Select", 0);
	roiManager("Delete");
	run("Clear Results");
	roiManager("Measure");
	length = getResult("Length", 0);
	return length;
}

function measureSegments(lengths, distances) {
	roiManager("Reset");
	selectLowerObject();
       	getSelectionCoordinates(x, y);
      	Array.getStatistics(x, xMin, xMax);
	Array.getStatistics(y, yMin, yMax);
       	length = (xMax-xMin) / numberOfSegments;
      	initialLength = length;
      	if (numberOfSegments>1) {
       		for (i=0; i<numberOfSegments; i++) {
           		roiManager("Select", 0);
           		length=initialLength-1;
			do {
			       	roiManager("Select", 0);
			     	length++;
			        currentEndX = xMin+((i+1)*length);
			        currentStartX = xMin+(i*length);
			        if (i<numberOfSegments-1) {
			        	setKeyDown("ctrl");
				        setKeyDown("alt");
				        makeRectangle(currentEndX, 0, xMax, yMax);
				        setKeyDown("none");
        			}
			        if (i>0) {
				        setKeyDown("ctrl");
					setKeyDown("alt");
				        makeRectangle(0, 0, currentStartX, yMax);
					setKeyDown("none");
        			}
			} while (selectionType()>3);
			run("MRI Roi Converter");
			roiManager("Add");
		}
	} else {
	    run("MRI Roi Converter");
	    roiManager("Add");
	}
	resetThreshold();
	roiManager("Select", 0);
	roiManager("Delete");
	run("Clear Results");
	roiManager("Measure");
	for (i=0; i<numberOfSegments; i++) {
        		lengths[i] = getResult("Length", i);
                       		 roiManager("Select", i);
        		getSelectionCoordinates(x, y);
		xs = x[0];
		ys = y[0];
		xe = x[x.length-1];
		ye = y[y.length-1];
		toScaled(xs, ys);
		toScaled(xe, ye);
		distances[i] = sqrt (((xe - xs) * (xe - xs)) + ((ye - ys) * (ye - ys)));
             	}
}

function measureWidthPerpendicularLines() {
	width = getWidth();
	if (!randomSet) {
        	        random("seed", getTime());
	        randomSet = true;
    	}
    	selectSkinBorder();
 	run("Fit Spline");
	getSelectionCoordinates(x, y);
	Array.getStatistics(y, yMin);
	numberOfLinesTried = 0;
	numberOfLinesFound = 0;
	maxNumberOfTrials = numberOfLines * 100;
	maxIndex = x.length - 2;
	minIndex = 1;
        	widths = newArray(numberOfLines);
    	while (numberOfLinesFound<numberOfLines && numberOfLinesTried<maxNumberOfTrials) {
        	        index =minIndex +  round (random * ((maxIndex - minIndex)));
	        makeLine(x[index], y[index], x[index+1], y[index+1]);
	        run("Rotate...", "angle=90");
	        getSelectionCoordinates(xL, yL);
	        x1 = xL[0];
	        y1 = yL[0];
	        x2 = xL[xL.length-1];	
	        y2 = yL[yL.length-1];
	        x0 = x1 - y1 * ((x2-x1) / (y2-y1));
        	        if (x0>=0 && x0 < width) {
	              widths[numberOfLinesFound] = findUpperEdgeIndex(x[index], y[index], x0, 0);  	
        	              numberOfLinesFound++;
          	              roiManager("Add");
	        }
        	        numberOfLinesTried++;
                     }
                      return widths;
}

function measureWidthVerticalLines() {
	roiManager("Reset");
    	selectSkinBorder();
	run("MRI Extrema", minRadius);
	call("roi.RoiConverter.addVerticalLinesToRoiManager");
	run("Select None");
	run("Clear Results");
	roiManager("Measure");
	widths = newArray(nResults);
	for (i=0; i<nResults; i++) {
		widths[i] = getResult("Length", i);	
	} 
	return widths;
}

function saveControlImage(widths, distances) {
	colorR = newArray(2);
	colorG = newArray(2);
	colorB = newArray(2);
	colorR[0] = COLOR1_R;
	colorG[0] = COLOR1_G;
	colorB[0] = COLOR1_B;
	colorR[1] = COLOR2_R;
	colorG[1] = COLOR2_G;
	colorB[1] = COLOR2_B;

	run("RGB Color");

	for (i=0; i<distances.length; i++) {
		setForegroundColor(colorR[i % 2], colorG[i % 2], colorB[i % 2]);
		roiManager("select", i);
		roiManager("Set Line Width", LINE_WIDTH1);
		roiManager("Draw");
	}
	setForegroundColor(colorR[0], colorG[0], colorB[0]);
	for (i=distances.length; i<distances.length + widths.length; i++) {
	             roiManager("select", i);
	             roiManager("Set Line Width", LINE_WIDTH2);
	             roiManager("Draw");
	}	
	setForegroundColor(colorR[1], colorG[1], colorB[1]);
	for (i=distances.length+widths.length; i<roiManager("Count"); i++) {
	             roiManager("select", i);
	             roiManager("Set Line Width", LINE_WIDTH2);
	             roiManager("Draw");
	}	
	if (!File.exists(folder + "/" + "control/")) File.makeDirectory(folder+ "/" + "control/");
	saveAs("png", folder + "/" + "control/" + File.nameWithoutExtension + ".png");
	close();
}

function openCSVFile(filename, headings) {
        if (File.exists(filename)) File.delete(filename);
        file = File.open(filename);
        print(file, headings); 
        return file;
}

function createTable(title, headings) {
    f = "[" + title + "]";
    if (isOpen(title))
     	print(f, "\\Clear");
    else
     	run("Table...", "name="+f+" width=250 height=600");
    print(f, "\\Headings:"+headings);
    return f;
}

