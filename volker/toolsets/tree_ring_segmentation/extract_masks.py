from ij import IJ
from ij import ImagePlus
from fr.cnrs.mri.cialib.tree_rings import TreeTrunkGroundTruthHelper

INTERVAL = 50
CLOSING = 2
GRADIANT = 2
DILATION = 1
RING_MASKS_ONLY = True


def main():
    image = IJ.getImage()
    treeTrunkGTHelper = TreeTrunkGroundTruthHelper(image)
    treeTrunkGTHelper.interval = INTERVAL
    treeTrunkGTHelper.closing_radius = CLOSING
    treeTrunkGTHelper.gradiant_radius = GRADIANT
    treeTrunkGTHelper.dilation_radius = DILATION
    treeTrunkGTHelper.ringsOnly = RING_MASKS_ONLY
    mask = treeTrunkGTHelper.createMaskFromRois()
    mask.show()


main()
