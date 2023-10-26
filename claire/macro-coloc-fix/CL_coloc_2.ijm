
// ===================== GLOBAL VARIABLES =====================

var channels = newArray(4);
var targets  = newArray(4);

// ============================================================


function setup() {
	roiManager("reset");
	roiManager("Centered", "false");
	run("Clear Results");
	setBackgroundColor(0, 0, 0);
	setFont("Serif", 28, "antialiased");
	run("Options...", "iterations=1 count=1 black do=Nothing");
	close("*");
}


function assign(name) { // Return the correct order for the channels
	if (name=="Nucleolin") { return 1; }
	if (name=="SENP3")     { return 2; }
	if (name=="HA-BnpB")   { return 3; }
	if (name=="DAPI")      { return 4; }
}


function channels_order() {	
	Dialog.create("Channels' order");
	Dialog.addMessage("Channels as they are on your current image.");
	stainings= newArray("Nucleolin", "SENP3", "HA-BnpB", "DAPI");
	
	for (i = 1 ; i <= 4 ; i++) {
		Dialog.addChoice("C"+i, stainings, stainings[i-1]);
	}
	
	Dialog.show();
	
	for (i = 0 ; i < 4 ; i++) {
		channels[i] = Dialog.getChoice();
	}
}

function rearrange() { // Reorganize channels' order
	
	title = getTitle();
	run("Split Channels");
	buffer = "";
	
	for (i = 0; i < 4; i++) {
		buffer+="c";
		targets[i] = assign(channels[i]);
		buffer += toString(targets[i]);
		buffer += "=";
		cName = "C"+toString(i+1)+"-"+title;
		buffer += cName;
		buffer += " ";
	}

	run("Merge Channels...", buffer + "create");
}

