from loci.plugins.in import ImporterOptions
from loci.formats import ImageReader
from ij.io import OpenDialog


def main():
    openDialog = OpenDialog("Select a file or folder")
    
    inPath = openDialog.getPath()
    inDir = openDialog.getDirectory()
    inFile = openDialog.getFileName()
    
    reader = ImageReader()
    reader.setId(inPath)
    seriesCount = reader.getSeriesCount()
    
    if seriesCount>1:
        batchProcessSeries(inFile, inDir, inPath, seriesCount)
    else:
        batchProcessFiles(inFile, inDir, inPath)
        

def batchProcessSeries(inFile, inDir, inPath, seriesCount):
    for s in range(1, seriesCount+1):
        print(str(s))
    
    
def batchProcessFiles(inFile, inDir, inPath):
    pass
    

main()


