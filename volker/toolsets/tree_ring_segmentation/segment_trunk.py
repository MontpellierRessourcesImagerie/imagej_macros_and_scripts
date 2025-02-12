from ij import IJ
from ij import Prefs
from fr.cnrs.mri.cialib.tree_rings import TreeRingAnalyzer

        
SAVE_OPTIONS = True       


def main():
    optionsOnly = Prefs.get("mri.options.only", "false")
    if optionsOnly=="true":
        treeRingAnalyzer = TreeRingAnalyzer(None)
    else:
        image = IJ.getImage()
        image.setOverlay(None)
        treeRingAnalyzer = TreeRingAnalyzer(image)
    if not treeRingAnalyzer.showDialog(SAVE_OPTIONS):
        return
    if optionsOnly=='true':        
        return
    treeRingAnalyzer.run()
    
    
main()    
