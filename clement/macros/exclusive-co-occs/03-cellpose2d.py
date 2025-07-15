from cellpose import models, core
from cellpose.io import logger_setup
import os
import tifffile

# Settings:

images_dir = "/home/benedetti/Downloads/2025-04-16-celia_chamontin/transfer_9591250_files_e96af054"

######################

def main():
    logger_setup()
    model = models.CellposeModel(
        gpu=True, 
        model_type="cyto3", 
        nchan=2
    )

    input_dir  = os.path.join(images_dir, "mips")
    output_dir = os.path.join(images_dir, "labeled-2d")

    if not os.path.isdir(input_dir):
        print("The input folder doesn't exist. Abort.")
        return False

    if not os.path.isdir(output_dir):
        os.mkdir(output_dir)

    content = [f for f in os.listdir(input_dir) if f.endswith('.tif')]

    for i, image in enumerate(content):
        # Load an image
        print(f"[{i+1}/{len(content)}] Processing: {image}")
        full_path = os.path.join(input_dir, image)
        imIn = tifffile.imread(full_path)

        # Segment cells
        cells, _, _ = model.eval(
            imIn,
            channels     = [1, 2],
            channel_axis = 0,
            diameter     = 250.0
        )

        # Segment nuclei
        nuclei, _, _ = model.eval(
            imIn,
            channels     = [2, 2],
            channel_axis = 0,
            diameter     = 100.0
        )

        # Remove nuclei from cells
        nuclei = nuclei == 0
        masks = cells * nuclei

        # Write the result to the disk
        output_path = os.path.join(output_dir, image)
        tifffile.imwrite(output_path, masks)

    print("Segmentation done")
    return True

if __name__ == "__main__":
    main()