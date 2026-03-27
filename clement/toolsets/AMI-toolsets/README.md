# Count spots per cell

## Installation

To be able to run the full workflow, you will need both ImageJ/Fiji and a Python (>=3.11).

### a. The cells segmentation tool

- This tool relies on CellPose-SAM (aka CellPose 4) to segment the cells from all the images located in a folder using a membrane and a nuclei channel.
- Using pip in your favorite environments manager, you should install both `cellpose[gui]==3.1.1` and `scikit-image` in an env running a Python>=3.11.
- The  tool is the whole ["batch-cp-sam" folder](clement/stand-alones/batch-cp-sam) that you can find in `clement/stand-alones`.
- Once your environment is setup and you downloaded the tool, you can launching by:
    - activating the environment
    - write `python ` (the blankspace after the "python" word is required, it is not a mistake).
    - Drag and drop the `qt_gui.py` file in the terminal.
    - press the "Enter" key.

### b. The spots segmentation and counting toolset

- Open ImageJ/Fiji and in the menu bar, go to `File > Show folder > ImageJ`.
- In the folder that appears, drag and drop the `macros` and `plugins` folders that you should find in the ["AMI-toolsets" folder](clement/toolsets/AMI-toolsets) located in `clement/toolsets`.
- Your operating system should propose you to merge the content of both folders.
- Once it is done, restart Fiji and check in the `>>` menu that the "AMI xxx" toolsets are present.
- If you go to `Help > Update... > Manage update sites` you should verify that `IJPB-plugins` and `LabKit` are activated.

### c. Extra(s)

- To run the spots segmentation, you will need a pixel classifier for LabKit.
- You can either retrain one depending of your needs or use [a pretrained classifier](https://dev.mri.cnrs.fr/attachments/download/4526/spots-classifier-v003.classifier).

## Usage

### 0. Convert the images

- In Fiji, open the "AMI Post-process cells".
- In case the images are coming from the X1, and the images are folders containing a hierarchy ending in image_Pos0.ome.tif", you can use the first "Unpack images" tool. Select the folder containing all the folders representing images. The images should be exported as independant TIFF images.

### 1. Cells segmentation

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

### 2. Cells post-processing

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

### 3. Segment spots per cell

- Open the "AMI process spots" toolset in Fiji.
- Using the "Segment spots" button will result in the segmentation of spots on all images in the folder.
- You should have new images with the "spots_" prefix.
- Eventually, you can:
    - count spots per cell
    - measure the intensities in cells