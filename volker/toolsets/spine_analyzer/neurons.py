class Dendrites:
    """Dendrites are represented as line rois in the overlay of the image.
    The spines are part of the segmentation"""

    
    def __init__(self, segmentation):
        """Create new dendrites from a (possibly empty) segmentation.
        """
        self.segmentation = segmentation
        self.image = segmentation.image
        self.overlay = image.getOverlay()
        if not self.overlay:
            self.overlay = Overlay()
            image.setOverlay(overlay)
            
    
    def add(self, roi, frame):
        """Add a new dendrite from a line roi. The dendrite created from a line roi on a z-position
        will be considered as being the same on each z-slice (like a wall).
        """
        roi.setPosition(0, 0, frame)
        self.overlay.add(roi)