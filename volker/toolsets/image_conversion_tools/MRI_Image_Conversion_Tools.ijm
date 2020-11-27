/**
  * MRI Image Conversion Tools
  * Tools for batch-converting lsm or lif images to tif
  *
  * Work on a folder containing lif or lsm files
  * For each file and for each image it contains:
  * 	- save the channels each as a tif file
  *	- save the overlay as an RGB tif file
  *                      - optional: save stacks as projections
  *
  * written 2011 by Volker Baecker (INSERM) at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *
  * The Lif2Tif macro is based on the Leica LIF Extractor macro by Christophe LETERRIER (http://christopheleterrier.com/LeterrierSOFT.html)
  * which is based on the ZStacks Projector macro version 1.1 14/05/2008
*/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Image_Conversion_Tools";
var DO_PROJECTION = false;
var USE_ALL_SLICES_FOR_PROJECTION = false;
var PROJECTION_START_SLICE = 1;
var PROJECTION_END_SLICE = 3;
var PROJECTION_METHOD = "Max Intensity";
var CHANNELS_STRING = "1111";

var OUTPUT_SUBFOLDER = "tif"

macro "Unused Tool - C037" { }

macro "MRI Image Conversion Tools Help Action Tool - C000T4b12?" {
    run('URL...', 'url='+helpURL);
}
 
macro "Lif2Tif Action Tool - C037T0b11LT7b09iTcb09f" {

    DIR_PATH=getDirectory("Select a directory");
    OUTPUT_DIR = DIR_PATH + "/" + OUTPUT_SUBFOLDER;
    File.makeDirectory(OUTPUT_DIR);

    print("\\Clear");
    print("converting lif file in folder: "+DIR_PATH);

    // Get all file names
    ALL_NAMES=getFileList(DIR_PATH);
    ALL_EXT=newArray(ALL_NAMES.length);
    // Create extensions array
    for (i=0; i<ALL_NAMES.length; i++) {
	LENGTH=lengthOf(ALL_NAMES[i]);
	ALL_EXT[i]=substring(ALL_NAMES[i],LENGTH-4,LENGTH);
    }

    setBatchMode(true);

    // Loop on all .lei and .lif extensions
    fileIndex = 0;
    numberOfLifFiles = 0;
    for (n=0; n<ALL_EXT.length; n++) {
	if (ALL_EXT[n]==".lei" || ALL_EXT[n]==".lif") numberOfLifFiles++;
    }

    for (n=0; n<ALL_EXT.length; n++) {
    if (ALL_EXT[n]==".lei" || ALL_EXT[n]==".lif") {
        fileIndex++;
        // Get the file path
        FILE_PATH=DIR_PATH+ALL_NAMES[n];
        FILE_NAME=File.getName(FILE_PATH);

        // Start BioFormats and get series number in file.
        run("Bio-Formats Macro Extensions");
        Ext.setId(FILE_PATH);
        Ext.getSeriesCount(SERIES_COUNT);
        SERIES_NAMES=newArray(SERIES_COUNT);

        seriesIndex = 0;
        for (i=0; i<SERIES_COUNT; i++) {
          seriesIndex++;
          print("\\Update2:converting image " + (fileIndex) + " of " + numberOfLifFiles + " / series " + seriesIndex + " of " + SERIES_COUNT);
          Ext.setSeries(i);
          Ext.getEffectiveSizeC(CHANNEL_COUNT);
          Ext.getSizeZ(SLICE_COUNT);
          SERIES_NAMES[i]="";
          Ext.getSeriesName(SERIES_NAMES[i]);
          TEMP_NAME=toLowerCase(SERIES_NAMES[i]);
          run("Bio-Formats Importer", "open=["+ FILE_PATH + "] " + " color_mode=Default view=Hyperstack" + " stack_order=Default " + "series_"+d2s(i+1,0));
          Stack.setDisplayMode("composite");
          title = getTitle();
          Stack.setActiveChannels(CHANNELS_STRING);
          run("Stack to RGB", "slices keep");
          rename(title + "-1");
           if (SLICE_COUNT>1 && DO_PROJECTION)  doProjection();
          currentTitle = getTitle();
          index = lastIndexOf(currentTitle, ".lif - ");
          name = substring(currentTitle, index+7, lengthOf(currentTitle)-2);
          save(OUTPUT_DIR + "/" + name + " - RGB.tif");
          close();	
          run("Split Channels");
          // Loop on each channel (each opened window)
         for(j=1; j<CHANNEL_COUNT+1; j++) {
	selectImage("C"+j+"-"+title); 
	if (SLICE_COUNT>1 && DO_PROJECTION)  doProjection();
	currentTitle = getTitle();
	index = lastIndexOf(currentTitle, ".lif - ");
	name = substring(currentTitle, index+7, lengthOf(currentTitle));
	save(OUTPUT_DIR + "/" + name + " - C" + j + ".tif");
	close();
           }
         }
      }
    }
     setBatchMode("exit and display");
     showStatus("finished converting lif to tif");
    print("finished converting lif to tif");
}



