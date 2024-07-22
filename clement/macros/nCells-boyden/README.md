# Count cells in Boyden chamber

This macro counts cells in a Boyden chamber, even though pores are stained with the same dye as the cells.
This macro can work either on the current image or on a full folder.
The provided output is a table giving the number of cells for each image.

## Use the macro

- Download the IJM file and drag'n'drop it in ImageJ like it is an image.
- Edit the settings depending on what your image looks like.

## Tweak the settings

- `_MODE`: Determines wether we work on the current image or on the content of a folder. 0 means that we work on the current image, while 1 means that we will work on a folder.
- `_IMAGES_PATH`: Only useful if `_MODE` is 1. Folder in which your images are. It must end with a separator. Use "/" even on Windows.
- `_EXTENSION`: Only useful if `_MODE` is 1. Extension of the images in the folder. Don't forget the dot.
- `_GAMMA`: Coef of the [gamma function](https://en.wikipedia.org/wiki/Gamma_correction) used to reduce the gap between the pores intensities and the cells intensities.
- `_GAUSSIAN_RADIUS`: Smoothing radius to try to remove the pores, that are small structures compared to cells.
- `_MIN_VALUE`: Minimal intensity to reach to not discard the peak.
- `_PROMINENCE`: Gap between values to separate peaks.
- `_TABLE_NAME`: Name of the results table containing the number of cells per image.
