/**
 * Load Corresponding Images 
 * 
 * Opens for each image a second image with the same name from another folder and displays the two images next to each other.
 * 
 * (c) INSERM 2019
 * 
 * written 2019 by Volker Baecker (INSERM) at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
 * 
**/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Load-Corresponding_Images";
var DIRECTORY1 = "";
var DIRECTORY2 = "";
var FILES = newArray(0);
var EXT = ".tif";
var VIEW_OPTION = "Hyperstack";
var currentFile = 0;
var IMAGE_A = "";
var IMAGE_B = "";
var CLOSE_LAST_IMAGES = true;

macro "Load Corresponding Images Help [f1]" {
   showHelp();
} 

macro "Set Folders [f2]" {
	setFolders();	
}

macro "First Image [f3]" {
     firstImageAction();
}

macro "Previous Image [f4]" {
    previousImageAction();
}

macro "Next Image [f5]" {
    nextImageAction();
}

macro "Last Image [f6]" {
    lastImageAction();
}

macro "Reload Image [f7]" {
    reloadImageAction();
}

macro "Load Corresponding Images Help (f1) Action Tool - C000T4b12?"{
   showHelp();
}

macro "Set Folders (f2) Action Tool - C000D17D18D25D26D27D28D29D2aD34D35D36D37D38D39D3aD3bD43D44D4bD4cD4dD52D53D54D5bD5cD5dD62D63D6cD6dD6eD71D72D7dD7eD81D82D8dD8eD91D92D93D9dD9eDa2Da3DacDadDb2Db3Db4DbbDbcDbdDc4Dc5DcaDcbDccDd4Dd5Dd6Dd7Dd8Dd9DdaDdbDe6De7De8De9C000D2bD3cD42D45D73D9cDc3Dc6C000D33D7cD83Dc9C000D24D4aD61Da4C000D16D8cDaeC000D19C000DabDe5C000DeaC000Db5Dc7C000Dc8C000D5eC000Da1DbaC000DcdC111D64C111D46C111DdcC111D49Dc2C111D15D51C111D3dC111D1aC111Dd3C111D6bC222D2cC222D55C222D32D47DbeC222D48C222D94C222C333DebC333De4C333D23C333D5aC333Db1C444D9bC444D4eC444Db6C444D74C444Df7Df8C444D8fC444D7fC444C555Db9C555D9fC555D84C555D41C555C666D1bDf6C666D08D7bDa5Df9C666D07C666D6fC666D14C666C777D70D80C777D8bC777D90DaaC777C888DddC888Db7C888D06C888D60C999Db8C999DceC999D09D88C999D87DafC999Df5C999DfaC999D2dDd2C999CaaaDecCaaaD78CaaaDc1CaaaD65CaaaD56D5fCaaaDe3CaaaCbbbD77CbbbDa0CbbbD22D3eCbbbD59CbbbCcccD05D6aCcccD50CcccD0aCcccD31CcccD1cCdddDbfCdddDf4DfbCdddD57CdddD13D58CdddD95CeeeDa6CeeeDb0CeeeD4fDa9CeeeD9aCeeeCfffD97D98CfffD04CfffD0bCfffDdeCfffD40DedCfffD75CfffD89Dd1De2CfffD2eD86CfffD66D67D68D79DfcCfffD1dD76DcfDf3CfffD21D69D7aCfffD0cD12D3fD85D96D99Dc0CfffD00D01D02D03D0dD0eD0fD10D11D1eD1fD20D2fD30D8aDa7Da8Dd0DdfDe0De1DeeDefDf0Df1Df2DfdDfeDff"{
	setFolders();
}

macro "Set Folders (f2) Action Tool Options" {
    showIOSettings();
}

