import os
from cellpose import models, utils, io
import tifffile

_MIP_FOLDER = "/home/benedetti/Documents/projects/2068-coralie-co-occurance/transfer_8066882_files_8c192037/new_version/mips/"
_MEDIAN_NUCLEI_DIAMETER = 130

def segment_yeasts_cells(transmission, gpu=True):
    """
    Takes the transmission channel (brightfield) of yeast cells and segments it (instances segmentation).
    
    Args:
        transmission (image): Single channeled image, in brightfield, representing yeasts
    
    Returns:
        (image) An image containing labels (one value == one individual).
    """
    model = models.Cellpose(gpu=gpu, model_type='nuclei')
    chan = [0, 0]
    masks, flows, styles, diams = model.eval(transmission, diameter=_MEDIAN_NUCLEI_DIAMETER, channels=chan)
    return masks


if __name__ == "__main__":
    content = [f for f in os.listdir(_MIP_FOLDER) if f.endswith(".tif")]
    for c in content:
        if c.startswith("labeled"):
    	    continue
        full_path = os.path.join(_MIP_FOLDER, c)
        img = tifffile.imread(full_path)
        print(img.shape)
        labeled = segment_yeasts_cells(img)
        export_path = os.path.join(_MIP_FOLDER, "labeled-" + c)
        tifffile.imwrite(export_path, labeled)
    print("DONE")
