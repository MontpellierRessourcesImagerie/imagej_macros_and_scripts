var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Qualify_DAB_Tools ";
var _ORDER_X = 2;
var _ORDER_Y = 2;
var _ORDER_MIXED = 1;
var _R1 = 0.268;
var _G1 = 0.57;
var _B1 = 0.78;
var _R2 = 0.65;
var _G2 = 0.70;
var _B2 = 0.29;
var _R3 = 0.71;
var _G3 = 0.42;
var _B3 = 0.56;
var _THRESHOLDING_METHOD_SHADING = "Yen";
var _THRESHOLDING_METHODS = getList("threshold.methods");
var _REGION_4_UPPER_LIMIT = 60;
var _REGION_3_UPPER_LIMIT = 120;
var _REGION_2_UPPER_LIMIT = 180;
var _REGION_1_UPPER_LIMIT = 235;

macro "MRI QualifyDAB Tools Help Action Tool - C000T4b12?"{
    run('URL...', 'url='+helpURL);
}


macro "open ndpi-tiff image [f8]" {
  openFile();
}

macro "open ndpi tiff image (f8) Action Tool - C000T4b12o"{
    openFile();
}

macro "correct shading [f9]" {
	shadingCorrection();
}

macro"correct shading (f9) Action Tool - C000T4b12s" {
	 shadingCorrection();
}

macro "correct shading (f9) Action Tool Options" {
	 Dialog.create("Correct Shading Options");
	 Dialog.addNumber("order x", _ORDER_X);
	 Dialog.addNumber("order y", _ORDER_Y);
	 Dialog.addNumber("order mixed", _ORDER_MIXED);
	 Dialog.addChoice("thresholding method: ", _THRESHOLDING_METHODS, _THRESHOLDING_METHOD_SHADING);
 	 Dialog.show();
 	 _ORDER_X = Dialog.getNumber();
 	 _ORDER_Y = Dialog.getNumber();
 	 _ORDER_MIXED = Dialog.getNumber();
 	 _THRESHOLDING_METHOD_SHADING = Dialog.getChoice();
}

macro "colour deconvolution [f10]" {
	colourDeconvolution();
}

macro "colour deconvolution (f10) Action Tool - C000T4b12c" {
	colourDeconvolution();
}

macro "colour deconvolution (f10) Action Tool Options" {
	 Dialog.create("Colour Deconvolution Options");
	 Dialog.addNumber("R1", _R1);
	 Dialog.addNumber("G1", _G1);
	 Dialog.addNumber("B1", _B1);
	 Dialog.addNumber("R2", _R2);
	 Dialog.addNumber("G2", _G2);
	 Dialog.addNumber("B2", _B2);
	 Dialog.addNumber("R3", _R3);
	 Dialog.addNumber("G3", _G3);
	 Dialog.addNumber("B3", _B3);
 	 Dialog.show();
 	 _R1 = Dialog.getNumber();
 	 _G1 = Dialog.getNumber();
 	 _B1 = Dialog.getNumber();
 	 _R2 = Dialog.getNumber();
 	 _G2 = Dialog.getNumber();
 	 _B2 = Dialog.getNumber();
 	 _R1 = Dialog.getNumber();
 	 _G2 = Dialog.getNumber();
 	 _B3 = Dialog.getNumber();
}

macro "colour threshold [f11]" {
	colourThreshold();
}

macro "colour threshold (f11) Action Tool - C000T4b12t" {
	colourThreshold();
}

macro "run ihc profiler [f4]" {
	runIHCProfiler();
}

macro "run ihc profiler (f4) Action Tool - C000T4b12r" {
	runIHCProfiler();
}

macro "run ihc profiler (f4) Action Tool Options" {
	 Dialog.create("Run IHC profiler Options");
	 Dialog.addNumber("region 4 upper limit: ", _REGION_4_UPPER_LIMIT);
	 Dialog.addNumber("region 3 upper limit: ", _REGION_3_UPPER_LIMIT);
	 Dialog.addNumber("region 2 upper limit: ", _REGION_2_UPPER_LIMIT);
	 Dialog.addNumber("region 1 upper limit: ", _REGION_1_UPPER_LIMIT);
 	 Dialog.show();
 	 _REGION_4_UPPER_LIMIT = Dialog.getNumber();
 	 _REGION_3_UPPER_LIMIT = Dialog.getNumber();
 	 _REGION_2_UPPER_LIMIT = Dialog.getNumber();
 	 _REGION_1_UPPER_LIMIT = Dialog.getNumber();
}

function openFile() {
	path = File.openDialog("Select an NDPI-tiff file");
	run("Open TIFF...", "ndpitools=["+path+"]");
}

function shadingCorrection() {
	imageID = getImageID();
	run("Duplicate...", " ");
	run("8-bit");
	setAutoThreshold(_THRESHOLDING_METHOD_SHADING + " dark");
	run("Create Selection");
	close()
	selectImage(imageID);
	run("Restore Selection");
	run("Fit Polynomial", "x="+_ORDER_X+" y="+_ORDER_Y+" mixed="+_ORDER_MIXED);
	run("Select None");
}

