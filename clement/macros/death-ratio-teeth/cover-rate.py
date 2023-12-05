from ij import IJ, ImagePlus, CompositeImage
from ij.plugin import Duplicator, RGBStackMerge, ImageCalculator
import os
from ij.process import AutoThresholder
from ij.measure import ResultsTable
from ij.gui import GenericDialog


###############################  SETTINGS  ###############################

folder = IJ.getDirectory("home")
tr_method = "Otsu"

##########################################################################


def ask_settings():
    global folder
    global tr_method

    gd = GenericDialog("Settings")
    gd.addDirectoryField("Target folder:", IJ.getDirectory("home"))

    methods = AutoThresholder.getMethods()
    gd.addChoice("Threshold method:", methods, methods[0])

    gd.showDialog()
    
    if gd.wasCanceled():
        return False
    
    folder = gd.getNextString()
    tr_method = gd.getNextChoice()
    
    return True


def threshold_channel(ch, name):
    stats = ch.getProcessor().getStatistics()
    at = AutoThresholder()
    histo = [int(i) for i in stats.histogram()]
    thr = at.getThreshold(tr_method, histo)
    thr = stats.histMin + stats.binSize * thr
    ch.getProcessor().setThreshold(thr, 65535)
    mask = ImagePlus(name, ch.getProcessor().createMask())
    return mask


def make_total_mask(m1, m2, file):
    total = ImageCalculator.run(m1, m2, "or create")
    stats = total.getProcessor().getStatistics()
    total_area = [int(i) for i in stats.histogram()]
    total_area = total_area[255]
    
    return total_area
    

def get_mask_area(mk):
    stats = mk.getProcessor().getStatistics()	
    histo = [int(i) for i in stats.histogram()]
    area = histo[255]
    return area


def assemble_control(alive, dead, file):
    images = [alive, dead]
    merged = RGBStackMerge.mergeChannels(images, False)
    IJ.save(merged, os.path.join(folder, file+"_control.tif"))


def main():
    if not ask_settings():
        return

    results = ResultsTable()
    content = [f for f in os.listdir(folder) if f.lower().endswith("czi")]
    d = Duplicator()

    for file in content:
        print("============ Processing: " + file + " ==============")
        full_path = os.path.join(folder, file)
        imIn = IJ.openImage(full_path)
        
        ch1 = d.run(imIn, 1, 1, 1, 1, 1, 1) # vert
        ch2 = d.run(imIn, 2, 2, 1, 1, 1, 1) # rouge
        imIn.close()
        
        mask_green = threshold_channel(ch1, "green-mask")
        mask_red   = threshold_channel(ch2, "red-mask")
        mask_green = ImageCalculator.run(mask_green, mask_red, "subtract create")
        
        green_area = get_mask_area(mask_green)
        red_area   = get_mask_area(mask_red)
        
        total_area = make_total_mask(mask_green, mask_red, file)
        ratio_green = float(green_area) / float(total_area)
        ratio_red = float(red_area) / float(total_area)

        ch1.close()
        ch2.close()
        assemble_control(mask_green, mask_red, file)
        
        results.addRow()
        results.addValue("source", file)
        results.addValue("alive", ratio_green)
        results.addValue("dead", ratio_red)
        results.show("Results")

main()
    