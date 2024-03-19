import os
from ij import ImagePlus
from ij import ImageStack 
from ij.io import FileSaver
from ij.io import OpenDialog
from ij.plugin import RGBStackMerge
from loci.plugins import BF
from loci.plugins.in import ImporterOptions
from loci.formats import ImageReader
from fr.cnrs.mri.cialib.conversion import BFWellsSeriesToTifStackSeries

def main():    
    od = OpenDialog("Choose a file", None)
    folder = od.getDirectory()
    file = od.getFileName()
    path = folder + file
    converter = BFWellsSeriesToTifStackSeries(path)
    converter.run()

main()
