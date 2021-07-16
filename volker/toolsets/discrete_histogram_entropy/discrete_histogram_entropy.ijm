/**
  * discrete_histogram_entropy.ijm
  * 
  * Calculates the discrete histogram entropy
  * 
  * The macro has originally be intended to be used with the histogram of directions
  * created by the Directionality plugin. 
  * 
  * It can be used on an image or on a histogram table.
  *   
  * (c) 2019-2021, INSERM
  * 
  * written by Volker Baecker at Montpellier Ressources Imagerie (www.mri.cnrs.fr)
  *
  * USAGE WITH DIRECTIONALITY:
  *  Run the Directionality plugin (see https://imagej.net/Directionality) on your image
  *  Select "Display table" in the dialog. Activate the results table containing for each direction
  *  the normalized frequency of the data and the fit. Run the macro. The discrete histogram entropy 
  *  is written to a table.
  *  
  */
var _NBINS = 256;
var _DELTA = 0.001;
var _VALUE_COLUMN = "bin start";
var _COUNT_COLUMN = "count";
var _AUTO = true;
var _LOG_CHOICES = newArray("log_2", "log_e", "log_10");
var _LOG = "log_e";


var helpURL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Discrete_Histogram_Entropy_Tool";

autoHistogramEntropy();
exit();

macro "Discrete Histogram Entropy (f5)" {
	autoHistogramEntropy();
}

macro "Discrete Histogram Entropy (f5) Action Tool - CeefD10CfccL2030CccfL7080CfdeDc0CfccDd0CfdeDe0D01Ce56D11Cb46L2131Ce9aD41C44eD61C43cL7181C77dD91CfccDb1Ce56Lc1e1CfccDf1D02Cb46D12Ce11L2232Ce56D42CfdeD52C43cD62C44eL7282C43cD92CccfDa2Ce9aDb2Ce11Lc2e2Ce9aDf2CfccD03Cb46D13Ce11L2333Ce9aD43CeefD53Cb46D63C11dL7383C43cD93CeefDa3Ce9aDb3Cb46Dc3Ce11Dd3Cb46De3Ce9aDf3CfccD14Ce56D24Ce9aD34CfdeD44CeefD64C44eD74C77dD84CccfD94Ce9aDc4Ce56Dd4Ce9aDe4CfdeL2535CeefD75CccfD85CfdeDc5CfccDd5CfdeDe5C77dD16C43cL2636CccfD46D66C43cL7686C77dD96CfccDb6Ce56Dc6Cb46Dd6Ce56De6CfccDf6CccfD07C11dD17C44eD27C11dD37C77dD47CeefD57C43cD67C44eL7787C43cD97CccfDa7Ce9aDb7Ce11Lc7e7Ce9aDf7CccfD08C43cD18C11dL2838C77dD48D68C11dL7888C43cD98CfdeDa8Ce9aDb8Ce56Dc8Ce11Dd8Cb46De8Ce9aDf8CccfD19Cb46D29C77dD39CeefD49CccfD69C77dD79Cb46D89CccfD99CfdeDb9Ce9aDc9Ce56Dd9Ce9aDe9CccfD2aCeefD3aCfdeL7a8aCeefDcaCfdeDdaCeefDeaC44eD1bC43cD2bCb46D3bCccfD4bCfccD6bCe56D7bCb46D8bCe9aD9bCeefDbbC77dDcbC43cDdbC77dDebCccfD0cC11dD1cC44eD2cC11dD3cC77dD4cCfdeD5cCe56D6cCe11L7c8cCb46D9cCfccDacC44eDbcC11dDccC44eDdcC11dDecC44eDfcCccfD0dC11dD1dC44eD2dC11dD3dC77dD4dCeefD5dCe56D6dCe11L7d8dCb46D9dCfccDadC44eDbdC11dDcdC44eDddC11dDedC44eDfdD1eC43cD2eCb46D3eCccfD4eCfccD6eCe56L7e8eCe9aD9eC77dDceC43cDdeC77dDeeCeefL2f3fD8f" {
	autoHistogramEntropy();
}

macro "Discrete Histogram Entropy (f5) Action Tool Options" {
	Dialog.create("Options DHE");
	Dialog.addNumber("number of bins: ", _NBINS);
	Dialog.addNumber("epsilon: ", _DELTA);
	Dialog.addString("bin column: ", _VALUE_COLUMN);
	Dialog.addString("counts column: ", _COUNT_COLUMN);
	Dialog.addCheckbox("auto", _AUTO);
	Dialog.addRadioButtonGroup("base of logarithm: ", _LOG_CHOICES, 1, 3, _LOG);
	Dialog.addHelp(helpURL);
	Dialog.show();
	_NBINS = Dialog.getNumber();
	_DELTA = Dialog.getNumber();
	_VALUE_COLUMN = Dialog.getString();
	_COUNT_COLUMN = Dialog.getString();
	_AUTO = Dialog.getCheckbox();
	_LOG = Dialog.getRadioButton();
}

