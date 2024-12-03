# Signal repartition bacilli

## Summary

This toolset is meant to analyze the rapartition of the signal in bacilli.
We want to know if it is:

- Uniformly spread in the whole bacteria
- Only focused in the membrane area
- Only focused in the center area

To do that, we have a workflow as follows:

1. We create a mask of the bacilli with LabKit.
2. On the resulting masks, the user creates rectangle ROIs to select "good" bacilli (AABB).
3. Each ROI is added to the RoiManager, and the RoiManager is saved as a ZIP file alongside the masks (same name but `.tif` -> `.zip`)
4. In a loop, we erode the mask of 1 pixel and extract statistics in the remaining region.

- If the signal is uniformly spread, the values should remain constant.
- If the signal is concentrated in the membrane, the mean and median should dicrease over erosions.
- If the signal is concentrated in the center, the mean and the median should increase over erosions.

## Install

- Make sure that you have the MorphoLibJ and LabKit plugins installed on your Fiji (`IJPB-plugins` and `LabKit` in the update sites).
- Take the content of the `macros/toolsets` folder and copy it in the `macros/toolsets` folder on your Fiji.
- Do the same thing with the content of `plugins`.
- Restart your Fiji.
- In your toolsets (the red >> in Fiji's window), you should now have the "Measure bacilli" toolset.

## Before you start

The files are expected to be sorted for this toolset to work. Let's say that we want to segment our objects on `channel_1` and measure on `channel_2`, then we expected the following folders hierarchy:

- some_folder
    - channel_1
        - image1.tif
        - image2.tif
        - image3.tif
    - channel_2
        - image1.tif
        - image2.tif
        - image3.tif

Note that images are named the same way in both folders.

## How to use it

### Step 1: Settings

- Click on the little gear and fill the settings:
    - `Root folder` is the folder refered as "some_folder" in the hierarchy example of the previous part. It contains the two sub-folders.
    - `Membranes folder`: Is the **name** (not the full path) of the folder containing the segmentation channel.
    - `Measures folder`: Is the **name** of the folder containing the measures channel.
    - `Classifier path`: Is the full absolute path of the ".classifier" file used for segmentation.
- Click the "OK" button and you are good to go.

### Step 2: Segmentation

- Click the "Segment tool" button.
- Wait until the "Log" window displays "DONE."
- A new folder prefixed with "masks-" should have appeared in the root folder.

### Step 3: Select individuals

- During this step, users have to manually select the bacilli that can be used. To do so:
    - Open one of the mask.
    - If there is nothing you can use in this image, you have nothing to do, go to the next mask.
    - Make a rectangle over one of the good bacilli.
    - Press [T] to add it to the RoiManager.
    - To avoid selecting twice the same item, you can check "Show all" in the RoiManager's window.
    - Once all your boxes are in the RoiManager:
        - In the RoiManager, click in the empty area below your list of ROIs.
        - Press [Ctrl+A] to select all your ROIs.
        - Click the "More" button, and then "Save as".
        - Give it the same name as the mask, just by replacing ".tif" by ".zip".
        - Close the RoiManager and pass to the next mask.

### Step 4: Measures

- Click the "Measure tool" button.
- After a few seconds, a ResultsTable should show up.
- One line == one ROI
- For the statistics, the index in the name (ex: "xxx-0", "xxx-1", "xxx-2") corresponds to the erosion level.
