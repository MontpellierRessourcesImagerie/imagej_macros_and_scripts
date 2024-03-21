from ij.io import OpenDialog
from fr.cnrs.mri.cialib.process import ImageIterator
from fr.cnrs.mri.cialib.quantification import StainingAnalyzer


def main():
    openDialog = OpenDialog("Select a file or folder")
    
    inPath = openDialog.getPath()
    inDir = openDialog.getDirectory()
    inFile = openDialog.getFileName()
    
    iterator = ImageIterator.getInstance(inPath)
    
    while(iterator.hasNext()):
        image = iterator.next()
        title = image.getTitle()
        analyzer = StainingAnalyzer(image, 1, 2)
        analyzer.setMinAreaNucleus(50)
        analyzer.measure()
        analyzer.createOverlayOfResults()
        analyzer.results.show("measurements of " + title)
    

main()


