import os
from loci.plugins import BF
from loci.plugins.in import ImporterOptions
from loci.formats import ImageReader


class ImageIterator(object):
    
    
    @classmethod
    def getInstance(cls, path):
        reader = ImageReader()
        reader.setId(path)
        seriesCount = reader.getSeriesCount()    
        if seriesCount>1:
           return SeriesImageIterator(path)
        else:
           return TifSeriesIterator(path)
    
    
    def __init__(self, path):
        super(ImageIterator, self).__init__()
        self.path = path
        self.index = 0
        self.numberOfImages = 0
        
    
    def next(self):
        return self.__next__()
    
    
    def hasNext(self):
        return self.index < self.numberOfImages
        
        
    
class SeriesImageIterator(ImageIterator):


    def __init__(self, path):
        super(SeriesImageIterator, self).__init__(path)
        reader = ImageReader()
        reader.setId(self.path)
        self.numberOfImages = reader.getSeriesCount()     
        self.index = 0
                
        
    def __next__(self):
        if self.index >= self.numberOfImages:
             return False
        options = ImporterOptions()
        options.setId(self.path)
        options.setOpenAllSeries(False)
        options.setSplitChannels(False)
        options.setSeriesOn(self.index, True)
        res = BF.openImagePlus(options)[0]
        self.index = self.index + 1
        return res
        
        
     
class TifSeriesIterator(ImageIterator):


    @classmethod
    def getImagesInFolder(cls, path, extensions):
        images = []
        for file in os.listdir(path):
            _, ext = os.path.splitext(file)
            ext = ext.lower()
            if not ext in extensions: 
                continue
            images.append(file)
        return images
            
    
    def __init__(self, path):
        super(TifSeriesIterator, self).__init__(path)
        self.path = os.path.dirname(self.path)
        self.images = TifSeriesIterator.getImagesInFolder(self.path, [".tif", ".tiff"])
        self.numberOfImages = len(self.images)
        self.index = 0
        
            
    def __next__(self):
        if self.index >= self.numberOfImages:
            return False
        options = ImporterOptions()
        options.setId(os.path.join(self.path, self.images[self.index]))
        options.setOpenAllSeries(False)
        options.setSplitChannels(False)
        res = BF.openImagePlus(options)[0]
        self.index = self.index + 1
        return res