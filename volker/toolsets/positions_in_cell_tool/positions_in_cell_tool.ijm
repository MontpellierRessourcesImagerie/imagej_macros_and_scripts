var _NUCLEI_CHANNEL = 1;
var _SIGNAL_CHANNEL = 2;
var _MIN_NUCLEUS_SIZE =0.005;

cropCenterCell();
copyCenterOfCellSlice();

function cropCenterCell() {
	inputImageID = getImageID();
	centerX = getWidth() / 2;
	centerY = getHeight() / 2;
	
	run("Set Measurements...", "area display redirect=None decimal=9");
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+_SIGNAL_CHANNEL+"-"+_SIGNAL_CHANNEL);
	stackID = getImageID()
	run("Z Project...", "projection=[Max Intensity]");
	selectImage(stackID);
	close();
	setAutoThreshold("Li dark");
	run("Convert to Mask");
	run("Fill Holes");
	run("Analyze Particles...", "size=0.005-Infinity exclude add");
	count = roiManager("count");
	if (count==0) return false;
	minDist = getWidth()+getHeight();
	index = 0;
	for (i = 0; i < count; i++) {
		roiManager("select", i);
		getSelectionBounds(x, y, width, height);
		centerOfRoiX = x + (width/2);
		centerOfRoiY = y + (height/2);
		dist = sqrt(pow(centerX - centerOfRoiX, 2) + pow(centerY - centerOfRoiY, 2));
		if (dist<minDist) {
			minDist = dist;
			index = i;
		}
	}
	close();
	selectImage(inputImageID);
	roiManager("select", index);
	run("Crop");
	run("Select None");
	return true;
}

function copyCenterOfCellSlice() {
	inputImageID = getImageID();
	index = findCenterOfCellSlice();
	run("Duplicate...", "duplicate slices="+index+"-"+index);
	selectImage(inputImageID);
	close();
}

function findCenterOfCellSlice() {
	run("Clear Results");
	measureNucleiAreas();
	selectWindow("Results");
	areas = Table.getColumn("Area1");
	startIndex = findLeftMin(areas);
	endIndex = findRightMin(areas);
	centerIndex = findMax(areas, startIndex, endIndex);
	return centerIndex+1;
}

function measureNucleiAreas() {
	run("Set Measurements...", "area limit display redirect=None decimal=9");
	roiManager("reset");
	run("Duplicate...", "duplicate channels="+_NUCLEI_CHANNEL+"-"+_NUCLEI_CHANNEL);
	run("Convert to Mask", "method=Default background=Dark calculate");
	run("Fill Holes", "stack");
	run("Select All");
	roiManager("Add");
	roiManager("Multi Measure");
	close();
}

function findMax(values, start, end) {
	index = start;
	max = values[start];
	for(i=start+1; i<=end; i++) {
		if (values[i]>max) {
			max = values[i];
			index = i;
		}
	}
	return index;
}

function findLeftMin(values) {
	lastSlice = (values.length / 2) - 1;
	min = values[0];
	index = 0;
	for (i = 1; i < lastSlice+1; i++) {
		if (values[i]<min) {
			min = values[i];
			index = i;
		}
	}	
	return index;
}

function findRightMin(values) {
	Array.reverse(values);
	index = findLeftMin(values);
	index = values.length-1-index;
	Array.reverse(values);
	return index;
}

/* 
 * Tests  
 *
 */

var _TEST_COUNTER = 0;
runTests();



function runTests() {
	_TEST_COUNTER = 0;
	print("Test suite started");
	testFindLeftMin();
	testFindRightMin();
	testFindMax();
	print("Test suite finished");
}

function testFindMax() {
	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
	start = findLeftMin(values);
	end = findRightMin(values);
 	index = findMax(values, start, end);
 	assertEquals(index, 5, "testFindMax (even length)");

 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
	start = findLeftMin(values);
	end = findRightMin(values);
 	index = findMax(values, start, end);
 	assertEquals(index, 5, "testFindMax (odd length)");
}

function testFindLeftMin() {
 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
 	index = findLeftMin(values);
 	assertEquals(index, 1, "testFindLeftMin (even length)");

 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12, 15);
 	index = findLeftMin(values);
 	assertEquals(index, 1, "testFindLeftMin (odd length)");
}

function testFindRightMin() {
 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12);
 	index = findRightMin(values);
 	assertEquals(index, 9, "testFindRightMin (even length)");

 	values = newArray(10, 5, 7, 8, 9, 24, 8, 6, 4, 3, 11, 12, 15);
 	index = findRightMin(values);
 	assertEquals(index, 9, "testFindRightMin (odd length)");
}

function assertEquals(isValue, shouldValue, nameOfTest) {
	_TEST_COUNTER++;
	result = false;
	if (isValue==shouldValue) {
		print (_TEST_COUNTER + "-" + nameOfTest + " - ok");
	} else {
		print (_TEST_COUNTER + "-" + nameOfTest + " - FAILED!");
		print ("expected value is "+shouldValue+", but the result is "+isValue);
	}
}

