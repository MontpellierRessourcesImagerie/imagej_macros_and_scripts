class ImageInfo:

    
    def __init__(self, image):
        self.image = image
        self.extractWellFromName = True
        self.wellStartMarker = "Well "
        self.wellEndMarker = " Field"
        self.extractFieldFromName = True
        self.fieldStartMarker = "#"
        self.fieldEndMarker = ".tif"
    
    
    def getWell(self):
        if self.extractWellFromName:
            return self. getWellFromName()
        else:
            return self. getWellFromMetadata()
            
            
    def getWellFromName(self):
        title = self.image.getTitle()
        well = title.split(self.wellStartMarker)[1].split(self.wellEndMarker)[0]
        return well
        
   
    def getWellFromMetadata(self):
        pass
        
        
    def getField(self):
        if self.extractFieldFromName:
            return self.getFieldFromName()
        else:
            return getFieldFromMetadata()
            
            
    def getFieldFromName(self):
        title = self.image.getTitle()
        field = title.split(self.fieldStartMarker)[1].split(self.fieldEndMarker)[0]
        return field