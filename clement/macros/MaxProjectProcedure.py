from __future__ import with_statement, division, print_function

from ij import IJ, WindowManager
from ij.gui import GenericDialog
from ij.io import OpenDialog
from ij.plugin import ChannelSplitter, ZProjector

# Simply opens an image and returns the image and its path
def acquireImage():
	dataPath = IJ.getFilePath("Select an image") # OpenDialog("Choose as image", IJ.getDirectory("home"), "")
	
	if dataPath is None:
		return None
		
	rawImage = None
	try:
		rawImage = IJ.openImage(dataPath)
	except:
		return None
	
	return {'image': rawImage, 'path': dataPath}

# Applies a Gaussian blur to reduce the noise, splits the channels and applies a z-projection (max element)
def preprocess(data):
	srcImg = data['image']
	IJ.run(srcImg, "Gaussian Blur 3D...", "x=4.8 y=4.8 z=1.2"); # Transfer parameters in settings, or measure automatically at the begining of a batch.
	
	if srcImg.getNChannels() != 2:
		IJ.log("Only two channeled images are handled (1:segmentation, 2:data)")
		return None
	
	segmentationChannel, dataChannel = ChannelSplitter.split(srcImg)
	
	segmentationChannel = ZProjector.run(segmentationChannel, "max all");
	dataChannel = ZProjector.run(dataChannel, "max all");
	
	return {'segmentation': segmentationChannel, 'data': dataChannel}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#    MAIN                                                                                         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def main():
	imgData = acquireImage()
	if imgData is None:
		return -1
	preprocess(imgData)
	return 0
	
#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#-#

main()

#   Notes:
#
# - [ ] La projection peut avoir lieu avant qu'on split les channels.
# - [ ] On peut jouer avec la std dev du Gaussian au début avant de train le classifier.
# - [ ] Doit proposer un batch mode qui permet de sélectionner un fichier et de traiter tout ce qui se trouve dans le même dossier que ce fichier.