macro "First Image (f3) Action Tool - C000D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dD1eD87D88D96D97D98D99Da6Da7Da8Da9DaaDb5Db6Db7Db8Db9DbaDc4Dc5Dc6Dc7Dc8Dc9DcaDcbDd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDe3De4De5De6De7De8De9DeaDebDecC000DedC000Dd3C000De2C000D78DbbC000Da5C000DccC111D77D89Db4C111D21D22D23D24D25D26D27D28D29D2aD2bD2cD2dD2eC111C222DddC222D86C222D9aDc3C222C333DeeC333Dd2C333D95C333DabC444D68C444C555D67C555D79C555C666Da4C666DbcC666De1C666C777D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD10D1fDf2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdC777DfeC777Df1C777D76C777C888D20D2fD8aC888Db3C888C999DcdC999D31D32D33D34D35D36D37D38D39D3aD3bD3cD3dD3eC999CaaaD85CaaaD9bCaaaCbbbD00D0fCbbbD58Dc2CbbbD69CbbbCcccD57CcccDdeCcccD94CcccD30D3fDffCcccDacCcccCdddD66CdddD7aCdddCeeeDa3Dd1CeeeDbdDf0CeeeD75CeeeDefCeeeD8bCeeeCfffDb2CfffD59CfffDceDe0CfffD84CfffD9cCfffD47D48CfffD56Dc1CfffD6aCfffDdfCfffD93DadCfffDd0CfffD40D41D42D43D44D45D46D49D4aD4bD4cD4dD4eD4fD50D51D52D53D54D55D5aD5bD5cD5dD5eD5fD60D61D62D63D64D65D6bD6cD6dD6eD6fD70D71D72D73D74D7bD7cD7dD7eD7fD80D81D82D83D8cD8dD8eD8fD90D91D92D9dD9eD9fDa0Da1Da2DaeDafDb0Db1DbeDbfDc0Dcf"{
      firstImageAction();
}

macro "First Image (f3) Action Tool Options" {
    showIOSettings();
}

macro "Previous Image (f4) Action Tool - C000D37D47D56D57D58D65D66D67D68D69D75D76D77D78D79D7aD85D86D87D88D89D8aD94D95D96D97D98D99D9aDa3Da4Da5Da6Da7Da8Da9DaaDabDb3Db4Db5Db6Db7Db8Db9DbaDbbDbcDc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDccDd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcC000Dc2C000D48C000DddC000D84C000Db2C000D46D9bC111D27C111Dd1C111D38C111D59D74C111C222De1De2De3De4De5De6De7De8De9DeaDebDecDedC222D93C222DcdC333D36C333D55C333DacC333C444DeeC444D8bC444C555Dc1C555D6aC666D49C666De0C666Da2C666C777D17D83C777Df0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeC777C888DdeC888D28C888C999D64DbdC999D45C999CaaaD9cCaaaDd0CaaaCbbbD26CbbbD5aCcccD7bCcccD92CcccD07Db1DffCcccCdddD18CdddD54CeeeDceCeeeDadCeeeD39CeeeDefCeeeD16D73CfffD6bCfffD8cDa1CfffD29Dc0CfffD63DdfCfffD00D01D02D03D04D05D06D08D09D0aD0bD0cD0dD0eD0fD10D11D12D13D14D15D19D1aD1bD1cD1dD1eD1fD20D21D22D23D24D25D2aD2bD2cD2dD2eD2fD30D31D32D33D34D35D3aD3bD3cD3dD3eD3fD40D41D42D43D44D4aD4bD4cD4dD4eD4fD50D51D52D53D5bD5cD5dD5eD5fD60D61D62D6cD6dD6eD6fD70D71D72D7cD7dD7eD7fD80D81D82D8dD8eD8fD90D91D9dD9eD9fDa0DaeDafDb0DbeDbfDcf"{
      previousImageAction();
}


macro "Previous Image (f4) Action Tool Options" {
       showIOSettings();
}

