from ij import IJ
from ij.plugin.frame import RoiManager
from ij.plugin import ContrastEnhancer
import os

testingDir = "/home/benedetti/Bureau/testingYeasts"
outputPath = "/home/benedetti/Bureau/testingYeasts/results"

if not os.path.isdir(outputPath):
    os.mkdir(outputPath)



def makeLaplacian(img):
    IJ.run(img, "FeatureJ Laplacian", "compute smoothing=0.25")

    tres = IJ.getImage()
    res = tres.duplicate()
    tres.close()
    img.close()

    return res


def segment(img):

    # 0. Acquire tile
    d = img.duplicate()
    img.close()

    # 1. Enhance contrast (equalize + normalize)
    # ce = ContrastEnhancer()
    # ce.setNormalize(True)
    # ce.equalize(d)
    # ce.stretchHistogram(d, 0.35)
    IJ.run(d, "Enhance Contrast...", "saturated=0.35 normalize equalize")

    # 2. Laplacian (@ 0.25)
    lp = makeLaplacian(d)

    # 3. Threshold (w/ Otsu)
    IJ.setAutoThreshold(lp, "Otsu dark no-reset")
    IJ.run(lp, "Convert to Mask", "")

    # 4. Invert
    IJ.run(lp, "Invert", "")

    # 6. Label connected components & keep the largest
    IJ.run(lp, "Connected Components Labeling", "connectivity=4 type=[16 bits]")
    temp = IJ.getImage()
    compos = temp.duplicate()
    temp.close()
    lp.close()

    IJ.run(compos, "Keep Largest Label", "")
    temp = IJ.getImage()
    largest = temp.duplicate()
    temp.close()
    compos.close()

    # 7. Closing or find a way to detect gaps
    
    # 8. Return
    return largest


def mainLoop():

    for i in range(1, 17):
        oriPath = os.path.join(testingDir, "ori_{0}.tif".format(str(i).zfill(2)))
        roiPath = os.path.join(testingDir, "roi_{0}.zip".format(str(i).zfill(2)))
        
        ori = IJ.openImage(oriPath)
        rm = RoiManager()

        try:
            rm.runCommand("open", roiPath)
        except:
            print("Failed", oriPath)
            continue

        print(oriPath)
        print(roiPath)

        imgs = ori.crop(rm.getRoisAsArray())
        nRois = rm.getCount()

        for idx, img in enumerate(imgs):
            cName = "segPair_{0}_{1}.tif".format(str(i).zfill(2), str(idx).zfill(2))
            oName = "oriPair_{0}_{1}.tif".format(str(i).zfill(2), str(idx).zfill(2))
            IJ.saveAs(img, "tiff", os.path.join(outputPath, oName))

            img2 = segment(img)
            
            IJ.saveAs(img2, "tiff", os.path.join(outputPath, cName))
            img2.close()
        
        ori.close()
        rm.runCommand("delete")
        rm.close()

mainLoop()
print("DONE.")