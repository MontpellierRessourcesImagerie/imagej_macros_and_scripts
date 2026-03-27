from cellpose import io, models, train
import tifffile
import os
from datetime import datetime
from pathlib import Path
from skimage.measure import regionprops
import numpy as np

def get_prefix():
    return "inference_"

def print_inference():
    print("")
    print("# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #")
    print("#                            INFERENCE                                        #")
    print("# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #")
    print("")

def extract_channels(image, n_ch, m_ch, use_secondary):
    # Axes: Z, C, Y, X
    m_data = image[:,m_ch-1,:,:]
    if use_secondary:
        n_data = image[:,n_ch-1,:,:]
        return np.array([m_data, n_data])
    else:
        return np.array([m_data])

def run_cellpose_sam(settings, content, callback=None):
    # decapsulate settings
    use_gpu      = settings['use_gpu']
    folder       = settings['folder_path']
    med_diam     = settings['median_diameter']
    p_xy         = settings['xy_pixel_size']
    p_z          = settings['z_pixel_size']
    nuclei_ch    = settings['nuclei_channel']
    membranes_ch = settings['membrane_channel']
    use_second   = settings['use_secondary']
    
    model = models.CellposeModel(
        gpu=use_gpu,
        pretrained_model='cpsam'
    )

    an_ratio = p_z / p_xy
    prefix = get_prefix()

    if callback is not None:
        callback(0, 0, "▶️ Running...", len(content))

    print_inference()

    for i, (img, row) in enumerate(content):
        if img.startswith(prefix):
            continue
        print(f"  - [{i+1}/{len(content)}] Running CellPose for: {img}")
        if callback is not None:
            callback(i, row, "▶️ Running...", len(content))
        im_path = os.path.join(folder, img)
        im_data = tifffile.imread(im_path)
        im_data = extract_channels(im_data, nuclei_ch, membranes_ch, use_second)
        masks, flows, styles = model.eval(
            im_data,
            # rescale=True,
            diameter=med_diam,
            anisotropy=an_ratio,
            do_3D=True,
            channel_axis=0,
            z_axis=1
        )
        tifffile.imwrite(
            os.path.join(folder, f"{prefix}{img}"), 
            masks.astype('uint16')
        )
        if callback is not None:
            callback(i+1, row, "✅ Done", len(content))
    
    print("Inference completed.")