macro "Next Image (f5) Action Tool - C000D22D23D24D25D26D27D28D29D2aD2bD2cD33D34D35D36D37D38D39D3aD3bD3cD43D44D45D46D47D48D49D4aD4bD4cD53D54D55D56D57D58D59D5aD5bD64D65D66D67D68D69D6aD75D76D77D78D79D7aD85D86D87D88D89D8aD95D96D97D98D99Da6Da7Da8Db7Dc7C000D32C000Db8C000D2dC000D74C000D42C000D6bDb6C111Dd7C111D21C111Dc8C111D84Da9C111C222D11D12D13D14D15D16D17D18D19D1aD1bD1cD1dC222D63C222D3dC333Dc6C333Da5C333D5cC333C444D1eC444D7bC444C555D31C555D9aC666Db9C666D10C666D52C666C777D73De7C777D00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eC777C888D2eC888Dd8C888C999D4dD94C999Db5C999CaaaD6cCaaaD20CaaaCbbbDd6CbbbDaaCcccD8bCcccD62CcccD0fD41Df7CcccCdddDe8CdddDa4CeeeD3eCeeeD5dCeeeDc9CeeeD1fCeeeD83De6CfffD9bCfffD51D7cCfffD30Dd9CfffD2fD93CfffD3fD40D4eD4fD50D5eD5fD60D61D6dD6eD6fD70D71D72D7dD7eD7fD80D81D82D8cD8dD8eD8fD90D91D92D9cD9dD9eD9fDa0Da1Da2Da3DabDacDadDaeDafDb0Db1Db2Db3Db4DbaDbbDbcDbdDbeDbfDc0Dc1Dc2Dc3Dc4Dc5DcaDcbDccDcdDceDcfDd0Dd1Dd2Dd3Dd4Dd5DdaDdbDdcDddDdeDdfDe0De1De2De3De4De5De9DeaDebDecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df8Df9DfaDfbDfcDfdDfeDff"{
      nextImageAction();
}

macro "Last Image (f6) Action Tool - C000D13D14D15D16D17D18D19D1aD1bD1cD23D24D25D26D27D28D29D2aD2bD34D35D36D37D38D39D3aD3bD45D46D47D48D49D4aD55D56D57D58D59D66D67D68D69D77D78De1De2De3De4De5De6De7De8De9DeaDebDecDedDeeC000D12C000D2cC000D1dC000D44D87C000D5aC000D33C111D4bD76D88C111Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDddDdeC111C222D22C222D79C222D3cD65C222C333D11C333D2dC333D6aC333D54C444D97C444C555D98C555D86C555C666D5bC666D43C666D1eC666C777D02D03D04D05D06D07D08D09D0aD0bD0cD0dDe0DefDf1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeC777D01C777D0eC777D89C777C888D75Dd0DdfC888D4cC888C999D32C999Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dc8Dc9DcaDcbDccDcdDceC999CaaaD7aCaaaD64CaaaCbbbDf0DffCbbbD3dDa7CbbbD96CbbbCcccDa8CcccD21CcccD6bCcccD00Dc0DcfCcccD53CcccCdddD99CdddD85CdddCeeeD2eD5cCeeeD0fD42CeeeD8aCeeeD10CeeeD74CeeeCfffD4dCfffDa6CfffD1fD31CfffD7bCfffD63CfffDb7Db8CfffD3eDa9CfffD95CfffD20CfffD52D6cCfffD2fCfffD30D3fD40D41D4eD4fD50D51D5dD5eD5fD60D61D62D6dD6eD6fD70D71D72D73D7cD7dD7eD7fD80D81D82D83D84D8bD8cD8dD8eD8fD90D91D92D93D94D9aD9bD9cD9dD9eD9fDa0Da1Da2Da3Da4Da5DaaDabDacDadDaeDafDb0Db1Db2Db3Db4Db5Db6Db9DbaDbbDbcDbdDbeDbf"{
     lastImageAction();
}

macro "Last Image (f6) Action Tool Options" {
       showIOSettings();
}

