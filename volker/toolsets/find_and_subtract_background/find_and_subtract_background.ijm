/**
 * Find the background intensity value and subtract it from the current image.
 * 
 * Search for the maximum intensity value around pixels that are below or equal
 * to the minimum intensity plus an offset in the image.
 * 
 * (c) 2020, INSERM
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 */
var _SUBTRACT_BACKGROUND_RADIUS = 1;
var _SUBTRACT_BACKGROUND_OFFSET = 1;
var _SUBTRACT_BACKGROUND_ITERATIONS = 2;
var _SKIP_LIMIT = 0.3
var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Find_and_Subtract_Background_Tool";

findAndSubtractBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS, _SKIP_LIMIT);
exit();

macro "Find and Subtract Background [f5]" {
	findAndSubtractBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS, _SKIP_LIMIT);	
}

macro "Find and Subtract Background (f5) Action Tool - C00eD00C00aD10C00bL2030C009D40C006D50C008D60C00cD70C00eD80C009D90C00bDa0C00eDb0C00dDc0C00aDd0C00dDe0C00bDf0C009D01C00aL1121C009D31C00aL4151C009D61C00bD71C115D81C004D91C009Da1C007Db1C00eDc1C00cDd1C009De1C008Df1C00aD02C009L1222C006D32C119D42C117D52C113D62C114D72C112D82C004D92C006Da2C002Db2C006Dc2C008Dd2C118De2C008Df2D03C00bD13C00aD23C117D33C446D43C444D53C112D63C113D73C114D83C113D93C115Da3C114Db3C005Dc3C117Dd3C009De3C007Df3C006D04C008D14C006D24C116D34C223D44C444D54C555D64C444L7484C333L94a4C224Db4C114Dc4C113Dd4C007De4C005Df4C116D05C006D15C114D25C113D35C666D45CaaaD55CbbbD65CcccD75CaaaL85a5C888Db5C555Dc5C223Dd5C004De5C008Df5C115D06C004D16C115D26C444D36CaaaD46CcccD56CdbbD66CeccD76CdddD86CdccD96CbbbLa6c6C555Dd6C113De6C005Df6C115D07C007D17C227D27C889D37CcccL4757CdccD67CeccL7787Cf99D97CeccDa7Cd99Db7CdccDc7C777Dd7C115De7C006Df7C00bD08C00aD18C557D28CcccL3848CcbbD58CdbbD68CeccD78CeddD88CfccD98CfddDa8CeccLb8c8C777Dd8C116De8C003Df8C00cD09C117D19C555D29CbbbD39CcccD49CcbbL5979CdbbD89CcccD99CeeeDa9CcccLb9c9C444Dd9C005De9C006Df9C009D0aC007D1aC222D2aC888D3aCbbbD4aCcbbD5aCcccD6aCaaaD7aC988D8aC888D9aC999DaaC777DbaC666DcaC114LdaeaC007DfaC009L0b1bC005D2bC223D3bC444D4bC777D5bC888D6bC555D7bC225D8bC223D9bC225DabC115DbbC112DcbC007DdbC005DebC007DfbC006L0c1cC007D2cC005D3cC116D4cC113L5c6cC115D7cC006D8cC002D9cC005DacC007DbcC112DccC00aDdcC008DecC007DfcC00aD0dC007L1d2dC008D3dC115D4dC008D5dC115L6d7dC005D8dC004D9dC005DadC116DbdC004DcdC116DddC00bDedC00eDfdC00bL0e1eC007L2e3eC005D4eC008L5e6eC007D7eC006L8e9eC005DaeC117DbeC007DceC00aDdeC00dDeeC00fDfeC00dD0fC00aD1fC009D2fC007D3fC008D4fC119D5fC009D6fC006D7fC007D8fC009D9fC00bDafC009DbfC00eLcfdfC00bDefC00eDff" {
	findAndSubtractBackground(_SUBTRACT_BACKGROUND_RADIUS, _SUBTRACT_BACKGROUND_OFFSET, _SUBTRACT_BACKGROUND_ITERATIONS, _SKIP_LIMIT);
}

macro "Find and Subtract Background (f5) Action Tool Options" {
	Dialog.create("Options FaSB");
	Dialog.addNumber("radius:", _SUBTRACT_BACKGROUND_RADIUS);
	Dialog.addNumber("offset:", _SUBTRACT_BACKGROUND_OFFSET);
	Dialog.addNumber("iterations:", _SUBTRACT_BACKGROUND_ITERATIONS);
	Dialog.addNumber("skip limit:", _SKIP_LIMIT);
	Dialog.addHelp(helpURL);
	Dialog.show();
	_SUBTRACT_BACKGROUND_RADIUS = Dialog.getNumber();
	_SUBTRACT_BACKGROUND_OFFSET = Dialog.getNumber();
	_SUBTRACT_BACKGROUND_ITERATIONS = Dialog.getNumber();
	_SKIP_LIMIT = Dialog.getNumber();	
}

/**
 * Find the background intensity value and subtract it from the current image.
 * 
 * Search for the maximum intensity value around pixels that are below or equal
 * to the minimum intensity plus an offset in the image.
 * 
 * @param radius The radius in which the maximum around the small values is searched
 * @param offset The intensity offset above the minimum intensity of the image
 * @param iterations The number of times the procedure is repeated
 * @param skipLimit The ratio of pixels with value zero above which the procedure is skipped
 * @return Nothing
 */
function findAndSubtractBackground(radius, offset, iterations, skipLimit) {
   width = getWidth();
   height = getHeight();
   getStatistics(area, mean, min, max, std, histogram);
   ratio = histogram[0] / ((width * height) * 1.0);
   if (ratio>skipLimit) {
		run("HiLo");
		run("Enhance Contrast", "saturated=0.35");
		print('find and subtract background - skipped, ratio of 0-pixel is: ' + ratio);
		return;
   }
   for(i=0; i<iterations; i++) {
       getStatistics(area, mean, min, max, std, histogram); 
       minPlusOffset =  min + offset;
       currentMax = 0;
	   for(x=0; x<width; x++) {
	   		for(y=0; y<height; y++) {
				intensity = getPixel(x,y);
				if (intensity<=minPlusOffset) {
				    value = getMaxIntensityAround(x, y, mean, radius, width, height);
				    if (value>currentMax) currentMax = value;	
				}
			}
	   }
       result = currentMax / (i+1);
       print('find and subtract background - iteration ' + (i+1) + ', value = ' + result);
       run("Subtract...", "value=" + result);
	}
    run("HiLo");
    run("Enhance Contrast", "saturated=0.35");
}

/**
 * Find the maximal intensity value below mean in the radius around x,y
 * 
 * @param x (x,y) are the coordinates around which the maximum is searched
 * @param y (x,y) are the coordinates around which the maximum is searched
 * @param mean The mean value of the image, only values below mean are considered
 * @radius The radius around (x,y) in which the maximum is searched
 * @width The width of the image 
 * @height The height of the image
 * @return The maximum value below mean around (x,y) or zero
 */
function getMaxIntensityAround(x, y, mean, radius, width, height) {
    max = 0;
    for(i=x-radius; i<=x+radius; i++) {
        if (i>=0 && i<width) {
               for(j=y-radius; j<=y+radius; j++) {
                      if (j>=0 && j<height) {
	    					value = getPixel(i,j);
                            if (value<mean && value>max)  max = value;
                      }
               }
        }
    }
    return max;
}