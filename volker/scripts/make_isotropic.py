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


def main():
    image = IJ.getImage()
    makeIsotropic = MakeIsotropic(image)
    if not makeIsotropic.run():
    	return
    resultImage = makeIsotropic.getResultImage()
    resultImage.show()
    
    

class MakeIsotropic:
    
    
    def __init__(self, image):
    	self.image = image
    	self.resultImage = None
    	

    def run(self):
        if self.image.getStackSize() == 1: 
            IJ.error("Stack required")
            return    
        cal = self.image.getCalibration()
        scaling = cal.pixelDepth/cal.pixelWidth
        if scaling == 1:
            IJ.log("Make Isotropic: Stack already isotropic")
            return False
        IJ.run(self.image, "TransformJ Scale", "x-factor=1.0 y-factor=1.0 z-factor="+str(scaling)+" interpolation=Linear")
        self.resultImage = IJ.getImage()
        self.resultImage.hide()
        self.resultImage.setTitle(self.image.getTitle()+ " - isotropic")
        self.resultImage.setCalibration(cal)
        cal_sca = self.resultImage.getCalibration()
        cal_sca.pixelDepth = cal_sca.pixelWidth
        return True
        
        
    def getResultImage(self):
    	return self.resultImage
    	
        
main()
