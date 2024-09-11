from ij import IJ
from ij import ImagePlus
from ij import Prefs
from fr.cnrs.mri.cialib.tree_rings import TreeTrunkGroundTruthHelper

SAVE_OPTIONS = True


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if optionsOnly=="true":
        treeTrunkGTHelper = TreeTrunkGroundTruthHelper(None)
    else:
        image = IJ.getImage()
        treeTrunkGTHelper = TreeTrunkGroundTruthHelper(image)
    if not treeTrunkGTHelper.showCreateMaskFromRoisDialog(SAVE_OPTIONS):
        return
    if optionsOnly=='true':        
        return
    mask = treeTrunkGTHelper.createMaskFromRois()
    mask.show()


main()
