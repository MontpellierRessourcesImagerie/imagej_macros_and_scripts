from lls_transforms.lls_transform import lls_transform
from ij.gui import GenericDialog
from ij import IJ
import math
import os

def show_transform_dialog():
    defaults = {
        'angle': 30.0,
        'shift': 3.0,
        'step' : 0.1
    }

    gd = GenericDialog("Transform settings")
    # Line 1
    gd.addNumericField("Objective's angle (degrees):", defaults['angle'], 3)

    # Group label + numeric fields for variations
    gd.addMessage("Variations:")
    gd.addNumericField("  Shift:", defaults['shift'], 3)
    gd.addNumericField("  Step:", defaults['step'], 3)

    # Add a button to choose an export folder
    gd.addDirectoryField("Export folder:", "")

    gd.showDialog()
    if gd.wasCanceled():
        IJ.log("Transform dialog cancelled by user.")
        return None

    # getNextNumber() reads numeric fields in the order they were added
    angle = gd.getNextNumber()
    shift = gd.getNextNumber()
    step = gd.getNextNumber()
    export_folder = gd.getNextString()

    # basic validation: ensure numbers are finite
    for name, val in (("angle", angle),
                      ("shift", shift),
                      ("step", step)):
        if val is None or math.isnan(val):
            IJ.log("Invalid numeric value for %s: %s" % (name, val))
            return None

    out = {
        'angle'        : float(angle),
        'shift'        : float(shift),
        'step'         : float(step),
        'export_folder': export_folder
    }
    return out

def create_variations(config):
    ang = config['angle'] - config['shift']
    image = IJ.getImage()

    while ang <= config['angle'] + config['shift']:
        res = lls_transform(image, ang, -180-ang, "CGT")
        title = "CGT_ang-%0.2f.tif" % (ang)
        path = os.path.join(config['export_folder'], title)
        IJ.saveAs(res, "TIFF", path)
        res.close()
        IJ.log("Saved: %s" % path)
        ang += config['step']


config = show_transform_dialog()
create_variations(config)
