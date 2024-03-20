from ij import IJ
from ij import WindowManager
from ij.plugin import Duplicator
from ij.plugin import RGBStackMerge


def main():
    SPOTS_CHANNEL = 2
    NUCLEI_CHANNEL = 1
    LAMBDA_FLAT = 0.50
    LAMBDA_DARK = 0.50
    image = IJ.getImage()
    width, height, nChannels, nSlices, nFrames = image.getDimensions()
    spotsChannelImage = Duplicator().run(image, SPOTS_CHANNEL, SPOTS_CHANNEL, 1, nSlices, 1, nFrames)
    spotsChannelImage.show()
    title = spotsChannelImage.getTitle()
    IJ.run(spotsChannelImage, "BaSiC ", "processing_stack=[" + spotsChannelImage.getTitle() + "] flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=[Replace with zero] correction_options=[Compute shading and correct images] lambda_flat=" + str(LAMBDA_FLAT) + " lambda_dark=" + str(LAMBDA_DARK))
    correctedSpotsImage = IJ.getImage()
    closeWindow("Dark-field:" + title)
    closeWindow("Flat-field:" + title)
    closeWindow("Basefluor")
    closeWindow("Temporal components")
    spotsChannelImage.close()
    nucleiChannelImage = Duplicator().run(image, NUCLEI_CHANNEL, NUCLEI_CHANNEL, 1, nSlices, 1, nFrames)
    resultImage = RGBStackMerge.mergeChannels([nucleiChannelImage, correctedSpotsImage], False)
    correctedSpotsImage.close()
    image.close()
    resultImage.setTitle(title)
    resultImage.show()
    

def closeWindow(title):
    win = WindowManager.getWindow(title)
    win.close()
    
    
main()