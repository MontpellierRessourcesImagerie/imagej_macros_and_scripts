from ij.gui import Overlay


class Dendrites:
    """Dendrites are represented as line rois in the overlay of the image.
    The spines are part of the segmentation"""

    
    def __init__(self, segmentation):
        """Create new dendrites from a (possibly empty) segmentation.
        """
        self.segmentation = segmentation
        self.image = segmentation.image
        self.overlay = self.image.getOverlay()
        if not self.overlay:
            self.overlay = Overlay()
            self.image.setOverlay(self.overlay)
            
    
    def add(self, roi, frame):
        """Add a new dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        roi.setPosition(0, 0, frame)
        self.overlay.add(roi)
        
"""
'''Track dendrites'''

from ij import IJ

max_dist = 20


image = IJ.getImage()
width, height, nChannels, nSlices, nFrames = image.getDimensions()
overlay = image.getOverlay()
rois = overlay.toArray()

minT = 999999999
maxT = -999999999
for i in range(0, len(rois)):
    roi = rois[i]
    print(roi)
    t = roi.getTPosition()
    if t > maxT:
        maxT = t
    if t < minT:
        minT = t
    roi.setGroup(i+1)

    
dendritesByTime = [[] for x in range(0, nFrames)]

for i in range(0, len(rois)):
    roi = rois[i]
    t = roi.getTPosition()
    x = roi.getBounds().getCenterX()
    y = roi.getBounds().getCenterY()
    dendritesByTime[t-1].append((roi, (x, y)))
    
print(dendritesByTime)
"""