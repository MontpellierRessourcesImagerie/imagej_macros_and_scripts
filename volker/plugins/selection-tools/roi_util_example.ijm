/*
 * Create test data, 
 * 	rois 1 and 2 intersect without one being included in the other
 * 	rois 4 is included in roi 3
 * 	roi 1 and roi 3 do not have any overlap 
 */

/* doRoisOverlap
 *  test is the two rois overlap without one being included in the other
 *  
 * isRoi2IncludedIn1 
 *  test if roi two is entirely included in roi one
 *  
 * doRoisHaveNoOverlap 
 *  test if the overlap of the two rois is empty
 */

getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
newImage("test_roi_utils", "8-bit black", 800, 600, 1);
roiManager("reset");
makeRectangle(55, 51, 145, 92);
roiManager("Add");
roiManager("Show All");
makeRectangle(139, 95, 126, 92);
roiManager("Add");
makeRectangle(284, 259, 252, 133);
roiManager("Add");
makeRectangle(456, 99, 252, 133);
makeRectangle(359, 297, 97, 58);
roiManager("Add");

testResults = newArray(0);
testDesc = newArray(0);
// activate the macro-extension
run("MRI Roi Util");

/*
 * Test doRoisOverlap
 */
testDesc = Array.concat(testDesc, "roi 1 and 2 overlap (true)"); 
roiManager("select", 0);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 1);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="true");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "roi 2 and 1 overlap (true)");
roiManager("select", 0);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 1);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisOverlap(xpoints2, ypoints2, xpoints1, ypoints1)=="true");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "roi 3 and 4 overlap (false)");
roiManager("select", 2);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 3);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "roi 4 and 3 overlap (false)");
roiManager("select", 3);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 2);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "roi 1 and 3 overlap (false)");
roiManager("select", 0);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 2);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

/*
 * Test isRoi2IncludedIn1
 */
testDesc = Array.concat(testDesc, "test roi 1 included in 2 (false)"); 
roiManager("select", 1);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 0);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.isRoi2IncludedIn1(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "test roi 4 included in 3 (true)"); 
roiManager("select", 2);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 3);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.isRoi2IncludedIn1(xpoints1, ypoints1, xpoints2, ypoints2)=="true");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "test roi 3 included in 4 (false)"); 
roiManager("select", 3);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 2);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.isRoi2IncludedIn1(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "test roi 1 included in 3 (false)"); 
roiManager("select", 0);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 2);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.isRoi2IncludedIn1(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

/*
 * doRoisHaveNoOverlap
 */
testDesc = Array.concat(testDesc, "test do rois 1 and 2 have no overlap (false)"); 
roiManager("select", 0);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 1);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisHaveNoOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "test do rois 3 and 4 have no overlap (false)"); 
roiManager("select", 2);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 3);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisHaveNoOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="false");
testResults = Array.concat(testResults, result);

testDesc = Array.concat(testDesc, "test do roi 1 and 3 have no overlap (true)"); 
roiManager("select", 0);
getSelectionCoordinates(xpoints1, ypoints1);
roiManager("select", 2);
getSelectionCoordinates(xpoints2, ypoints2);
result = (Ext.doRoisHaveNoOverlap(xpoints1, ypoints1, xpoints2, ypoints2)=="true");
testResults = Array.concat(testResults, result);

/*
 * Print test results
 */
 print(year+"-"+month+"-"+dayOfMonth+" "+hour+":"+minute+":"+second+"."+msec);
failedTests = 0;
passedTests = 0;
for(i=0; i<testResults.length; i++) {
	output = "test "+(i+1)+" - ";
	if (testResults[i]) {
		output = output + "ok";
		passedTests++;
	} else {
		output = output + "FAILED";
		failedTests++;
	}
	print (output);
	print (testDesc[i]);
}
print("Ran "+ testResults.length + " tests - " + passedTests + " passed - " +  failedTests + " FAILED.");
