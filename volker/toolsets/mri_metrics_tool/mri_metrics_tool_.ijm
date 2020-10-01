var IMAGE_A = "";
var IMAGE_B = "";

macro "MRI Metrics Tool Help Action Tool - C000D23D28D29D34D35D39D3aD44D45D49D4aD53D58D59D5dD6dD7dD8dD9dDa3Da8Da9DadDb4Db5Db9DbaDc4Dc5Dc9DcaDd3Dd8Dd9CeeeD2bD4cD5bDabDbcDdbC555D13D19D26D69D99Da6De3De9C111D57D72D82Dd7CbbbD12D3bD4bD4dDbbDbdDcbDe2C000D27D2aD5aD73D83Da7DaaDdaC999D1aD38D48D6aD9aDb8Dc8DeaC333D74D75D76D77D78D79D7aD7bD84D85D86D87D88D89D8aD8bCcccD22D24D25D52D54D55Da2Da4Da5Dd2Dd4Dd5C888D37D47D62D92Db7Dc7C222D33D43D7cD8cDb3Dc3CcccD5cD6cD9cDacCaaaD18D68D98De8C666D56D71D81Dd6C111D36D46D63D93Db6Dc6"" {
	
}

macro "Intersection over Union Action Tool - C037T0b10IT6b10oTeb10U" {
	showIoUDialog();
}

function showIoUDialog() {
	images = getList("image.titles");
	if (images.length<2) {
		showMessage("Two input masks needed!");
		return;
	}
	if (IMAGE_A=="") IMAGE_A = images[0];
	if (IMAGE_B=="") IMAGE_B = images[1];
	Dialog.createNonBlocking("IoU Metric");
	Dialog.addChoice("Image A: ", images, IMAGE_A);
	Dialog.addChoice("Image B: ", images, IMAGE_B);
	Dialog.show();
	IMAGE_A = Dialog.getChoice();
	IMAGE_B = Dialog.getChoice();
	iouValue = iou(IMAGE_A, IMAGE_B);
	print("IoU between " + IMAGE_A + " & " + IMAGE_B + " = " + iouValue);
	showIoUDialog();
}

function iou(a, b) {
	setBatchMode("true");
	imageCalculator("AND create", a, b);
	getHistogram(values, counts, 256);
	I = counts[255];
	close();
	imageCalculator("OR create", a, b);
	getHistogram(values, counts, 256);
	U = counts[255];
	close();
	setBatchMode("false");
	return I/U;
}