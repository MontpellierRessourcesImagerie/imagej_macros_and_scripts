/***
 * 
 * MRI Random Selection From Table Tool
 * 
 * The tool allows to create a sub-population of your data by randomly copying a configurable portion of lines from the active table to a new table. 
 * 
 * (c) 2021, INSERM
 * 
 * written by Volker Baecker at Montpellier Ressources Imagerie, Biocampus Montpellier, INSERM, CNRS, University of Montpellier (www.mri.cnrs.fr)
 * 
**/

var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Random_Selection_From_Table_Tool";
var _PORTION = 20

macro "MRI Random Selection From Table Tool help [f4]" {
	run('URL...', 'url='+helpURL);
}

macro "MRI Random Selection From Table Tool (f4) Action Tool - CfffL0050CcccD60C888L7080CcccD90CfffLa0f0L0121CeeeD31CbbbD41C555D51C222D61C333L7181C222D91C555Da1CbbbDb1CeeeDc1CfffLd1f1D02CcccD12C888D22C333D32C222D42C666D52CbbbD62CeeeL7282CbbbD92C666Da2C222Db2C333Dc2C888Dd2CcccDe2CfffDf2C888D03C111L1323C666D33CcccD43CfffL5363C888L7383CfffL93a3CcccDb3C666Dc3C111Ld3e3C888Df3C666D04C111D14C333D24C222D34C333D44C999D54CcccD64C999L7484CcccD94C999Da4C333Db4C222Dc4C333Dd4C111De4C666Df4L0515CeeeD25CbbbD35C777D45C333D55C222D65C333L7585C222D95C333Da5C777Db5CbbbDc5CeeeDd5C666Le5f5L0616CfffL2646CeeeD56CcccD66C333L7686CcccD96CfffLa6d6C666Le6f6L0717CfffL2737CbbbD47C777D57CfffD67C666L7787CfffL97d7C666Le7f7L0818CfffL2838CbbbD48C666D58CfffD68C666L7888CfffL98a8CeeeDb8C333Dc8CbbbDd8C666Le8f8L0919CbbbD29C555D39CeeeL4959CfffD69C666L7989CcccD99C555Da9CcccDb9C888Dc9CcccDd9C666Le9f9L0a1aCcccD2aC888D3aCeeeD4aC333D5aC999D6aC666L7a8aCcccD9aC777DaaCeeeDbaCfffLcadaC666LeafaL0b1bCfffL2b4bC999D5bCeeeD6bC666L7b8bCfffL9bdbC666LebfbD0cC222D1cC999D2cCcccD3cCfffL4c6cC666L7c8cCfffL9cbcCcccDccC999DdcC222DecC666DfcCcccD0dC777D1dC333D2dC222D3dC333D4dC888D5dCcccD6dC555L7d8dCcccD9dC888DadC333DbdC222DcdC333DddC777DedCcccDfdCfffL0e2eCcccD3eC777D4eC333D5eC222D6eC111L7e8eC222D9eC333DaeC777DbeCcccDceCfffLdefeL0f5fCcccD6fC888L7f8fCcccD9fCfffLafff"{
	copyRandomLines(_PORTION);
}

macro "MRI Random Selection From Table Tool (f4) Action Tool Options" {
	Dialog.create("Random Selection Options");
	Dialog.addNumber("Portion of the lines to be copied: ", _PORTION);
	Dialog.addHelp(helpURL);
	Dialog.show();
	_PORTION = Dialog.getNumber();
}


function copyRandomLines(portion) {
	title = getInfo("window.title");
	type = getInfo("window.type");
	
	if (type!="ResultsTable") {
		showMessage("Please select a table!");
		return;
	}
	
	N  = round((Table.size(title) * portion) / 100);
	
	lines = newArray(0);
	pool = Array.getSequence(N);
	
	for(i=0; i<N; i++) {
		length = pool.length;
		index = floor(random*length);
		line = pool[index];
		lines = Array.concat(lines, line+1);
		Array.deleteIndex(pool, index);
	}
	newTitle = "" + portion + "% random lines from " + title;
	Table.create(newTitle);
	for (i = 0; i < lines.length; i++) {
		index = lines[i];
		headings = Table.headings(title);
		columns = split(headings, "\t");
		for(c=0; c<columns.length; c++) {
			column = columns[c];
			if (column==" ") continue;
			value = Table.get(column, index, title);
			Table.set(column, i, value, newTitle);
		}
	}
}
