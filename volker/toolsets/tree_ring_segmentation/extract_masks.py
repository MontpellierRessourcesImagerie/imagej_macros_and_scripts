from java.awt import Color
from ij import IJ
from ij.gui import NewImage
from ij import ImagePlus
from ij.gui import Roi
from ij.gui import PolygonRoi
from ij.gui import Overlay
from ij.plugin.filter import ThresholdToSelection
from inra.ijpb.morphology import Strel
from inra.ijpb.morphology.filter import Closing
from inra.ijpb.morphology.filter import InternalGradient
from inra.ijpb.morphology.filter import Dilation


INTERVAL = 50
CLOSING = 2
RING_MASKS_ONLY = True

def main():
    image = IJ.getImage()
    mask = createMask(image)
    mask.show()

def createMask(image):
    mask = NewImage.createByteImage ("mask of rings", image.getWidth(), image.getHeight(), 1, NewImage.FILL_BLACK)        
    mask.setOverlay(Overlay())
    overlay = image.getOverlay()
    rois = []
    
    closing = Closing(Strel.Shape.OCTAGON.fromRadius(2))
    internalGradient = InternalGradient(Strel.Shape.DISK.fromRadius(2))
    dilation = Dilation(Strel.Shape.DISK.fromRadius(1))
    
    for i in range(0, overlay.size()):
        tmp = NewImage.createByteImage ("tmp mask of rings", image.getWidth(), image.getHeight(), 1, NewImage.FILL_BLACK) 
        roi = overlay.get(i)
        print("roi " + str(i) + ", type: ", roi.getTypeAsString())
        poly = roi.getInterpolatedPolygon(50, True)
        if not poly.xpoints[-1] == poly.xpoints[0] or not poly.ypoints[-1] == poly.ypoints[0]:
            poly.addPoint(poly.xpoints[0], poly.ypoints[0])
        roi = PolygonRoi(poly, Roi.POLYGON)
        tmp.setRoi(roi)
        tmpMask = tmp.createRoiMask()
        ip = closing.process(tmpMask)
        tmp.setProcessor(ip)   
        ip = internalGradient.process(ip)
        ip = dilation.process(ip)
        ip.setThreshold(1, 255)
        tmp.setProcessor(ip)
        roi = ThresholdToSelection().run(tmp)    
        print("roi", roi)
        rois.append(roi)
        
    
    smallestIndex = -1
    biggestIndex = -1
    smallestLength = image.getWidth() * image.getHeight()
    biggestLength = 0
    
    if RING_MASKS_ONLY:
        for index, roi in enumerate(rois):
            length = roi.getLength()
            if length < smallestLength:
                smallestLength = length
                smallestIndex = index
            if length > biggestLength:
                biggestLength = length
                biggestIndex = index
    
    toBeRemoved = [smallestIndex, biggestIndex]
    for index, roi in enumerate(rois):
        if index in toBeRemoved:
            continue
        mask.getOverlay().add(roi)
    
        
    mask.setRoi(None)   
    mask.getOverlay().fill(mask, Color.WHITE, Color.BLACK)
    mask.setOverlay(None)
    return mask

main()