function colourDeconvolution() {
	run("Colour Deconvolution", "vectors=[User values] [r1]="+_R1+" [g1]="+_G1+" [b1]="+_B1+" [r2]="+_R2+" [g2]="+_G2+" [b2]="+_B2+" [r3]="+_R3+" [g3]="+_G3+" [b3]="+_B3);
}

function colourThreshold() {
	run("Color Threshold...");
}

function runIHCProfiler() {
	// This is the code copied and modified from the IHC profiler, see 
	// http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0096801
	// by Varghese F, Bukhari AB, Malhotra R, De A (2014)
	// The modification allows to change the borders of the regions.

	  bins = 256;
	  maxCount = 0;
	  histMin = 0;
	  histMax = 0;
	
	  if (histMax>0)
	  	getHistogram(values, counts, bins, histMin, histMax);
	  else
	  	getHistogram(values, counts, bins);
	  
	  is8bits = bitDepth()==8 || bitDepth()==24;
	  
	  Plot.create("Histogram", "Pixel Value", "Count", values, counts);
	  
	  if (maxCount>0)
	  	Plot.setLimits(0, 256, 0, maxCount);
	
	  n = 0;
	  sum = 0;
	  min = 9999999;
	  max = -9999999;
	  Region2=0;
	  Region3=0;
	  Region4=0;
	  Region1=0;
	  Region0=0;
	  TotalPixel=0;
	  PercentRegion1=0;
	  PercentRegion2=0;
	  PercentRegion4=0;
	  PercentRegion3=0;
	  PercentRegion0=0;
	  Score=0;
	  PixelUnderConsideration=0;
	
	  for (i=0; i<bins; i++) 
		{
	         count = counts[i];
	         if (count>0) 
			{
	          	 n += count;
	          	 sum += count*i;
	          	 if (i<min) min = i;
	          	 if (i>max) max = i;
	                }
	  	}
	
	  var x=0.025, y=0.1; // global variables
	  
	  print("Pixel Count: "+n);
	  
	  if (is8bits)
	  	{
		 for (i=0; i<bins; i++)
			{
		         if (i>=0 && i<_REGION_4_UPPER_LIMIT+1)
		   	      Region4=Region4+counts[i];
		 	 if (i>_REGION_4_UPPER_LIMIT && i<_REGION_3_UPPER_LIMIT+1)	
	          	      Region3=Region3+counts[i];
		  	 if (i>_REGION_3_UPPER_LIMIT && i<_REGION_2_UPPER_LIMIT+1)	
	          	      Region2=Region2+counts[i];
		  	 if (i>_REGION_2_UPPER_LIMIT && i<_REGION_1_UPPER_LIMIT+1)	
	          	      Region1=Region1+counts[i];
	          	 if (i>_REGION_1_UPPER_LIMIT && i<=256)	
	          	      Region0=Region0+counts[i];
	  		}
		 }
	
	  function draw(text) 
		 {
	  	  Plot.addText(text, x, y);
	          y += 0.08;
	  	 }
	  
	  TotalPixel=TotalPixel+Region1+Region2+Region3+Region4+Region0;
	  
	  PixelUnderConsideration=TotalPixel-Region0;
	  
	  PercentRegion3=(Region3/PixelUnderConsideration)*100; 
	  
	  PercentRegion2=(Region2/PixelUnderConsideration)*100;
	  
	  PercentRegion1=(Region1/PixelUnderConsideration)*100;
	  
	  PercentRegion4=(Region4/PixelUnderConsideration)*100;
	  
	  print("Percentage contibution of High Positive:  "+PercentRegion4);
	  
	  print("Percentage contibution of Positive:  "+PercentRegion3);
	  
	  print("Percentage contibution of Low Positive:  "+PercentRegion2);
	
	  print("Percentage contibution of Negative:  "+PercentRegion1);
	
	  if((PercentRegion3>66)||(PercentRegion2>66)||(PercentRegion1>66)||(PercentRegion4>66))
		{
		 if(PercentRegion4>66)
	              print("The score is High Positive  ");
	         if(PercentRegion3>66)
	              print("The score is Positive  ");
	         if(PercentRegion2>66)
	              print("The score is Low Positive  "); 
	         if(PercentRegion1>66)
	              print("The score is Negative  ");
	        }
	
	  else
		{
	         Score=Score+(PercentRegion4/100)*4+(PercentRegion3/100)*3+(PercentRegion2/100)*2+(PercentRegion1/100)*1;  
	      
	      	 if(Score>=2.95)
			{    
	           	 print("The score is High Positive  ");
	        	}
	     	 if((Score>=1.95) && (Score<=2.94))
			{
	           	 print("The score is Positive  ");
	        	}
	      	 if((Score>=0.95) && (Score<=1.94))
			{
	            	 print("The score is Low Positive  ");
	        	}
	     	 if((Score>=0.0) && (Score<=0.94))
			{
	            	 print("The score is Negative  ");
	       		}
	      
	    	}

}

