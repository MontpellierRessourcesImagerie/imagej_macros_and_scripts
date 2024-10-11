/*
 *  Copy the images corresponding to the available ground truth from the pool folder to the in folder.
 */
 
EXT = "tif";
gtFolder = '/media/baecker/6b38a953-6650-4da5-94d9-57bd718df733/2024/in/2007-tree-rings/gt/masks_all/';
inFolder = '/media/baecker/6b38a953-6650-4da5-94d9-57bd718df733/2024/in/2007-tree-rings/in/';
imagePoolFolder = '/media/baecker/6b38a953-6650-4da5-94d9-57bd718df733/2024/in/2007-tree-rings/images/';

files = getFileList(gtFolder);

for(i=0; i<files.length; i++) {
	showProgress(i+1, files.length);
	file = files[i];
	if (!endsWith(file, "."+EXT)) continue;
	srcPath = imagePoolFolder + file;
	dstPath = inFolder + file;
	print("copying file " + (i+1) + " from "+ srcPath + " to " +dstPath);
	File.copy(srcPath, dstPath);
}
