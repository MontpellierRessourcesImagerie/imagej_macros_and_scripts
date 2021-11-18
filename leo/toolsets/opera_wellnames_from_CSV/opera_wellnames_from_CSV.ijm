var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Opera_wellnames_from_CSV";

var _WELLNAMES_FILE = "wellNames.txt"

macro "wellNames from CSV help (f4) Action Tool - C000T4b12?"{
	run('URL...', 'url='+helpURL);
}

macro "Export to wellNames Action Tool - C000T4b12E"{
	exportWellNamesAction();
}

function exportWellNamesAction(){
	Dialog.create("Enter Input output");
	Dialog.addFile("CSV input file","");
	Dialog.addDirectory("Folder to output "+_WELLNAMES_FILE,"");

	Dialog.show();

	inputCSV = Dialog.getString();
	outputFolder = Dialog.getString();

	exportWellNames(inputCSV,outputFolder+_WELLNAMES_FILE);
}

function exportWellNames(inputCSV,outputFile){
	Table.open(inputCSV);

	tableHeadings = split(Table.headings,"\t");
	nbTableRow = Table.size;
	nbTableColumn = tableHeadings.length;

	wellNamesContent = "";
	for (row = 0; row < nbTableRow; row++) {
		for(column = 0;column < nbTableColumn;column++){
			currentValue = Table.getString(tableHeadings[column], row);
			if(isNotNull(currentValue)){
				stringToAdd = String.pad(row+1,2)+String.pad(column+1,2)+":"+currentValue+"\n";
				//print(stringToAdd);
				wellNamesContent = wellNamesContent + stringToAdd;
			}
		}
	}
	File.saveString(wellNamesContent, outputFile);
}

function isNotNull(value){
	if(value == "#N/A"){return false;}
	if(value == "NaN"){	return false;}
	if(value == ""){	return false;}
	return true;
}

exportWellNamesAction();
