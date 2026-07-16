# User manual: Quantify spots in cells

## 0. Convert the images

- In Fiji, open the "AMI Post-process cells".
- In case the images are coming from the X1, and the images are folders containing a hierarchy ending in image_Pos0.ome.tif", you can use the first "Unpack images" tool. Select the folder containing all the folders representing images. The images should be exported as independant TIFF images.

## 1. Cells segmentation

- Place all your TIFF files in a folder.
- Activate the Python environment in which CellPose is installed and run the `qt_gui.py` file.
- In the "Folder path" field, provide the path of the folder containing your TIFF images.
- In the list below, all the segmentable images should show up.
- In the "Median diameter" field, provide (approximately) how many pixels the average cell is in number of pixels.
- In the "XY pixel size" and "Z pixel size" provide the physical size of a voxel in µm.
- In the "Membrane channel" provide the index of the channel where your membranes are stained (starting at 1).
- In the "Nuclei channel" provide the index of the channel where your nuclei are stained (starting at 1). If you don't have nuclei, uncheck the "Use secondary channel" box.
- If a GPU is available, you should use it.
- If you click on "Run", the segmentation should be done over the whole folder. 
- The results are named after the original images to which the "inference_" prefix is added.

## 2. Cells post-processing

- In Fiji, open the "AMI Post-process cells".
- Open an image.
- Click on the "Initialize workspace" button. It should:
    - adjust the contrast in the image
    - open the associated segmented cells
    - set the LUT of the segmented cells
    - open the "Windows sync" tool (in which you can click on **Synchronize all**)
- Now you can:
    - Start by merging the cells that are over segmented. To do so, you can make lines or polylines over the labels and add them to the RoiManager using the `[T]` key.
    - Then you can cut cells that are merged together. To do so, you can help yourself of the cursor showed by the windows syncronizer. Simply draw lines or polylines where the cells should be cut.
    - In case the network hallucinated, you can make points over the objects to be removed and use the dedicated button.
    - The last step is to remove objects by size.

## 3. Segment spots per cell

- Open the "AMI process spots" toolset in Fiji.
- Using the "Segment spots" button will result in the segmentation of spots on all images in the folder.
- You should have new images with the "spots_" prefix.
- Eventually, you can:
    - count spots per cell
    - measure the intensities in cells