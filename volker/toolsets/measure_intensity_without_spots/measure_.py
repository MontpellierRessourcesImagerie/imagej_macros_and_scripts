from ij import IJ
from fr.cnrs.mri.cialib.quantification import StainingAnalyzer

def main():
    image = IJ.getImage()
    title = image.getTitle()
    analyzer = StainingAnalyzer(image, 1, 2)
    analyzer.setMinAreaNucleus(50)
    analyzer.measure()
    analyzer.createOverlayOfResults()
    analyzer.results.show("measurements of " + title)


main()