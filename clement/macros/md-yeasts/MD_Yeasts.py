from ij import IJ
from ij.plugin.frame import RoiManager
from mdYeasts.makeSegmentation import segmentYeasts, preprocess

def run():
    rm = RoiManager.getInstance()
    if (rm is None) or (rm.getCount() == 0):
        IJ.log("An ROI manager containing at least one ROI is required.")
        return False

    imIn = IJ.getImage()
    if imIn is None:
        IJ.log("An image is required to work")
        return False

    segmentYeasts(rm, imIn)
    rm.runCommand("Deselect")
    return True


def _run_():
    import os
    from ij.plugin import ContrastEnhancer, ImageCalculator, ChannelSplitter, Concatenator
    from ij.plugin.frame import RoiManager

    path = "/home/benedetti/Documents/projects/2-maxime-yeasts/Testing/Segmentation-tests"
    prep = "/home/benedetti/Documents/projects/2-maxime-yeasts/Testing/Segmentation-tests/results/10-prepro-fluo"
    src  = "/home/benedetti/Documents/projects/2-maxime-yeasts/Testing/Segmentation-tests/results/11-sources-fluo"
    
    content = os.listdir(path)

    for i in range(1, 17):

        imgPath = os.path.join(path, "ori_{0}.tif".format(str(i).zfill(2)))
        roiPath = os.path.join(path, "roi_{0}.zip".format(str(i).zfill(2)))
        
        imIn = IJ.openImage(imgPath)

        rm = RoiManager.getInstance() or RoiManager()
        if rm.getCount() > 0:
            rm.reset()
        rm.open(roiPath)
        chunks = imIn.crop(rm.getRoisAsArray(), "stack")

        for idx, chunk in enumerate(chunks):
            transmission, fluo = ChannelSplitter.split(chunk)
            IJ.saveAs(fluo, "tiff", os.path.join(src, "fluo_{0}_{1}.tif".format(str(i).zfill(2), str(idx).zfill(2))))
            preprocessed = preprocess(fluo, biggest=False)
            IJ.saveAs(preprocessed, "tiff", os.path.join(prep, "pfluo_{0}_{1}.tif".format(str(i).zfill(2), str(idx).zfill(2))))
            chunk.close()
            fluo.close()
            transmission.close()
            preprocessed.close()

        imIn.close()


run()