macro "Reload Image (f7) Action Tool - C000D62D63D64De7C000D73C000D53C000DeaC000D1aD74C000D6eDe8C000D54D72C000DcdC000Db4C000D4dDaeDebC000D83C000DdcC000D75C111D2bC111Dd5C111De9C111De6C111D7eC111D71C111D3cD93C111D5eC111D9eC111DbeC111D8eC111Dd6C222D3dD65Df8C222D2cC222Dc4C222Df9C222Da4C222Dc5C222C333D43C333Da3C333D2aD5dDddC333D52C333D84C333C444Df7C444D1bC444D19C444DbdC444DdbC444D8fC444DfaC555D44D76C555D9fC555D94C555DecC555D7fC555D61C555C666D4eC666DccC666DceC666C777D82Dd7C777De5C777D4cDb3C888DafC888D70C888D29C888D6dC888D55C999D3bC999D6fC999Df6C999D81D85Db5C999Dd4C999D86C999D09CaaaD80CaaaD2dCaaaD0aDfbCaaaDadCaaaDdaCaaaCbbbD1cCbbbDc6CbbbD66CbbbD33CbbbDd8CbbbCcccD42CcccD7dCcccD5fCcccD3eCcccDbfCcccDc3CcccD92CcccD34D9dDd9CcccDedCdddD8dCdddDdeCdddD51CdddDbcCdddD0bCdddD5cD87CdddCeeeDa5CeeeDa2CeeeDfcCeeeD77DcbCeeeD18CeeeD45D60CeeeDf5CeeeD3aCeeeCfffD08De4CfffD28CfffD4bDcfCfffD56CfffDb2CfffD1dD4fDc7CfffD6cDd3CfffD2eD32Db6CfffD39CfffD23CfffD0cD24DacDcaDfdCfffD41D67Dc8CfffD00D01D02D03D04D05D06D07D0dD0eD0fD10D11D12D13D14D15D16D17D1eD1fD20D21D22D25D26D27D2fD30D31D35D36D37D38D3fD40D46D47D48D49D4aD50D57D58D59D5aD5bD68D69D6aD6bD78D79D7aD7bD7cD88D89D8aD8bD8cD90D91D95D96D97D98D99D9aD9bD9cDa0Da1Da6Da7Da8Da9DaaDabDb0Db1Db7Db8Db9DbaDbbDc0Dc1Dc2Dc9Dd0Dd1Dd2DdfDe0De1De2De3DeeDefDf0Df1Df2Df3Df4DfeDff"{
     reloadImageAction();
}

macro "Reload Image (f7) Action Tool Options" {
      showIOSettings();
}

macro "Open File [f8]" {
	openFile();
}

macro "Open File (f8) Action Tool - C000D51D61D71D81D91Da1Db1Db8Db9DbaDbbDc1Dc8Dc9DcaDcbDd8Dd9DdaDdbDe2De3De4De5De6De7De8De9DeaC000D45D47D48DabC000D42D44Dd1C000D4aD4bD5bC000D46C000D43D49D6bD7bD8bD9bC000D1eDa8C000DebC000C111Dd5C111D41D55DaaC111Dd7C111D1dD2eC222D57D58Da9C222De1C222D15D16D17D18D19D1aD1bD1cD3eD4eD5eD65D6eD75D7eD85D8eD95D9eDa5DaeDb5Dc5C222Dd4C222C333D14D54DbeC333D98C333Dd2C333Dc7C333D32D33D34D35D36D37D38D39D3aD5cD67D68D6cD77D78D7cD87D88D8cD97D9cDa7DacDb7DbcDccDdcC333C444D52C444D06D0aDf6C444D05D07D08D09D0bD0cD0dD2fD3fD4fD5fD60D6fD70D7fD80D8fD90D9fDa0DafDb0Dc0Df3Df4Df5Df7Df8Df9C444D5aDfaC444D3bC444D50C555Df2C555D4cC555D04DbfC555Dd0C555D1fDc4C555Dd6C555D64D74D84D94Da4Db4C555D0eC555C666DecC666D56C666Dd3C666C777Dc2C777D31C777D62D72D82D92Da2Db2C777D9aC777D59C777D53C777C888D6aD7aD8aC888DfbC888C999D40C999CaaaDf1CaaaCbbbD13DceCbbbDe0CbbbD2dCbbbDc6CbbbD03DcfCbbbCcccD3cCcccD25D26D27D28D29D2aD5dD66D6dD76D7dD86D8dD96D9dDa6DadDb6CcccD0fCcccD24DbdCcccD99CcccD2bCcccD4dCcccCdddD23D2cDcdCdddD3dCdddDfcCeeeD22D69D79D89Dc3DddCeeeD30CeeeD63D73D83D93Da3Db3CeeeDedCfffD21Df0CfffD20DfdCfffD00D01D02D10D11D12DdeDdfDeeDefDfeDff"{
	openFile();
}

