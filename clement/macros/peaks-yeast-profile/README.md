# PEAKS IN YEASTS

## What is it?

This macro is meant to be used in Fiji (ImageJ) to detect peaks of intensity within yeasts radial profiles.
To install this macro, you can place it (the ".ijm" file) in the "plugins" folder of your Fiji.

**Requirements:**
- BAR (https://imagej.net/plugins/bar)
- StackReg (https://imagej.net/plugins/stackreg)

**Inputs**

- (In one-shot mode) An opened image and a RoiManager filled with line ROIs.
- (In batch mode) The path to a folder filled with images and RoiManagers saved as ZIP, with matching names (ex: "image1.tif" and "image1.zip").

**Outputs**

The output is a folder named after the image you provided, prefixed with "control-" (ex: "image1.tif" -> "control-image1").
It contains:
- The plot of the profile as a PNG image for each line named `peaks-ROI-[index roi]-[index frame].png`.
- The peaks that were found for each line at each frame as a CSV file (a CSV == a time serie for a line)
- The RoiManager bundled as a ZIP file.
- For reproducibility, the settings of distance and amplitude are written on the PNG plot.

## Settings

- Minimum peak width: To avoid peaks created by an isolated pixel or small aggregate of pixel, you can increase this value.
- Maximum peak width: To find peaks within a big structure, you can lower this setting.
- Exclude edge peaks: To avoid peaks touching the left and right sides of the plot (cut peaks)
- Output directory: Path of the directory that will contain the CSVs, the plots, ...
- Presmoothing radius: (Negative value == disabled) If you have a noisy image and if the noise can be caught as peaks, you can increase the value of this setting to reduce the amount of noise.
- Channel: If you have a multi-channel image, which channel should we work on (starts at 1).
- Minimum peak amplitude: Minimal value (in intensity) to reach for a maxima to be actually recorded. If the value is negative, an automatic calculation will be performed during which a circle will be drawn using the center of the line and its length as diameter. The mean value within this circle will be used.
- Minimum peaks distance: Due to noise, a peak can be split into two very close peaks. This setting allows to merge back those peaks.
- Run batch processing: Should the script run on the active image, or on an entire folder.
- Input directory: Folder in which images and RoiManagers are located, having the same name except for the extension.
- Extension: Extension of the image to process, including the dot (ex: ".czi", ".tif", ...)

## What is in the CSV?

The CSV contains all the information through the whole time serie for a given line.
Numbers are written with the american standard (`.` as decimal separator) and the comma (`,`) is used as values separator.
Unused cells are padded with zeros.
Each column has a suffix `t-N` where N is the index of the frame within the time serie.
The minima and maxima are sorted by their abscissa value.

**Columns:**

- Plot-X (unit)-tN: This column is about the full plot, not the peaks yet. To make a plot of intensities through a line, samples are realized at a regular interval of distance along the line. This column indicates the distance from the first point of the line at which each sample was made.
- Plot-Y (Intensity)-tN: This column contains the intensity found for each sample along the line you provided.
- Max-X-tN: This columns indicates the distance tbetween the first point of the line and a given maxima.
- Max-Y-tN: Contains the intensity at the top of the maxima.
- Min-X-tN: Same as 'Max-X-tN' but for a minima.
- Max-Y-tN: Same as 'Max-Y-tN' but for a minima.

