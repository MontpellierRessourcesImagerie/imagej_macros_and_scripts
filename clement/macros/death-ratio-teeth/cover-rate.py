from ij import IJ, ImagePlus
from ij.plugin import Duplicator
import os
from ij.process import AutoThresholder
from ij.plugin import ImageCalculator
from ij.measure import ResultsTable

folder = "/home/benedetti/Documents/projects/19-cover-rate"
content = [f for f in os.listdir(folder) if f.lower().endswith("czi")]
d = Duplicator()


def threshold_channel(ch, name):
	stats = ch.getProcessor().getStatistics()
	at = AutoThresholder()
	histo = [int(i) for i in stats.histogram()]
	thr = at.getThreshold(AutoThresholder.Method.Otsu, histo)
	thr = stats.histMin + stats.binSize * thr
	ch.getProcessor().setThreshold(thr, 65535)
	mask = ImagePlus(name, ch.getProcessor().createMask())
	return mask


def make_total_mask(m1, m2, file):
	total = ImageCalculator.run(m1, m2, "or create")
	stats = total.getProcessor().getStatistics()
	total_area = [int(i) for i in stats.histogram()]
	total_area = total_area[255]
	
	IJ.save(total, os.path.join(folder, file+"_mask.tif"))
	
	return total_area
	

def get_mask_area(mk):
	stats = mk.getProcessor().getStatistics()	
	histo = [int(i) for i in stats.histogram()]
	area = histo[255]
	return area


results = ResultsTable()
for file in content:
	print("============ Processing: " + file + " ==============")
	full_path = os.path.join(folder, file)
	imIn = IJ.openImage(full_path)
	# vert
	ch1 = d.run(imIn, 1, 1, 1, 1, 1, 1)
	# rouge
	ch2 = d.run(imIn, 2, 2, 1, 1, 1, 1)
	imIn.close()
	
	mask_green = threshold_channel(ch1, "green-mask")
	mask_red = threshold_channel(ch2, "red-mask")
	mask_green = ImageCalculator.run(mask_green, mask_red, "subtract create")
	
	green_area = get_mask_area(mask_green)
	red_area = get_mask_area(mask_red)
	
	total_area = make_total_mask(mask_green, mask_red, file)
	ratio_green = float(green_area) / float(total_area)
	ratio_red = float(red_area) / float(total_area)
	
	
	results.addRow()
	results.addValue("alive", ratio_green)
	results.addValue("dead", ratio_red)
	results.addValue("source", file)
	results.show("Results")
	