/**
 * Run the calculation on an image, a histogram results table or
 * the Directionality results table.
 */
function autoHistogramEntropy() {
	winType = getInfo("window.type");
	title = getInfo("window.title");
	if (winType=='Image') {
		entropy = imageEntropy();
		displayResult(title, entropy);
		return entropy;
	} 
	if (indexOf(title, 'Directionality histograms')>=0) {
		entropy = directonalityEntropy();
		displayResult(title, entropy);
		return entropy;
	}
	valueColumn = _VALUE_COLUMN;
	countColumn = _COUNT_COLUMN;
	if (_AUTO) {
		countColumn = 'count';
		headings = Table.headings;
		valuesColumn = "index";
		if (indexOf(headings, 'bin start')>=0) {
			valuesColumn = "bin start";
		}
	}
	entropy = histogramEntropy(title, valuesColumn, countColumn);
	displayResult(title, entropy);
	return entropy;
}

/**
 * Report the discrete histogram entropy in a table.
 */
function displayResult(title, entropy) {
	tableTitle = "Discrete-Histogram-Entropy";
	if (!isOpen(tableTitle)) Table.create(tableTitle);
	index = Table.size(tableTitle);
	Table.set('image', index, title, tableTitle);
	Table.set('entropy', index, entropy, tableTitle);	
}

/**
 * Calculate the discrete histogram entropy from a table.
 * 
 * Normalize the counts if necessary.
 */
function histogramEntropy(title, columnValues, columnCounts) {
	values = Table.getColumn(columnValues, title);
	counts = Table.getColumn(columnCounts, title);
	sum = sumArray(counts);
	diffFromOne = abs(sum-1);
	if (diffFromOne>_DELTA) {
		normalizeArray(counts);
	}
	entropy = discreteHistogramEntropy(values, counts);	
	return entropy;
}

/**
 * Calculate the discrete histogram entropy from an image.
 */
function imageEntropy() {
	imageTitle = getTitle();
	getHistogram(values, counts, _NBINS);
	sum = sumArray(counts);
	diffFromOne = abs(sum-1);
	if (diffFromOne>_DELTA) {
		normalizeArray(counts);
	}
	entropy = discreteHistogramEntropy(values, counts);
	return entropy;
}

/**
 * Normalize the values in anArray, so that their sum is equal to one.
 */
function normalizeArray(anArray) {
	sum = sumArray(anArray);
	for (i = 0; i < anArray.length; i++) {
		anArray[i] /= sum;
	}
}

/**
 * Return the sum of all values in the array.
 */
function sumArray(anArray) {
	sum = 0;
	for (i = 0; i < anArray.length; i++) {
		sum += anArray[i];
	}
	return sum;
}

/**
 * Calculate the discrete histogram entropy from the histogram table of the 
 * Directonality plugin.
 */
function directonalityEntropy() {
	content = getInfo("window.contents");
	lines = split(content, "\n");
	line0 = split(lines[0],"\t");
	imageTitle = line0[1];
	directions = newArray(lines.length-1);
	frequencies = newArray(lines.length-1);
	for (i = 1; i < lines.length; i++) {
		line =  split(lines[i],"\t");
		directions[i-1] = parseFloat(line[0]);
		frequencies[i-1] = parseFloat(line[1]);
	}	
	entropy = discreteHistogramEntropy(directions, frequencies);
	return entropy;
}

/**
 * Calculate the discrete histogram entropy from the bin size and
 * the frequencies, i.e. normalized count values.
 * 
 * @param bins	the starts of the bins of the histogram
 * @param frequencies  the normalized count values of the histogram
 * @return the discrete histogram entropy
 */
function discreteHistogramEntropy(bins, frequencies) {

	binWidth = abs(bins[0]-bins[1]);
	
	entropy = 0;
	for(i=0; i<bins.length; i++) {
		if (frequencies[i]>0) {
			logValue = log(frequencies[i]/binWidth);
			if (_LOG=="log_2") {
				logValue = logValue/log(2);
			}
			if (_LOG=="log_10") {
				logValue = logValue/log(10);
			}
			entropy += frequencies[i] * logValue;
		}
	}
	
	entropy *= -1;
	return entropy;
}

/**
 * Apply the discrete histogram entropy as an image filter.
 * 
 * Not used in the macro-tool
 */
function entropyFilter(radius) {
	imgWidth = getWidth();
	imgHeight = getHeight();
	imageID = getImageID();
	run("Duplicate...", " ");
	run("32-bit");
	outID = getImageID();
	width = (2 * radius) + 1;
	setBatchMode(true);
	for (i = 0; i < imgWidth; i++) {
		for (j = 0; j < imgHeight; j++) {
			selectImage(imageID);
			makeRectangle(i-radius, j-radius, width, width);
			entropy = imageEntropy();
			selectImage(outID);
			setPixel(i, j, entropy);
		}
	}
	setBatchMode(false);
	selectImage(imageID);
	run("Select None");
	selectImage(outID);
}
