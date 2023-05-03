# Radial profile of cells

## Segmentation

### 1. Generation of masks

The first steps consists in generating masks from the provided images. The channel 4 shows a coloration made for this purpose.
The Fiji plugin "map organelles" will provide a segmentation.
This plugin produces an image (.tif) with an overlay corresponding to the indentified individuals.
Nuclei and full cells are represented as polygonal selections. A point selection is present but is useless.
The first step consists in extracting a mask representing cells and a mask representing nuclei.

### 2. Curing

We need to work on representative data, so we start by discarding invalid data:

#### A. Individuals cut by the border

On the mask representing cells, we remove groups touching the borders.

#### B. Protruding nuclei

Then, we take the mask and create a labeling by connected components.
By subtracting the cells mask from the nuclei labels map, we obtain a new label map.
These labels represent invalid nuclei (protruding from their cell). We can detect the remaining labels and remove them from the original label map.
We are now left with a label map of valid nuclei, and a mask representing cells.

#### C. Couples cell+nuclei

The last step consists in removing cells that don't have an associated nuclei.
To do so, we start by creating a labeling by connected components from the full cells mask, and a mask from the valid nuclei.
We create a new label map by applying the AND operator between the mask and the label map (in this order to beneficiate from the lazy evaluation and keep labels).
Now we take the original label map representing the full cells, and we discard all the labels not present on the label map we created at the previous line.
Be extremely vigilant to the bit depth.
The result of the AND operations now contains the valid nuclei, and the new image with selected labels contains valid cells.
If the operation was performed correctly, the label of each nuclei should be the same as the cell's label.

## Radial profile

---

## Problems

- [ ] Find the correct settings for a good segmentation.
- [ ] We still need a way to automate the cells detection since the provided plugin doesn't expose any of its methods. Only a run method is available.
- [ ] 