macro "Lsm2Tif Action Tool - C037T0b11LT7b09sTcb09m" {
    DIR_PATH=getDirectory("Select a directory");
    OUTPUT_DIR = DIR_PATH + "/" + OUTPUT_SUBFOLDER;
    File.makeDirectory(OUTPUT_DIR);

    print("\\Clear");
    print("converting lsm file in folder: "+DIR_PATH);

    // Get all file names
    ALL_NAMES=getFileList(DIR_PATH);
    ALL_EXT=newArray(ALL_NAMES.length);
    // Create extensions array
    for (i=0; i<ALL_NAMES.length; i++) {
	LENGTH=lengthOf(ALL_NAMES[i]);
	ALL_EXT[i]=substring(ALL_NAMES[i],LENGTH-4,LENGTH);
    } 

    setBatchMode(true);

    // Loop on all .lei and .lsm extensions
    fileIndex = 0;
    numberOfLifFiles = 0;
    for (n=0; n<ALL_EXT.length; n++) {
        if (ALL_EXT[n]==".lsm" )  numberOfLifFiles++;
    }

    for (n=0; n<ALL_EXT.length; n++) {
        if (ALL_EXT[n]==".lsm") {
            fileIndex++;
            // Get the file path
            FILE_PATH=DIR_PATH+ALL_NAMES[n];
            FILE_NAME=File.getName(FILE_PATH);
            print("\\Update2:converting image " + (fileIndex) + " of " + numberOfLifFiles);
            open(FILE_PATH);
            Stack.setDisplayMode("composite");
            title = getTitle();
            getDimensions(width, height, colors, slices, frames);
            SLICE_COUNT = slices;
            Stack.setActiveChannels(CHANNELS_STRING);
            run("Stack to RGB", "slices keep");
            rename(title + "-1");
             if (slices>1 && DO_PROJECTION)  doProjection();
            currentTitle = getTitle();
            name = substring(currentTitle, 0, lengthOf(currentTitle)-6);
            save(OUTPUT_DIR + "/" + name + " - RGB.tif");
            close();	
            run("Split Channels");
            // Loop on each channel (each opened window)
            for(j=1; j<colors+1; j++) {
	selectImage("C"+j+"-"+title); 
	if (slices>1 && DO_PROJECTION)  doProjection();
	currentTitle = getTitle();
	name = substring(currentTitle, 3, lengthOf(currentTitle)-4);
	save(OUTPUT_DIR + "/" + name + " - C" + j + ".tif");
	close();
            }
            if (nImages>0) close();
       }
    }
    setBatchMode("exit and display");
    showStatus("finished converting lsm to tif");
    print("finished converting lsm to tif");
}

