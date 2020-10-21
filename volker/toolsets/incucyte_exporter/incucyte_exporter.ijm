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
					saveAs("tiff", outDir+images[i]);
					close();
				}
				setBatchMode(false);
			}
		}
	}
}

function contains(files, file) {
	for(i=0; i<files.length; i++) {
		if (files[i]==file) return true;
	}
	return false;
}
