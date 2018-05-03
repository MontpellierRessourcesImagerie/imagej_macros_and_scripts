// @File(label = "Input directory", style = "directory") srcFile
// @String(label = "File extension", value=".tif") ext
// @Integer(label = "Number of width measurements", value="7", stepSize="1") numberOfWidthMeasurements
// Compare with the original Process_Folder to see how ImageJ 1.x
// GenericDialog use can be converted to @Parameters.
/**
  * Analyze Cardiomyocytes (SHG images)
  * Collaborators: 
  *		 Albano Meli, Olivier Cazorla
  *
  * Analyze images from second harmonics microscopy of cardiac muscle cells (cardiomyocytes). 
  * The tool measures the length of the sarcomeres using the FFT of the image and the degree 
  * of organization of the sarcomeres by using the dispersion provided by the Directonality command
  * of FIJI. Although the input images can be stacks only the middle slice is used for the analysis.
  *
  * (c) 2017, INSERM
  * written by Volker Baecker at Montpellier RIO Imaging (www.mri.cnrs.fr)
  *
*/

var ext = ".tif";
var numberOfWidthMeasurements = 7

var helpURL = "http://dev.mri.cnrs.fr/wiki/imagej-macros/Analyze_Cardiomyocytes"

macro "Analyze Cardiomyocytes Help Action Tool - C000D60D6fD70D71D7eD7fD80D81D82D8eD8fD90D91D92D9dD9eD9fDa0Da1Da2Da3DadDaeDafDb0Db1Db2Db3DbdDbeDbfDc0Dc1Dc2Dc3Dc4DcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5Dd6DddDdeDdfDe0De1De2De3De4De5De6De7DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC333D0cD1bD1fD51D7cD8cDa8Da9Db7Db8Db9Dc8Dc9DcaDd8Dd9DdaC000D4eD50D5eD6eD8dDb4DbcDc5DecC888D04D13D16D24D46D52D55D64D78D85D87D88D96C777D05D06D0aD14D31D3aD48D49D59D5aD63D65D74D75D76D8bD97D99D9aC222D0eD1cD1dD1eD2fD3fD40D6cD83D9cDa4DabDb5DbbDcbDd7De9DeaCbbbD03D12D17D26D27D34D35D36D42D45D54D6aD79D7aC555D30D41D4aD56D57D58D5bD66D67D84D98D9bDa5Da6Da7C111D2eD4fD5cD61Dc6DdcDe8DebCaaaD07D1aD21D25D2aD32D37D38D69D7bD8aC888D15D47D68D6bD77D95C333D0dD2bD3bD4bD73DaaDb6DbaDc7DdbCeeeD00D01D02D08D09D10D11D18D19D28D29D33D43D44D53C444D0bD0fD62D94C111D2cD2dD3cD3dD3eD4cD4dD5dD5fD6dD72D7dD93DacDccC999D20D22D23D39D86D89"{
    run('URL...', 'url='+helpURL);
}

macro 'Analyze Cadiomyocytes Action Tool (f1) - C000T4b12r' {
	analyzeCardimyocytes();
}

macro 'Analyze Cadiomyocytes Action Tool (f1) Options' {
	 Dialog.create("Analyze Cardiomyocytes Options");
	 Dialog.addString("file extension: ", ext);
	 Dialog.addNumber("number of width measurements: ", numberOfWidthMeasurements);
	 Dialog.show();
	 ext = Dialog.getString();
	 numberOfWidthMeasurements = Dialog.getNumber();
}

macro 'Analyze Cadiomyocytes [f1]' {
	analyzeCardimyocytes();
}

macro 'Analyze Cadiomyocytes Batch Action Tool (f2) - C000T4b12b' {
	analyzeCardimyocytesBatch();
}

macro 'Analyze Cadiomyocytes Batch [f2]' {
	analyzeCardimyocytesBatch();
}

function analyzeCardimyocytes() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/directionality_batch.py");
	parameter = "srcFile=None, ext=" + ext+", nrOfMeasurements="+numberOfWidthMeasurements;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}

function analyzeCardimyocytesBatch() {
	macrosDir = getDirectory("macros");
	script = File.openAsString(macrosDir + "/toolsets/directionality_batch.py");
	srcFile = getDirectory("select the input folder !");
	parameter = "srcFile=" + srcFile+ ", ext=" + ext+", nrOfMeasurements="+numberOfWidthMeasurements;
	call("ij.plugin.Macro_Runner.runPython", script, parameter); 
}