URL = "https://github.com/MontpellierRessourcesImagerie/imagej_macros_and_scripts/wiki/Spine_Analyzer"
SAVE_OPTIONS = True

def main():   
    image = IJ.getImage()
    segmentation = InstanceSegmentation(image)
    dendrites = Dendrites(segmentation)
    results = dendrites.measure()
    reportResults(results)
    
    
def reportResults:
    pass
    
    
main()