var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Opera_wellnames_from_CSV";

var _WELLNAMES_FILE = "wellNames.txt";

var _ROW_OFFSET = 1;
var _COLUMN_OFFSET = 1;

macro "wellNames from CSV help (f4) Action Tool - C000T4b12?"{
	run('URL...', 'url='+helpURL);
}

macro "Export to wellNames Action Tool - C000T4b12E"{
	exportWellNamesAction();
}

macro "Export to wellNames Action Tool Options"{
	exportWellNamesOption();
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

function exportWellNamesOption(){
	Dialog.create("Export Well Names Options");
	Dialog.addMessage("Enter the offset between the top left of the sheet and the top left of the plate layout");
	Dialog.addNumber("Row Offset", _ROW_OFFSET, 0, 4, "cell");
	Dialog.addNumber("Column Offset", _COLUMN_OFFSET, 0, 4, "cell");

	Dialog.show();
	_ROW_OFFSET = Dialog.getNumber();
	_COLUMN_OFFSET = Dialog.getNumber();
}

function exportWellNames(inputCSV,outputFile){
	Table.open(inputCSV);

	tableHeadings = split(Table.headings,"\t");
	nbTableRow = Table.size;
	nbTableColumn = tableHeadings.length;

	wellNamesContent = "";
	rowOffset = _ROW_OFFSET -1;
	columnOffset = _COLUMN_OFFSET -1;
	
	for (row = rowOffset; row < nbTableRow-rowOffset; row++) {
		for(column = columnOffset;column < nbTableColumn-columnOffset;column++){
			currentValue = Table.getString(tableHeadings[column], row);
			if(isNotNull(currentValue)){
				stringToAdd = IJ.pad(row-rowOffset+1,2)+IJ.pad(column-columnOffset+1,2)+":"+currentValue+"\n";
				//stringToAdd = String.pad(row-rowOffset+1,2)+String.pad(column-columnOffset+1,2)+":"+currentValue+"\n";
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
