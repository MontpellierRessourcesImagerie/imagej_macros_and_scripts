from ij import IJ
from ij.plugin import Duplicator, ZProjector, ImageCalculator

export_dir = "C:\\Users\\cbenedetti\\Desktop\\dataset\\"
skip       = 12


imIn = IJ.getImage()
n_frames = imIn.getNFrames()
dp = Duplicator()

title = imIn.getTitle()
for f in range(1, 1+n_frames, skip):
	IJ.log("Processing " + str(f))
	imIn.setT(f)
	n_slices = imIn.getNSlices()
	c1 = dp.run(imIn, 1, 1, 1, n_slices, f, f)
	c2 = dp.run(imIn, 2, 2, 1, n_slices, f, f)
	c1_proj = ZProjector.run(c1, "max")
	c2_proj = ZProjector.run(c2, "max")
	c1.close()
	c2.close()
	cell_mask = ImageCalculator.run(c1_proj, c2_proj, "add create")
	c1_proj.close()
	c2_proj.close()
	title_frame = str(f).zfill(4) + "-" + title
	export_path = export_dir + title_frame
	IJ.saveAs(cell_mask, "TIFF", export_path)
	IJ.run("Collect Garbage")
