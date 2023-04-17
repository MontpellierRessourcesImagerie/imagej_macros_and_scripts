
# Spots in neurites

This is a toolbar aggregating several macros (written in ImageJ's macro language) triggered and articulated through Python scripts.

Settings are managed by a dedicated script, and can be exported and loaded as we need them.

A part of the macros is located in the subsection "clement/macros":
    - "Neurons_Spots.ijm"
    - "stack-focus_mip.ijm"
    - "Verif_Segmentation.ijm"
    - "Verif_Spots.ijm"

And the other part is in "leo/macros":
    - "verif_mip.ijm"
    - "measure-intensity-in-nucleus.ijm"

The following ImageJ plugins are required:
    - ComDet
    - Find_focused_slices

For the segmentation part, you will need some pieces of the dl4mic plugin (https://github.com/MontpellierRessourcesImagerie/dl4mic/releases).
You will also need an installation of miniconda.



Files to pick from dl4mic:
    - "environment.yml" if you are on Linux/Mac
    - "environment_win.yml" if you are on Windows (pfff...)
    - Tout le package dl4mic


Common sources of errors:
    - The file extension varies from a file to another and doesn't match the one provided in the settings (that problem is quite often observed on Windows users, where file extension is hidden and can't see that a mix of ".tif" and ".TIF" is present.)