macro "Open File (f8) Action Tool Options" {
    showIOSettings();
}

function showIOSettings() {
    // Create options with dialog
}

function getFiles() {
     list = getFileList(DIRECTORY1);
     FILES = newArray(0);
     for (i=0; i<list.length; i++) {
     	file = list[i];
     	if (endsWith(file, EXT)) {
     		FILES = Array.concat(FILES, file);
     	}
     }
     return FILES;
}

function setFolders() {
	currentFile = 0;
	DIRECTORY1 = getDirectory("Choose folder A: ");
	DIRECTORY2 = getDirectory("Choose folder B: ");
	getFiles();
	loadCurrentImage();
}

function loadCurrentImage() {
    if (nImages>0 && CLOSE_LAST_IMAGES) {
    	selectImage(IMAGE_A);
    	close();
    	selectImage(IMAGE_B);
    	close();
    }
    if (FILES.length<1) return;
    file = FILES[currentFile];
    run("Bio-Formats Importer", "open=["+DIRECTORY1+"/"+file+"] color_mode=Default view=["+VIEW_OPTION+"] stack_order=XYCZT");
    enhanceDisplay();
    IMAGE_A = getImageID();
    run("Bio-Formats Importer", "open=["+DIRECTORY2+"/"+file+"] view=["+VIEW_OPTION+"]");
    enhanceDisplay();
    IMAGE_B = getImageID();
    run("Tile");
}

function enhanceDisplay() {
    Stack.getDimensions(width, height, channels, slices, frames)
    if (channels==1)
    	run("Enhance Contrast", "saturated=0.35");
    else { 
	    for (i=1; i<=channels; i++) {
	           Stack.setChannel(i);
	           run("Enhance Contrast", "saturated=0.35");
	    }
	    Stack.setChannel(1);
    }
}

function showImageStatus() {
      showStatus("Image " + (currentFile+1) + " of " + FILES.length);
}

function showHelp() {
    run('URL...', 'url='+helpURL);
}

function firstImageAction() {
      if (FILES.length>0) {
               if (currentFile!=0) {
                    currentFile = 0;
                    loadCurrentImage();
               }
      }
     showImageStatus();
} 

function previousImageAction() {
      if (FILES.length>0) {
             if (currentFile!=0) {
                   if (currentFile>0) currentFile--;
                   else currentFile=0;
                   loadCurrentImage();
            }
      }
      showImageStatus();
}

function nextImageAction() {
      if (FILES.length>0) {
               if (currentFile!=FILES.length-1) {
                   if (currentFile<FILES.length-1) currentFile++;
                   else currentFile = FILES.length-1;
                   loadCurrentImage();
              }
      }
      showImageStatus();
}

function lastImageAction() {
      if (FILES.length>0) {
               if (currentFile!=FILES.length-1) {
                   currentFile = FILES.length-1;
                   loadCurrentImage();
               }
      }
      showImageStatus();
}

function reloadImageAction() {
        if (FILES.length>0) {
        	if (currentFile<0 || currentFile>=FILES.length) currentFile = 0;
                        loadCurrentImage();
         }	
         showImageStatus();
}

function openFile() {
	path = File.openDialog("Choose a file!");
	dir = File.getParent(path) + File.separator;
	file = File.getName(path);
	if (!((dir==DIRECTORY1) || (dir==DIRECTORY2))) return;
	index = -1;
	for (i=0; i< FILES.length; i++) {
		current = FILES[i];
		if (current == file) {
			index = i;
		}
	}
	if (index<0) return;
	currentFile = index;
	reloadImageAction();
}