function main() {
	setup();
	
	m = 0;	//m will be used to count the number of lines of the result table after each image analysis
	dir = getDirectory("Choose a directory");	//the directory with the images to analyze
	list = getFileList(dir);
	channels_order();
	setBatchMode(true);
	
	for (j = 0; j < list.length; j++) { // loop for all images of the folder
		if (!endsWith(list[j], ".czi")) { continue; }	//works only with 2D images in czi (Zeiss) format
											// Order of the channels must be 1-Nucleolin, 2-SENP3, 3-HA-BnpB, 4-DAPI
		path = dir + list[j];
		run("Bio-Formats Importer", "open=["+path+"] autoscale color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		ImageTitle=getTitle();
		rearrange();
		rename(ImageTitle);
		print("============== " + ImageTitle + " ==============");
		
		// 1. Working on nucleolin
		run("Duplicate...", "duplicate  channels=1");
		rename("Nucleolin");
		run("Median...", "radius=2");
		setAutoThreshold("MaxEntropy dark"); 	//detection of the nucleoli with the nucleolin signal
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Fill Holes");
		setColor(255, 255, 255);
		selectWindow(ImageTitle);
		
		// 2. Working on DAPI
		run("Duplicate...", "duplicate  channels=4");
		rename("DAPI");
		run("Gaussian Blur...", "sigma=0.25 scaled");
		setAutoThreshold("Otsu dark");
		run("Convert to Mask");		
		run("Fill Holes");
		run("Analyze Particles...", "size=60.00-Infinity circularity=0.10-1.00 show=Masks exclude add");
		run("Invert LUT");
		imageCalculator("AND", "Nucleolin","Mask of DAPI"); // as the nucleolin signal is sometimes wrongly found outside the nuclei (background), the segmentation of the nucleoli is corrected with the image of the segmented nuclei.
		
		selectWindow("DAPI");
		close();
		n = roiManager("count"); // the number of ROIs in the ROI manager corresponds to the number of nuclei in the current image
		roiManager("Show None");
		
		if (n == 0) {
			print("No ROI built for image: " + ImageTitle);
			close("*");
			roiManager("reset");
			continue;
		} 
		else {
			print("ROI for image: " + ImageTitle + " -> " + n);
		}
		
		for (i = 0 ; i < n ; i++) { // loop for all the nuclei of the current image, meaning each ROI of the ROI manager
			selectWindow(ImageTitle);
			run("Select None");
			roiManager("select", i);
			run("Duplicate...", "duplicate");
			rename("StackOne");
			run("Select None");
			run("Split Channels");
			selectWindow("C3-StackOne");
			run("Select None");
			roiManager("select", i);
			Roi.move(0, 0);
			run("Set Measurements...", "min redirect=None decimal=4"); // measure of the minimum and maximum intensity of the HA-BnpB signal for each nucleus. These results will be saved in the columns Min and Max of the results file.
			roiManager("Measure");
			BnpB = getResult("Max", (m+i));
			
			res = "0";
			if (BnpB >= 50) { res = "1"; }
			setResult("BnpB", (m+i), res);
			
			selectWindow("C4-StackOne");
			roiManager("select", i);
			Roi.move(0, 0);
			run("Clear Outside");
			setThreshold(1, 255);
			run("Convert to Mask"); // a mask of the nuclei is created ; it will be used to restrict the measure of the Pearson coefficient to the nucleus area
			
			run("Coloc 2", "channel_1=C1-StackOne channel_2=C2-StackOne roi_or_mask=C4-StackOne threshold_regression=Costes manders'_correlation psf=3 costes_randomisations=10");// with the plugin Coloc2, the Pearson correlation coefficient is measured between the nucleolin signal and the SENP3 signal. The result is saved in the "Pearson Nucl/SENP3" column. 
			logcontent=getInfo("log");
			Pindex1=indexOf(logcontent, "Pearson's R value (no threshold)")+34;
			Pindex2=indexOf(logcontent, "Pearson's R value (below threshold)");
			PC=substring(logcontent, Pindex1, Pindex2-1);
			setResult("Pearson Nucl/SENP3", (m+i), PC);
	
	
			run("Coloc 2", "channel_1=C2-StackOne channel_2=C3-StackOne roi_or_mask=C4-StackOne threshold_regression=Costes manders'_correlation psf=3 costes_randomisations=10");// with the plugin Coloc2, the Pearson correlation coefficient is measured between the HA-BnpB signal and the SENP3 signal. The result is saved in the "Pearson SENP3/BnpB" column.
			logcontent2=getInfo("log");
			P2index1=indexOf(logcontent2, "Pearson's R value (no threshold)")+34;
			P2index2=indexOf(logcontent2, "Pearson's R value (below threshold)");
			PC2=substring(logcontent2, P2index1, P2index2-1);
			setResult("Pearson SENP3/BnpB", (m+i), PC2);
	
		
			selectWindow("Nucleolin"); // this part will measure the mean intensity of the SENP3 signal in the nucleoli (results in the "SENP3inNuc" column), the mean intensity of the SENP3 signal in the nuclei but outside the nucleoli (results in the "SENP3outNuc" column), and the ratio between the 2 previous results (results in the "SENP3-ratio" column).
			run("Select None");
			roiManager("select", i);
			run("Duplicate...", " ");
			rename("NucOne");
			setThreshold(1, 255);
			run("Create Selection");
			type = selectionType();
			
			if (type > -1) {
				roiManager("Add");
				selectWindow("NucOne");
				close();
				selectWindow("C2-StackOne");
				roiManager("select", n);
				getStatistics(area, mean);
				setResult("SENP3inNuc", (m+i), mean);
				run("Clear", "slice");
				run("Select None");
				setThreshold(1, 255);
				roiManager("select", i);
				List.setMeasurements("limit");
				mean2 = List.getValue("Mean");
				setResult("SENP3outNuc", (m+i), mean2);
				ratio = mean/mean2;
				setResult("SENP3-ratio", (m+i), ratio);
				roiManager("select", n);
				roiManager("Delete");
			} else {	// when no nucleolin signal is found in the nucleus, the 3 results are "NA"
				setResult("SENP3inNuc", (m+i), "NA");
				setResult("SENP3outNuc", (m+i), "NA");
				setResult("SENP3-ratio", (m+i), "NA");
				selectWindow("NucOne");
				close();
				ratio="NA";
			}
			
			selectWindow("C1-StackOne");
			close();
			selectWindow("C2-StackOne");
			close();
			selectWindow("C3-StackOne");
			close();
			selectWindow("C4-StackOne");
			close();
		
			selectWindow(ImageTitle);
			run("Select None");
			roiManager("select", i);
			Roi.getBounds(x, y, width, height);
			Overlay.drawString(PC+"\n"+PC2, x, y+30); // the 2 Pearson coefficient are added in the overaly of the image that will be saved.
			setResult("Titre", (m+i), ImageTitle);
		}
		
		m += n; // m, number of the Results table	
		Overlay.show();
		selectWindow("Nucleolin");
		setThreshold(1, 255);
		run("Create Selection");
		roiManager("Add");
		selectWindow("Nucleolin");
		close();
		selectWindow("Mask of DAPI");
		close();
		selectWindow(ImageTitle);
		run("Select None");
		saveAs("Tiff", path+".tif");
		close();
		roiManager("Save", path+".zip"); // the ROI of the ROI manager are saved ; they contain each nucleus analyzed for each image, and the nucleoli segmentation.
		roiManager("reset");
	
	}
	setBatchMode(false);
	selectWindow("Results");
	saveAs("Results", dir+"Results.xls"); //the Results table is saved
	run("Close");
}

main();

	
