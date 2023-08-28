import os
from ij import IJ
from ij import ImagePlus
from ij.plugin import LutLoader

######################## SETTINGS ########################

from_intensity = 0
to_intensity   = 50
lut            = 'Red' # Can take the name of any ImageJ's built-in LUT (Grays, Red, Yellow, ...)

##########################################################

inputDir = IJ.getDirectory("")
outputDir = IJ.getDirectory("")
content  = [f for f in os.listdir(inputDir) if f.lower().endswith(".tif")]
k = 256.0 / (to_intensity - from_intensity)

for imgName in content:
    img  = IJ.openImage(os.path.join(inputDir, imgName))
    print("============= Processing: " + img.getTitle() + " =============")
    proc = img.getProcessor()
    v = 0
    newTitle = '.'.join(img.getTitle().split('.')[:-1])+".png"
    canvas = IJ.createImage(
        newTitle, 
        img.getWidth(),
        img.getHeight(),
        1,
        8
    )
    c_proc = canvas.getProcessor()

    for l in range(img.getHeight()):
        for c in range(img.getWidth()):
            rgb_value = proc.get(c, l)
            v = (rgb_value >> 16) & 0xff
            if v <= from_intensity:
                v = 0
            elif v >= to_intensity:
                v = 255
            else:
                v -= from_intensity
                v *= k
                v = int(v)
            c_proc.set(c, l, v)

    img.close()
    IJ.run(canvas, lut, "")
    IJ.saveAs(canvas, 'PNG', os.path.join(outputDir, newTitle))

print("DONE.")