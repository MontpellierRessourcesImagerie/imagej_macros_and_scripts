# Multiple co-occurrences

This set of scripts aims to segment blobs/spots in 3D over several channels (with LabKit)
Then, co-occurences are processed in all combinations of channels.
Classifiers must be named "c1.classifier", "c2.classifier", ... for every channel you want to segment and have to be placed in a folder.
For each image, channels will be split and segmented in a new folder.
Each mask will be named "c1.tif", "c2.tif", ...
These folders will be the source of the second script.

Find some classifiers [here](https://dev.mri.cnrs.fr/attachments/download/3483/2064-classifiers.zip)

---

The method is based on the intersection of masks to count co-occurences.

## Requirements

- LabKit (package name: `LabKit`)
- MorphoLibJ (package name: `IJPB-plugins`)

## Usage

### 1. Segment spots/blobs

- Place all your images in a folder and open `make-masks.py` in Fiji.
- Fill the variables (`_CLASSIFIERS_PATH`, `_SOURCES_FOLDER`, `_OUTPUT_FOLDER` and `_EXTENSION`)
- Click run.
- After the Logs window displayed "DONE.", you will find the segmentation masks in the output folder

### 2. Find co-occurences

- Open the script `find-co_occ.py`.
- Fill the `_TABLE_NAME` and `_INPUT_FOLDER` variables.
- Wait for the Logs window to show "DONE."
- A result table should contain the count of every combination.
