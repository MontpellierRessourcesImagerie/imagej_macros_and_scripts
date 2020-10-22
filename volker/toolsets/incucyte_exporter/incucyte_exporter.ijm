var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Incucyte_Exporter";
var PAD_NUMBERS = true;

macro "Incucyte Exporter Help (f1) Action Tool-C000T4b12?" {
	help();
}

macro "Incucyte Exporter Help [f1]" {
	help();
}

macro "export raw images as std. tif (f2) Action Tool-C999D42C555D52C111D62C000L7282C111D92C555Da2C999Db2CdddD23C111D33C000L43b3C111Dc3CdddDd3C222D24C000L34c4C222Dd4D25C000L35c5C222Dd5CdddD26C111D36C000L46b6C111Dc6CdddDd6C666D27C999D47C555D57C222D67C000L7787C222D97C555Da7C999Db7C666Dd7C000D28C555D38CcccD48Db8C444Dc8C000Dd8C999D29C000L3949C111D59C444L6999C111Da9C000Lb9c9C999Dd9CcccD2aCbbbD3aC444D4aC000L5aaaC444DbaCcccLcadaC111D2bCbbbD3bCcccL6b9bC999DcbC111DdbC444D2cC000D3cC222D4cC666D5cC888D6cCbbbL7c8cC888D9cC666DacC222DbcC000DccC444DdcC666D3dC000L4dbdC666DcdCeeeD4eC999D5eC888D6eC555L7e8eC888D9eC999DaeCeeeDbe" {
	 exportAsStdTif();
}

macro "export raw images as std. tif [f2]" {
	exportAsStdTif();
}

macro "stitch images (f3) Action Tool-C111D22C000L3242CcccL5262C000L7282CcccL92a2C000Lb2c2C111Dd2C000L2343CcccL5363C000L7383CcccL93a3C000Lb3d3L2444CcccL5464C000L7484CcccL94a4C000Lb4d4CcccL2545L7585Lb5d5L2646L7686Lb6d6C000L2747CcccL5767C000L7787CcccL97a7C000Lb7d7L2848CcccL5868C000L7888CcccL98a8C000Lb8d8CcccL2949L7989Lb9d9L2a4aL7a8aLbadaC000L2b4bCcccL5b6bC000L7b8bCcccL9babC000LbbdbL2c4cCcccL5c6cC000L7c8cCcccL9cacC000LbcdcC111D2dC000L3d4dCcccL5d6dC000L7d8dCcccL9dadC000LbdcdC111Ddd" {
	stitchImages();	 
}

macro "stitch images [f3]" {
	stitchImages();	 
}

macro "clean images (f4) Action Tool-C000D4aD4bD5aD5bD6aD7aD7bD7cD89D8aD8bC888D29D3bD54D8eC333D6cD79D7dDb5CcccD36D53D5dD7eDb6Dc2C000D3aD6bD8cCaaaD46D49D98D9aDa5C666D4cD88Db4Dc4CeeeD6eC999D39D59D9bD9cD9dC444D5cD97Dc3Dd2CeeeD63D78D96D9eDd1C111D6dD8dDa6CbbbD37D64D75D76Dd3C777D2aD47D69D99Da7CfffD3cD85D86Db3"{
	cleanImages();	
}

macro "clean images [f4]" {
	cleanImage();	
}

function help() {
	run('URL...', 'url='+helpURL);
}

function exportAsStdTif() {	
	nr = "644";
	root = getDir("Please select the database root directory (the folder containig EssenFiles)");
	files = getFileList(root);
	if (!contains(files, "EssenFiles/")) exit("db not found!");
	dataDir = root+"/EssenFiles/ScanData/";
	years = getFileList(dataDir);
	for (y=0; y<years.length; y++) {
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				hour = hours[h];
				inDir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + nr + "/";
				images = getFileList(inDir);
				outDir =  inDir + "tif/";
				if (!File.exists(outDir)) File.makeDirectory(outDir);
				setBatchMode(true);
				for(i=0; i<images.length; i++) {
					if (File.isDirectory(inDir+images[i]) || !endsWith(images[i], ".tif")) continue;
					print("Converting " + inDir+images[i]);
					run("Bio-Formats", "open=["+inDir+images[i]+"] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
					image = images[i];			
					if (PAD_NUMBERS) image = padNumbers(image);	
					saveAs("tiff", outDir+image);
					close();
				}
				setBatchMode(false);
			}
		}
	}
}

