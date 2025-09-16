from lls_transforms.lls_transform import lls_transform, get_zeiss_config
from ij import IJ
import math

conf = get_zeiss_config()

if IJ.altKeyDown():
    ang = IJ.getNumber("Deskew angle:", conf['angle_deskew'])
    if ang is not None and not math.isnan(ang):
        conf['angle_deskew'] = ang
        conf['angle_cgt']    = -180 - ang

image = IJ.getImage()
img = lls_transform(
    image, 
    conf['angle_deskew'], 
    conf['angle_cgt'], 
    "Deskew"
)
img.show()