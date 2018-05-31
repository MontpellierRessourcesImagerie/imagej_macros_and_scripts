# Crop macro (for dataset larger than available RAM)
You may use the software ImageJ to crop your images.
## Case 1: you are able to fully load your CT/MRI dataset within ImageJ on your workstation

If you are able to open your entire CT/MRI dataset with ImageJ, then simply make use of the "Crop" function, and save your resulting image stack in another location (draw a rectangle delimitating your region of interest, and then go to menu Image->Crop).
## Case 2: your dataset is too large to be opened entirely "at once".

It may happen that a CT/MRI data set is too large to be entirely loaded in memory (for instance you may have synchrotron data). Here I present you a rather simple way to crop such large data without having to load the entire image stack in memory. As a first step, download the crop macro and place this file inside the "macro" directory of ImageJ.

* 1) Open a part of your image sequence (for instance go in File->Import->Image sequence and chose to open only 1 image every 20 images by changing the Increment value, in order to reduce the amount of memory needed to open the stack by a factor of 20).


* 2) Open Macro recorder window (Plugin->Macros->Record)


* 3) Define the ROI with the rectangle selection tool. Adjust the ROI in order to have your structures of interest enclosed in the rectangle for all slices.


*  4) Copy the last "makeRectangle" command in the macro recorder window.


* 5) Open the _macro.txt file you have placed in your "macro" directory. Find the makeRectangle command and replace it by the one you have just copied from the Recorder window. Save the _crop.txt file.


* 6) Launch the _crop.txt macro. To do so, first go in Plugins->Macros->Install and chose the _crop.txt file. Then go in Plugins->Macro->_crop. The following window should appear. Here you should chose an input directory in which you have stored your original CT/MRI data. Be aware that this directory should contain only images, and that these images should all have the same width and height. If these requirements are not fulfilled, the _crop.txt macro will not work.


* 7) Chose an empty target directory. This will be the place where the new image stack will be stored. 


# Binning macro (for dataset larger than available RAM)

= reducing image resolution by a factor of 2 using ImageJ

Again, you may use the software ImageJ to reduce the resolution of a CT/MRI dataset.
## Step 1: download and install "averaging reducer" plugin

You can download the plugin at the following page.. Then close and restart ImageJ.
## Step 2: Install and run the "binning" macro.

Download the binning macro and place this file inside the "macro" directory of ImageJ.

* 1) Launch the _binning.txt macro. To do so, first go in Plugins->Macros->Install and chose the _binning.txt file. Then go in Plugins->Macro->_binning. The following window should appear. Here you should chose an input directory in which you have stored your original CT/MRI data. Be aware that this directory should contain only images, and that these images should all have the same width and height. If these requirements are not fulfilled, the _binning.txt macro will not work.
	View	

* 2) Chose an empty target directory. This will be the place where the new image stack will be stored. The target directory will contain twice as less images as the input directory, and the width and height of the resulting images will have been divided by 2. The weight of the output directory should be 8 times smaller than that of the input directory. 
