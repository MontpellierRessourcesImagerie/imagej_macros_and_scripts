# make_isotropic.py
# 
# Author: Volker Baecker
# Date: 22/03/2024
# This script is in the public domain
#
# Jython script translated from the plugin (java):
#
    #     Author: Julian Cooper
    #    Contact: Julian.Cooper [at] uhb.nhs.uk
    #    First version: 2009/05/22
    #    Licence: Public Domain  */
    
    #  Acknowledgements: Erik Meijering, author of TransformJ*/
    
    #  This plugin scales an anisotropically calibrated stack of images so that the
    #    calibration is isotropic (the pixel depth becomes the same as the pixel
    #    width). The plugin will not rescale XY anisotropy.
     
    #    Note: If the pixel depth of the source stack is less than then the width
    #    there will be fewer slices in the output stack resulting in a potential loss
    #    of information.
    
    # Requires imagescience.jar to be installed in plugins folder
    # Available as part of TransformJ written by Erik Meijering
    # http://www.imagescience.org/meijering/software/transformj/ 


from ij import IJ
from fr.cnrs.mri.cialib.plasmodium import MakeIsotropic


URL = "https://github.com/MontpellierRessourcesImagerie/plasmodium-organelle-analysis"
PROJECT = "plasmodium-organelle-analysis"


def main():
    image = IJ.getImage()
    makeIsotropic = MakeIsotropic(PROJECT, URL)
    makeIsotropic.setImage(image)
    makeIsotropic.run()
    resultImage = makeIsotropic.getResultImage()
    resultImage.show()
    
    
main()
