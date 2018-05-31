# Binning macro (for dataset larger than available RAM)

= reducing image resolution by a factor of 2 using ImageJ

Again, you may use the software ImageJ to reduce the resolution of a CT/MRI dataset.
## Step 1: download and install "averaging reducer" plugin 

You can download the plugin at the following page: https://imagej.nih.gov/ij/plugins/reducer.html Then close and restart ImageJ.
## Step 2: Install and run the "binning" macro.

Download the binning macro and place this file inside the "macro" directory of ImageJ.

* 1) Launch the _binning.txt macro. 
To do so, first go in Plugins->Macros->Install and chose the _binning.txt file. Then go in Plugins->Macro->_binning. The following window should appear. Here you should chose an input directory in which you have stored your original CT/MRI data. Be aware that this directory should contain only images, and that these images should all have the same width and height. If these requirements are not fulfilled, the _binning.txt macro will not work.


* 2) Chose an empty target directory. 
This will be the place where the new image stack will be stored. The target directory will contain twice as less images as the input directory, and the width and height of the resulting images will have been divided by 2. The weight of the output directory should be 8 times smaller than that of the input directory. 
