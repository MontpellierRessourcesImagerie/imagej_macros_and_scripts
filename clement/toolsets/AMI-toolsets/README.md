# Count spots per cell

## Installation

**Requirements:** To be able to run the full workflow, you will need both ImageJ/Fiji and a Python (>=3.11).

### A. The segmentation tools

#### a. Option 1: For the cyto without nuclei:

- This option is relevant to you if your images have both a cyto/membrane staining and a nuclear staining. Your desired outcome is the cells from which the nuclei were cut of.
- This tool relies on CellPose-SAM (aka CellPose 4) to segment the cells from all the images located in a folder using a membrane and a nuclei channel.
- Using pip in your favorite environments manager, you should install both `cellpose[gui]` and `scikit-image` in an env running a Python>=3.11.
- The  tool is the whole ["batch-cp-sam" folder](clement/stand-alones/batch-cp-sam) that you can find in `clement/stand-alones`.
- Once your environment is setup and you downloaded the tool, you can launching by:
    - activating the environment
    - write `python ` (the blankspace after the "python" word is required, it is not a mistake).
    - Drag and drop the `qt_gui.py` file in the terminal.
    - press the "Enter" key.

#### b. Option 2: For the nuclei only:

- This option is relevant to you if you have a nuclear staining and the desired outcome is the segmented nuclei.
- This tool relies of Cellpose SAM exposed through Napari.
- Using pip in your favorite environments manager, you should install:
    - `cellpose[gui]`
    - `git+https://github.com/MontpellierRessourcesImagerie/cellpose-napari.git`
- In Napari, the tool is located in Plugin > cellpose-napari.

### B. The spots segmentation and counting toolset

- Open ImageJ/Fiji and in the menu bar, go to `File > Show folder > ImageJ`.
- In the folder that appears, drag and drop the `macros` and `plugins` folders that you should find in the ["AMI-toolsets" folder](clement/toolsets/AMI-toolsets) located in `clement/toolsets`.
- Your operating system should propose you to merge the content of both folders.
- Once it is done, restart Fiji and check in the `>>` menu that the "AMI xxx" toolsets are present.
- If you go to `Help > Update... > Manage update sites` you should verify that `IJPB-plugins` and `LabKit` are activated.

