import os

from ij.gui import GenericDialog

from ij import IJ, ImagePlus, ImageStack
from ij.measure import ResultsTable

from inra.ijpb.label import LabelImages
from inra.ijpb.measure import IntrinsicVolumes3D
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling3D
from inra.ijpb.measure.region3d import BoundingBox3D, EquivalentEllipsoid

def make_stack_mask(imIn, t):
    ttl = imIn.getTitle()
    stack = imIn.getStack()
    width = imIn.getWidth()
    height = imIn.getHeight()
    depth = imIn.getNSlices()
    mask_stack = ImageStack(width, height)
    
    for z in range(1, depth + 1):
        ip = stack.getProcessor(z)
        mask_ip = ip.duplicate()
        mask_ip.threshold(t)
        mask_stack.addSlice(mask_ip)
    
    imIn.close()
    mask = ImagePlus("tr-"+ttl, mask_stack)
    return mask

def measure_image(image, threshold, rt):
    calib = image.getCalibration()
    calib.pixelDepth = calib.pixelWidth = calib.pixelHeight = 1
    calib.setUnit("pixel")
    src = image.getTitle()
    mask = make_stack_mask(image, threshold)
    ffcl = FloodFillComponentsLabeling3D(26, 16)
    labeled = ffcl.computeLabels(mask.getStack())
    mask.close()
    labeled_img = ImagePlus("lab-"+image.getTitle(), labeled)
    labeled_img.setCalibration(calib)
    all_labels = LabelImages.findAllLabels(labeled_img)
    all_labels = [l for l in all_labels if l != 0]  # remove background label
    sorted_labels = sorted(all_labels)
    volumes = IntrinsicVolumes3D.volumes(labeled_img.getStack(), sorted_labels, calib)
    boxes = BoundingBox3D.boundingBoxes(labeled_img.getStack(), sorted_labels, calib)
    ellipses = EquivalentEllipsoid.equivalentEllipsoids(labeled_img.getStack(), sorted_labels, calib)
    
    for volume, bbox, ellipse in zip(volumes, boxes, ellipses):
        rt.addRow()
        
        rt.addValue("Source", src)
        rt.addValue("Volume", volume)

        s_x = bbox.width()
        s_y = bbox.height()
        s_z = bbox.depth()

        rt.addValue("R X/Z", s_x / s_z)
        rt.addValue("R Y/Z", s_y / s_z)
        rt.addValue("R X/Y", s_x / s_y)

        rt.addValue("Width", s_x)
        rt.addValue("Height", s_y)
        rt.addValue("Depth", s_z)

        rt.addValue("Ellip. Major", ellipse.radius1())
        rt.addValue("Ellip. Minor", ellipse.radius3())
        rt.addValue("Ellip. Ratio", ellipse.radius1() / ellipse.radius3())

    return labeled_img

def measure_folder(path, threshold):
    content = os.listdir(path)
    content = [c for c in content if (not c.startswith('ctrl-')) and (c.endswith('.tif') or c.endswith('.tiff'))]
    content = sorted(content)
    rt = ResultsTable()
    for img_name in content:
        full_path = os.path.join(path, img_name)
        img = IJ.openImage(full_path)
        ctrl = measure_image(img, threshold, rt)
        IJ.saveAs(ctrl, "TIFF", os.path.join(path, "ctrl-"+img_name))
        ctrl.close()
        rt.show("LLS Angles")

def ask_settings():
    # generic dialog asking for a folder and a threshold
    defaults = {
        'folder'   : "",
        'threshold': 1250
    }
    gd = GenericDialog("Measure settings")
    gd.addDirectoryField("Folder:", defaults['folder'])
    gd.addNumericField("Threshold:", defaults['threshold'], 0)
    gd.showDialog()
    if gd.wasCanceled():
        IJ.log("Measure dialog cancelled by user.")
        return None

    settings = {
        'folder'   : gd.getNextString(),
        'threshold': int(gd.getNextNumber())
    }
    return settings

config = ask_settings()
if config is not None:
    measure_folder(
        config['folder'], 
        config['threshold']
    )
    print("DONE.")