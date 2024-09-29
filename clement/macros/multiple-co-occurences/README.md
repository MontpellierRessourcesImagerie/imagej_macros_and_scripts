
This set of scripts aim to segment blobs/spots in 3D over several channels (with LabKit)
Then, co-occurences are processed in all combinations of channels.
Classifiers must be named "c1.classifier", "c2.classifier", ... for every channel you want to segment and have to be placed in a folder.
For each image, channels will be split and segmented in a new folder.
Each mask will be named "c1.tif", "c2.tif", ...
These folders will be the source of the second script.

Find some classifiers [here](https://dev.mri.cnrs.fr/attachments/download/3483/2064-classifiers.zip)
