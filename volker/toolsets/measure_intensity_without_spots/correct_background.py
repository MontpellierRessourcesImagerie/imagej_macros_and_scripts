from ij import IJ

CHANNEL = 2
LAMBDA_FLAT = 0.50
LAMBDA_DARK = 0.50
image = IJ.getImage()
width, height, nChannels, nSlices, nFrames = image.getDimensions()
spotsChannelImage = Duplicator().run(image, CHANNEL, CHANNEL, 1, nSlices, 1, nFrames)
title = spotsChannelImage.getTitle()
IJ.run(spotsChannelImage, "BaSiC ", "processing_stack=[" + spotsChannelImage.getTitle() + "] flat-field=None dark-field=None shading_estimation=[Estimate shading profiles] shading_model=[Estimate both flat-field and dark-field] setting_regularisationparametes=Automatic temporal_drift=[Replace with zero] correction_options=[Compute shading and correct images] lambda_flat=" + LAMBDA_FLAT + " lambda_dark=" + LAMBDA_DARK)
IJ.selectImage()
