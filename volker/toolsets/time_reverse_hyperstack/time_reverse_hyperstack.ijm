/**
  * Time-Reverse Hyperstack
  *
  * Reverse the order of the frames of a hyperstack.
  * 
  * (c) 2021, INSERM
  * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
  *
 **/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Time_Reverse_Hyperstack_Tool";

macro "time reverse hyperstack Action Tool (f2) - CfffL00f0L0141CdddD51CbbbL6181CdddD91CfffLa1f1L0212CcccD22CbbbD32C555D42C222L5292C555Da2CbbbDb2CfffLc2f2L0313C555D23C111D33C555D43CbbbD53CdddD63CeeeD73CdddD83CbbbD93C666Da3C333Db3CeeeDc3CfffLd3f3L0414C888D24C555D34CdddD44CfffD54CcccD64CbbbD74CcccD84CeeeD94CfffDa4CdddDb4CfffLc4f4L0535CbbbD45C555D55C111L6585C333D95CbbbDa5CfffLb5f5L0626CbbbD36C222L4656C888D66CbbbD76C888D86C333D96C111Da6C999Db6CfffLc6f6L0717CeeeD27C333D37C222D47CcccL5767C555D77CdddD87CeeeD97C555Da7C222Db7CdddDc7CfffLd7f7L0818CcccD28C111D38C888D48CfffD58CcccD68C222D78CcccD88CfffD98CbbbDa8C111Db8C999Dc8CfffLd8f8L0919CbbbD29C111D39CcccD49CfffD59CcccD69C111D79C333D89C555D99CbbbDa9C222Db9C888Dc9CfffLd9f9L0a1aCbbbD2aC111D3aCbbbD4aCfffD5aCeeeD6aC888L7a8aC999D9aCbbbDaaC111DbaC888DcaCfffLdafaL0b1bCeeeD2bC222D3bC555D4bCeeeD5bCfffL6b9bC666DabC111DbbCcccDcbCfffLdbfbL0c2cC888D3cC111D4cC666D5cCcccD6cCeeeD7cCcccD8cC666D9cC111DacC666DbcCfffLccfcL0d3dC888D4dC222D5dC111D6dC222D7dC111L8d9dC666DadCeeeDbdCfffLcdfdL0e4eCcccD5eC888D6eC666D7eC888D8eCcccD9eCfffLaefeL0fff" {
	reverseHyperstack();
}

macro "time reverse hyperstack [f2]" {
	reverseHyperstack();
}


macro "time reverse hyperstack Action Tool (f2) Options" {
	Dialog.create("Time-reverse hyperstack Help");
	Dialog.addMessage("The tool reverses the frames in a hyperstack.");
	Dialog.addMessage("Press the help button below to open the online help!");
	Dialog.addHelp(helpURL);
	Dialog.show();
}

function reverseHyperstack() {
	setBatchMode("hide");
	Stack.getDimensions(width, height, channels, slices, frames);
	title = getTitle();
	sourceID = getImageID();
	bd = bitDepth();
	newImage("tmp", ""+bd+"-bit composite-mode", width, height, channels, slices, frames);
	targetID = getImageID();
	for (t = 0; t < frames; t++) {
		tSource = t+1;
		tTarget =  frames-t;
		for(c=1; c<=channels; c++) {
			for(z=1; z<=slices; z++) {
				selectImage(sourceID);
				Stack.setPosition(c, z, tSource);
				run("Copy");
				selectImage(targetID);
				Stack.setPosition(c, z, tTarget);
				run("Paste");
			}
		}
	}
	for(c=1; c<=channels; c++) {
		selectImage(sourceID);
		Stack.setChannel(c);
		getMinAndMax(min, max);
		selectImage(targetID);
		Stack.setChannel(c);
		setMinAndMax(min, max);
	}
	selectImage(sourceID);
	close();
	setBatchMode("show");
	selectImage(targetID);
	rename(title);
	run("Select None");
	Stack.setPosition(1, 1, 1);
}	
