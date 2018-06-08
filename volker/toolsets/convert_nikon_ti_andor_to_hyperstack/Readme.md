# Convert Nikon TI Andor to Hyperstack

Process images taken with the spinning disk confocal miscroscope. Because of the big size of the images the microscope cuts images along the time dimension into multiple files each with a number of frames. This tool will for each position and wavelength convert the image. It will do a z-projection, concatenate all time-chunks and save the resulting image. The user has to provide the number of slices in the z-dimension. The pixel size and time interval can automatically be set when provided by the user.

For more information see the [wiki of the project](https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/MRI_Convert_Nikon_Andor_To_Hyperstack).