function stitchImages() {
	nr = "644";
	root = getDir("Please select the database root directory (the folder containig EssenFiles)");
	files = getFileList(root);
	if (!contains(files, "EssenFiles/")) exit("db not found!");
	dataDir = root+"/EssenFiles/ScanData/";
	years = getFileList(dataDir);
	for (y=0; y<years.length; y++) {
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				hour = hours[h];
				inDir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + nr + "/tif/";
				calculateStitchings(inDir);
			}
		}
	}
}


function calculateStitchings(dir) {
	files = getFileList(dir);
	images = filterChannelOneImages(files);
	wells = getWells(images);
	for (i = 0; i < wells.length; i++) {
		well = wells[i];
		run("Grid/Collection stitching", "type=[Grid: row-by-row] order=[Right & Down                ] grid_size_x=4 grid_size_y=4 tile_overlap=20 first_file_index_i=1 directory="+dir+" file_names="+well+"-{ii}-C1.tif output_textfile_name="+well+"-C1-translations.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save memory (but be slower)] image_output=[Write to disk] output_directory="+dir);
		translations = File.openAsString(dir + well+"-C1-translations.registered.txt");
		translations = replace(translations, well, dir+well);
		File.saveString(translations, dir + well+"-C1-translations.registered.txt");
	}	
}

function cleanImages() {
	nr = "644";
	root = getDir("Please select the database root directory (the folder containig EssenFiles)");
	files = getFileList(root);
	if (!contains(files, "EssenFiles/")) exit("db not found!");
	dataDir = root+"/EssenFiles/ScanData/";
	years = getFileList(dataDir);
	for (y=0; y<years.length; y++) {
		year = years[y];
		days = getFileList(dataDir + "/" + year);
		for(d=0; d<days.length; d++) {
			day = days[d];
			hours = getFileList(dataDir + "/" + year + "/" + day);
			for(h=0; h<hours.length; h++) {
				hour = hours[h];
				dir = dataDir + "/" + year + "/" + day + "/" + hour + "/" + nr + "/tif/";
				files = getFileList(dir);
				images = filterChannelOneImages(files);
				wells = getWells(images);
				setBatchMode(true);
				for (i = 0; i < wells.length; i++) {
					well = wells[i];
					run("Image Sequence...", "dir="+dir+" filter=("+well+"-..-C1) sort");
					cleanImage();
					run("Image Sequence... ", "dir="+dir+"back/"+" format=TIFF use");
					close();
					run("Image Sequence...", "dir="+dir+" filter=("+well+"-..-C2) sort");
					cleanImage();
					run("Image Sequence... ", "dir="+dir+"back/"+" format=TIFF use");
					close();
				}
				setBatchMode(false);
			}
		}
	}
}

function padNumbers(image) {
	parts = split(image, '-');
	leftPart=parts[0];
	nrString = parts[1];
	rightPart = parts[2];
	nrString = IJ.pad(nrString, 2);
	result = leftPart+"-"+nrString+"-"+rightPart;
	return result;
}

function contains(array, element) {
	for (i = 0; i < array.length; i++) {
		if (array[i]==element) return true;
	}
	return false;
}

function filterChannelOneImages(files) { 
	images = newArray(0);
	for (i = 0; i < files.length; i++) {
		file = files[i];
		if (File.isDirectory(file) || !endsWith(file, "C1.tif")) continue;
		images = Array.concat(images, file);
	}
	return images;
}

function getWells(images) {
	wells = newArray(0);
	for (i = 0; i < images.length; i++) {
		image = images[i];
		parts = split(image, '-');
		well = parts[0];
		if (!contains(wells, well)) wells = Array.concat(wells, well);
	}
	return wells;
}

function cleanImage() {
	Stack.getDimensions(width, height, channels, slices, frames);
	run("32-bit");
	sumOfMeans = 0;
	maxIndes = 1;
	bestMax = 0;
	for (i = 0; i < slices; i++) {
		setSlice(i+1);
		getStatistics(area, mean, min, max, std, histogram);
		sumOfMeans += mean;
		run("Divide...", "value="+mean+" slice");
		if (max>bestMax) {
			maxIndex = (i+1);
			bestMax = max;
		}
	}
	avgMean = sumOfMeans / slices;
	run("Multiply...", "value="+avgMean + " stack");
	setSlice(maxIndex);
	run("16-bit");
	run("Subtract Background...", "rolling=50 stack");
}
