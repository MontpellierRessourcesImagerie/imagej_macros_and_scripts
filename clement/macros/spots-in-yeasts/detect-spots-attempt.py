from ij import IJ, ImagePlus
from ij.process import ImageProcessor
from ij.plugin import Concatenator, GroupedZProjector, ZProjector, RGBStackMerge
from ij.plugin.filter import MaximumFinder, RankFilters
from ij.gui import PointRoi, NewImage
from ij.plugin.frame import RoiManager
from inra.ijpb.label import LabelImages
from java.awt import Color, Polygon
from ij.process import AutoThresholder
from inra.ijpb.binary.conncomp import FloodFillComponentsLabeling
from inra.ijpb.label.select import LabelSizeFiltering, RelationalOperator
from inra.ijpb.morphology import Strel
from ij.plugin import ImageCalculator

# TODO [ ] Appliquer un flou median de 2 pixels retire des défauts de détection.

def seekSpots(image, tolerance=0.01, sigmas=[3, 5, 7], cellSize=40, maxSpotSize=250):
	"""
	This function produces:
	|  - A polygon representing a set of points, where spots are supposed to be located.
	|  - A binary mask representing the position of dead cells.
	The filtering of spots located in dead cells is not performed in this function.

	image     : The image (fluo) from which the spots have to be extracted.
	tolerance : Threshold used by "Find Maxima". It is the relative displacement between the top of a hill and its base for it to be considered a spot.
	sigmas    : Set of integer representing the scales at which spots are seeked on the image. The results of LoG filters are summed. This way, we don't loose small spots.
	cellSize  : Cell size used to detect dying cells (aka completly marked cells).
	"""
	workingImage  = image.duplicate()
	spotsPolygon  = None # Polygons containing points representing spots location.
	deadCellsMask = None # Binary mask showing the location of dead cells, with some buffer space around.
	RankFilters().rank(workingImage.getProcessor(), 2, RankFilters.MEDIAN)
	
	# - - - PART 1: Isolating spots in cells - - -

	# Seeking for spots with LoG filters of different sizes.
	multiScaleLoGs = []
	for sigma in sigmas:
		IJ.run(workingImage, "FeatureJ Laplacian", "compute smoothing={0}".format(sigma))
		multiScaleLoGs.append(IJ.getImage())
	
	# Assembling slices and summing them into one image.
	stack = Concatenator().concatenate(multiScaleLoGs, False)
	for p in multiScaleLoGs:
		p.close()
	
	proj = GroupedZProjector().groupZProject(stack, ZProjector.SUM_METHOD, len(sigmas))
	proj.getProcessor().invert()
	stack.close()
	
	# - Transforming spots in points and labels:
	spotsMask    = ImagePlus("Spots Mask", MaximumFinder().findMaxima(proj.getProcessor(), tolerance, MaximumFinder.IN_TOLERANCE, True))
	compLab      = FloodFillComponentsLabeling(8, 16)
	labeled      = compLab.computeLabels(spotsMask.getProcessor())
	lsf          = LabelSizeFiltering(RelationalOperator.LT, maxSpotSize)
	filtLabels   = ImagePlus("Spots Labels", lsf.process(labeled))
	proj.close()
	spotsMask.close()

	spotsPolygon = MaximumFinder().getMaxima(filtLabels.getProcessor(), tolerance, False, True)

	# - - - PART 2: Mask representing dead cells - - -
	
	# LoG filter applied with big sigma to seek very bright cells.
	IJ.run(workingImage, "FeatureJ Laplacian", "compute smoothing={0}".format(cellSize))
	LoGdeadCells = IJ.getImage()
	workingImage.close()

	# Transforming LoG result into binary mask.
	deadCellsProcessor = LoGdeadCells.getProcessor()
	deadCellsProcessor.setAutoThreshold(AutoThresholder.Method.MaxEntropy, False, ImageProcessor.BLACK_AND_WHITE_LUT)
	threshold = deadCellsProcessor.getAutoThreshold()
	deadCellsProcessor.threshold(threshold)
	deadCellsMask = ImagePlus("dead-cells-mask-{0}".format(image.getTitle()), deadCellsProcessor.createMask())
	LoGdeadCells.close()
			
	return deadCellsMask, spotsPolygon, filtLabels


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def testing():
	deadCellsMask, spotsLocation, spotsLabels = seekSpots(image=IJ.getImage())
	roi = PointRoi(spotsLocation)
	spotsLabels.setRoi(roi)
	deadCellsMask.show()
	spotsLabels.show()
	IJ.log("DONE.")

testing()
