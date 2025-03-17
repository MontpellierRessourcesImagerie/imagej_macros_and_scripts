import ij.plugin.frame.RoiManager


def imageData = getCurrentImageData()
def name = GeneralTools.stripExtension(imageData.getServer().getMetadata().getName())
def path = buildFilePath(PROJECT_BASE_DIR, name + ".zip")

def annotations = getAnnotationObjects()
def roiMan = new RoiManager(false)
double x = 0
double y = 0
double downsample = 1 // Increase if you want to export to work at a lower resolution
annotations.each {
  def roi = IJTools.convertToIJRoi(it.getROI(), x, y, downsample)
  roiMan.addRoi(roi)
}
print("Writing File " + path)
roiMan.runCommand("Save", path)
roiMan.runCommand("Reset")