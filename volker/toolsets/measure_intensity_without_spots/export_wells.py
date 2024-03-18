import os
from ij import ImagePlus
from ij import ImageStack 
from ij.io import FileSaver
from ij.plugin import RGBStackMerge
from loci.plugins import BF
from loci.formats import ImageReader
from loci.plugins.in import ImportProcess
from loci.plugins.in import ImporterOptions

def main():
    PATH = "/home/baecker/Documents/mri/in/marina/Quantification fluorescence/iHCS2301104-07-1et2-col2b-10X_Plate_45944/iHCS2301104-07-1et2-col2b-10X.HTD"
    OUT_PATH = os.path.dirname(PATH)
    OUT_PATH = os.path.join(OUT_PATH, "export")
    
    if not os.path.exists(OUT_PATH):
        os.makedirs(OUT_PATH)

    CHANNELS = 2    
    options = ImporterOptions()
    options.setId(PATH)
    options.setOpenAllSeries(True)
    options.setSplitChannels(True)
    images = list(BF.openImagePlus(options))
    c0Stack = ImageStack(images[0].getWidth(), images[0].getHeight())
    c1Stack = ImageStack(images[0].getWidth(), images[0].getHeight())
    lastWell = None
    title = ""
    c0Images = [image for i, image in enumerate(images) if i%2==0]
    c1Images = [image for i, image in enumerate(images) if i%2==1]
    for c0Image, c1Image in zip(c0Images, c1Images):
        print(c0Image.getTitle(), c1Image.getTitle())
        title = c0Image.getTitle()
        well = title.split("Well ")[1].split(" Field")[0]
        if well == lastWell or lastWell==None: 
            c0Stack.addSlice(c0Image.getProcessor())
            c1Stack.addSlice(c1Image.getProcessor())
        else:
            imageC0 = ImagePlus(title, c0Stack)
            imageC1 = ImagePlus(title.replace("C=0", "C=1"), c1Stack)
            resultImage = RGBStackMerge.mergeChannels([imageC0, imageC1], False)
            saver = FileSaver(resultImage)
            saver.saveAsTiffStack(os.path.join(OUT_PATH, title.replace(" - C=0", "")))
            c0Stack = ImageStack(images[0].getWidth(), images[0].getHeight())
            c1Stack = ImageStack(images[0].getWidth(), images[0].getHeight())
        lastWell = well


main()
