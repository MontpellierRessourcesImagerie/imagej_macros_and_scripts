_CONTENT_CHANNEL = 2;
_WITNESS_CHANNEL = 1;

correctConstantDrift();

/**
 * Correct the drift in one channel by using the first and last frame 
 * of another channel (the witness) to calculate the overall translation. 
 * divide it by the number of timepoints-1 and apply it to each frame
 */
function correctConstantDrift() {
	setBatchMode("hide");
	title = getTitle();
	getDimensions(width, height, channels, slices, frames);
	tmpDir = getDir('imagej') + "/tmp";
	transformationsFilePath = tmpDir + "/trans.txt";
	File.makeDirectory(tmpDir);
	run("Split Channels");
	localDelta = getOneStepDriftVector(title, frames, transformationsFilePath);
	writeTransformationFileForAllFrames(localDelta, frames, transformationsFilePath);
	run("MultiStackReg", "stack_1=[C"+_CONTENT_CHANNEL+"-"+title+"] action_1=[Load Transformation File] file_1="+transformationsFilePath+" stack_2=None action_2=Ignore file_2=[] transformation=[Translation]");
	run("MultiStackReg", "stack_1=[C"+_WITNESS_CHANNEL+"-"+title+"] action_1=[Load Transformation File] file_1="+transformationsFilePath+" stack_2=None action_2=Ignore file_2=[] transformation=[Translation]");
	mergeChannels(title);	
	setBatchMode("show");
	beep();
}

/**
 * Calculate the translation-vector between two frames, from the translation vector
 * between the first and the last frame frame in the witness-channel.
 * 
 * Answers an array with the x-component and the y-component of the vector 
 * at the positions 0 and 1.
 */
function getOneStepDriftVector(title, frames, transformationsFilePath) {
	selectImage('C'+_WITNESS_CHANNEL+'-'+title);
	run("Make Substack...", "  slices=1,"+frames);
	substackID = getImageID();
	run("MultiStackReg", "stack_1=[Substack (1,"+frames+")] action_1=Align file_1=["+transformationsFilePath+"] stack_2=None action_2=Ignore file_2=[] transformation=Translation save");
	selectImage(substackID);
	close();
	transformationsText = File.openAsString(transformationsFilePath);
	transformationsLines = split(transformationsText, "\n");
	srcLine = transformationsLines[5]
	targetLine = transformationsLines[9]
	parts = split(srcLine, "\t");
	xSrc = parseFloat(parts[0]);
	ySrc = parseFloat(parts[1]);
	parts = split(targetLine, "\t");
	xTarget = parseFloat(parts[0]);
	yTarget = parseFloat(parts[1]);
	globalDeltaX = xSrc - xTarget;
	globalDeltaY = ySrc - yTarget;
	print("global delta x:", globalDeltaX);
	print("global delta y:", globalDeltaY);
	localDeltaX = globalDeltaX / (frames - 1);
	localDeltaY = globalDeltaY / (frames - 1);
	print("local delta x:", localDeltaX);
	print("local delta y:", localDeltaY);
	return newArray(localDeltaX, localDeltaY);
}

/**
 * Fake a transformations-file for MultiStackReg, using a constant vector 
 * localDelta for each steps.
 */
function writeTransformationFileForAllFrames(localDelta, frames, transformationsFilePath) {
	output = ""
	output = output + "MultiStackReg Transformation File\n"
					+ "File Version 1.0\n"
					+ "0\n";
	for (i = 2; i <= frames; i++) {
		output = output + "TRANSLATION\n"
						+ "Source img: "+ i + " Target img: 1\n" 
						+ "" + 300+((1)*localDelta[0]) + "\t" + 300+((1)*localDelta[1]) + "\n"
						+ "0.0\t0.0\n"
						+ "0.0\t0.0\n"
						+ "\n"
						+ "300.0\t300.0\n"
						+ "0.0\t0.0\n"
						+ "0.0\t0.0\n"
						+ "\n";
	}
	File.saveString(output, transformationsFilePath);	
}

/**
 * Re-merge the channels of an image that have been
 * split with ImageJ's split channels command.
 */
function mergeChannels(title) {
	mergeOptions = "";
	for (c = 1; c <= channels; c++) {
		mergeOptions = mergeOptions + "c"+c+"=[C"+c+"-"+title+"] ";
	}
	mergeOptions = mergeOptions + "create";
	run("Merge Channels...", mergeOptions);
	for (c = 1; c <= channels; c++) {
		Stack.setChannel(c);
		run("Grays");
	}
	Stack.setChannel(1);
	Stack.setDisplayMode("color");
}

