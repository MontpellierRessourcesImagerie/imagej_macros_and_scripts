# User manual: Volume of GAG protein per nucleus

- In Fiji, open the "AMI Quantify GAG".

## 0. Convert the images

- If your images are coming from the X1 and consist in folders containing a hierarchy ending in `image_Pos0.ome.tif`, you can use the first "Unpack images" tool. 
- Select the folder containing all the folders representing images. The images should be exported as independant TIFF images.

## 1. Extract nucleus channel

- Use the "Extract channel" tool.
- Provide the path of the folder containing your TIFF images.
- Provide the index (starting at 1) of the channel containing nuclei.
- Provide the prefix to assign to the isolated nuclei (ex: "nuclei_").
- Run the macro, the console should show "DONE." whenever it's over.

## 2. Segment the nuclei

- From `D:\MRI\software`, launch the runnable file "launch-cellpose-napari.cmd".

### A. It is the first image of a kind that you deal with

- Once Napari is opened, you must open two toolsets:
	- Plugins > Calibration Tool > Scale Tool
	- Plugins > cellpose-napari > Cellpose Inference (may take a little while to open)
- Drag and drop one of your nuclei images in the viewer.
- In the "Scale Tool" widget:
	- Set your X, Y and Z value (ex: 0.0971045, 0.0971045, 0.3)
	- The unit should be fine already
	- Tell the widget that the extra axis is some depth (ZYX) and not time (TYX) or channels (CYX).
	- Click on either "Apply" or "Apply to all" (there is only one image here)
	- If the image disappears, click on the little house in the lower-left corner of the viewer and navigate with the slider under the viewer.
In the "CellPose Inference" widget:
	- The "main channel" should already point to the only image you opened.
	- The model is fine as well ("cpsam")
	- Tune the "median diameter" until the circle is roughly the same diameter as your nuclei (ex: 110).
	- Set the "Flow smoothing" to something big enough (like 3.0 or bigger) to avoid sur-segmentation.
	- Click "Apply" and wait to have a preview of the result.
	- You can repeat the tuning of the settings and the segmentation as many times as you need until you get a descent result.

### B. You have already dealt with such images

- Once Napari is opened, launch only the "cellpose-napari" > "CellPose Batch Processing" widget.
- Provide the same input and output folders (the one containing your TIFF images)
- As the "main channel prefix", use the prefix that you provided in the "Extract channel" macro.
- Set the axes to ZYX, and update the calibration to match your pixel size.
- Set the "median diameter" and "min object size" according to what you used in the one-shot mode.
- Set the "segmentation prefix" to "inference_".
- You can then run the segmentation.
- If you click on the blue-dots GIF in the lower right part of Napari's window, you should have the progression.

## 3. Recalibrate the images

- Get back to Fiji in the "AMI Quantify GAG" toolset.
- Python produces stacks of images but ImageJ doesn't understand by itself that these are slices.
- To recalibrate images and set the correct axes, use the "Recalibrate tool".
- If you run it, you should be asked:
	- the folder containing your images
	- the prefix of your segmented nuclei (ex: "inference_")

## 4. Measure of intensities in nuclei

- Now, we can measure the global intensity in the GAG channel for each individual nucleus.
- The "Intensity in nuclei" macro should allow you to do so.
- If you run it, you should be asked:
	- the folder containing your images
	- the prefix of your segmented nuclei (ex: "inference_")

## 5. Segment the GAG spots

- This next macro should produce a label map of GAG spots.
- It will ask you:
	- The path of the folder containing your images
	- Which channel contains your spot in the original images
	- The absolute path to the classifier used by LabKit
	- The label that spots have in this classifier
	- The min and max size of a spot to apply a post-filter.
	- The min sphericity to reach to apply a post-filter as well.
- The "spots_" images should show up in the images folder.

## 6. Volume of protein per nucleus

- The last macro will count the number of "foci" and the volume they occupy in each nucleus.