macro "Zvi2Tif Action Tool - C037T0b11ZT7b09vTcb09i" {
    DIR_PATH=getDirectory("Select a directory");
    OUTPUT_DIR = DIR_PATH + "/" + OUTPUT_SUBFOLDER;
    File.makeDirectory(OUTPUT_DIR);

    print("\\Clear");
    print("converting zvi file in folder: "+DIR_PATH);

    // Get all file names
    ALL_NAMES=getFileList(DIR_PATH);
    ALL_EXT=newArray(ALL_NAMES.length);
    // Create extensions array
    for (i=0; i<ALL_NAMES.length; i++) {
	LENGTH=lengthOf(ALL_NAMES[i]);
	ALL_EXT[i]=substring(ALL_NAMES[i],LENGTH-4,LENGTH);
    } 

    setBatchMode(true);

    // Loop on all .lei and .lsm extensions
    fileIndex = 0;
    numberOfLifFiles = 0;
    for (n=0; n<ALL_EXT.length; n++) {
        if (ALL_EXT[n]==".zvi" )  numberOfLifFiles++;
    }

    for (n=0; n<ALL_EXT.length; n++) {
        if (ALL_EXT[n]==".zvi") {
            fileIndex++;
            // Get the file path
            FILE_PATH=DIR_PATH+ALL_NAMES[n];
            FILE_NAME=File.getName(FILE_PATH);
            print("\\Update2:converting image " + (fileIndex) + " of " + numberOfLifFiles);

            run("Bio-Formats Importer", "open=["+FILE_PATH+"] open=["+FILE_PATH+"] autoscale color_mode=Composite view=Hyperstack stack_order=XYCZT");

            Stack.setDisplayMode("composite");
            title = getTitle();
            getDimensions(width, height, colors, slices, frames);
            SLICE_COUNT = slices;
            run("Bio-Formats Macro Extensions");
            Ext.setId(FILE_PATH);
            for (j=1; j<colors+1; j++) {
	Ext.getMetadataValue("MultiChannel Color "+(j-1), colorCode);
	colorCode = parseInt(colorCode,10);
	Stack.setChannel(j);
	blueColor    = (colorCode&0xff0000)>> 16;
	greenColor = (colorCode & 0xff00)>>8;
	redColor = colorCode&0xff;
	reds = newArray(256); 
	greens = newArray(256); 
	blues = newArray(256);
	for (i=0; i<256; i++) {
    		 reds[i] = round((i / 255.0) * redColor); 
    		 greens[i] = round((i / 255.0) * greenColor);
    		 blues[i] = round((i / 255.0) * blueColor);
	}
	setLut(reds,greens,blues);
           }
            Stack.setChannel(1);	

            Stack.setActiveChannels(CHANNELS_STRING);
            run("Stack to RGB", "slices keep");
            rename(title + "-1");
             if (slices>1 && DO_PROJECTION)  doProjection();
            currentTitle = getTitle();
            name = substring(currentTitle, 0, lengthOf(currentTitle)-6);
            save(OUTPUT_DIR + "/" + name + " - RGB.tif");
            close();	
            run("Split Channels");
            // Loop on each channel (each opened window)
            for(j=1; j<colors+1; j++) {
	selectImage("C"+j+"-"+title); 
	if (slices>1 && DO_PROJECTION)  doProjection();
	currentTitle = getTitle();
	name = substring(currentTitle, 3, lengthOf(currentTitle)-4);
	save(OUTPUT_DIR + "/" + name + " - C" + j + ".tif");
	close();
            }
       }
    }
    setBatchMode("exit and display");
    showStatus("finished converting zvi to tif");
    print("finished converting zvi to tif");
}

function doProjection() {
    currentTitle = getTitle();
    startSlice = PROJECTION_START_SLICE;
    endSlice = PROJECTION_END_SLICE;
    if (USE_ALL_SLICES_FOR_PROJECTION) {
        startSllice = 1;
        endSlice = SLICE_COUNT;
    }
    run("Z Project...", "start=" + startSlice + " stop=" + endSlice +" projection=" + "[" + PROJECTION_METHOD + "]");
    selectImage(currentTitle);
    close();
    rename(currentTitle);
}

macro 'Lif2Tif Action Tool Options' {
     showOptionsDialog()
}

macro 'Lsm2Tif Action Tool Options' {
     showOptionsDialog()
}

macro 'Zvi2Tif Action Tool Options' {
     showOptionsDialog()
}

function showOptionsDialog() {
       Dialog.create("Tif Export Options");
       Dialog.addMessage("Projection Options");
       Dialog.addCheckbox("do z-projection", DO_PROJECTION);
       Dialog.addCheckbox("use all slices for projection", USE_ALL_SLICES_FOR_PROJECTION);
       Dialog.addNumber("start slice for projection", PROJECTION_START_SLICE);
       Dialog.addNumber("end slice for projection", PROJECTION_END_SLICE);
       Dialog.addChoice("projection method", newArray("Average Intensity", "Max Intensity", "Min Intensity", "Sum Slices", "Standard Deviation", "Median"), PROJECTION_METHOD);
       Dialog.addMessage("Colour Options");
       Dialog.addString("Channels for RGB-overlay (1-use, 0-skip):", CHANNELS_STRING);
       Dialog.show();
       DO_PROJECTION = Dialog.getCheckbox();
       USE_ALL_SLICES_FOR_PROJECTION = Dialog.getCheckbox();
       PROJECTION_START_SLICE = Dialog.getNumber();
       PROJECTION_END_SLICE = Dialog.getNumber();
       PROJECTION_METHOD = Dialog.getChoice();
       CHANNELS_STRING = Dialog.getString();
}
